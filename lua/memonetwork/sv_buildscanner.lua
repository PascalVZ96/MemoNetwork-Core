MNCore = MNCore or {}
MNCore.BuildScanner = MNCore.BuildScanner or {}
MNCore.BuildScanner.LastHashes = MNCore.BuildScanner.LastHashes or {}

local function isBuildEntity(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass() or ""
    return string.StartWith(class, "prop_")
        or string.StartWith(class, "gmod_wire")
        or string.StartWith(class, "sent_")
        or string.StartWith(class, "acf_")
end

local function getOwner(ent)
    if not IsValid(ent) then return nil end

    if ent.CPPIGetOwner then
        local ok, owner = pcall(function() return ent:CPPIGetOwner() end)
        if ok and IsValid(owner) and owner:IsPlayer() then return owner end
    end

    local candidates = {
        ent:GetNWEntity("Owner"),
        ent:GetNWEntity("owner"),
        ent:GetNWEntity("Creator"),
        ent:GetNWEntity("creator")
    }

    for _, ply in ipairs(candidates) do
        if IsValid(ply) and ply:IsPlayer() then return ply end
    end

    if IsValid(ent.Owner) and ent.Owner:IsPlayer() then return ent.Owner end
    if IsValid(ent.owner) and ent.owner:IsPlayer() then return ent.owner end

    return nil
end

local function ownerKey(owner)
    if IsValid(owner) then return owner:SteamID() end
    return "unknown"
end

local function ownerName(owner)
    if IsValid(owner) then return owner:Nick() end
    return "Unknown"
end

local function countConstraints(ent)
    if not constraint or not constraint.GetTable then return 0 end
    local ok, constraints = pcall(constraint.GetTable, ent)
    if not ok or not istable(constraints) then return 0 end
    return #constraints
end

local function scoreBuild(data)
    local score = 100
    score = score - math.floor((data.props or 0) / 20)
    score = score - math.floor((data.vehicles or 0) * 2)
    score = score - math.floor((data.wire_entities or 0) / 4)
    score = score - math.floor((data.constraints or 0) / 15)
    return math.Clamp(score, 1, 100)
end

local function buildHash(data)
    return util.CRC(table.concat({
        data.owner_steam_id or "unknown",
        data.map_name or game.GetMap(),
        tostring(data.props or 0),
        tostring(data.vehicles or 0),
        tostring(data.wire_entities or 0),
        tostring(data.constraints or 0)
    }, ":"))
end

function MNCore.BuildScanner.Scan()
    if not MNCore.Config.EnableBuildScanner then return end

    local grouped = {}

    for _, ent in ipairs(ents.GetAll()) do
        if isBuildEntity(ent) then
            local owner = getOwner(ent)
            local key = ownerKey(owner)
            grouped[key] = grouped[key] or {
                owner = owner,
                props = 0,
                vehicles = 0,
                wire_entities = 0,
                constraints = 0,
                entities = 0
            }

            local class = ent:GetClass() or ""
            grouped[key].entities = grouped[key].entities + 1
            grouped[key].constraints = grouped[key].constraints + countConstraints(ent)

            if string.StartWith(class, "prop_vehicle") then
                grouped[key].vehicles = grouped[key].vehicles + 1
            elseif string.StartWith(class, "gmod_wire") then
                grouped[key].wire_entities = grouped[key].wire_entities + 1
            elseif string.StartWith(class, "prop_") then
                grouped[key].props = grouped[key].props + 1
            end
        end
    end

    local sent = 0
    for key, data in pairs(grouped) do
        if sent >= (MNCore.Config.MaxBuildsPerScan or 25) then break end
        if (data.props or 0) >= (MNCore.Config.MinBuildProps or 5) then
            local owner = data.owner
            local payload = {
                server_key = MNCore.Config.ServerKey,
                build_name = ownerName(owner) .. "'s Build",
                owner_name = ownerName(owner),
                owner_steam_id = key ~= "unknown" and key or nil,
                map_name = game.GetMap(),
                props = data.props or 0,
                vehicles = data.vehicles or 0,
                wire_entities = data.wire_entities or 0,
                performance_score = scoreBuild(data),
                preview_url = nil,
                file_url = nil
            }

            local hash = buildHash(data)
            if MNCore.BuildScanner.LastHashes[key] ~= hash then
                MNCore.BuildScanner.LastHashes[key] = hash
                sent = sent + 1

                if MNCore.Config.SendBuildsToWeb then
                    MNCore.HTTP.Post("api/builds.php", payload, function()
                        MNCore.Console.Log("info", "Build scan uploaded for " .. payload.owner_name .. " (" .. payload.props .. " props)")
                    end)
                end
            end
        end
    end

    if MNCore.Config.Debug then
        print("[MemoNetwork Core] Build scan complete, sent " .. sent .. " build updates")
    end
end

function MNCore.BuildScanner.Start()
    if not MNCore.Config.EnableBuildScanner then return end
    timer.Create("MNCore.BuildScanner", MNCore.Config.BuildScanInterval or 120, 0, MNCore.BuildScanner.Scan)
    timer.Simple(20, MNCore.BuildScanner.Scan)
end
