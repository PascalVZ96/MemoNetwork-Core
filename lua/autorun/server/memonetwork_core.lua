if not SERVER then return end

MNCore = MNCore or {}
MNCore.Version = "Alpha 2"

local function loadFile(path)
    include(path)
end

loadFile("memonetwork/sh_config.lua")
loadFile("memonetwork/sv_http.lua")
loadFile("memonetwork/sv_status.lua")
loadFile("memonetwork/sv_metrics.lua")
loadFile("memonetwork/sv_players.lua")
loadFile("memonetwork/sv_console.lua")
loadFile("memonetwork/sv_commands.lua")
loadFile("memonetwork/sv_buildscanner.lua")

hook.Add("Initialize", "MNCore.Initialize", function()
    print("[MemoNetwork Core] Loaded " .. MNCore.Version)
    MNCore.Status.Start()
    MNCore.Metrics.Start()
    MNCore.Commands.Start()
    MNCore.Players.Start()
    MNCore.Console.Start()
    MNCore.BuildScanner.Start()
end)
