local GetCategoryAppearances = C_TransmogCollection.GetCategoryAppearances

-- probably not the right way to do this and taints everything
function C_TransmogCollection.GetCategoryAppearances(...)
	local visualsList = GetCategoryAppearances(...)
	if HideAppearanceDB then
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
		UIDropDownMenu_AddButton({notCheckable = true, disabled = true})
		UIDropDownMenu_AddButton({notCheckable = true, text = HIDE, func = function()
			f:HideTransmog(model)
		end})
	end
end

function f:HideTransmog(model)
	local visualID = model.visualInfo.visualID
	local source = WardrobeCollectionFrame_GetSortedAppearanceSources(visualID)[1]
	local name, link = GetItemInfo(source.itemID)
	HideAppearanceDB[visualID] = name
	WardrobeCollectionFrame.ItemsCollectionFrame:RefreshVisualsList()
	WardrobeCollectionFrame.ItemsCollectionFrame:UpdateItems()
	print("Hiding "..link.." from the Appearances Tab")
end
