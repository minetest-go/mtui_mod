
minetest.register_chatcommand("mtui_tan", {
    description = "generates a tan (temporary access number) for the web-ui access",
    func = function(name)
        local tan = "" .. math.random(1000, 9999)
        mtui.send_command({
            type = "tan_set",
            data = {
                playername = name,
                tan = tan
            }
        })
        return true, "Your tan is " .. tan .. ", it will expire upon leaving the game"
    end
})

minetest.register_on_leaveplayer(function(player)
    mtui.send_command({
        type = "tan_remove",
        data = {
            playername = player:get_player_name()
        }
    })
end)