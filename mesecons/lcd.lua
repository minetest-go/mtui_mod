local lcd_name = "digilines:lcd"

mtui.mesecons.allowed_nodes[lcd_name] = true

local lcd_def = minetest.registered_nodes[lcd_name]
if not lcd_def or not lcd_def.digilines then
    -- old or invalid digilines mod, skip this module
    return
end

mtui.mesecons.allowed_nodes[lcd_name] = true

local old_effector_action = assert(lcd_def.digilines.effector.action)

lcd_def.digilines.effector.action = function(pos, node, channel, msg)
    old_effector_action(pos, node, channel, msg)

    if type(msg) ~= "string" then
        return
    end

    local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	if setchan ~= channel then return end

    mtui.send_command({
        type = "mesecons_event",
        data = {
            pos = pos,
            state = msg,
            nodename = node.name
        }
    })
end
