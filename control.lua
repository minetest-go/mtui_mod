-- input/output control

-- name => control_def
local controls = {}

function mtui.register_control(name, def)
    def.name = name
    def.modname = def.modname or minetest.get_current_modname()
    controls[name] = def
end

function mtui.get_controls()
    return controls
end

function mtui.get_control(name)
    return controls[name]
end
