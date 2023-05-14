------------------
-- Action stuff --
------------------
-- These helpers are required to set the port states of the luacontroller

function mooncontroller.update_real_port_states(pos, rule_name, new_state)
	local meta = minetest.get_meta(pos)
	if rule_name == nil then
		meta:set_int("real_portstates", 1)
		return
	end
	local n = meta:get_int("real_portstates") - 1
	local L = {}
	for i = 1, 4 do
		L[i] = n % 2
		n = math.floor(n / 2)
	end
	--                   (0,-1) (-1,0)      (1,0) (0,1)
	local pos_to_side = {  4,     1,   nil,   3,    2 }
	if rule_name.x == nil then
		for _, rname in ipairs(rule_name) do
			local port = pos_to_side[rname.x + (2 * rname.z) + 3]
			L[port] = (new_state == "on") and 1 or 0
		end
	else
		local port = pos_to_side[rule_name.x + (2 * rule_name.z) + 3]
		L[port] = (new_state == "on") and 1 or 0
	end
	meta:set_int("real_portstates",
		1 +
		1 * L[1] +
		2 * L[2] +
		4 * L[3] +
		8 * L[4])
end


local port_names = {"a", "b", "c", "d"}

function mooncontroller.get_real_port_states(pos)
	-- Determine if ports are powered (by itself or from outside)
	local meta = minetest.get_meta(pos)
	local L = {}
	local n = meta:get_int("real_portstates") - 1
	for _, name in ipairs(port_names) do
		L[name] = ((n % 2) == 1)
		n = math.floor(n / 2)
	end
	return L
end


function mooncontroller.merge_port_states(ports, vports)
	return {
		a = ports.a or vports.a,
		b = ports.b or vports.b,
		c = ports.c or vports.c,
		d = ports.d or vports.d,
	}
end

local function generate_name(ports)
	local d = ports.d and 1 or 0
	local c = ports.c and 1 or 0
	local b = ports.b and 1 or 0
	local a = ports.a and 1 or 0
	return mooncontroller.BASENAME..d..c..b..a
end


local function set_port(pos, rule, state)
	if state then
		mesecon.receptor_on(pos, {rule})
	else
		mesecon.receptor_off(pos, {rule})
	end
end


local function clean_port_states(ports)
	ports.a = ports.a and true or false
	ports.b = ports.b and true or false
	ports.c = ports.c and true or false
	ports.d = ports.d and true or false
end


function mooncontroller.set_port_states(pos, ports)
	local node = minetest.get_node(pos)
	local name = node.name
	clean_port_states(ports)
	local vports = minetest.registered_nodes[name].virtual_portstates
	local new_name = generate_name(ports)

	if name ~= new_name and vports then
		-- Problem:
		-- We need to place the new node first so that when turning
		-- off some port, it won't stay on because the rules indicate
		-- there is an onstate output port there.
		-- When turning the output off then, it will however cause feedback
		-- so that the luacontroller will receive an "off" event by turning
		-- its output off.
		-- Solution / Workaround:
		-- Remember which output was turned off and ignore next "off" event.
		local meta = minetest.get_meta(pos)
		local ign = minetest.deserialize(meta:get_string("ignore_offevents"), true) or {}
		if ports.a and not vports.a and not mesecon.is_powered(pos, mooncontroller.rules.a) then ign.A = true end
		if ports.b and not vports.b and not mesecon.is_powered(pos, mooncontroller.rules.b) then ign.B = true end
		if ports.c and not vports.c and not mesecon.is_powered(pos, mooncontroller.rules.c) then ign.C = true end
		if ports.d and not vports.d and not mesecon.is_powered(pos, mooncontroller.rules.d) then ign.D = true end
		meta:set_string("ignore_offevents", minetest.serialize(ign))

		minetest.swap_node(pos, {name = new_name, param2 = node.param2})

		if ports.a ~= vports.a then set_port(pos, mooncontroller.rules.a, ports.a) end
		if ports.b ~= vports.b then set_port(pos, mooncontroller.rules.b, ports.b) end
		if ports.c ~= vports.c then set_port(pos, mooncontroller.rules.c, ports.c) end
		if ports.d ~= vports.d then set_port(pos, mooncontroller.rules.d, ports.d) end
	end
end
