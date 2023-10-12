
local button_off_def = assert(minetest.registered_nodes["mesecons_button:button_off"])
local switch_off_def = assert(minetest.registered_nodes["mesecons_switch:mesecon_switch_off"])
local switch_on_def = assert(minetest.registered_nodes["mesecons_switch:mesecon_switch_on"])

-- ui -> game
-- enable/disable switch or press button for an amount of time
mtui.register_on_command("mesecons_set", function(data)
    minetest.load_area(data.pos)
    local node = minetest.get_node_or_nil(data.pos)
    if node == nil then
        -- not loaded
        return
    end

    if data.state == "on" then
        if node.name == "mesecons_switch:mesecon_switch_off" then
            -- switch in off-state, turn on
            switch_off_def.on_rightclick(data.pos, node)
        elseif node.name == "mesecons_button:button_off" then
            -- button in off-state, turn on for 1 second
            button_off_def.on_rightclick(data.pos, node)
            -- call turnoff async, in case the node-timer does not fire (unloaded area)
            minetest.after(1, mesecon.button_turnoff, data.pos)
        end
    elseif data.state == "off" then
        if node.name == "mesecons_switch:mesecon_switch_on" then
            -- switch in on-state, turn off
            switch_on_def.on_rightclick(data.pos, node)
        end
    end
end)

-- game -> ui
-- catch switch states

-- on -> off
local old_switch_on_rightclick_action = switch_on_def.on_rightclick
switch_on_def.on_rightclick = function(pos, node)
    mtui.send_command({
        type = "mesecons_event",
        data = {
            pos = pos,
            state = "off",
            name = node.name
        }
    })
    return old_switch_on_rightclick_action(pos, node)
end

-- off -> on
local old_switch_off_rightclick_action = switch_off_def.on_rightclick
switch_off_def.on_rightclick = function(pos, node)
    mtui.send_command({
        type = "mesecons_event",
        data = {
            pos = pos,
            state = "on",
            name = node.name
        }
    })
    return old_switch_off_rightclick_action(pos, node)
end


-- catch on/off events from lightstones
local lightstone_colors = {"red", "green", "blue", "gray", "darkgray",
    "yellow", "orange", "white", "pink", "magenta", "cyan", "violet"}
for _, color in ipairs(lightstone_colors) do
    local def_on = minetest.registered_nodes["mesecons_lightstone:lightstone_" .. color .. "_on"]
    if def_on then
        local old_action_on = def_on.mesecons.action_on
        def_on.mesecons.action_on = function(pos, node)
            mtui.send_command({
                type = "mesecons_event",
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
                type = "mesecons_event",
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