--[[
	组队好友UI相关逻辑 by eddygu 2017-11-19	
--]]

TeamUPFriendUI = TeamUPFriendUI or 
{
	isInit = false;
	isShowing = false;
	profileSlice = 8;

	isContentShowing = false
}

BP_STRUCT_InviteFriendProfile =

{
    gid="",
	nickName = "",
	level = 0,
    picUrl = "",
    vipLevel = 0,
    ladder = 0,
    platName = "",
    sex = 0,
	online = 1, -- 0为离线，1为在线
	showInviteIcon = 0,
    lastOnlineTime = 0,
	teamState = 0, -- 0为空闲，1为组队中（组队中提供当前队伍人数，队伍最大可容纳人数，队伍id）,2为已开局状态（需已开局时间数据
	reserveState = 0,	-- 0 亲密度不足不能预约，1 可预约，2 预约CD中, 3 已预约
	currentTeamAmount = 1, -- 当前队伍人数
	maxTeamAmount = 4, -- 队伍最大可容纳人数
	teamId = 0, -- 队伍id
	timeSinceGameBegin = 0, -- 已开局时间
    op=0, --邀请列表里面的操作
    applyMsg="", --邀请列表里面的留言
	timeSinceGameBeginStr = "", --已开局时间
	intimacy = 0,
	
	gameSubMode = 0, -- 子模式id(对应BTMode表),用于观战获取地图
	watchUid = 0, -- 若观战中则不为0
	enableWatch = 1,  --是否允许观战

	segment_info_solo = 0;-- 段位数据
	segment_info_duo = 0;
	segment_info_squad = 0;
	cur_avatar_box_id = 0; --头像框

	upass_is_buy = 0; -- 绝地通行证--是否购买(1为已购买，0为未购买)
	upass_keep_buy = 0; -- 绝地通行证--连续购买
	upass_is_show = 0; -- 绝地通行证--是否显示(1为显示，0为不显示)
    roleNation = "";    --国籍

    aliasId = 0;
    aliasTitle = "";
    aliasNation = "";
};


--组队好友列表
BP_ARRAY_Teamuup_Friend_Profile =
{
    BP_STRUCT_InviteFriendProfile = _G.BP_STRUCT_InviteFriendProfile, --定义结构体数组，这种写法要作为规范规定下来
}

--车队列表
BP_ARRAY_CarTeam_Friend = 
{
	BP_STRUCT_InviteFriendProfile = _G.BP_STRUCT_InviteFriendProfile,
}

--最近列表
BP_ARRAY_Recent_Friend = 
{
	BP_STRUCT_InviteFriendProfile = _G.BP_STRUCT_InviteFriendProfile,
}

--UI是否展开
BP_TeamUPFriendIsShow = false;

------------------------------军团
BP_TeamUp_Corps_Scroll_Start = 0;
BP_TeamUp_Corps_Scroll_End = 0;

--军团全量数据
BP_ARRAY_TeamUp_Corps_Friend = 
{
	BP_STRUCT_InviteFriendProfile = _G.BP_STRUCT_InviteFriendProfile,
}
--分段加载gid全量
BP_STRUCT_TeamupCorpsLiteProfile = 
{
	gid = "",	
}
BP_ARRAY_Corps_Lite_Profile = 
{
	BP_STRUCT_TeamupCorpsLiteProfile = _G.BP_STRUCT_TeamupCorpsLiteProfile,
}
--ui（暂且显示8个）分段显示详细数据
BP_ARRAY_Corps_Friend_Detail_Profile = 
{
	BP_STRUCT_InviteFriendProfile = _G.BP_STRUCT_InviteFriendProfile,
}
------------------------------end军团

--是否关闭相关UI,true表示关闭UI
local IsCheckClose = false;

BP_TeamupFriendMaxLoginTypeNum = 5;

-- 是否开启观战
BP_TEAMUP_FRIEND_IS_WATCHING_OPEN = false;

-- 排序后的登录类型列表, 空就是没有
BP_ARRAY_TeamupFriendLoginTypeOrderList =
{
    "",
    "",
    "",
    "",
    "",
}

function bp_teamup_friend_RegisterUI()                                                                                                                                     
	LuaClassObj.SubUIWidgetList(bp_teamup_friend,
		{
			{Path="/Game/UMG/UI_Logic/Lobby/Lobby_InviteFriendLogic_BP.Lobby_InviteFriendLogic_BP_C", Container="Default", ZOrder=34},
		},
		{"Lobby"},
		false,
		bp_teamup_friend_OnModeSwitched ~= nil
	);
    

    EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, TeamUPFriendUI.HandleIOSCheck);
	EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, TeamUPFriendUI.UpdateLobbySkin);

end	
function TeamUPFriendUI.HandleIOSCheck()
	-- body
    if GlobalData:IsIOSCheck() then
        LuaClassObj.SubCollapseWidgetList(bp_teamup_friend,
            "Lobby_InviteFriendLogic_BP_C",
            {
                "WidgetSwitcher_WXorQQ",
                "Overlay_OfflineShareFather",
            }
        );
    LuaClassObj.HandleCollapseWidgetList(bp_teamup_friend, "Lobby_InviteFriendLogic_BP_C");
    end
    
end


function TeamUPFriendUI.Init()
	log("TeamUPFriendUI.Init","corps");
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_STATUS_UI_MATCH, TeamUPFriendUI.OnHandleUIChange);
    EventSystem:registEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_UPDATE_MEMBER, TeamUPFriendUI.UpdateCarTeamMember);
	EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE, TeamUPFriendUI.UpdateAllFriendStatus);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_INVITE_FRIEND, TeamUPFriendUI.ShowUI)
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, TeamUPFriendUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, TeamUPFriendUI.WardRobeAvatarResetClose);
    --获取军团数据
	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, TeamUPFriendUI.InitCorpsData);
	EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_CORPS_STATE_UPDATE, TeamUPFriendUI.UpdateCorpsMember);
	BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList();
	TeamUPFriendUI.isShowing = true;
	TeamUPFriendUI.isContentShowing = false
	--log_tree("TeamUPFriendUI.Init", BP_ARRAY_Teamuup_Friend_Profile)

	BP_TEAMUP_FRIEND_IS_WATCHING_OPEN =  LogicLobbyWatching.IsWatchingOpen();

	StatusManager.getInstance():addEventListener(StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED, TeamUPFriendUI.OnStatusChanged)
end


function TeamUPFriendUI.Release()
	log("TeamUPFriendUI.Release","corps");
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_STATUS_UI_MATCH, TeamUPFriendUI.OnHandleUIChange);
    EventSystem:unregistEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_UPDATE_MEMBER, TeamUPFriendUI.UpdateCarTeamMember);
	EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE, TeamUPFriendUI.UpdateAllFriendStatus);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_INVITE_FRIEND, TeamUPFriendUI.ShowUI)
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, TeamUPFriendUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, TeamUPFriendUI.WardRobeAvatarResetClose);
    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, TeamUPFriendUI.InitCorpsData)
	EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_CORPS_STATE_UPDATE, TeamUPFriendUI.UpdateCorpsMember);
	
	StatusManager.getInstance():removeEventListener(TeamUPFriendUI.OnStatusChanged)
end

function TeamUPFriendUI.ShowUI()
	if not BP_TeamUPFriendIsShow then
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "OnClickBtnFriendList")
	end
end


--sami 个人信息角色开关处理
function TeamUPFriendUI.WardRobeAvatarResetOpen()
	--log("TeamUPFriendUI.WardRobeAvatarResetOpen")
	if(TeamUPFriendUI.isShowing == true) then
		LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "HideSelf");
		TeamUPFriendUI.isShowing = false;
		-- TeamUPFriendUI.isContentShowing = false

		LobbyUI.HideAddFriendMessage()
	end
end

function TeamUPFriendUI.WardRobeAvatarResetClose()
    log("TeamUPFriendUI.WardRobeAvatarResetClose")
	if TeamUPFriendUI.isShowing == false and WardrobeUI.saveIsShowing == false then
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "ShowSelf")
		TeamUPFriendUI.isShowing = true;

		LobbyUI.ShowAddFriendMessage()
	end
end

function TeamUPFriendUI.UpdateCarTeamMember(eventType, eventID, msgType)
	if eventType ~= EVENTTYPE_ALLIANCE then
		return;
	end

	if eventID == EVENTID_ALLIANCE_UPDATE_MEMBER then --车队成员更新
		--log_tree("UpdateCarTeamMember", msgType);	
		--重新取下车队数据
		TeamUPFriendUI.SetCarTeamFriendList()

		if BP_TeamUPFriendIsShow == true then
			LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateCarTeamStatus");
		end

	end

end

function TeamUPFriendUI.OnHandleUIChange(eventType, eventID, vars)
	log("OnHandleUIChange");
	if eventType ~= EVENTTYPE_TEAMUP then
		return;
	end
	
	if eventID == EVENTID_TEAMUP_STATUS_UI_MATCH then
		log("EVENTID_TEAMUP_STATUS_UI_MATCH");
		if BP_TeamUPFriendIsShow then
			log("EVENTID_TEAMUP_STATUS_UI_MATCH Hide");
			LuaClassObj.HandleUIMessage(bp_teamup_friend, "HideFriendMenu");
		end
	end
end


--资源加载完成
function bp_teamup_friend_OnModeSwitched(gamestatus)
	
	log("bp_teamup_friend_OnModeSwitched gamestatus = " .. gamestatus);
	if _G._inCustomBattle and string.lower(gamestatus) == "lobby" then return end
	if string.lower(gamestatus) == "lobby" then		
		
		--拿去好友系统数据
		TeamUPFriendUI.Init();
		
		--默认不显示UI
		log("bp_teamup_friend ShowUI");
		--屏蔽2017年12月10版本
		if IsCheckClose == false then
			LuaClassObj.HandleUIMessage(bp_teamup_friend, "UIShow");	
		end
	end	

	
	
end



local function RefreshList()
	--打开列表才需要取自己队友数量
	BP_MyPlyerCount = TeamUpSystem.TeamInfo.player_count;
	
	BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList();	
	
	--列表增加或者删除
	LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateFriendList");		
end

--sami显示好友列表
function EventShowFriendMenu()
	log("TeamUPFriendUI.EventShowFriendMenu")
	TeamUPFriendUI.isContentShowing = true

	LobbyChatEntranceUI.ForceSetVisibility(false);
	ExpressionUI.WardRobeAvatarResetOpen();

end

--是否显示面板下栏（房间状态区分）
function EventSetDownPanel()
	if BP_Room_IsInRoom then
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "HideDownPanel");
	else
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "ShowDownPanel");
	end
end

--隐藏好友列表
function EventHideFriendMenu()
	log("TeamUPFriendUI.EventHideFriendMenu")
	TeamUPFriendUI.isContentShowing = false

	LobbyChatEntranceUI.ForceSetVisibility(true);
	ExpressionUI.WardRobeAvatarResetClose();
end

function TeamUPFriendUI.ShowPanel()
	log("TeamUPFriendUI.ShowPanel")
	--屏蔽2017年12月10版本
	if IsCheckClose == false then
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "UIShow");	
	end
	
end

function TeamUPFriendUI.ShowFriendPanel()
	log("TeamUPFriendUI.ShowFriendPanel");
	if IsCheckClose == false then
		BP_TeamUp_EnterRoom = RoomUI.IsShow or RoomWaitingUI.IsShow;
		BP_TeamUp_EnterRoomWaiting = RoomWaitingUI.IsShow;
		log("BP_TeamUp_EnterRoomWaiting = "..tostring(BP_TeamUp_EnterRoomWaiting));
		LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "UIShowNative");
		LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "OnclickBtnFriendList");
	end
	TeamUPFriendUI.UpdateAllFriendStatus();
end

function TeamUPFriendUI.HidePanel()
	log("TeamUPFriendUI.HidePanel")
	LuaClassObj.HandleUIMessage(bp_teamup_friend, "HideFriendMenu");	
end

function TeamUPFriendUI.ShowBtnPanel()
	log("TeamUPFriendUI.ShowBtnPanel")
	LuaClassObj.HandleUIMessage(bp_teamup_friend, "ShowBtnPanel");
end

--*更新逻辑*--
--拉取、增加、删除好友、逻辑
function TeamUPFriendUI.UpdateFriend()	
	if TeamUPFriendUI.isInit == true then
		RefreshList();
		TeamUpUI.UpdateFriendStatus();		
	end
	--更新好友数量
	TeamUPFriendUI.UpdateOnlineNum();
	
end

--更新好友状态
function TeamUPFriendUI.UpdateAllFriendStatus()		
	--如果这里面板打开才需要更新数据，否则
	if(BP_TeamUPFriendIsShow) then
		--取最新好友所有状态
		BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList();
		BP_ARRAY_Recent_Friend = FriendSystem.SortRecentList();
		
		for k,v in pairs(BP_ARRAY_Teamuup_Friend_Profile) do	
			local str_gid = v.gid;
			
			if v.intimacy == nil then
				log("updateallfriendstatus intimacy is nil")
				v.intimacy = 0
			end
			
			if (v.intimacy >= 100) then	
				local isReserved = LobbyChatSystem.IsReserved(str_gid);				
				if true == isReserved then					
					v.reserveState = 3;
				else					
					local reservingData = LobbyChatSystem.friendReservingList[str_gid];
					if nil ~= reservingData then					
						local thisTime = os.time();								
						if thisTime - reservingData.time >= 60 then
							v.reserveState = 1;							
							LobbyChatSystem.on_clear_reserving(str_gid);
						else
							v.reserveState = 2;
						end
					else					
						v.reserveState = 1;
					end
				end				
			else				
				v.reserveState = 0;
			end
		end	
		--log("UpdateAllFriendStatus");
		--log_tree("UpdateAllFriendStatus new data", BP_ARRAY_Teamuup_Friend_Profile);
		--只刷状态信息
		--LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateAllFriendStausNew");
		--更新页签相关的数据
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateByCurrentType");		
		
	end

end

function TeamUPFriendUI.ChangePlayerCount()
	--队伍人员变更，外部调用，重新刷新好友列表,表示可以邀请，或申请入队按钮出现
	BP_MyPlyerCount = TeamUpSystem.TeamInfo.player_count;
	--log("TeamUPFriendUI.ChangePlayerCount BP_MyPlyerCount"..BP_MyPlyerCount);
	TeamUPFriendUI.UpdateAllFriendStatus();	
	
end
--更新BP_ARRAY_Teamuup_Friend_Profile
function TeamUPFriendUI.UpdateTeamUpProfile()
	BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList();
	--log_tree("zino BP_ARRAY_Teamuup_Friend_Profile",BP_ARRAY_Teamuup_Friend_Profile)
end
--更新在线人数显示
function TeamUPFriendUI.UpdateOnlineNum()
	--取最新好友所有状态
	log("TeamUPFriendUI.UpdateOnlineNum");
	BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList();
	--log_tree("TeamUPFriendUI.UpdateOnlineNum", BP_ARRAY_Teamuup_Friend_Profile);
	LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateOnLineNum");	
	if(BP_TeamUPFriendIsShow) then
		--log("TeamUPFriendUI.UpdateOnlineNum BP_TeamUPFriendIsShow true");	
		TeamUPFriendUI.UpdateAllFriendStatus();
	end
end


function TeamUPFriendUI.CheckSwitch()
	log("==================checkSWitch")
	if IsCheckClose == true then
		IsCheckClose = false;
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "UIShow");
	end
end

--从战斗回到大厅，或者切换账号清空相关数据
function TeamUPFriendUI.OnLogOut()
	IsCheckClose = false;
	TeamUPFriendUI.isInit = false;
	BP_MyPlyerCount = 0;

end

function TeamUPFriendUI.OnFriendReserved(str_gid)
	TeamUPFriendUI.UpdateAllFriendStatus();
end


--************************************************蓝图交互逻辑**********************************--
--蓝图取最新lua数据
function EventFetchTeamupFriendInfo()
end

--lua取最新蓝图的修改过得变量
function EventSetInfo_Push()

end

--打开列表，关闭时候回调
function EventShowListCallBack()
	if(BP_TeamUPFriendIsShow) then
		
		--FriendSystem.getFriendIDList()
		--打开 发请求告诉后台实时拉取状态
		TeamUpSystem.recv_stau_request(true);
		--同步下最新状态
		FriendSystem.batchGetTeamInfoList();
		TeamUpUI.HidePanel();		
		--打开好友重新拉取最新数据
		--FriendSystem.getFriendIDList();	
			
		log("EventShowListCallBack true");		

		LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateOnLineNum");	
		--设置最近队友数据
		BP_ARRAY_Recent_Friend = FriendSystem.SortRecentList();
		--[[local idlist = {};
		for i = 1,#BP_ARRAY_Recent_Friend,1 do
			table.insert(idlist, BP_ARRAY_Recent_Friend[i].gid);
		end
		if #idlist > 0 then
			local TeamupHandler = RequireNetHandler("TeamupHandler")
			TeamupHandler.send_batch_get_group_and_online_req( "recentteammate", idlist);
		end--]]
	
        --设置车队数据
		TeamUPFriendUI.SetCarTeamFriendList()
		--log_tree("EventShowListCallBack BP_ARRAY_CarTeam_Friend",BP_ARRAY_CarTeam_Friend);
		
		--设置军团数据
		--CorpsMgr.GetCorpsMemberList();

		FriendSystem.CheckFetchFriendList();
	else		
		TeamUpUI.ShowPanel();
		TeamUpSystem.recv_stau_request(false);
		log("EventShowListCallBack false");		
	end


	--第一次打开
	if TeamUPFriendUI.isInit == false then
		--第一次打开重新拉取列表
		TeamUPFriendUI.isInit = true;
		TeamUPFriendUI.UpdateFriend();
		return;
	end
		
	if(BP_TeamUPFriendIsShow) then		
		--打开好友重新拉取下最新状态
		TeamUPFriendUI.UpdateAllFriendStatus();
	end

	--cole bug=58181204 【【ALL】房间模块：再房间内点击邀请好友按钮后大厅的组队图标会出现在房间内】
	if RoomUI.IsShow or RoomWaitingUI.IsShow then
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "HideBtnPanel");
	end
end

--邀请好友的ID
BP_InviteFriendID = "";
BP_InviteFriendName = "";

--自己队伍人数，用于（双方都是≥2人队伍，不能邀请或者加入，不显示邀请或加入按钮。）
BP_MyPlyerCount = 0;
-- 0 亲密度不足不能预约，1 可预约，2 预约CD中, 3 已预约
BP_ReservationState = 0;

--点击邀请好友按钮 (delegates to FakeFriendSystem)
function EventClickInviteFriendBtn()
	FakeFriendSystem.PerformInvite()
end


-- 离线离开队伍 (delegates to FakeFriendSystem)
function EventTeamUpLeaveTeam()
	FakeFriendSystem.PerformLeaveTeam()
end

--点击申请组队
function EventClickJoinBtn()
	local isMatch = TeamUpUI.IsMatching();
	if isMatch then
		log("EventClickInviteFriendBtn isMatch:");
		--DataMgr.ShowNoticeByString("匹配中，无法邀请或者加入队伍");
		DataMgr.ShowNoticeByID(110122);	
		return;
	end
	--log_tree("OnClickMeta", BP_ARRAY_Teamuup_Friend_Profile);
	log("EventClickJoinBtn GID:"..tonumber(BP_InviteFriendID));	
	TeamUpSystem.team_apply_request(tonumber(BP_InviteFriendID));
end

BP_Teamup_friend_IsFaceTeamOpened = true;

function EventIsFaceTeamOpened()
	if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_MODULE_FACE_TEAM] == nil then
        BP_Teamup_friend_IsFaceTeamOpened = true;
    elseif LobbySystem.LobbyMenuOpenStatus[BP_ENUM_MODULE_FACE_TEAM].is_open == 0 then
        BP_Teamup_friend_IsFaceTeamOpened = false;
    else
        BP_Teamup_friend_IsFaceTeamOpened = true;
    end
	log("BP_Teamup_friend_IsFaceTeamOpened = " .. tostring(BP_ENUM_MODULE_FACE_TEAM));
end

function EventClickFaceTeamBtn()
	log("EventClickFaceTeamBtn()")
	if TeamUpSystem.IsInFaceTeam() then
		DataMgr.ShowNoticeByID(4364);
		return
	end
	FaceteamUI:OpenCreateFaceTeamPanel()
	FaceteamUI.Init()
end

function EventOnClickInviteJoin()
	log("[HHF]EventOnClickInviteJoin");
	ClientSendBAReport(BP_BA_LOBBY_INVITE_FRIEND);
	
	InviteJoinTeamUI.ShowUI();
	--隐藏大厅邀请按钮的高亮显示，用在组队邀请活动中，需要高亮指引的地方
	LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "OnMsg_Normal_ButtonInvite")
end

--点击跳转好友列表按钮
function EventClickAddFriendBtn()
	--TeamUPFriendUI.TestOneData("10000002");
	--LobbyFriendUI:Jump(); 
	
	log("friend list open");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_FRIEND) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    LobbyFriendUI:Init();
    LobbyFriendUI:Show();

	ClientSendBAReport(BP_BA_LOBBY_ADD_FRIEND);
end

--点击邀请上线
function EventClickOfflineShare()
	log("[HHF]EventClickOfflineShare");
	if Client.IsInstallMessenger(NetInterface) == false then
		DataMgr.ShowNoticeByID(4466);
		return
	end

	local function confirmClick()
		FriendSystem.invite_offline_friend_req();
	end
	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, string.format(Client.GetTableData("LocalizeRes", "4059").TextValue, BP_InviteFriendName), confirmClick, nil);
end

--点击预约
function EventClickReserveFriend()
	LobbyChatSystem.on_reserve_friend_req(BP_InviteFriendID);
	
	local friendData = FriendSystem.GetFriendDataByGID(BP_InviteFriendID);
	if nil ~= friendData then
		PopUpNoticeUI.ShowNewNotice(string.format(DataMgr.GetMsgByID(110123), friendData.nickName));
	end	
end
--查询预约状态
function EventCheckReservationState()
	if BP_TeamUPFriendIsShow == true then
		TeamUPFriendUI.UpdateAllFriendStatus();	
	end	
end

--点击头像设置的GID
BP_FriendHeadClickGid = "";
function EventClickHeadBtn()
	RoleInfoSystem.Enter(BP_FriendHeadClickGid);
	log("bp_teamup_friend enter profile panel:"..tostring(BP_FriendHeadClickGid));
	RoleInfoUI.Init(true, RoleInfoOpenFromType.TeamUPFriend);
end

function EventClickStartChat()
	local isFriend = FriendSystem.IsMyFriend(BP_FriendHeadClickGid);
	if false == isFriend then		
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106075).TextValue);
		return;
	end
	
	LobbyChatLogic.ChatWithFriend(BP_FriendHeadClickGid);
end

function EventClickPlatformInvite()
	TeamUpSystem.WXPlatformInviteType = 0;
	TeamUpSystem.get_teamid_for_plat_request();
end

-- 微信小程序
function EventClickPlatformInviteWXMiniApp()
	log("EventClickPlatformInviteWXMiniApp");
	TeamUpSystem.WXPlatformInviteType = 1;
	TeamUpSystem.get_teamid_for_plat_request();
end

function EventSwitchFriend( )
	log("TeamUpFriendUIEventSwitchFriend")
end

function EventSwitchRecent( )
	log("TeamUpFriendUIEventSwitchRecent")
	--设置最近队友数据
	BP_ARRAY_Recent_Friend = FriendSystem.SortRecentList();
	local idlist = {};
	for i = 1,#BP_ARRAY_Recent_Friend,1 do
		table.insert(idlist, BP_ARRAY_Recent_Friend[i].gid);
	end
	if #idlist > 0 then
		local TeamupHandler = RequireNetHandler("TeamupHandler")
			TeamupHandler.send_batch_get_group_and_online_req( "recentteammate", idlist);
	end
end

function EventSwitchCarTeam( )
	log("TeamUpFriendUIEventSwitchCarTeam")
	TeamUPFriendUI.SetCarTeamFriendList()
	log_tree("BP_ARRAY_CarTeam_Friend", BP_ARRAY_CarTeam_Friend , "test")
	if BP_TeamUPFriendIsShow == true then
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateCarTeamStatus");
	end
end

function TeamUPFriendUI.SetCarTeamFriendList()
	log("TeamUPFriendUI.SetCarTeamFriendList")
	BP_ARRAY_CarTeam_Friend = AllianceSystem.GetAllianceProfileListWithoutSelf();
	for k , v in pairs(BP_ARRAY_CarTeam_Friend) do
		for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(v.gid) then
				v.enableWatch = BP_ARRAY_All_Friend_Profile[i].enableWatch
				v.upass_keep_buy = v.upass_keep;
			end
		end
	end
end

function TeamUPFriendUI.TestOneData(uid)
	for k,v in pairs(BP_ARRAY_Teamuup_Friend_Profile) do
		log("uid:aaaaaaaa"..uid);
		log("v.gid:aaaaaaaa"..v.gid);
		--log("aaaaaaa"..tostring(uid == v.gid));
		if tostring(uid) == tostring(v.gid) then	
			v.currentTeamAmount = 4;
			v.maxTeamAmount = 4;
			v.nickName = "adfadf";		
			v.teamState = 1;
			v.level = 100;
			break;
		end		
	
	end
	--log_tree("TeamUPFriendUI.TestOneData", BP_ARRAY_Teamuup_Friend_Profile);
	LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateAllFriendStausNew");
end

-- 获取登录类型配置
function EventTeamupFriendGetLoginTypeList()

	BP_ARRAY_TeamupFriendLoginTypeOrderList = FuncUtil.GetLoginTypeList(BP_ARRAY_TeamupFriendLoginTypeOrderList);
	
end

------------------------------军团需求


function TeamUPFriendUI.CopyBaseInfo(v, profile)
	--log_tree("CopyBaseInfo",profile);
	v.gid = tostring(profile.uid);
	v.nickName = profile.nickName;
	v.level = profile.level;
	v.vipLevel = profile.vipLevel;
	v.picUrl = profile.picUrl;
	v.platName = profile.platName;
	v.sex = profile.sex;
	v.lastOnlineTime = profile.lastOnlineTime;
	--v.segment_info_solo = profile.segment_info[1];
	--v.segment_info_duo = profile.segment_info[2];
	--v.segment_info_squad = profile.segment_info[3];
	v.segment_info_solo, v.segment_info_duo, v.segment_info_squad = FuncUtil.GetMaxSegement(profile.segment_info);
	v.history_max_segment_level = profile.history_max_segment_level;
	if profile.cur_max_segment_level ~= nil then
		v.history_max_segment_level = profile.cur_max_segment_level;
	end 
	v.cur_avatar_box_id = profile.cur_avatar_box_id;
	v.aliasId = profile.aliasId or 0;
	v.aliasTitle = profile.aliasTitle or "";
	v.aliasNation = profile.aliasNation or "";
	v.roleNation = profile.roleNation or "";
	--v.ownerID = profile.owner_id or profile.ownerID or 0;
	if FriendSystem.IsMyFriend(v.gid) then
		v.enableWatch = profile.enableWatch;
	else
		-- 非好友，不开启观战
		v.enableWatch = 0;
	end
  --[[
    v.ladder = 0;
	v.online = 1; -- 0为离线，1为在线
	v.showInviteIcon = 0;   
	v.teamState = 0; -- 0为空闲，1为组队中（组队中提供当前队伍人数，队伍最大可容纳人数，队伍id）,2为已开局状态（需已开局时间数据
	v.reserveState = 0;	-- 0 亲密度不足不能预约，1 可预约，2 预约CD中, 3 已预约
	v.currentTeamAmount = 1; -- 当前队伍人数
	v.maxTeamAmount = 4; -- 队伍最大可容纳人数
	v.teamId = 0; -- 队伍id
	v.timeSinceGameBegin = 0; -- 已开局时间
    v.op=0; --邀请列表里面的操作
    v.applyMsg=""; --邀请列表里面的留言
	v.timeSinceGameBeginStr = ""; --已开局时间
	v.game_mode = 0;--0为默认模式
	v.gameModeStr = ""; --经典模式中（已开局t分钟）	训练模式中（已开局t分钟）天命圈模式中（已开局t分钟）		
	v.intimacy = 0;	
	v.remarks_name="";--备注名称，有备注名称表示备注名称，无备注表示平台名称
	]]
	return v;
end


function TeamUPFriendUI.InitCorpsData(eventType, eventID, dataList)
	log("TeamUPFriendUIInitCorpsData","corps")
	if eventType ~= EVENTTYPE_CORPS then
		return;
	end

	if eventID ~= EVENTID_CORPS_GET_MEMBERLIST	then
		return;
	end


	if dataList == nil then
		return;
	end
	BP_ARRAY_TeamUp_Corps_Friend = {};
	--log_tree("TeamUPFriendUIInitCorpsData",dataList,"corps")
	for i,v in ipairs(dataList) do
		if v.BP_STRUCT_BASE_INFO.profile ~= nil then
			if tonumber(v.BP_STRUCT_BASE_INFO.profile.uid) ~= tonumber(DataMgr.roleData.uid) then
				local newDataInfo = {};
				newDataInfo = TeamUPFriendUI.CopyBaseInfo(newDataInfo, v.BP_STRUCT_BASE_INFO.profile);	
				--加入RP图标和旗帜信息的显示
				newDataInfo.roleNation = v.BP_STRUCT_BASE_INFO.profile.nation;
				newDataInfo.upass_is_buy = v.BP_STRUCT_BASE_INFO.profile.upass.is_buy;
				newDataInfo.upass_keep_buy = v.BP_STRUCT_BASE_INFO.profile.upass.keep_buy or 0;
				newDataInfo.upass_is_show = v.BP_STRUCT_BASE_INFO.upass_is_show;
				newDataInfo.aliasId = v.BP_STRUCT_BASE_INFO.profile.alias.id;
				newDataInfo.aliasTitle = v.BP_STRUCT_BASE_INFO.profile.alias.title;
				newDataInfo.aliasNation = v.BP_STRUCT_BASE_INFO.profile.alias.nation;
				--过滤非好友的
				local isFriend = FriendSystem.IsPlatFriend(newDataInfo.gid);
				--log("TeamUPFriendUIInitCorpsData:"..newDataInfo.gid.."isFriend:"..tostring(isFriend));
				if isFriend == false then
					--非好友不显示平台名字和备注名字
					newDataInfo.platName = "";
					newDataInfo.remarks_name = "";
				end 
				table.insert( BP_ARRAY_TeamUp_Corps_Friend, newDataInfo);	
			end
		end
	end
	--log_tree("BP_ARRAY_TeamUp_Corps_Friend",BP_ARRAY_TeamUp_Corps_Friend);
	--log("BP_ARRAY_TeamUp_Corps_Friend"..#BP_ARRAY_TeamUp_Corps_Friend);
	local len = #BP_ARRAY_TeamUp_Corps_Friend;
	if len == 0 then
		--清除数据
		--刷新UI
		TeamUPFriendUI.UpdateCorpsData();
		if(BP_TeamUPFriendIsShow) and false == BP_Friend_Is_Show  then	
			LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "UpdateByCurrentType");		
		end	
	else
		TeamUPFriendUI.SendCorpsMemberStatus();
	end	
end

function TeamUPFriendUI.UpdateCorpsData()

	--BP_ARRAY_TeamUp_Corps_Friend = AllianceSystem.GetAllianceProfileListWithoutSelf();
	BP_ARRAY_Corps_Lite_Profile = {}; --只存gid的全量数据
	BP_ARRAY_Corps_Friend_Detail_Profile = {}; --列表显示详细数据
	--log("BP_TeamUp_Corps_Scroll_End"..tostring(BP_TeamUp_Corps_Scroll_End));
	--取全量
	if BP_TeamUp_Corps_Scroll_Start <=0  then
		BP_TeamUp_Corps_Scroll_Start = 0;		
	end

	if BP_TeamUp_Corps_Scroll_End <= 0 then		
		BP_TeamUp_Corps_Scroll_End = TeamUPFriendUI.profileSlice;
	end

	local startIndex = BP_TeamUp_Corps_Scroll_Start / TeamUPFriendUI.profileSlice;
	local endIndex = BP_TeamUp_Corps_Scroll_End / TeamUPFriendUI.profileSlice;

	local count = 0;

	--组队排序
	table.sort( BP_ARRAY_TeamUp_Corps_Friend, TeamUPFriendUI.SortCorpsMember);
	for k,v in pairs(BP_ARRAY_TeamUp_Corps_Friend) do
		--log_tree("BP_ARRAY_TeamUp_Corps_Friend11",v);
		local str_gid = v.gid;
		table.insert(BP_ARRAY_Corps_Lite_Profile,{gid = tostring(str_gid)});			
		if (startIndex * TeamUPFriendUI.profileSlice <= count) and (endIndex * TeamUPFriendUI.profileSlice >= count) then			
			table.insert(BP_ARRAY_Corps_Friend_Detail_Profile, v);
		end		
		count = count + 1;	
	end

	--log_tree("BP_ARRAY_Corps_Friend_Detail_Profile", BP_ARRAY_Corps_Friend_Detail_Profile);
end

--更新取军团成员状态（打开好友和切换页签）
function TeamUPFriendUI.SendCorpsMemberStatus()
	local idlist = {};
	for i = 1,#BP_ARRAY_TeamUp_Corps_Friend,1 do		
		if BP_ARRAY_TeamUp_Corps_Friend[i].gid ~= nil then
			table.insert(idlist, BP_ARRAY_TeamUp_Corps_Friend[i].gid);
		end		
	end
	if #idlist > 0 then
		--local TeamupHandler = RequireNetHandler("TeamupHandler")
		--TeamupHandler.send_batch_get_group_and_online_req( "corpsTeamup", idlist);
		-- ProfileMgr.GetProfileList(idlist, TeamUPFriendUI.UpdateCorpsMemberStateCallBack, false, false, false, true)	
		StatusManager.getInstance():request(idlist, StatusManager.KEY_CORPS_TEAMUP)
	end
end

function TeamUPFriendUI.UpdateCorpsMemberStateCallBack(listInfo)
	-- body
	--log_tree("UpdateCorpsMemberStateCallBack",listInfo);
	TeamUPFriendUI.UpdateCorpsMember(EVENTTYPE_FRIEND, EVENTID_FRIEND_CORPS_STATE_UPDATE, listInfo);
end

--军团组队排序
function TeamUPFriendUI.SortCorpsMember(a, b)
    
	if a.online == nil or b.online == nil then
		return false
	end

	if a.online == b.online then
		if a.teamState == nil or b.teamState == nil then
				return false
			end
			
		if a.teamState == b.teamState then
	
            if a.level == nil or b.level == nil then
                return false
            end
                
            if a.level == b.level then
                return tonumber(a.lastOnlineTime) > tonumber(b.lastOnlineTime)
            else
                return a.level > b.level
            end

		else
			return a.teamState < b.teamState
		end
	else
		return a.online > b.online
	end

end

-- 基于StatusManager的成员状态刷新
function TeamUPFriendUI.OnStatusChanged(packet)
	log_tree("TeamUPFriendUI OnStatusChanged", packet,"StatusManager")
	if packet.key ~= StatusManager.KEY_CORPS_TEAMUP 
	and packet.key ~= StatusManager.KEY_SERVER_NOTIFY then 
		return 
	end

	local stm = StatusManager.getInstance()

	for ka,va in pairs(BP_ARRAY_TeamUp_Corps_Friend) do
		local v = stm:getStatus(va.gid)
		if v ~= nil then               
			va.online = v.online;
			va.teamState = v.teamState;
			va.currentTeamAmount = v.currentTeamAmount;
			va.maxTeamAmount = v.maxTeamAmount;
			va.timeSinceGameBegin = os.time() - v.timeSinceGameBeginStamp
			if FriendSystem.IsMyFriend(va.gid) then
				va.enableWatch = v.enableWatch;
			else
				-- 非好友，不开启观战
				va.enableWatch = 0;
			end
		end           
	end  
	--log_tree("BP_ARRAY_TeamUp_Corps_Friend ",BP_ARRAY_TeamUp_Corps_Friend,"Corps")
	--组队排序
	table.sort( BP_ARRAY_TeamUp_Corps_Friend, TeamUPFriendUI.SortCorpsMember);
	--log_tree("BP_ARRAY_TeamUp_Corps_Friend ddddddddd",BP_ARRAY_TeamUp_Corps_Friend);
	--刷新UI
	TeamUPFriendUI.UpdateCorpsData();
	if(BP_TeamUPFriendIsShow) and false == BP_Friend_Is_Show  then	
		LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "UpdateByCurrentType");		
	end
end

--刷新成员列表状态信息--- 这个应该要废弃了
function TeamUPFriendUI.UpdateCorpsMember(eventType, eventID, infos)	
	if eventType ~= EVENTTYPE_FRIEND then
		return;
	end

	if eventID ~= EVENTID_FRIEND_CORPS_STATE_UPDATE  then
		return;
	end

	log("TeamUPFriendUI.UpdateCorpsMember");
	--log_tree("infos aaaaaaaaaaa",infos);

   --更新成员的状态信息，用于组队好友那边数据同步
   for k,v in pairs(infos) do	
		for ka,va in pairs(BP_ARRAY_TeamUp_Corps_Friend) do
			if tonumber(va.gid) == tonumber(v.uid) then               
				va.online = v.online;
				va.teamState = v.teamState;
				va.currentTeamAmount = v.currentTeamAmount;
				va.maxTeamAmount = v.maxTeamAmount;
				va.timeSinceGameBegin = v.timeSinceGameBegin;
				if FriendSystem.IsMyFriend(v.uid) then
					va.enableWatch = v.enableWatch;
				else
					-- 非好友，不开启观战
					va.enableWatch = 0;
				end
			end           
		end        
	end
	--组队排序
	table.sort( BP_ARRAY_TeamUp_Corps_Friend, TeamUPFriendUI.SortCorpsMember);
	--log_tree("BP_ARRAY_TeamUp_Corps_Friend ddddddddd",BP_ARRAY_TeamUp_Corps_Friend);
	--刷新UI
	TeamUPFriendUI.UpdateCorpsData();
	if(BP_TeamUPFriendIsShow) and false == BP_Friend_Is_Show  then	
		LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "UpdateByCurrentType");		
	end	
end

--点击页签军团
function EventSwitchCorps()	
	CorpsMgr.GetCorpsMemberList();
end

--滚动的时候刷新数据
function EventCorpsFriendScrollChanged()
	if BP_TeamUp_Corps_Scroll_Start ~= 0 then		
		TeamUPFriendUI.UpdateCorpsData();
	end 	
	LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "UpdateCorpsList");
end

--设置房间状态为false
function EventSetEnterRoomWaitingFalse()
	BP_TeamUp_EnterRoomWaiting = false;
end

-- Add by Hogoliu 2018.5.3  处理是否显示好友预约Tips
function EventBlockReserveTips()
	TeamUPFriendUI.bShowReserveTipsPanel = false;	
	-- LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "HideReserveTips");
end
-- End

-- 进入观战界面
BP_TEAMUP_FRIEND_WATCH_ID = ""
function EventTeamUpFriendWatch()
	log("EventLobbyFriendWatch: BP_TEAMUP_FRIEND_WATCH_ID = "..tostring(BP_TEAMUP_FRIEND_WATCH_ID))
	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "5077").TextValue,
			Client.GetTableData("LocalizeRes", "501124").TextValue,
			function()
				LogicLobbyWatching.enter_battle_watch(BP_TEAMUP_FRIEND_WATCH_ID)
			end, nil)
end

-- 刷新观战开关
function EventCheckWatchingSwitch()
	BP_TEAMUP_FRIEND_IS_WATCHING_OPEN =  LogicLobbyWatching.IsWatchingOpen();
end

-- 查看官媒链接
function EventClickOfficialInfoBtn()
	log("EventClickOfficialInfoBtn()")
	--LuaClassObj.HandleUIMessage(bp_official_info, "ShowOfficialInfoPanel");
	OfficialInfoUI:OpenCreateOfficialInfoPanel()
end

BP_TeamUpFriend_Cur_Lobby_Skin_Id = 0;
--更新皮肤
function TeamUPFriendUI.UpdateLobbySkin(eventType, eventID, skinId)
	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		skinId = 10004
	end
	BP_TeamUpFriend_Cur_Lobby_Skin_Id = skinId;
	LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "UpdateLobbySkin");
end