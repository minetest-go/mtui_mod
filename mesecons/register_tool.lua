
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

        if not mtui.mesecons.allowed_nodes[node.name] then
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