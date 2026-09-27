LobbyChatEntranceUI = LobbyChatEntranceUI or
{
	isRoomVisible = true;
	isCorpsVisible = true;
	isCorpsShow = false;
}


function bp_chat_entrance_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_chat_entrance,
    {{Path="/Game/UMG/UI_BP/LobbyChat/LobbyChatEntrance_BP.LobbyChatEntrance_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_ENTRANCE_ZORDER}},
    {"Lobby"},
	false,
	bp_chat_entrance_OnModeSwitched ~= nil
  );

	EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, LobbyChatEntranceUI.UpdateLobbySkin);
end

--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
	
end

function EventSetInfo_Push()
end

BP_ChatEntranceValid = false;
BP_ChatEntranceNewSender = "";
BP_ChatEntranceNewMsg = "";
BP_ChatEntranceNewMsgAchievement = "";
BP_ChatEntranceNewChannel = 2;
BP_ChatFriendNewMsgCount = 0;
BP_ChatEntranceChatroomNewMsgCount = 0;
BP_ChatEntranceTeamed = false;
BP_ChatEntranceTickBufferList = false;
BP_ChatEntranceEnterRoom = false;
BP_ChatEntranceEnterCorps = false;

BP_ChatEntranceVoiceRoomId = "";
BP_ChatEntranceClearGID = "";

BP_ChatEntranceQuickMsgId = 0;
BP_ChatEntranceQuickMsgStr = "";

BP_ChatEntranceEnterWaitingRoom = false;
BP_ChatEntrance_New_Crops_Num = 0;



function bp_chat_entrance_OnModeSwitched(gamestatus)
	local status = string.lower(gamestatus);
	if _G._inCustomBattle and string.lower(gamestatus) == "lobby" then return end
	if "lobby" == status then
		log("init chat entrance" .. tostring(BP_ChannelType));
		
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIInit");
		
		LobbyChatSystem.Entry();
	elseif "login" == status then
		LobbyChatEntranceUI.Release()
		LobbyChatSystem.Release();	
	elseif "fighting" == status then
		pcall(function() LobbyChatSystem.EnterFight() end)
	else	
		LobbyChatEntranceUI.Release();		
		
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIRelease");
	end
end

function LobbyChatEntranceUI.Init()
	log("LobbyChatEntranceUI.Init")
	BP_ChatEntranceValid = true;	
	BP_ChatEntranceEnterCorps = CorpsBaseUI.isVisible;
	LobbyChatEntranceUI.RefreshTickBufferState();	
	LobbyChatEntranceUI.RefreshUnreadList(BP_ChatFriendNewMsgCount);
	LobbyChatEntranceUI.RefreshChatroomUnread(BP_ChatRoomNewMessageCount);
	
	if (true == BP_ChatEntranceEnterRoom and false == LobbyChatEntranceUI.isRoomVisible)
		or (true == LobbyChatEntranceUI.isCorpsShow and false == LobbyChatEntranceUI.isCorpsVisible)
		or CorpsBaseUI.isShow == true or RoleInfoUI.IsShow or RankUI.isShowing
	then
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIHide");			
	else		
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIShow");		
	end
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "RefreshEntrance");
end

function LobbyChatEntranceUI.InitVisibility(bLogicHide)
	log("LobbyChatEntranceUI.InitVisibility")
	BP_ChatEntranceValid = true;	
	
	LobbyChatEntranceUI.RefreshTickBufferState();	
	LobbyChatEntranceUI.RefreshUnreadList(BP_ChatFriendNewMsgCount);
	LobbyChatEntranceUI.RefreshChatroomUnread(BP_ChatRoomNewMessageCount);
	
	if (true == BP_ChatEntranceEnterRoom and false == LobbyChatEntranceUI.isRoomVisible) 
		or (true == LobbyChatEntranceUI.isCorpsShow and false == LobbyChatEntranceUI.isCorpsVisible)
		or TeamUPFriendUI.isContentShowing == true
		or (LeagueGameLobbyUI.IsShow == true and false == RoomWaitingUI.IsShow)
		or RoleInfoUI.IsShow
		or (RoomWaitingUI.IsShow and not RoomWaitingUI.IsShowChatEntrance)
	then
		if bLogicHide then
			LobbyChatLogic.CloseUI();
		end
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIHide");			
	else		
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIShow");		
	end	
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "RefreshEntrance");
end

function LobbyChatEntranceUI.Release()
	BP_ChatFriendNewMsgCount = 0;
	BP_ChatEntranceOpenMic = false;
	BP_ChatEntranceOpenMic = false;
	BP_ChatEntranceTickBufferList = false;
	BP_ChatEntranceEnterRoom = false;
	BP_ChatEntranceValid = false;
	LobbyChatEntranceUI.isRoomVisible = true;
	LobbyChatEntranceUI.isCorpsVisible = true;
	BP_ChatEntranceEnterWaitingRoom = false;
end

function LobbyChatEntranceUI.SetIsTeamUp(isTeamup)
	BP_ChatEntranceTeamed = isTeamup;
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "TeamStateChanged");
end

function LobbyChatEntranceUI.OnRoomModeChanged()
	BP_ChatEntranceEnterRoom = RoomUI.IsShow or RoomWaitingUI.IsShow;
	log("LobbyChatEntranceUI.OnRoomModeChanged()" .. tostring(RoomUI.IsShow) .. " " ..tostring(RoomWaitingUI.IsShow));
	--LuaClassObj.HandleUIMessage(bp_chat_entrance, "RoomStateChanged");
	BP_ChatEntranceEnterWaitingRoom = RoomWaitingUI.IsShow and BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id < 10000000;

	if false == BP_ChatEntranceEnterRoom then
		LobbyChatEntranceUI.isRoomVisible = true;
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "ShowBtnPanel");
	else
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "HideBtnPanel");
	end
	
	LobbyChatEntranceUI.InitVisibility(true);
end

function LobbyChatEntranceUI.SetIsRoomMode(is_room)
	BP_ChatEntranceEnterRoom = is_room;
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "RoomStateChanged");
end

function LobbyChatEntranceUI.SetInCorps(corps_show)
	LobbyChatEntranceUI.isCorpsShow = CorpsBaseUI.isVisible;	
	BP_ChatEntranceEnterCorps = CorpsBaseUI.isVisible;
	BP_ChatEntranceEnterRoom = RoomUI.IsShow or RoomWaitingUI.IsShow;
	log("LobbyChatEntranceUI.OnRoomModeChanged()2 " .. tostring(RoomUI.IsShow) .. " " ..tostring(RoomWaitingUI.IsShow));
	log("LobbyChatEntranceUI.SetInCorps" .. tostring(corps_show));
	--LuaClassObj.HandleUIMessage(bp_chat_entrance, "RefreshEntrance");
	
	if false == corps_show then
		LobbyChatEntranceUI.isCorpsVisible = true;
	end
	
	LobbyChatEntranceUI.InitVisibility(true);
end

function LobbyChatEntranceUI.ForceSetVisibility(visible)
	log("LobbyChatEntranceUI.ForceSetVisibility(visible)" .. tostring(visible));

	BP_ChatEntranceValid = true;	
	
	LobbyChatEntranceUI.RefreshTickBufferState();	
	LobbyChatEntranceUI.RefreshUnreadList(BP_ChatFriendNewMsgCount);
	LobbyChatEntranceUI.RefreshChatroomUnread(BP_ChatRoomNewMessageCount);
	
	if (visible == false) then		
		LobbyChatLogic.CloseUI();
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIHide");			
	else		
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIShow");		
	end	
	
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_entrance, "RefreshEntrance");
end

function LobbyChatEntranceUI.SetVisibility(visible)
	log("LobbyChatEntranceUI.SetVisibility(visible)" .. tostring(visible));
	
	BP_ChatEntranceEnterRoom = RoomUI.IsShow or RoomWaitingUI.IsShow;
	if true == BP_ChatEntranceEnterRoom then
		LobbyChatEntranceUI.isRoomVisible = visible;
	end
	
	LobbyChatEntranceUI.InitVisibility(true);
end

function LobbyChatEntranceUI.SetVisibilityCorps(visible)
	log("LobbyChatEntranceUI.SetVisibility(visible)" .. tostring(visible));
	
	if true == LobbyChatEntranceUI.isCorpsShow then
		LobbyChatEntranceUI.isCorpsVisible = visible;
	end
	
	LobbyChatEntranceUI.InitVisibility(true);
end

function LobbyChatEntranceUI.ClearSomeonesMsg(gid)
	if not BP_ChatEntranceValid then
		return;
	end

	BP_ChatEntranceClearGID = gid;
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "ClearSomeonesMsg");
end

function LobbyChatEntranceUI.ReceiveNewMsg(channel_type, msg_type, sender_name, voice_file, voice_length, chat_content, zone_id, self_msg, other)	
	if not BP_ChatEntranceValid then
		return;
	end

    -- 拼多多军团仅显示拼多多红点，不显示在主界面
    if channel_type == LobbyChatSystem.channelCorpsBargain then
        Bargain_Logic.OnGetNewMessage();
        return;
    end    
	
	-- 组队招募,自身延迟比较高时,过滤掉其他人发的招募信息
	if channel_type == LobbyChatSystem.channelTeamRecruit and false == self_msg then
		--取当前zone ip
		local zoneIp = "";
		for i,v in pairs(TeamUpSystem.ChooseZoneList) do
			if v.zone_id == zone_id then
				zoneIp = v.tpingsvr_ip;
			end
		end
		
		local serveryDelay = Client.GetServerDelay(zoneIp);
		if serveryDelay > LobbyChatSystem.maxTeamRecruitDelayTime then
			return
		end
	end

	BP_ChatEntranceNewSender = sender_name;
	
	if "" ~= voice_file then
		BP_ChatEntranceNewMsg = Client.GetTableData("LocalizeRes", 106016).TextValue .. chat_content;
	elseif LobbyChatSystem.teamRecruitMsgType == msg_type then
		if channel_type == LobbyChatSystem.channelTeamRecruit then
			if other ~= nil then
				local msg, mapdata =  FuncUtil.TeamRecruitMap(chat_content, other)
				BP_ChatEntranceNewMsg = Client.GetTableData("LocalizeRes", 110027).TextValue .. " " .. (msg or "");
			end
		else
			BP_ChatEntranceNewMsg = Client.GetTableData("LocalizeRes", 110027).TextValue .. " " .. chat_content;
		end
	elseif LobbyChatSystem.corpsRecruitMsgType == msg_type then
		local msgStr = DataMgr.GetMsgByID(410072);
		BP_ChatEntranceNewMsg = string.format(tostring(msgStr), tostring(chat_content));
	elseif LobbyChatSystem.roomRecruitMsgType == msg_type then
		BP_ChatEntranceNewMsg = DataMgr.GetMsgByID(110027) .. DataMgr.GetMsgByID(117067);		
	elseif 14 == msg_type then
		if other ~= nil then
			chat_content = string.format(FuncUtil.GetLocalizeResStr("5082"), tostring(other.title));
		end
		BP_ChatEntranceNewMsg = chat_content;
	else
		BP_ChatEntranceNewMsg = chat_content;
	end
	if channel_type == LobbyChatSystem.channelTopic or channel_type == LobbyChatSystem.channelTopic2 then
		BP_ChatEntranceNewChannel = 100
	else
		BP_ChatEntranceNewChannel = channel_type;
	end
end

function LobbyChatEntranceUI.RefreshUnreadList(message_count)
	if not BP_ChatEntranceValid then
		return;
	end
	
	local count = 0;
	for k, v in pairs(LobbyChatSystem.friendChatList) do
		count = v.newMessageCount + count;
	end
	
	BP_ChatFriendNewMsgCount = count;
	BP_ChatEntrance_New_Crops_Num = BP_CorpsNewMessageCount
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "YourFriendCalledYou");
end

function LobbyChatEntranceUI.RefreshChatroomUnread(count)
	if not BP_ChatEntranceValid then
		return;
	end	
	
	BP_ChatEntranceChatroomNewMsgCount = count;
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "ChatroomUnreadChanged");
	
	if 0 == count then
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "ChatroomUnreadCleared");
	else
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "ChatroomUnreadAppeared");
	end
end

function LobbyChatEntranceUI.RefreshTickBufferState()
	if not BP_ChatEntranceValid then
		return;
	end
	
	BP_ChatEntranceTickBufferList = (nil ~= LobbyChatSystem.chatBufferList and #LobbyChatSystem.chatBufferList > 0) or 
									(nil ~= LobbyChatSystem.chatRoomBufferList and #LobbyChatSystem.chatRoomBufferList > 0);
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "OnRefreshMsgBufferState");
end

function LobbyChatEntranceUI.OpenChatUI()
	EventOpenChatWindow();
    
    ClientSendBAReport(BP_BA_LOBBY_CHAT_PANEL, 0);
end

function LobbyChatEntranceUI.OnQuitCorps()
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_entrance, "ClearNewMsg");
end

function EventOpenChatUI()	
end

function EventOpenChatWindow()
	BP_ChatEntranceNewSender = "";
	BP_ChatEntranceNewMsg = "";
	BP_ChatEntranceNewChannel = 0;	
	
	--如果是从军团界面点击打开聊天，那么不要再检查是否打开个人信息界面
	BP_Corps_NeedReOpenRoleInfo = false;
	
	-- 房间内打开聊天消息,招募界面则显示房间招募
	if BP_IsRoomOwner then
		BP_OpenChatPanelFromRoom = true;
	else
		BP_OpenChatPanelFromRoom = false;
	end

	LobbyChatEntranceUI.Init()
	LobbyChatSystem:OpenUI();
end

function EventOpenFriendNewChat()
	LobbyChatSystem.OpenNewestFriendChat();
end

function EventTestQuitRoom()
	--GlobalChatVoice.QuitVoiceRoomOnDeactivate();	
	TeamUpSystem.ProcessChat();
	GlobalChatVoice.QuitRoomTemp();
end

function EventTestJoinGameRoom()
	--GlobalChatVoice.JoinVoiceRoomOnReactivate();
	local temp = {};
	table.insert(temp, 12045234);
	table.insert(temp, 954875721);
	table.insert(temp, 93939393);
	
	GlobalChatVoice.JoinGameVoiceRoom(temp);
	GlobalChatVoice.OnJoinGameVoiceRoom();
end

function EventPopMessageBuffer()
	LobbyChatSystem.PopBufferList();
end

function EventAchieveQuickMsgStr()
	if 0 == BP_ChatEntranceQuickMsgId then
		return;
	end

	BP_ChatEntranceQuickMsgStr = Client.GetTableData("LocalizeRes", BP_ChatEntranceQuickMsgId).TextValue;	
end

function EventSendTeamQuickMsg()
	if not BP_ChatEntranceValid then
		return;
	end		
	
	if not BP_ChatEntranceTeamed then
		return;
	end
	
	if 0 == BP_ChatEntranceQuickMsgId then
		return;
	end
	
	local msg = Client.GetTableData("LocalizeRes", BP_ChatEntranceQuickMsgId).TextValue;
	-- local msg = BP_ARRAY_LocalizeRes[BP_ChatEntranceQuickMsgId].TextValue;	
	LobbyChatSystem.on_chat_quick_msg(BP_ChatEntranceQuickMsgId);
end

function EventClickBtnRecruit()
	RecruitUI.ShowUI();
end

function EventClickBtnFriendList()
	TeamUPFriendUI.ShowFriendPanel();
end

--更新皮肤
BP_LobbyChatEntrance_Cur_Lobby_Skin_Id = 0;
function LobbyChatEntranceUI.UpdateLobbySkin(eventType, eventID, skinId)
	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		skinId = 10004
	end

	BP_LobbyChatEntrance_Cur_Lobby_Skin_Id = skinId;
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_entrance, "UpdateLobbySkin");
end