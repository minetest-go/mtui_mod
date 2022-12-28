
mtui.register_control("mtui_shutdown_server", {
    type = "button",
    label = "Shutdown server",
    set = function()
        minetest.request_shutdown("planned shutdown")
    end
})

mtui.register_control("mtui_time_of_day", {
    type = "numeric",
    min = 0,
    max = 24,
    label = "Time of day (hour)",
    get = function()
        -- 1/10 decimal precision
        return math.floor( minetest.get_timeofday() * 24 * 10 ) / 10
    end,
    set = function(n)
        minetest.set_timeofday(n / 24)
    end
})
