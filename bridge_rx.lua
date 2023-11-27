local http = ...

local metric_commands, metric_requests
if minetest.get_modpath("monitoring") then
    metric_commands = monitoring.counter("mtui_rx_commands", "number of received commands")
    metric_requests = monitoring.counter("mtui_rx_requests", "number of rx requests")
end

local command_handlers = {}

function mtui.register_on_command(type, handler)
    command_handlers[type] = handler
end

-- fetch commands from the ui
local function fetch_commands()
    if metric_requests then
        metric_requests.inc()
    end

    http.fetch({
        url = mtui.url .. "/api/bridge",
        extra_headers = {
            "Api-Key: " .. mtui.key
        },
        timeout = 30,
        method = "GET"
    }, function(res)
        if res.succeeded and res.code == 200 and res.data ~= "" then
            local command_list = minetest.parse_json(res.data)

            for _, cmd in ipairs(command_list) do
                if metric_commands then
                    metric_commands.inc()
                end
                local handler = command_handlers[cmd.type]
                if type(handler) == "function" then
                    local send = function(data)
                        mtui.send_command({
                            type = cmd.type,
                            id = cmd.id,
                            data = data
                        }, true)
                    end

                    local response = handler(cmd.data, send)
                    if response then
                        -- send synchronous response
                        send(response)
                    end
                end
            end

            minetest.after(0, fetch_commands)
        else
            print("[mtui] bridge error: " .. res.code)
            minetest.after(10, fetch_commands)
        end
    end)
end

minetest.after(1, fetch_commands)