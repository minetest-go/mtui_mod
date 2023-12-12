
mtui.register_control("mtui:shutdown", {
    category = "builtin",
    type = "button",
    label = "Shutdown server",
    description = "shuts down the server",
    action = {
        set = function()
            minetest.request_shutdown("planned shutdown")
        end
    }
})

mtui.register_control("mtui:tod", {
    category = "builtin",
    type = "numeric",
    min = 0,
    max = 24,
    label = "Time of day (hour)",
    description = "sets the time of day",
    action = {
        get = function()
            -- 1/10 decimal precision
            return math.floor( minetest.get_timeofday() * 24 * 10 ) / 10
        end,
        set = function(n)
            minetest.set_timeofday(n / 24)
        end
    }
})
