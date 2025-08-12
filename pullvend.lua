/*
This is a Script for Auto Pulling Player in world after buying a certain item
#ONLY WORKS ON GROWPAI
#Created By Github: sammdevl
*/

local n={} n[0]="OnAddNotification" n[1]="interface/cash_icon_overlay.rttex" n[2]="`cScript Created by `p"..string.char(68,105,115,99,111,114,100)..": SmThing `5Github: sammdevl" n[3]="audio/achievement.wav" n[4]=0 n.netid=-1 SendVarlist(n) local items="Dirt" local ap=false log("`c/ap `9To Start AutoPulling") log("`c/item item name `9To Change Item Target") log("`cCurrent Item: `9"..items) AddCallback("autopull","OnPacket",function(_,p) if p=="action|input\n|text|/ap" then if ap then ap=false log("`cAutopull is `4OFF") RemoveCallback("vend") return true else log("`cAutopull is `2ON") AddCallback("vend","OnVarlist",function(v) if v[0]=="OnConsoleMessage" and v[1]:find("bought") and v[1]:find(items) then local z=v[1] local s="(.+)%s+bought" local name=z:match(s) name=name:gsub("```9",""):gsub("`7%[","") SendPacket(2,"action|input\n|text|/pull "..name) end end) ap=true return true end end end) AddCallback("ci","OnPacket",function(_,p) if p:find("action|input\n|text|/item") then items=p:gsub("action|input\n|text|/item%s*","") log("`cChanged Item to:`9"..items) return true end end) AddCallback("fc","OnPacket",function(_,p) if p:find("action|input\n|text|/fc") then log("`4Autopull Closed") RemoveCallbacks() return true end end)
