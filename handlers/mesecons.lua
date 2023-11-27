local allowed_nodes = {
    ["mesecons_switch:mesecon_switch_off"] = true,
    ["mesecons_switch:mesecon_switch_on"] = true
}

local switch_off_def = assert(minetest.registered_nodes["mesecons_switch:mesecon_switch_off"])
local switch_on_def = assert(minetest.registered_nodes["mesecons_switch:mesecon_switch_on"])

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
        if node.name == "mesecons_switch:mesecon_switch_off" then
            -- switch in off-state, turn on
            switch_off_def.on_rightclick(data.pos, node)
            return { success = true }
        end
    elseif data.state == "off" then
        if node.name == "mesecons_switch:mesecon_switch_on" then
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
            nodename = "mesecons_switch:mesecon_switch_off"
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
            nodename = "mesecons_switch:mesecon_switch_on"
        }
    })
    return old_switch_off_rightclick_action(pos, node)
end


-- catch on/off events from lightstones
local lightstone_colors = {"red", "green", "blue", "gray", "darkgray",
    "yellow", "orange", "white", "pink", "magenta", "cyan", "violet"}
for _, color in ipairs(lightstone_colors) do
    local on_nodename = "mesecons_lightstone:lightstone_" .. color .. "_on"
    local off_nodename = "mesecons_lightstone:lightstone_" .. color .. "_off"
    allowed_nodes[on_nodename] = true
    allowed_nodes[off_nodename] = true

    local def_on = assert(minetest.registered_nodes[on_nodename])
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

minetest.register_tool("mtui:register_mesecons", {
    description = "UI Register wand",
    inventory_image = "mtui_register_mesecons.png",
    stack_max = 1,
    on_use = function(_, player, pointed_thing)
        local pos = pointed_thing.under
        if not pos then
            return
        end
        local node = minetest.get_node_or_nil(pos)
        local playername = player:get_player_name()

        if not allowed_nodes[node.name] then
            minetest.chat_send_player(playername, "Node '" .. node.name ..
                "' at position '" .. minetest.pos_to_string(pos) .. "' not supported!")
            return
        end

        if minetest.is_protected(pos, playername) then
            minetest.chat_send_player(playername, "Node '" .. node.name ..
                "' at position '" .. minetest.pos_to_string(pos) .. "' is protected!")
            return
        end

        mtui.send_command({
            type = "mesecons_register",
            data = {
                pos = pos,
                playername = playername,
                nodename = node.name
            }
        })

        minetest.chat_send_player(playername, "Node '" .. node.name ..
            "' at position '" .. minetest.pos_to_string(pos) .. "' has been registered")
    end
})