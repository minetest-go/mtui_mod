local old_log = minetest.log
local logfile_level_mapping = {
    ["none"] = "logfile",
    ["error"] = "logfile-error",
    ["warning"] = "logfile-warning",
    ["action"] = "logfile-action",
    ["info"] = "logfile-info",
    ["verbose"] = "logfile-verbose",
}

function minetest.log(level, msg)
    if type(level) == "string" and type(msg) == "string" then
        -- TODO: parse out online player-names, mod-prefix, position(s?)
        local event = logfile_level_mapping[level]
        if not event then
            event = "logfile"
        end

        mtui.send_command({
            type = "log",
            data = {
                category = "minetest",
                event = event,
                message = msg
            }
        })
    end

    if not msg then
        -- call with a single parameter only (the engine checks param-count, not var-type)
        return old_log(level)
    else
        return old_log(level, msg)
    end
end
