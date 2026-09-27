--个人段位信息管理UI
RoleInfoSegmentUI = RoleInfoSegmentUI or
{
	
}

--注册widget
function bp_roleinfo_segment_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_segment,
			{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Segment_BP.RoleInfo_Segment_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
			{"Lobby"},
			false,
			false,
			true
	);
end


function RoleInfoSegmentUI.ShowUI()
	log("RoleInfoSegmentUI.ShowUI")	
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_segment)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UIShow")
	
	UIManager.Show(eUIType.eRoleInfoSegmentUI)

	RoleInfoUI.RequestBattleInfo()
	
	RoleInfoSegmentUI.UpdateRoleInfo()
end

function RoleInfoSegmentUI.HideUI()
	log("RoleInfoSegmentUI.HideUI")

	UIManager.Hide(eUIType.eRoleInfoSegmentUI)
	
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UIHide")

	pcall(function()
		if RoleInfoUI and RoleInfoUI.IsShow then
			RoleInfoUI.Hide()
		end
	end)
end

function RoleInfoSegmentUI.UpdateRoleInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UpdateRoleInfo");
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UpdatePlatformRight");
	RoleInfoSegmentUI.FreshCorpsInfo()
end


function RoleInfoSegmentUI.OnRoleInfoOpen()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "OnRoleInfoOpen");
end

function RoleInfoSegmentUI.RefreshAttrInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "RefreshAttrInfo");
end

function RoleInfoSegmentUI.UpdateAvatar()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UpdateAvatar")
end

function RoleInfoSegmentUI.UpdateHeadportraitReddot()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UpdateHeadportraitReddot")
end

function RoleInfoSegmentUI.FreshCorpsInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "FreshCorpsInfo")
end

function RoleInfoSegmentUI.SetPersonalBasicInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo_segment, "SetPersonalBasicInfo")
end

function RoleInfoSegmentUI.UpdateAchievementScore()
	log("RoleInfoSegmentUI.UpdateAchievementScore")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UpdateAchievementScore")
end

function RoleInfoSegmentUI.UpdateCarteamInfo()
	log("RoleInfoSegmentUI.UpdateCarteamInfo")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_segment, "UpdateCarteamInfo")
end

function RoleInfoSegmentUI.UpdateRoleNationInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo_segment, "UpdateRoleNationInfo")
end

function RoleInfoSegmentUI.SetSeasonCombatInfo()
	log("RoleInfoSegmentUI.SetSeasonCombatInfo")
	LuaClassObj.HandleUIMessage(bp_roleinfo_segment, "SetSegmentInfo")
end