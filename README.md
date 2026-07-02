# MemoNetwork Core

Garry's Mod server addon for MemoNetwork Web.

## Alpha 1

This first release connects a Garry's Mod server to MemoNetwork Web.

### Features

- Sends live server status to the web panel
- Sends metrics to the web panel
- Sends player join/leave events
- Polls the command queue
- Executes basic queued commands
- Sends command results back to the web panel
- Basic console logging to the web panel

## Installation

1. Download this repository as ZIP.
2. Extract it into your Garry's Mod server:

```text
garrysmod/addons/memonetwork_core/
```

3. Edit:

```text
lua/memonetwork/sh_config.lua
```

4. Set your panel URL and API token:

```lua
MNCore.Config.PanelUrl = "https://memocraft.nl/adminpanel"
MNCore.Config.ApiToken = "YOUR_API_TOKEN_FROM_ENV"
```

5. Restart the Garry's Mod server.

## Web panel endpoints used

- `api/server-status.php`
- `api/metrics.php`
- `api/console.php`
- `api/player-event.php`
- `api/commands.php`

## Notes

This addon only runs server-side. No client download is required for Alpha 1.
