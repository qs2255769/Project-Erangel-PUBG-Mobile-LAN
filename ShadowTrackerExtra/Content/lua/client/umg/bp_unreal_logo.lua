
UnrealLogoUI = UnrealLogoUI or {
    
}

function bp_unreal_logo_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unreal_logo,
        {
            {Path = "/Game/UMG/UI_BP/Login/Unreal_UIBP.Unreal_UIBP_C", Container = "Default", ZOrder = 50},
        },
        {"Login", "CreateRole"},
        false,
        false,
        true
    );
end

function UnrealLogoUI.ShowUI()
	LuaClassObj.HandleDynamicCreation(bp_unreal_logo);
    LuaClassObj.HandleUIMessage(bp_unreal_logo, "UIShow");
end

function UnrealLogoUI.HideUI()
    LuaClassObj.HandleUIMessage(bp_unreal_logo, "UIHide");
end
