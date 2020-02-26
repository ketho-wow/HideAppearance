local showHidden
local GetCategoryAppearances = C_TransmogCollection.GetCategoryAppearances

-- probably not the right way to do this and taints everything
function C_TransmogCollection.GetCategoryAppearances(...)
	local visualsList = GetCategoryAppearances(...)
	if HideAppearanceDB then
		-- iterate from end to beginning for tremove
		for i = #visualsList, 1, -1 do
			local isHidden = HideAppearanceDB[visualsList[i].visualID]
			if (not showHidden and isHidden) or (showHidden and not isHidden) then
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
		UIDropDownMenu_AddButton({ -- empty space
			notCheckable = true,
			disabled = true,
		})
		local isHidden = HideAppearanceDB[model.visualInfo.visualID]
		UIDropDownMenu_AddButton({
			notCheckable = true,
			text = isHidden and SHOW or HIDE,
			func = function() f:ToggleTransmog(model, isHidden) end,
		})
		UIDropDownMenu_AddButton({ -- allow showing all
			text = "Show hidden",
			checked = function() return showHidden end,
			func = function() showHidden = not showHidden; f:UpdateWardrobe() end,
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
	WardrobeCollectionFrame.ItemsCollectionFrame:RefreshVisualsList()
	WardrobeCollectionFrame.ItemsCollectionFrame:UpdateItems()
end
