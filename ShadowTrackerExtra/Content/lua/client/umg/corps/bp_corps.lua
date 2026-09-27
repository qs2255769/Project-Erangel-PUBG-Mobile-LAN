-- 军团UI

CorpsUI = CorpsUI or {
	
}


BP_Corps_Checkbox_ID = 0
BP_Corps_NeedReOpenRoleInfo = false
local curId = 0
local OpenList = 
{
	[1] = {nil,nil}, -- 军团列表界面
	[2] = {nil,nil}, -- 军团创建界面
	[3] = {nil,nil}, --军团排行
}

local isOpen = false

BP_CorpsUI_Has_New_IvitedCorps = false;

--注册Widget
function bp_corps_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_corps,
    {{Path="/Game/UMG/UI_Logic/Corps/Corps_BP.Corps_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_ZORDER}},
    {"Lobby"},
	false,
	false,
	true
  );

	LuaClassObj.SubShowHideEvent(bp_corps, { "Corps_BP_C" });
	
  	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsUI.OnReceivedJoinCorps)
  	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CORPS_CENTER, CorpsUI.JumpUrl)
end

function CorpsUI.RegisterPanelEvent(index , openFuction, closeFunction)
	if index <= #OpenList then
		OpenList[index][1] = openFuction
		OpenList[index][2] = closeFunction
	end
end

function CorpsUI.JumpUrl(type, moduleID, params)
	local idStr = params["id"];
	if idStr ~= nil then
		local id = tonumber(idStr);
		CorpsUI.InitByPanel(id);
	end
end

function CorpsUI.OpenSuggestionShowUI()
	EventCorpsSuggestionShowUI();
end

function CorpsUI.OpenSuggestionHideUI()
	EventCorpsSuggestionHideUI();
end

function CorpsUI.OpenCreateShowUI()
	EventCorpsCreateShowUI();
end

function CorpsUI.OpenCreateHideUI()
	EventCorpsCreateHideUI();
end
	
function CorpsUI.OpenPanel(index)
	log("CorpsUI.OpenPanel" .. index);
	curId = index
	-- log_tree("!!!!!" , OpenList)
	if OpenList[curId][1] ~= nil then
		log("!!!!!!!!!!!!!");
		OpenList[curId][1]()
	end
end

function CorpsUI.ClosePanel()
	log("CorpsUI.ClosePanel");
	if curId ~= 0 then
		if OpenList[curId][2] ~= nil then
			OpenList[curId][2]()
		end
	end
end

function CorpsUI.Init()
	log("CorpsUI.Init");
	CorpsUI.InitByPanel(1)
	CorpsUI.UpdateRedPoint();
end

function CorpsUI.UpdateRedPoint()
	-- BP_CorpsUI_Has_New_IvitedCorps = CorpsMgr.HasRedDot("invited_corps");
	-- LuaClassObj.HandleUIMessageNoFetch("UpdateRedPoint");
end

function CorpsUI.InitByPanel(index)
	if DataMgr.corpsInfo.id ~= 0 then
		ShowNotice(411012);
		return;
	end

	isOpen = true
	LuaClassObj.HandleDynamicCreation(bp_corps);
	LuaClassObj.HandleUIMessage(bp_corps, "UIShow");
	UIManager.Show(eUIType.eCorpsUI);
	CorpsUI.OpenPanel(index)
end

function CorpsUI.UIClose()
	EventOnCorpsClose();
end

function CorpsUI.Release()
	log("CorpsUI.Release");
end

function EventClickToggle_Push()
	log("EventClickToggle_Push");
	CorpsUI.ClosePanel()
	CorpsUI.OpenPanel(BP_Corps_Checkbox_ID)
end


--关闭界面
function EventOnCorpsClose()
	BP_CorpsSuggestionShowAnimation = true
	isOpen = false
	log("EventOnCorpsClose");
    CorpsUI.Release()
	CorpsUI.ClosePanel()
	CorpsShopUI.CloseUI()
	curId = 0
	UIManager.Hide(eUIType.eCorpsUI);
	LuaClassObj.HandleUIMessageNoFetch(bp_corps, "UIClose");
	CorpsUI.CheckReOpenRoleInfo();
	-- Restore lobby
	pcall(function()
		local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
		if lobbyBP then
			lobbyBP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
		end
	end)
	pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StartMallToLobby") end)
	pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIShowFromMall") end)
	pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "UIShow") end)
	pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "UIShow") end)
	pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup_model, "UIShow") end)
	pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_chat_entrance, "UIShow") end)
	pcall(function() LobbyUI:ShowLobbyPlayer(true) end)
end

function CorpsUI.CheckReOpenRoleInfo()
	if BP_Corps_NeedReOpenRoleInfo then
		RoleInfoUI.ReOpenWnd()
		BP_Corps_NeedReOpenRoleInfo = false
	end
end

function CorpsUI.OpenByRoleInfo()
	BP_Corps_NeedReOpenRoleInfo = true
end

function CorpsUI.OnReceivedJoinCorps()
	if CorpsMgr.IsInCorps() and isOpen then
		EventOnCorpsClose()
		LobbySystem.OpenCorpsUI()
	end
end