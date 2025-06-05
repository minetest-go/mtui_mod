
-- ip -> os.time()
local last_prejoin_time = {}

minetest.register_on_prejoinplayer(function(name, ip)
    local now = os.time()
    local last_time = last_prejoin_time[ip] or 0

    -- check for previous login attempt
    if now - last_time < 5 then
        mtui.log({
            event = "prejoin",
            username = name,
            message = "ratelimited prejoin for '" .. name .. "' with ip '" .. ip .. "'",
            ip_address = mtui.sanitize_ip(ip)
        })

        return "login attempts are rate-limited, try again later"
    end

    -- save current timestamp
    last_prejoin_time[ip] = now
end)

-- periodically flush prejoin-time map
local function flush()
    last_prejoin_time = {}
    minetest.after(3600, flush)
end
flush()