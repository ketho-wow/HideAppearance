local _, namespace = ...

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

namespace.L = L

local LOCALE = GetLocale()

if LOCALE == "enUS" then
	L["ShowHidden"] = "Show hidden"
return end


if LOCALE == "frFR" then
	L["ShowHidden"] = "Afficher les cachés"
return end