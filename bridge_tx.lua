local http = ...

local metric_commands, metric_requests
if minetest.get_modpath("monitoring") then
    metric_commands = monitoring.counter("mtui_tx_commands", "number of sent commands")
    metric_requests = monitoring.counter("mtui_tx_requests", "number of tx requests")
end

-- list of commands to send
local commands = {}

-- asnyc send triggered
local send_triggered = false

local function send_commands()
    if metric_requests then
        metric_requests.inc()
    end

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
function mtui.send_command(cmd, flush)
    if metric_commands then
        metric_commands.inc()
    end

    -- enqueue
    table.insert(commands, cmd)
    if flush then
        -- high prio
        send_commands()
    elseif not send_triggered then
        -- low prio
        -- defer sending of commands
        minetest.after(1, send_commands)
        send_triggered = true
    end
end
