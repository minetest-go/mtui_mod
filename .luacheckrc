globals = {
	"mtui",
	"minetest",
	"technic",
	"mail"
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
	"beerchat"
}
