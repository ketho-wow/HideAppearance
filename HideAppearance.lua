local showHidden
local GetCategoryAppearances = C_TransmogCollection.GetCategoryAppearances

-- probably not the right way to do this and taints everything
function C_TransmogCollection.GetCategoryAppearances(...)
	local visualsList = GetCategoryAppearances(...)
	if HideAppearanceDB and not showHidden then
		-- iterate from end to beginning for tremove
		for i = #visualsList, 1, -1 do
			if HideAppearanceDB[visualsList[i].visualID] then
				tremove(visualsList, i)
			end
		end
	end
	return visualsList
end

local f = CreateFrame("Frame")

function f:OnEvent(event, addon)
	if addon == "HideAppearance" then
		HideAppearanceDB = HideAppearanceDB or {}
		for _, model in pairs(WardrobeCollectionFrame.ItemsCollectionFrame.Models) do
			model:HookScript("OnMouseDown", self.AddHideButton)
		end
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
		UIDropDownMenu_AddButton({notCheckable = true, disabled = true}) -- empty space
		if not showHidden then -- only show Hide option when actively filtering
			UIDropDownMenu_AddButton({notCheckable = true, text = HIDE, func = function() f:HideTransmog(model) end})
		end
		-- allow toggling hiding
		local info = UIDropDownMenu_CreateInfo()
		info.text = "Show hidden"
		info.checked = function() return showHidden end
		info.func = function() showHidden = not showHidden; f:UpdateWardrobe() end
		UIDropDownMenu_AddButton(info)
	end
end

function f:HideTransmog(model)
	local visualID = model.visualInfo.visualID
	local source = WardrobeCollectionFrame_GetSortedAppearanceSources(visualID)[1]
	local name, link = GetItemInfo(source.itemID)
	HideAppearanceDB[visualID] = name
	self:UpdateWardrobe()
	print("Hiding "..link.." from the Appearances Tab")
end

function f:UpdateWardrobe()
	WardrobeCollectionFrame.ItemsCollectionFrame:RefreshVisualsList()
	WardrobeCollectionFrame.ItemsCollectionFrame:UpdateItems()
end
