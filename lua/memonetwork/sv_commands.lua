MNCore = MNCore or {}
MNCore.Commands = MNCore.Commands or {}

local function findTarget(command)
    local steamId = command.target_steam_id
    local name = command.target_name

    for _, ply in ipairs(player.GetHumans()) do
        if IsValid(ply) then
            if steamId and steamId ~= "" and (ply:SteamID() == steamId or ply:SteamID64() == steamId) then
                return ply
            end
            if name and name ~= "" and string.find(string.lower(ply:Nick()), string.lower(name), 1, true) then
                return ply
            end
        end
    end

    return nil
end

local function ack(command, status, result)
    MNCore.HTTP.Post("api/commands.php", {
        id = command.id,
        status = status,
        result = result or ""
    })
end

local function executePlayerCommand(command)
    local action = command.command_type
    local target = findTarget(command)

    if not IsValid(target) then
        ack(command, "failed", "Target not found")
        return
    end

    if action == "kick" then
        target:Kick(command.payload or "Kicked by MemoNetwork")
    elseif action == "slay" then
        target:Kill()
    elseif action == "heal" then
        target:SetHealth(100)
    elseif action == "ignite" then
        target:Ignite(10)
    elseif action == "freeze" then
        target:Freeze(true)
    elseif action == "unfreeze" then
        target:Freeze(false)
    elseif action == "mute" then
        target:SetNWBool("MNCoreMuted", true)
    elseif action == "unmute" then
        target:SetNWBool("MNCoreMuted", false)
    elseif action == "gag" then
        target:SetNWBool("MNCoreGagged", true)
    elseif action == "ungag" then
        target:SetNWBool("MNCoreGagged", false)
    elseif action == "ban" then
        RunConsoleCommand("banid", "0", target:SteamID())
        target:Kick(command.payload or "Banned by MemoNetwork")
    elseif action == "bring" then
        -- Requires a future staff source player. For Alpha 1 this is acknowledged only.
        ack(command, "failed", "Bring requires staff position context in a later Core release")
        return
    elseif action == "goto" or action == "spectate" then
        ack(command, "failed", string.upper(action) .. " requires a staff player context in a later Core release")
        return
    else
        ack(command, "failed", "Unsupported player command: " .. tostring(action))
        return
    end

    MNCore.Console.Log("info", "Executed " .. string.upper(action) .. " on " .. target:Nick())
    ack(command, "done", "Executed " .. action .. " on " .. target:Nick())
end

local function executeConsole(command)
    if not MNCore.Config.AllowConsoleCommands then
        ack(command, "failed", "Console commands are disabled in config")
        return
    end

    local payload = command.payload or ""
    if payload == "" then
        ack(command, "failed", "Empty console command")
        return
    end

    game.ConsoleCommand(payload .. "\n")
    MNCore.Console.Log("info", "Executed console command: " .. payload)
    ack(command, "done", "Console command executed")
end

function MNCore.Commands.Execute(command)
    if not command or not command.command_type then return end

    if command.command_type == "console" then
        executeConsole(command)
        return
    end

    executePlayerCommand(command)
end

function MNCore.Commands.Poll()
    MNCore.HTTP.Get("api/commands.php", {
        server_key = MNCore.Config.ServerKey
    }, function(data)
        if not data or not data.commands then return end
        for _, command in ipairs(data.commands) do
            MNCore.Commands.Execute(command)
        end
    end)
end

function MNCore.Commands.Start()
    timer.Create("MNCore.CommandPoll", MNCore.Config.CommandPollInterval or 5, 0, MNCore.Commands.Poll)
    timer.Simple(8, MNCore.Commands.Poll)
end
