MNCore = MNCore or {}
MNCore.HTTP = MNCore.HTTP or {}

local function endpoint(path)
    return string.TrimRight(MNCore.Config.PanelUrl or "", "/") .. "/" .. string.TrimLeft(path, "/")
end

function MNCore.HTTP.JsonEncode(tbl)
    return util.TableToJSON(tbl or {}, false) or "{}"
end

function MNCore.HTTP.JsonDecode(body)
    if not body or body == "" then return nil end
    local ok, data = pcall(util.JSONToTable, body)
    if not ok then return nil end
    return data
end

function MNCore.HTTP.Post(path, payload, onSuccess, onFail)
    payload = payload or {}
    payload.api_token = MNCore.Config.ApiToken
    payload.server_key = payload.server_key or MNCore.Config.ServerKey

    HTTP({
        url = endpoint(path),
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. tostring(MNCore.Config.ApiToken or "")
        },
        body = MNCore.HTTP.JsonEncode(payload),
        success = function(code, body)
            if code < 200 or code >= 300 then
                if MNCore.Config.Debug then
                    print("[MemoNetwork Core] HTTP POST failed", path, code, body or "")
                end
                if onFail then onFail(code, body) end
                return
            end
            if onSuccess then onSuccess(MNCore.HTTP.JsonDecode(body), code, body) end
        end,
        failed = function(err)
            if MNCore.Config.Debug then
                print("[MemoNetwork Core] HTTP POST error", path, err)
            end
            if onFail then onFail(0, err) end
        end
    })
end

function MNCore.HTTP.Get(path, query, onSuccess, onFail)
    query = query or {}
    query.api_token = MNCore.Config.ApiToken
    query.server_key = query.server_key or MNCore.Config.ServerKey

    local params = {}
    for k, v in pairs(query) do
        table.insert(params, util.CRC(k) and (k .. "=" .. string.Replace(tostring(v), " ", "%20")) or "")
    end

    HTTP({
        url = endpoint(path) .. "?" .. table.concat(params, "&"),
        method = "GET",
        headers = { ["Authorization"] = "Bearer " .. tostring(MNCore.Config.ApiToken or "") },
        success = function(code, body)
            if code < 200 or code >= 300 then
                if MNCore.Config.Debug then
                    print("[MemoNetwork Core] HTTP GET failed", path, code, body or "")
                end
                if onFail then onFail(code, body) end
                return
            end
            if onSuccess then onSuccess(MNCore.HTTP.JsonDecode(body), code, body) end
        end,
        failed = function(err)
            if MNCore.Config.Debug then
                print("[MemoNetwork Core] HTTP GET error", path, err)
            end
            if onFail then onFail(0, err) end
        end
    })
end
