--组队模式选 or
TeamUpModelUI = TeamUpModelUI or
{	
	listAllModelInfo = {
		{
		model_type = 1,
		model_id = 103,
		model_name = "经典模式",	-- 模式列表打开时看到的模式名称
		model_name_hide = "经典模式", -- 模式列表收起后看到的模式名称
		model_sub_name = "第一人称",  -- 模式子说明  第一人称/第三人称
		model_sub_name_type = 0,  -- 模式子说明样式
		
		perspective_name = "第三人称", -- 视角名称 第一人称/第三人称
		perspective_type = 100054,
		
		player_num = 4,
		player_num_name = "四人",
		is_open = true,
		is_lock = false,
		is_selected = false,
		
		seq = 0,	-- 排序用
		},
	},
	
	listPerspective = {
		{
			id = 0,
			name = "",
			last_model_id = 0,
		},
	},
	
	isShowing = false,
	
	curSelectedModelType = 0,
	curSelectedPlayerNum = 0,
	curSelectedPerspective = 0,
	
	ITEM_TYPE_MODEL = 0,
	ITEM_TYPE_PLAYER_NUM = 1,
	ITEM_TYPE_PERSPECTIVE = 2,
}

BP_STRUCT_TeamUpModelInfo =
{
	model_type = 0,
	
	model_id = 0,
	model_name = "",
	model_name_hide = "", -- 模式列表收起后看到的模式名称
	model_sub_name = "",  -- 模式子说明  第一人称/第三人称
	model_sub_name_type = 0,  -- 模式子说明样式
	
	perspective_name = "", -- 视角名称 第一人称/第三人称
	perspective_type= 0,
	
	player_num = 1,
	player_num_name = "",
	
	is_open = false,
	is_lock = false,
	is_selected = false,
	
	seq = 0,	-- 排序用
};

BP_ARRAY_TeamUpModelInfoList = 
{
	BP_STRUCT_TeamUpModelInfo = _G.BP_STRUCT_TeamUpModelInfo,
};

BP_STRUCT_ListItemInfo = 
{
	item_type = 0,
	id = 0,
	text = "",
	is_open = false,
	is_lock = false,
	is_selected = false,
	is_new = false,
};

BP_ARRAY_ListItemInfoList = 
{
	BP_STRUCT_ListItemInfo = _G.BP_STRUCT_ListItemInfo,
};

-- 视角列表
BP_STRUCT_ItemPerspective = 
{
	id = 0;
	name = "";
	last_model_id = 0;
};
BP_ARRAY_ListPerspective = 
{
	BP_STRUCT_ItemPerspective = _G.BP_STRUCT_ItemPerspective,
};

-- 当前选中模式
BP_TeamUpModel_SelectModelType = 0;
-- 当前选中人数
BP_TeamUpModel_PlayerNum = 0;
-- 当前选中视角
BP_TeamUpModel_Perspective = 0;
-- 当前是否自动匹配
BP_TeamUpModel_AutoMatch = 0;
-- 当前选中的模式数据
BP_STRUCT_CurSelectedModelInfo = _G.BP_STRUCT_TeamUpModelInfo;
--根据等级判定是否显示新手训练弱引导
BP_Teamup_Show_NewteachingGuide = false;
-- 地图路径
BP_Teamup_CurMapIconPath = "";
-- 当前地图名称
BP_Teamup_CurMapName = "";
-- 当前地图名称
BP_Teamup_CurMapName_Before = "";
--是否有新增游戏模式需要提示new
BP_MODETYPE_NEW = 0;
--是否有新增人数需要提示new
BP_PLAYERNUM_NEW = 0;
--是否有新开地图需要提示new
BP_MAPID_NEW = 0;
--是否有新的视角提示
BP_PERSPECTIVE_NEW = 0;
--是否显示跑马灯提示
BP_SCROLLBAR_TIPS = false;
--跑马灯内容
BP_MSG_CONTENT = "";
--跑马灯key，用于取消上报
SCROLLBAR_KEY = 0;
-- 当前选中的zone id
BP_TeamUp_ChooseZoneId = 0;
-- 当前选中的zone ip
BP_TeamUp_ChooseZoneIP = "";
-- 小红点
BP_Room_Hot_State = false;


local function BackLoginEventHandler(eventType, eventID, vars)
	--log("BackLoginEventHandler---TeamUpModelUI.listPerspective");
	TeamUpModelUI.listPerspective = {};
end

-- 注册面板
function bp_teamup_model_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_teamup_model,
        {
			{Path="/Game/UMG/UI_Logic/Lobby/Lobby_TeamModel_Ver2_Logic_BP.Lobby_TeamModel_Ver2_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_TEAMUP_MODEL_ZORDER},
		},
		{"Lobby"},
		false,
		bp_teamup_model_OnModeSwitched ~= nil
	);	
	--WidgetBlueprint'/Game/UMG/UI_Logic/Lobby/Lobby_TeamModel_Ver2_Logic_BP.Lobby_TeamModel_Ver2_Logic_BP'
	BP_TeamUpModel_SelectModelType = 1;
	BP_TeamUpModel_PlayerNum = 1;
	BP_STRUCT_CurSelectedModelInfo = {};
	
	TeamUpModelUI.curSelectedModelType = BP_TeamUpModel_SelectModelType;
	TeamUpModelUI.curSelectedPlayerNum = BP_TeamUpModel_PlayerNum;
	
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, TeamUpModelUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, TeamUpModelUI.WardRobeAvatarResetClose);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, TeamUpModelUI.PlayerLevelUp);
	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, BackLoginEventHandler);
	EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, TeamUpModelUI.UpdateLobbySkin);
	EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, TeamUpModelUI.OnNextDayHandler);

end

function TeamUpModelUI:WardRobeAvatarResetOpen()
    --log("TeamUpModelUI.WardRobeAvatarResetOpen")
    LuaClassObj.HandleUIMessageNoFetch(bp_teamup_model, "UIHideNative");
	LobbySceneManager.VisiableObjectsByTag("ResidenEvil", false)
end

function TeamUpModelUI:WardRobeAvatarResetClose()
    --log("TeamUpModelUI.WardRobeAvatarResetClose")
	--当打开商城的时候 不显示
	if StoreMainUI.bShow == false then
		LuaClassObj.HandleUIMessage(bp_teamup_model, "UIShowNative");
		if TeamUpMatchInfoUI.HasActivityModeInfo() then
			LobbySceneManager.VisiableObjectsByTag("ResidenEvil", true)
		end
	end
end

function TeamUpModelUI:PlayerLevelUp()
    log("TeamUpModelUI.PlayerLevelUp")
    TeamUpModelUI.CheckPerpectiveButtonShowing();
end

--进入Lobby显示组队界面
function bp_teamup_model_OnModeSwitched(gamestatus)
	log("bp_teamup_model_OnModeSwitched gamestatus = "..gamestatus)
	if _G._inCustomBattle and string.lower(gamestatus) == "lobby" then return end
	if string.lower(gamestatus) == "lobby" then
		--log("dddddddddddd"..#TeamUpModelUI.listAllModelInfo);
		if #TeamUpModelUI.listAllModelInfo > 0 then
			-- 必须有模式数据才能开启
			TeamUpModelUI.ShowPanel(TeamUpModelUI.curSelectedModelType, TeamUpModelUI.curSelectedPlayerNum);
		end
	end
end

-- utc0 拉取地图数据
function TeamUpModelUI.OnNextDayHandler()
	local interval = math.random(120);
	log("OnNextDayHandler.Tick, random = " .. tostring(interval));
	TeamUpModelUI.zeroPointTimer = Timer.InsertTimer(interval, TeamUpModelUI.OnTimerNextDayByRandomDelay, false);
end

function TeamUpModelUI.OnTimerNextDayByRandomDelay()
	if TeamUpModelUI.zeroPointTimer ~= nil then
		Timer.RemoveTimer(TeamUpModelUI.zeroPointTimer);
		TeamUpModelUI.zeroPointTimer = nil;
	end
	if string.lower(LuaClassObj.GetGameStatus(bp_lobby)) == "lobby" then
		TeamUpSystem.on_mode_shield_req();
	end
end

--弹出提示
function TeamUpModelUI.PopShieldTips(modelID)
	local shieldInfo = TeamUpSystem.GetShieldByType(modelID);
	if shieldInfo == nil then
		log("shieldInfo is none");
		return;
	end
	local tips = "";
	if shieldInfo.open_begin == 0 then		
		-- 无限期关闭,TODO,后续读取本地化表
		tips = DataMgr.GetMsgByID(110062);-- "该玩法暂时关闭，具体开放时间敬请留意邮件，感谢您的理解，您可以先体验其他玩法，谢谢！";
	elseif shieldInfo.open_begin > 0 then	
	
		if shieldInfo.open_end == 0 then
			--local dataTime = os.date("%Y-%m-%d-%H-%M", shieldInfo.open_begin);
			local dataTime = os.date("%m-%d %H:%M", shieldInfo.open_begin);
			--指定时间开放
			local newTips = DataMgr.GetMsgByID(110063);-- "该玩法将于%s开放，敬请期待！您可以先体验其他玩法，谢谢！";
			tips =string.format(newTips,tostring(dataTime));
		elseif shieldInfo.open_end > 0 then
			--指定时间段开放
			local startTime = os.date("%m-%d %H:%M", shieldInfo.open_begin);
			local endTime =  os.date("%m-%d %H:%M", shieldInfo. open_end);
			local newTips =  DataMgr.GetMsgByID(110064);-- "该玩法将于%s~%s开放，敬请期待！您可以先体验其他玩法，谢谢！";
			tips =string.format(newTips,tostring(startTime),tostring(endTime));
		end		
	end
	log("PopShieldTips"..tips);
	if tips ~= "" then
		CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, tips, nil, nil);		
	end
end

--弹出天命锁的提示
function TeamUpModelUI.PopDestinyTips()
	local openLv = DataMgr.GetDestinyModeOpenLevel();
	local str = DataMgr.GetMsgByID(110141);	
	-- if isrecruit ~= nil and isrecruit == true then	
	-- 	str = DataMgr.GetMsgByID(110142);	
	-- end				
	local showTip = string.format(str,tonumber(openLv));
	--弹出提示，等级不够
	DataMgr.ShowNoticeByString(showTip);	
end

--检查房间、训练场是否解锁，并弹出提示
function TeamUpModelUI.CheckRoomLock()
	-- local openLv = DataMgr.GetSystemConfig("RecruitmentTeamLevel5");
	-- local curLv = DataMgr.roleData.level;
	-- if openLv ~= nil and tonumber(curLv) < tonumber(openLv) then
	-- 	local str = DataMgr.GetMsgByID(110141);			
	-- 	local showTip = string.format(str,tonumber(openLv));
	-- 	--弹出提示，等级不够
	-- 	DataMgr.ShowNoticeByString(showTip);
	-- 	return true;
	-- end

	return false;		
end

function TeamUpModelUI.ShowPanel(defaultModelType, defaultPlayerNum)
	log("TeamUpModelUI:ShowPanel");
	TeamUpModelUI.isShowing = true;

	BP_Teamup_Show_NewteachingGuide = DataMgr.roleData.level == 10 and not DataMgr.team_up_has_guide_newteaching;
	
	--TeamUpModelUI.UpdateListModelInfo();
	TeamUpModelUI.ResetView(defaultModelType, defaultPlayerNum);
	
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UIShow");	
end

function TeamUpModelUI.HidePanel()
	TeamUpModelUI.isShowing = false;
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UIHide");
end

-- 当前队伍人数变化对面板的显示刷新
function TeamUpModelUI.UpdateCurTeamPlayerNum(curPlayerNum)
	if curPlayerNum == nil then
		curPlayerNum = 0;
	end

	for i,v in ipairs(TeamUpModelUI.listAllModelInfo) do
		v.is_lock = (curPlayerNum > v.player_num);
	end
	
	if curPlayerNum > TeamUpModelUI.curSelectedPlayerNum then
		-- 切换到下一个档位
		for i,v in ipairs(TeamUpModelUI.listAllModelInfo) do
			if TeamUpModelUI.curSelectedModelType == v.model_type and curPlayerNum <= v.player_num then
				TeamUpModelUI.curSelectedPlayerNum = v.player_num;
				BP_TeamUpModel_PlayerNum = v.player_num;
				BP_STRUCT_CurSelectedModelInfo = v;
				break;
			end
		end
	end
			
	-- 更新显示列表
	if #BP_ARRAY_ListItemInfoList > 0 then
		BP_ARRAY_ListItemInfoList = TeamUpModelUI.GetListItemInfo(BP_ARRAY_ListItemInfoList[1].item_type);
	end
	
	-- 刷新当前页面		
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateCurModelInfo");
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateListInfo");
end

function EventGetRoomHotSate()
	BP_Room_Hot_State = BP_CreateRoom_Hot_Point_IsShow or BP_CreateRoom_Adv_Hot_Point_IsShow
end

-- 刷新自动匹配状态
function TeamUpModelUI.UpdateAutoMatchStatus(teamInfoFill)
	BP_TeamUpModel_AutoMatch = teamInfoFill;
	LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangeAutoMatchStatus");
end

-- 隐藏列表
function TeamUpModelUI.HideList()
	log("TeamUpModelUI.HideList");
	if #BP_ARRAY_ListItemInfoList > 0 then
		local itemType = BP_ARRAY_ListItemInfoList[1].item_type;		
		if itemType == TeamUpModelUI.ITEM_TYPE_MODEL then
			LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangeMatchBtnSelectedStatus");	
		elseif itemType == TeamUpModelUI.ITEM_TYPE_PLAYER_NUM then
			LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangePlayerNumBtnSelectedStatus");	
		elseif itemType == TeamUpModelUI.ITEM_TYPE_PERSPECTIVE then
			LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangePerpectiveBtnSelectedStatus");	
		end

		LuaClassObj.HandleUIMessage(bp_teamup_model, "HideListInfo");	
		BP_ARRAY_ListItemInfoList = {};	
	end
end

-- 刷新当前模式
function TeamUpModelUI.SetCurSelectedModel(model_id)
	
	local isFind = false;
	
	log("TeamUpModelUI.SetCurSelectedModel "..tostring(model_id));
	--log_tree("TeamUpModelUI.listAllModelInfo", TeamUpModelUI.listAllModelInfo);
	
	for i,v in ipairs(TeamUpModelUI.listAllModelInfo) do
		if v.model_id == model_id then
			isFind = true;
			
			BP_STRUCT_CurSelectedModelInfo = v;
			TeamUpModelUI.curSelectedPlayerNum = v.player_num;
			BP_TeamUpModel_PlayerNum = v.player_num;
			
			TeamUpModelUI.curSelectedModelType = v.model_type;
			BP_TeamUpModel_SelectModelType = v.model_type;
			
			TeamUpModelUI.curSelectedPerspective = v.perspective_type;
			BP_TeamUpModel_Perspective = v.perspective_type;
			
			-- 更新当前视角的模式
			for kk,vv in pairs(TeamUpModelUI.listPerspective) do
				if vv.id == v.perspective_type then
					vv.last_model_id = v.model_id;
				end
			end
			
			break;
		end
	end
	
	if isFind then
		TeamUpModelUI.ResetView(BP_TeamUpModel_SelectModelType, BP_TeamUpModel_PlayerNum);
		-- 隐藏列表
		--TeamUpModelUI.HideList();
	end
	
	TeamUpModelUI.CheckPerpectiveButtonShowing();

	TeamUpMatchInfoUI.UpdateNewMapSkillInActivity()
end

-- 重置状态
function TeamUpModelUI.ResetView(defaultModelType, defaultPlayerNum)	
	log("TeamUpModelUI.ResetView ModelType:"..defaultModelType..", PlayerNum:"..defaultPlayerNum)

	BP_TeamUpModel_SelectModelType = defaultModelType;
	BP_TeamUpModel_PlayerNum = defaultPlayerNum;

	if defaultModelType ~= 4 then
		for k,v in pairs(TeamUpModelUI.listAllModelInfo) do
			if v.model_type == defaultModelType and v.player_num == defaultPlayerNum then
				v.is_selected = true;
				BP_STRUCT_CurSelectedModelInfo = v;
				break;
			end
		end
	end

	-- 刷新当前地图
	TeamUpModelUI.UpdateCurMapName();

	-- 刷新万圣节tip
	TeamUpModelUI.UpdateTip()
	
	TeamUpModelUI.curSelectedModelType = BP_TeamUpModel_SelectModelType;
	TeamUpModelUI.curSelectedPlayerNum = BP_TeamUpModel_PlayerNum;
	
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateCurModelInfo");
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateAutoMatchVisible");
end

-- 刷新当前可玩的游戏模式
function TeamUpModelUI.InitModel(modelSwitchTable, modelShields)
	--log_tree("TeamUpModelUI:InitModel modelSwitchTable", modelSwitchTable);
	--log_tree("TeamUpModelUI:InitModel modelShields", modelShields);
	
	TeamUpModelUI.listAllModelInfo = {};
	local modelConfig = {};
	local modelName = "";
	local modelNameHide = "";
	local modelSubName = "";
	local playerNumName = "";
	local isOpen = true;
	local perspectiveName = "";
	local isFind = false;
	local defalutLastModelId = 0;
	-- 主要记录本次登录的模式选择
	local oldPerspective = TeamUpModelUI.listPerspective;
	
	TeamUpModelUI.listAllModelInfo = {};
	TeamUpModelUI.listPerspective = {};
		
	for k,v in pairs(modelSwitchTable) do
		if v == 1 then
			modelConfig = Client.GetTableData("MatchModeTable", k);
			if modelConfig and modelConfig.PlayType == 1 then
				--log_tree("modelConfig",modelConfig);
				
				modelName = DataMgr.GetMsgByID(modelConfig.WordsToShowID);
				modelNameHide = DataMgr.GetMsgByID(modelConfig.ModeWhenHide);
				modelSubName = DataMgr.GetMsgByID(modelConfig.LabelWhenHide);
				playerNumName = DataMgr.GetMsgByID(modelConfig.PlayerNumStrID);
				perspectiveName = DataMgr.GetMsgByID(modelConfig.PersonPerspective);
				
				isOpen = true;
				for kk,vv in pairs(modelShields) do 
					if kk == modelConfig.ID then
						isOpen = not vv.is_shield;
					end
				end
								
				table.insert(TeamUpModelUI.listAllModelInfo,
				{
					model_type = modelConfig.ModeType,
					model_id = modelConfig.ID,
					model_name = modelNameHide,
					model_name_hide = modelNameHide,
					model_sub_name = modelSubName,
					model_sub_name_type = modelConfig.BackStyle,
					player_num = modelConfig.MaxTeamPlayerNum,
					player_num_name = playerNumName,
					
					perspective_name = perspectiveName,
					perspective_type = modelConfig.PersonPerspective;
					
					is_open = isOpen,
					is_lock = false,
					is_selected = false,
					
					seq = modelConfig.ShowSeq,
				});
				
				-- 获取当前可玩视角
				isFind = false;
				for kk,vv in pairs(TeamUpModelUI.listPerspective) do
					if vv.id == modelConfig.PersonPerspective then
						isFind = true;
						break;
					end
				end
				if not isFind then
					defalutLastModelId = 0;
					if oldPerspective then
						for kk,vv in pairs(oldPerspective) do
							if modelConfig.PersonPerspective == vv.id then
								defalutLastModelId = vv.last_model_id;
								break;
							end
						end
					end

					if defalutLastModelId == 0 then
						if modelConfig.PersonPerspective == 100053 then
							-- 经典四人第一人称
							defalutLastModelId = 403;
						elseif modelConfig.PersonPerspective == 100054 then
							-- 经典四人第三人称
							defalutLastModelId = 103;
						end
					end					
					
					table.insert(TeamUpModelUI.listPerspective,
					{
						id = modelConfig.PersonPerspective,
						name = perspectiveName,
						last_model_id = defalutLastModelId,
					});
				end
			end
		end
	end	
	
	-- 排序
	table.sort(TeamUpModelUI.listAllModelInfo,
		function (a, b)
			if a.seq ~= b.seq then
				return a.seq < b.seq;
			else
				return false;
			end
		end);

	table.sort(TeamUpModelUI.listPerspective,
		function (a, b)
			if a.id ~= b.id then
				return a.id > b.id;
			else
				return false;
			end
		end);

	--log_tree("InitModel TeamUpModelUI.listAllModelInfo", TeamUpModelUI.listAllModelInfo);
	--log_tree("InitModel TeamUpModelUI.listPerspective", TeamUpModelUI.listPerspective);
	--TeamUpModelUI.SetCurSelectedModel(TeamUpSystem.TeamInfo.team_type);
	-- 检查当前模式视角是否开启
	TeamUpModelUI.CheckPerpectiveButtonShowing();
end

function TeamUpModelUI.GetLastModelId(listPerspective, perspectiveType)
	-- 更新当前视角的模式
	local lastModelId = 0;
	for k,v in pairs(listPerspective) do
		if v.id == perspectiveType then
			lastModelId = v.last_model_id;
		end
	end
	
	-- 获取当前选择的人数
	if lastModelId ~= 0 then
		for k,v in pairs(TeamUpModelUI.listAllModelInfo) do
			if v.model_id == lastModelId then
				if TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.player_count and TeamUpSystem.TeamInfo.player_count > v.player_num then
					-- 当前实际人数大于上一次模式对应的人数
					lastModelId = 0;
				end		
				break;
			end
		end
	end	
	
	if lastModelId == 0 then
		if perspectiveType == 100053 then
			-- 经典四人第一人称
			lastModelId = 403;
		elseif perspectiveType == 100054 then
			-- 经典四人第三人称
			lastModelId = 103;
		end
	end
	
	return lastModelId;
end

function TeamUpModelUI.CheckPerpectiveButtonShowing()
	log("TeamUpModelUI.CheckPerpectiveButtonShowing");
	-- 当前模式如果队员模式
	if TeamUpSystem.IsTeamLeader() then
		-- 根据自己等级显示
		-- 当前模式视角大于1时
		local needShowing = #TeamUpModelUI.listPerspective > 1;
		
		-- 角色等级打到指定等级
		local openLv = DataMgr.GetFPPOpenLevel();
		if openLv ~= nil then
			needShowing = needShowing and (tonumber(openLv) <= DataMgr.roleData.level);
		end
		
		log("TeamUpSystem Is Team Leader status:"..tostring(needShowing));
		if needShowing then
			LuaClassObj.HandleUIMessage(bp_teamup_model, "ShowPerpectiveButton");
		else
			LuaClassObj.HandleUIMessage(bp_teamup_model, "HidePerpectiveButton");
		end
	else
		-- 如果不是队长，显示队长的模式选择视角
		local leaderUid = TeamUpSystem.TeamInfo.leader;
		log("TeamUpSystem Is Not Team Leader! leaderUid"..tostring(leaderUid));
		
		ProfileMgr.GetProfile(tonumber(leaderUid),
		function(profile_list)
			if nil == profile_list or 0 == #profile_list then
				return;
			end	
			
			local needShowing2 = false;
			local leaderProfile = profile_list[1];
			local openLv2 = DataMgr.GetFPPOpenLevel();
			if openLv2 ~= nil then
				needShowing2 = tonumber(openLv2) <= leaderProfile.level;
				log("openLv2:"..openLv2..", leaderProfile.level:"..leaderProfile.level);
			end
			log("TeamUpSystem Is Not Team Leader status:"..tostring(needShowing2));
			if needShowing2 then
				LuaClassObj.HandleUIMessage(bp_teamup_model, "ShowPerpectiveButton");
			else
				LuaClassObj.HandleUIMessage(bp_teamup_model, "HidePerpectiveButton");
			end
			
		end, false);
	end
	
	
end

-- 刷新当前可玩的游戏模式
function TeamUpModelUI.UpdateModel(modelSwitchTable, modelShields)
	--log_tree("TeamUpModelUI:UpdateModel modelSwitchTable", modelSwitchTable);
	--log_tree("TeamUpModelUI:UpdateModel modelShields", modelShields);
	
	TeamUpModelUI.listAllModelInfo = {};
	local modelConfig = {};
	local modelName = "";
	local playerNumName = "";
	local isOpen = true;
	
	for k,v in pairs(modelSwitchTable) do
		if v == 1 then
			modelConfig = Client.GetTableData("MatchModeTable", k);
			if modelConfig and modelConfig.PlayType == 1 then
				--log_tree("modelConfig",modelConfig);
				
				modelName = Client.GetTableData("LocalizeRes", modelConfig.WordsToShowID).TextValue;
				playerNumName = Client.GetTableData("LocalizeRes", modelConfig.PlayerNumStrID).TextValue;
				
				isOpen = true;
				for kk,vv in pairs(modelShields) do 
					if kk == modelConfig.ID then
						isOpen = not vv.is_shield;
					end
				end
								
				table.insert(TeamUpModelUI.listAllModelInfo,
				{
					model_type = modelConfig.ModeType,
					model_id = modelConfig.ID,
					model_name = modelName,
					player_num = modelConfig.MaxTeamPlayerNum,
					player_num_name = playerNumName,
					
					is_open = isOpen,
					is_lock = false,
					is_selected = false,
					
					seq = modelConfig.ShowSeq,
				});
			end
		end
	end	
	
	-- 排序
	table.sort(TeamUpModelUI.listAllModelInfo,
		function (a, b)
			if a.seq ~= b.seq then
				return a.seq < b.seq;
			else
				return false;
			end
		end);
		
	-- 检查当前模式是否可以用
	local canPlay = false;
	for i,v in ipairs(TeamUpModelUI.listAllModelInfo) do
		if v.model_id == TeamUpSystem.TeamInfo.team_type then
			canPlay = v.is_open and not v.is_lock;
			break;
		end
	end
	
	if not canPlay then
		-- 自动切换到一个可玩模式
		for i,v in ipairs(TeamUpModelUI.listAllModelInfo) do
			if v.is_open and not v.is_lock and v.player_num >= TeamUpSystem.TeamInfo.player_count then
				-- 变更当前模式
				TeamUpSystem.TeamInfo.team_type = v.model_id;
				canPlay = true;
				break;
			end
		end
	end
	
	if not canPlay then
		log("TeamUpModelUI.UpdateModel: no model can used!!!");
		return;
	end
	
	-- 刷新一下当前模式
	TeamUpModelUI.SetCurSelectedModel(TeamUpSystem.TeamInfo.team_type);
	if not TeamUpModelUI.isShowing then
		-- 打开面板
		log("TeamUpModelUI:UpdateModel showPanel type:"..TeamUpModelUI.curSelectedModelType..", num:"..TeamUpModelUI.curSelectedPlayerNum);
		
		TeamUpModelUI.ShowPanel(TeamUpModelUI.curSelectedModelType, TeamUpModelUI.curSelectedPlayerNum);
	end
end

-- 获取功能开启标识
function TeamUpModelUI.GetModelLockStatus(modelType)
	if modelType == 2 then
		local openLv = DataMgr.GetDestinyModeOpenLevel();
		local curLv = DataMgr.roleData.level;
		if openLv ~= nil then
			return tonumber(curLv) < tonumber(openLv);
		end
		
		return false;
	end
	
	return false;
end

-- 获取当前打开的内容列表
function TeamUpModelUI.GetListItemInfo(itemType)	
	local isFind = false;
	local listInfo = {};
		
	if itemType == TeamUpModelUI.ITEM_TYPE_MODEL then
		-- 模式列表
		for k,v in ipairs(TeamUpModelUI.listAllModelInfo) do
			isFind = false;
			for kk,vv in pairs(listInfo) do
				if vv.id == v.model_type then
					isFind = true;
					break;
				end
			end
			
			if not isFind and v.perspective_type == TeamUpModelUI.curSelectedPerspective then
				table.insert(listInfo, 
				{	item_type = itemType, 
					id = v.model_type, 
					text = v.model_name, 
					is_open = v.is_open, 
					is_lock = TeamUpModelUI.GetModelLockStatus(v.model_type),
					is_new = (v.model_type == BP_MODETYPE_NEW),
					is_selected = (TeamUpModelUI.curSelectedModelType == v.model_type)	});
			end
		end
	elseif itemType == TeamUpModelUI.ITEM_TYPE_PLAYER_NUM then
		-- 人数列表
		for k,v in pairs(TeamUpModelUI.listAllModelInfo) do		
			if TeamUpModelUI.curSelectedModelType == v.model_type and v.perspective_type == TeamUpModelUI.curSelectedPerspective then			
				table.insert(listInfo, 
				{	item_type = itemType, 
					id = v.player_num, 
					text = v.player_num_name, 
					is_open = v.is_open, 
					is_lock = v.is_lock, 
					is_new = (v.player_num == BP_PLAYERNUM_NEW),
					is_selected = (TeamUpModelUI.curSelectedPlayerNum == v.player_num)	});
			end
		end
	elseif itemType == TeamUpModelUI.ITEM_TYPE_PERSPECTIVE then
		-- 视角列表
		for k,v in pairs(TeamUpModelUI.listPerspective) do 
			table.insert(listInfo, 
			{	item_type = itemType, 
				id = v.id, 
				text = v.name, 
				is_open = true, 
				is_lock = false,
				is_new = (v.id == BP_PERSPECTIVE_NEW),
				is_selected = (TeamUpModelUI.curSelectedPerspective == v.id)	});
		end
	end
		
	return listInfo;
end

function TeamUpModelUI.PlayPanelEnterAni()
	LuaClassObj.HandleUIMessage(bp_teamup_model, "PlayPanelEnterAni");
end

function TeamUpModelUI.PlayPanelOutAni()
	LuaClassObj.HandleUIMessage(bp_teamup_model, "PlayPanelOutAni");
end

--取当前模式数据结构
function TeamUpModelUI.GetCurSelectModel()	
	return BP_STRUCT_CurSelectedModelInfo;
end

--取大模式类型
function TeamUpModelUI.GetCurSelectModelType()
	log("TeamUpModelUI.GetCurSelectModelType"..tostring(BP_STRUCT_CurSelectedModelInfo.model_type));
	return BP_STRUCT_CurSelectedModelInfo.model_type;
end

--点击匹配是否能进入
function TeamUpModelUI.CanStartMatchDestiny()
	local result = true;
	local curModelType = TeamUpModelUI.GetCurSelectModelType();
	local isLock = false;
	isLock = TeamUpModelUI.GetModelLockStatus(curModelType);
	local playerCount = 1;
	if TeamUpSystem.TeamInfo.player_count ~= nil then
		playerCount = TeamUpSystem.TeamInfo.player_count;
	end	
	--如果单人，并且
	if playerCount == 1 and isLock then
		TeamUpModelUI.PopDestinyTips();
		result = false;
	end
	return result;
end

-- 获取当前模式名称
function TeamUpModelUI.GetCurModelName()
	return BP_STRUCT_CurSelectedModelInfo.model_name.."-"..BP_STRUCT_CurSelectedModelInfo.player_num_name;
end
-- 获取模式类型
function TeamUpModelUI.GetCurModelType()
	if BP_STRUCT_CurSelectedModelInfo then
		return BP_STRUCT_CurSelectedModelInfo.model_type;
	else
		return 1;
	end
end

local function GetCurModelMapInfo()
	if not TeamUpSystem or not TeamUpSystem.ModeInfoList then
		return;
	end

	-- 获取当前模式对应的地图数据
	local curModelMapInfo = nil;
	if TeamUpSystem.IsTeamLeader() then
		for k,v in pairs(TeamUpSystem.ModeInfoList) do
			if k == BP_STRUCT_CurSelectedModelInfo.model_id then
				curModelMapInfo = v;
				break;
			end
		end
	else
		curModelMapInfo = TeamUpSystem.TeammateModeInfo;
	end

	return curModelMapInfo
end

function TeamUpModelUI.CheckIsShowTip(id)
	for i,j in pairs(BP_ARRAY_TeamUPHalloweenMapIdList) do
		if j == id then
			return true;
		end
	end
	return false;
end

local function HasHalloweenMapSelected(curModelMapInfo)
	if not curModelMapInfo then
		return false
	end

	for k,v in pairs(curModelMapInfo.mode_group) do
		if v.is_default == 1 and TeamUpModelUI.CheckIsShowTip(k) then
			return true
		end
	end

	return false
end

function TeamUpModelUI.UpdateTip()
	local showMapTip = false
	local halloweenID = 1
	local isHalloween = LoginSystem.commonSwitch.FestivalId == halloweenID

	if isHalloween then
		local curModelMapInfo = GetCurModelMapInfo()
		showMapTip = HasHalloweenMapSelected(curModelMapInfo)
	end

	if showMapTip then
		LuaClassObj.HandleUIMessage(bp_teamup_model, "ShowMapHalloweenTip");
	else
		LuaClassObj.HandleUIMessage(bp_teamup_model, "HideTip");
	end
end

-- 刷新当前地图
function TeamUpModelUI.UpdateCurMapName()
	local curModelMapInfo = GetCurModelMapInfo()

	if not curModelMapInfo then
		return;
	end
	--log_tree("UpdateCurMapName curModelMapInfo", curModelMapInfo);
	local mapId = 0;
	local selectedCount = 0;
	BP_Teamup_CurMapName = "";
	for k,v in pairs(curModelMapInfo.mode_group) do
		--log_tree("mode_group", v);
		if v.is_default == 1 then
			selectedCount = selectedCount + 1;
			mapId = k;
		end
	end

	if curModelMapInfo.model_type == 1 or curModelMapInfo.model_type == 3 then
		-- 已选地图
		BP_Teamup_CurMapName_Before = DataMgr.GetMsgByID(500047)..":";
	else
		-- 已选玩法
		BP_Teamup_CurMapName_Before = DataMgr.GetMsgByID(500046)..":";
	end
	
	if selectedCount == 1 then		
		local infoConfig = Client.GetTableData("ModeTeamTable", mapId);
		if infoConfig then
			BP_Teamup_CurMapName = FuncUtil.LocalizeResFormat( "6419",DataMgr.GetMsgByID(tonumber(infoConfig.mapName)));
		end
	else		
		-- 随机x张/x种
		if curModelMapInfo.model_type == 1 or curModelMapInfo.model_type == 3 then
			BP_Teamup_CurMapName = FuncUtil.LocalizeResFormat("6420", selectedCount);
		else
			BP_Teamup_CurMapName = FuncUtil.LocalizeResFormat("6421", selectedCount);
		end
	end
	
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapName");
	
	local infoConfig = Client.GetTableData("ModeTeamTable", mapId);
	if infoConfig then
		-- log_tree("infoConfig", infoConfig);
		-- BP_Teamup_CurMapIconPath = infoConfig.mapPath;
		if selectedCount == 1 then
			BP_Teamup_CurMapIconPath = infoConfig.LobbyEntryImagePath;
		else
			BP_Teamup_CurMapIconPath = infoConfig.LobbyRandomImagePath;
		end
		LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapIcon");
	end
end

function TeamUpModelUI.ShowRollTip()
	LuaClassObj.HandleUIMessage(bp_teamup_model, "ShowRollTip");
end

function TeamUpModelUI.CancelRollTip()
	LuaClassObj.HandleUIMessage(bp_teamup_model, "CancelRollTip");
end

function TeamUpModelUI.UpdateSelectedZoneId()
	BP_TeamUp_ChooseZoneId = TeamUpSystem.ChooseZoneId;
    for i, v in ipairs(TeamUpSystem.ChooseZoneList) do
        if BP_TeamUp_ChooseZoneId == v.zone_id then
            BP_TeamUp_ChooseZoneIP = v.tpingsvr_ip;
            break;
        end
    end
	LuaClassObj.HandleUIMessage(bp_teamup_model, "RefreshZoneName");
end

function EventFetchInfo()
	
end

function EventTeamUpRoomClick()
	EventTeamupMatchInfoClickRoom_Push()
end

function EventTeamUpTraningClick()
	EventTeamupMatchInfoClickTraining_Push()
end

-- 点击视角
function EventClickPerspective_Push()
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end
	
	BP_TeamUpModel_SelectModelType = TeamUpModelUI.curSelectedModelType;
	BP_TeamUpModel_PlayerNum = TeamUpModelUI.curSelectedPlayerNum;	
	BP_TeamUpModel_Perspective = TeamUpModelUI.curSelectedPerspective;
	BP_ARRAY_ListPerspective = TeamUpModelUI.listPerspective;
	
	BP_ARRAY_ListItemInfoList = TeamUpModelUI.GetListItemInfo(TeamUpModelUI.ITEM_TYPE_PERSPECTIVE);	
	--log_tree("BP_ARRAY_ListItemInfoList", BP_ARRAY_ListItemInfoList);
	
	-- 刷新当前地图
	TeamUpModelUI.UpdateCurMapName();

	-- 刷新万圣节tip
	TeamUpModelUI.UpdateTip()
	
	-- 刷新面板
	log("EventClickPerspective_Push Perspective:"..BP_TeamUpModel_Perspective);
	
	LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangePerpectiveBtnSelectedStatus");
	
	-- 隐藏组队好友
	TeamUPFriendUI.HidePanel();
end

-- 点击模式
function EventClickModel_Push()	
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end
	
	BP_TeamUpModel_SelectModelType = TeamUpModelUI.curSelectedModelType;
	BP_TeamUpModel_PlayerNum = TeamUpModelUI.curSelectedPlayerNum;	
	BP_TeamUpModel_Perspective = TeamUpModelUI.curSelectedPerspective;
	BP_ARRAY_ListItemInfoList = TeamUpModelUI.GetListItemInfo(TeamUpModelUI.ITEM_TYPE_MODEL);	
	--log_tree("BP_ARRAY_ListItemInfoList", BP_ARRAY_ListItemInfoList);
	
	-- 刷新当前地图
	TeamUpModelUI.UpdateCurMapName();

	-- 刷新万圣节tip
	TeamUpModelUI.UpdateTip()

	log("EventClickModel_Push model:"..BP_TeamUpModel_SelectModelType);
	LuaClassObj.HandleUIMessage(bp_teamup_model, "ShowChildBtnGroup");
	LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangeMatchBtnSelectedStatus");
	
	-- 隐藏组队好友
	TeamUPFriendUI.HidePanel();


end

-- 点击人数
function EventClickPlayerNum_Push()
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end
	
	BP_TeamUpModel_SelectModelType = TeamUpModelUI.curSelectedModelType;
	BP_TeamUpModel_PlayerNum = TeamUpModelUI.curSelectedPlayerNum;
	BP_TeamUpModel_Perspective = TeamUpModelUI.curSelectedPerspective;
	BP_ARRAY_ListItemInfoList = TeamUpModelUI.GetListItemInfo(TeamUpModelUI.ITEM_TYPE_PLAYER_NUM);		
	--log_tree("BP_ARRAY_ListItemInfoList", BP_ARRAY_ListItemInfoList);
	
	-- 刷新当前地图
	TeamUpModelUI.UpdateCurMapName();

	-- 刷新万圣节tip
	TeamUpModelUI.UpdateTip()
	
	log("EventClickPlayerNum_Push playerNum:"..BP_TeamUpModel_PlayerNum);	
	LuaClassObj.HandleUIMessage(bp_teamup_model, "HideChildBtnGroup");
	LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangePlayerNumBtnSelectedStatus");
	
	-- 隐藏组队好友
	TeamUPFriendUI.HidePanel();
end

-- 点击自动匹配
function EventAutoSelectSolo_Push()
	TeamUpSystem.team_change_type_request(101)
end

-- 点击自动匹配
function EventClickAutoMatch_Push()
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end
	
	if not TeamUpSystem.IsTeamLeader() then
		DataMgr.ShowNoticeByID(110003); --仅房主可设置
		return;
	end
		
	log("EventClickAutoMatch_Push status:"..BP_TeamUpModel_AutoMatch);	
	
	if BP_TeamUpModel_AutoMatch == 0 then
		BP_TeamUpModel_AutoMatch = 1;
	else
		BP_TeamUpModel_AutoMatch = 0;
	end
	
	--更新自动匹配选项
	TeamUpSystem.team_change_fill_request(BP_TeamUpModel_AutoMatch);
end

-- 点击地图
function EventClickMapList_Push()
	log("EventClickMapList_Push");
	--log_tree("BP_STRUCT_CurSelectedModelInfo", BP_STRUCT_CurSelectedModelInfo);
	TeamUpMaplUI.ShowPanel(BP_STRUCT_CurSelectedModelInfo.model_id);
end

-- 点击列表
function EventClickListItem_Push()
	log("EventClickListItem_Push modelType:"..BP_TeamUpModel_SelectModelType..", num:"..BP_TeamUpModel_PlayerNum..", Perpective:"..BP_TeamUpModel_Perspective);
	--log_tree("listAllModelInfo", TeamUpModelUI.listAllModelInfo);
	
	if #BP_ARRAY_ListItemInfoList == 0 then
		return;
	end
	
	if not TeamUpSystem.IsTeamLeader() then
		DataMgr.ShowNoticeByID(110003); --仅房主可设置
		return;
	end
	
	local itemType = BP_ARRAY_ListItemInfoList[1].item_type;	
			
	-- 检查当前模式是否可用
	local modelID = 0;
	local isLock = false;
	local isOpen = false;
	for i,v in ipairs(TeamUpModelUI.listAllModelInfo) do
		if itemType == TeamUpModelUI.ITEM_TYPE_MODEL then
			-- 点击的是模式，所有的模式只要有一个开启就算开启
			if v.model_type == BP_TeamUpModel_SelectModelType then
				if v.is_open then					
					isOpen = true;
					isLock = TeamUpModelUI.GetModelLockStatus(v.model_type);
					break;
				else
					modelID = v.model_id;
					isLock = TeamUpModelUI.GetModelLockStatus(v.model_type);
				end	
				
				if isLock then
					isOpen = false;
					isLock = TeamUpModelUI.GetModelLockStatus(v.model_type);
					break;
				end
			end
			
		elseif itemType == TeamUpModelUI.ITEM_TYPE_PLAYER_NUM then
			-- 点击的是人数
			if v.model_type == BP_TeamUpModel_SelectModelType and v.player_num == BP_TeamUpModel_PlayerNum then
				isLock = v.is_lock;
				isOpen = v.is_open;
				modelID = v.model_id;
				break;
			end
		elseif itemType == TeamUpModelUI.ITEM_TYPE_PERSPECTIVE then
			isOpen = true;
			break;	
		end
	end
	
	if not isOpen then
		-- 给出模式禁用提示
		TeamUpModelUI.PopShieldTips(modelID);
		return;
	end
	
	if isLock then
		-- 给出锁定提示
		if itemType == TeamUpModelUI.ITEM_TYPE_MODEL then
			-- 给出模式禁用提示
			TeamUpModelUI.PopDestinyTips();
		elseif itemType == TeamUpModelUI.ITEM_TYPE_PLAYER_NUM then
			DataMgr.ShowNoticeByID(110000); --当前队伍人数不满足
		end		
		return;
	end
		
	-- 更新当前模式
	if itemType == TeamUpModelUI.ITEM_TYPE_MODEL or itemType == TeamUpModelUI.ITEM_TYPE_PLAYER_NUM then
		for k,v in pairs(TeamUpModelUI.listAllModelInfo) do
			v.is_selected = false;
			if v.model_type == BP_TeamUpModel_SelectModelType and v.player_num == BP_TeamUpModel_PlayerNum then
				v.is_selected = true;
				BP_STRUCT_CurSelectedModelInfo = v;
				
				-- 更新当前选中的模式数据
				TeamUpModelUI.curSelectedModelType = BP_TeamUpModel_SelectModelType;
				TeamUpModelUI.curSelectedPlayerNum = BP_TeamUpModel_PlayerNum;
				TeamUpModelUI.curSelectedPerspective = BP_TeamUpModel_Perspective;
				
				-- 广播给其他队友
				TeamUpSystem.team_change_type_request(v.model_id);
		
				---每次点击都同步下限时开放数据
				--TeamUpSystem.on_mode_shield_req();			
			end
		end
	elseif itemType == TeamUpModelUI.ITEM_TYPE_PERSPECTIVE then
		local newModelID = TeamUpModelUI.GetLastModelId(TeamUpModelUI.listPerspective, BP_TeamUpModel_Perspective);
		--log_tree("TeamUpModelUI.listPerspective", TeamUpModelUI.listPerspective);
		log("PERSPECTIVE newModelID:"..newModelID);
		for k,v in pairs(TeamUpModelUI.listAllModelInfo) do
			v.is_selected = false;
			if newModelID == 0 or v.model_id == newModelID then
				v.is_selected = true;
				BP_STRUCT_CurSelectedModelInfo = v;
				
				-- 更新当前选中的模式数据
				TeamUpModelUI.curSelectedModelType = BP_TeamUpModel_SelectModelType;
				TeamUpModelUI.curSelectedPlayerNum = BP_TeamUpModel_PlayerNum;
				TeamUpModelUI.curSelectedPerspective = BP_TeamUpModel_Perspective;
				
				-- 广播给其他队友
				TeamUpSystem.team_change_type_request(v.model_id);
			end
		end
	end
				
	--log_tree("BP_STRUCT_CurSelectedModelInfo", BP_STRUCT_CurSelectedModelInfo);
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateCurModelInfo");	
	
	if itemType == TeamUpModelUI.ITEM_TYPE_MODEL then
		LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangeMatchBtnSelectedStatus");	
	elseif itemType == TeamUpModelUI.ITEM_TYPE_PLAYER_NUM then
		LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangePlayerNumBtnSelectedStatus");	
	elseif itemType == TeamUpModelUI.ITEM_TYPE_PERSPECTIVE then
		LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangePerpectiveBtnSelectedStatus");	
	end
	
	BP_ARRAY_ListItemInfoList = {};	

end
-- 点击房间
function EventClickRoom_Push()
	local isLock = TeamUpModelUI.CheckRoomLock();
	if isLock then
		return;
	end

	log("EventClickRoom_Push status:"..BP_TeamUpModel_AutoMatch);
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end
	
	if TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.player_count > 1 then
		DataMgr.ShowNoticeByID(110002); --请先退出组队
		return;
	end
	
	RoomUI:Init();
	RoomSystem.Enter();
	ClientSendBAReport(BP_BA_SHARE_ROOMREFASH, 0);
    ClientSendBAReport(BP_BA_LOBBY_ROOM_PANEL, 0);
end

-- 点击训练场
function EventClickTraining_Push()
	--log_tree("TeamUpSystem.TeamInfo", TeamUpSystem.TeamInfo);

	local isLock = TeamUpModelUI.CheckRoomLock();
	if isLock then
		return;
	end
	
	log("EventClickTraining_Push status:"..BP_TeamUpModel_AutoMatch..", playerNum:"..TeamUpSystem.TeamInfo.player_count);
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end	
	
	if TeamUpSystem.TeamInfo.player_count > 1 then
		local content = Client.GetTableData("LocalizeRes", "4145").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
		return;
	end
		
	NetUtil.SendPkg("on_match_req", 301, 0, nil);
	TeamUpSystem.matchIsTrainingMode = true;
end

-- 点击教学
function EventClickTeach_Push()
	log("EventClickTeach_Push status:"..BP_TeamUpModel_AutoMatch);
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end
	
	NewteachingUI.Show()
    ClientSendBAReport(BP_BA_LOBBY_NEWERGUIDE_PANEL, 0);	
end

-- 点击邀请 (delegates to FakeFriendSystem)
function EventClickInvite_Push()
	FakeFriendSystem.PerformInvite()
end

function EventSetHasGuideNewteaching()
	DataMgr.team_up_has_guide_newteaching = true;
end

function EventTeamupClickMatchInfo_Push()
	pcall(function() Client.ShowScreenDebugMessage("MAP_BTN: clicked") end)

	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014);
		return;
	end

	pcall(function()
		TeamUpMatchInfoUI.Show()
	end)
	-- Immediately suppress newbie guide overlay
	pcall(function()
		Timer.InsertTimer(0.1, function()
			pcall(function()
				LuaClassObj.HandleUIMessage(bp_teamup_match_info, "HideNewbieGuide")
			end)
			pcall(function()
				LuaClassObj.HandleUIMessage(bp_teamup_match_info, "HideUI")
			end)
		end)
	end)
end

BP_TeamUpModel_Cur_Lobby_Skin_Id = 0
function TeamUpModelUI.UpdateLobbySkin(eventType, eventID, skinId)
	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		skinId = 10004
	end
	
	BP_TeamUpModel_Cur_Lobby_Skin_Id = skinId;
	LuaClassObj.HandleUIMessageNoFetch(bp_teamup_model, "UpdateLobbySkin");
end

-- 从大厅场景点击进入，有活动才能进去
function EventTeamUpEnterEvilFromScene()
	-- 队员不可选择从场景进入，不响应点击
	if not TeamUpSystem.IsTeamLeader() then
		DataMgr.ShowNoticeByID(500045); --队员无法进行选择
		return;
	end
	
	-- 匹配中不可选择从场景进入，不响应点击
	if TeamUp_Is_Matching then
		return;
	end

	if TeamUpMatchInfoUI.HasActivityModeInfo() then
		TeamUpMatchInfoUI.Show();
		EventTeamupMatchInfoClickActivity_Push();
		LuaClassObj.HandleUIMessageNoFetch(bp_teamup_model, "PlayEvilClickSound");
	end
end

-- 界面入口显示隐藏
function TeamUpModelUI.SetEvilEntranceVisible(value)
	if TeamUpMatchInfoUI.HasActivityModeInfo() and BP_TeamUpModel_Cur_Lobby_Skin_Id == 10004 then
		if value then
			LuaClassObj.HandleUIMessageNoFetch(bp_teamup_model, "ShowEvil");
		else
			LuaClassObj.HandleUIMessageNoFetch(bp_teamup_model, "HideEvil");
		end 
	end
end

function EventClickTeamUpActEntryTPPFromScene()
    -- 队员不可选择从场景进入，不响应点击
    if not TeamUpSystem.IsTeamLeader() then
        DataMgr.ShowNoticeByID(500045); --队员无法进行选择
        return;
    end

    -- 匹配中不可选择从场景进入，不响应点击
    if TeamUp_Is_Matching then
        return;
    end

    if TeamUpMatchInfoUI.HasActivityModeInfo() then
        TeamUpMatchInfoUI.Show();
        if not BP_TeamUpMatchInfo_IsThirdPerson then
            TeamUpMatchInfoUI.EnterActivityFPPMode();
        else
            TeamUpMatchInfoUI.EnterActivityTPPMode();
        end
        LuaClassObj.HandleUIMessageNoFetch(bp_teamup_model, "PlayEvilClickSound");
    end
end