-- Only Works For Growpai


local authorizedUsers = {
	"pokesampink",
	"pokesampink4"
}

local isAuthorized = false
local currentUserName = ""

local function initializeAuth()
    currentUserName = GetLocal().name:gsub("`.", "")
    
    for _, authorizedUser in pairs(authorizedUsers) do
        if currentUserName == authorizedUser then
            isAuthorized = true
            return true
        end
    end
    
    isAuthorized = false
    return false
end

local function quickAuthCheck()
    return isAuthorized
end

if not initializeAuth() then
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
    return
end


local pulledPlayers = {}
local pulledSet = {}
local MAX_HISTORY = 100

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

log("`2[AUTHORIZED USER] `9Welcome, " .. currentUserName .. "!")
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
    if name == "" or pulledSet[name] then return end 
    
    table.insert(pulledPlayers, name)
    pulledSet[name] = true
    
    if #pulledPlayers > MAX_HISTORY then
        local old = table.remove(pulledPlayers, 1)
        if old then pulledSet[old] = nil end
    end
end

function venddc(varlist)
    if not quickAuthCheck() then
        log("`4[AUTH ERROR] Session expired!")
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
    if packet == "action|input\n|text|/ap" then
        if not quickAuthCheck() then
            log("`4[AUTH ERROR] Session expired!")
            RemoveCallbacks()
            return true
        end
        
        if vendkontol then
            vendkontol = false
            log("`cAutopull is `4OFF")
            RemoveCallback("vendkontol")
            RemoveCallback("venddc")
            return true
        else
            log("`cAutopull is `2ON")
            function vendkontol(varlist)
                if not isAuthorized then
                    RemoveCallbacks()
                    return
                end
                
                if varlist[0] == "OnConsoleMessage" and varlist[1]:find("bought") and varlist[1]:find(items) then
                    local z = varlist[1]
                    local s = "(.+)%s+bought"
                    local name = z:match(s)
                    name = name:gsub("```9", ""):gsub("`7%[", "")
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
    if packet:find("action|input\n|text|/item") then
        if not quickAuthCheck() then
            log("`4[AUTH ERROR] Session expired!")
            RemoveCallbacks()
            return true
        end
        
        items = packet:gsub("action|input\n|text|/item", ""):match("^%s*(.-)%s*$")
        log("`cChanged Item to:`9" .. items)
        return true
    end
end
AddCallback("changeitem", "OnPacket", changeitem)

function showpulled(type, packet)
    if packet:find("action|input\n|text|/clear") then
        if not quickAuthCheck() then
            log("`4[AUTH ERROR] Session expired!")
            RemoveCallbacks()
            return true
        end
        
        pulledPlayers = {}
        pulledSet = {}
        log("`4Pulled list cleared")
        return true
    end
    
    if packet:find("action|input\n|text|/list") then
        if not quickAuthCheck() then
            log("`4[AUTH ERROR] Session expired!")
            RemoveCallbacks()
            return true
        end
        
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
    if packet:find("action|input\n|text|/fc") then
        if not quickAuthCheck() then
            log("`4[AUTH ERROR] Session expired!")
            RemoveCallbacks()
            return true
        end
        
        log("`4Autopull Closed")
        RemoveCallbacks()
        return true
    end
end
AddCallback("fc", "OnPacket", fc)

