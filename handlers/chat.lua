
if minetest.get_modpath("beerchat") then
    -- use beerchat hooks

    -- game -> ui
    local old_on_channel_message = beerchat.on_channel_message
    function beerchat.on_channel_message(channel, name, message)
        old_on_channel_message(channel, name, message)
        mtui.send_command({
            type = "chat_notification",
            data = {
                channel = channel,
                name = name,
                message = mtui.strip_escapes(message)
            }
        })
    end

    -- ui -> game
    mtui.register_on_command("chat_send", function(data)
        beerchat.send_on_local_channel(data)
    end)
else
    -- use builtin

    -- game -> ui
    minetest.register_on_chat_message(function(name, message)
        mtui.send_command({
            type = "chat_notification",
            data = {
                channel = "main",
                name = name,
                message = mtui.strip_escapes(message)
            }
        })
    end)

    -- ui -> game
    mtui.register_on_command("chat_send", function(data)
        minetest.chat_send_all("<" .. data.name .. "> " .. data.message)
    end)
end

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()
    mtui.send_command({
        type = "chat_notification",
        data = {
            channel = "main",
            name = name,
            message =  "❱ Joined the game" .. (last_login and "" or " (new)")
        }
    })
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()

    mtui.send_command({
        type = "chat_notification",
        data = {
            channel = "main",
            name = name,
            message =  "❰ Left the game" .. (timed_out and " (timed out)" or "")
        }
    })
end)

minetest.register_on_mods_loaded(function()
    mtui.send_command({
        type = "chat_notification",
        data = {
            channel = "main",
            name = "",
            message =  "Minetest started"
        }
    })
end)

minetest.register_on_shutdown(function()
    mtui.send_command({
        type = "chat_notification",
        data = {
            channel = "main",
            name = "",
            message =  "Minetest shutting down"
        }
    })
end)