
mtt.register("sanitize_ip", function(callback)
    assert(mtui.sanitize_ip("2a01:cb10:15e:7d20:3004:8502:c0d3:a13f") == "2a01:cb10:15e:7d20:3004:8502:c0d3:a13f")
    assert(mtui.sanitize_ip("::ffff:112.33.176.254") == "112.33.176.254")
    assert(mtui.sanitize_ip("blah") == "blah")
    assert(mtui.sanitize_ip("") == "")
    assert(mtui.sanitize_ip(nil) == nil)
    callback()
end)