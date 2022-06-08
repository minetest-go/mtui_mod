
local function post_features()
    mtui.send_command({
        type = "features",
        data = {
            mail = minetest.get_modpath("mail") ~= nil
        }
    })

    -- periodically send feature-set
    minetest.after(30, post_features)
end

minetest.after(1, post_features)