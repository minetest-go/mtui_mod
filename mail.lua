
local old_mail_send = mail.send

mail.send = function(m)
    local success, msg = old_mail_send(m)

    if success then
        -- notify ui (for mail-forwarding, if configured)
        mtui.send_command({
            type = "mail_sent",
            data = {
                mail = m
            }
        })
    end

    return success, msg
end