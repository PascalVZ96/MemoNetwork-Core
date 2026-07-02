MNCore = MNCore or {}
MNCore.Console = MNCore.Console or {}
MNCore.Console.Buffer = MNCore.Console.Buffer or {}

function MNCore.Console.Log(level, message)
    table.insert(MNCore.Console.Buffer, {
        server_key = MNCore.Config.ServerKey,
        level = level or "info",
        message = tostring(message or "")
    })

    if MNCore.Config.Debug then
        print("[MemoNetwork Core] " .. tostring(message or ""))
    end
end

function MNCore.Console.Flush()
    if #MNCore.Console.Buffer <= 0 then return end
    local lines = MNCore.Console.Buffer
    MNCore.Console.Buffer = {}

    MNCore.HTTP.Post("api/console.php", {
        server_key = MNCore.Config.ServerKey,
        lines = lines
    })
end

function MNCore.Console.Start()
    timer.Create("MNCore.ConsoleFlush", MNCore.Config.ConsoleFlushInterval or 10, 0, MNCore.Console.Flush)

    MNCore.Console.Log("info", "MemoNetwork Core " .. tostring(MNCore.Version) .. " started on " .. game.GetMap())

    hook.Add("PlayerSay", "MNCore.Console.PlayerSay", function(ply, text)
        if IsValid(ply) then
            MNCore.Console.Log("info", "[CHAT] " .. ply:Nick() .. ": " .. tostring(text))
        end
    end)
end
