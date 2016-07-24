local aname, atbl = ...
local addon = CreateFrame("Frame", aname)
local L = atbl.L
local roll_pattern = "^"..(RANDOM_ROLL_RESULT:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)").."$" --RANDOM_ROLL_RESULT = "%s rolls %d (%d-%d)";
local item_pattern = "^(|cff%x%x%x%x%x%x"..TEXT_MODE_A_STRING_ITEM:gsub("%%s", ".+").."|r)$" --TEXT_MODE_A_STRING_ITEM = "|Hitem:%s|h%s|h";

local playername = UnitName("player")
addon.raidroster = {}


function addon:SendMessage(msg) --todo possibly add option to set your own channel
	SendChatMessage(msg,"RAID")
end

function addon:OnEvent(event, msg)
	if not self.processingresult then return end --apparently theres a bug with 3.3.3
	
	local name, result, min, max = msg:match(roll_pattern)
	if name == playername and min == "1" and tonumber(max) == addon.raidsize then
		if self.prize then self:SendMessage(L["%s has won %s."]:format(self.raidroster[tonumber(result)], self.prize))
		else self:SendMessage(L["%s has won."]:format(self.raidroster[tonumber(result)]))
		end
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self.processingresult = nil
	end
end
addon:SetScript("OnEvent", addon.OnEvent)

function addon:Error(msg)
	local info = ChatTypeInfo["SYSTEM"]
	ChatFrame1:AddMessage(msg, info.r, info.g, info.b, info.id)
end

function SlashCmdList.RAIDROLL(msg)
	if not UnitInRaid("player") then
		addon:Error(ERR_NOT_IN_RAID)
		return
	end
	if addon.processingresult then
		addon:Error(L["A RaidRoll is already taking place."])
		return
	end
	if msg ~= "" then
		local prize = msg:match(item_pattern)
		if prize then
			addon.prize = prize
			addon:SendMessage(L["Commencing RaidRoll for %s :"]:format(prize))
		else
			addon:Error(L["\"%s\" is not a correct Item Link."]:format(msg))
			return
		end
	else
		addon.prize = nil
		addon:SendMessage(L["Commencing RaidRoll:"])
	end
	
	local s, x, name = ""
	addon.raidsize = 0
	for i=1, MAX_RAID_MEMBERS do
		name = GetRaidRosterInfo(i)
		if name then
			addon.raidsize = addon.raidsize + 1
			addon.raidroster[addon.raidsize] = name
			x = s..addon.raidsize..": "..name.."  "
			if #x > 255 then
				addon:SendMessage(s)
				s = ""
			else
				s = x
			end
		end
	end
	if s ~= "" then
		addon:SendMessage(s)
	end
	addon.processingresult = true
	addon:RegisterEvent("CHAT_MSG_SYSTEM")
	RandomRoll(1, addon.raidsize)
end

SLASH_RAIDROLL1 = "/raidroll"
SLASH_RAIDROLL2 = "/rroll"
SLASH_RAIDROLL3 = "/rr"