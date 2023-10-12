
-- enable switch or press button for an amount of time
mtui.register_on_command("mesecons_enable", function(data)
    -- TODO
end)

-- disable switch
mtui.register_on_command("mesecons_disable", function(data)
    -- TODO
end)


-- catch on/off events from lightstones
local lightstone_colors = {"red", "green", "blue", "gray", "darkgray",
    "yellow", "orange", "white", "pink", "magenta", "cyan", "violet"}
for _, color in ipairs(lightstone_colors) do
    local def_on = minetest.registered_nodes["mesecons_lightstone:lightstone_" .. color .. "_on"]
    if def_on then
        local old_action_on = def_on.mesecons.action_on
        def_on.mesecons.action_on = function(pos, node)
            mtui.send_command({
                type = "mesecons_on",
                data = {
                    pos = pos,
                    state = "on",
                    color = color,
                    name = node.name
                }
            })
            return old_action_on(pos, node)
        end
    end

    local def_off = minetest.registered_nodes["mesecons_lightstone:lightstone_" .. color .. "_off"]
    if def_off then
        local old_action_off = def_off.mesecons.action_off
        def_off.mesecons.action_off = function(pos, node)
            mtui.send_command({
                type = "mesecons_off",
                data = {
                    pos = pos,
                    state = "off",
                    color = color,
                    name = node.name
                }
            })
            return old_action_off(pos, node)
        end
    end
end