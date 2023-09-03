
mtui.register_on_command("get_controls_metadata", function()
	return { success = true, result = mtui.get_controls_metadata() }
end)

mtui.register_on_command("get_controls_values", function()
	return { success = true, result = mtui.get_controls_values() }
end)

mtui.register_on_command("set_control", function(data)
    mtui.set_control_value(data.name, data.value)
	return { success = true, result = mtui.get_controls_metadata() }
end)