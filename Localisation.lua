local aname, atbl = ...
local L = {
	["%s has won %s."] = "%s has won %s.",
	["%s has won."] = "%s has won.",
	["A RaidRoll is already taking place."] = "A RaidRoll is already taking place.",
	["Commencing RaidRoll for %s :"] = "Commencing RaidRoll for %s :",
	["\"%s\" is not a correct Item Link."] = "\"%s\" is not a correct Item Link.",
	["Commencing RaidRoll:"] = "Commencing RaidRoll:",
}

atbl.L = setmetatable(L, {__index = function(t, k)
	t[k] = k
	return k
end})