--称号UI (patched for offline mode)
RoleInfoAliasUI = RoleInfoAliasUI or
{
	CurrentChangeState = 1; --小红点隐藏状态，如果是0表示是预览称号，1表示默认状态和使用称号，1会刷新界面。
	isNeedGuide = false;
	alias_type_warzone_nation = 1; --战区称号子类型
	BP_ALIAS_OPEN_TYPE = 0; --0：大厅界面个人称号选择 1：角色信息界面个人称号选择
	isShow = false,
}

enum_Alias_State_Type =
{
	notHave = 0,
	have = 1,
	use = 2,
}

enum_Alias_Select_Type = {
	all = 0,
	rank = 1,
	achievement = 2,
	fightData = 3,
}

enum_Alias_Sort_Type = {
	default = 0,
	date = 1,
	rarity = 2,
	a_z = 3,
}

enum_Alias_Jump_Type = {
	default = 0,
	season = 1,
	achievement = 2,
	pay = 3,
	fightArea = 4,
	leagueGame = 5,
}


BP_STRUCT_AliasInfo = {
	id = 0,
	aliasState = 0,
	aliasTitle = "",
	aliasReceiveTime = "",
	aliasExpireTime = "",
	aliasDesc = "",
	aliasGetDesc = "",
	aliasType = 0,
	aliasIconUrl = "",
	aliasQuality = 0,
	aliasSortWeight = 0,
	aliasReceiveTimeCompare = 0,
	aliasIsHaveUse = 0,
	aliasNation = "",
	aliasIconUrlBig = "",
	aliasExpireTimeNum = 0;
}

BP_ARRAY_AliasList = {
	BP_STRUCT_AliasInfo = _G.BP_STRUCT_AliasInfo;
}

BP_ARRAY_TypeListName = {
	"";
}

BP_ARRAY_SortListName = {
	"";
}

BP_Current_CheckHad = 0;
BP_Current_SelectType = 0;
BP_Current_SortType = 0;

BP_Current_SelectAliasId = 0;

arr_temp = {
	BP_STRUCT_AliasInfo = _G.BP_STRUCT_AliasInfo;
}



--注册Widget
function bp_roleinfo_alias_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_alias,
		{
		{Path="/Game/UMG/UI_Logic/RoleInfo/Title_managemen2_BP.Title_managemen2_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+20},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end


function RoleInfoAliasUI.Init()
	isShow = true
	RoleInfoAliasUI.initTypeList();
	RoleInfoAliasUI.initSortList();
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_alias);
	pcall(function() RoleInfoAliasSystem.Enter() end);
	pcall(function() RoleInfoAliasUI.refreshAliasList() end);
	if pcall(function() return DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1) end) and RoleInfoAliasUI.isNeedGuide then
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowNewbieTips2") end);
	end
	-- Force bring to front after widget is fully created and laid out.
	-- The profile's dark overlay (RoleInfo_Mgr_BP) covers the title widget on first open
	-- because HandleDynamicCreation + UIManager.Show runs before BP layout completes.
	pcall(function()
		Timer.InsertTimer(0.2, function()
			if isShow then
				pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowUI") end)
				pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowUI2") end)
				pcall(function() UIManager.Show(eUIType.eRoleinfoAlias) end)
				pcall(function() UIManager.Show(eUIType.eRoleInfoAliasUI) end)
				pcall(function() initAliasInfo() end)
				pcall(function() EventSelectCombox() end)
			end
		end)
	end)
end

function RoleInfoAliasUI.Hide()
	isShow = false

	log("RoleInfoAliasUI Hide");
	pcall(function() RoleInfoAliasUI.Release() end);
	RoleInfoAliasUI.CurrentChangeState = 1;
	if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "HideUI") end);
	else
		pcall(function() UIManager.Hide(eUIType.eRoleInfoAliasUI) end)
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "HideUI2") end);
	end

	pcall(function() UIManager.Hide(eUIType.eRoleinfoAlias) end)
end

--当前使用称号，以及称号列表数据
function RoleInfoAliasUI.refreshAliasList()
	if isShow == false then return end

	pcall(function() initAliasInfo() end);
	if RoleInfoAliasUI.CurrentChangeState == 1 then
		if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
			pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowUI") end);
			pcall(function() EventSelectCombox() end)
			if pcall(function() return DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1) end) and RoleInfoAliasUI.isNeedGuide then
				pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowNewbieTips") end);
			end
		else
			pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowUI2") end);
			pcall(function() UIManager.Show(eUIType.eRoleInfoAliasUI) end)
			pcall(function() EventSelectCombox() end)
			if pcall(function() return DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1) end) and RoleInfoAliasUI.isNeedGuide then
				pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowNewbieTips2") end);
			end
		end
	end
	pcall(function() UIManager.Show(eUIType.eRoleinfoAlias) end)

	DataMgr.roleData.alias.red_point = 0;
	pcall(function() LobbyUI:UpdateHeadportraitReddot() end);
	pcall(function() RoleInfoUI.UpdateHeadportraitReddot() end);
	pcall(function() RoleInfoUI.UpdateAliasInfo() end);
	pcall(function() LobbyUI:RefreshPlayerData() end);
end


function EventHideTitleNewbieTips()
	pcall(function() DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1) end)
end

function sortListFunction(a, b)
	if a.aliasState == b.aliasState then
		return a.id < b.id;
	else
		return a.aliasState > b.aliasState;
	end
end

function initAliasInfo()
	BP_ARRAY_AliasList = {};
	arr_temp = {};
	DataMgr.roleData.alias.id = 0;
	DataMgr.roleData.alias.title = "";
	DataMgr.roleData.alias.nation = "";
	RoleInfoAliasUI.isNeedGuide = false;
	BP_Current_SelectAliasId = 0;
	RoleInfoAliasUI.Empty();
	--称号信息
	for _k, _v in pairs(RoleInfoAliasSystem.alias_list_info) do
		local ok, cfg = pcall(function() return Client.GetTableData("AliasCfg", _k) end)
		if not ok then cfg = nil end
		-- PATCHED: removed cfg ~= nil filter — use defaults when cfg is nil
		do
			local myItem = {};
			myItem.id = _k;
			myItem.aliasState = _v.state;
			myItem.aliasQuality = (cfg and cfg.AliasQuality) or 0;
			myItem.aliasDesc = (cfg and cfg.AliasDesc) or "";
			myItem.aliasGetDesc = (cfg and cfg.AliasGetDesc) or "";
			myItem.aliasType = (cfg and tonumber(cfg.AliasType)) or 0;
			myItem.aliasIconUrl = (cfg and cfg.AliasIconPath) or "";
			myItem.aliasIconUrlBig = (cfg and cfg.AliasIconPathBig) or "";
			myItem.aliasSortWeight = (cfg and cfg.AliasSortWeight) or 0;
			myItem.aliasReceiveTimeCompare = _v.receive_time;
			myItem.aliasIsHaveUse = _v.have_used;
			myItem.aliasExpireTimeNum = _v.expire_ts;
			if _v.state == enum_Alias_State_Type.have or _v.state == enum_Alias_State_Type.use then
				pcall(function()
					myItem.aliasReceiveTime = FuncUtil.LocalizeResFormat( "6422", FuncUtil.SecToDateString(_v.receive_time));
				end)
				if not myItem.aliasReceiveTime then myItem.aliasReceiveTime = "" end
				if _v.expire_ts == 0 then
					local ok301, locRes = pcall(function() return Client.GetTableData("LocalizeRes",301300) end)
					myItem.aliasExpireTime = (ok301 and locRes and locRes.TextValue) or "Permanent";
				else
					pcall(function()
						myItem.aliasExpireTime = FuncUtil.SecToDateString(_v.expire_ts);
					end)
					if not myItem.aliasExpireTime then myItem.aliasExpireTime = "" end
				end
				myItem.aliasTitle = _v.title;
				myItem.aliasReceiveTimeCompare = _v.receive_time;
				myItem.aliasIsHaveUse = _v.have_used;
				myItem.aliasNation = _v.nation;
			else
				myItem.aliasReceiveTime = 0;
				myItem.aliasExpireTime = 0;
				myItem.aliasTitle = (cfg and cfg.AliasName) or _v.title or "";
				myItem.aliasReceiveTimeCompare = 0;
				myItem.aliasIsHaveUse = 0;
				myItem.aliasNation = "";
			end
			--发现有可以用的称号，改变状态
			-- OFFLINE FIX: suppress newbie guide loop
			--if _v.state == enum_Alias_State_Type.have then
			--	RoleInfoAliasUI.isNeedGuide = true;
			--end
	        if _v.state == enum_Alias_State_Type.use then
	        	BP_STRUCT_AliasInfo = myItem;

	        	if BP_Current_SelectAliasId == 0 or BP_Current_SelectAliasId == "" then
	        		BP_Current_SelectAliasId = _k;
	        	end

	        	--更新个人信息的称号
	        	DataMgr.roleData.alias.id = myItem.id;
	        	DataMgr.roleData.alias.title = myItem.aliasTitle;
	        	DataMgr.roleData.alias.nation = myItem.aliasNation;
	        end
	        table.insert(BP_ARRAY_AliasList, myItem);
	        table.insert(arr_temp, myItem);
		end -- do
	end -- for

	table.sort( BP_ARRAY_AliasList, sortListFunction );

	if BP_Current_SelectAliasId == 0 and #BP_ARRAY_AliasList > 0 and RoleInfoAliasUI.isNeedGuide == true then
		BP_Current_SelectAliasId = BP_ARRAY_AliasList[1].id;
		BP_STRUCT_AliasInfo = BP_ARRAY_AliasList[1];
	end

	if #BP_ARRAY_AliasList == 0 then
		BP_STRUCT_AliasInfo = {};
		BP_Current_SelectAliasId = 0;
	end
end

function RoleInfoAliasUI.initTypeList()
	BP_ARRAY_TypeListName= {};
	pcall(function()
		local data = Client.GetTableData("LocalizeRes",4462);
		table.insert(BP_ARRAY_TypeListName, data.TextValue);
		for id=4675,4677 do
			local data = Client.GetTableData("LocalizeRes",id);
			table.insert(BP_ARRAY_TypeListName, data.TextValue);
		end
	end)
	if #BP_ARRAY_TypeListName == 0 then
		BP_ARRAY_TypeListName = {"All", "Rank", "Achievement", "Battle"}
	end
end

function RoleInfoAliasUI.initSortList()
	BP_ARRAY_SortListName = {};
	pcall(function()
		for id=4670,4673 do
			local data = Client.GetTableData("LocalizeRes",id);
			table.insert(BP_ARRAY_SortListName, data.TextValue);
		end
	end)
	if #BP_ARRAY_SortListName == 0 then
		BP_ARRAY_SortListName = {"Default", "Date", "Rarity", "A-Z"}
	end
end

function RoleInfoAliasUI.Empty()
	BP_STRUCT_AliasInfo = {
	}
end


function RoleInfoAliasUI.Release()
	BP_ARRAY_AliasList = {};
	RoleInfoAliasUI.Empty();
	arr_temp = {};
	BP_ARRAY_TypeListName = {};
	BP_ARRAY_SortListName = {};
	BP_Current_SelectAliasId = 0;
	RoleInfoAliasUI.Empty();
	RoleInfoAliasUI.isNeedGuide = false;
	RoleInfoAliasUI.AliasReddot = 0;
end

function sortFunction(a, b)
	if a.aliasReceiveTimeCompare == b.aliasReceiveTimeCompare then
		return a.aliasSortWeight > b.aliasSortWeight;
	else
		return a.aliasReceiveTimeCompare > b.aliasReceiveTimeCompare;
	end
end

--选择显示
function EventSelectCombox()
	BP_Current_SelectAliasId = 0;
	RoleInfoAliasUI.Empty();
	BP_ARRAY_AliasList = {};
	--根据类型筛选数据
	for k, v in pairs(arr_temp) do
		if BP_Current_SelectType > 0 then
			if BP_Current_CheckHad == 1 then
				if (v.aliasState == enum_Alias_State_Type.have or v.aliasState == enum_Alias_State_Type.use) and v.aliasType == BP_Current_SelectType then
        			table.insert(BP_ARRAY_AliasList, v);
        			if BP_Current_SelectAliasId == 0 then
        				BP_STRUCT_AliasInfo = v;
        				BP_Current_SelectAliasId = v.id;
        			end
				end
			else
				if v.aliasType == BP_Current_SelectType then
        			table.insert(BP_ARRAY_AliasList, v);
				end
			end
		else
			if BP_Current_CheckHad == 1 then
				if v.aliasState == enum_Alias_State_Type.have or v.aliasState == enum_Alias_State_Type.use then
        			table.insert(BP_ARRAY_AliasList, v);
        			if BP_Current_SelectAliasId == 0 then
        				BP_STRUCT_AliasInfo = v;
        				BP_Current_SelectAliasId = v.id;
        			end
				end
			else
    			table.insert(BP_ARRAY_AliasList, v);
			end
		end
	end
	table.sort( BP_ARRAY_AliasList, sortListFunction );

	if #BP_ARRAY_AliasList == 0 then
		BP_STRUCT_AliasInfo = {};
		BP_Current_SelectAliasId = 0;
	else
		BP_Current_SelectAliasId = BP_ARRAY_AliasList[1].id;
		BP_STRUCT_AliasInfo = BP_ARRAY_AliasList[1];
	end

	if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "refreshList") end);
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "upDateAliasItemSelect") end);
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "updateCurrentAlias") end);
	else
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "refreshList2") end);
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "upDateAliasItemSelect2") end);
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "updateCurrentAlias2") end);
	end
end

function EventAliasUpDateSelect()
	local isNeedChange = false;
	local selId = tostring(BP_Current_SelectAliasId);
	for k, v in pairs(BP_ARRAY_AliasList) do
		if tostring(v.id) == selId then
			if v.aliasState == enum_Alias_State_Type.have and v.aliasIsHaveUse == 0 then
				v.aliasIsHaveUse = 1;
				isNeedChange = true;
			end
			BP_STRUCT_AliasInfo = v;
		end
	end
	if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "updateCurrentAlias") end);
	else
		pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "updateCurrentAlias2") end);
	end
	RoleInfoAliasUI.CurrentChangeState = 0;
	if isNeedChange then
		pcall(function() RoleInfoAliasSystem.change_alias_req(BP_Current_SelectAliasId, RoleInfoAliasUI.CurrentChangeState) end);
	end
end

function EventUseAlias()
	RoleInfoAliasUI.CurrentChangeState = 1;
	pcall(function() RoleInfoAliasSystem.change_alias_req(BP_Current_SelectAliasId, RoleInfoAliasUI.CurrentChangeState) end);
end

function EventOnJump()
	pcall(function()
		local cfg = Client.GetTableData("AliasCfg", BP_Current_SelectAliasId);
		if cfg ~= nil then
			if cfg.AliasJumpUrl == enum_Alias_Jump_Type.season then
				RoleInfoAliasUI.Hide();
				RoleInfoUI.BtnCloseRoleInfo();
				pcall(function() SeasonUI.Show() end);
				local t = Timer.InsertTimer(1.0, function() pcall(function() SeasonUI.ShowSeasonAward() end) end, false, true);
			elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.achievement then
				RoleInfoAliasUI.Hide();
				pcall(function() TaskUI.OpenTaskWithIndex(4) end);
			elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.pay then
				RoleInfoAliasUI.Hide();
				RoleInfoUI.BtnCloseRoleInfo();
				pcall(function() RechargeUI:Init() end);
			elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.fightArea then
				RoleInfoAliasUI.Hide();
				RoleInfoUI.BtnCloseRoleInfo();
				pcall(function() LobbyUI.EnterWarZone() end);
			elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.leagueGame then
				RoleInfoAliasUI.Hide();
				RoleInfoUI.BtnCloseRoleInfo();
				pcall(function() LeagueGameLobbyUI.Init() end);
			end
		end
	end)
	if pcall(function() return RoleInfoShowInfoUI.bShow end) then
		pcall(function() RoleInfoShowInfoUI.Hide() end);
	end
end

function EventAliasUIHide()
	RoleInfoAliasUI.Hide();
end

function EventRemoveAlias()
	RoleInfoAliasUI.CurrentChangeState = 1;
	pcall(function() RoleInfoAliasSystem.change_alias_req(0, 0) end);
end
