

local old_chat_send_all = minetest.chat_send_all
local old_chat_send_player = minetest.chat_send_player

-- message/PM from the ui to ingame
mtui.register_on_command("send_chat_message", function(data)
    old_chat_send_player(data.name, "DM from " .. data.name .. ": " .. data.text)
end)

-- intercept ingame message and send themto the ui
function minetest.chat_send_player(name, text)
    old_chat_send_player(name, text)
    mtui.send_command({
        type = "chat_send_player",
        data = {
            name = name,
            text = text
        }
    })
end

function minetest.chat_send_all(text)
    old_chat_send_all(text)
    mtui.send_command({
        type = "chat_send_all",
        data = {
            text = text
        }
    })
end