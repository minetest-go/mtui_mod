globals = {
	"mtui",
	"minetest",
	"technic",
	"mail",
	"beerchat"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump", "dump2",
	"VoxelArea",

	-- deps
	"monitoring",
	"mtt",
	"mesecon"
}
