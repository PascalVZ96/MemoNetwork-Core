MNCore = MNCore or {}
MNCore.Config = MNCore.Config or {}

-- Web panel base URL. Do not add a slash at the end.
MNCore.Config.PanelUrl = "https://memocraft.nl/adminpanel"

-- Copy API_TOKEN from /adminpanel/.env on your web hosting.
MNCore.Config.ApiToken = "CHANGE_ME"

MNCore.Config.ServerKey = "main"
MNCore.Config.ServerName = "MemoNetwork"

-- Timers in seconds
MNCore.Config.StatusInterval = 10
MNCore.Config.MetricsInterval = 30
MNCore.Config.CommandPollInterval = 5
MNCore.Config.ConsoleFlushInterval = 10

-- Command safety
MNCore.Config.AllowConsoleCommands = true
MNCore.Config.Debug = true
