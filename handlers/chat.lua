
if minetest.get_modpath("beerchat") then
    -- use beerchat hooks
    local last_sent_msg = {}

    -- game -> ui
    table.insert(beerchat.cb.on_send_on_channel, function(_, msg)
        print("beerchat.cb.on_send_on_channel", msg)
        if last_sent_msg ~= msg then
            -- this is not the last sent message, relay to ui
            mtui.send_command({
                type = "chat_notification",
                data = {
                    channel = msg.channel,
                    name = msg.name,
                    message = mtui.strip_escapes(msg.message)
                }
            })
        end

        return true
    end)

    -- ui -> game
    mtui.register_on_command("chat_send", function(data)
        print("chat_send", data)
        -- remember last sent message (don't send it back to the ui in the above callback)
        last_sent_msg = data
        beerchat.send_on_channel(data)
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

-- join/leave/start/shutdown messages
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
            message =  "✔ Minetest started"
        }
    })
end)

minetest.register_on_shutdown(function()
    mtui.send_command({
        type = "chat_notification",
        data = {
            channel = "main",
            name = "",
            message =  "✖ Minetest shutting down"
        }
    })
end)