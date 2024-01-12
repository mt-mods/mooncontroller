
mooncontroller.rules = {
	a = {x = -1, y = 0, z =  0, name="A"},
	b = {x =  0, y = 0, z =  1, name="B"},
	c = {x =  1, y = 0, z =  0, name="C"},
	d = {x =  0, y = 0, z = -1, name="D"},
}

-- Performs a deep copy of a table, changing the environment of any functions.
-- Adapted from the builtin table.copy() function.
function mooncontroller.tablecopy_change_env(t, env, seen)
	local n = {}
	seen = seen or {}
	seen[t] = n
	for k, v in pairs(t) do
		if type(v) == "function" then
			setfenv(v, env)
			n[(type(k) == "table" and (seen[k] or mooncontroller.tablecopy_change_env(k, env, seen))) or k] = v
		else
		n[(type(k) == "table" and (seen[k] or mooncontroller.tablecopy_change_env(k, env, seen))) or k] =
			(type(v) == "table" and (seen[v] or mooncontroller.tablecopy_change_env(v, env, seen))) or v
		end
	end
	return n
end

function mooncontroller.terminal_clear(pos)
	minetest.get_meta(pos):set_string("terminal_text","")
end
