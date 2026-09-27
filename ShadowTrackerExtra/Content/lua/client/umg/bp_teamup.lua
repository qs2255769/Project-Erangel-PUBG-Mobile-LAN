--组队UI
TeamUpUI = TeamUpUI or
{
	
}

local TEAMUP_MAX_MEMBER_SOLO = 1;
local TEAMUP_MAX_MEMBER_DOUBLE = 2;
local TEAMUP_MAX_MEMBER_QUAD = 4;

TEAMUP_INVITE_TIP = "";
TEAMUP_APPLY_TIP = "";
TEAMUP_INVITE_TIMEOUT_TIP = "";
TEAMUP_APPLY_TIMEOUT_TIP = "";

TEAMUP_TEAM_TYPE_SOLO = 101;
TEAMUP_TEAM_TYPE_DOUBLE = 102;
TEAMUP_TEAM_TYPE_QUAD = 103;

TEAMUP_CHS_NAME_SOLO = "";
TEAMUP_CHS_NAME_DOUBLE = "";
TEAMUP_CHS_NAME_QUAD = "";
TEAMUP_CHS_NAME_NONE = "";

TeamUp_Is_Matching = false;			--是否在匹配中

TeamUp_CrtTeam_ID = "0";			--当前的队伍ID（单人也是队伍）

TeamUp_CrtTeam_Count = 0;		--当前队伍的人数

TeamUp_Host_ID = "0";			--房主ID

TeamUp_My_User_ID = "0";		---自己的ID

TeamUp_IsSelfHost = true;		--房主是否是自己

TeamUp_Team_Type = 103;			--队伍类型 101 102 103

TeamUp_Change_Team_Type = 103;	--UI上点击的队伍类型

TeamUp_Team_Type_Name = TEAMUP_CHS_NAME_QUAD; --选中的队伍类型名字

TeamUp_Invite_Apply_Type = 0; 	--0是邀请，1是申请

TeamUp_Inviter_Name = "";		--邀请我组队的好友名字

TeamUp_Applyer_Name = "";		--申请加入的玩家名字

TeamUp_AutoMatch = true;		--是否自动匹配队友

TeamUp_Count_Down = 5;			--倒计时5秒自动拒绝

TeamUp_IS_LOCK_SOLO = false;	--单人模式是否锁定

TeamUp_IS_LOCK_DOUBLE = false;	--双人模式是否锁定

TeamUp_IS_LOCK_QUAD = false;	--四人模式是否锁定

TeamUp_Auto_Refuse = false;		--是否自动拒绝邀请/申请

TeamUp_Click_Player_Name = "玩家名字";	---点击的玩家名字

TeamUp_Click_Player_ID = "0";	---点击的玩家ID
TeamUp_Click_Player_IS_FRIEND = false;	---点击的玩家是否好友

TeamUp_Click_Switch_Camera = false;

TeamUp_Click_Switch_Camera_Time = 2;

TeamUp_Quick_Msg_GID = "";

TeamUp_Quick_Msg_Content = "";

TeamUp_Fill = 1;

TeamUp_Will_Change_Fill = 0;

TeamUp_Team_Code = ""

------------------------------intl start----------------------------
-- 服务器返回的选择大区id
BP_SvrBackChoosedZoneId = ""
-- 服务器返回选服结果 ok, nil zone, player_matching, not-leader
BP_SvrBackChooseZoneResult = "" 
BP_STRUCT_ChooseZoneInfo =
{
	zone_id = 0,
	tpingsvr_ip = "",
	tpingsvr_port = "",
};
BP_ARRAY_ChooseZoneList =
{
	BP_STRUCT_ChooseZoneInfo = _G.BP_STRUCT_ChooseZoneInfo,
};

BP_SelectRegionVoiceUrl = ""

BP_DestinyIsLock = false; --天命圈是否显示锁
------------------------------intl end----------------------------


--人物角色在大厅的位置存储
TeamUP_Role_Position = {
	--uid:""
	--pos:0
};

TeamUP_Shield_Lock_Solo = false; --限时是否锁定单人模式
TeamUP_Shield_Lock_Double = false;--限时是否锁定双人模式
TeamUP_Shield_Lock_Quad = false;--限时是否锁定四人模式

Teamup_Show_NewteachingGuide = false;--根据等级判定是否显示新手训练弱引导

BP_Teamup_MinUDPPingIntervalTime = 15;	--网络异常时ping服务器的频率
BP_Teamup_UDPPingIntervalTime = 15;		--网络正常时ping服务器的频率

--是否关闭相关UI,true表示关闭UI
local IsCheckClose = false;

function TeamUpUI.OnCameraSwitch()
	if (TeamUp_Click_Switch_Camera == false) then
		TeamUp_Click_Switch_Camera = true;
		LuaClassObj.HandleUIMessage(bp_teamup, "OnCameraSwitch");
	end
end



BP_STRUCT_TeamUpMenuInfo =
{
	player_id = "0",
	player_name = "",
	player_status = 0, --准备和取消准备
	player_online = true, --在线和离线
	player_isFriend = false,
	player_position = 1,
	player_openVoice = false,
	player_isSpeaking = false,
	player_segment = 101,
	player_upvote = 0,
	player_gameStart =  0, --已开局时间，0表示非游戏中
	player_carteamName = "", --战队名字
	player_nation = "",
	player_aliasid = 0;  -- 称号id
	player_aliastitle = ""; -- 称号名称
	player_aliasnation = ""; -- 称号国籍
	player_credit = 100, --信誉分
	player_corpsName = "", --军团名字
	player_corpsIconUrl = "", --军团iconUrl
	player_corps_alias_id = 0, --军团称号
	player_corps_position = 0, --军团职位
};

BP_ARRAY_TeamUpMenuInfoList = 
{
	BP_STRUCT_TeamUpMenuInfo = _G.BP_STRUCT_TeamUpMenuInfo,
};


--定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问
--组队中的好友信息列表
BP_ARRAY_TeamUpFriendList = 
{
	BP_STRUCT_TeamUpFriendInfo = _G.BP_STRUCT_TeamUpFriendInfo, --定义结构体数组，这种写法要作为规范规定下来
};

--版本不一致提示优化，marco
BP_ENUM_VerCompareResult_HIGH = 1;
BP_ENUM_VerCompareResult_LESS = 2;

--新增弹窗内容显示(模式或地图名 大厅延迟)
BP_Teamup_DesStrId = 0
BP_Teamup_NetworkDelay = 0

--注册Widget
function bp_teamup_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_teamup,
		{
			{Path="/Game/UMG/UI_Logic/Lobby/Lobby_TeamModeLogic_BP.Lobby_TeamModeLogic_BP_C", Container="Default", ZOrder=10},
			{Path="/Game/UMG/UI_Logic/Lobby/Lobby_InviteFriendsTipsLogic_BP.Lobby_InviteFriendsTipsLogic_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER + 1},
			--{Path="/Game/UMG/UI_Logic/Lobby/Item/Lobby_PlayerHeadNameItemLogic_BP.Lobby_PlayerHeadNameItemLogic_BP_C", Container="Default", ZOrder=10},
			{Path="/Game/UMG/UI_BP/Lobby/Item/LobbyZoneListItem_BP.LobbyZoneListItem_BP_C", Container="Default", ZOrder=60},
		},
		{"Lobby"},
		false,
		bp_teamup_OnModeSwitched ~= nil
	);

	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_TEAM, function()
		LuaClassObj.HandleUIMessage(bp_teamup, "ClickExpandButton")
	end);
end

--进入Lobby显示组队界面
function bp_teamup_OnModeSwitched(gamestatus)
	log("bp_teamup_OnModeSwitched gamestatus = " .. gamestatus);
	if _G._inCustomBattle and string.lower(gamestatus) == "lobby" then return end
	if string.lower(gamestatus) == "lobby" then
		--拉取之前清空下组队数据，用于游戏中返回大厅模型加载不出来的问题处理
		TeamUpUI.ClearData();
		--显示LobbyUI
		log("Enter TeamUp");
		TeamUpSystem.Enter();
		TeamUpUI.Init();
	elseif string.lower(gamestatus) == "fighting" then
		TeamUpSystem.HasEnterFighting = true;
	end
end



function TeamUpUI.ClearData()
	--清除数据，关闭面板
	if TeamUpSystem ~= nil then
		log("clear TeamUpSystemTeamInfo");
		TeamUpSystem.TeamInfo = {};
		--防止报错
		TeamUpSystem.TeamInfo.members={};
	end	
	IsCheckClose = false;
	--组队好友数据
	TeamUPFriendUI.OnLogOut();
end

local function OnLogOut(eventType, eventID, vars)
	TeamUpUI.ClearData();

	
end

--事件处理
local function TeamUpEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_TEAMUP then
		return;
	end
	
	log("TeamUpEventHandler eventType="..eventType..", eventID="..eventID);
	
	--队伍信息同步
	if eventID == EVENTID_TEAMUP_TEAMINFO_SYNC then
		--log("EVENTID_TEAMUP_TEAMINFO_SYNC");
		--处理和大厅交互，增加或者删除角色
		TeamUpUI.OnChangeMember();

		--人员变动需要处理人物光圈
		TeamUpUI.OnLightRingChange();
		
		TeamUpUI.UnifyData();
		
		-- 刷新当前模式
		TeamUpModelUI.SetCurSelectedModel(TeamUpSystem.TeamInfo.team_type);
		-- 刷新人员变动
		TeamUpModelUI.UpdateCurTeamPlayerNum(TeamUpSystem.TeamInfo.player_count);
		-- 刷新自动匹配状态
		TeamUpModelUI.UpdateAutoMatchStatus(TeamUpSystem.TeamInfo.fill);
		-- 刷新当前选中模式地图
		TeamUpModelUI.UpdateCurMapName();

		-- 刷新万圣节tip
		TeamUpModelUI.UpdateTip()

		-- 匹配信息选择
		TeamUpMatchInfoUI.UpdateCurTeamPlayerNum(TeamUpSystem.TeamInfo.player_count);
		
		LuaClassObj.HandleUIMessage(bp_teamup, "TeamInfoRefresh");
	end
	--队伍类型改变
	if eventID == EVENTID_TEAMUP_TYPE_CHAGNE then		
		log("EVENTID_TEAMUP_TYPE_CHAGNE");
		TeamUpUI.SetCurrentTeamType(tonumber(TeamUpSystem.TeamInfo.team_type));
		LuaClassObj.HandleUIMessage(bp_teamup, "TeamTypeChange");
		
		--模式切换也要处理人物光圈
		TeamUpUI.OnLightRingChange();
	end
	--收到其它队伍的组队邀请
	if eventID == EVENTID_TEAMUP_GET_INVITE then
		log("EVENTID_TEAMUP_GET_INVITE");
		TeamUp_Invite_Apply_Type = 0;
		--TeamUp_Inviter_Name = TeamUpSystem.GetMemberName(TeamUpSystem.Inviter);
		TeamUp_Auto_Refuse = false;
		if BP_Teamup_DesStrId ~= 0 then
			LuaClassObj.HandleUIMessage(bp_teamup, "ShowTopTipWithMapName");
		else
			LuaClassObj.HandleUIMessage(bp_teamup, "ShowTopTip");
		end
	end
	
	--收到其他人加入本队的请求
	if eventID == EVNETID_TEAMUP_APPLY_JOIN then
		log("EVNETID_TEAMUP_APPLY_JOIN");
		TeamUp_Invite_Apply_Type = 1;
		TeamUp_Auto_Refuse = false;
		LuaClassObj.HandleUIMessage(bp_teamup, "ShowTopTip");
	end
	
	if eventID == EVENTID_TEAMUP_STATUS_UI_FRIEND then
		log("EVENTID_TEAMUP_STATUS_UI_FRIEND");
		HidePanel();
	end
	
	if eventID == EVENTID_TEAMUP_CHANGE_WEAR then
		--组队换装
		log("EVENTID_TEAMUP_CHANGE_WEAR");
		 TeamUpUI.OnWearChange();		
	elseif eventID == EVENTID_TEAMUP_CHANGE_AVATAR then
		--组队换脸性别
		log("EVENTID_TEAMUP_CHANGE_AVATAR");
		TeamUpUI.OnAvatarChange();
	end

	if eventID == EVENTID_INTL_ZONELIST_RSP then
			--选服-服务器列表
			log("EVENTID_INTL_ZONELIST_RSP");
			BP_ARRAY_ChooseZoneList = TeamUpSystem.ChooseZoneList;
			BP_ARRAY_MatchInfo_ChooseZoneList = TeamUpSystem.ChooseZoneList;
			LuaClassObj.HandleUIMessage(bp_teamup, "RefreshServerList");
	end

	if eventID == EVENTID_INTL_SELECT_ZONE_RSP then
			--选服-服务器返回
			BP_SvrBackChoosedZoneId = tostring(TeamUpSystem.ChooseZoneId);
			TeamUpMatchInfoUI.UpdateSelectedZoneId();
			TeamUpModelUI.UpdateSelectedZoneId();
			BP_SvrBackChooseZoneResult = vars;

			BP_SelectRegionVoiceUrl = tostring(TeamUpSystem.SelectRegionVoiceUrl);
			log ("BP_SelectRegionVoiceUrl " .. BP_SelectRegionVoiceUrl)
			log("EVENTID_INTL_SELECT_ZONE_RSP, BP_SvrBackChooseZoneResult = "..BP_SvrBackChooseZoneResult.."TeamUpSystem.ChooseZoneId = "..BP_SvrBackChoosedZoneId);
			LuaClassObj.HandleUIMessage(bp_teamup, "OnServerChooseZoneItem");
	end
	if eventID == EVENTID_INTL_MATCH_ZONE_NOTIFY then
			--选服-服务器广播
			BP_SvrBackChooseZoneResult = "ok";
			BP_SvrBackChoosedZoneId = tostring(TeamUpSystem.ChooseZoneId);
			TeamUpMatchInfoUI.UpdateSelectedZoneId();
			TeamUpModelUI.UpdateSelectedZoneId();
			BP_SelectRegionVoiceUrl = tostring(TeamUpSystem.SelectRegionVoiceUrl);
			log ("BP_SelectRegionVoiceUrl " .. BP_SelectRegionVoiceUrl)
			log("EVENTID_INTL_MATCH_ZONE_NOTIFY TeamUpSystem.ChooseZoneId = "..BP_SvrBackChoosedZoneId);
			LuaClassObj.HandleUIMessage(bp_teamup, "OnServerChooseZoneItem");
	end

	if eventID == EVENTID_TEAMUP_TEAMCODE_SYNC then
		TeamUpUI.RefreshTeamCode()
		LuaClassObj.HandleUIMessage(bp_teamup, "RefreshShowTeamCode");
	end

	if eventID == EVENTID_TEAMUP_CHANGE_HEADSHOW then
		log("EVENTID_TEAMUP_CHANGE_HEADSHOW");
		TeamUpUI.OnHeadShowChange();
	end

	if eventID == EVENTID_TEAMUP_CHANGE_WEAR_PAIR then
		log("EVENTID_TEAMUP_CHANGE_WEAR_PAIR");
		TeamUpUI.ChangeWearPair();
	end
end
-- UI
function EventGetCurChoosedZoneId()
	log("EventGetCurChoosedZoneId");
	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_MATCH_ZONE_NOTIFY);    
end

function TeamUpUI.CheckSwitch()
	if IsCheckClose == true then
		IsCheckClose = false;
		LuaClassObj.HandleUIMessage(bp_teamup, "UIShow");		
		LuaClassObj.HandleUIMessage(bp_teamup, "TeamTypeChange");
		--TeamUpUI.SetCurrentTeamType(TeamUp_Team_Type);
	end
end

function TeamUpUI.Init()
	log("TeamUpUI Init");
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TYPE_CHAGNE, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_GET_INVITE, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVNETID_TEAMUP_APPLY_JOIN, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_STATUS_UI_FRIEND, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_AVATAR, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_HEADSHOW, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR_PAIR, TeamUpEventHandler);
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, TeamUpUI.WardRobeAvatarResetOpen);
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, TeamUpUI.WardRobeAvatarResetClose);

		EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_ZONELIST_RSP, TeamUpEventHandler);
		EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, TeamUpEventHandler);
		EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_MATCH_ZONE_NOTIFY, TeamUpEventHandler);
		EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC, TeamUpEventHandler);
	
	--切号或被顶号 各个系统要自己清理，界面要关闭
	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, OnLogOut);

	--房间邀请提示
	EventSystem:registEvent(EVENTTYPE_ROOM, EVENTID_ROOM_GET_INVITE, TeamUpInviteUI.SetRoomInviteTipsInfo);

	
	TEAMUP_INVITE_TIP = DataMgr.GetMsgByID(110005);		--邀请您组队
	TEAMUP_APPLY_TIP = DataMgr.GetMsgByID(110010);		--申请加入组队
	TEAMUP_INVITE_TIMEOUT_TIP = DataMgr.GetMsgByID(110006);	--5分钟内忽略该玩家邀请
	TEAMUP_APPLY_TIMEOUT_TIP = DataMgr.GetMsgByID(110015);	--5分钟内忽略该玩家邀请
	TEAMUP_CHS_NAME_SOLO = DataMgr.GetMsgByID(110049);
	TEAMUP_CHS_NAME_DOUBLE = DataMgr.GetMsgByID(110050);
	TEAMUP_CHS_NAME_QUAD = DataMgr.GetMsgByID(110051);
	TEAMUP_CHS_NAME_NONE = DataMgr.GetMsgByID(110066); -- "模式全关闭";

	Teamup_Show_NewteachingGuide = DataMgr.roleData.level <= 3 and not DataMgr.team_up_has_guide_newteaching;
	
		--屏蔽2017年12月10版本
	if IsCheckClose == false then
		LuaClassObj.HandleUIMessage(bp_teamup, "UIShow");
		TeamUpUI.ProcessDestinyLock();
	end
end

function TeamUpUI.Release()
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TYPE_CHAGNE, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_GET_INVITE, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVNETID_TEAMUP_APPLY_JOIN, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_STATUS_UI_FRIEND, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_AVATAR, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_HEADSHOW, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR_PAIR, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, TeamUpUI.WardRobeAvatarResetOpen);
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, TeamUpUI.WardRobeAvatarResetClose);

	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_ZONELIST_RSP, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_MATCH_ZONE_NOTIFY, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC, TeamUpEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROOM, EVENTID_ROOM_GET_INVITE, TeamUpInviteUI.SetRoomInviteTipsInfo);
end

function TeamUpUI:WardRobeAvatarResetOpen()
	--log("TeamUpUI.WardRobeAvatarResetOpen")
	LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "UIHide");
end

function TeamUpUI:WardRobeAvatarResetClose()
	log("TeamUpUI.WardRobeAvatarResetClose")
	--当打开商城的时候 不显示
	if StoreMainUI.bShow == false then
		 TeamUpUI.ShowPanel();
	end
end

TeamUpTeamTypeNameKeyId = 0;
function EventGetTeamUpTeamTypeNameKeyId()
	if (TeamUp_Team_Type == TEAMUP_TEAM_TYPE_SOLO) then
		TeamUpTeamTypeNameKeyId = 1217;
	elseif (TeamUp_Team_Type == TEAMUP_TEAM_TYPE_DOUBLE) then
		TeamUpTeamTypeNameKeyId = 1218;
	elseif (TeamUp_Team_Type == TEAMUP_TEAM_TYPE_QUAD) then
		TeamUpTeamTypeNameKeyId = 1219; 
	else
		TeamUpTeamTypeNameKeyId = 1217;
	end
end

---当前队伍类型更新
function TeamUpUI.SetCurrentTeamType(newTeamType)

	TeamUp_Team_Type = newTeamType;

	--看到有为nil的报错，在这加一个默认处理
	if nil == TeamUp_Team_Type then
		TeamUp_Team_Type = TEAMUP_TEAM_TYPE_SOLO
	end
	
	if (TeamUp_Team_Type == TEAMUP_TEAM_TYPE_SOLO) then
		TeamUp_Team_Type_Name = TEAMUP_CHS_NAME_SOLO;
		TeamUp_IS_LOCK_SOLO = TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_SOLO;
		TeamUp_IS_LOCK_DOUBLE = false;
		TeamUp_IS_LOCK_QUAD = false;
	elseif (TeamUp_Team_Type == TEAMUP_TEAM_TYPE_DOUBLE) then
		TeamUp_Team_Type_Name = TEAMUP_CHS_NAME_DOUBLE;
		TeamUp_IS_LOCK_SOLO = TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_SOLO;
		TeamUp_IS_LOCK_DOUBLE = TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_DOUBLE;
		TeamUp_IS_LOCK_QUAD = false;
	elseif (TeamUp_Team_Type == TEAMUP_TEAM_TYPE_QUAD) then
		TeamUp_Team_Type_Name = TEAMUP_CHS_NAME_QUAD;
		TeamUp_IS_LOCK_SOLO = TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_SOLO;
		TeamUp_IS_LOCK_DOUBLE = TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_DOUBLE;
		TeamUp_IS_LOCK_QUAD = TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_QUAD;
	else 
		TeamUp_Team_Type_Name = TEAMUP_CHS_NAME_NONE;
	end
	
	
	LobbySystem.SetRoomMode(newTeamType);
	LobbyChatSystem.ChangeTeamType(newTeamType);
end

--是否显示锁和未开放提示，登录时候需要同步下，每次拉取限时开放数据更新
function TeamUpUI.SetShieldLock()	
	TeamUP_Shield_Lock_Solo = false;
	TeamUP_Shield_Lock_Double = false;
	TeamUP_Shield_Lock_Quad = false;

	local soloLock = TeamUpSystem.GetShieldByType(TEAMUP_TEAM_TYPE_SOLO);
	if soloLock ~= nil then
		if soloLock.is_shield == true then
			TeamUP_Shield_Lock_Solo = true;
		end  		
	end

	local doubleLock =  TeamUpSystem.GetShieldByType(TEAMUP_TEAM_TYPE_DOUBLE);
	if doubleLock ~= nil then
		if doubleLock.is_shield == true then
			TeamUP_Shield_Lock_Double = true;
		end  	
	end

	local quadLock = TeamUpSystem.GetShieldByType(TEAMUP_TEAM_TYPE_QUAD);
	if quadLock ~= nil then
		if quadLock.is_shield == true then
			TeamUP_Shield_Lock_Quad = true;
		end  		
	end

	--ToDo 更新蓝图菜单显示（如果显示）,蓝图调用前先fetchInfo
	LuaClassObj.HandleUIMessage(bp_teamup, "UpdateShieldMenu");
end


--[[
		├─ members
		│  └─ 382236358
		│     ├─ name: "吃鹅ebrcx"
		│     └─ svr: 17039369		
		│  └─ 38223623123
		│     ├─ name: "吃鹅2ebrcx"
		│     └─ svr: 17039369
		├─ team_type: 4
		├─ id: 6488841903671345157
		├─ create_time: 1510841388
		├─ player_count: 0
		└─ leader: 382236358
]]

--TODO jack
function TeamUpUI.TestAddOnPlayer(teaminfo, index)
	
	local myinfo = teaminfo.members[TeamUpSystem.MyUserID];
	
	teaminfo.player_count = teaminfo.player_count + 1;
	
	local newMember = {};
	newMember.name = "测试玩家" .. index;
	newMember.svr = myinfo.svr;
	newMember.avatar = DeepCopy(myinfo.avatar);
	newMember.wear_ext = DeepCopy(myinfo.wear_ext);
	
	--teaminfo.leader = 123456; --TODO
	
	teaminfo.members[TeamUpSystem.MyUserID + index] = newMember;
end

--是否在说话
function TeamUpUI.SetVoiceSpeaking(uid, isPeaking)
	local tUid = tostring(uid);
	for k,v in pairs(BP_ARRAY_TeamUpMenuInfoList) do
		if tUid == v.player_id then			
			BP_ARRAY_TeamUpMenuInfoList[k].player_isSpeaking = isPeaking;
		end
	end

	LuaClassObj.HandleUIMessage(bp_teamup, "VoiceRefresh");
end

--设置军团名字和徽章
function TeamUpUI.SetCorpsNameIcon(uid, corpsName, corpsIcon, corpsAliasId, corpsPosition)	
	local url = TeamUpUI.GetCorpsIconByID(corpsIcon);
	if corpsName == nil and corpsIcon == nil then
		--表示没有军团
		corpsName = "";
		url = "";
	end

	local tUid = tostring(uid);
	--log_tree("BP_ARRAY_TeamUpMenuInfoList",BP_ARRAY_TeamUpMenuInfoList)
	for k,v in pairs(BP_ARRAY_TeamUpMenuInfoList) do
		if tUid == v.player_id then			
			BP_ARRAY_TeamUpMenuInfoList[k].player_corpsName = tostring(corpsName);
			BP_ARRAY_TeamUpMenuInfoList[k].player_corpsIconUrl = url;
			BP_ARRAY_TeamUpMenuInfoList[k].player_corps_alias_id = corpsAliasId;
			BP_ARRAY_TeamUpMenuInfoList[k].player_corps_position = corpsPosition;

		end
	end
	--log_tree("BP_ARRAY_TeamUpMenuInfoList2",BP_ARRAY_TeamUpMenuInfoList)

	LuaClassObj.HandleUIMessage(bp_teamup, "CorpsNameIconRefresh");	
end


--徽章取路径
function TeamUpUI.GetCorpsIconByID(bageID)
	local url = "";
	local config = Client.GetTableData("CorpsBadge", tonumber(bageID));
	if config ~= nil then
		url = config.IconPath;
	end
	return url;
end


--设置信誉值
function TeamUpUI.SetCredit(uid, credit)
	local num = 100;
	if uid == nil then
		return;
	end
	if credit ~= nil then
		num = credit;
	end
	--log_tree("BP_ARRAY_TeamUpMenuInfoList",BP_ARRAY_TeamUpMenuInfoList);

	local tUid = tonumber(uid);
	for k,v in pairs(BP_ARRAY_TeamUpMenuInfoList) do
		if tUid == tonumber(v.player_id) then	
			--log("ddddddddddd:"..num);
			BP_ARRAY_TeamUpMenuInfoList[k].player_credit = tonumber(num);
		end
	end
	--log_tree("BP_ARRAY_TeamUpMenuInfoList2",BP_ARRAY_TeamUpMenuInfoList);
	LuaClassObj.HandleUIMessage(bp_teamup, "CreditRefresh");	
end

--组队队员概要信息强制更新
function TeamUpUI.GetProfileRsp(list)
	-- body
	LuaClassObj.HandleUIMessage(bp_teamup, "TeamInfoRefresh");
end

function TeamUpUI.RefreshTeamCode()
	TeamUp_Team_Code = TeamUpSystem.GetTeamCode()
end

function TeamUpUI.GetOldTeamType(newTeamType)
	if (newTeamType > 200) then
		return newTeamType - 100;
	else
		return newTeamType;
	end
end
function TeamUpUI.GetOldGameType(newTeamType)
	if (newTeamType > 200) then
		return 2;
	else
		return 1;
	end
end

function TeamUpUI.GetNewTeamType(gameType, oldTeamType)
	if (gameType == 1) then
		return oldTeamType;
	else
		return oldTeamType + 100;
	end
end

function TeamUpUI.SetCurrentGameType(teaminfo)
	--log("SetCurrentGameType before team_type = " .. teaminfo.team_type);
	--local gameType = TeamUpUI.GetOldGameType(teaminfo.team_type);
	--local teamType = TeamUpUI.GetOldTeamType(teaminfo.team_type);

	--teaminfo.game_type = gameType;
	--TeamUp_GameType = gameType;
	--teaminfo.team_type = teamType;
	--log("SetCurrentGameType after team_type = " .. teaminfo.team_type);
	--log("SetCurrentGameType after gameType = " .. gameType);
end

function TeamUpUI.GetMaxSegment(segment_info)
	local segment_info_solo = 0;
	local segment_info_duo = 0;
	local segment_info_squad = 0;
	segment_info_solo, segment_info_duo, segment_info_squad = FuncUtil.GetMaxSegement(segment_info);
	return math.max(segment_info_solo, segment_info_duo, segment_info_squad);
end

--组织数据
function TeamUpUI.UnifyData()
	log("TeamUpUI_UnifyData");
	
	local teaminfo = TeamUpSystem.TeamInfo;

	if (teaminfo.game_type == nil) then
		log("TeamUpUI.UnifyData teaminfo.game_type == nil")
		teaminfo.game_type = 1;
		if (teaminfo.team_type == nil) then
			return;
		end
	end

	teaminfo.team_type = TeamUpUI.GetNewTeamType(teaminfo.game_type, teaminfo.team_type);

	TeamUp_My_User_ID = tostring(TeamUpSystem.MyUserID);
	TeamUp_CrtTeam_ID = tostring(teaminfo.id);
	TeamUp_CrtTeam_Count = teaminfo.player_count or 0;
	TeamUp_Host_ID = tostring(teaminfo.leader);
	TeamUp_IsSelfHost = TeamUpSystem.IsTeamLeader();-- (TeamUpSystem.MyUserID == teaminfo.leader );
	TeamUpUI.RefreshTeamCode()
	TeamUp_Fill = teaminfo.fill;
	LobbySystem.SetFillValue(teaminfo.fill);
	--log("TeamUpSystem.MyUserID == teaminfo.leader"..tostring(TeamUp_IsSelfHost));
	--log("TeamUpSystem.MyUserID == teaminfo.leader"..TeamUpSystem.MyUserID.." "..teaminfo.leader);
	LobbySystem.SetRoomMode(teaminfo.team_type);
	TeamUpUI.SetCurrentGameType(teaminfo);
	TeamUpUI.SetCurrentTeamType(teaminfo.team_type);
	
	--队伍人员变动需要更新组队好友状态更新
	
	TeamUPFriendUI.ChangePlayerCount();
	--log("TeamUPFriendUI.ChangePlayerCount");
	
	--[[
	BP_ARRAY_TeamUpFriendList = {};
	if(teaminfo.members ~= null) then
		for k,v in pairs(teaminfo.members) do
			local friendinfo = 
			{
				friend_id = k,
				friend_name = v.name
			};
			table.insert(BP_ARRAY_TeamUpFriendList, friendinfo);
		end
	end
	--]]
	
	BP_ARRAY_TeamUpMenuInfoList = {};
	
	local memberInfo = teaminfo.members[TeamUpSystem.MyUserID];
	local menuInfo = {};
	--local positionInfo = {};
	--组队强拉一次队伍的概要信息
	local newGetProfileList = {};
	if (memberInfo ~= nil) then
		--log_tree("memberInfomemberInfo", memberInfo);
		menuInfo.player_id = tostring(TeamUpSystem.MyUserID);
		menuInfo.player_name = memberInfo.name;
		menuInfo.player_status = memberInfo.status;
		menuInfo.player_online = memberInfo.svr ~= nil;
		menuInfo.player_isFriend = true;
		menuInfo.player_position = 1;
		menuInfo.player_openVoice = false;--自己永远关闭，声音那边取不到TeamUpSystem.IsOpenVoice(menuInfo.player_id);
		menuInfo.player_segment = TeamUpUI.GetMaxSegment(memberInfo.segment_info);
		menuInfo.player_upvote = memberInfo.upvote or 0;
		menuInfo.player_isSpeaking = false;
		menuInfo.player_gameStart = 0; --自己永远看不到在游戏中的状态
		menuInfo.player_carteamName = TeamUpSystem.GetMemberCarteamName(TeamUpSystem.MyUserID);

		if ProfileMgr ~= nil then 
			menuInfo.player_nation = ProfileMgr.GetRoleNationByUid(TeamUpSystem.MyUserID);
		end
		if not menuInfo.player_nation or menuInfo.player_nation == "" then
			menuInfo.player_nation = "US"
		end
		
		local aliasInfo = DataMgr.roleData.alias;
		menuInfo.player_aliasid = memberInfo.aliasid or aliasInfo.id;
		menuInfo.player_aliastitle = memberInfo.aliastitle or aliasInfo.title;
		menuInfo.player_aliasnation = memberInfo.aliasnation or aliasInfo.nation;

		menuInfo.player_corpsName = "";
		menuInfo.player_corpsIconUrl = "";
		menuInfo.player_corps_alias_id = 0;
		menuInfo.player_corps_position = 0;
		menuInfo.player_credit = 100;
		if memberInfo.credit ~= nil then
			menuInfo.player_credit = memberInfo.credit;
		end
		
		if memberInfo.corps_name ~= nil then
			menuInfo.player_corpsName = memberInfo.corps_name;
			menuInfo.player_corpsIconUrl = TeamUpUI.GetCorpsIconByID(memberInfo.corps_icon);
			menuInfo.player_corps_alias_id = memberInfo.cur_corps_alias_id;
			menuInfo.player_corps_position = memberInfo.corps_position;
		end

		--positionInfo[1] = TeamUpSystem.MyUserID;

		table.insert(BP_ARRAY_TeamUpMenuInfoList, menuInfo);
		
		log("menuInfo.player_id = " .. menuInfo.player_id);
		
		for key, value in pairs(teaminfo.members) do  
			if (key ~= TeamUpSystem.MyUserID) then
				--log_tree("MyUserIDMyUserIDMyUserIDMyUserIDMyUserID", memberInfo);
				menuInfo = {};
				menuInfo.player_id = tostring(key);
				menuInfo.player_name = value.name;
				menuInfo.player_status = 1;
				menuInfo.player_online = value.svr ~= nil;
				menuInfo.player_isFriend = FriendSystem.IsMyFriend(key);
				menuInfo.player_openVoice = TeamUpSystem.IsOpenVoice(menuInfo.player_id);
				menuInfo.player_isSpeaking = false;
				menuInfo.player_gameStart = 0; -- 不为0表示已开局xx时间
				menuInfo.player_segment = TeamUpUI.GetMaxSegment(value.segment_info);
				menuInfo.player_upvote = value.upvote or 9999999;
				menuInfo.player_carteamName = TeamUpSystem.GetMemberCarteamName(key);

				if ProfileMgr ~= nil then 
					menuInfo.player_nation = ProfileMgr.GetRoleNationByUid(menuInfo.player_id);

					local aliasInfo = ProfileMgr.GetRoleAliasByUid(menuInfo.player_id);
					menuInfo.player_aliasid = value.aliasid or aliasInfo.id;
					menuInfo.player_aliastitle = value.aliastitle or aliasInfo.title;
					menuInfo.player_aliasnation = value.aliasnation or aliasInfo.nation;
				end
				if not menuInfo.player_nation or menuInfo.player_nation == "" then
					menuInfo.player_nation = value.nation or "US"
				end
				if not menuInfo.player_aliastitle or menuInfo.player_aliastitle == "" then
					menuInfo.player_aliastitle = value.aliastitle or "PUBG Partner"
				end
				

				if value.game_start ~= nil then
					menuInfo.player_gameStart = value.game_start;
				end

				menuInfo.player_corpsName = "";
				menuInfo.player_corpsIconUrl = "";
				menuInfo.player_corps_alias_id = 0;
				menuInfo.player_corps_position = 0;
				menuInfo.player_credit = 100;
				if value.credit ~= nil then
					menuInfo.player_credit = value.credit;
				end	

				if value.corps_name ~= nil and value.corps_name ~= "" then
					menuInfo.player_corpsName = value.corps_name;
					menuInfo.player_corpsIconUrl = TeamUpUI.GetCorpsIconByID(value.corps_icon);
					menuInfo.player_corps_alias_id = value.cur_corps_alias_id;
					menuInfo.player_corps_position = value.corps_position;
				end
				
				local spawnPos = LobbyUI:GetSpawnPlayerPos(key);
				
				menuInfo.player_position = spawnPos == nil and 4 or spawnPos;

				if (spawnPos ~= nil) then
					log("menuInfo.player_id = " .. menuInfo.player_id  .. ", spawnPos == " .. tostring(spawnPos));
					table.insert(BP_ARRAY_TeamUpMenuInfoList, menuInfo);	
				else
					log("menuInfo.player_id = " .. menuInfo.player_id  .. ", spawnPos == nil");
				end
				
								
				
				--positionInfo[menuInfo.player_position] = key;				
				
				--log("menuInfo.player_id = " .. menuInfo.player_id);	
				
			end
			table.insert(newGetProfileList, tonumber(key));
		end
		--组队强拉一次队伍的概要信息		
		if ProfileMgr ~= nil then --灰度更新有可能吧lua释放，导致报错
			ProfileMgr.GetProfileList(newGetProfileList,TeamUpUI.GetProfileRsp);
		end

		
		--[[
		local listCount = #BP_ARRAY_TeamUpMenuInfoList;
		
		if listCount < 4 then
			for i = listCount + 1, 4, 1 do
				menuInfo = {};
				menuInfo.player_id = "0";
				menuInfo.player_name = "";
				menuInfo.player_status = 0;
				menuInfo.player_online = false;
				menuInfo.player_isFriend = false;
				menuInfo.player_position = 4;
				for j = 1, 4 do
					if (positionInfo[j] == nil) then
						menuInfo.player_position = j;
						positionInfo[j] = i;
						break;
					end
				end
				table.insert(BP_ARRAY_TeamUpMenuInfoList, menuInfo);
			end

		end
		]]
	end
	
	--log_tree("BP_ARRAY_TeamUpMenuInfoList", BP_ARRAY_TeamUpMenuInfoList);
end

local function FindPos(pos)
	local isFind = false;
	for k,v in pairs(TeamUP_Role_Position) do
		local curPos = v.pos;
		if pos == curPos then			
			isFind = true;
			break;			
		end	
	end
	return isFind;
end

local function GetEmptyPos()
	local posIndex = 0;
	
	for i = 2, 4, 1 do
		local isFind = false;
		posIndex = i;
		for k,v in pairs(TeamUP_Role_Position) do
			local pos = v.pos;
			if posIndex == pos then
				isFind = true;
				break;
			end 
		end
		
		if not isFind then
			return posIndex;
		end
	end
	
	return posIndex;
end

--位置排序为2134
function TeamUpUI.GetRolePos(uid)
	
	if (TeamUpSystem.MyUserID == uid) then
		return 1;
	end
	
	--log_tree("TeamUpUI.GetRolePos", TeamUP_Role_Position);
	
	for k,v in pairs(TeamUP_Role_Position) do
		local _gid = v.uid;
		if uid == _gid then
			log("TeamUpUI.GetRolePos return pos:"..v.pos);
			return tonumber(v.pos);
		end
	end
	--异常为0
	return 0;
end


--组队人变更和大厅交互
function TeamUpUI.OnChangeMember()
	local memberInfo = TeamUpSystem.ChangeMemberInfo;
	--log_tree(" TeamUpUI.OnChangeMember memberInfo", memberInfo);	
	local _lenth = #TeamUpSystem.ChangeMemberInfo; 
	--log(" TeamUpUI.OnChangeMember length".._lenth);
	if _lenth == 0 then
		return;
	end
	--[[
				├─ members
			│   └─ 382236358
			│     ├─ name: "吃鹅ebrcx"
			│     └─ svr: 17039369		

	--]]
	for k,v in pairs(memberInfo) do
		
		local _sex = 1;
		if v.gender  ~= nil then
			_sex = v.gender;
		end		
		log_tree(" TeamUpUI.memberInfo", v);	
		
		local wearArray = {};
		if v.wear ~= nil then
			for k,v in pairs(v.wear) do
				table.insert(wearArray, LobbyUI.MakeClientAvatarWearInfo(v));
			end
		end
		--log_tree(" TeamUpUI.wearArray", wearArray);
		local head_show = 0;
		if v.skin_info ~= nil then
			if(v.skin_info.head_show == 0 or v.skin_info.head_show == v.skin_info.helmet_skin) then
				local head = v.wear[1];
				if(head ~= nil) then
					log_tree("head", head);
					for i, v in pairs(wearArray) do
						if(v.resID == head[1]) then
							v.resID = 0;
						end
					end
				end
				head_show = DataMgr.GetEquipmentItemIDByResID(v.skin_info.helmet_level, v.skin_info.head_show);
			end
		end
		
		local playerData = {
			gid = v.gid,
			sex = _sex,
			BP_ARRAY_AvatarList = wearArray,
			avatar = v.avatar,
			bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(v.skin_info.bag_level, v.skin_info.bag_skin),
			headShow = head_show,
		};
		log_tree(" TeamUpUI.OnChangeMember", playerData);
		--log("playerData.gid:"..tostring(playerData.gid).."---TeamUpSystem.IsAddMember"..tostring(TeamUpSystem.IsAddMember));
		LobbyUI:SpawnPlayer(playerData, TeamUpSystem.IsAddMember);
	end
	
	--[[
		gid = _newGid,
		name = v.name,
		status = v.status,
		svr = v.svr,
	--]]
	
	--位置存储逻辑处理
	if TeamUpSystem.IsAddMember then
		
		for k,v in pairs(memberInfo) do	
			--找出空位，默认从2位置开始找
			local posIndex = GetEmptyPos();
			--log("posIndex"..posIndex);
			if TeamUp_My_User_ID ~= v.gid then
				--uid:""
				--pos:0
				local posData =
				{
					uid = v.gid,
					pos = posIndex,
				}
				table.insert(TeamUP_Role_Position, posData);
			end
		end	
		--log_tree("TeamUP_Role_Position add",TeamUP_Role_Position);		
		
	else 
		if TeamUP_Role_Position ~= nil then
			--log_tree("TeamUP_Role_Position del",TeamUP_Role_Position);		
			for k,v in pairs(memberInfo) do
				local _gid = v.gid;
				if #TeamUP_Role_Position < 1 then
					break;
				end
				for i= #TeamUP_Role_Position, 1, -1 do
					if _gid == TeamUP_Role_Position[i].uid then
						table.remove(TeamUP_Role_Position, i);
					end
			
				end
			end	
		end	
		
	end	
	--log_tree("TeamUP_Role_Position",TeamUP_Role_Position);
	---增加后置空 ---by eddy
	TeamUpSystem.ChangeMemberInfo = {};
end


--隐藏面板
function TeamUpUI.HidePanel()
	LuaClassObj.HandleUIMessage(bp_teamup, "HideAll");
end

function TeamUpUI.ShowPanel()
	LuaClassObj.HandleUIMessage(bp_teamup, "ShowAll");
end


function TeamUpUI.CanShowChatEntrance()
	local exceptUI = {
		eUIType.eUnknowPassUI,
		eUIType.eRoleInfoUI,
		eUIType.eStoreMainUI,
		eUIType.eSupplyMainUI,
		eUIType.eRankUI,
		eUIType.eWarZoneRankUI,
	}
	for k,v in pairs(exceptUI) do
		if UIManager.GetUI(v) then
			return false
		end
	end
	local ui_manager = require("ui.manager");
	if ui_manager.GetUI(ui_manager.UI_Config.pet_main) ~= nil then
		return false
	end
	return true
end

function TeamUpUI.StartMatch()
	TeamUp_Is_Matching = true;
	TeamUPFriendUI.HidePanel();
	TeamUpUI.HidePanel();

	if TeamUpUI.CanShowChatEntrance() then
		LobbyChatEntranceUI.ForceSetVisibility(true);
	end
	TeamUPFriendUI.ShowBtnPanel();
	log("TeamUp_Is_Matching = true");
end

function TeamUpUI.StopMatch()
	TeamUp_Is_Matching = false;
	log("TeamUp_Is_Matching = false");
end
--组队换装逻辑
function TeamUpUI.OnWearChange()
	--log_tree("TeamUpUI.OnWearChange", TeamUpSystem.ChangeWearInfo);
	local isPutOff = false;
	if TeamUpSystem.ChangeWearInfo.pos > 0 then
		isPutOff = true; 
	end
	--log("eamUpUI.OnWearChange isPutOff"..tostring(isPutOff));
	LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.ChangeWearInfo.uid, TeamUpSystem.ChangeWearInfo.resId, TeamUpSystem.ChangeWearInfo.wearInfo[2], TeamUpSystem.ChangeWearInfo.wearInfo[3]), isPutOff);	
	
end

--组队换脸性别
function TeamUpUI.OnAvatarChange()
	--[[
	TeamUpSystem.ChangeAvatarInfo = {
		reCreate = NeedReCreatPalyer(op_uid,newAvatar), --是否重新创建
		uid = op_uid,
		avatar = newAvatar,
	};
	--]]
	if TeamUpSystem.OnAvatarChange == nil then
		log("OnAvatarChange is none");
	end

	if TeamUpSystem.ChangeAvatarInfo.reCreate == false then --只是换头发
		log("OnAvatarChange hairid:"..TeamUpSystem.ChangeAvatarInfo.avatar.hairid);
		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.ChangeAvatarInfo.uid, TeamUpSystem.ChangeAvatarInfo.avatar.hairid), true);

	elseif TeamUpSystem.ChangeAvatarInfo.reCreate == true then --重新创建
		local memberInfo = TeamUpSystem.GetMemberInfo(TeamUpSystem.ChangeAvatarInfo.uid);

		local wearArray = {};
		if memberInfo.wear_ext ~= nil then
			for k,v in pairs(memberInfo.wear_ext) do
				table.insert(wearArray, LobbyUI.MakeClientAvatarWearInfo(v));
			end
		end
	
		local playerData ={
			gid = TeamUpSystem.ChangeAvatarInfo.uid,
			sex = TeamUpSystem.ChangeAvatarInfo.avatar.gamegender,	
			BP_ARRAY_AvatarList = wearArray,					
			avatar = TeamUpSystem.ChangeAvatarInfo.avatar,
		};

		--log_tree("OnAvatarChange", playerData);
		LobbyUI:LockSwitchLobbyCamera(true);
		LobbyUI:SpawnPlayer(playerData, false);
		LobbyUI:SpawnPlayer(playerData, true);
		LobbyUI:LockSwitchLobbyCamera(false);
		TeamUpSystem.OnMemberWeaponChange(TeamUpSystem.ChangeAvatarInfo.uid);
	end
	
end

-- 组队换头盔和背包
function TeamUpUI.OnHeadShowChange()
	local oldMemberInfo = TeamUpSystem.GetMemberInfo(TeamUpSystem.HeadShowChangeInfo.uid);
	if(oldMemberInfo == nil) then
		log("oldMemberInfo is nil");
	end
	log_tree("oldMemberInfo", oldMemberInfo);
	local oldHeadShow = oldMemberInfo.skin_info.head_show;
	local oldHelmet = oldMemberInfo.skin_info.helmet_skin;
	local oldBagSkin = oldMemberInfo.skin_info.bag_skin;
	local oldBagLevel = oldMemberInfo.skin_info.bag_level;
	local oldHelmetLevel = oldMemberInfo.skin_info.helmet_level;
	TeamUpSystem.UpdateMemberHeadShowInfo(TeamUpSystem.HeadShowChangeInfo);
	local newMemberInfo = TeamUpSystem.GetMemberInfo(TeamUpSystem.HeadShowChangeInfo.uid);
	log_tree("newMemberInfo", newMemberInfo);
	
	if(TeamUpSystem.HeadShowChangeInfo.param.head_show ~= nil) then -- 如果头部有变动
		if(oldHelmet == oldHeadShow) then --如果当前穿的是头盔
			local resID = DataMgr.GetEquipmentItemIDByResID(oldHelmetLevel, oldHeadShow);
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, resID, 0, 0), false);
		end
		
		if(TeamUpSystem.HeadShowChangeInfo.param.head_show == TeamUpSystem.HeadShowChangeInfo.param.helmet_skin) then
			local resID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.helmet_level, TeamUpSystem.HeadShowChangeInfo.param.head_show);
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, resID, 0, 0), true);
		end
		
		if(TeamUpSystem.HeadShowChangeInfo.param.head_show == 0) then
			log("enter TeamUpSystem.HeadShowChangeInfo.param.head_show")
			if(oldMemberInfo.wear_ext ~= nil and oldMemberInfo.wear_ext[1] ~= nil) then
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, oldMemberInfo.wear_ext[1], 0, 0), false);
			end
		end
	end

	if(TeamUpSystem.HeadShowChangeInfo.param.bag_skin ~= nil) then -- 背包变动
		if(TeamUpSystem.HeadShowChangeInfo.param.bag_skin ~= 0) then
			local bagResID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.bag_level, TeamUpSystem.HeadShowChangeInfo.param.bag_skin);
			if(bagResID ~= 0) then
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, bagResID, 0, 0), true);
			end
		else
			local bagResID = DataMgr.GetEquipmentItemIDByResID(oldBagLevel, oldBagSkin);
			if(bagResID ~= 0) then
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, bagResID, 0, 0), false);
			end
		end
	end

	if(TeamUpSystem.HeadShowChangeInfo.param.bag_level ~= nil) then -- 背包等级变动
		local bagResID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.bag_level, newMemberInfo.skin_info.bag_skin);
		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, bagResID, 0, 0), true);
	end

	if(TeamUpSystem.HeadShowChangeInfo.param.helmet_skin ~= nil) then -- 头盔变动
		if(TeamUpSystem.HeadShowChangeInfo.param.helmet_skin ~= 0) then
			local helmetResID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.helmet_level, TeamUpSystem.HeadShowChangeInfo.param.helmet_skin);
			if(helmetResID ~= 0) then
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, helmetResID, 0, 0), true);
			end
		else
			local helmetResID = DataMgr.GetEquipmentItemIDByResID(oldHelmetLevel, oldHelmet);
			if(helmetResID ~= 0) then
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, helmetResID, 0, 0), false);
			end
		end
	end
	
	if(TeamUpSystem.HeadShowChangeInfo.helmet_level ~= 0) then -- 头盔等级变动
		if(newMemberInfo.skin_info.helmet_skin == newMemberInfo.skin_info.head_show) then
			local resID = DataMgr.GetEquipmentItemIDByResID(newMemberInfo.skin_info.helmet_level, newMemberInfo.skin_info.helmet_skin);
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.HeadShowChangeInfo.uid, resID, 0, 0), true);
		end
	end
end

--sami 脱下背包道具
function TeamUpUI.PutOffBag(oldIndex)
	--卸下老头盔，背包
	local myUid = DataMgr.roleData.uid
	local oldBagInfo = HallThemeUtils.themeBagInfo[oldIndex]
	if oldBagInfo ~= nil then
		if oldBagInfo.head_show ~= 0 then
			if oldBagInfo.head_show == oldBagInfo.helmet_skin then
				local originalResId = WardrobeSystem.GetItemResId(oldBagInfo.helmet_skin)
				local resID = DataMgr.GetEquipmentItemIDByResID(oldBagInfo.helmet_level, originalResId)
				log("TeamUpUI.PutOffBag old helmet resID="..resID)
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(myUid, resID, 0, 0), false)

				local item = {
					use_flag = 0,
					isnew = 0,
					count = 1,
					instid = oldBagInfo.helmet_skin,
					res_id = originalResId
				}
				WardrobeUI:UpdatePutOnData(nil, item)
			end
		end
		if oldBagInfo.bag_skin ~= 0 then
			local originalResId = WardrobeSystem.GetItemResId(oldBagInfo.bag_skin)
			local resID = DataMgr.GetEquipmentItemIDByResID(oldBagInfo.bag_level, originalResId)
			log("TeamUpUI.PutOffBag old bag resID="..resID)
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(myUid, resID, 0, 0), false)

			local item = {
				use_flag = 0,
				isnew = 0,
				count = 1,
				instid = oldBagInfo.bag_skin,
				res_id = originalResId
			}
			WardrobeUI:UpdatePutOnData(nil, item)
		end
	end
end

--穿上背包道具
function TeamUpUI.PutOnBag(newIndex)
	--安装新头盔，背包
	local myUid = DataMgr.roleData.uid
	local newBagInfo = HallThemeUtils.themeBagInfo[newIndex]
	if newBagInfo ~= nil then
		if newBagInfo.head_show ~= 0 then
			if newBagInfo.head_show == newBagInfo.helmet_skin then
				local originalResId = WardrobeSystem.GetItemResId(newBagInfo.helmet_skin)
				local resID = DataMgr.GetEquipmentItemIDByResID(newBagInfo.helmet_level, originalResId)
				log("TeamUpUI.PutOnBag new helmet resID="..resID)
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(myUid, resID, 0, 0), true)

				local item = {
					use_flag = 1,
					isnew = 0,
					count = 1,
					instid = newBagInfo.helmet_skin,
					res_id = originalResId
				}
				WardrobeUI:UpdatePutOnData(item, nil)
			end
		end
		if newBagInfo.bag_skin ~= 0 then
			local originalResId = WardrobeSystem.GetItemResId(newBagInfo.bag_skin)
			local resID = DataMgr.GetEquipmentItemIDByResID(newBagInfo.bag_level, originalResId)
			log("TeamUpUI.PutOnBag new bag resID="..resID)
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(myUid, resID, 0, 0), true)

			local item = {
				use_flag = 1,
				isnew = 0,
				count = 1,
				instid = newBagInfo.bag_skin,
				res_id = originalResId
			}
			WardrobeUI:UpdatePutOnData(item, nil)
		end
	end
	WardrobeUI:ShowEquipmentLevelPanel()
end

function TeamUpUI.ChangeWearPair()
	local oldMemberInfo = TeamUpSystem.GetMemberInfo(TeamUpSystem.ChangeWearPair.uid);
	if oldMemberInfo == nil then
		return;
	end
	--先脱掉当前的
	log_tree("oldMemberInfo", oldMemberInfo)
	log_tree("oldMemberInfo.wear_ext", oldMemberInfo.wear_ext);
	if oldMemberInfo.wear_ext ~= nil then
		for k,v in pairs(oldMemberInfo.wear_ext) do
			if(v[1] ~= nil) then
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.ChangeWearPair.uid, v[1], 0, 0), false);
			end
		end
	end

	local newWearArray = {};
	if TeamUpSystem.ChangeWearPair.wear_ext ~= nil then
		for k,v in pairs(TeamUpSystem.ChangeWearPair.wear_ext) do
			table.insert(newWearArray, LobbyUI.MakeClientAvatarWearInfo(v));
		end
	end

	for i, v in pairs(newWearArray) do
		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(TeamUpSystem.ChangeWearPair.uid, v.resID, v.colorID, v.patternID), true);
	end

	TeamUpSystem.UpdateTeamMemberWear(TeamUpSystem.ChangeWearPair.uid, TeamUpSystem.ChangeWearPair.ware, TeamUpSystem.ChangeWearPair.wear_ext)
end

function TeamUpUI.IsMatching()
	return TeamUp_Is_Matching;
end

function TeamUpUI.OnQuickMsg(gid, msg)
	TeamUp_Quick_Msg_GID = gid;
	TeamUp_Quick_Msg_Content = msg;
	
	LuaClassObj.HandleUIMessage(bp_teamup, "UpdateQuickMsg");
end

--队伍光圈
function TeamUpUI.OnLightRingChange()
		--[[
	 TeamInfo
		├─ members
		│  └─ 382236358
		│     ├─ name: "吃鹅ebrcx"
		│     └─ svr: 17039369		
		│  └─ 38223623123
		│     ├─ name: "吃鹅2ebrcx"
		│     └─ svr: 17039369
		├─ team_type: 4
		├─ id: 6488841903671345157
		├─ create_time: 1510841388
		├─ player_count: 0
		└─ leader: 382236358
	]]--
	if TeamUpSystem.TeamInfo == nil then
		return;
	end
	--log_tree("TeamUpUI.OnLightRingChange", TeamUpSystem.TeamInfo);
	local teamType = TeamUpSystem.TeamInfo.team_type;
	
	local tableUID = {};
	for k,v in pairs(TeamUpSystem.TeamInfo.members) do
		local _uid = k;
		table.insert(tableUID, k);	
	end
	
	--转换type
	if (TeamUpSystem.TeamInfo.team_type == TEAMUP_TEAM_TYPE_SOLO) then
		teamType = 1;		
	elseif (TeamUpSystem.TeamInfo.team_type == TEAMUP_TEAM_TYPE_DOUBLE) then
		teamType = 2;
	elseif (TeamUpSystem.TeamInfo.team_type == TEAMUP_TEAM_TYPE_QUAD) then
		teamType = 4;
	else 
		teamType = 1;
	end
	
	--log("TeamUpUI.OnLightRingChange teamType"..teamType);
	--log_tree("TeamUpUI.OnLightRingChange tableUID", tableUID);
	--调用接口
	LobbyUI:CreateTeamUpRings(teamType, tableUID);
	
end

--弹出提示
function TeamUpUI.PopShieldTips(modelType)
	local shieldInfo = TeamUpSystem.GetShieldByType(modelType);
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

--跨版本组队相关提示
function TeamUpUI.NotSameVertionTips()
	--DataMgr.GetMsgByID(110115) 提示
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, DataMgr.GetMsgByID(110116));	
end

function TeamUpUI.HandelVertionCompareTips(verCompareResult)

	if verCompareResult == nil then
		log("TeamUpUI.HandelVertionCompareTips verCompareResult == nil");

		--兼容性，假设服务器没有更新
		TeamUpUI.NotSameVertionTips();
		return;
	end

	log("TeamUpUI.HandelVertionCompareTips verCompareResult:" ..verCompareResult);

	if verCompareResult == BP_ENUM_VerCompareResult_HIGH then
		CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, DataMgr.GetMsgByID(110150));
	else
		CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, DataMgr.GetMsgByID(110149));
	end
end

function TeamUpUI.ProtocolErrorCode(errorString)
	--[[
	1、邀请组队
	team_invite_respond("already_in_room", invitee)   ---您在房间中，不能组队。
	team_invite_respond("invitee_in_room", invitee)   ---对方房间中，不能组队。
	team_join_respond("inviter_in_room", nil, nil)    ---邀请者在房间中，不能组队。
	team_join_respond("already_in_room", nil, nil)    ---您在房间中，不能组队。
	2、申请入队
	team_apply_respond("already_in_room")             ---您在房间中，不能组队。
	team_apply_respond("applicant_in_room")           ---被申请者在房间中，不能组队。
	3、邀请消息
	team_recruit_for_plat_res("already_in_room")      ---您在房间中，不能邀请组队。
	]]
	if errorString == "already_in_room" then
		 ---您在房间中，不能组队。
		 --DataMgr.ShowNoticeByString("您在房间中，不能组队。");
		 DataMgr.ShowNoticeByID(110117);
	elseif errorString == "invitee_in_room" then
		---对方房间中，不能组队。
		--DataMgr.ShowNoticeByString("对方房间中，不能组队。");
		DataMgr.ShowNoticeByID(110118);
	elseif errorString == "inviter_in_room" then
		---邀请者在房间中，不能组队。
		--DataMgr.ShowNoticeByString("邀请者在房间中，不能组队。");
		DataMgr.ShowNoticeByID(110119);
	elseif errorString == "applicant_in_room" then
		---被申请者在房间中，不能组队。
		--DataMgr.ShowNoticeByString("被申请者在房间中，不能组队。");
		DataMgr.ShowNoticeByID(110120);
	elseif errorString == "kickOut" then
		--您已被请出队伍
		--DataMgr.ShowNoticeByString("您已被请出队伍");
		DataMgr.ShowNoticeByID(110121);
	end
end

--是否需要提示
function TeamUpUI.NeedShowDestinyLimit()
	return BP_DestinyIsLock;
end

--天命锁
function TeamUpUI.ProcessDestinyLock()
	local openLv = DataMgr.GetSystemConfig("DestinyModeOpenLevel");
	local curLv = DataMgr.roleData.level;
	--log("ddddddd:"..openLv.."aaaa:"..curLv);
	if openLv ~= nil and tonumber(curLv) < tonumber(openLv) then
		BP_DestinyIsLock = true;
	else
		BP_DestinyIsLock = false;
	end

	log("ProcessDestinyLock:"..tostring(BP_DestinyIsLock));
	--更新UI
	--LuaClassObj.HandleUIMessage(bp_teamup, "UpdateDestiny");
end

--显示天命开放提示
function TeamUpUI.ShowDestinyLimit(isrecruit)

	local openLv = DataMgr.GetDestinyModeOpenLevel();
	local str = DataMgr.GetMsgByID(110141);	
	if isrecruit ~= nil and isrecruit == true then	
		str = DataMgr.GetMsgByID(110142);	
	end	
	
	local showTip = string.format(str,tonumber(openLv));
	--log("dddddddddddd",showTip);
	--弹出提示，等级不够
	DataMgr.ShowNoticeByString(showTip);
end

--显示第一人称开放提示
function TeamUpUI.NeedShowFirstPersonLimit()
	local result = false;
	local openLv = DataMgr.GetFPPOpenLevel();
	local curLv = DataMgr.roleData.level;
	if openLv ~= nil and tonumber(curLv) < tonumber(openLv) then
		result = true;
	end
	return result;
end

function TeamUpUI.ShowUpvoteTips(uid, name)
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby))
    if curStatus == "lobby" then
        local str = DataMgr.GetMsgByID(4830);
		local showTip = string.format(str, name);
		-- <SettlementTips_Font1>%s </>点赞了你
		DataMgr.ShowNoticeByString(showTip);
    end
	
end


function TeamUpUI.ShowFirstPersonLimit()
	local str = DataMgr.GetMsgByID(110142);		
	local openLv = DataMgr.GetFPPOpenLevel();
	local showTip = string.format(str,tonumber(openLv));
	--弹出提示，等级不够
	DataMgr.ShowNoticeByString(showTip);
end
--(以Event开头的函数名就能暴露给蓝图调用)

function EventShowTopTip()
	log("EventShowTopTip");
	LuaClassObj.HandleUIMessage(bp_teamup, "ShowTopTip");
end


--改变组队类型
function EventTeamUpChangeTeamType()
	 ---每次点击都同步下限时开放数据
	TeamUpSystem.on_mode_shield_req();

	local shieldInfo = TeamUpSystem.GetShieldByType(TeamUp_Change_Team_Type);
	log("EventTeamUpChangeTeamType"..TeamUp_Change_Team_Type);
	if shieldInfo ~= nil then
		if shieldInfo.is_shield == true then
			--弹出提示
			TeamUpUI.PopShieldTips(TeamUp_Change_Team_Type);
			return;
		end
	end



	--log("EventTeamUpChangeTeamType "..TeamUp_Change_Team_Type);
	if (TeamUp_Change_Team_Type == TEAMUP_TEAM_TYPE_SOLO) then
		if (TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_SOLO) then
			DataMgr.ShowNoticeByID(110001);	--队伍人数过多
			return;
		end
	elseif (TeamUp_Change_Team_Type == TEAMUP_TEAM_TYPE_DOUBLE) then
		if (TeamUp_CrtTeam_Count > TEAMUP_MAX_MEMBER_DOUBLE) then
			DataMgr.ShowNoticeByID(110001);	--队伍人数过多
			return;
		end
	end

	local newTeamType = TeamUpUI.GetNewTeamType(nil, TeamUp_Change_Team_Type);
	TeamUpSystem.team_change_type_request(newTeamType);
end

--回复收到的组队邀请 --同意入队
function EventTeamUpInviteApplyPermit()

	log("EventTeamUpInviteApplyPermit");
	
	if (TeamUp_Invite_Apply_Type == 0) then
		TeamUpSystem.team_invite_reply("ok", TeamUpSystem.Inviter, TeamUpSystem.InviterTeamID);
		
	elseif (TeamUp_Invite_Apply_Type == 1) then
		TeamUpSystem.team_apply_reply("ok", TeamUpSystem.ApplyerID, TeamUpSystem.ApplyerTeamID);
	end
	
	TeamUpSystem.InviteApplyShowing = false;
	TeamUpSystem.CheckNextInviteApply()
	LevelUpSystem.ClosePveLevelupPanel()

	local pandoraSystem = require("client.pandora.pandora_system");
	pandoraSystem.HideCurAct();

	EventSystem:postEvent(EVENTTYPE_TEAMUP,EVENTID_TEAMUP_ACCEPT_INVITE)
end

--拒绝收到的组队邀请 --拒绝入队
function EventTeamUpInviteApplyRefuse()
	
	log("EventTeamUpInviteApplyRefuse");

	if (TeamUp_Invite_Apply_Type == 0) then
		TeamUpSystem.team_invite_reply("refuse", TeamUpSystem.Inviter, TeamUpSystem.InviterTeamID);
		if (TeamUp_Auto_Refuse == true) then
			TeamUpSystem.AutoRefuseInviterMap[TeamUpSystem.Inviter] = FuncUtil.GetServerTimeInSec();
		end

	elseif (TeamUp_Invite_Apply_Type == 1) then
		TeamUpSystem.team_apply_reply("refuse", TeamUpSystem.ApplyerID, TeamUpSystem.ApplyerTeamID);
		if (TeamUp_Auto_Refuse == true) then
			TeamUpSystem.AutoRefuseApplyerMap[TeamUpSystem.ApplyerID] = FuncUtil.GetServerTimeInSec();
		end
	end
	TeamUpSystem.InviteApplyShowing = false;
	TeamUpSystem.CheckNextInviteApply();
end

--申请离开队伍
function EventTeamUpLeaveTeam()
	log("EventTeamUpLeaveTeam "..TeamUp_CrtTeam_ID);

	-- Offline fake team cleanup (multi-teammate support)
	if FakeFriendSystem and FakeFriendSystem.PerformLeaveTeam then
		if FakeFriendSystem.PerformLeaveTeam() then return end
	end

	TeamUpSystem.team_quit_request(tonumber(TeamUp_CrtTeam_ID));
end


--对于申请组队提示的回应 --同意入队
function EventTeamUpApplyPermit()
	log("EventTeamUpPermit");
	--TeamUpSystem.team_apply_reply(TeamUpSystem.TeamInfo.id, true);
end

--对于申请组队提示的回应 --拒绝请求
function EventTeamUpApplyForbid()
	log("EventTeamUpForbid");
	--TeamUpSystem.team_apply_reply(TeamUpSystem.TeamInfo.id, false);
end

function EventTeamUpUI_Push()
end

function EventFetchInfo()

end

function EventFetchTeamUpInfo()
end

function EventTeamUpNoHostRight()
	log("EventTeamUpNoHostRight");
	DataMgr.ShowNoticeByID(110003); --仅房主可设置
end

function EventTeamUpNoRightForMatching()
	log("EventTeamUpNoRightForMatching");
	DataMgr.ShowNoticeByID(110017); --匹配中无法执行此操作
end

function EventTeamUpFailOnMatching()
	log("EventTeamUpNoHostRight");
	DataMgr.ShowNoticeByID(110014); --匹配中无法设置
end

--用户点击了展开按钮（应该关闭好友面板）
function EventTeamUpClickExpand()
	TeamUPFriendUI.HidePanel();
	
	--打开菜单也同步下数据
	TeamUpSystem.on_mode_shield_req();

	--EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_STATUS_UI_MATCH);
end


function EventTeamUpClickPlayerInfo()
	--PopUpNoticeUI.ShowMessageBox("Notice", "Content");
	log("EventTeamUpClickPlayerInfo");
	log("点击玩家的ID"..TeamUp_Click_Player_ID);	
	RoleInfoSystem.Enter(TeamUp_Click_Player_ID);	
	RoleInfoUI.Init(true, RoleInfoOpenFromType.TeamUp);
end

function EventTeamUpAddFriend()
	log("EventTeamUpAddFriend");
	FriendSystem.add_inner_friend_req(tonumber(TeamUp_Click_Player_ID), "",BP_ENUM_ADD_FRIEND_FROM_TEAM);
end

function EventTeamUpClickKick()
	log("EventTeamUpClickKick");
	TeamUpSystem.team_kick_request(tonumber(TeamUp_Click_Player_ID));
end

function EventTeamUpClickQuit()
	log("EventTeamUpClickQuit");
	if (TeamUp_Is_Matching) then
		EventTeamUpNoRightForMatching();
		return;
	end
	TeamUpSystem.team_quit_request(TeamUpSystem.TeamInfo.id);
end

function EventTeamUpChangeLeader()
	log("EventTeamUpChangeLeader");
	--对方已离线，不能任命队长
	local memberInfo = TeamUpSystem.GetMemberInfo(tonumber(TeamUp_Click_Player_ID));
	if memberInfo ~= nil then
		if memberInfo.svr == nil then --为空表示离线
			--todo 后续读表格
			DataMgr.ShowNoticeByID(110065);
			return;
		end
	end
		
	

	TeamUpSystem.team_change_leader_request(tonumber(TeamUp_Click_Player_ID));
end

function EventTeamUpClickCreateRoomBtn()
	log("EventTeamUpClickCreateRoomBtn");
	
	if TeamUp_CrtTeam_Count > 1 then
		DataMgr.ShowNoticeByID(110002); --请先退出组队
		return;
	end
	RoomUI:Init();
	RoomSystem.Enter();
	ClientSendBAReport(BP_BA_SHARE_ROOMREFASH, 0);
	ClientSendBAReport(BP_BA_LOBBY_ROOM_PANEL, 0);
end

--local test_flag = false;

function EventTeamUpClickTrainingBtn()
	--TeamUpUI.Test();
	--[[test_flag = not test_flag;
	local userid = TeamUpSystem.MyUserID + 1;
	if (test_flag) then
		TeamUpUI.OnFriendRemove(userid);
	else
		TeamUpUI.OnFriendAdd(userid);
	end
	
	
	if TeamUp_CrtTeam_Count > 1 then
		DataMgr.ShowNoticeByID(110002); --请先退出组队
		return;
	end
	--]]
	log("EventTeamUpClickTrainingBtn");

	NewteachingUI.Show()
	ClientSendBAReport(BP_BA_LOBBY_NEWERGUIDE_PANEL, 0);
end

--点击自动匹配
function EventTeamUpClickAutoMatchBtn()
	TeamUpSystem.team_change_fill_request(TeamUp_Will_Change_Fill);
	--[[if TeamUp_AutoMatch == true then		
		LobbySystem.SetFillValue(0);
		log("EventTeamUpClickAutoMatchBtn 0");
	else
		LobbySystem.SetFillValue(1);
		log("EventTeamUpClickAutoMatchBtn 1");
	end]]
end

function EventTeamUpUpdateClickPlayerInfo()
	TeamUp_Click_Player_IS_FRIEND = FriendSystem.IsMyFriend(tonumber(TeamUp_Click_Player_ID));
end


function TeamUpUI.Test()
	TeamUpUI.UpdateFriendStatus();
	--log("110001");
	--DataMgr.ShowNoticeByID(110001);	--队伍人数过多
	--TeamUpSystem.on_team_invite_notify(TeamUpSystem.MyUserID);
	--TeamUpSystem.on_team_apply_notify(TeamUpSystem.MyUserID, "jack");
	--LuaClassObj.HandleUIMessage(bp_lobby, "SpawnPlayer");
	--TeamUpSystem.team_kick_request(TeamUpSystem.MyUserID);
	--TeamUpSystem.team_quit_request(TeamUpSystem.TeamInfo.id);
end

function TeamUpUI.UpdateFriendStatus()
	--[[log("EventTeamUpUpdateFriendStatus");
	local found = false;
	if (BP_ARRAY_TeamUpMenuInfoList ~= nil) then
		for key, value in pairs(BP_ARRAY_TeamUpMenuInfoList) do  
			local player_id = tonumber(value.player_id);
			if (player_id ~= 0) then
				found = true;
				value.player_isFriend = FriendSystem.IsMyFriend(player_id);	
				log(value.player_name .. " isFriend = " .. tostring(value.player_isFriend));
			end
		end
	end		
	if (found) then
		log("EventTeamUpUpdateFriendStatus found = " .. tostring(found));
		LuaClassObj.HandleUIMessage(bp_teamup, "CreateOrUpdateFourHeadMenu");
	end]]
end

function TeamUpUI.GetShowData(userid)
	log("userid = ".. userid);
	--log_tree("BP_ARRAY_TeamUpMenuInfoList ", BP_ARRAY_TeamUpMenuInfoList)
	if (BP_ARRAY_TeamUpMenuInfoList ~= nil) then
		for key, value in pairs(BP_ARRAY_TeamUpMenuInfoList) do  
			log("value.player_id = ".. value.player_id);
			if (tonumber(value.player_id) == tonumber(userid)) then
				return value;
			end
		end
	end		
	return nil;
end

function TeamUpUI.CloseInviteApplyPanel()
	if (TeamUpSystem.InviteApplyShowing) then
		
		if (TeamUpSystem.InviteApplyShowType == 0) then
			TeamUpSystem.team_invite_reply("autoRefuseOnTeamChange", tonumber(TeamUpSystem.Inviter), tonumber(TeamUpSystem.InviterTeamID));
		elseif (TeamUpSystem.InviteApplyShowType == 1) then
			TeamUpSystem.team_apply_reply("autoRefuseOnTeamChange", tonumber(TeamUpSystem.ApplyerID), tonumber(TeamUpSystem.ApplyerTeamID));
		end
		
		TeamUpSystem.InviteApplyShowing = false;
		LuaClassObj.HandleUIMessage(bp_teamup, "HideInviteApplyPanel");
	end
end

function EventSetHasGuideNewteaching()
	DataMgr.team_up_has_guide_newteaching = true;
end

function  EventAfterChooseZone()
	log("EventAfterChooseZone")
	GlobalChatVoice.UnlockVoiceOperation();
	GlobalChatVoice.ResetVoiceOperation();
	GlobalChatVoice.QuitRoomTemp();
end

function EventTeamCodeDelete()
	FaceTeamSystem.team_code_delete_req(TeamUpSystem.GetTeamCode())
end


-----------------------intl start-----------------------------

--定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问
--好友信息

--(以Event开头的函数名就能暴露给蓝图调用)

function EventQueryMatchZoneList()
	log("EventQueryMatchZoneList");
	TeamUpSystem.query_match_zone_list_req();
end
--蓝图返回的选大区请求id
BP_Back_ChooseZoneId = ""

function EventSelectZone_Push()
	log("EventSelectZone_Push, BP_Back_ChooseZoneId = "..BP_Back_ChooseZoneId);
	if not BP_Room_IsInRoom then
		TeamUpSystem.on_select_zone_req(tonumber(BP_Back_ChooseZoneId));
	end
end

function TeamUpUI.OnLanguageChanged()
	log("lua bp_teamup OnLanguageChanged." );
	--LuaClassObj.HandleUIMessage(bp_teamup, "OnLanguageChanged");
end

-- 按照后台下发的ping服务器的频率设置与服务器ping的频率
function TeamUpUI.OnGetUDPPingIntervalTime(pingSvrPars)
	if pingSvrPars then
		BP_Teamup_MinUDPPingIntervalTime = pingSvrPars.MinUDPPingIntervalTime or 15;
		BP_Teamup_UDPPingIntervalTime = pingSvrPars.UDPPingIntervalTime or 15;
		LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "InitUDPPingCollectorNormal");
	end
end

-----------------------intl end-----------------------------
