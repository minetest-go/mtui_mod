
mtt.emerge_area({x=0,y=0,z=0}, {x=32,y=32,z=32})

mtt.register("player join", function(callback)
    local player = mtt.join_player("singleplayer")
    player:leave()

    callback()
end)