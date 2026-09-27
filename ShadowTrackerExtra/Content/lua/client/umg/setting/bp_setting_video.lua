--一设置界面

SettingVideoUI = SettingVideoUI or 
{
	
}

--注册widget
function bp_setting_video_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_video,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Video_UIBP.Setting_Video_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby"},
	false,
	false,
	true
  );
end

function SettingVideoUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_video);
	LuaClassObj.HandleUIMessage(bp_setting_video, "InitUI");
end

function SettingVideoUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_video, "UIHide");
end
