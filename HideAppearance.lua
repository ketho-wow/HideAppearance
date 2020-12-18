local Wardrobe, showHidden
local f = CreateFrame("Frame")
local GetCategoryAppearances = C_TransmogCollection.GetCategoryAppearances

-- its confusing to check if a (LoadOnDemand) addon is/will be enabled
local function IsAddonEnabled(addon)
	local _, title = GetAddOnInfo(addon)
	local state = GetAddOnEnableState(nil, addon)
	return title and state > 0
end

local function PositionButton(cb, isAtTransmogrifier)
	cb:ClearAllPoints()
	if isAtTransmogrifier then
		cb:SetPoint("BOTTOMLEFT", Wardrobe.ModelR1C1, "TOPLEFT", -7, 10)
	elseif IsAddonEnabled("WardrobeSort") or IsAddonEnabled("LegionWardrobe") then
		cb:SetPoint("TOPRIGHT", Wardrobe.WeaponDropDown, "BOTTOMLEFT", -64, 5)
	else
		cb:SetPoint("TOPLEFT", Wardrobe.WeaponDropDown, "BOTTOMLEFT", 14, 5)
	end
end

-- probably not the right way to do this and taints everything
function C_TransmogCollection.GetCategoryAppearances(...)
	local visualsList = GetCategoryAppearances(...)
	if visualsList and HideAppearanceDB then
		for i = #visualsList, 1, -1 do
			local isHidden = HideAppearanceDB[visualsList[i].visualID]
			if (not showHidden and isHidden) or (showHidden and not isHidden) then
				tremove(visualsList, i)
			end
		end

	end
	return visualsList
end

function f:OnEvent(event, addon)
	if addon == "HideAppearance" then
		HideAppearanceDB = HideAppearanceDB or {}
		Wardrobe = WardrobeCollectionFrame.ItemsCollectionFrame
		-- hook all models
		for _, model in pairs(Wardrobe.Models) do
			model:HookScript("OnMouseDown", self.AddHideButton)
		end
		-- toggle for showing only hidden Appearances
		local cb = CreateFrame("CheckButton", nil, Wardrobe, "UICheckButtonTemplate")
		hooksecurefunc("ShowUIPanel", function(panel)
			if panel == CollectionsJournal then
				PositionButton(cb)
			elseif panel == WardrobeFrame then
				PositionButton(cb, true)
			end
		end)
		-- PositionButton(cb)
		cb.text:SetText("Show hidden")
		cb:SetScript("OnClick", function(btn)
			showHidden = btn:GetChecked()
			f:UpdateWardrobe()
		end)
		self:UnregisterEvent(event)
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

function f.AddHideButton(model, button)
	if button == "RightButton" then
		if not DropDownList1:IsShown() then -- force show dropdown
			WardrobeModelRightClickDropDown.activeFrame = model
			ToggleDropDownMenu(1, nil, WardrobeModelRightClickDropDown, model, -6, -3)
		end
		UIDropDownMenu_AddSeparator()
		local isHidden = HideAppearanceDB[model.visualInfo.visualID]
		UIDropDownMenu_AddButton({
			notCheckable = true,
			text = isHidden and SHOW or HIDE,
			func = function() f:ToggleTransmog(model, isHidden) end,
		})
	end
end

function f:ToggleTransmog(model, isHidden)
	local visualID = model.visualInfo.visualID
	local source = WardrobeCollectionFrame_GetSortedAppearanceSources(visualID)[1]
	local name, link = GetItemInfo(source.itemID)
	HideAppearanceDB[visualID] = not isHidden and name
	self:UpdateWardrobe()
	print(format("%s "..link.." from the Appearances Tab", isHidden and "Unhiding" or "Hiding"))
end

function f:UpdateWardrobe()
	Wardrobe:RefreshVisualsList()
	Wardrobe:UpdateItems()
end
