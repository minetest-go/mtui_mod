
local function post_metrics()
    local exported_metrics = {}

    for name, metric in pairs(monitoring.metrics_mapped) do
        if metric.type == "gauge" or metric.name == "counter" then
            -- export gauge and counter type only
            table.insert(exported_metrics, {
                name = name,
                type = metric.type,
                help = metric.help,
                value = metric.value
            })
        end
    end

    mtui.send_command({
        type = "metrics",
        data = exported_metrics
    })

    minetest.after(5, post_metrics)
end

minetest.after(5, post_metrics)