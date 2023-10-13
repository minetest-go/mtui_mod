local switch_off_name = "mesecons_switch:mesecon_switch_off"
local switch_on_name = "mesecons_switch:mesecon_switch_on"

local switch_off_def = assert(minetest.registered_nodes[switch_off_name])
local switch_on_def = assert(minetest.registered_nodes[switch_on_name])

mtui.mesecons.allowed_nodes[switch_on_name] = true
mtui.mesecons.allowed_nodes[switch_off_name] = true

-- ui -> game
-- enable/disable switch
mtui.register_on_command("mesecons_set", function(data)
    minetest.load_area(data.pos)
    local node = minetest.get_node_or_nil(data.pos)
    if node == nil then
        -- not loaded
        return { success = false }
    end

    if data.state == "on" then
        if node.name == switch_off_name then
            -- switch in off-state, turn on
            switch_off_def.on_rightclick(data.pos, node)
            return { success = true }
        end
    elseif data.state == "off" then
        if node.name == switch_on_name then
            -- switch in on-state, turn off
            switch_on_def.on_rightclick(data.pos, node)
            return { success = true }
        end
    end

    return { success = false }
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
            nodename = switch_off_name
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
            nodename = switch_on_name
        }
    })
    return old_switch_off_rightclick_action(pos, node)
end
