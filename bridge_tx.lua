local http = ...

local metric_commands, metric_requests, metric_time, metric_size
if minetest.get_modpath("monitoring") then
    metric_commands = monitoring.counter("mtui_tx_commands", "number of sent commands")
    metric_requests = monitoring.counter("mtui_tx_requests", "number of tx requests")
    metric_time = monitoring.counter("mtui_tx_request_time", "time usage in microseconds for tx requests")
    metric_size = monitoring.counter("mtui_tx_request_size", "tx request size in bytes")
end

-- list of commands to send
local commands = {}

-- asnyc send triggered
local send_triggered = false

local function send_commands()
    if metric_requests then
        metric_requests.inc()
    end

    local t0 = minetest.get_us_time()

    local data = minetest.write_json(commands)
    if metric_size then
        metric_size.inc(#data)
    end

    http.fetch({
        url = mtui.url .. "/api/bridge",
        extra_headers = {
            "Api-Key: " .. mtui.key
        },
        timeout = 10,
        method = "POST",
        data = data
    }, function(res)
        if metric_time then
            local t1 = minetest.get_us_time()
            metric_time.inc(t1 - t0)
        end

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

-- send pending commands on shutdown
minetest.register_on_shutdown(send_commands)