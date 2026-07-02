MNCore = MNCore or {}
MNCore.Metrics = MNCore.Metrics or {}

local function countProps()
    local count = 0
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and string.StartWith(ent:GetClass() or "", "prop_") then
            count = count + 1
        end
    end
    return count
end

function MNCore.Metrics.Payload()
    return {
        server_key = MNCore.Config.ServerKey,
        players_online = #player.GetHumans(),
        entities = #ents.GetAll(),
        props = countProps(),
        server_fps = math.Round(1 / math.max(FrameTime(), 0.001), 2),
        ram_mb = math.floor(collectgarbage("count") / 1024),
        cpu_percent = 0
    }
end

function MNCore.Metrics.Send()
    MNCore.HTTP.Post("api/metrics.php", MNCore.Metrics.Payload(), function()
        if MNCore.Config.Debug then print("[MemoNetwork Core] Metrics sent") end
    end)
end

function MNCore.Metrics.Start()
    timer.Create("MNCore.Metrics", MNCore.Config.MetricsInterval or 30, 0, MNCore.Metrics.Send)
    timer.Simple(10, MNCore.Metrics.Send)
end
