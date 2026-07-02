MNCore = MNCore or {}
MNCore.Status = MNCore.Status or {}

local function countByClassPrefix(prefix)
    local count = 0
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and string.StartWith(ent:GetClass() or "", prefix) then
            count = count + 1
        end
    end
    return count
end

local function collectPlayers()
    local rows = {}
    for _, ply in ipairs(player.GetHumans()) do
        if IsValid(ply) then
            table.insert(rows, {
                steam_id = ply:SteamID(),
                steam_id64 = ply:SteamID64(),
                name = ply:Nick(),
                ping = ply:Ping(),
                team = team.GetName(ply:Team()) or tostring(ply:Team()),
                connected_seconds = math.floor(CurTime() - ply:TimeConnected())
            })
        end
    end
    return rows
end

function MNCore.Status.Payload()
    local playersOnline = #player.GetHumans()
    local maxPlayers = game.MaxPlayers() or 0

    return {
        server_key = MNCore.Config.ServerKey,
        server_name = MNCore.Config.ServerName,
        map_name = game.GetMap(),
        players_online = playersOnline,
        max_players = maxPlayers,
        entities = #ents.GetAll(),
        props = countByClassPrefix("prop_"),
        vehicles = #ents.FindByClass("prop_vehicle*") or 0,
        wire_entities = countByClassPrefix("gmod_wire"),
        server_fps = math.Round(1 / math.max(FrameTime(), 0.001), 2),
        ram_mb = math.floor(collectgarbage("count") / 1024),
        cpu_percent = 0,
        uptime_seconds = math.floor(CurTime()),
        health = "online",
        players = collectPlayers()
    }
end

function MNCore.Status.Send()
    MNCore.HTTP.Post("api/server-status.php", MNCore.Status.Payload(), function()
        if MNCore.Config.Debug then print("[MemoNetwork Core] Status sent") end
    end)
end

function MNCore.Status.Start()
    timer.Create("MNCore.Status", MNCore.Config.StatusInterval or 10, 0, MNCore.Status.Send)
    timer.Simple(5, MNCore.Status.Send)
end
