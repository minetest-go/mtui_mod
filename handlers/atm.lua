
mtui.register_on_command("atm_transfer", function(data)
    if not data.amount then
        return { success = false, errmsg = "no amount specified" }
    end

    if data.amount <= 0 then
        return { success = false, errmsg = "invalid amount" }
    end

    if not minetest.player_exists(data.source) then
        return { success = false, errmsg = "source player does not exist" }
    end

    if not minetest.player_exists(data.target) then
        return { success = false, errmsg = "target player does not exist" }
    end
    atm.read_account(data.source)
    atm.read_account(data.target)

    if atm.balance[data.source] < data.amount then
        return { success = false, errmsg = "insufficient amount" }
    end

    atm.balance[data.source] = atm.balance[data.source] - data.amount
    atm.balance[data.target] = atm.balance[data.target] + data.amount

    local source_balance = atm.balance[data.source]
    local target_balance = atm.balance[data.target]

    atm.save_account(data.source)
    atm.save_account(data.target)

    return {
        success = true,
        source_balance = source_balance,
        target_balance = target_balance
    }
end)