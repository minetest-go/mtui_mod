
mtt.register("items", function(callback)
    assert(mtui.items)

    local count = 0
    for _ in pairs(mtui.items) do
        count = count + 1
    end

    assert(count > 0)
    callback()
end)