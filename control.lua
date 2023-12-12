-- input/output control

-- name => control_def
local controls = {}

function mtui.register_control(name, def)
    def.category = def.category or "unknown"
    def.name = name
    def.modname = def.modname or minetest.get_current_modname()
    controls[name] = def
end

function mtui.get_controls()
    return controls
end

-- returns only the controls metadata without action fields
function mtui.get_controls_metadata()
    local md = {}
    for name, def in pairs(controls) do
        md[name] = table.copy(def)
        md[name].action = nil
    end
    return md
end

function mtui.get_controls_values()
    local values = {}
    for name, def in pairs(controls) do
        if def.action and type(def.action.get) == "function" then
            values[name] = def.action.get()
        end
    end
    return values
end

function mtui.set_control_value(name, value)
    local def = controls[name]
    if def and def.action and type(def.action.set) == "function" then
        def.action.set(value)
    end
end

function mtui.get_control(name)
    return controls[name]
end
