
local function register(on_nodename, off_nodename)
    local def_on = minetest.registered_nodes[on_nodename]
    if not def_on then
        return
    end

    mtui.mesecons.allowed_nodes[on_nodename] = true
    mtui.mesecons.allowed_nodes[off_nodename] = true

    local old_action_off = assert(def_on.mesecons.effector.action_off)
    def_on.mesecons.effector.action_off = function(pos, node)
        mtui.send_command({
            type = "mesecons_event",
            data = {
                pos = pos,
                state = "off",
                nodename = off_nodename
            }
        })
        return old_action_off(pos, node)
    end

    local def_off = assert(minetest.registered_nodes[off_nodename])
    local old_action_on = assert(def_off.mesecons.effector.action_on)
    def_off.mesecons.effector.action_on = function(pos, node)
        mtui.send_command({
            type = "mesecons_event",
            data = {
                pos = pos,
                state = "on",
                nodename = on_nodename
            }
        })
        return old_action_on(pos, node)
    end
end

-- catch on/off events from lightstones
local lightstone_colors = {
    "red",
    "green",
    "blue",
    "gray",
    "darkgray",
    "yellow",
    "orange",
    "white",
    "pink",
    "magenta",
    "cyan",
    "violet"
}

for _, color in ipairs(lightstone_colors) do
    local on_nodename = "mesecons_lightstone:lightstone_" .. color .. "_on"
    local off_nodename = "mesecons_lightstone:lightstone_" .. color .. "_off"
    register(on_nodename, off_nodename)
end

-- mcl2 fork of mesecons
register("mesecons_lightstone:lightstone_on", "mesecons_lightstone:lightstone_off")