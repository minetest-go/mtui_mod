
mtui.register_on_command("lua", function(data)
    local fn = loadstring(data.code)

	local result
	local status, err = pcall(function()
		result = fn()
	end)

	if not status then
		return { success=false, message="Command crashed: " .. dump(err) }
	end

	-- strip control chars from message
	return { success = true, result = result }
end)