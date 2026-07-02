# MemoNetwork Core

Garry's Mod server addon for MemoNetwork Web.

## Alpha 2

Alpha 2 adds an automatic build scanner on top of Alpha 1.

### Features

- Sends live server status to the web panel
- Sends metrics to the web panel
- Sends player join/leave events
- Polls the command queue
- Executes basic queued commands
- Sends command results back to the web panel
- Basic console logging to the web panel
- Automatic build scanner
- Groups builds by owner when CPPI ownership is available
- Sends build data to MemoNetwork Web Build Browser
- Calculates a basic performance score

## Installation

1. Download this repository as ZIP.
2. Copy the new files into your existing MemoNetwork-Core addon.
3. Edit:

```text
lua/memonetwork/sh_config.lua
```

4. Set your panel URL and API token:

```lua
MNCore.Config.PanelUrl = "https://memocraft.nl/adminpanel"
MNCore.Config.ApiToken = "YOUR_API_TOKEN_FROM_ENV"
```

5. Make sure the loader includes:

```lua
include("memonetwork/sv_buildscanner.lua")
MNCore.BuildScanner.Start()
```

6. Restart the Garry's Mod server.

## Web panel endpoints used

- `api/server-status.php`
- `api/metrics.php`
- `api/console.php`
- `api/player-event.php`
- `api/commands.php`
- `api/builds.php`

## Notes

This addon only runs server-side. No client download is required.
