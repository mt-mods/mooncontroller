local MP = minetest.get_modpath("mooncontroller")

mooncontroller = {
	BASENAME = "mooncontroller:mooncontroller"
}

dofile(MP.."/common.lua")
dofile(MP.."/libraries.lua")
dofile(MP.."/port_states.lua")
dofile(MP.."/controller.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP .. "/controller.spec.lua")
end