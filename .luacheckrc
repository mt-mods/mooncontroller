globals = {
	"mooncontroller"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest", "vector", "ItemStack",
	"dump", "dump2",
	"AreaStore",
	"VoxelArea",

	-- hard deps
	"mesecon", "default",

	-- opt deps
	"mtt", "dreambuilder_theme", "digiline"
}

ignore = {
	"631" -- line too long
}
