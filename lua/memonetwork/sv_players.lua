MNCore = MNCore or {}
MNCore.Players = MNCore.Players or {}
MNCore.Players.JoinTimes = MNCore.Players.JoinTimes or {}

local function sendEvent(ply, eventName, message, extra)
    if not IsValid(ply) then return end
    local payload = extra or {}
    payload.server_key = MNCore.Config.ServerKey
    payload.event = eventName
    payload.player_name = ply:Nick()
    payload.steam_id = ply:SteamID()
    payload.steam_id64 = ply:SteamID64()
    payload.message = message
    MNCore.HTTP.Post("api/player-event.php", payload)
end

function MNCore.Players.Start()
    hook.Add("PlayerInitialSpawn", "MNCore.PlayerInitialSpawn", function(ply)
        MNCore.Players.JoinTimes[ply:SteamID()] = CurTime()
        timer.Simple(3, function()
            if IsValid(ply) then
                sendEvent(ply, "join", ply:Nick() .. " joined the server.")
            end
        end)
    end)

    hook.Add("PlayerDisconnected", "MNCore.PlayerDisconnected", function(ply)
        local steamId = ply:SteamID()
        local joined = MNCore.Players.JoinTimes[steamId] or CurTime()
        sendEvent(ply, "disconnect", ply:Nick() .. " left the server.", {
            session_seconds = math.floor(CurTime() - joined)
        })
        MNCore.Players.JoinTimes[steamId] = nil
    end)
end
