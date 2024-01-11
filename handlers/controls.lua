
mtui.register_on_command("get_controls_metadata", function()
	return mtui.get_controls_metadata()
end)

mtui.register_on_command("get_controls_values", function()
	return mtui.get_controls_values()
end)

mtui.register_on_command("set_control", function(data)
    return mtui.set_control_value(data.name, data.value)
end)