local http = ...

-- list of commands to send
local commands = {}

-- asnyc send triggered
local send_triggered = false

local function send_commands()
    http.fetch({
        url = mtui.url .. "/api/bridge",
        extra_headers = {
            "Api-Key: " .. mtui.key
        },
        timeout = 10,
        method = "POST",
        data = minetest.write_json(commands)
    }, function(res)
        if not res.succeeded or res.code ~= 200 then
            minetest.log("error", "[mtui] failed to send command, " ..
                "status: " .. res.code .. " response: " .. (res.data or "<none>"))
        end
    end)

    -- clear commands list
    commands = {}
    -- reset triggered state
    send_triggered = false
end

-- queues a command to send to the ui
function mtui.send_command(cmd)
    table.insert(commands, cmd)

    if not send_triggered then
        -- defer sending of commands until next globalstep
        minetest.after(0, send_commands)
        send_triggered = true
    end
end
