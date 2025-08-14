local authorizedUsers = {
    "pokesampink"
}

local function checkAuthorization()
    local currentUser = GetLocal().name
    currentUser = currentUser:gsub("`.", "")
    
    for _, authorizedUser in pairs(authorizedUsers) do
        if currentUser == authorizedUser then
            return true
        end
    end
    return false
end

-- Check authorization before running script
if not checkAuthorization() then
    log("`4[ERROR] Unauthorized user! This script is locked to specific GrowIDs.")
    log("`4Contact the script owner for access.")
    
    var2 = {}
    var2[0] = "OnAddNotification"
    var2[1] = "interface/atomic_button.rttex"
    var2[2] = "`4Unauthorized Access Detected!"
    var2[3] = "audio/fail.wav"
    var2[4] = 0
    var2.netid = -1
    SendVarlist(var2)
    return -- Exit script
end

-- Initialize variables
local pulledPlayers = {}
local pulledSet = {}
local MAX_HISTORY = 100

-- Send authorized notification
var2 = {}
var2[0] = "OnAddNotification"
var2[1] = "interface/cash_icon_overlay.rttex"
var2[2] = "`2[AUTHORIZED] `cScript Created by `pDiscord: SmThing `5Github: sammdevl"
var2[3] = "audio/achievement.wav"
var2[4] = 0
var2.netid = -1
SendVarlist(var2)

local items = "Dirt"
local vendkontol = false

log("`2[AUTHORIZED USER] `9Welcome, " .. GetLocal().name .. "!")
log("`c/ap `9To Start AutoPulling")
log("`c/item item name `9 To Change Item Target")
log("`c/pulled `9To See All Pulled Player List")
log("`c/clear `9To Clear All Pulled Player List")
log("`c/item `2item name `9 To Change Item Target")
log("`cCurrent Item: `9" .. items)

if vendkontol then
    log("`cAutopull is `2ON")
else
    log("`cAutopull is `4OFF")
end

local function add_pulled(name)
    if name == "" then return end
    if pulledSet[name] then return end 
    table.insert(pulledPlayers, name)
    pulledSet[name] = true
    if #pulledPlayers > MAX_HISTORY then
        local old = table.remove(pulledPlayers, 1)
        if old then pulledSet[old] = nil end
    end
end

function venddc(varlist)
    -- Runtime authorization check
    if not checkAuthorization() then
        log("`4[AUTH ERROR] Unauthorized access detected during runtime!")
        vendkontol = false
        RemoveCallbacks()
        return
    end
    
    if varlist[0] == "OnConsoleMessage" and (varlist[1]:find("dc") or varlist[1]:find("DC")) then
        local z = varlist[1]
        local name = z:match("`w(%w+)`")
        if name and pulledSet[name] then
            log("`6Pulling DC player: `p" .. name .. " `6(from pulled list)")
            SendPacket(2, "action|input\n|text|/pull " .. name)
        elseif name then
            log("`4Player `p" .. name .. " `4DCed but not in pulled list - ignoring")
        end
    end
end

function autopull(type, packet)
    -- Runtime authorization check
    if not checkAuthorization() then
        log("`4[AUTH ERROR] Unauthorized access detected during runtime!")
        vendkontol = false
        RemoveCallbacks()
        return true
    end
    
    if packet == "action|input\n|text|/ap" then
        if vendkontol then
            vendkontol = false
            log("`cAutopull is `4OFF")
            RemoveCallback("vendkontol")
            RemoveCallback("venddc")
            return true
        else
            log("`cAutopull is `2ON")
            function vendkontol(varlist)
                -- Additional auth check inside nested function
                if not checkAuthorization() then
                    log("`4[AUTH ERROR] Security breach detected!")
                    vendkontol = false
                    RemoveCallbacks()
                    return
                end
                
                if varlist[0] == "OnConsoleMessage" and varlist[1]:find("bought") and varlist[1]:find(items) then
                    local z = varlist[1]
                    local s = "(.+)%s+bought"
                    local name = z:match(s)
                    name = name:gsub("```9", "") 
                    name = name:gsub("`7%[", "")
                    if name ~= "" then
                        add_pulled(name)
                        SendPacket(2, "action|input\n|text|/pull " .. name)
                    end
                end
            end
            AddCallback("vendkontol", "OnVarlist", vendkontol)
            AddCallback("venddc", "OnVarlist", venddc)
            vendkontol = true
            return true
        end
    end
end
AddCallback("autopull", "OnPacket", autopull)

function changeitem(type, packet)
    -- Runtime authorization check
    if not checkAuthorization() then
        log("`4[AUTH ERROR] Unauthorized access detected during runtime!")
        vendkontol = false
        RemoveCallbacks()
        return true
    end
    
    if packet:find("action|input\n|text|/item") then
        items = packet:gsub("action|input\n|text|/item", "")
        items = items:match("^%s*(.-)%s*$")
        log("`cChanged Item to:`9" .. items)
        return true
    end
end
AddCallback("changeitem", "OnPacket", changeitem)

function showpulled(type, packet)
    -- Runtime authorization check
    if not checkAuthorization() then
        log("`4[AUTH ERROR] Unauthorized access detected during runtime!")
        vendkontol = false
        RemoveCallbacks()
        return true
    end
    
    if packet:find("action|input\n|text|/clear") then
        pulledPlayers = {}
        pulledSet = {}
        log("`4Pulled list cleared")
        return true
    end
    if packet:find("action|input\n|text|/pulled") then
        if #pulledPlayers == 0 then
            log("`cPulled list is empty.")
            return true
        end
        log("`cPulled players (" .. #pulledPlayers .. "):")
        for i, name in ipairs(pulledPlayers) do
            log("`9" .. i .. ". `p" .. name)
        end
        return true
    end
end
AddCallback("showpulled", "OnPacket", showpulled)

function fc(type, packet)
    -- Runtime authorization check
    if not checkAuthorization() then
        log("`4[AUTH ERROR] Unauthorized access detected during runtime!")
        vendkontol = false
        RemoveCallbacks()
        return true
    end
    
    if packet:find("action|input\n|text|/fc") then
        log("`4Autopull Closed")
        RemoveCallbacks()
        return true
    end
end
AddCallback("fc", "OnPacket", fc)
