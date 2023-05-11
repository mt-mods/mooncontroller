local MP = minetest.get_modpath("mooncontroller")

dofile(MP.."/controller.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP .. "/controller.spec.lua")
end