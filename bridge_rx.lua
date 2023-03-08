local http = ...

local metric
if minetest.get_modpath("monitoring") then
    metric = monitoring.counter("mtui_rx", "number of received commands")
end

local command_handlers = {}

function mtui.register_on_command(type, handler)
    command_handlers[type] = handler
end

-- fetch commands from the ui
local function fetch_commands()
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
                if metric then
                    metric.inc()
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