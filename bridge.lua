local http = ...

-- send a command to the ui
function mtadmin.send_command(cmd, success_callback, error_callback)
    http.fetch({
        url = mtadmin.url .. "/api/bridge",
        extra_headers = {
            "Api-Key: " .. mtadmin.key
        },
        timeout = 10,
        method = "POST",
        data = minetest.write_json(cmd)
    }, function(res)
        if res.succeeded and res.code == 200 and type(success_callback) == "function" then
            local obj = minetest.parse_json(res.data)
            success_callback(obj)
        elseif type(error_callback) == "function" then
            local obj
            if res.data and res.data ~= "" then
                obj = minetest.parse_json(res.data)
            end
            error_callback(res.code or 0, obj)
        end
    end)
end

local command_handlers = {}

function mtadmin.register_on_command(type, handler)
    command_handlers[type] = handler
end

-- fetch commands from the ui
local function fetch_commands()
    http.fetch({
        url = mtadmin.url .. "/api/bridge",
        extra_headers = {
            "Api-Key: " .. mtadmin.key
        },
        timeout = 30,
        method = "GET"
    }, function(res)
        if res.succeeded and res.code == 200 and res.data ~= "" then
            local command_list = minetest.parse_json(res.data)

            for _, cmd in ipairs(command_list) do
                local handler = command_handlers[cmd.type]
                if type(handler) == "function" then
                    local send = function(data)
                        mtadmin.send_command({
                            type = cmd.type,
                            id = cmd.id,
                            data = data
                        })
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
            print("[mtadmin] bridge error: " .. res.code)
            minetest.after(10, fetch_commands)
        end
    end)
end

minetest.after(1, fetch_commands)