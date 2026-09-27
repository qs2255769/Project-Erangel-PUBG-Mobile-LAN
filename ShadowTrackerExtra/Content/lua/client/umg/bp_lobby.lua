-- 大厅UI
-- Safety init for offline mode (belt-and-suspenders with bp_login.lua)
LobbySystem = LobbySystem or {}
LobbySystem.LobbyMenuOpenStatus = LobbySystem.LobbyMenuOpenStatus or {}
LobbySystem.currentLobbyPlayerDataList = LobbySystem.currentLobbyPlayerDataList or {}

LobbyUI = LobbyUI or
{
    isMoreShow = false,
    lobbySkinTimer = {},
    lobbyForLeagueGameOpen = {},
    tActivityReddotTimer = 0,

    lastDay = -1,
    zeroPointTimer = nil,

    eSkinId =
    {
        defalute = 10006,
        halloween = 10002,
        iceandSnow = 10003,
        ResidentEvil = 10004,
        Anniversary = 10005,
        Rainforest = 10001,
    },
    
    isShowLeagueTips = false,
    countDownTimer = nil,
    countDownTime = 0,
    TimeToCountDown = 0,
    IsTimeToEnter = false,

    onButtonMysteriousShopClickDelegate = nil,
}


--玩家个人信息
BP_PlayerName = "";
BP_PlayerLevel = 1;
BP_PlayerGold = 0;
BP_PlayerTicket = 0;
BP_PlayerFpToken = 0;--炸猪令牌，目前只有日韩有
BP_PlayerExp = 0;
BP_PlayerUid = ""
BP_PlayerGender = 1
BP_PlayerIconUrl = ""
BP_Lobby_PlayerMaxRankLevel = 0
BP_PlayerQQVip = 0;
BP_Lobby_Role_Avatar_Frame = 0
BP_PlayerAliasID = 0;
BP_PlayerAliasTitle = "";
BP_PlayerAliasNation = "";

--大厅组队信息
BP_LobbyPlayerNum = 0;

--大厅模型是否显示
BP_LobbyPlayerShow = true;
BP_MallPlayerShow = true;

--大厅状态
BP_LobbyNetworkDelay = 0
BP_LobbyNetworkStatus = true
BP_CurrentMenuId = 0
BP_CurrentRedPointStatus = false
BP_LevelChange = false
BP_Lobby_RankChange = false
BP_CurrentMaxExp = 0
BP_Lobby_OpenShoporWardrobe = false
BP_Exciting_Party_Open = false  -- 刺激盛宴是否开启

BP_COLLECT_EQUIPMENT_Open = false --收集装备活动是否开启
BP_Free_Data_Open = false -- 免流状态
BP_XinyueRedPointSvrOpen = false -- 心悦红点状态
BP_FriendApplyMessageCount = 0 --好友申请消息条数

--大厅相机控制
BP_LobbyCameraSwitchLock = false;  -- 是否锁住大厅相机切换(针对组队时队友更换性别做处理)
BP_LobbyTargetCameraIndex = 0;
BP_LobbyTargetCameraBlendTime = 0;
BP_SystemTargetCameraSysName = "";
BP_SystemTargetCameraIndex = 0;
BP_SystemTargetCameraBlendTime = 0;

BP_ShowHeadportraitReddot = false; -- 头像红点
BP_UNKNOWPASS_IS_IN_CURRENT_SESSION = false; -- 是否在当前赛季
BP_UNKNOWPASS_PANEL_IS_ENABLE = true; -- 面板开关是否开启，默认开启
BP_UnknowPass_ShowReddot = false; -- 勇者令红点

BP_ShowPersonSpaceReddot = false; -- 个人空间红点

BP_NATION_SWITCH_UPDATED = false;
BP_NATION_ALL_SWITCH = false;
BP_NATION_BATTLE_SWITCH = false;
BP_NATION_RANK_SWITCH= false;

BP_CameraIdx = 0;
BP_IsShow = false;

BP_PutOnResId = 0; -- 请求穿戴的资源id
BP_PutOnRes_Isolated = false; -- 物品是否处于隔离状态(服务器独有物品)

BP_PutOnWeaponResId = 0; -- 请求穿戴的武器id(隔离状态下替换成默认的枪id)
BP_CurrentDay = 0;  --用于标记本地是哪天

BP_IsWardrobePutOnAvatar = false;  -- 是否是在仓库穿戴服装
EmulatorCheck_FirstinLobby = true -- 初次检查模拟器

BP_STRUCT_AvatarInfo =
{
    resID = 401999,
    colorID = 0,
    patternID = 0,
}

BP_ARRAY_AvatarList =
{
    BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo,
}

-- 创建模型信息
BP_STRUCT_SpawnPlayerData =
{
    gid = "",
    sex = 1,
    headId = 401999,
    index = 1,
    BP_ARRAY_AvatarList = _G.BP_ARRAY_AvatarList,
    weaponResId = 0,
    weaponSkinId = 0,
    bagSkinInsId = 0,
    headShow = 0,
}

-- 位置占用结构
BP_STRUCT_TransformUseList =
{
    index = 1,
    inUse = false,
}

-- avatar变更信息
BP_STRUCT_AvatarChange =
{
    gid = "",
    resId = 403000,
    colorID = 0,
    patternID = 0,
}

-- 光圈信息
BP_STRUCT_TeamUpRingsChange =
{
    teamMemberNum = 4,
    BP_ARRAY_CurrentTeamMemberGidList = {"1"}
}

-- 初始化标签
DataMgrInit = false
LobbyModeSwitched = false
EmulatorCheck_FirstinLobby = true

-- 组队玩家信息列表
BP_ARRAY_LobbyPlayerDataList =
{
    BP_STRUCT_SpawnPlayerData = _G.BP_STRUCT_SpawnPlayerData,
}

BP_STRUCT_ShopLimit = {
    Title = "",
    EndTime = "",
}

BP_STRUCT_ActivityBtnDisplay = {
    Priority = 1,
    ActivityName = "",
    IconPath = "",
    JumpUrl = "",
    StartTime = "",
    EndTime = "",
    StartTimeUTC =  0,
    EndTimeUTC = 0,
    ActivityType = 0,
    IsShowCountDownIcon = false,
}

BP_ARRAY_LobbyActivityBtnDisplayList =
{
    BP_STRUCT_ActivityBtnDisplay = _G.BP_STRUCT_ActivityBtnDisplay,
}
--当前时间标志
BP_Lobby_Mall_Cur_ServerTime = 0;
BP_Lobby_Mall_Hot_Point_IsShow = false;--商城大部分红点状态
BP_Lobby_Supply_RedDot = false;     --补给入口红点状态

BP_ARRAY_Lobby_Mall_Simple_List =
{
    id = 0,
}

-- 商城宝箱列表,小红点用
BP_ARRAY_LobbyStoreBoxList =
{
    id = 0,
}
BP_ARRAY_LobbyStoreBoxHotPoint =
{
    new = 0,
}

-- 商城礼包小红点
BP_ARRAY_LobbyStoreGiftBoxList =
{
    id = 0,
}
BP_ARRAY_LobbyStoreGiftBoxHotPoint =
{
    new = 0,
}

BP_Mall_Hot_Mystery_Isopen = false;
local Mall_Limit_INDEX = 13

--sami 播放声音文件路径
BP_Lobby_Play_Sound_Path = ""
BP_Lobby_Play_Sound_Uid = ""
BP_Lobby_Play_Sound_FromWhereType = 0;

BP_Lobby_LeagueStage = 0;

--大厅冰雪主题开关
BP_Lobby_BgIceThemeSwitch = false;
--生化危机开关
BP_Lobby_BgResidentEvilThemeSwitch = false;
--周年庆开关
BP_Lobby_BgAnniversaryThemeSwitch = false;
--大厅皮肤ID
BP_Lobby_CurSkinId = 0;

--zino 订阅小图标
BP_Lobby_IsShowPrimeImage = false;
-- 默认true 开启订阅 点击了 充值按钮后 变为false
BP_Lobby_IsFirstTimeShowPrime = true 

-- 潘多拉集合页按钮红点状态
BP_Lobby_Pandora_ActivityNavigatorRedPoint = false;

BP_Lobby_TeamUpEnterOpen = false

--角色开关
BP_Lobby_CharacterSwitch = false;


--商城气泡
BP_STRUCT_LobbyBubble = 
{
    StartTime = 0,
    EndTime = 0,
    Duration = 0,
    ItemID = 0,
    FromType = 0,
    LastClickServerTime = 0,
    Cdn = "",
    Jump = "",
}

BP_LobbyBubble_CurCdn = ""

BP_LobbyBubble_CurItemID = 0

BP_LobbyBubble_CurFromType = 0

--是否有新的亲密关系
BP_Lobby_HasNewIntimacy = false

-- 越南版战斗内18+标志开关
BP_Lobby_VNGMarkSwitch = false;

-- 是否显示研究所tips
BP_Lobby_LabTips_Show = false;

--注册Widget
function bp_lobby_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_lobby,
            {{Path="/Game/UMG/UI_Logic/Lobby/Lobby_Logic_BP.Lobby_Logic_BP_C", Container="Default", ZOrder=0}},
            {"Lobby"},
            false,
            bp_lobby_OnModeSwitched ~= nil
    );

    FaceSlapSystem.Init();
    AfterFightingSlapSystem.Init();
end

G_Index_In_Login = 0
--跳转到Lobby
function bp_lobby_OnModeSwitched(gamestatus)
    log("bp_lobby_OnModeSwitched gamestatus = " .. gamestatus);

    if _G._inCustomBattle and string.lower(gamestatus) == "lobby" then
        if _G.writeLog then _G.writeLog("OnModeSwitched: BLOCKED (Lobby in custom battle)") end
        return
    end
    if _G._inCustomBattle and _G.writeLog then
        _G.writeLog("OnModeSwitched: PASS (" .. gamestatus .. ") in custom battle")
    end

    _isInLobby = string.lower(gamestatus) == "lobby"
    if string.lower(gamestatus) == "lobby" then
        if _G.writeLog then _G.writeLog("OnModeSwitched: entered lobby mode") end

        log_shipping_client("jaysun [Login process]bp_lobby_OnModeSwitched begin");

        AvatarManager.Show()
        pcall(function() PetManager.Show() end)

        TeamAvatarManager.Init()

        --sami UIManager初始化
        UIManager.Init()

        JumpUtils.Init()

        if ActivtyShaoJiUI then ActivtyShaoJiUI.bRedDot = false end
        if BlackFridayUI then BlackFridayUI.bRedDot = false end
        if BioChemicalUI then BioChemicalUI.bRedDot = false end
        if DiscountFeverUI then DiscountFeverUI.bRedDot = false end
        
        LoadingUI.RefreshLoadPercent(1)
        log("gavin OnModeSwitched          in lobby!!!");

        --刷新双倍金币/经验卡信息
        LobbySystem.UpdateHasDoubleCard();

        -- Init player data and create character BEFORE UIShow (wardrobe needs depot populated)
        if _G.writeLog then _G.writeLog("OnModeSwitched: creating character") end
        local ok, err = pcall(function()
            LobbyUI:InitPlayerData()
            LobbyUI:CreateMyself()
        end)
        if not ok and _G.writeLog then
            _G.writeLog("OnModeSwitched: CreateMyself FAILED: " .. tostring(err))
        elseif ok and _G.writeLog then
            _G.writeLog("OnModeSwitched: CreateMyself succeeded")
        end

        -- Explicitly trigger InitHallDepotData to populate wardrobe items from BP_ARRAY_Drop
        pcall(function()
            if DataMgr and DataMgr.InitHallDepotData then
                DataMgr.InitHallDepotData({})
                if _G.writeLog then _G.writeLog("OnModeSwitched: InitHallDepotData called, items=" .. tostring(#DataMgr.arrayHallDepotItemInfo)) end
            end
        end)

        --显示LobbyUI
        LuaClassObj.HandleUIMessage(bp_lobby, "UIShow")

        --创建大厅UI后 处理 订阅红点
        if NewSubscribeSystem.DelayLobbyCreate then
            local rs = coroutine.resume(NewSubscribeSystem.DelayLobbyCreate)
            if not rs then
                log("no regist DelayLobbyCreate")
            end
        end

        --设置定时器
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "RefreshTimer")

        --设置电量及网络状态,电量走底层c++接口
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateBattery")
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateNetworkStatus")
        -- 察看刺激盛宴是否开启
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateExcitingPartyBtnState")


        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "InitialTranform")

        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "CheckLobbyHalloweenVehicle")

        
        LobbyModeSwitched = true

        ScrollNoticeSystem.Enter()
        pcall(function() LoginSystem.CheckWakeupDataForTeamup() end)
        pcall(function() UpdateLobbyTaskRedDot(TaskUI.GetTaskRedDot()) end)
        pcall(function() UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby")) end)
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "InitXinyueRedPoint")
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateHuatiRedPoint")
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateCollectEquipRedPoint")

        pcall(function() UpdateSettingRedPoint() end)
        
        --CreateRoleResetUI.RefresRedPoint()
        pcall(function() WardrobeSystem.UpdateLobbyHotDot() end)

        pcall(function() LobbyUI.HandleTheFirstChargeIcon() end)

        --每次回到大厅都需要判断是否展示战队赛的气泡提醒
        --LeagueGameSystem.LeagueGameStageReq()

        --LuckAirDropUI.IsInLobby = true;
        pcall(function() ExpressionUI.ShowNewsInfo() end) -- news显示
        --幸运空投入口
        pcall(function()
            if LuckAirDropUI.IsFinishFaceNotice then
                log("LuckAirDropUI.IsFshFaceNotice")
                LobbyUI:ShowLuckAirDropQuery()--幸运空投
            else
                LuckAirDropUI.RefreshData()
                LobbyUI:ShowLuckAirDropEntrance()   --大厅是否显示
            end
            LobbyChatEntranceUI.SetIsRoomMode(false);
            LobbyUI.SetGmButton();
        end)

        -- -1: refuse, 0: tips, 1: normal
        if (HasShowDeviceLimit == false) then
            LobbySystem.CheckDeviceTip();
        end

        if EmulatorCheck_FirstinLobby then
            local isEmulator = Client.IsEmulator();
            local isEmulatorNoChromoBook = Client.IsEmulatorWhenInit();

            if isEmulator then
                if isEmulatorNoChromoBook then
                    local title = Client.GetTableData("LocalizeRes", 101001).TextValue;
                    local tips = Client.GetTableData("LocalizeRes", 4051).TextValue;
                    CommonMessageBoxUI:ShowPanel(1, title, tips);
                else
                    local title = Client.GetTableData("LocalizeRes", 101001).TextValue;
                    local tips = Client.GetTableData("LocalizeRes", 6055).TextValue;
                    CommonMessageBoxUI:ShowPanel(1, title, tips);
                end
                EmulatorCheck_FirstinLobby = false
            end
        end

        local t = Timer.InsertTimer(1,
                function()
                    local is_lobby_show_red = ActivitySystem.HasActBtnRedPoint()
                    log("活动红点 bp_lobby_OnModeSwitched " .. tostring(is_lobby_show_red))
                    UpdateLobbyActivityRedPoint(is_lobby_show_red)
                end, false, true);

        --sami 延迟1s拉取商城出售信息 AVATOR_INDEX,WEAPON_INDEX
        local t = Timer.InsertTimer(1,
                function()
                    ProfileMgr.GetProfileList({DataMgr.roleData.uid});
                end, false, true);

        -- 延迟5s拉取离线消息数量
        local t = Timer.InsertTimer(5,
                function()
                    -- 拉取h5商城数据
                    StoreIndiaUtils.ReqH5Market()
                    --JumpUtils.RequestJumpMapInfo();--改到登录就拉取，不然5秒之前点拍脸图不会正常跳转
                    if not GlobalData.IsJapanOrKorea() then
                        StoreSystem.GetTabList(StoreSystem.store_tab);
                    end
                    StoreSystem.GetTabList(StoreSystem.supply_tab)
 
                    LobbyChatSystem.req_get_offline_chat_msg_num()
                end, false, true);

        -- 延迟3s拉取GM面板 
        local GMtimer = Timer.InsertTimer(1,
                function()
                    LobbySystem.query_gm_request();
                    LoginSystem.isCanDeleteOp = true;--设置下删号状态
                end, false, true);
        -- 延迟2s拉取头像框信息
        local tAvatarBox = Timer.InsertTimer(2,
                function()
                    RoleInfoAvatarFrameSystem.get_avatar_box_list()
                    RoleInfoHeadportraitSystem.get_headportrait_list()
                end, false, true);

        UnknowPassSystem.upass_get_season_info_req();
        LobbyUI:RefreshUnknowPassButton();

        --初始化宠物配置表
        local PetSystem = require("client.slua.logic.pet.logic_pet")
        PetSystem.InitPetFromTable()
        WardrobeUI.RefreshPetRedPoint()

        BP_Lobby_CharacterSwitch = LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_CHARACTER, false)
        if BP_Lobby_CharacterSwitch then
            WardrobeUI.RefreshCharacterRedPoint()
        end

        --检查模拟器
        LobbyUI.CheckEmulatorTip();
        
        --设置皮肤
        pcall(function() LobbyUI.SetLobbySkin(); end)
        
        --不放回抽奖入口检测
        LuckyUnbackUI.IsLobbyOpen()
        LobbyUI.CheckLuckyBackEnterOpen()
        
        --极寒模式入口检测
        LobbyUI.IsTeamUpEnterOpen()
        
        --检查是否是赛事比赛打完
        Timer.RemoveTimer(LobbyUI.lobbyForLeagueGameOpen);
        LobbyUI.lobbyForLeagueGameOpen = Timer.InsertTimer(0.5,
                function()
                    LobbyUI.CheckLeagueGameSubMode();
                    IndiaCompetitionIntroduceUI.UpdateRedPoint()
                end, false, true);

        LobbyUI.tActivityReddotTimer = Timer.InsertTimer(1,
                function()
                    --下面方法已优化，勿动
                    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
                    ActivtyShaoJiUI.UpdateExchangeRedpoint()
                    BlackFridayUI.UpdateRedPoint()
                    --BioChemicalUI.UpdateRedPoint()
                    --DiscountFeverUI.UpdateRedPoint()
                    LuckyUnbackUI.UpdateRedPoint()
                    LuckybackActivitySystem.IsShowRedPoint()
                    
                end, true, false);


        --拉取首充数据
        ActivitySystem.get_season_recharge_info_req(true);
		
		
		--越南版标志刷新
		if Client.GetPublishRegion() == "VNG" and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_VNG_OPENMARK] ~= nil then
			log("LobbySystem.on_fetch_label_switch_res BP_ENUM_VNG_OPENMARK = " .. LobbySystem.LobbyMenuOpenStatus[BP_ENUM_VNG_OPENMARK].is_open)
			BP_Lobby_VNGMarkSwitch = (LobbySystem.LobbyMenuOpenStatus[BP_ENUM_VNG_OPENMARK].is_open == 1);
			LuaClassObj.HandleUIMessage(bp_lobby, "SetVNGMarkSwitch");
		end

        --首冲入口刷新
        if Client.GetPublishRegion() == "VNG" and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_VNG_OPENMARK_Lobby] ~= nil then
            log("LobbySystem.on_fetch_label_switch_res BP_ENUM_VNG_OPENMARK = " .. LobbySystem.LobbyMenuOpenStatus[BP_ENUM_VNG_OPENMARK_Lobby].is_open)
            BP_Lobby_VNGMarkSwitch = (LobbySystem.LobbyMenuOpenStatus[BP_ENUM_VNG_OPENMARK_Lobby].is_open == 1);
            LuaClassObj.HandleUIMessage(bp_lobby, "SetVNGMarkSwitch");
        end
        --检查是否完成，完成就关闭入口
        --TheFirstChargeUI.CheckIsFinished();
        --拉取数据检查小红点
        --TheFirstChargeUI.CheckFirstChargeRedDot();
        
        --注册商品数量变化通知
        EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, LobbyUI.DepotDataChange)

        --刷新大厅神秘商店入口
        LobbyUI.UpdateMysteriousShopEnter();
        LobbyUI.RefreshMysteriousShopRedPoint();

        --弹出角色升级面板
        local CharacterNetSystem = require("client.slua.logic.character.net_character")
        CharacterNetSystem.ShowCharacterLevelUpView()
        log_shipping_client("jaysun [Login process]bp_lobby_OnModeSwitched end");

        LobbyUI.CheckShowComeBack()
        LobbySystem.on_championship_info_notify(LobbySystem.RedPointInfo)
    else
        if LobbyUI.tActivityReddotTimer ~= 0 then
            Timer.RemoveTimer(LobbyUI.tActivityReddotTimer)
            LobbyUI.tActivityReddotTimer = 0
        end

        if LobbySystem.redTimer then
            Timer.RemoveTimer(LobbySystem.redTimer)
            LobbySystem.redTimer = nil
        end

        --解注册商品数量变化通知
        EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, LobbyUI.DepotDataChange)
    end

    -- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
        local PetSystem = require("client.slua.logic.pet.logic_pet")
        PetSystem.Reset()
        TeamAvatarManager.Destroy()
        AvatarManager.Hide()
        PetManager.Hide()
        --songGT ver devide，暂时屏蔽掉，转移到资源下载结束后调用一次
        --LobbyUI:ReleaseData()

        --第一次进入时更新进入，初始化逻辑延后到更新完成
        if G_Index_In_Login > 0 then
            LobbyUI:ReleaseData()
            G_Index_In_Login = G_Index_In_Login + 1
        end
    elseif string.lower(gamestatus) == "fighting" then
        if _G.writeLog then _G.writeLog("OnModeSwitched: fighting path — cleaning lobby widgets") end
        pcall(function() TeamAvatarManager.Destroy() end)
        pcall(function() AvatarManager.Hide() end)
        pcall(function() PetManager.Hide() end)
        pcall(function() AfterFightingSlapSystem.BeginShow() end)
        pcall(function()
            local drop_util = require("client.common.drop_util")
            drop_util.ReleaseCache()
        end)
        pcall(function() Client.StopH5Downloading() end)
    elseif string.lower(gamestatus) == "lobby" then
        local ComeBackMgr = require("client.slua.logic.come_back.come_back_mgr")
        ComeBackMgr.InitTaskTable()
        local ComeBackSystem = require("client.slua.logic.come_back.logic_come_back")
        ComeBackSystem.PopAfterFight()
    end

end

function LobbyUI.SetLobbySkin()
    local prevSkinId = BP_Global_Setting_LobbySkinId
    local curSkinId = BP_Global_Cur_Lobby_Skin_Id
    if _G.writeLog then _G.writeLog("SetLobbySkin: BEFORE — BP_Global_Setting_LobbySkinId=" .. tostring(prevSkinId) .. " BP_Global_Cur_Lobby_Skin_Id=" .. tostring(curSkinId)) end
    if not BP_Global_Setting_LobbySkinId or BP_Global_Setting_LobbySkinId == 0 then
        BP_Global_Setting_LobbySkinId = 10003
    end
    if _G.writeLog then _G.writeLog("SetLobbySkin: using skinId=" .. tostring(BP_Global_Setting_LobbySkinId)) end

    pcall(function() GlobalData.SaveLobbySkinID(); end)
    Timer.RemoveTimer(LobbyUI.lobbySkinTimer);
    LobbyUI.lobbySkinTimer = Timer.InsertTimer(0.5,
            function()
                if _G.writeLog then _G.writeLog("SetLobbySkin: switching to " .. tostring(BP_Global_Setting_LobbySkinId)) end
                pcall(function() GlobalData.SwitchLobbySkin(BP_Global_Setting_LobbySkinId); end)
                pcall(function() HallThemeUtils.ShowThemeVehicle() end)
            end, false, true);
end

function LobbyUI.DepotDataChange(eventType, eventID, vars)
    log("LobbyUI.DepotDataChange");
    --log_tree("LobbyUI.DepotDataChange:", vars);
    if vars ~= nil then
        for i,v in pairs(vars) do
            if v.res_id == LogicHalloweenVehicle.TicketId then --如果是载具升级券变化了
                LogicHalloweenVehicle.UpdateShowRedPoint()
            end
        end
    end
end

function LobbyUI.EnterUnknowPass()
    LuaClassObj.HandleUIMessage(bp_lobby, "ShowUnknowPassUI");
end

function LobbyUI.ShowUnknowPassSeasonLock()
    -- Force RP unlocked for offline mode
    BP_UNKNOWPASS_IS_IN_CURRENT_SESSION = true
    UnknowPassSystem.IsInCurSession = true
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowUPassSeasonLock");
end

function LobbyUI.SetGmButton()
    log("DataMgr.IsGmOpen = " .. tostring(DataMgr.IsGmOpen));
    if (DataMgr.IsGmOpen == true) then
        LuaClassObj.HandleUIMessage(bp_lobby, "ShowGmButton")
    else
        LuaClassObj.HandleUIMessage(bp_lobby, "HideGmButton")
    end
end

function EventFetchInfo()

end

--是时候检查转盘入口开启
function LobbyUI.CheckLuckyBackEnterOpen()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateLuckyBackEnter")
end

--转盘活动入口开启
function LobbyUI.IsLuckyBackEnterOpen()
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        local actId = ActivitySystem.CheckActivityIsOpenByType(ActivityType["LUCKY_UPGRADE"], 0)
        if actId == -1 then
            return false
        else
            --local imagePath = ActivitySystem.activityDataTable[actId].cfg.activity_image_link
            return true
        end
    else
        local actId = ActivitySystem.CheckActivityIsOpenByType(ActivityType["LUCKYBACK"], 1)
        log("LobbyUI.IsLuckyBackEnterOpen"..actId)
        local now = FuncUtil.GetServerTimeInSec()
        if actId == -1 or now < 1560988800 then  --在6月22号之前的哥斯拉转盘是不开启大厅右上入口的，不好的写法
            return false
        else
            --local imagePath = ActivitySystem.activityDataTable[actId].cfg.activity_image_link
            return true
        end
    end
end

--点击大厅右上角入口打开转盘活动
function EventLobbyOpenHalloweenVehicleActivity()
    log("EventLobbyOpenHalloweenVehicleActivity")
    local region = Client.GetPublishRegion()
    if region == "JAPAN" or region == "KOREA" then    --日韩直接进入载具升级
        HalloweenVehicleSkinUI.ShowUI()
    else
        local actId = ActivitySystem.CheckActivityIsOpenByType(ActivityType["LUCKYBACK"], 1)
        local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
        LuckybackActivitySystem.OpenUIWithActId(actId)
    end
    ClientSendTLogReport(BP_BA_EXPOSURE_ENTRANCE, nil, GemReportUtils.SubEventName_LobbyFixedEntranceLuckyBack)
end

--万圣节载具活动是否开启
function LobbyUI.HalloweenVehicleActivityIsOpen()
    if _isInLobby == false then
        return false
    end

    local activityType;
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        activityType = ActivityType["HALLOWEEN_VEHICLE_KR"];--
    else
        activityType = ActivityType["HALLOWEEN_VEHICLE"];--
    end

    if LobbySystem.activityDisplayDataList == nil then
        --log("LobbySystem.activityDisplayDataList == nil");
        return false
    end

    for _, activity in ipairs(LobbySystem.activityDisplayDataList) do
        if activity.ActivityType == activityType then
            local now = FuncUtil.GetServerTimeInSec()
            if activity.StartTimeUTC < now and activity.EndTimeUTC > now then
                --log("activity.StartTimeUTC < now and activity.EndTimeUTC > now")
                return true
            end
        end
    end
    --log("other is false")
    return false
end

function LobbyUI.AnniversaryActivityIsOpen()
    if _isInLobby == false then
        return false
    end

    local activityType;
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        activityType = ActivityType["ANNIVERSARY_KR"];--
    else
        activityType = ActivityType["ANNIVERSARY"];--
    end

    if LobbySystem.activityDisplayDataList == nil then
        return false
    end

    for _, activity in ipairs(LobbySystem.activityDisplayDataList) do
        if activity.ActivityType == activityType then
            local now = FuncUtil.GetServerTimeInSec()
            if activity.StartTimeUTC < now and activity.EndTimeUTC > now then
                return true
            end
        end
    end
    return false
end

-- 更新网络延迟
function LobbyUI:UpdateNetworkDelay()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateNetworkStatus")
end


local function lobbyEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_LOBBY then
        return;
    end

    if eventID == EVENTID_ENTERLOBBY then
        log("enter lobby!");
        if LuaClassObj ~= nil then

            LuaClassObj.HandleUIMessage(bp_global, "EnterLobby");
        end
    end
end

local function CheckIfOpenRankUpPanel()
    -- 在大厅中时不弹出段位升级面板
    if string.lower(LuaClassObj.GetGameStatus(bp_lobby)) == "lobby" then
        return
        --[[BP_Lobby_RankChange = true
        LevelUpUI:Init()
        BP_Lobby_RankChange = false]]
    else
        BP_Lobby_RankChange = true
    end
end

-- 玩家属性变更
local function PlayerDataChange(eventType, eventID, vars)
    log("PlayerDataChange "..eventType)
    if eventType ~= EVENTTYPE_DATA_MGR then
        return;
    end

    -- 更新大厅显示数据
    LobbyUI:RefreshPlayerData()

    if eventID == EVENTID_DATAMGR_GOLD_CHANGE then
        log("EVENTID_DATAMGR_GOLD_CHANGE");

    elseif eventID == EVENTID_DATAMGR_ROLE_LEVEL_CHANGE then
        log("EVENTID_DATAMGR_ROLE_LEVEL_CHANGE");

        -- 在大厅中时弹出军衔升级面板
        if string.lower(LuaClassObj.GetGameStatus(bp_lobby)) == "lobby" then
            log("remm levelup lobby direct popup")
            BP_LevelChange = true
            --LevelUpSystem.IsLevelUp = true;
            LevelUpUI:Init()
            --LevelUpSystem.OpenLevelupPanel(vars)
            BP_LevelChange = false
            UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
            --更新下天命锁显示
            TeamUpUI.ProcessDestinyLock();
        else
            log("remm levelup lobby BP_LevelChange true")
            BP_LevelChange = true
            --LevelUpSystem.IsLevelUp = true;
        end

    elseif eventID == EVENTID_DATAMGR_ROLE_EXP_CHANGE then
        log("EVENTID_DATAMGR_ROLE_EXP_CHANGE");

        --[[elseif eventID == EVENTID_DATAMGR_ROLE_SOLO_SEG_CHANGE then
            log("EVENTID_DATAMGR_ROLE_SOLO_SEG_CHANGE");
            --BP_LevelUp_RankTypeName = "单人模式"
        BP_LevelUp_RankTypeName = Client.GetTableData("LocalizeRes", "110049").TextValue
            BP_LevelUp_RankType = 1
            CheckIfOpenRankUpPanel()
    
        elseif eventID == EVENTID_DATAMGR_ROLE_DOUBLE_SEG_CHANGE then
            log("EVENTID_DATAMGR_ROLE_DOUBLE_SEG_CHANGE");
            --BP_LevelUp_RankTypeName = "双人模式"
        BP_LevelUp_RankTypeName = Client.GetTableData("LocalizeRes", "110050").TextValue
            BP_LevelUp_RankType = 2
            CheckIfOpenRankUpPanel()
    
        elseif eventID == EVENTID_DATAMGR_ROLE_TEAM_SEG_CHANGE then
            log("EVENTID_DATAMGR_ROLE_TEAM_SEG_CHANGE");
            --BP_LevelUp_RankTypeName = "四人模式"
        BP_LevelUp_RankTypeName = Client.GetTableData("LocalizeRes", "110051").TextValue
            BP_LevelUp_RankType = 4
            CheckIfOpenRankUpPanel()]]
    elseif eventID == EVNETID_DATAMGR_ROLE_RANK_CHANGE then
        log("EVNETID_DATAMGR_ROLE_RANK_CHANGE")
        CheckIfOpenRankUpPanel()

    elseif eventID == EVENTID_DATAMGR_PVE_LEVEL_CHANGE then
        log("EVENTID_DATAMGR_PVE_LEVEL_CHANGE:" .. tostring(vars));

        -- 在大厅中时弹出PVE升级面板
        if string.lower(LuaClassObj.GetGameStatus(bp_lobby)) == "lobby" then
            LevelUpSystem.IsPveLevelUp = true;
            LevelUpSystem.OpenPveLevelupPanel(vars)
        else
            log("pve levelup lobby BP_LevelChange true")
            LevelUpSystem.IsPveLevelUp = true;
        end
    end
end

-- 登出、重连返回登录清除数据
local function ReleaseAllData(eventType, eventID, vars)
    log("ReleaseAllData "..eventType)
    if eventType ~= EVENTTYPE_LOGIN then
        return;
    end

    if eventID == EVENTID_BACKLOGIN then
        log("ReleaseAllData");
        LobbyUI:ReleaseData()

        --成就浮窗 重新登录后，会再次打开
        AchievementFloatTipUI.HasClickedIngore = false
        
        --重新登录再次显示倒计时
        LobbyUI.isShowLeagueTips = false;

        -- 免流没有bp，在这里处理
        FreeDataStreamMgr:ClearFreeDataStatus()
    end
end

-- 清除数据
function LobbyUI:ReleaseData()
    log("lobby release data")
    DataMgr.ResetData()
    LobbySystem.currentLobbyPlayerDataList = {}
    BP_LobbyPlayerNum = 0;
    BP_LobbyNetworkStatus = true
    BP_LevelChange = false
	LevelUpSystem.IsLevelUp = false;
    LevelUpSystem.IsPveLevelUp = false;
    BP_Lobby_RankChange = false
    --DataMgrInit = false
    LobbyModeSwitched = false
    ScrollNoticeUI:BackLoginReleaseData()
    FaceSlapSystem.Reset();
    LuaClassObj.HandleUIMessage(bp_lobby, "ReleaseData")
    LobbyUI.isMoreShow = false
    UIReflux.ResetData();
    RoleInfoAvatarFrameSystem.ResetData();
    RoleInfoHeadportraitSystem.ResetData();
    TeamUpMatchInfoUI.ResetMapDownloaderInfo();
    GlobalData.ResetLobbySkinStatus();
    PDD_System_UI.Release();
    IMSDKNoticeUI.Release();
    StoreSystem.ResetData();
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice");
    ActorVoiceSystem.ResetVoiceData();
end

-- 当更换服务器时，隔离服务器不应该存在的物品(avatar,gun)
-- 组队时队友的替换也在这里触发
function LobbyUI.HandleItemIsolate( )
    -- 是否存在需要隔离的物品
    local bIsolate = false;
    if DataMgr.rolewear then
        for k,v in pairs(DataMgr.rolewear) do
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            if itemInfo ~= nil then
                if WardrobeSystem.IsItemIsolated( itemInfo.resID ) then
                    bIsolate = true;
                    break;
                end
            end
        end
    end

    if not bIsolate then
        local weaponId = DataMgr.GetCurrentWeaponID()
        if WardrobeSystem.IsItemIsolated( weaponId ) then
            bIsolate = true;
        end
    end

    if not bIsolate then
        local parachuteId = DataMgr.parachute;
        local itemInfo = DataMgr.GetHallDepotItemDataByInsID(parachuteId);
        if itemInfo then
            if WardrobeSystem.IsItemIsolated( itemInfo.resID ) then
                bIsolate = true;
            end
        end
    end

    if not bIsolate then
        local planeSkinInsID = DataMgr.planeSkinInsID;
        local itemInfo = DataMgr.GetHallDepotItemDataByInsID(planeSkinInsID);
        if itemInfo then
            if WardrobeSystem.IsItemIsolated( itemInfo.resID ) then
                bIsolate = true;
            end
        end
    end

    if not bIsolate then
        local glidingID = DataMgr.gliding;
        local itemInfo = DataMgr.GetHallDepotItemDataByInsID(glidingID);
        if itemInfo then
            if WardrobeSystem.IsItemIsolated( itemInfo.resID ) then
                bIsolate = true;
            end
        end
    end

    if not bIsolate then
        for k,v in pairs(DataMgr.vehicleSkinInsIDTable) do
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            if itemInfo then
                if WardrobeSystem.IsItemIsolated( itemInfo.resID ) then
                    bIsolate = true;
                    break;
                end
            end
        end
    end

    if not bIsolate then
        for k,v in pairs(DataMgr.equipmentSkinInsIDTable) do
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            if itemInfo then
                if WardrobeSystem.IsItemIsolated( itemInfo.resID ) then
                    bIsolate = true;
                    break;
                end
            end
        end
    end

    if bIsolate then
        -- 当前服务器不可使用物品已经卸下
        DataMgr.ShowNoticeByID(4986);
    end

    -- 脱下自己和队友的衣服，如果枪是隔离的重置的时候会自动替换成默认的枪，所以不用脱
    -- LobbyUI:ClearPlayerAvarar()
    -- LobbyUI:ResetAllPlayerAvatar()
    TeamAvatarManager.PutoffInvalidEquipments()
    -- 更新仓库的显示，隔离物品显示"不可使用"
    if WardrobeUI.isShowing then
        WardrobeUI:UpdateAvatarList()
    end
end

-- 针对从RP回到大厅时avatar的特殊处理
-- 因为RP和大厅公用一个模型，RP中不隔离，回到大厅隔离
-- 有疑问联系 seataoLi
function LobbyUI.HandleItemIsolateSelf( )
    -- 先脱
    if DataMgr.rolewear then
        for _,v in pairs(DataMgr.rolewear) do
            local itemData = DataMgr.GetHallDepotItemDataByInsID(v);
            if itemData then
                LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemData.resID), false);
            end
        end
    end

    -- 再穿
    local rolewear = {}
    for k,v in pairs(DataMgr.rolewear) do
        if (DataMgr.GetHallDepotItemDataByInsID(v) ~= nil) then
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            table.insert(rolewear, LobbyUI.CreateClientAvatarWearInfo(itemInfo.resID, itemInfo.colorID, itemInfo.patternID));
        end
    end
    local weaponID = DataMgr.GetCurrentWeaponID()

    if(DataMgr.head_show == 0 or DataMgr.head_show == DataMgr.GetEquipmentResID(DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex])) then
        table.remove(rolewear, 1);
    else
        DataMgr.head_show = 0;
    end

    BP_STRUCT_SpawnPlayerData =
    {
        gid = tostring(DataMgr.roleData.uid),
        sex = DataMgr.avatarData.gamegender,
        headId = DataMgr.avatarData.headid,
        index = 1,
        BP_ARRAY_AvatarList = rolewear,
        weaponResId = weaponID,
        weaponSkinId = 0,
        bagSkinInsId = DataMgr.GetEquipmentResID(DataMgr.BagSkinTableIndex),
        headShow = DataMgr.head_show,
    }
    log_tree("Reset BP_STRUCT_SpawnPlayerData", BP_STRUCT_SpawnPlayerData)
    -- LuaClassObj.HandleUIMessage(bp_lobby, "ResetPlayerAvatar");

    TeamAvatarManager.PutoffInvalidEquipments(BP_STRUCT_SpawnPlayerData)
end

function LobbyUI.HandleBroadcastInfo( )
    local LobbyHandler = RequireNetHandler("LobbyHandler")
    LobbyHandler.send_get_championship_info()
end

function LobbyUI.OnServerChange()
    LobbyUI.HandleItemIsolate( )
    LobbyUI.HandleBroadcastInfo()
end

function EventOpenBroadcast( )
    LobbyLeagueGameEntranceUI.Init();

    if WardrobeUI.isShowing then
        LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UIHide");
    end
end


function LobbyUI:Init()
    log_shipping_client("jaysun [Login process] lobby init");
    --LobbyUI:InitPlayerData()
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ENTERLOBBY, lobbyEventHandler);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_EXP_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_LEVEL_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_EXP_CHANGE, PlayerDataChange);


    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, ReleaseAllData);
    --EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_SOLO_SEG_CHANGE, PlayerDataChange);
    --EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_DOUBLE_SEG_CHANGE, PlayerDataChange);
    --EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_TEAM_SEG_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_RANK_CHANGE, PlayerDataChange);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY, LobbyUI.CloseOtherMenu);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyUI.WardRobeAvatarResetClose);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_INVITEJOIN, LobbyUI.OnInviteJoin);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PDD_BARGAIN, LobbyUI.OnClickBargainInfo);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LEAGUEGAME,LobbyUI.OnClickLeagueGame);

    --- 活动跳转
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_EXCITING_FEAST, LobbyUI.OnOpenExcitingFeast)
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_COLLECT_EQUIPMENT, LobbyUI.OnOpenCollectEquipment)
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_FRONTIER_AWARD, LobbyUI.OnOpenFrontierAward)
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SHARE_AWARD, LobbyUI.OnOpenShareAward)
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_OPENSERVICE_CARNIVAL, LobbyUI.OnOpenCarnival)
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BIND_FACEBOOK, BindFacebookUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_THEFIRSTCHARGE, TheFirstChargeUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON, TheFirstChargeUI.OnJumpUrlSeason);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BUY_UPASS_ACT, BuyUPassActUI.OnJumpUrl);

    --EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BUY_UNKNOW_PASS, UnknowPassBuy.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY_CORPS, EventOnClickCorps);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MONTH_CARD, WelfareMonthCardUI.ShowUI);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_REWARD_PKG, WelfareRewardPkgUI.ShowUI);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_SHAO_JI, ActivtyShaoJiUI.OpenFromUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BLACK_FRIDAY, BlackFridayUI.OpenFromUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BIOCHEMICAL_LUCKY, BioChemicalUI.OpenFromUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_DISCOUNT_FEVER, DiscountFeverUI.OpenFromUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_UNBACK, LuckyUnbackUI.OpenFromUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_BACK, LuckybackActivitySystem.OpenMainUI);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_BACK_VEHICLE, HalloweenVehicleSkinUI.ShowUI);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PDD, PDD_System_UI.OnJumpToPDDSystem);

    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_INVITE_TEAM, ActivityInviteTeamUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_TEAMUP_ENTER, EventTeamUpEnterEvilFromScene);

    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE, HalloweenVehicleTrickUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_ICE_LUCKY, IceLuckyGemUI.OnJumpUrl);

    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_LOBBY_MENU_PURCHASE, Direct_Purchase_By_Ativity_UI.InitData);
  	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_LOBBY_MENU_PURCHASE_BANNER, LobbyUI.ShowDirectPurchaseBanner);
    EventSystem:registEvent(EVENTTYPE_URL, BP_EMUM_MODULE_WEGAME, LobbyUI.OnGetWegameUrl);
    

    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR, LobbyUI.UpdateActivityBtnList)

    --EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_REFRESH_HOT, LobbyUI.OnGetMallHotInfo);--拉取月卡信息回调
    --EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST, LobbyUI.OnGetMallHotInfo);
    EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_ALL_SIMPLE_INFO, LobbyUI.OnGetMallHotInfo);
    EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_TAB_RES_UPDATE, LobbyUI.OnGetMallTabInfo);


    EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, LobbyUI.OnServerChange);
    EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_MATCH_ZONE_NOTIFY, LobbyUI.OnServerChange);

    EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, LobbyUI.OnLobbyNextDayHandler);
    EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, LobbyUI.OnStoreTabList);
    EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, LobbyUI.OnSupplyTabList);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, LobbyUI.OnActivityChange);

    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, LobbyUI.RefreshShowNewIntimacyMessage);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, LobbyUI.UpdateHeadportraitReddot);


    EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_OPEN_PANEL, LobbyUI.HideAirDropOnShowRoleinfo);
    EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_PANEL, LobbyUI.ShowAirDropOnHideRoleinfo);
    EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, LobbyUI.UpdateLobbySkin);

    

    --EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_PAY_NOTIFY,LobbyUI.MidasPayBackEventHandler);
    EventSystem:registEvent(EVENTTYPE_PANDORA, EVENTID_PANDORA_UPDATE_REDPOINT, LobbyUI.UpdateMysteriousShopRedPoint);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_INDIACOMP, EventLobbyLeagueGameEntranceEnterIndia);



    EventSystem:registEvent(EVENTTYPE_TASK, EVENTID_DATAMGR_BACKFLOWTASK_CHANGE, LobbyUI.CheckShowComeBack);

    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVNETID_ACTIVITY_REDDOT, LobbyUI.UpdateActivityBtnRedDot);
end

function LobbyUI:Release()
    log("lobby release");
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ENTERLOBBY, lobbyEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, PlayerDataChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, PlayerDataChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, PlayerDataChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_EXP_CHANGE, PlayerDataChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, PlayerDataChange);

    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_LEVEL_CHANGE, PlayerDataChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_EXP_CHANGE, PlayerDataChange);


    EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, ReleaseAllData);
    --EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_SOLO_SEG_CHANGE, PlayerDataChange);
    --EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_DOUBLE_SEG_CHANGE, PlayerDataChange);
    --EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_TEAM_SEG_CHANGE, PlayerDataChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_RANK_CHANGE, PlayerDataChange);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY, LobbyUI.CloseOtherMenu);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyUI.WardRobeAvatarResetClose);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_INVITEJOIN, LobbyUI.OnInviteJoin);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PDD_BARGAIN, LobbyUI.OnClickBargainInfo);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LEAGUEGAME,LobbyUI.OnClickLeagueGame);

    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_EXCITING_FEAST, LobbyUI.OnOpenExcitingFeast)
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_COLLECT_EQUIPMENT, LobbyUI.OnOpenCollectEquipment)
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_FRONTIER_AWARD, LobbyUI.OnOpenFrontierAward)
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SHARE_AWARD, LobbyUI.OnOpenShareAward)
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_OPENSERVICE_CARNIVAL, LobbyUI.OnOpenCarnival)
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BIND_FACEBOOK, BindFacebookUI.OnJumpUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_THEFIRSTCHARGE, TheFirstChargeUI.OnJumpUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON, TheFirstChargeUI.OnJumpUrlSeason);
    --EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BUY_UNKNOW_PASS, UnknowPassBuy.OnJumpUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BUY_UPASS_ACT, BuyUPassActUI.OnJumpUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY_CORPS, EventOnClickCorps);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MONTH_CARD, WelfareMonthCardUI.ShowUI);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_REWARD_PKG, WelfareRewardPkgUI.ShowUI);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_INVITE_TEAM, ActivityInviteTeamUI.OnJumpUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_SHAO_JI, ActivtyShaoJiUI.OpenFromUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE, HalloweenVehicleTrickUI.OnJumpUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY_ICE_LUCKY, IceLuckyGemUI.OnJumpUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_LOBBY_MENU_PURCHASE, Direct_Purchase_By_Ativity_UI.InitData);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BLACK_FRIDAY, BlackFridayUI.OpenFromUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BIOCHEMICAL_LUCKY, BioChemicalUI.OpenFromUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_DISCOUNT_FEVER, DiscountFeverUI.OpenFromUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_UNBACK, LuckyUnbackUI.OpenFromUrl);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_BACK, LuckybackActivitySystem.OpenMainUI);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LUCKY_BACK_VEHICLE, HalloweenVehicleSkinUI.ShowUI);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PDD, PDD_System_UI.OnJumpToPDDSystem);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_TEAMUP_ENTER, EventTeamUpEnterEvilFromScene);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_LOBBY_MENU_PURCHASE_BANNER, LobbyUI.ShowDirectPurchaseBanner);


    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR, LobbyUI.UpdateActivityBtnList)

    --EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_REFRESH_HOT, LobbyUI.OnGetMallHotInfo);
    --EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST, LobbyUI.OnGetMallHotInfo);
    EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_ALL_SIMPLE_INFO, LobbyUI.OnGetMallHotInfo);
    EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_TAB_RES_UPDATE, LobbyUI.OnGetMallTabInfo);

    EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, LobbyUI.OnServerChange);
    EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_MATCH_ZONE_NOTIFY, LobbyUI.OnServerChange);

    EventSystem:unregistEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, LobbyUI.OnLobbyNextDayHandler);
    EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, LobbyUI.OnStoreTabList);
    EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, LobbyUI.OnSupplyTabList);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, LobbyUI.OnActivityChange);

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, LobbyUI.RefreshShowNewIntimacyMessage);
    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, LobbyUI.UpdateHeadportraitReddot);

    EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_OPEN_PANEL, LobbyUI.HideAirDropOnShowRoleinfo);
    EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_PANEL, LobbyUI.ShowAirDropOnHideRoleinfo);
    EventSystem:unregistEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, LobbyUI.UpdateLobbySkin);
    --EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GETMPINFO_NOTIFY, LobbyUI.MidasMPEventHandler)

    --EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_PAY_NOTIFY,LobbyUI.MidasPayBackEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_PANDORA, EVENTID_PANDORA_UPDATE_REDPOINT, LobbyUI.UpdateMysteriousShopRedPoint);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_INDIACOMP, EventLobbyLeagueGameEntranceEnterIndia);

    EventSystem:unregistEvent(EVENTTYPE_TASK, EVENTID_DATAMGR_BACKFLOWTASK_CHANGE, LobbyUI.CheckShowComeBack);

    EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVNETID_ACTIVITY_REDDOT, LobbyUI.UpdateActivityBtnRedDot);
end

function LobbyUI.GetMallHotProto()
    ShopSystem.shop_itemlist_req(16);
    ShopSystem.shop_itemlist_req(17);
    MallSystem.GetShopIdListReq();
    MallSystem.Get2rdVerPageListReq()
end

function LobbyUI.OnGetMallHotInfo(eventType, eventID, vars)
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdateMallHotPoint");
end

function LobbyUI.OnGetMallTabInfo(eventType, eventID, vars)
    -- local pageResDict = vars[1];
    -- BP_Mall_Hot_Mystery_Isopen = false;
    -- for i,v in pairs(pageResDict) do
    -- 	if i == Mall_Limit_INDEX then
    -- 		BP_Mall_Hot_Mystery_Isopen = v.isOpen == 1;
    -- 	end
    -- end
    BP_Mall_Hot_Mystery_Isopen = MallSystem.IsTabOpen(Mall_Limit_INDEX);
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdateMallHotPoint");
end

-- 更新玩家数据
function LobbyUI:RefreshPlayerData()
    BP_PlayerName = DataMgr.roleData.nickName;
    BP_PlayerLevel = DataMgr.roleData.level;
    BP_PlayerGold = DataMgr.gold;
    BP_PlayerFpToken = DataMgr.fp_token;
    BP_Recharge = DataMgr.Recharge;
    BP_Registertime = DataMgr.registertime;
    if DataMgr.ticket ~= nil then
        BP_PlayerTicket = DataMgr.ticket;
    end

    BP_PlayerExp = DataMgr.roleData.roleExp;
    BP_PlayerUid = DataMgr.roleData.uid
    BP_PlayerGender = DataMgr.avatarData.gamegender
    BP_PlayerIconUrl = DataMgr.roleData.headIconUrl
    BP_Lobby_PlayerMaxRankLevel = DataMgr.GetMaxRankLevel()
    BP_PlayerQQVip = DataMgr.roleData.qq_vip
    BP_Lobby_Role_Avatar_Frame = DataMgr.roleData.cur_avatar_box_id
    BP_PlayerAliasID = DataMgr.roleData.alias.id;
    BP_PlayerAliasTitle = DataMgr.roleData.alias.title;
    BP_PlayerAliasNation = DataMgr.roleData.alias.nation;
    log("remm RefreshPlayerData".. BP_PlayerName .." " .. BP_PlayerGold .. " " .. BP_PlayerExp.."max rank ".. BP_Lobby_PlayerMaxRankLevel.." player ticket = ".. BP_PlayerTicket)
    LuaClassObj.HandleUIMessage(bp_lobby, "InitPlayerData")
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdatePlatformRight")
end

-- 初始化大厅UI显示数据
function LobbyUI:InitPlayerData()
    log("lobby initPlayerData")
    LobbySystem.currentLobbyPlayerDataList = {}
    BP_LobbyPlayerNum = 0

    LobbyUI:RefreshPlayerData()
end

-- 创建自己的模型
function LobbyUI:CreateMyself()
    local rolewear = {}
    WardrobeSystem.UpdateInvalidWearInfo(nil);

    for k,v in pairs(DataMgr.rolewear) do
        if (DataMgr.GetHallDepotItemDataByInsID(v) ~= nil) then
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            table.insert(rolewear, LobbyUI.CreateClientAvatarWearInfo(itemInfo.resID, itemInfo.colorID, itemInfo.patternID));
        end
    end
    --log_tree("remmm create avatar inst id", DataMgr.rolewear)
    --log_tree("remmm create avatar", rolewear)
    local avatarSt = {
        gamegender = DataMgr.avatarData.gamegender,
        headid = DataMgr.avatarData.headid,
        hairid = DataMgr.avatarData.hairid,
        beardid = DataMgr.avatarData.beardid,
        beardcolor = DataMgr.avatarData.beardcolorid
    }

    local weaponID = DataMgr.GetCurrentWeaponID()
    
    --sami 头盔穿戴逻辑
    local head_show = 0
    local bagInfo = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex]
    if bagInfo ~= nil then
        if bagInfo.head_show == 0 then
            local item = DataMgr.GetHallDepotItemDataByResID(rolewear[1])
            if item and item.itemSubType == WardrobeUI.wardrobeSubType_Hat then
                table.remove(rolewear, 1);
            end
        end
        if bagInfo.head_show == bagInfo.helmet_skin then
            table.remove(rolewear, 1)
            local originalResId = WardrobeSystem.GetItemResId(bagInfo.helmet_skin)
            head_show = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, originalResId)
        end
    end
    local bag_skin_resId = 0
    if bagInfo ~= nil then
        local originalResId = WardrobeSystem.GetItemResId(bagInfo.bag_skin)
        bag_skin_resId = DataMgr.GetEquipmentItemIDByResID(bagInfo.bag_level, originalResId)
    end
    
    local playerData =
    {
        gid = tostring(DataMgr.roleData.uid),
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = rolewear,
        weaponId = weaponID,
        weaponSkinId = 0,
        bagSkinInsId = bag_skin_resId,
        headShow = head_show or 0;
    }
    log_tree("playerData", playerData)

    LobbyUI:SpawnPlayer(playerData, true)
end

function LobbyUI.OnInviteJoin(eventType, eventID, vars)
    log("[HHF]LobbyUI.OnInviteJoin, eventType = " .. tostring(eventType) .. ", eventID = " .. tostring(eventID));
    log("[HHF]LobbyUI.OnInviteJoin, uid = " .. tostring(vars.uid) .. ", teamid = " .. tostring(vars.teamid));
    --log_tree("[HHF]LobbyUI.OnInviteJoin, vars = ", vars, "[HHF]");
    LobbyUI.CloseOtherMenu();

    if vars.teamid ~= nil and vars.uid ~= nil then
        if TeamUpSystem.TeamInfo ~= nil and TeamUpSystem.TeamInfo.leader == vars.uid and TeamUpSystem.TeamInfo.id == vars.teamid then
            log("[HHF]LobbyUI.OnInviteJoin, aready in the team!");
            return;
        end
        local source = vars.src or "facebook";
        TeamUpSystem.JoinTeamByChat(vars.uid, vars.teamid, source);
    end
end

function LobbyUI.OnClickBargainInfo(eventType, eventID, vars)
    log("[HHF]LobbyUI.OnClickBargainInfo, eventType = " .. tostring(eventType) .. ", eventID = " .. tostring(eventID));
    log("[HHF]LobbyUI.OnClickBargainInfo, uid = " .. tostring(vars.uid) .. ", orderid = " .. tostring(vars.orderid) .. ", name = " .. tostring(vars.name));
    --log_tree("[HHF]LobbyUI.OnInviteJoin, vars = ", vars, "[HHF]");
    LobbyUI.CloseOtherMenu();

    if vars.orderid ~= nil and vars.uid ~= nil and vars.name ~= nil then
        vars.name = Bargain_Detail_UI.URLDecode(vars.name);
        Bargain_Detail_UI.ShowDetailAfterClickChat(Bargain_Detail_UI.sns_application, vars.uid, vars.name, vars.orderid, nil);
    end
end

function LobbyUI.OnClickLeagueGame(eventType, eventID, vars)
    LeagueGameLobbyUI.Init();
end

function LobbyUI.CloseOtherMenu()
    LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu")
    EventTaskHideUI()
end

function LobbyUI:WardRobeAvatarResetOpen()
    log("WardRobeAvatarResetOpen")
    LobbyUI.isHideByAvatarReset = true;
    LuaClassObj.HandleUIMessage(bp_lobby, "UIHide");
    LuaClassObj.HandleUIMessage(bp_common_messagebox_panel, "UIHide")
end

function LobbyUI:WardRobeAvatarResetClose()
    log("WardRobeAvatarResetClose")
    LobbyUI.isHideByAvatarReset = false
    --设置 丛openbox 回到大厅的镜头设置
    if BP_LobbyPlayerNum > 1  then
        OpenBoxtUI.SetOpenBoxBackCamera(1);
    else
        OpenBoxtUI.SetOpenBoxBackCamera(0);
    end

    if WardrobeUI.saveIsShowing then
        log("WardrobeUI.saveIsShowing = true");
        LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromAvatarReset");
        --CreateRoleUI.OnOpenWardRobe();
        --LuaClassObj.HandleUIMessage(bp_createrole, "UIShowResetAvatar");
    end

    if RoleInfo_JumpResetAvatar == true then
        EventEnterRoleInfo();
        LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromAvatarReset");
        WardrobeUI.isShowing = true;
        EventHideWardrodbe();
        RoleInfo_JumpResetAvatar = false;
    end
end

--更新大厅pass入口红点
function LobbyUI:UpdateUnknowPassReddot(isShow)
    local bCurShow = false
    if BP_UNKNOWPASS_IS_IN_CURRENT_SESSION then
        bCurShow = UnknowPassUI.CanShowReddot() or isShow
    else
        bCurShow = false
    end
    --变化才刷新
    if bCurShow ~= BP_UnknowPass_ShowReddot then
        BP_UnknowPass_ShowReddot = bCurShow;
        LuaClassObj.HandleUIMessage(bp_lobby, "UpdateUnknowPassReddot");
    end
end

function LobbyUI:UpdateHeadportraitReddot()
    log("[HHF]LobbyUI:UpdateHeadportraitReddot");
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdateHeadportraitReddot");
end

-- 刷新通行证入口状态
function LobbyUI:RefreshUnknowPassButton()
    -- Force RP button enabled and unlocked for offline mode
    BP_UNKNOWPASS_PANEL_IS_ENABLE = true
    BP_UNKNOWPASS_IS_IN_CURRENT_SESSION = true
    UnknowPassSystem.IsInCurSession = true
    LuaClassObj.HandleUIMessage(bp_lobby, "RefreshUnknowPassButton");
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowUPassSeasonLock");
    --小红点刷新处理
    if BP_UnknowPass_ShowReddot then
        LuaClassObj.HandleUIMessage(bp_lobby, "UpdateUnknowPassReddot");
    end
end

function LobbyUI.EnterWarZone()
    --EventEnterWarzone();
end

function LobbyUI.RefreshHeadportraitReddot()
    BP_ShowHeadportraitReddot = RoleInfoHeadportraitSystem.HaveNewHeadportrait();
    if not BP_ShowHeadportraitReddot then
        BP_ShowHeadportraitReddot = RoleInfoAvatarFrameSystem.HaveNew(); -- 头像框有红点
    end
    -- if not BP_ShowHeadportraitReddot then
    --    BP_ShowHeadportraitReddot = AchievementSystem.HasRedpoint(); -- 个人成就系统有红点
    -- end
    if not BP_ShowHeadportraitReddot then
        BP_ShowHeadportraitReddot = RoleInfoAliasSystem.hasRedpoint(); --称号红点
    end

    BP_ShowPersonSpaceReddot = PersonSpaceSystem.HasIntimacyReddotAll(); --亲密拍档红点

    log("[HHF]EventHaveNewHeadportraitInLobby, have = " .. tostring(BP_ShowHeadportraitReddot) .. ",BP_ShowPersonSpaceReddot:" .. tostring(BP_ShowPersonSpaceReddot));
end

function EventHaveNewHeadportraitInLobby()
    LobbyUI.RefreshHeadportraitReddot()
end

--点击按钮请求进入房间
function EventEnterRoom()
    log("enter room");
    --RoomUI:Init();
    --RoomSystem.Enter();
    --LobbySystem.on_start_match_req(TeamUp_Team_Type);
end

-- 点击分解
function EventclickDecompose()
    log("EventclickDecompose")
    ItemDecomposeUI.Show();
end

-- 检测通行证能否被打开
function LobbyUI.CheckCanShowPass()
    -- Force-enable for offline mode (skip server switch + season date checks)
    BP_Lobby_MenuOpen = true;
    return true;
end

-- 通行证
function EventOpenUnknowPass()
    -- Hide lobby UI before opening RP panel
    pcall(function()
        local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
        if lobbyBP then
            lobbyBP:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
    end)
    UnknowPassUI.Init();
    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_Pass)
end

function EventShowUnknowPassIsNotInSession()
    UnknowPassSystem:PopErrorMsg(502015);
    --sami 增加拉取pass信息，也许新赛季开启了
    UnknowPassSystem.upass_get_req()
end

function EventOpenPDDSystem()
    log("[HHF]EventOpenPDDSystem");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_PDD_SYSTEM) then
        BP_Lobby_MenuOpen = false
        return
    end

    PDD_System_UI.Show();
    BP_Lobby_MenuOpen = true;

    ClientSendTLogReport(BP_BA_EXPOSURE_ENTRANCE, nil, GemReportUtils.SubEventName_LobbyFixedEntrancePDD)

    ClientSendBAReport(BP_ENUM_LOBBY_MENU_PDD_SYSTEM, 0);
end

--真.商城
function EventOpenMallSystem()
    if not GlobalData.IsJapanOrKorea() then
        if UIUtil.CanClickNow(ClickFrequencyLimit.LobbyBtn) == false then
            return;
        end
    end

    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MALL) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true;
    WardrobeUI.isShowing = false;
    
    --启用新版商城
    if not GlobalData.IsJapanOrKorea() then
        StoreMainUI.Init()
        OpenBoxtUI.SetOpenBoxBackCamera(3);
        GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_LobbyClickStore)
    else
        EventLobby_ClickSupply();
    end

    --设置新手
    local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, 1);
    if bNewbie then
        DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, 1);
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "MallHotPointUpdate");
    end

    ClientSendBAReport(BP_ENUM_LOBBY_MENU_MALL, 0);
end

-- 充值面板
function EventOpenEnchargePanel()
    log("EventOpenEnchargePanel")
    -- SignInSystem.Enter(false);

    RechargeUI:Init();
end

BP_LOBBY_AdjustURL = "";

function AdjustJumpTo(url)
    local s = string.find(url, tostring(BP_ENUM_MODULE_PDD_BARGAIN));
    if s ~= nil then
        if FaceSlapSystem.IsModuleShowedByModulID(BP_ENUM_MODULE_PDD_BARGAIN) == true then
            log("[HHF]AdjustJumpTo, url = " .. url .. ", immediately jump PDD.");
            BP_LOBBY_AdjustURL = "";
            GlobalData:JumpUrl(url);
        else
            log("[HHF]AdjustJumpTo, url = " .. url .. ", insert to FaceSlapSystem queue.");
            BP_LOBBY_AdjustURL = "";
            Bargain_Detail_UI.SetBargainURL(url);
        end
        return;
    end

    local s = string.find(url, tostring(BP_ENUM_MODULE_INVITE_COME_BACK));
    if s ~= nil then
        local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
        AssemblyActivitySystem.AdjustURL = url
        EventSystem:postLobbyEvent(EVENTTYPE_ASSEMBLY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE);
        return
    end

    local start = string.find(url, tostring(BP_ENUM_MODULE_INVITEJOIN));
    local wegameStart = string.find(url, tostring(BP_EMUM_MODULE_WEGAME));
    if start ~= nil or wegameStart ~= nil then
        log("[HHF]AdjustJumpTo, url = " .. url .. ", immediately jump.");
        BP_LOBBY_AdjustURL = "";
        GlobalData:JumpUrl(url);
    else
        log("[HHF]AdjustJumpTo, url = " .. url .. ", jump after lobby.");
        BP_LOBBY_AdjustURL = url;
    end
    --GlobalData:JumpUrl("game://?module=1002500");
end

--点击按钮进入商城-补给
function EventEnterShop()
    log("enter Shop");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SHOP) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    if ShopUI.isShow == false then
        BP_Lobby_OpenShoporWardrobe = true
        LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu")
        BP_Lobby_OpenShoporWardrobe = false
        
        pcall(function() OpenBoxtUI.SetOpenBoxBackCamera(3) end)
    end
    pcall(function() ShopUI.Init() end)
    pcall(function() ShopSystem.Enter() end)

    pcall(function() ClientSendBAReport(BP_BA_LOBBY_SHOP_PANEL, 0) end)
end
-- 进入车队
function EventLobbyEnterAlliance()
    log("EventLobbyEnterAlliance")
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ALLIANCE) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true

    AllianceSystem.OpenAllianceUI()

    ClientSendBAReport(BP_BA_LOBBY_ALLIANCE_PANEL, 0);
end
--点击进入邮件系统
function EventEnterMail()
    log("Enter Mail");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MAIL) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    MailSystem.Enter();
    MailUI.Init();

    ClientSendBAReport(BP_BA_LOBBY_MAIL_PANEL, 0);
end

--点击进入邮件礼物系统
function EventEnterMailGift()
    log("Enter MailGift");
    EventEnterMail();
    if not BP_Lobby_MenuOpen then
        return
    end
    if not ShopGiftMsgCenter.CheckLobbyMenuOpen(50005) then
        return
    end
    LuaClassObj.HandleUIMessage(bp_mail, "ShowGiftUI");
end

--点击进入赛季系统
function EventEnterSeason()
    log("Enter Season");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SEASON) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true

    SeasonUI.Show();

    ClientSendBAReport(BP_BA_LOBBY_SEASON_PANEL, 0);
end

BP_RankSavedChoosingZoneId = 0
function EventRankSavedChoosingZoneId_Push()
    BP_Back_ShowRankZoneId = BP_RankSavedChoosingZoneId
    log("EventRankSavedChoosingZoneId_Push:BP_Back_ShowRankZoneId = "..BP_Back_ShowRankZoneId)
end


--打开排行榜界面
function EventEnterRank()
    EventLobbyRankEntranceEnterRank();
end


--点击主界面排行榜按钮入口响应事件
function EventEnterLobbyNewRank()

    -- 面板开关检查
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_RANK) then
        return
    end

    --sami war
    if true then
        LobbyRankEntranceUI.Init();
    else
        LuaClassObj.HandleUIMessage(bp_lobby, "OpenRank");
    end

    if WardrobeUI.isShowing then
        LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UIHide");
    end
end

function LobbyUI.EnterWardrobe()
    log("enter Wardrobe isShowing:" .. tostring(WardrobeUI.isShowing ).." isPlayingOutAnim:"..tostring(WardrobeUI.isPlayingOutAnim));
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_WARDROBE) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    if WardrobeUI.isShowing == false then
        BP_Lobby_OpenShoporWardrobe = true
        LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu")
        BP_Lobby_OpenShoporWardrobe = false
    end
    WardrobeSystem.Enter(false);

    ClientSendBAReport(BP_BA_LOBBY_WARDROBE_PANEL, 0);
end

--点击按钮进入仓库
function EventEnterWardrobe()
    log("enter Wardrobe" .. tostring(WardrobeUI.isShowing )..tostring(WardrobeUI.isPlayingOutAnim));
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_WARDROBE) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    if WardrobeUI.isShowing == false then
        BP_Lobby_OpenShoporWardrobe = true
        LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu")
        BP_Lobby_OpenShoporWardrobe = false
    end
    WardrobeSystem.Enter(true);

    ClientSendBAReport(BP_BA_LOBBY_WARDROBE_PANEL, 0);
end

function EventOpenChatUI()
    log("open chat ui");
    LobbyChatLogic.Init();
end

-- 点击进入好友系统
function EventEnterFriendList()
    writeLog("EventEnterFriendList: entered");
    pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: entered") end)
    local ok1, err1 = pcall(function()
        if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_FRIEND) then
            writeLog("EventEnterFriendList: CheckLobbyMenuOpen blocked");
            pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: BLOCKED by menu") end)
            BP_Lobby_MenuOpen = false
            return
        end
    end)
    if not ok1 then
        writeLog("EventEnterFriendList: CheckLobbyMenuOpen CRASH: " .. tostring(err1))
        pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: CRASH " .. tostring(err1)) end)
        return
    end
    BP_Lobby_MenuOpen = true
    writeLog("EventEnterFriendList: calling Init");
    pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: calling Init") end)
    local ok2, err2 = pcall(function()
        LobbyFriendUI:Init();
    end)
    if not ok2 then
        writeLog("EventEnterFriendList: Init CRASH: " .. tostring(err2))
        pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: Init CRASH " .. tostring(err2)) end)
        return
    end
    writeLog("EventEnterFriendList: calling Show");
    pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: calling Show") end)
    local ok3, err3 = pcall(function()
        LobbyFriendUI:Show();
    end)
    if not ok3 then
        writeLog("EventEnterFriendList: Show CRASH: " .. tostring(err3))
        pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: Show CRASH " .. tostring(err3)) end)
        return
    end
    writeLog("EventEnterFriendList: done");
    pcall(function() Client.ShowScreenDebugMessage("FRIEND_BTN: done") end)

    pcall(function() ClientSendBAReport(BP_BA_LOBBY_FRIEND_PANEL, 0); end)
end
-- Save reference for Tick hook re-override (bp_lobby.lua may be reloaded)
_G._eventEnterFriendListImpl = EventEnterFriendList

-- 打开设置
function EventEnterConfig()
    log("enter setting ui");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SETTING) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    SettingUI:Init();

    ClientSendBAReport(BP_BA_LOBBY_SETTING_PANEL, 0);
end

--世界观弹窗
function EventOpenWorldView()
    log("Enter OpenWorldView");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_WORLDVIEW) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    PopUpNoticeUI.ShowMessageBox(LongTxt.WorldView_Title, LongTxt.WorldView_Content);

    ClientSendBAReport(BP_BA_LOBBY_WORLDVIEW_PANEL, 0);
end

function EventOpenGuidePanel()
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_HELP) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    GuideUI:Show()

    ClientSendBAReport(BP_BA_LOBBY_GUIDE_PANEL, 0);
end

BP_Lobby_IsActivityOpened = true;
function EventIsActivityOpened()
    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_ACTIVITY] == nil then
        BP_Lobby_IsActivityOpened = true;
    end

    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_ACTIVITY].is_open == 0 then
        BP_Lobby_IsActivityOpened = false;
    else
        BP_Lobby_IsActivityOpened = true;
    end

    log("[HHF]EventIsActivityOpened, BP_Lobby_IsActivityOpened = " .. tostring(BP_Lobby_IsActivityOpened));
end

function EventOpenActivityPanel()
    log("Enter Activity");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ACTIVITY) then
        BP_Lobby_MenuOpen = false
        return
    end
    log("open!!!!!!!!")
    --ActivtyUI.SetIsFromLobby();
    --BP_Lobby_MenuOpen = true
    --LuaClassObj.HandleDynamicCreation(bp_activty);
    --LuaClassObj.HandleUIMessage(bp_activty, "TryToShowActivty");
    --ActivtyUI.ResetShow();

    local uiManager = require("ui.manager");
    local ui = uiManager.ShowUI(uiManager.UI_Config.activity_center)
    ui:SetData()

    ClientSendBAReport(BP_BA_LOBBY_ACTIVITY_CENTER, 0);
end

--进入组队界面
function EventEnterTeamUp()
    log("Enter TeamUp");
    ---TeamUpSystem.Enter();
    --TeamUpUI.Init();
end


BP_RoleInfoSavedChoosingZoneId = 0
function EventRoleInfoSavedChoosingZoneId_Push()
    --BP_Back_ShowRoleInfoOfZoneId = BP_RoleInfoSavedChoosingZoneId
    --log("EventRoleInfoSavedChoosingZoneId_Push:BP_Back_ShowRoleInfoOfZoneId = "..BP_Back_ShowRoleInfoOfZoneId)
end

-- Hide lobby by directly setting widget visibility (bypasses ALL Blueprint events)
local function HideLobby()
    pcall(function()
        local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
        if lobbyBP then
            lobbyBP:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
    end)
    pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "UIHide") end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_lobby, "UIHide") end)
    pcall(function() EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN) end)
end

-- Show lobby by directly setting widget visibility back
local function ShowLobby()
    pcall(function()
        local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
        if lobbyBP then
            lobbyBP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
    end)
    pcall(function() LuaClassObj.HandleDynamicCreation(bp_teamup) end)
    pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "UIShow") end)
    pcall(function() FakeFriendSystem.RefreshNameplates() end)
end

-- Expose globally so other files can call them
LobbyUI.HideLobby = HideLobby
LobbyUI.ShowLobby = ShowLobby

-- 进入个人信息面板 (use original flow + offline fallbacks)
function EventEnterRoleInfo()
    log("Enter roleinfo")
    -- Hide lobby BEFORE roleinfo init (ensures it runs even if Init fails)
    HideLobby()
    pcall(function() RoleInfoSystem.CurShowPlayerInfoUid = tostring(DataMgr.roleData.uid) end)
    pcall(function() RoleInfoSystem.Enter(DataMgr.roleData.uid) end)
    pcall(function() RoleInfoUI.Init(true, RoleInfoOpenFromType.Lobby) end)
    -- Hide lobby AFTER roleinfo init (in case Init re-showed anything)
    HideLobby()
    -- Retry hide with delay (catches async re-shows)
    pcall(function()
        Timer.InsertTimer(0.1, function()
            HideLobby()
        end)
    end)
    pcall(function() LobbyUI:RefreshPlayerData() end)
    pcall(function()
        Timer.InsertTimer(0.5, function()
            local ok1, err1 = pcall(function()
                RoleInfoUI.UpdateRoleInfoTab()
            end)
            if _G.writeLog then _G.writeLog("UpdateRoleInfoTab result: " .. tostring(ok1) .. " " .. tostring(err1)) end
            pcall(function() TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_ROLEINFO) end)
            -- Final hide retry after data is ready
            HideLobby()
        end)
    end)
    pcall(function()
        Timer.InsertTimer(0.8, function()
            local ok2, err2 = pcall(function()
                RoleInfoUI.UpdateAliasInfo()
            end)
            if _G.writeLog then _G.writeLog("UpdateAliasInfo result: " .. tostring(ok2) .. " " .. tostring(err2)) end
        end)
    end)
    if _G.writeLog then _G.writeLog("EventEnterRoleInfo done") end
end

-- 进入分享
function EventClickDailyShareBtn()
    log("Enter EventClickDailyShareBtn")
    --ShareDayUI.ShowUI();
    ShareAwardUI.Show();
end

-- 进入签到
function EventEnterSigninSystem()
    log("Enter EventEnterSigninSystem")
    -- SignInSystem.Enter(false);
end

-- 打开收集装备
function LobbyUI.OnOpenCollectEquipment()
    LuaClassObj.HandleUIMessage(bp_lobby, "OnCollectEquipmentBtnClick")
end

-- 打开刺激盛宴
function LobbyUI.OnOpenExcitingFeast()
    --ExcitingPartyMgr.OpenUI()
end

-- 打开先锋好礼
function LobbyUI.OnOpenFrontierAward()
    LuaClassObj.HandleUIMessage(bp_lobby, "OpenFrontierAward")
end

-- 打开分享有礼
function LobbyUI.OnOpenShareAward()
    ShareAwardUI.Show();
end

-- 打开开服狂欢
function LobbyUI.OnOpenCarnival()
    EventOpenActivityGroupUI()
end


function LobbyUI.UpdateActivityBtnList()
    LobbySystem.QueryActivityDisplayStatus();
end

--midas 支付成功的消息
function LobbyUI.MidasPayBackEventHandler(evenType, eventID, result_code)

    log("[TAL]==主界面收到支付成功的消息 DataMgr.Recharge = "..DataMgr.Recharge)
    if (result_code == "0" or result_code == 0) and DataMgr.Recharge == 1  then
        DataMgr.Recharge = 0; --表示充值过了
        LobbySystem.refresh_activity_display_byMidas();
    end

end

---midas营销活动回调（刷新主界面右侧的活动显示列表）
function LobbyUI:MidasMPEventHandler(evenType, eventID, result_code)
    log("[TAL]===主界面收到米大师充值回调");
    LobbySystem.refresh_activity_display_byMidas();
end

BP_HasClickUPassAct = false;
----------购买UPass红点
function LobbyUI:HandleUPassActRedPoint()
    LuaClassObj.HandleUIMessage(bp_lobby, "GetIsClickUPassAct");
    --log("xzx BP_HasClickUPassAct = "..BP_HasClickUPassAct)

    if BP_HasClickUPassAct == false then--没有点击过,需要红点
        log("xzx BP_HasClickUPassAct = false")
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_BUY_UPASS_ACT, true);
    else --点击过,是否有未领取的奖励
        log("xzx BP_HasClickUPassAct = true")
        BuyUPassActUI.RefreshBuyData()--此函数会处理红点
    end
end

---------------------
--在大厅中，由于并没有创建 BindFacebook_Logic_BP, 所以调用不了这个蓝图里面的函数,只能在大厅里面获取这两个存储在本地的数据
BP_ClickTimeNotBind = 0; -- 未绑定时的点击时间
BP_ClickTimeBind = 0; -- 绑定时的点击时间

function LobbyUI:HandleBindActRedPoint()--是否要显示绑定按钮的红点
    LuaClassObj.HandleUIMessage(bp_lobby, "GetClickTimeAboutBind");
    log("BP_ClickTimeNotBind = "..BP_ClickTimeNotBind..", BP_ClickTimeBind = "..BP_ClickTimeBind);
    BindFacebookUI.RefreshBindData()
    BindFacebookUI.CheckRedPoint(BP_ClickTimeNotBind, BP_ClickTimeBind);
end

function LobbyUI:SetBindActClickTime(timeNotBind, timeBind)
    BP_ClickTimeNotBind = timeNotBind;
    BP_ClickTimeBind = timeBind;
    LuaClassObj.HandleUIMessage(bp_lobby, "SetClickTimeAboutBind")
    log("timeNotBind = "..timeNotBind..", timeBind = "..timeBind);
end

BP_HasClickInviteTeamAct = false;

function LobbyUI.HasClickInviteTeamAct()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "GetIsClickInviteTeamAct");
    return BP_HasClickInviteTeamAct
end
----------邀请组队活动
function LobbyUI:HandleInviteTeamActRedPoint()
    ActivityInviteTeamUI.RefreshData()--此函数会处理红点
end

BP_ClickTimeHalloweenVehicle = 0; --万圣节载具的点击时间
--是否点击了万圣节载具,每天更新
function LobbyUI.HasClickHalloweenVehicle()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "GetClickTimeHalloweenVehicle");
    if BP_ClickTimeHalloweenVehicle == 0 then
        return false
    else
        local CurrDateTb = os.date("*t", FuncUtil.GetServerTimeInSec())
        local ClickDateTb = os.date("*t", BP_ClickTimeHalloweenVehicle)
        return CurrDateTb.year == ClickDateTb.year and CurrDateTb.yday  == ClickDateTb.yday
    end
end
--更新点击时间
function LobbyUI.UpdateClickHalloweenVehicle()
    BP_ClickTimeHalloweenVehicle = FuncUtil.GetServerTimeInSec()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetClickTimeHalloweenVehicle");

    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE, LogicHalloweenVehicle.IsShowRedPoint());
end

BP_ClickTimeIceLucky = 0; --冰雪节的点击时间
--是否点击了冰雪节,每天更新
function LobbyUI.HasClickIceLucky()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "GetClickTimeIceLucky");
    if BP_ClickTimeIceLucky == 0 then
        return false
    else
        local CurrDateTb = os.date("!*t", FuncUtil.GetServerTimeInSec())
        local ClickDateTb = os.date("!*t", BP_ClickTimeIceLucky)
        return CurrDateTb.year == ClickDateTb.year and CurrDateTb.yday  == ClickDateTb.yday
    end
end
--更新点击时间
function LobbyUI.UpdateClickIceLucky()
    BP_ClickTimeIceLucky = FuncUtil.GetServerTimeInSec()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetClickTimeIceLucky");

    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_ICE_LUCKY, LogicIceLuckyGem.IsShowRedPoint());
end

BP_ClickTimeAnniversary = 0; --周年庆的点击时间
--是否点击了周年庆,每天更新
function LobbyUI.HasClickAnniversary()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "GetClickTimeAnniversary");
    if BP_ClickTimeAnniversary == 0 then
        log("====================false");
        
        return false
    else
        local CurrDateTb = os.date("!*t", FuncUtil.GetServerTimeInSec())
        local ClickDateTb = os.date("!*t", BP_ClickTimeAnniversary)
        local click = CurrDateTb.year == ClickDateTb.year and CurrDateTb.yday  == ClickDateTb.yday;
        log("======================click .. " .. tostring(click));
        return CurrDateTb.year == ClickDateTb.year and CurrDateTb.yday  == ClickDateTb.yday
    end
end

--更新点击时间
function LobbyUI.UpdateClickAnniversary()
    BP_ClickTimeAnniversary = FuncUtil.GetServerTimeInSec()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetClickTimeAnniversary");

    local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ANNIVERSARY, AnniversaryActivitySystem.IsShowRedPoint());
end


BP_Activity_Jump_Url = ""; --按钮的跳转按钮
BP_Activity_Icon_Path = ""; --按钮的图片
BP_Activity_IconShowTimes = 0;   --图片被展示次数
BP_Activity_Type = 0; --活动类型(目前供H5赛事活动用)

function EventHandleActivityBtn()
    log("xzx jumpUrl = "..BP_Activity_Jump_Url);
    if UIUtil.CanClickNow(ClickFrequencyLimit.LobbyBtn) == false then
        return;
    end

    if BP_Activity_Jump_Url then
        GlobalData:JumpUrl(BP_Activity_Jump_Url)
    end

    -- 打点
    if BP_Activity_Icon_Path ~= "" then
        local str = string.split(BP_Activity_Icon_Path, "/");
        local pngName = tostring(str[#str]);
        ClientSendBAReport(BP_BA_LOBBY_ACTIVITY_BANNER, BP_Activity_IconShowTimes, pngName);
        -- log("acitivty "..tostring(pngName).."  "..tostring(BP_Activity_IconShowTimes));
    end

    if(BP_Activity_Type == ActivtyUI.H5LeagueGameActivityID) then
        ActivitySystem.Req_DealActivity(ActivtyUI.H5LeagueGameActivityID, 1, 0);
    elseif BP_Activity_Type == ActivtyUI.KR_H5LeagueGameActivityID then
        ActivitySystem.Req_DealActivity(ActivtyUI.KR_H5LeagueGameActivityID, 1, 0);
    end
    
    if not BP_Activity_Jump_Url then
        return;
    end

    ClientSendTLogReport(BP_BA_EXPOSURE_ENTRANCE, nil, GemReportUtils.SubEventName_LobbyBannerJump.."_".. BP_Activity_Jump_Url)


    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_BIND_FACEBOOK) ~= nil then --处理绑定页面
        BindFacebookUI.ClickActEnterance(BP_ClickTimeNotBind, BP_ClickTimeBind)
    end

    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_BUY_UPASS_ACT) ~= nil then --处理购买通行证页面
        --BuyUPassActUI.RefreshBuyData() 本身打开页面就会刷新活动数据,判断是否红点
        --BuyUPassActUI.HandleRedPoint()
        BP_HasClickUPassAct = true
        LuaClassObj.HandleUIMessage(bp_lobby, "SetIsClickUPassAct");
    end

    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_ACTIVITY_INVITE_TEAM) ~= nil then --处理打开邀请组队活动
        BP_HasClickInviteTeamAct = true
        LuaClassObj.HandleUIMessage(bp_lobby, "SetIsClickInviteTeamAct");
        LobbyUI:HandleInviteTeamActRedPoint()
    end

    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE) ~= nil then --处理打开载具升级活动
        LobbyUI.UpdateClickHalloweenVehicle()
    end

    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_ACTIVITY_ICE_LUCKY) ~= nil then --处理打开冰雪家活动
        LobbyUI.UpdateClickIceLucky()
    end

    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_ANNIVERSARY) ~= nil then --处理打开周年庆活动
        LobbyUI.UpdateClickAnniversary()
    end

    if JumpUtils.IsPanDoraJumpUrl(BP_Activity_Jump_Url) then
        local pandoraSystem = require("client.pandora.pandora_system");
        pandoraSystem.TryJumpUrl(BP_Activity_Jump_Url);
    end    

    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_STARTER_PACK) then
        StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.CAROUSEL, true)
    end

    if string.find(BP_Activity_Jump_Url, BP_ENUM_MODULE_INDIACOMP) ~= nil then --处理打开周年庆活动
        EventLobbyLeagueGameEntranceEnterIndia()
    end

    BP_Activity_Jump_Url = "";--使用完后需要将其置为空字符串
end
-----------------
----------------- 幸运空投
BP_LuckAirDropTime = 0;--此次空投的活动开始时间,用来判别是否弹窗
BP_LuckAirDropTimeLeft = 0; --用来倒计时

function LobbyUI:ShowLuckAirDropQuery(is_only_show_entrance)--登录时刻(拍脸图结束后),查看是否有幸运空投
    log("ShowLuckAirDropQuery")
    LuckAirDropUI.RefreshData()
    if LuckAirDropUI.isDataLawful() == true then
        if is_only_show_entrance then
            LobbyUI:ShowLuckAirDropEntrance()
            LobbySystem.PopNextUI();
        else
            --此次空投是否弹过窗
            LuaClassObj.HandleUIMessage(bp_lobby, "GetLuckAirDropTime")
            log("xzx LobbyUI BP_LuckAirDropTime = "..BP_LuckAirDropTime)
            if BP_Struct_LuckAirDrop_AllInfo.beginTime then
                log("BP_Struct_LuckAirDrop_AllInfo.beginTime " .. tostring(BP_Struct_LuckAirDrop_AllInfo.beginTime))
            end
            if BP_LuckAirDropTime ~= BP_Struct_LuckAirDrop_AllInfo.beginTime then--新的空投
                LuckAirDropUI.ShowQuery()
            else
                LobbyUI:ShowLuckAirDropEntrance()
                LobbySystem.PopNextUI();
            end
        end
    else
        LobbySystem.PopNextUI();
    end
end

function LobbyUI:SetLuckAirDropQueryTime()--记录弹框时间
    BP_LuckAirDropTime = BP_Struct_LuckAirDrop_AllInfo.beginTime;
    log("SetLuckAirDropQueryTime " .. tostring(BP_LuckAirDropTime))
    LuaClassObj.HandleUIMessage(bp_lobby, "SetLuckAirDropTime")
end

function LobbyUI:ShowLuckAirDropEntrance()
    log("LuckAirDropEntrance")
    BP_LuckAirDropTimeLeft = LuckAirDropUI.GetEndTimeStamp()
    log("BP_LuckAirDropTimeLeft "..BP_LuckAirDropTimeLeft)
    if BP_LuckAirDropTimeLeft > 0 and not RoleInfoUI.IsShow  then
        LuaClassObj.HandleUIMessage(bp_lobby, "ShowLuckAirDropIcon")--是否显示入口
        if LuckAirDropUI.IsinTeam() then
            LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIHideAirDropEntrance")--隱藏打开空投的入口
        end
    end
end

--展示空投箱
function LobbyUI.ShowAirDropOnHideRoleinfo()
    LobbyUI:ShowLuckAirDropEntrance();
end

--隐藏空投箱
function LobbyUI.HideAirDropOnShowRoleinfo()
    log("LobbyUI.HideAirDropOnShowRoleinfo")
    if BP_LuckAirDropTimeLeft > 0  then
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideLobbyAirDropBoxActorAndEntrance")--隱藏入口的箱子
    end
end

function EventLobbyLuckAirDropShow()
    LuckAirDropUI.ShowFromLobby();
end
---------------

-- 打开内置浏览器判断
BP_Lobby_CanOpenUrl = true
function EventCanOpenUrl()
    BP_Lobby_CanOpenUrl = true
    return
    -- 暂时屏蔽
    --[[
    if TeamUpUI.IsMatching() then
        BP_Lobby_CanOpenUrl = false
        DataMgr.ShowNoticeByID(110017)
		return
    end

    if BP_LobbyPlayerNum > 1 then
        BP_Lobby_CanOpenUrl = false
        DataMgr.ShowNoticeByID(110067)
    end]]
end
-- 关闭商城
function EventLobbyHideShop()
    if true == ShopUI.isShow then
        LuaClassObj.HandleUIMessage(bp_shop, "UIHide")
    end
    --EventShopHide()
end

-- 关闭仓库
function EventLeaveWardrobe()
    --log("leave Wardrobe");
    WardrobeUI:Hide();
end

-- 关闭获得物品面板
function EventLobbyLeaveItemGet()
    CommonItemGetUI:Hide()
end

function EventLobbyLeaveChatWnd()
    LobbyChatLogic.CloseUI();
end

function EventLobbyLeaveRankList()
end

function EventLobbyLeaveFriend()
end

function EventLobbyLeaveMail()
end

function EventLobbyLeaveSetting()
    SettingUI:Hide()
end

function EventLobbyLeaveWorldView()
end

function EventLobbyLeaveRoleInfo()
end

function EventLobbyLeaveGuidePanel()
    GuideUI:Hide()
end

function EventLeaveWeekSignUp()
    WeekSignUpUI.HideUI();
end

function EventLobbyLeaveTask()
    EventTaskHideUI()
end

function  EventLeaveLobby()
    EventLeaveWardrobe();
    EventLobbyHideShop();
    EventLobbyLeaveFriend();
    EventLobbyLeaveMail();
    EventLobbyLeaveRankList();
    EventLobbyLeaveRoleInfo();
    EventLobbyLeaveSetting();
    EventLobbyLeaveWorldView();
    EventLobbyLeaveItemGet();
    EventLobbyLeaveChatWnd();
    EventLobbyLeaveGuidePanel();
    --EventLeaveWeekSignUp();
    --EventLobbyLeaveTask();
    EventLobbyExpressionLeave();
end

_ValidPopUI = {
    --仓库
    ["Wardrobe_BP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UIHide");
    end,
    --仓库引导Pass开启面板
    ["Wardrobe_RP_UIBP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "OnClickRPCloseBtn");
    end,
    --仓库购买时装背包
    ["Wardrobe_Buy_Item_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "OnClickBuyCloseBtn");
    end,

    ["Shop_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_shop, "UIHide");
    end,
    ["LobbyFriendList_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_lobby_friend, "UIHide");
    end,
    ["LobbyFriendList_UIBP_C_BlackList"] = function()
        LuaClassObj.HandleUIMessage(bp_lobby_friend, "CloseBlackList");
    end,
    ["LobbyFriendList_UIBP_C_ApplyPanel"] = function()
        LuaClassObj.HandleUIMessage(bp_lobby_friend, "CloseApplyPanel");
    end,
    ["LobbyFriendList_UIBP_C_InviteVerify"] = function()
        LuaClassObj.HandleUIMessage(bp_lobby_friend, "CloseInviteVerify");
    end,
    ["Mail_BP_C"] = function()
        EventMailClose();
    end,
    ["Rank_BP_C"] = function()
        EventRankClose();
    end,
    ["RoleInfo_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo, "BtnCloseRoleInfo");
    end,
    ["RoleInfo_AvatarFrame_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo_avatarframe, "Close");
        RoleInfoShowInfoUI.SafeHide()
    end,
    ["Title_managemen2_BP_C"] = function()
        RoleInfoShowInfoUI.SafeHide()
    end,

    ["RoomWaiting_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_room_waiting, "OnClickCloseInRoomList");
    end,
    ["RoomList_BP_C"] = function()
        RoomUI:RoomHide()
    end,
    ["Setting_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_setting, "UIHide");
    end,
    ["Inform_BP_C"] = function()
        ComplaintUI:Hide();
    end,      
    ["Inform_BP_C_TeamList"] = function()
        LuaClassObj.HandleUIMessage(bp_complaint, "HideTeamList");
    end, 
    ["TeamAthleticsResultShare_UIBP_C"] = function()
        ShareDeathMatchUI:Hide();
    end, 
    ["TeamAthleticsResultShare_UIBP_C_RewardDetail"] = function()
        LuaClassObj.HandleUIMessage(bp_battleresult_deathmatch, "HideRewardDetail");
    end, 
    ["ShareResult_UIBP_C"] = function()
        ShareResultUI.HideUI();
    end, 
    ["ResultsRanking_BP_C_BattleDetail"] = function()
        LuaClassObj.HandleUIMessage(bp_battleresult, "HideBattleDetailInfo");
    end,
    ["ResultsRanking_BP_C_RankingTitle"] = function()
        LuaClassObj.HandleUIMessage(bp_battleresult, "HideTitles");
    end,
    ["ResultsRanking_BP_C_RankingRewardTitle"] = function()
        LuaClassObj.HandleUIMessage(bp_battleresult, "HideRewardTips");
    end,
    ["ResultsRanking_BP_C_MyTitle"] = function()
        LuaClassObj.HandleUIMessage(bp_battleresult, "AndroidbackHideMyTitles");
    end,
    ["ResultsRanking_BP_C_TeamRankingList"] = function()
        LuaClassObj.HandleUIMessage(bp_battleresult, "HideTeamRankingList");
    end,
    ["FirstTimeTips_FPP_C"] = function()
        FPP_TPP_TIPSUI:HideFPPTips();
    end,    
    ["FirstTimeTips_war_FPP_C"] = function()
        WARMODE_TIPSUI:HideWarModeTips();
    end,   
    ["FirstTimeTips_PVEVP_C"] = function()
        PVEVP_TIPSUI:HidePVEVPModeTips();
    end,   
    ["sports_guide_UIBP_C"] = function()
        TMODE_TIPSUI:HideTModeTips();
    end,       
    ["Tmode_Control_UIBP_C_Tab_UIBP"] = function()
        if tmode then
            InGameUIManager.HandleUIMessage(tmode, "HideTabUIBP");
        end
    end,   
    ["Setting_language02_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_language, "UIHide");
    end,
    ["UIElemLayout_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_uielem, "Close");
    end,
    ["CtrGuide_UIBP_C"] = function()
        GuideUI:Hide()
    end,
    ["Common_MessageBox_Panel_BP_C"] = function()
        if BP_CommonMessageBox_style == 1 then
            EventCommonMessageBoxClickOK();
        else
            EventCommonMessageBoxClickCancel();
        end
        LuaClassObj.HandleUIMessage(bp_common_messagebox_panel, "UIHide");
    end,
    --New弹窗
    ["Common_MessageBox_News_UIBP_C"] = function()
        UrgentNoticeUI:Hide()
    end,

    ["PopupNotice_BP_C_ShowMsgBox"] = function()
        LuaClassObj.HandleUIMessage(bp_popup_notice, "OnClickCloseUI");
    end,
    --社交媒体选择面板
    ["Lobby_OfficialInfo_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_official_info, "OnClickCloseButton");
    end,

    ["RecruitLogic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_recruit, "OnBtnClikClose");
    end,
    ["ChatMain_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_chat_main, "UIHide");
    end,
    ["ChatReport_LogicBp_C"] = function()
        LuaClassObj.HandleUIMessage(bp_chat_report, "OnClickCancel");
    end,

    ["Common_Item_Get_Panel_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_common_item_get_panel, "UIHide");
    end,
    ["Annual_Item_Get_Panel_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_common_item_get_panel, "UIHideAnnual");
    end,
    ["ReportBug_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_reportbug, "UIHide");
    end,
    ["LobbyTeam_NoTeam_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_alliance, "HideNoTeamPanel");
    end,
    ["LobbyTeam_CreateTeam_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_alliance, "HideCreateTeamPanel");
    end,
    ["LobbyTeamMain_LogicBP_C"] = function()
        -- LuaClassObj.HandleUIMessage(bp_alliance, "CloseTeamMainPanel");
        -- LuaClassObj.HandleUIMessage(bp_alliance, "EventClickAllianceCloseMainPanel");

        -- EventClickAllianceCloseMainPanel()
        AllianceUI:CloseTeamMainPanel()

    end,
    ["LobbyTeam_SelectIcon_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_alliance, "HideSelectIconPanel");
    end,
    ["LobbyTeam_LogicRecruitBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_alliance_recruit, "OnClickBtnClose");
    end,
    ["Newteaching_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_newteaching, "HideUI");
    end,
    ["Task_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_task, "OnCloseBtnClicked");
    end,
    ["Activty_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_activty, "OnCloseBtn");
    end,
    ["LobbyReportBug_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_lobby_reportbug, "UIHide");
    end,
    ["Good_Item_Get_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_good_item_get_panel, "Close");
    end,
    ["Share_DayFinalyLogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_dayfinaly, "UIHide");
    end,
    ["Share_Item_Get_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_item_get_share, "UIHide");
    end,
    ["Share_LevelUp_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_levelup, "UIHide");
    end,
    ["Share_PersonLogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_person, "UIHide");
    end,
    ["Share_Rank_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_rank, "UIHide");
    end,
    --分享个人单局排名
    ["Share_History_Ranking_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_history_ranking, "UIHide");
    end,
    --分享个人单局战绩
    ["Share_History_Results_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_history_results, "UIHide");
    end,
    ["OpenBox_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_open_box_panel, "UIHide");
    end,
    ["Season_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_season, "OnClickClose");
    end,
    ["EightDay_BP_C"] = function()
        EventEightDayHideUI()
        --LuaClassObj.HandleUIMessage(bp_eightday, "HideUI");
    end,
    ["BindFacebook_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_bind_facebook, "CloseUI");
    end,
    ["Common_Invite_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_invite_join_team, "CloseUI");
    end,
    ["Faceteam_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_faceteam, "UIHide");
    end,
    ["Lobby_SelectMap_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_teamup_map, "ClickBtnClose");
    end,
    --直购活动
    ["Lobby_Direct_Purchase_By_Activity_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_direct_purchase_by_activity, "Hide");
    end,


    ["LevelAward_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_season, "onCloseSeasonAward");
    end,
    ["LevelDetail_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_season, "OnCloseSegmentTips");
    end,
    ["TheFirstCharge_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_thefirstcharge, "CloseUI");
    end,
    ["Recharge_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_recharge, "ExitRecharge");
    end,
    ["RechargeJK_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_rechargeJK, "ExitRecharge");
        local uiManager = require("ui.manager");
        if uiManager then
            uiManager.CloseUI(uiManager.UI_Config.recharge_mgr);
        end
    end,
    ["Countryarea_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_countryarea, "UIHIde");
    end,
    ["RoleInfo_Headportrait_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "Close");
        RoleInfoShowInfoUI.SafeHide()
    end,
    ["RoleInfo_Tag_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo_tag, "OnClose");
    end,
    ["Lobby_MallSystem_Logic_2_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_mall_system_2, "ExitMall");
    end,
    ["Mall_Buy_Item_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_mall_buy_item, "UIHide");
    end,
    ["Shop_Gift_BP_C"] = function()
        EventGiftUIClose();
    end,
    ["Lobby_CreatingRole_UIBP_C"] = function()
        if BP_CreateRole_Mode == 1 then -- 创角
            EventAndroidQuitGame();
        else
            LuaClassObj.HandleUIMessage(bp_createrole, "Close");
        end
    end,
    --重置外观购买界面
    ["ResetPurchase_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_createrole, "Hide");
    end,

    ["Armory_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_armory, "OnClickBtnClose");
        ShowLobby();
    end,
    ["Authorization_BP_C_LoginChoice_Panel"] = function()
        LuaClassObj.HandleUIMessage(bp_authorization, "CloseMore");
    end,
    --登陆界面修复面板
    ["Login_Repair_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_login_repair, "UIHide");
    end,


    ["Faceteam_LogicBP_Faceteam_UIPB2"] = function()
        LuaClassObj.HandleUIMessage(bp_faceteam, "OnClickCloseFaceTeam");
    end,
    ["Protection02_BP1_C"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_gdpr, "CloseProtection02");
    end,
    ["Protection06_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_gdpr, "CloseProtection06");
    end,

    ["Setting_CancelPUBGM_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_korea_delete_account, "CloseSettingCancelPUBGM");
    end,

    ["Common_Use_Items_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_common_use_items, "OnClickClose");
    end,
    ["Setting_UIBP_C_Setting_BindChoice_Panel"] = function()
        LuaClassObj.HandleUIMessage(bp_setting, "HideBindChoicePanel");
    end,
    ["UIElemLayout_BP_C_CanvasPanel_QuitMsgBox"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_uielem, "CloseQuitDialog");
    end,
    --设置面板云端布局界面
    ["Setting_Selection_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_selection, "OnClickCloseBtn");
    end,

    ["RoleInfo_HistoryDetail_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo_historydetail, "OnClickBtnBack");
    end,
    ["Lobby_UnknowPass_Logic_BP_C"] = function()
        EventCloseUnknowPass()
    end,
    ["UnknowPass_Buy_Score_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "OnCloseBuyScore");
    end,
    ["UnknowPass_Exchange_Confirm_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange_confirm, "OnCloseClick");
    end,
    ["UnknowPass_Buy_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_buy, "OnCloseClick");
    end,
    ["UnknowPass_Buy_Logic_BP_C_Detail"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_buy, "CloseDetail");
    end,
    ["UnknowPass_Show_Ordinary_Award_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_show_ordinary_award, "HideUI");
    end,
    ["UnknowPass_Choose_Award_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_choose_award, "Hide");
    end,
    ["UnknowPass_Mission_AwardALL_Logic_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_mission_award_all, "Hide");
    end,

    ["UnknowPass_Rank_Logic_BP_C"] = function()
        EventCloseUnknowPass();
    end,

    --Pass开场动画
    ["UnknowPass_Introduce_Logic_BP_C"] = function()
        EventUnknowPassIntroduceUIClickClose();
    end,

    --Pass新手引导
    ["UnknowPass_Newbie_Logic_BP_C"] = function()
        EventUnknowPassNewbie_Close()
    end,

    --Pass升级界面
    ["UnknowPass_LevelUp_Logic_BP_C"] = function()
        UnknowPassLevelUp.HideUI()
    end,

    --Pass恭喜获得界面
    ["UnknowPass_Show_Award_Logic_BP_C"] = function()
        UnknowPassShowAward.HideUI()


        LuaClassObj.HandleUIMessage(bp_unknow_pass_show_award, "UIHide");
    end,

    --Pass升级活动
    ["BuyUPassAct_BP_C"] = function()
        EventBuyUPassActHideUI()
    end,

    ["Title_managemen_BP_C"] = function()
        RoleInfoAliasUI.Hide();
    end,
    ["Lobby_MallSystem_Logic_2_BP_C"] = function()
        EventStartCloseMallSystemforAndroidBack();
    end,
    ["Mail_BP_C_MailI_tem_Detail"]= function()
        LuaClassObj.HandleUIMessage(bp_mail, "HideMailDetail");
    end,
    ["Common_TreasureBox_Popup_BP_C"] = function()
        CommonTreasureBoxPopup:ClosePanel();
    end,
    ["WarZoneMedalChoose_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_warzone_medalchoose, "HideUI");
    end,
    ["CountryStrongest_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_countrystrongerrank, "HideUI");
    end,
    ["RegionStrongest_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_regionstrongerrank, "HideUI");
    end,
    ["ShareWarZoneTitle_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_warzone_title, "HideUI");
    end,
    ["WarZoneRank_BP_C"] = function()
        EventWarZoneRankClose();
    end,
    ["EightDay_BP_C"] = function()
        EventEightDayHideUI()
        --LuaClassObj.HandleUIMessage(bp_eightday, "HideUI");
    end,
    ["WeekSignUp_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_week_signup, "UIHide");
    end,
    ["Slap_IMSDKNotice_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_notice_intl, "HideSlapNotice");
        IMSDKNoticeUI.ShowNextOrQuitNotice();
    end,
    ["Common_IMSDKNotice_Panel_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_notice_intl, "HideCommonNotice");
        IMSDKNoticeUI.ShowNextOrQuitNotice();
    end,
    ["JKNoticeAfterLogin_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_notice_intl, "HideJKNotice");
        EventCloseJKNotice();
    end,
    ["Setting_UIBP_C_Setting_BindChoice_Panel"] = function()
        LuaClassObj.HandleUIMessage(bp_setting_basic, "HideBindChoice");
    end,
    ["DecomposeItem_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_item_decompose, "UIHide");
    end,
    ["Armory_Logic_BP_C_Full_Screen"] = function()
        LuaClassObj.HandleUIMessage(bp_armory, "OnCloseFullScreen");
        ShowLobby();
    end,

    ["Lobby_InviteFriendLogic_BP_C_FriendListGroup"] = function()
        LuaClassObj.HandleUIMessage(bp_teamup_friend, "OnclickBtnFriendList");
    end,
    ["Lobby_SelectMatchInfo_Logic_BP_C"] = function()
        TeamUpMatchInfoUI.Hide();
    end,
    ["Common_Item_List_BP_C"] = function()
        CommonItemListUI.Hide();
    end,
    ["Room_RoomCreate_BP_C"] = function()
        RoomCreateUI.HideUI()
    end,
    ["RoomWaiting_BP_C_RoomWatchingPanle"] = function()
        LuaClassObj.HandleUIMessage(bp_room_waiting, "HideRoomWatchingPanel");
    end,
    ["RefluxTraining_BP_C"] = function()
        EventOnRefluxTrainingUIClose();
    end,
    ["Global_expression_BP_C_ExpressionPanel"] = function()
        LuaClassObj.HandleUIMessage(bp_expression, "UIHide");
    end,
    ["RoomList_BP_C_GridPanel_EnterPswUI"] = function()
        LuaClassObj.HandleUIMessage(bp_room, "ClosePSWUIAfterEnterRoom");
    end,
    ["AchievementScoreAward_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo_achievement_score_award, "HideUI");
    end,
    ["SelectAchievement_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo_select_achievement, "HideUI");
    end,
    ["Achievement_Detail_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_achievement_detail, "OnCloseBtnClick");
    end,
    ["Lobby_RoleInfo_BigAvatar_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_roleinfo_bigavatar, "HideUI");
    end,
    ["Common_HelpTips_Panel_BP_C"] = function()
        CommonHelpTipsUI:ClosePanel();
    end,
    ["CorpsIconPanelNew_BP_C"] = function()
        CorpsIconSelectUI.HideUI();
    end,
    ["Corps_BP_C"] = function()
        CorpsUI.UIClose();
    end,
    ["Corps_Logic_BP_C"] = function()
        CorpsBaseUI.HideUI();
    end,
    ["CorpsAutoInvite_BP_C"] = function()
        CorpsAutoInviteUI.HideUI();
    end,
    ["CorpsTraining_BP_C"] = function()
        CorpsTrainingUI.Hide();
    end,
    ["CorpsTraining_Rank_BP_C"] = function()
        CorpsTrainingRankUI.Hide();
    end,
    ["CorpsAppoint_BP_C"] = function()
        CorpsAppointUI.HideUI();
    end,
    ["CorpsManager_BP_C"] = function()
        CorpsManagerUILogic.HideUI();
    end,
    ["CorpsApplyList_BP_C"] = function()
        CorpsApplyListUILogic.HideUI();
    end,
    ["MainControlPanelTochButton_BP_C"] = function()
        InGameUIManager.HandleUIMessage(ingame, "BackToLobby");
    end,
    ["NoticeBox_BP_C"] = function()
        CommonNoticeBoxPanelAndroidBackHide();
    end,
    ["protection08_UIBP_C"] = function()
        CommonNoticeBoxPanelAndroidBackHide();
    end,
    ["UIElemLayout_BP_C_CanvasPanel_SwitchMsgBox"] = function()
        AndroidBackInvalid();
    end,
    ["Direct_Purchase_BP_C"] = function()
        Direct_Purchase_UI.Release();
    end,
    ["Direct_Purchase_By_Ativity_UI_C"] = function()
        Direct_Purchase_By_Ativity_UI.HideUI();
    end,
    ["Share_Achievement_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_achievement, "OnClose");
    end,
    ["Drop_Rate_Panel_C"] = function()
        LuaClassObj.HandleUIMessage(bp_rate_panel, "UIHide");
    end,
    ["Shop_Gift_BP_C"] = function()
        EventGiftUIClose();
    end,
    ["Shop_Gift_Packet_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_shop_gift_packet, "HideUI");
    end,

    -- 月卡
    ["Welfare_MonthCard_BP_C"] = function()
        WelfareMonthCardUI.HideUI()
    end,
    -- 赛季
    ["Lobby_Season_Review_BP_C"] = function()
        SeasonReviewUI.HidePanel()
    end,

    -- 语言选择
    ["SelectLanguage_BP_C"] = function()
        ChatLanguageSelect.Hide()
    end,

    -- 匹配语言选择
    ["SelectLanguage_Match_BP_C"] = function()
        MatchLanguageSelect.Hide()
    end,

    -- 聊天成就分享界面
    ["ChatShareAchievement_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_chat_share_achievement, "OnClickCloseBtn");
    end,


    -- 聊天查看他人成就分享
    ["ChatShareAchievement_Item_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_chat_share_achievement_show, "UIHide")
    end,


    -- 聊天室密码输入
    ["Chatroomcreat_LogicBP_C_GridPanel_PswUI"] = function()
        LuaClassObj.HandleUIMessage(bp_chat_room, "ClickPasswordClose");
    end,
    -- 聊天室创建聊天室
    ["Chatroomcreat_LogicBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_chat_roomcreate, "ClickClose");
    end,


    -- 军团称号
    ["CorpsChoosetitle_BP_C"] = function()
        EventCorpAliasHide()
    end,

    -- 奖赏包
    ["Welfare_RewardPkg_BP_C"] = function()
        WelfareRewardPkgUI.HideUI();
    end,

    -- 军团个人信息详情
    ["RoleInfoCorps_BP_C"] = function()
        RoleInfoCorps:Hide();
    end,

    -- 军团邀请信息详情
    ["CorpsInvitation_BP_C"] = function()
        CorpsInvitationUI.HideUI();
    end,

    -- 军团排行榜奖励
    ["CorpsRankAward_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_corps_rank_award, "UIHide")
    end,

    -- 军团福利券
    ["CorpsRedEnvelopes_Item_BP_C"] = function()
        CorpsWelfareRedEnvelopesUI.Close()
    end,

    -- 军团福利领取记录
    ["CropsReceivingrecords_BP_C"] = function()
        CorpsWelfareReceiveUI.Close()
    end,
    
    -- 幸运空投
    ["LuckAirDrop_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_luck_airdrop, "UIHide");
    end,

    -- 通行证积分兑换
    ["UnknowPass_Exchange_Buy_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "CloseBuyDialogWithoutSound");
    end,

    -- 通行证雨林黄金珍藏宝箱
    ["UnknowPass_TreasureBox_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_unknow_pass_treasurebox, "OnBtnCloseClickWithoutSound");
    end,

    -- 组队邀请活动
    ["ActivityInviteTeam_Logic_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_activity_invite_team, "UIHide");
    end,

    -- 载具抽奖
    ["Halloween_Vehicle_trick_BP_C"] = function()
        HalloweenVehicleTrickUI.HideUI()
    end,

    -- 载具兑换
    ["Halloween_Vehicle_Skin_BP_C"] = function()
        HalloweenVehicleSkinUI.HideUI()
    end,

    -- 载具抽奖奖励领取
    ["Halloween_Vehicle_Award_BP_C"] = function()
        HalloweenVehicleAwardUI.HideUI()
    end,

    -- -- 战队商店
    -- ["LobbyTeam_Competition_Shop_LogicBP_C"] = function()
    --     AllianceCompetitionShopUI.Hide()
    -- end,

    -- 战队商店宝箱
    ["LobbyTeam_Competition_Box_LogicBP_C"] = function()
        EventAllianceCompetitionTreasureBoxClose()
    end,


    -- 称号弹窗
    ["Title_Get_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_alias, "UIHide");
    end,


    -- 烧鸡活动
    ["Activty_ShaoJi_Logic_BP_C"] = function()
        EventActivtyShaoJiClose()
    end,
    --赛事报名弹出
    ["LeagueGame_SignUp_BP2_C"] = function()
        LeagueGameSignUpPopUI.Hide()
    end,
    --赛事报名
    ["LeagueGame_signUp_BP_C"] = function()
        EventLeagueGameSignUpHide()
    end,
    -- 赛事信息
    ["LeagueGame_LeagueInfo_BP_C"] = function()
        EventLeagueInfoHide()
    end,
    -- 赛事冠军显示
    ["LeagueGame_Champion_BP1_C"] = function()
        EventLeagueGameChampionHide()
    end,
    -- 赛事奖励
    ["LeagueGameAdvance_BP_C"] = function()
        EventLeagueGameAdvanceHide()
    end,
    -- 赛事排行详情
    ["LeagueGame_LeagueInfoDetail_BP_C"] = function()
        LeagueGameLeagueInfoDetailUI.Hide()
    end,
    --赛事规则
    ["LeagueGame_scheduleRule_BP_C"] = function()
        EventLeagueGameScheduleRuleHide()
    end,
    
    --赛事treasureBox
    ["LeagueGame_TreasureBox_BP_C"] = function()
        LeagueGameTreasureBoxUI.Hide(true)
    end,
    --赛事引导
    ["LeagueGame_Introduce_BP_C"] = function()
        EventLeagueGameIntroduceUIClickClose()
    end,
    -- 海选匹配
    ["LobbyTeam_Competition_Room_LogicBP_C"] = function()
        EventAllianceCompetitionClickCloseBtn()
    end,

    -- PDD
    ["PDD_System_Logic_BP_C"] = function()
        EventClosePDDSystemUI()
    end,
    ["Bargained_Rule_UIBP_C"] = function()
        EventClosePDDSystemRules()
    end,
    ["Bargain_Detail_Logic_BP_C"] = function()
        EventOnClickCloseBargainDetail()
    end,
    ["Bargain_First_Logic_BP_C"] = function()
        EventOnClickCloseFirstBargain()
    end,
    ["Bargain_Buy_Logic_BP_C"] = function()
        EventOnClickBargainBuyClose()
    end,
    ["Bargain_History_Logic_BP_C"] = function()
        EventOnClickBargainHistoryClose()
    end,
    --黑五界面
    ["Lobby_BlackFriday_BP_C"] = function()
      LuaClassObj.HandleUIMessage(bp_blackfriday, "OnBtnClose");
    end,

    ["Lobby_BioChemical_BP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_biochemical_lucky, "UIHideForAndroid");
    end,
    ["Lobby_LuckyUnback_BP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_lucky_unback, "UIHideForAndroid");
    end,
    ["Lobby_DiscountFever_BP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_discount_fever, "UIHide");
    end,

    ["ItemUpgrade_BP_C"] = function()
        ItemUpgradeUI.AndroidBack();
    end,
    ["IceLucky_Snatch_BP_C"] = function()
        IceLuckyGemUI.HideUI(true);
    end,
    ["IceLucky_Award_BP_C"] = function()
        IceLuckyAwardUI.HideUI()
    end,
    --新版商城
    ["StoreMainLogicUI_BP_C"] = function()
        EventStoreMainUI_Close()
    end,
    ["SupplyMainLogicUI_BP_C"] = function()
        EventSupplyMainUI_Close()
    end,
    ["StorePreviewLogicUI_BP_C"] = function()
        StorePreviewUI.Hide()
    end,

    --礼物中心
    ["Shop_Gift_With_Day_LogicBP_C"] = function()
        EventShopGiftWithDayUIClickClose()
    end,

    --礼物中心领取界面
    ["Shop_GetGift_View_BP_C"] = function()
        ShopGiftViewUI.HideUI()
    end,
    --礼物中心领取后分享界面
    ["ShopGift_Share_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_share_shop_gift, "UIHide");
    end,



    ["Store_Buy_BP_C"] = function()
        StoreBuyUI:Release()
    end,
    ["Mall_Buy_Item_With_Count_BP_C"] = function()
        MallBuyItemWithCountUI:Release()
    end,
    ["StoreBindPhoneLogicUI_BP_C"] = function()
        EventStoreBindPhone_Close()
    end,
    ["ODDS_PVE_UIBP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_pve_rate, "UIHide");
    end,
    ["Championship_India_History_LogicBP_C"] = function()
        IndiaCompetitionHistoryRecordUI.Hide()
    end,
    ["ChampionIndia_Introduce_LogicBp_C"] = function()
        IndiaCompetitionIntroduceUI.Hide()
    end,
    ["Championship_India_Popup_UIBP_C"] = function()
        IndiaSignUpUI.Hide()
    end,
    ["ChampionshipIndiaLogicBp_C"] = function()
        IndiaCompetitionUI:Hide()
    end,
    ["RoleInfo_BP_C"] = function()
        RoleInfoUI.HideUI(true)
    end,
    ["PersonSpaceMain_BP_C"] = function()
        RoleInfoUI.HideUI(true)
    end,
    ["RoleInfo_Card_Popup_BP_C"] = function()
        RoleInfoCardPopupUI.HideUI()
    end,
    ["RoleInfo_Combat_BP_C"] = function()
        RoleInfoUI.HideUI(true)
    end,
    ["RoleInfo_Segment_BP_C"] = function()
        RoleInfoUI.HideUI(true)
    end,
    ["RoleInfo_History_BP_C"] = function()
        RoleInfoUI.HideUI(true)
    end,
    ["Countryarea_BP_C"] = function()
        CountryareaUI.HideUI()
        RoleInfoShowInfoUI.SafeHide()
    end,
    ["Countryarea2_BP_C"] = function()
        CountryareaUI.HideUI()
        RoleInfoShowInfoUI.SafeHide()
    end,
    ["RoleInfo_Achievement_BP_C"] = function()
        RoleInfoUI.HideUI(true)
    end,
    ["PersonSpace_PartnerSetting_BP_C"] = function()
        PersonSpacePartnerSettingUI.HideUI()
    end,
    ["PersonSpace_SecrecySetting_BP_C"] = function()
        --PersonSpaceSecrecySettingUI.HideUI()
        RoleInfoShowInfoUI.Hide()
    end,
    ["PersonSpace_Relationship_BP_C"] = function()
        PersonSpaceRelationshipUI.HideUI()
    end,

    --NEWS公告
    ["logic_Common_News_BP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_news, "UIHide")
    end,
    --日本首充年龄弹窗
    ["Protection07_BP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_jpage_panel, "CloseUI")
    end,
    --越南年龄弹窗
    ["Protection01_BP_C"] = function()
        LuaClassObj.HandleUIMessageNoFetch(bp_eugdpr_panel, "CloseUI");
    end,
    
    --直购活动
    ["Lobby_Direct_Purchase_By_Activity_BP_C"] = function()
        LuaClassObj.HandleUIMessage(bp_direct_purchase_by_activity, "Hide");
    end,
    -- 价格选择
    ["Store_PriceType_UIBP_C"] = function()
        StorePriceSelect_UI.Hide()
    end,

    -- 价格选择
    ["TaskBackflow_BP_C"] = function()
        local ui_manager = require("ui.manager");
        ui_manager.CloseUI(ui_manager.UI_Config.activity_center)
    end,

    [""] = function()
        log("Exit");
        EventAndroidQuitGame();
    end,
}

-- Wrap _ValidPopUI handlers in pcall for offline safety
for _vk, _vv in pairs(_ValidPopUI) do
    local _orig = _vv
    _ValidPopUI[_vk] = function(...)
        local ok, err = pcall(_orig, ...)
        if not ok then
            if _G.writeLog then _G.writeLog("_ValidPopUI[" .. tostring(_vk) .. "] error: " .. tostring(err)) end
        end
    end
end

-- Android back 逻辑
-- 为了保证以后合入方便没有直接使用 closeOtherMenu, closeOtherMenu实现不完备
function EventLobbyAndroidBack()
    if not BP_Global_AndroidKey_IsValid then
        log("EventLobbyAndroidBack: AndroidKey Is Not Valid");
        return
    end

    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ANDROID_BACK)
end

--对于需要禁用安卓返回键的界面，调用此函数避免当前界面被pop
function AndroidBackInvalid()
    return
end


function EventGetFriendProfile()
    FriendSystem.OnRefreshFriendProfile()
end

function EventLobbyLeaveCorps()
    EventCorpsClose()
end

-- 进入游戏关闭其他面板
function LobbyUI:GotoGameHidePanels()
    LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu")
    ExpressionUI.Hide()
    CommonMessageBoxUI:HidePanel();
    EventTaskHideUI()
    ArmoryUI.CloseArmory()
    LuaClassObj.HandleUIMessage(bp_good_item_get_panel, "Hide");
    LuaClassObj.HandleUIMessage(bp_item_get_share, "Hide");
    LuaClassObj.HandleUIMessage(bp_lobby_reportbug, "UIHide");

    -- 关闭匹配面板
    AllianceCompetitionRoomUI.Hide()
end


-- 创建avatar变更数据结构
function LobbyUI:CreateAvatarChangeData(gid, resId, colorID, patternID)
    colorID = colorID or 0;
    patternID = patternID or 0;
    local playerData =
    {
        gid = tostring(gid),
        resId = resId,
        colorID = colorID,
        patternID = patternID,
    }

    return playerData
end

-- 转换后台玩家服装数据为前台结构
function LobbyUI.MakeClientAvatarWearInfo(serverWearInfo)
    if serverWearInfo == nil then
        return { resID = 0, colorID = 0, patternID = 0 };
    end
    local clientWearInfo =
    {
        resID = serverWearInfo[1] or 0,
        colorID = serverWearInfo[2] or 0,
        patternID = serverWearInfo[3] or 0,
    };
    return clientWearInfo;
end

-- 创建服装数据
function LobbyUI.CreateClientAvatarWearInfo(resID, colorID, patternID)
    local clientWearInfo =
    {
        resID = resID or 0,
        colorID = colorID or 0,
        patternID = patternID or 0,
    };
    return clientWearInfo;
end

-- 创建组队玩家变更数据结构
function LobbyUI.CreateSpawnPlayerData(gid, sex, headId, hairid, avatarList)
    local avatarSt = {
        gamegender = sex,
        headid = headId,
        hairid = hairid
    }

    local spawnPlayerData =
    {
        gid = tostring(gid),
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = avatarList
    }

    return spawnPlayerData
end

-- 判断组队玩家是否已经在大厅中
local function IsPlayerAlreadyInLobby(playerData)
    log("LobbySystem.currentLobbyPlayerDataList " .. tostring(next(LobbySystem.currentLobbyPlayerDataList) == nil))
    for k,v in pairs(LobbySystem.currentLobbyPlayerDataList) do
        log(playerData.gid .. " " .. v.gid .. "aaaaaaaaaaaaaaaaaa" .. tostring(playerData.gid == v.gid))
        if tostring(playerData.gid) == tostring(v.gid) then
            return true
        end
    end

    return false
end

function LobbyUI:CheckLobbyMenuOpenWithoutTips(menuId)
    if LobbySystem.LobbyMenuOpenStatus[menuId] == nil then
        return true
    else
        if LobbySystem.LobbyMenuOpenStatus[menuId].is_open == 0 then
            return false
        end
        return true
    end
end

function EventSetInfo_Push()
end

-----------------------------------------------------
----------- 组队进入\退出玩家，创建模型 -------------
BP_LOBBY_SPAWNPOS = 0

function LobbyUI:SpawnPlayer(playerData, spawn)
    log("spawnPlayer " .. playerData.gid .. tostring(spawn))
    BP_STRUCT_SpawnPlayerData =
    {
        index = BP_LobbyPlayerNum,
        gid = tostring(playerData.gid),
        headId = playerData.avatar.headid,
        sex = playerData.avatar.gamegender,
        headShow = playerData.headShow or 0,
        weaponResId = playerData.weaponId or 0,
        weaponSkinId = playerData.weaponSkinId or 0,
        bagSkinInsId = playerData.bagSkinInsId or 0,
        BP_ARRAY_AvatarList = playerData.BP_ARRAY_AvatarList or {},
    }
    local switchInfo = 0

    -- 处理皮肤
    if BP_STRUCT_SpawnPlayerData.weaponSkinId ~= 0 then
        BP_STRUCT_SpawnPlayerData.weaponResId = BP_STRUCT_SpawnPlayerData.weaponSkinId
    end

    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON] then
        switchInfo = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON].is_open or 0 
    end

    if switchInfo == 0 then
        log("LobbyUI:SpawnPlayer weapon Not Open")
        BP_STRUCT_SpawnPlayerData.weaponResId = 0
    end

    BP_STRUCT_SpawnPlayerData.sex = BP_STRUCT_SpawnPlayerData.sex - 1
    if BP_STRUCT_SpawnPlayerData.sex == 0 then --male
        table.insert(BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(playerData.avatar.beardid, playerData.avatar.beardcolor,0))
    end
    table.insert(BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(playerData.avatar.hairid,0,0))
    --log_tree("BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList", BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList)
    --log_tree("BP_STRUCT_SpawnPlayerData", BP_STRUCT_SpawnPlayerData);

    if spawn then
        --- 判断是否合法 ---
        if BP_LobbyPlayerNum >= 4 then
            log("To many player in lobby!!!!!")
            return
        end

        if IsPlayerAlreadyInLobby(playerData) then
            log("Player already in!!!!!  PlayerGID : " .. playerData.gid)
            return
        end
        ---------------------
        -- LuaClassObj.HandleUIMessage(bp_lobby, "SpawnPlayer")
        local avatar = TeamAvatarManager.CreateAvatar(BP_STRUCT_SpawnPlayerData)

        BP_LobbyPlayerNum = BP_LobbyPlayerNum + 1

        LobbyUI:SwitchToTeamorMenuCamera(false)

        -- 活动隐藏
        if BP_LobbyPlayerNum == 2 then
            LuaClassObj.HandleUIMessage(bp_lobby, "HideActivityBtnList")
        end

        -- 加入当前玩家数据
        BP_STRUCT_SpawnPlayerData.index = avatar.positionIndex
        LobbySystem.currentLobbyPlayerDataList[tostring(playerData.gid)] = BP_STRUCT_SpawnPlayerData
        --log_tree("currentlobbyplayerdata add:", LobbySystem.currentLobbyPlayerDataList)
        log("currentlobbyplayerdata add pos : "..tostring(BP_STRUCT_SpawnPlayerData.index) .. " BP_LobbyPlayerNum = "..BP_LobbyPlayerNum)

        if RoleInfoUI.IsRestoreMenu then
            LobbyUI:ShowLobbyPlayer(false)
        end
        return avatar.positionIndex
    else

        --- 判断是否合法 ----
        if BP_LobbyPlayerNum <= 0 then
            log("No player in lobby!!!!!")
            return
        end

        if not IsPlayerAlreadyInLobby(playerData) then
            log("Player is not in!!!!!  PlayerGID : " .. playerData.gid)
            return
        end
        ----------------------
        TeamAvatarManager.DestroyAvatar(BP_STRUCT_SpawnPlayerData)
        -- LuaClassObj.HandleUIMessage(bp_lobby, "DelPlayer")

        BP_LobbyPlayerNum = BP_LobbyPlayerNum - 1

        LobbyUI:SwitchToMainCamera(false)
        -- 活动显示
        if BP_LobbyPlayerNum == 1 then
            LuaClassObj.HandleUIMessage(bp_lobby, "ShowActivityBtnList")
        end
        -- 删除当前玩家数据
        LobbySystem.currentLobbyPlayerDataList[tostring(playerData.gid)] = nil
        --log_tree("currentlobbyplayerdata del:", LobbySystem.currentLobbyPlayerDataList)

        if RoleInfoUI.IsRestoreMenu then
            LobbyUI:ShowLobbyPlayer(false);
        end
        return
    end
end

function EventSpawnPlayer()
	local oldTeamInfo = TeamUpSystem.TeamInfo;
	if oldTeamInfo == nil then
		return
	end
	--单人不需要替换模型
	if oldTeamInfo.player_count == 1 then
		return;
	end
	--删除旧的模型
	for k1,v1 in pairs(oldTeamInfo.members) do
		local _oldGid = k1;
		if k1 ~= TeamUpSystem.MyUserID then

			local _sex = 1;
			if v1.gender  ~= nil then
				_sex = v1.gender;
			end	

			local wareArray = {};
			if v1.wear_ext ~= nil then
				for wk,wv in pairs(v1.wear_ext) do
					table.insert(wareArray, LobbyUI.MakeClientAvatarWearInfo(wv));
				end
			else
				log("UpdateMemberModle v1.wear_ext = nil");
			end

			local playerData ={
				gid = _oldGid,
				sex = _sex,		
				BP_ARRAY_AvatarList = wareArray,
				avatar = v1.avatar,
				bagSkinInsId = v1.skin_info.bag_skin,
				headShow = v1.skin_info.head_show,
			};
			--log_tree("UpdateMemberModle del", playerData);	
			LobbyUI:SpawnPlayer(playerData, false);
		end
	end

	--重新加载新的模型
	for k2,v2 in pairs(oldTeamInfo.members) do
		local _newGid1 = k2;
		if k2 ~= TeamUpSystem.MyUserID then

			local _sex = 1;
			if v2.gender  ~= nil then
				_sex = v2.gender;
			end	

			local wareArray = {};
			if v2.wear_ext ~= nil then
				for wk1,wv1 in pairs(v2.wear_ext) do
					table.insert(wareArray, LobbyUI.MakeClientAvatarWearInfo(wv1));
				end
			else
				log("UpdateMemberModle v2.wear_ext = nil");
			end

			local head_show = 0;
			if v2.skin_info ~= nil then
				if(v2.skin_info.head_show == 0 or v2.skin_info.head_show == v2.skin_info.helmet_skin) then
					local head = v2.wear[1];
					if(head ~= nil) then
						--log_tree("head", head);
						for i, v in pairs(wareArray) do
							if(v.resID == head[1]) then
								v.resID = 0;
							end
						end
					end
					head_show = DataMgr.GetEquipmentItemIDByResID(v2.skin_info.helmet_level, v2.skin_info.head_show);
				end
			end

			local playerData ={
				gid = _newGid1,
				sex = _sex,		
				BP_ARRAY_AvatarList = wareArray,
				avatar = v2.avatar,
				bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(v2.skin_info.bag_level ,v2.skin_info.bag_skin),
				headShow = head_show,
			};
			--log_tree("UpdateMemberModle", playerData);	
			LobbyUI:SpawnPlayer(playerData, true);
		end
	end
end

--sami 创建人物模型，个人信息界面使用
--[[playerData = {
    rolewear_res,
    avater_info,
};]]
function LobbyUI:CreateRoleInfoPlayer(roleData)
    log_tree(" roleData.avatar_show",  roleData.avatar_show)
    local rolewear = {}
    local headResId = 0;
    local weaponResId = 0;
    local weaponSkinId = 0;
    local wear_ext = roleData.avatar_show.wear_ext or {};
    for k,v in pairs(wear_ext) do
        --服装
        local wearInfo = LobbyUI.MakeClientAvatarWearInfo(v);
        if k >= 1 and k <= 5 or k == 10 then
            table.insert(rolewear, wearInfo);
        end
        if k == 9 then
            headResId = wearInfo.resID;
        end
        --武器
        if k == 13 then
            weaponResId = wearInfo.resID;
        end
        if k == 14 then
            weaponSkinId = wearInfo.resID;
        end
        log("LobbyUI:CreateRoleInfoPlayer " ..wearInfo.resID)
    end

    log_tree("beforerolewear ", rolewear);
    local skin_info = roleData.avatar_show.skin_info or {0, 0, 0, 1, 1};
    local head_show = skin_info.head_show or 0;
    local bag_skin = skin_info.bag_skin or 0;
    local helmet_skin = skin_info.helmet_skin or 0;
    local bag_level = skin_info.bag_level or 1; 
    local helmet_level = skin_info.helmet_level or 1;
    if(head_show == helmet_skin or head_show == 0) then
        local head = wear_ext[1];
        if(head ~= nil) then
            for i, v in pairs(rolewear) do
                if(v.resID == head[1]) then
                    v.resID = 0;
                end
            end
        end
    else
        head_show = 0;
    end

    if(head_show ~= 0) then
        head_show = DataMgr.GetEquipmentItemIDByResID(helmet_level, head_show);
    end
    
    log_tree("rolewear ", rolewear);

    BP_STRUCT_SpawnPlayerData =
    {
        gid = "100",
        sex = roleData.avatar_show.gender - 1,
        headId = headResId,
        index = 0,
        BP_ARRAY_AvatarList = rolewear,
        weaponResId = weaponResId,
        weaponSkinId = weaponSkinId,
        bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(bag_level ,bag_skin) or 0,
        headShow = head_show or 0,
    }
    log_tree("CreateRolePlayer BP_STRUCT_SpawnPlayerData", BP_STRUCT_SpawnPlayerData)
    RoleInfoUI._roleInfoAvatar = nil
    if _G.writeLog then _G.writeLog("CreateRoleInfoPlayer: data built, existing lobby avatar will be used") end
end

--sami删除人物模型，个人信息界面使用
function LobbyUI:DelRoleInfoPlayer()
    if _G.writeLog then _G.writeLog("DelRoleInfoPlayer: no-op (using lobby avatar)") end
end

function LobbyUI:ShowLobbyPlayer(bShow)
    if bShow then
        TeamAvatarManager.ShowAllAvatar()
        -- LuaClassObj.HandleUIMessage(bp_lobby, "ShowLobbyPlayer");
    else
        -- LuaClassObj.HandleUIMessage(bp_lobby, "HideLobbyPlayer");
        TeamAvatarManager.HideAllAvatar()
    end
end

function EventUpdatePlayer()
	LobbyUI:UpdatePlayer();
end

function LobbyUI:UpdatePlayer()
    log("LobbyUI:UpdatePlayer")
    BP_STRUCT_SpawnPlayerData =
    {
        index = 1,
        weaponResId = 0,
        weaponSkinId = 0,
        BP_ARRAY_AvatarList = {},
        headId = DataMgr.avatarData.headid,
        sex = DataMgr.avatarData.gamegender,
        gid = tostring(DataMgr.roleData.uid),
    }
    local petTypeID = 0
    local petLevel = 0
    local rolewear = {}
    local weaponID = DataMgr.GetCurrentWeaponID()
    local pet = TeamAvatarManager.GetMainAvatar():GetShowingAvatar():GetPet()

    if pet ~= nil then
        petTypeID = pet:GetPetTypeID()
        petLevel = pet:GetLevel()
    end

    TeamAvatarManager.DestroyAvatar(BP_STRUCT_SpawnPlayerData)

    for k,v in pairs(DataMgr.rolewear) do
        if (DataMgr.GetHallDepotItemDataByInsID(v) ~= nil) then
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            table.insert(rolewear, LobbyUI.CreateClientAvatarWearInfo(itemInfo.resID, itemInfo.colorID, itemInfo.patternID)); 
        end
    end
    --log_tree("LobbyUI:UpdatePlayer inst id", DataMgr.rolewear)
    --log_tree("LobbyUI:UpdatePlayer", rolewear)

    BP_STRUCT_SpawnPlayerData =
    {
        index = 1,
        weaponSkinId = 0,
        weaponResId = weaponID,
        BP_ARRAY_AvatarList = rolewear,
        headId = DataMgr.avatarData.headid,
        sex = DataMgr.avatarData.gamegender,
        gid = tostring(DataMgr.roleData.uid),
    }

    BP_STRUCT_SpawnPlayerData.sex = BP_STRUCT_SpawnPlayerData.sex - 1
    if BP_STRUCT_SpawnPlayerData.sex == 0 then --male
        table.insert(BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(DataMgr.avatarData.beardid, DataMgr.avatarData.beardcolorid,0))
    end
    table.insert(BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(DataMgr.avatarData.hairid,0,0))

    LobbySystem.currentLobbyPlayerDataList[tostring(BP_STRUCT_SpawnPlayerData.gid)] = BP_STRUCT_SpawnPlayerData
    TeamAvatarManager.CreateAvatar(BP_STRUCT_SpawnPlayerData)
    if pet~= nil then
        TeamAvatarManager.CreatePet(DataMgr.roleData.uid, petTypeID, petLevel)
    end

    if RoleInfoUI.IsRestoreMenu then
        LobbyUI:ShowLobbyPlayer(false);
    end
end

-- 获取组队玩家位置index
function LobbyUI:GetSpawnPlayerPos(uid)
    if LobbySystem.currentLobbyPlayerDataList[tostring(uid)] ~= nil then
        return LobbySystem.currentLobbyPlayerDataList[tostring(uid)].index
    else
        return nil
    end
end

function LobbyUI:MakeSpawnPlayerData(playerData)
    BP_STRUCT_SpawnPlayerData =
    {
        index = 0,
        gid = tostring(playerData.gid),
        headId = playerData.avatar.headid,
        sex = playerData.avatar.gamegender,
        headShow = playerData.headShow or 0,
        weaponResId = playerData.weaponId or 0,
        weaponSkinId = playerData.weaponSkinId or 0,
        bagSkinInsId = playerData.bagSkinInsId or 0,
        BP_ARRAY_AvatarList = playerData.BP_ARRAY_AvatarList or {},
    }
    local switchInfo = 0

    -- 处理皮肤
    if BP_STRUCT_SpawnPlayerData.weaponSkinId ~= 0 then
        BP_STRUCT_SpawnPlayerData.weaponResId = BP_STRUCT_SpawnPlayerData.weaponSkinId
    end

    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON] then
        switchInfo = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON].is_open or 0;
    end

    if switchInfo == 0 then
        BP_STRUCT_SpawnPlayerData.weaponResId = 0
    end

    BP_STRUCT_SpawnPlayerData.sex = BP_STRUCT_SpawnPlayerData.sex - 1
    if BP_STRUCT_SpawnPlayerData.sex == 0 then --male
        table.insert(BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(playerData.avatar.beardid, playerData.avatar.beardcolor,0))
	end
    table.insert(BP_STRUCT_SpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(playerData.avatar.hairid,0,0))
end

function LobbyUI:ClearPlayerAvarar( )
    if DataMgr.rolewear then
        for _,v in pairs(DataMgr.rolewear) do
            local itemData = DataMgr.GetHallDepotItemDataByInsID(v);
            if itemData then
                LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemData.resID), false);
            end
        end
    end
    
    

    -- 重置队友的Avatar
    if nil ~= TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.members ~= nil then
        for k,v in pairs(TeamUpSystem.TeamInfo.members) do
            if k ~= TeamUpSystem.MyUserID then

                if v.wear_ext ~= nil then
                    for wk,wv in pairs(v.wear_ext) do
                        LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(k, wv), false);
                    end
                end

            end
        end
    end
end
-- 重置当前所有玩家的Avatar
function LobbyUI:ResetAllPlayerAvatar()
    -- 重置主角的Avatar
    log("[LLP]LobbyUI:ResetAllPlayerAvatar");
    log_tree("DataMgr.rolewear", DataMgr.rolewear)
    local rolewear = {}
    for k,v in pairs(DataMgr.rolewear) do
        if (DataMgr.GetHallDepotItemDataByInsID(v) ~= nil) then
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            table.insert(rolewear, LobbyUI.CreateClientAvatarWearInfo(itemInfo.resID, itemInfo.colorID, itemInfo.patternID))
        end
    end
    local weaponID = DataMgr.GetCurrentWeaponID()

    local head_show = 0;
    if DataMgr.head_show == 0 or DataMgr.head_show == tonumber(DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex]) then
        if(DataMgr.rolewear[1] ~= nil) then
            log_tree("DataMgr.rolewear", DataMgr.rolewear)
            local head = DataMgr.rolewear[1];
            for i, vk in pairs(rolewear) do
                if(vk.resID == DataMgr.GetHallDepotItemDataByInsID(head)) then
                    vk.resID = 0;
                end
            end
        end
    end

    if DataMgr.head_show == tonumber(DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex]) then
        head_show = DataMgr.GetEquipmentItemIDByResID(DataMgr.helmet_level, DataMgr.GetEquipmentResID(DataMgr.HelmetSkinTableIndex))
    end

    BP_STRUCT_SpawnPlayerData =
    {
        gid = tostring(DataMgr.roleData.uid),
        sex = DataMgr.avatarData.gamegender,
        headId = DataMgr.avatarData.headid,
        index = 1,
        BP_ARRAY_AvatarList = rolewear,
        weaponResId = weaponID,
        weaponSkinId = 0,
        bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(DataMgr.bag_level, DataMgr.GetEquipmentResID(DataMgr.BagSkinTableIndex)) or 0,
        headShow = head_show,
    }
    if nil == UIManager.GetUI(eUIType.eUnknowPassUI)
            and not AllianceCompetitionShopUI.isShow then
        log_tree("BP_STRUCT_SpawnPlayerData", BP_STRUCT_SpawnPlayerData)
        -- LuaClassObj.HandleUIMessage(bp_lobby, "ResetPlayerAvatar");
        TeamAvatarManager.PutoffInvalidEquipments(BP_STRUCT_SpawnPlayerData)
    end

    -- 重置队友的Avatar
    if nil ~= TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.members ~= nil then
        -- print_r(TeamUpSystem.TeamInfo.members)
        for k,v in pairs(TeamUpSystem.TeamInfo.members) do
            if k ~= TeamUpSystem.MyUserID then
                local _sex = 1;
                if v.gender  ~= nil then
                    _sex = v.gender;
                end

                local wareArray = {};
                if v.wear_ext ~= nil then
                    for wk,wv in pairs(v.wear_ext) do
                        table.insert(wareArray, LobbyUI.MakeClientAvatarWearInfo(wv));
                    end
                end

                local head_show = 0;
                if v.skin_info ~= nil then
                    if(v.skin_info.head_show == 0 or v.skin_info.head_show == v.skin_info.helmet_skin) then
                        if(v.wear_ext ~= nil) then
                            local head = v.wear_ext[1];
                            if(head ~= nil) then
                                log_tree("head", head);
                                for i, vk in pairs(wareArray) do
                                    if(vk.resID == head[1]) then
                                        vk.resID = 0;
                                    end
                                end
                            end 
                        end
                        if(v.skin_info.head_show ~= 0) then
                            head_show = DataMgr.GetEquipmentItemIDByResID(v.skin_info.helmet_level, v.skin_info.head_show); 
                        end
                    end
                end

                local playerData ={
                    gid = k,
                    sex = _sex,
                    BP_ARRAY_AvatarList = wareArray,
                    avatar = v.avatar,
                    bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(v.skin_info.bag_level ,v.skin_info.bag_skin),
                    headShow = head_show,
                };

                log_tree("UpdateMemberModle del", playerData);
                -- print_r(playerData)
                LobbyUI:MakeSpawnPlayerData(playerData)
                TeamAvatarManager.PutoffInvalidEquipments(playerData)
                -- LuaClassObj.HandleUIMessage(bp_lobby, "ResetPlayerAvatar");
            end
        end
    end
end


-----------------------------------------------
-------- avatar变更接口 -----------------------
function LobbyUI:AvatarChange(playerData, open, changeReason)
    log("LobbyUI:AvatarChange");
	--logtree("LobbyUI:AvatarChange playerData = ", playerData);
	--log("LobbyUI:AvatarChange" .. debug.traceback());
    --检查是否可改变，例如通行证打开时只允许通行证修改自己的穿戴
    local ret = LobbyUI:CheckAvatarChange(playerData.gid, changeReason);
    if not ret then
        BP_IsWardrobePutOnAvatar = false;
        log("LobbyUI:AvatarChange CheckAvatarChange not pass");
        return;
    end

    --人物没有在大厅
    if not IsPlayerAlreadyInLobby(playerData) then
        BP_IsWardrobePutOnAvatar = false;
        log("LobbyUI:AvatarChange : Player is not in!!!!!  PlayerGID : " .. playerData.gid)
        return;
    end

    --    -- 修复查看其他人外观时断线重连后，衣服穿帮的问题 by lepengli
    --    if not BP_LobbyPlayerShow then
    --        log("LobbyUI:AvatarChange : Player is not show in lobby: " .. playerData.gid)
    --        return
    --    end

    BP_STRUCT_AvatarChange =
    {
        gid = tostring(playerData.gid),
        resId = playerData.resId,
        colorID = playerData.colorID,
        patternID = playerData.patternID,
    }
    --log_tree("BP_STRUCT_AvatarChange", BP_STRUCT_AvatarChange)
    --调用大厅蓝图穿装，脱装
    if open then
        -- LuaClassObj.HandleUIMessage(bp_lobby, "PutOnAvatar")
        TeamAvatarManager.PutonEquipment(
            BP_STRUCT_AvatarChange.gid,
            BP_STRUCT_AvatarChange.resId, 
            BP_STRUCT_AvatarChange.colorID, 
            BP_STRUCT_AvatarChange.patternID
        )
    else
        if type(BP_STRUCT_AvatarChange.resId) == "table" then
            for i,v in ipairs(BP_STRUCT_AvatarChange.resId) do
                TeamAvatarManager.PutoffEquipment(
                    BP_STRUCT_AvatarChange.gid,
                    v
                )
            end
        else
            TeamAvatarManager.PutoffEquipment(
                BP_STRUCT_AvatarChange.gid,
                BP_STRUCT_AvatarChange.resId
            )
        end
       
        -- LuaClassObj.HandleUIMessage(bp_lobby, "PutOffAvatar")
    end
    BP_IsWardrobePutOnAvatar = false;

    if RoleInfoUI.IsRestoreMenu then
        Timer.InsertTimer(2, test, false, false);
        LobbyUI:ShowLobbyPlayer(false);
    end
end
------------------------------------------------


-- 测试接口 --------------------------------------------
function test()
    LobbyUI:ShowLobbyPlayer(false);
end
function EventTestSpawnPlayer()
    local avatarSt =
    {
        gamegender = 1,
        headid = 401999,
        hair = 406001
    }
    local playerData =
    {
        gid = "1",
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = {}
    }

    LobbyUI:SpawnPlayer(playerData, true)
end

function EventTestSpawnPlayer2()
    local avatarSt =
    {
        gamegender = 1,
        headid = 401999,
        hair = 406001
    }
    local playerData =
    {
        gid = "2",
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = {}
    }


    LobbyUI:SpawnPlayer(playerData, true)
end

function EventTestSpawnPlayer3()
    local avatarSt =
    {
        gamegender = 1,
        headid = 401999,
        hair = 406001
    }
    local playerData =
    {
        gid = "3",
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = {}
    }


    LobbyUI:SpawnPlayer(playerData, true)
end

function EventTestRemovePlayer()
    local avatarSt =
    {
        gamegender = 1,
        headid = 401999,
        hair = 406001
    }
    local playerData =
    {
        gid = "1",
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = {}
    }

    LobbyUI:SpawnPlayer(playerData, false)
end

function EventTestRemovePlayer2()
    local avatarSt =
    {
        gamegender = 1,
        headid = 401999,
        hair = 406001
    }
    local playerData =
    {
        gid = "2",
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = {}
    }


    LobbyUI:SpawnPlayer(playerData, false)
end
function EventTestRemovePlayer3()
    local avatarSt =
    {
        gamegender = 1,
        headid = 401999,
        hair = 406001
    }
    local playerData =
    {
        gid = "3",
        avatar = avatarSt,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = {}
    }


    LobbyUI:SpawnPlayer(playerData, false)
end


function EventAvatarChange()

    local playerData =
    {
        gid = tostring(DataMgr.roleData.uid ),
        resId = 403000,
    }
    LobbyUI:AvatarChange(playerData, true)
end


function EventTeamUpRings()
    local teamNum = 4
    local uidList = {}

    LobbyUI:CreateTeamUpRings(teamNum, uidList)
end

function LobbyUI:AvatarChangePose()
    LuaClassObj.HandleUIMessage(bp_lobby, "ChangeAvatarPose");
end

-----------------------------------------------------------

--创建脚底光圈接口
function LobbyUI:CreateTeamUpRings(teamNum, uidList)

    --[[BP_STRUCT_TeamUpRingsChange =
    {
        teamMemberNum = teamNum,
        BP_ARRAY_CurrentTeamMemberGidList = uidList
    }

    LuaClassObj.HandleUIMessage(bp_lobby, "CreateRings")]]--

end

-- 红点状态更新
function LobbyUI:LobbyRedPointUpdate(menuId, show)
    if BP_CurrentMenuId ~= menuId or BP_CurrentRedPointStatus ~= show then
        BP_CurrentMenuId = menuId
        BP_CurrentRedPointStatus = show
        
        LuaClassObj.HandleUIMessage(bp_lobby, "UpdateRedPointStatus")
    end
end


--系统消息数量更新（数量控制显示与否）
function LobbyUI:LobbySystemMessageUpdate(menuId,count)
    if menuId == BP_ENUM_LOBBY_MENU_FRIEND then
        BP_CurrentMenuId = menuId
        BP_FriendApplyMessageCount = count
    end

    log("LobbySystemMessageUpdate "..tostring(count))
    LuaClassObj.HandleUIMessage(bp_lobby,"UpdateSystemMessageCount")
    if TeamUPFriendUI.isShowing == true then
        LobbyUI.ShowAddFriendMessage()
    end
end

function EventTestRedpoint()
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_SHARE_AWARD, true)
end

function EventTestLevelUp()
    LevelUpUI:Init()
end

-- 打开GM面板
function EventOpenGMMenu()
    GM_UI:ShowPanel();
end


function EventTestScrollMsg()
    EventShowNextMsg()
end


function EventOnClickCorps()
    log("EventOnClickCorps - blocked in offline mode")
    PopUpNoticeUI.ShowNewNotice("Clan not available")
end


function EventLobbyOpenArmory()
    HideLobby()
    pcall(function() LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu") end)
    pcall(function() ArmoryUI:OpenArmoryMainUI() end)
end

function EventOpenMissionUI()
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_TASK) then
        BP_Lobby_MenuOpen = false
        return
    end
    BP_Lobby_MenuOpen = true
    EventTaskShowUI()

    ClientSendBAReport(BP_BA_LOBBY_TASK_PANEL, 0);
end

function EventInitActivityListComplete()
    ShareAwardMgr.CheckAwardRedPoint();--分享有礼红点
    LobbyUI:UpdateLobbyActGroupRedDot()
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdateCollectEquipRedPoint")
end


-- 回到大厅重播跑马灯
function EventRerollAllScrollMsg()
    ScrollNoticeUI:RerollScrollNotice()
end

-- 打开全屏面板隐藏跑马灯
function EventHideScrollMsg()
    ScrollNoticeUI:HideScrollNotice()
end

function UpdateLobbyTaskRedDot(is_show_redDot)
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_TASK, is_show_redDot);
end

function UpdateLobbyCorpsRedDot(hasReddot)
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_CORPS, hasReddot)
end

function UpdateSettingRedPoint()
    log("UpdateSettingRedPoint");
    LuaClassObj.HandleUIMessage(bp_lobby, "CheckSettingRedPoint")
end

function LobbyUI:UpdateLobbyActGroupRedDot()
    local isShow = ActivityGroupSystem.CheckShowRedPoint()
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_OPENSERVICE_CARNIVAL, isShow);
end

-- 判断功能是否开启
BP_Lobby_MenuOpen = true
BP_ARRAY_Lobby_ActivityNotOpenList = {1}

function LobbyUI:CheckLobbyMenuOpen(menuId , isShowTip)
    if isShowTip == nil then
        isShowTip = true;
    end
    if LobbySystem.LobbyMenuOpenStatus[menuId] == nil then
        return true
    end

    if LobbySystem.LobbyMenuOpenStatus[menuId].is_open == 0 then
        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local text = Client.GetTableData("LocalizeRes", "120001").TextValue;

        if isShowTip then
            CommonMessageBoxUI:ShowPanel(1, title, text);
        end

        return false
    else
        return true
    end

end

--判断是否可以切换穿戴
function LobbyUI:CheckAvatarChange(gid, reason)
    local myId = tostring(DataMgr.roleData.uid);
    --只检测自己
    if myId == tostring(gid) then
        if AllianceCompetitionShopUI and AllianceCompetitionShopUI.isShow then
            if reason == nil then
                return false;
            else
                return true;
            end
        else
            return true;
        end
    else
        return true;
    end
end

-- 相机切换接口
function LobbyUI:LockSwitchLobbyCamera(isLock)
    BP_LobbyCameraSwitchLock = isLock;
end

function LobbyUI:CheckCanSwitchToLobbyCamera()
    local itemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview");
    local ui_manager = require("ui.manager");
    local ok, ret = pcall(function()
        if BP_LobbyCameraSwitchLock then
            log("LobbyUI:SwitchCheck--BP_LobbyCameraSwitchLock "..tostring(BP_LobbyCameraSwitchLock));
            return true;
        elseif BP_CreateRole_LobbyToAvatar == 1 then
            log("LobbyUI:SwitchCheck--BP_CreateRole_LobbyToAvatar "..tostring(BP_CreateRole_LobbyToAvatar));
            return true;
        elseif ArmoryUI and ArmoryUI.isShow then
            log("LobbyUI:SwitchCheck--ArmoryUI.isShow "..tostring(ArmoryUI.isShow));
            return true;
        elseif WarZoneRankUI and WarZoneRankUI.isShow then
            log("LobbyUI:SwitchCheck--WarZoneRankUI.isShow "..tostring(WarZoneRankUI.isShow));
            return true;
        elseif OpenBoxtUI and OpenBoxtUI.isShow then
            log("LobbyUI:SwitchCheck--OpenBoxtUI.isShow "..tostring(OpenBoxtUI.isShow).." "..tostring(OpenBoxtUI.isShow10Box));
            return true;
        elseif UnknowPassUI and UnknowPassUI.isShowing then
            log("LobbyUI:SwitchCheck--UnknowPassUI.isShowing "..tostring(UnknowPassUI.isShowing));
            return true;
        elseif AllianceCompetitionShopUI and AllianceCompetitionShopUI.isShow then
            log("LobbyUI:SwitchCheck--AllianceCompetitionShopUI.isShow "..tostring(AllianceCompetitionShopUI.isShow));
            return true;
        elseif RoleInfoUI.IsShow and RoleInfoUI.IsRestoreMenu then
            log("LobbyUI:SwitchCheck--RoleInfoUI.IsShow "..tostring(RoleInfoUI.IsShow).." "..tostring(RoleInfoUI.IsRestoreMenu));
            return true;
        elseif PDD_System_UI and PDD_System_UI.bShowing == true then
            log("[HHF]LobbyUI:CheckCanSwitchToLobbyCamera, In PDDSystem and do not change camera.");
            return true;
        elseif ItemUpgradeUI and ItemUpgradeUI.isShow == true then
            log("[HHF]LobbyUI:CheckCanSwitchToLobbyCamera, In ItemUpgradeSystem and do not change camera.");
            return true;
        elseif StoreMainUI and StoreMainUI.bShow == true then
            log("[HHF]LobbyUI:CheckCanSwitchToLobbyCamera, In NewStoreSystem and do not change camera.");
            return true;
        elseif SupplyMainUI and SupplyMainUI.bShow == true then
            log("[HHF]LobbyUI:CheckCanSwitchToLobbyCamera, In NewStoreSystem and do not change camera.");
            return true;
        elseif RoleInfoUI.IsShow  then
            log("[HHF]LobbyUI:CheckCanSwitchToLobbyCamera, In RoleInfoUI and do not change camera.");
            return true;
        elseif itemPreviewSystem.isShow == true then
            log("itemPreviewSystem lock camera");
            return true;
        elseif ui_manager.IsUIShow(ui_manager.UI_Config.pet_main) then
            log("ui_manager.UI_Config.pet_main lock camera");
            return true;
        elseif ui_manager.IsUIShow(ui_manager.UI_Config.character_main) then
            log("ui_manager.UI_Config.character_main lock camera");
            return true
        else
            return false;
        end
    end)
    if ok then return ret end
    return false
end

function LobbyUI:SwitchToMainCamera(isMenu)
    if LobbyUI:CheckCanSwitchToLobbyCamera() then
        log("LobbyUI:SwitchToMainCamera(isMenu) can not switch");
        return;
    end

    log("LobbyUI:SwitchToMainCamera(isMenu)"..tostring(isMenu).." "..tostring(BP_LobbyPlayerNum))
    if (BP_LobbyPlayerNum == 1 and ((not (ShopUI or {}).isShow and not (WardrobeUI or {}).isShowing) or isMenu)) then
        log("LobbyUI:SwitchCamera(succ): SwitchCamera_CloseMenu");
        LuaClassObj.HandleUIMessage(bp_lobby, "SwitchCamera_CloseMenu");
    end

end

function LobbyUI:SwitchToTeamorMenuCamera(isMenu)
    if LobbyUI:CheckCanSwitchToLobbyCamera() then
        log("LobbyUI:SwitchToTeamorMenuCamera(isMenu) can not switch");
        return;
    end

    log("LobbyUI:SwitchToTeamorMenuCamera(isMenu)"..tostring(isMenu).." "..tostring(BP_LobbyPlayerNum))
    if (isMenu and BP_LobbyPlayerNum == 1) or (BP_LobbyPlayerNum > 1) then
        log("LobbyUI:SwitchCamera(succ): SwitchCamera_OpenMenu");
        LuaClassObj.HandleUIMessage(bp_lobby, "SwitchCamera_OpenMenu");
    end

end

local tickTimes = 0;
function LobbyUI.Tick()
    if not LobbyModeSwitched then
        return;
    end

    tickTimes = tickTimes + 1;
    if tickTimes > 10 then
        tickTimes = 0;
        local dateTime = os.date("!*t", FuncUtil.GetServerTimeInSec());
        if dateTime.day ~= LobbyUI.lastDay then
            LobbyUI.lastDay = dateTime.day;
            local interval = math.random(60);
            log("[HHF]LobbyUI.Tick, random = " .. tostring(interval));
            LobbyUI.zeroPointTimer = Timer.InsertTimer(interval, LobbyUI.OnTimerNextDayByRandomDelay, false);
        end
    end
end

function LobbyUI.OnTimerNextDayByRandomDelay()
    log("[HHF]LobbyUI.OnTimerNextDayByRandomDelay, post event = EVENTID_NEXTDAY_ZERO");
    if LobbyUI.zeroPointTimer ~= nil then
        Timer.RemoveTimer(LobbyUI.zeroPointTimer);
        LobbyUI.zeroPointTimer = nil;
    end

    EventSystem:postEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO);
end

function LobbyUI.OnLobbyNextDayHandler()
    log("[HHF]LobbyUI.OnLobbyNextDayHandler");
    --if MallSystemUI_2.isShowing == true then
    --    MallSystemUI_2.UpdateStoreData();
    --end

    ShopSystem.shop_itemlist_req(16);
    ShopSystem.shop_itemlist_req(17);

    --重现获取次数，修复跨越24点之后，每日赠送次数限制重置
    ShopGiftPacketLogic.market_gift_give_count_req();
end

function LobbyUI.OnStoreTabList()
    log("[HHF]LobbyUI.OnStoreTabList");
    StoreMainUI.InitTabListInfo();
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "MallHotPointUpdate");
end

function LobbyUI.OnSupplyTabList()
    if GlobalData.IsJapanOrKorea() then
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "MallHotPointUpdate");
    else
        EventLobbyMallGetHotPointState();
    end
end

function LobbyUI.OnActivityChange(eventType, eventID, changeList)
    -- 补给入口红点
    if changeList.typeList ~= nil and
        (changeList.typeList[ActivityType["SUPPLY_ACTIVITY_MUST_DROP"]] or
         changeList.typeList[ActivityType["SUPPLY_ACTIVITY_EXTRA_BOX"]] or
         changeList.typeList[ActivityType["SUPPLY_ACTIVITY_LUCKY"]]) then
        if GlobalData.IsJapanOrKorea() then
            LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "MallHotPointUpdate");
        else
            EventLobbyMallGetHotPointState();
        end
    end
    -- 首充+折扣活动
    LobbyUI.HandleTheFirstChargeIcon();
end

-- 获取收集装备活动状态
function EventGetCollectEquipOpenState()
    --BP_COLLECT_EQUIPMENT_Open = RedPacketSystem.IsActivityInTime( ActivityType.COLLECT_EQUIPMENT )
end

-- 获取刺激盛宴状态
function EventGetExcitingPartyOpenState()
    -- BP_Exicting_Party_Open = false
    --BP_Exciting_Party_Open = ExcitingPartyMgr.isInTime
end

-- 打开刺激盛宴UI
function EventOpenGetExcitingPartyUI()
    --PromotionMgr.SendGetPromotionInfo()
end

function EventOpenShopLimitUI()

end

-- 注释删除了的函数
function EventGetShopLimitTitle()
    --local limit = ShowLimitSystem.GetShowLimit()
    --if #limit == 0 then
    --    BP_STRUCT_ShopLimit.IsOpen = false
    --    return
    --end
    --local shopLimitInfo = limit[1]
    --BP_STRUCT_ShopLimit.IsOpen = true
    --BP_STRUCT_ShopLimit.Title = shopLimitInfo.typename
    --BP_STRUCT_ShopLimit.EndTime = shopLimitInfo.end_time
end

function UpdateLobbyActivityRedPoint(is_show_redPoint)
    if is_show_redPoint then
        LuaClassObj.HandleUIMessage(bp_lobby, "ShowActivityRedPoint");
    else
        LuaClassObj.HandleUIMessage(bp_lobby, "HideActivityRedPoint");
    end
end

---------------------------------------首充+折扣活动的icon显示需要在Lobby中处理
BP_TheFirstCharge_IconFlag = 0 --0无入口, 1显示首充Icon, 2显示折扣Icon
function LobbyUI.HandleTheFirstChargeIcon()
    log("HandleTheFirstChargeIcon");
    log("before HandleTheFirstChargeIcon, flag = "..BP_TheFirstCharge_IconFlag)
    if GlobalData.IsJapanOrKorea() then
        BP_TheFirstCharge_IconFlag = TheFirstChargeUI.RefreshData();
    end
    log("After HandleTheFirstChargeIcon, flag = "..BP_TheFirstCharge_IconFlag)
    if BP_TheFirstCharge_IconFlag == 2 then
        log("HandleTheFirstChargeIcon is 2");
        local isOpen = LobbyUI.HalloweenVehicleActivityIsOpen();
        if isOpen == true then
            log("HalloweenVehicleActivityIsOpen true");
            BP_TheFirstCharge_IconFlag = 0;
        else
            log("HalloweenVehicleActivityIsOpen false");
        end
    end
    LuaClassObj.HandleUIMessage(bp_lobby, "SetFirstCharge");
end

BP_TheFirstCharge_RedDot = false;   --首充小红点显示
function LobbyUI.HandleTheFirstChargeRedDot(isShow)
    BP_TheFirstCharge_RedDot = isShow;
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetFirstChargeRedDot");
end

--隐藏首充入口
function LobbyUI.HandleTheFirstChargeHide()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetFirstChargeHide");
end
-----------------------------------------
function EventOpenCollectEquipment( )
    local baseUrl = "https://pg.qq.com/act/a20180104share/index.shtml";

    local finalEncodeUrl = Client.GetEncodeUrl(baseUrl);
    log("finalEncodeUrl url = " .. finalEncodeUrl)
    local accessToken = Client.GetAccessToken(NetInterface);
    local urlWithToken = string.format( "%s&access_token=%s", finalEncodeUrl, accessToken )
    log("urlWithToken url = " .. urlWithToken)
    Client.OpenURL(urlWithToken);

end
function LobbyUI:UpdateFreeDataState()
    BP_Free_Data_Open = FreeDataStreamMgr.isFreeState
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdateFreeDataState")
end

function EventOpenXinyue()
    --XinyueSystem.OpenXinYueURL();
end

function EventOpenESportTV()
    if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
        Client.OpenURL("https://game.weixin.qq.com/cgi-bin/h5/static/embedgame/index.html?pt=1&gameid=wxc4c0253df149f02d");
    elseif _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
        Client.OpenURL("http://info.gamecenter.qq.com/cgi-bin/platform_game_handle_ticket?gc_t=1&url_id=1113");
    end
end


-- 免流
function EventOpenFreeDataUrl()
    FreeDataStreamMgr:OpenFreeDataUrl()
end

-- 打开活动集合页UI
function EventOpenActivityGroupUI()
    ActivityGroupShowUI()
end

function EventOpenQQVip()
    EventShowPlatQQVip();
end

function EventOpenQQlibao()
    local baseURL = "https://imgcache.qq.com/gc/gamecenterV2/dist/index/gift/search_gift.html?_wv=1031&_wwv=4&appid=1106467070&apptype=1&ADTAG=game_gift_juediqiusheng";
    Client.OpenURL(baseURL);
end


function EventOpenCommunityInLobby()
    local url = "https://pg.qq.com/m/ingame/all/index.shtml";
    log("EventOpenCommunityInLobby url = " .. url);
    GlobalData:JumpUrl(url);
end

function EventOpenHuati()
    --TopicQuanSystem.OpenTopicQuanURL();
end

-- 进入大厅后，读取本地记录，设置问卷活动已完成
function EventQuestionDone()
    ActivitySystem.questionDone = true
end

-- 设置宝箱数据,商城小红点用
function EventLobbyGetStoreBox()
    log("EventMallGetStoreBox");
    --if MallSystem.IsTabOpen(SHOP_BOX_INDEX) then
    --    BP_ARRAY_LobbyStoreBoxList = ShopSystem.BoxList;
    --else
        BP_ARRAY_LobbyStoreBoxList = {};
    --end
end

function EventLobbyGetStoreGiftBox()
    log("EventLobbyGetStoreGiftBox");
    --if MallSystem.IsTabOpen(GIFT_BOX_INDEX) then
    --    BP_ARRAY_LobbyStoreGiftBoxList = ShopSystem.BoxGiftList;
    --else
        BP_ARRAY_LobbyStoreGiftBoxList = {};
    --end
end

-- 双倍卡

BP_STRUCT_LOBBY_GoldExp_BuffInfo =
{
    name = "",
    timer = "",
};

BP_Lobby_Gold_Rate = 0;
BP_ARRAY_Lobby_GoldBuffInfo = {BP_STRUCT_LOBBY_GoldExp_BuffInfo = _G.BP_STRUCT_LOBBY_GoldExp_BuffInfo}

BP_Lobby_Exp_Rate = 0;
BP_ARRAY_Lobby_ExpBuffInfo = {BP_STRUCT_LOBBY_GoldExp_BuffInfo = _G.BP_STRUCT_LOBBY_GoldExp_BuffInfo}

BP_Lobby_Has_Gold_Rate = false;
BP_Lobby_Has_Exp_Rate = false;

function EventLobbyShowDoubleCard()
    LobbySystem.UpdateDoubleCardInfo();
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdateDoubleCardInfo");
end

function EventLobbyUpdateDoubleCardButton()
    LobbySystem.UpdateHasDoubleCard();
    LuaClassObj.HandleUIMessage(bp_lobby, "UpdateDoubleCardBtn");
end

function LobbyUI:ShowNewMessageTips(isShow)
    log("LobbyUI:ShowNewMessageTips" ..tostring(isShow))

    if isShow then
        LuaClassObj.HandleUIMessage(bp_lobby, "ShowNewMessageTips");
    else
        LuaClassObj.HandleUIMessage(bp_lobby, "HideNewMessageTips");
    end

end

function EventLobbyMallSetCurTime()
    local dateTime = os.date("*t", FuncUtil.GetServerTimeInSec());
    BP_Lobby_Mall_Cur_ServerTime = dateTime.year * 1000 +  dateTime.month * 100 + dateTime.day;
end

function EventLobbyMallGetHotPointState()
    BP_Lobby_Mall_Hot_Point_IsShow = false;--月卡红点

    if StoreRedDotModel.HasLobbyRedDot() then
        BP_Lobby_Mall_Hot_Point_IsShow = true;
    end

    --补给红点计算
    if StoreRedDotModel.HasLobbySupplyRedDot() then
        if GlobalData.IsJapanOrKorea() then
            BP_Lobby_Mall_Hot_Point_IsShow = true;
        else
            BP_Lobby_Supply_RedDot = true;
        end
    else
        BP_Lobby_Supply_RedDot = false;
    end

    if StoreIndiaUtils.IsShowRedPoint() then
        BP_Lobby_Mall_Hot_Point_IsShow = true;
    end

    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateSupplyBtn");
end

function EventLobbyMallGetMallSimpleInfoArr()
    BP_ARRAY_Lobby_Mall_Simple_List = {};
    local allDict = MallSystem.GetMallSimpleInfoDict();
    if allDict ~= nil then
        for tab1,v1 in pairs(allDict) do
            --if MallSystemUI_2.IsIgnoreTab1(tab1) == false then
                for tab2,v2 in pairs(v1) do
                    for index,id in ipairs(v2) do
                        table.insert(BP_ARRAY_Lobby_Mall_Simple_List,id);
                    end
                end
            --end
        end
    end

end

--------------------------------------------------------
BP_Lobby_WeaponStatusChange_UID = ""
BP_Lobby_WeaponStatusChange_WeaponResId = 0

-- 大厅人物装载武器接口 --
function LobbyUI:EquipWeapon(uid, weaponResId, skinId, reason)
    local switchInfo = LobbySystem.LobbyMenuOpenStatus and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON] and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON].is_open or 0;
    if switchInfo == 0 then
        log("LobbyUI:EquipWeapon Not Open")
        return
    end

    local ret = LobbyUI:CheckAvatarChange(uid, reason);
    if not ret then
        log("LobbyUI:EquipWeapon CheckAvatarChange not pass");
        return;
    end

    local playerData =
    {
        gid = tostring(uid)
    }
    if not IsPlayerAlreadyInLobby(playerData) then
        log("LobbyUI:EquipWeapon : Player is not in!!!!!  PlayerGID : " .. playerData.gid)
        return
    end

    --    -- 修复查看其他人外观时断线重连后，武器穿帮的问题 by lepengli
    --    if not BP_LobbyPlayerShow then
    --        log("LobbyUI:EquipWeapon : Player is not show in lobby: "..playerData.gid)
    --        return
    --    end

    skinId = skinId or 0
    skinId = tonumber(skinId)

    log("LobbyUI:EquipWeapon(uid, weaponResId) "..tostring(uid).." "..tostring(weaponResId).." "..tostring(skinId))
    BP_Lobby_WeaponStatusChange_UID = tostring(uid)
    if skinId ~= 0 then
        BP_Lobby_WeaponStatusChange_WeaponResId = skinId
    else
        BP_Lobby_WeaponStatusChange_WeaponResId = weaponResId
    end
    -- LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "EquipWeapon");
    TeamAvatarManager.PutonEquipment(tostring(uid), BP_Lobby_WeaponStatusChange_WeaponResId)

    if RoleInfoUI.IsRestoreMenu then
        LobbyUI:ShowLobbyPlayer(false);
    end
end

function LobbyUI:UnEquipWeapon(uid, reason)
    local ret = LobbyUI:CheckAvatarChange(uid, reason);
    if not ret then
        log("LobbyUI:UnEquipWeapon CheckAvatarChange not pass");
        return;
    end

    local playerData =
    {
        gid = tostring(uid)
    }
    if not IsPlayerAlreadyInLobby(playerData) then
        log("LobbyUI:UnEquipWeapon : Player is not in!!!!!  PlayerGID : " .. playerData.gid)
        return
    end

    log("LobbyUI:UnEquipWeapon(uid) "..tostring(uid))
    BP_Lobby_WeaponStatusChange_UID = tostring(uid)
    -- LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UnEquipWeapon");
    -- TeamAvatarManager.PutoffEquipment(tostring(uid), BP_Lobby_WeaponStatusChange_WeaponResId)
    TeamAvatarManager.PutoffSubtype(tostring(uid), LobbyAvatar.EQUIPMENT_SUBTYPE_WEAPON)
end
--------------------------

--------------------------
BP_Lobby_ShowEmoteAction_UID = ""
BP_Lobby_ShowEmoteAction_EmoteResId = 0
BP_Lobby_ShowEmoteAction_Sex = 0

-- 大厅人物表情动作接口 --
function LobbyUI:ShowEmoteAction(uid, emoteId, sex, randSoundId, fromWhereType)
    local playerData =
    {
        gid = tostring(uid)
    }
    -- if not IsPlayerAlreadyInLobby(playerData) then
    --     log("LobbyUI:ShowEmoteAction : Player is not in!!!!!  PlayerGID : " .. playerData.gid)
    --     return
    -- end
    BP_Lobby_ShowEmoteAction_UID = tostring(uid)
    BP_Lobby_ShowEmoteAction_EmoteResId = emoteId

    TeamAvatarManager.PlayAction(BP_Lobby_ShowEmoteAction_UID, BP_Lobby_ShowEmoteAction_EmoteResId)

    -- Sync emote to all fake teammates
    if FakeFriendSystem and FakeFriendSystem._teammates then
        for _, tm in ipairs(FakeFriendSystem._teammates) do
            TeamAvatarManager.PlayAction(tostring(tm.gid), emoteId)
        end
    end

    -- if sex == nil then
    --     BP_Lobby_ShowEmoteAction_Sex = ProfileMgr.GetRoleSexByUid(uid)
    -- else
    --     BP_Lobby_ShowEmoteAction_Sex = sex
    -- end
    -- LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowEmoteAction");

    LobbyUI.PlayEmotionSound(emoteId, sex, randSoundId, uid, fromWhereType)
end

function LobbyUI.ShowPutOnAvatarTips(itemID1, itemID2)
    log("[LLP]LobbyUI.ShowPutOnAvatarTips:"..tostring(itemID1).."~~~"..tostring(itemID2));
    local itemCfg1 = Client.GetTableData("Item", itemID1);
    local itemCfg2 = Client.GetTableData("Item", itemID2);
    if itemCfg1 ~= nil and itemCfg2 ~= nil then
        local notice_content = "Notice:"..itemCfg1.ItemName.." Will Hide "..itemCfg2.ItemName;
        PopUpNoticeUI.ShowNewNotice(notice_content);
    end

end

--------------------------------------
------ Test Action

--[[
=======================地图下载界面相关=======================
--]]
BP_Struct_LobbyShowDownloadingMapInfo =
{
    state = 0,
    current = 0,
    total = 0,
    name = "",
    fileName = "",
    percent = 0,
};
BP_Array_LobbyShowDownloadingMapInfoList =
{
    BP_Struct_LobbyShowDownloadingMapInfo = _G.BP_Struct_LobbyShowDownloadingMapInfo,
};

BP_Lobby_IsDownloadingMap = false;
BP_Lobby_AllDownloadCurrent = 0;
BP_Lobby_AllDownloadTotal = 0;

function LobbyUI.UpdateDownloadingMapInfo()
    log("[HHF]LobbyUI.UpdateDownloadingMapInfo");
    BP_Lobby_IsDownloadingMap = false;
    BP_Lobby_AllDownloadCurrent = 0;
    BP_Lobby_AllDownloadTotal = 0;
    BP_Array_LobbyShowDownloadingMapInfoList = {};
    for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
        if v.state ~= TeamUpMatchInfoUI.downloadState_have then
            local have = false;
            for k1, v1 in pairs(BP_Array_LobbyShowDownloadingMapInfoList) do
                if v.showName == v1.name then
                    have = true;
                    break;
                end
            end
            if have == false and v.showInLobby == true then
                local oneMap = {};
                oneMap.state = v.state;
                oneMap.current = v.mapFileSize * math.min(math.max(v.percent - 50, 0), 700) / 700;
                oneMap.total = v.mapFileSize;
                oneMap.name = v.showName;
                oneMap.fileName = v.mapFileName;
                oneMap.percent = v.percent;
                table.insert(BP_Array_LobbyShowDownloadingMapInfoList, oneMap);

                BP_Lobby_AllDownloadCurrent = BP_Lobby_AllDownloadCurrent + oneMap.current;
                BP_Lobby_AllDownloadTotal = BP_Lobby_AllDownloadTotal + oneMap.total;
                if oneMap.state == TeamUpMatchInfoUI.downloadState_downloading then
                    BP_Lobby_IsDownloadingMap = true;
                end
            end
        end
    end

    --log_tree("[HHFTEST]LobbyUI.UpdateDownloadingMapInfo, BP_Array_LobbyShowDownloadingMapInfoList = ", BP_Array_LobbyShowDownloadingMapInfoList, "[HHFTEST]");
    if #BP_Array_LobbyShowDownloadingMapInfoList > 0 then
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateMapDownloadingInfo");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideMapDownloadingPanel");
    end
end

-- 好友申请提示显示控制
function LobbyUI.ShowAddFriendMessage()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowAddFreindMessage");

    LobbyUI.RefreshShowNewIntimacyMessage() --因为亲密好友与好友申请，是相关的，所以需要一起刷新
end

function LobbyUI.HideAddFriendMessage()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideAddFreindMessage");

    LobbyUI.RefreshShowNewIntimacyMessage() --因为亲密好友与好友申请，是相关的，所以需要一起刷新
end

function LobbyUI.RefreshShowNewIntimacyMessage()
    BP_Lobby_HasNewIntimacy = false
    if TeamUPFriendUI.isShowing and BP_FriendApplyMessageCount == 0 and PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) then
        BP_Lobby_HasNewIntimacy = true
    end
    
    log("LobbyUI.RefreshShowNewIntimacyMessage:" .. tostring(BP_Lobby_HasNewIntimacy))
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "refreshShowNewIntimacyMessage");
end


BP_Lobby_CurrentDownloadFileName = "";

function EventLobbyStartDownload()
    if TeamUpMatchInfoUI.bInitDownloadResult == true then
        log("[HHF]EventLobbyStartDownload");
        TeamUpMatchInfoUI.StartLobbyDownload(BP_Lobby_CurrentDownloadFileName);
    else
        --log("[HHF]EventLobbyStartDownload, InitDownloader failed.");
        --local notice = string.format(FuncUtil.GetLocalizeResStr(5047), tostring(TeamUpMatchInfoUI.initErrorCode));
        --PopUpNoticeUI.ShowNewNotice(notice);
        TeamUpMatchInfoUI.TryInitializeAgain(BP_Lobby_CurrentDownloadFileName);
    end
end

function EventLobbyPauseDownload()
    if TeamUpMatchInfoUI.bInitDownloadResult == true then
        if TeamUpMatchInfoUI.IsDownloadingCanPauseByFileName(BP_Lobby_CurrentDownloadFileName) == true then
            log("[HHF]EventLobbyPauseDownload, filename = " .. tostring(BP_Lobby_CurrentDownloadFileName));
            TeamUpMatchInfoUI.PauseDownloadByFileName(BP_Lobby_CurrentDownloadFileName);
        else
            local notice = FuncUtil.GetLocalizeResStr(201025);
            PopUpNoticeUI.ShowNewNotice(notice);
        end
    else
        --log("[HHF]EventLobbyPauseDownload, InitDownloader failed.");
        --local notice = string.format(FuncUtil.GetLocalizeResStr(5047), tostring(TeamUpMatchInfoUI.initErrorCode));
        --PopUpNoticeUI.ShowNewNotice(notice);
        TeamUpMatchInfoUI.StopTaskBeforeInitReturn(BP_Lobby_CurrentDownloadFileName);
    end
end
---------------------------------------

function EventLobbyExpressionLeave()
    log("EventLobbyExpressionLeave")
    ExpressionUI.Hide()
end

--大厅相机切换
function EventSwitchLobbyCameraByIndex()
    log("EventSwitchLobbyCameraByIndex"..tostring(BP_LobbyTargetCameraIndex))
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "TrySwitchLobbyCameraByIndex");
end

function PetLobbyActionPlayStartEnterAni()
    local ui_manager = require("ui.manager");
    if ui_manager then
        local ui = ui_manager.GetUI(ui_manager.UI_Config.pet_lobby_action)
        if ui then
            ui:PlayStartEnterAnimation()
        end
    end
end

function PetLobbyActionPlayEnterAni()
    local ui_manager = require("ui.manager");
    if ui_manager then
        local ui = ui_manager.GetUI(ui_manager.UI_Config.pet_lobby_action)
        --ui.UIRoot.Slot:SetZOrder(36)
        if ui then
            ui:PlayEnterAnimation()
        end
    end
end

function EventSwitchSystemCameraByIndex()
    log("EventSwitchSystemCameraByIndex")
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "TrySwitchSystemCameraByIndex");
end

function EventSetAchievementInitialFlag()
    log("EventSetAchievementInitialFlag")
    AchievementSystem.firstInitialize = true -- 设置成就系统首次初始化标记
end

BP_LOBBY_ClickedActivityState = -1;

function EventLobbyActivityEnd()
    log("[HHF]EventLobbyActivityEnd, BP_LOBBY_ClickedActivityState = " .. BP_LOBBY_ClickedActivityState);
    if BP_LOBBY_ClickedActivityState == -1 then
        PopUpNoticeUI.ShowNewNotice(FuncUtil.GetLocalizeResStr("120106"));
    elseif BP_LOBBY_ClickedActivityState == 1 then
        PopUpNoticeUI.ShowNewNotice(FuncUtil.GetLocalizeResStr("4002"));
    end
end

-- blueprint 调用穿戴时都会调用此接口判断是否需要隔离，衣服隔离的情况下不进行穿戴
function EventPutOnEquipment( )
    -- 通行证界面不需要隔离
    if nil ~= UIManager.GetUI(eUIType.eUnknowPassUI) or AllianceCompetitionShopUI.isShow then
        BP_PutOnRes_Isolated = false;
        return;
    end
    BP_PutOnRes_Isolated = WardrobeSystem.IsItemIsolated( BP_PutOnResId );
end

-- blueprint 调用gun穿戴时都会调用此接口，gun处于隔离时会替换成默认的枪id
function EventPutOnWeapon( )
    if nil ~= UIManager.GetUI(eUIType.eUnknowPassUI) or AllianceCompetitionShopUI.isShow then
        return;
    end
    local bIsolated = WardrobeSystem.IsItemIsolated( BP_PutOnWeaponResId );
    if bIsolated then
        -- 替换成默认id
        local weaponMapping = Client.GetTableData("WeaponSkinMapping", BP_PutOnWeaponResId);
        if weaponMapping then
            BP_PutOnWeaponResId = weaponMapping.WeaponID;
        end
    end
end
function EventPushToday( )
    -- body BP_CurrentDay
    BP_CurrentDay = FuncUtil.GetServerWeekDay()
end

--sami 根据声音文件播放声音
function LobbyUI.PlaySoundFromPath(soundPath, uid, fromWhereType)
    log("xx soundPath="..soundPath..",uid="..uid)
    BP_Lobby_Play_Sound_FromWhereType = fromWhereType or 0;
    BP_Lobby_Play_Sound_Path = soundPath
    BP_Lobby_Play_Sound_Uid = tostring(uid)
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "PlaySoundFromPath");
end

--sami 嘲讽语音随机播放
function LobbyUI.PlayChaoFengSound(emoteId, sex, randSoundId, uid, fromWhereType)
    sex = sex or 1
    --log("xx LobbyUI.PlayChaoFengSound emoteId = "..emoteId..",sex="..sex)
    local cfg = Client.GetTableData("ChaoFengSoundConfig", emoteId)
    if cfg == nil then
        return false
    end
    local pathListNan =
    {
        [1] = cfg.soundPathNan1;
        [2] = cfg.soundPathNan2;
    };
    local pathListNv =
    {
        [1] = cfg.soundPathNv1;
        [2] = cfg.soundPathNv2;
    };
    local soundPath = ""
    if sex == 1 then
        --男
        soundPath = pathListNan[randSoundId]
    else
        --女
        soundPath = pathListNv[randSoundId]
    end
    if soundPath == nil then
        return false
    end
    --log("xx soundPath = "..soundPath)
    LobbyUI.PlaySoundFromPath(soundPath, uid, fromWhereType)
    
    return true
end

-- 停止表情声音播放逻辑
function LobbyUI.StopEmotionSound()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StopPlaySoundFromPath");
end

--sami 处理表情声音播放逻辑
-- @fromWhereType 来源类型，用来设置3d音源距离，默认为0,pass里面为1
function LobbyUI.PlayEmotionSound(emoteId, sex, randSoundId, uid, fromWhereType)
    log("xx PlayEmotionSound stop uid="..uid)
    --先停止
    BP_Lobby_Play_Sound_Uid = tostring(uid);
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StopPlaySoundFromPath");
    
    --本地声音
    if randSoundId == nil or randSoundId == 0 then
        randSoundId = ExpressionUI.GetChaoFengRandSoundId(emoteId, sex)
    end
    
    --log("xx LobbyUI.PlayEmotionSound emoteId = "..emoteId)
    local bChaoFeng = LobbyUI.PlayChaoFengSound(emoteId, sex, randSoundId, uid, fromWhereType)
    if bChaoFeng == false then
        local cfg = Client.GetTableData("Item", emoteId)
        if cfg and cfg.RedEmotionSoundPath and cfg.RedEmotionSoundPath ~= "" then
            --log("LobbyUI:ShowEmoteAction sound path = " ..cfg.RedEmotionSoundPath)
            LobbyUI.PlaySoundFromPath(cfg.RedEmotionSoundPath, uid, fromWhereType)
        end
    end
end


-- 登录时检测是否要弹称号
function LobbyUI.CheckPopUILuckAir()
    LuckAirDropUI.IsFinishFaceNotice = true
    LobbyUI:ShowLuckAirDropQuery()--幸运空投
end

BP_LOBBY_ShowPDDSystem = false;
BP_LOBBY_ShowPDDReddot = false;

function EventShowPDDSystemReddot()
    if not LobbySystem.LobbyMenuOpenStatus or not LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_PDD_SYSTEM] or LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_PDD_SYSTEM].is_open ~= 1 then
        BP_LOBBY_ShowPDDSystem = false;
    else
        BP_LOBBY_ShowPDDSystem = PDD_System_Logic.can_show;
    end

    BP_LOBBY_ShowPDDReddot = PDD_System_UI.NeedShowReddot();
    log("[HHF]EventShowPDDSystemReddot, BP_LOBBY_ShowPDDSystem = " .. tostring(BP_LOBBY_ShowPDDSystem) .. ", BP_LOBBY_ShowPDDReddot = " .. tostring(BP_LOBBY_ShowPDDReddot));
end

function LobbyUI.UpdatePDDSystemReddot()
    log("[HHF]LobbyUI.UpdatePDDSystemReddot");
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdatePDDReddot");
end

function LobbyUI.UpdateLuckyUnbackReddot()
    log("LobbyUI.UpdateLuckyUnbackReddot");
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateLuckyUnbackReddot");
end

--检查是否是赛事比赛返回
function LobbyUI.CheckLeagueGameSubMode()
    --[[if LeagueGameSystem.signUpInfo then
        for k,v in pairs(LeagueGameSystem.signUpInfo.sub_mode) do
            if DataMgr.sub_mode == v and (DataMgr.RoomID == nil or DataMgr.RoomID <= 20000000) then
                EventLobbyLeagueGameEntranceEnterLeague();
                DataMgr.sub_mode = 0;
                return;
            end
        end
    end
    if DataMgr.RoomID and DataMgr.RoomID > 20000000 then
        IndiaCompetitionUI:Show();
        DataMgr.RoomID = nil;
    end--]]
    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_global));
    log("[COLE] LobbyUI.CheckLeagueGameSubMode league_seq = "..tostring(BP_STRUCT_BattleResultData.league_seq))
    log("[COLE] LobbyUI.CheckLeagueGameSubMode tournament_id = "..tostring(BP_STRUCT_BattleResultData.tournament_id))
    if curStatus == "lobby" and DataMgr.league_seq and DataMgr.league_seq >0 then
        EventLobbyLeagueGameEntranceEnterLeague();
    elseif curStatus == "lobby" and DataMgr.tournament_id and DataMgr.tournament_id >0 then
        IndiaCompetitionUI:Show();
        local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager");
        TournamentsManager.EnterTournamentTeamup(BP_STRUCT_BattleResultData.tournament_id)
    end
    DataMgr.league_seq = nil
    DataMgr.tournament_id = nil
end

--控制显示订阅小图标-----------------Start-------------------------------
function LobbyUI.ShowPrimeTag()
    -- body 
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "LoadLastTimeClickedRecharge") --这是读取本地存的是否第一次开启订阅
    
    BP_Lobby_IsShowPrimeImage = SubscribeUI.IsShowLobbySignal()
    log("BP_Lobby_IsShowPrimeImage " .. tostring(BP_Lobby_IsShowPrimeImage))
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIshowPrimeTag")
end



function EventCheckIsFirstInVietnam()
	if Client.GetPublishRegion() == "VNG" then
		if LoginSystem.IsFirstInVietnam == true then
			LoginSystem.ShowFirstInVietnam()
		end
	end
end

--点击商城气泡
function EventOnClickLobbyBubble()
    if LobbySystem.LobbyBubbleList == nil and #LobbySystem.LobbyBubbleList == 0 then
        log("EventOnClickLobbyBubble LobbySystem.LobbyBubbleList = nil")
        return
    end

    local bubbleInfo = LobbySystem.LobbyBubbleList[tostring(BP_LobbyBubble_CurItemID)]
    bubbleInfo.LastClickServerTime = FuncUtil.GetServerTimeInSec()
    --把最新的点击时间写入本地
    local saveStr = json.encode(LobbySystem.LobbyBubbleList)
    local fileName = string.format("SaveGames/LobbyBubble/LobbyBubble_%s.json", tostring(DataMgr.roleData.openID))
    Client.SaveStringToFile(saveStr, fileName)

    --跳转
    if bubbleInfo.FromType == 1 then
        JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY, bubbleInfo.ItemID)
    elseif bubbleInfo.FromType == 2 then
        JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY, bubbleInfo.ItemID)
    else
        StoreFuncUtils.Jump(bubbleInfo.Jump)
    end

    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_LobbyBubble, bubbleInfo.ItemID)
    ClientSendTLogReport(BP_BA_EXPOSURE_ENTRANCE, nil, GemReportUtils.SubEventName_LobbyBubble.."_".. bubbleInfo.ItemID)
end

function LobbyUI.HideLobbyBubble()
    LuaClassObj.HandleUIMessage(bp_lobby, "HideLobbyBubble")
end

BP_Lobby_LeagueGameCountDown = "";
----赛事倒计时小气泡提示
function LobbyUI.CheckIsShowLeagueGameCountDown(begin_time, end_time)
    if not LobbyUI.isShowLeagueTips then
        LobbyUI.isShowLeagueTips = true;
        LobbyUI.IsTimeToEnter = false;
        BP_Lobby_LeagueGameCountDown = "";
        if LeagueGameSystem.StageId and LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_ENROLL then
            local serverTime = FuncUtil.GetServerTimeInSec();
            if serverTime < begin_time then
                --比赛准备阶段
                log("LobbyUI.CheckIsShowLeagueGameCountDown" .. "比赛还未开始")
                LobbyUI.TimeToCountDown = begin_time;
                LobbyUI.countDownTime = LobbyUI.TimeToCountDown - serverTime;
                BP_Lobby_LeagueGameCountDown = FuncUtil.FormatTimeCountDown2(begin_time - serverTime);
                if BP_Lobby_LeagueGameCountDown ~= "" and string.find(BP_Lobby_LeagueGameCountDown, ":") ~= nil then
                    LobbyUI.ReleaseTimer();
                    LobbyUI.countDownTimer = Timer.InsertTimer(1, LobbyUI.ShowCountDown, true, false);
                end
            elseif serverTime >= begin_time and serverTime < end_time then
                log("LobbyUI.CheckIsShowLeagueGameCountDown" .. "在匹配阶段")
                LobbyUI.IsTimeToEnter = true;
                LobbyUI.TimeToCountDown = end_time;
                LobbyUI.countDownTime = LobbyUI.TimeToCountDown - serverTime;
                BP_Lobby_LeagueGameCountDown = Client.GetTableData("LocalizeRes", "6467").TextValue;
                LobbyUI.ReleaseTimer();
                LobbyUI.countDownTimer = Timer.InsertTimer(LobbyUI.countDownTime+1, LobbyUI.ShowCountDown, true, false);
            end
        end
        LobbyUI.ShowCountDown();
    end
end

function LobbyUI.ReleaseTimer()
    if LobbyUI.countDownTimer ~= nil then
        Timer.RemoveTimer(LobbyUI.countDownTimer);
        LobbyUI.countDownTimer = nil;
    end
end

function LobbyUI.ShowCountDown()
    LobbyUI.countDownTime = LobbyUI.TimeToCountDown - FuncUtil.GetServerTimeInSec();
    if LobbyUI.countDownTime >= 0 then
        if LeagueGameSystem.StageId and LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_ENROLL then
            if LeagueGameLobbyUI.IsAllianceUI and LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
                --BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
                --LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowSignUpStageCountDown");
            else
                if not LobbyUI.IsTimeToEnter then
                    BP_Lobby_LeagueGameCountDown = FuncUtil.FormatTimeCountDown2(LobbyUI.countDownTime);
                end
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpDateLeagueGameCountDown");
            end
        end
    else
        LobbyUI.HideLeagueGameCountDown();
        LeagueGameSystem.league_next_match_time_req(true);
    end
end

function LobbyUI.HideLeagueGameCountDown()
    if BP_Lobby_LeagueGameCountDown ~= "" then
        BP_Lobby_LeagueGameCountDown = "";
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpDateLeagueGameCountDown");
    end
    LobbyUI.ReleaseTimer();
end

--新版补给入口
function EventLobby_ClickSupply()
    if UIUtil.CanClickNow(ClickFrequencyLimit.LobbyBtn) == false then
        return;
    end

    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY, false) then
        ShowNotice(120001)
        return
    end
    SupplyMainUI.Init(0)
end

--检查是否为模拟器
function LobbyUI.CheckEmulatorTip()
    log("CheckEmulatorTip");
    if EmulatorSystem.white_simulator_list then
        if EmulatorCheck_FirstinLobby then
            local emulatorName = EmulatorSystem.GetEmulatorName();

            local isEmulator = EmulatorSystem.IsEmulator(emulatorName);
            local tips = "";
            local title = DataMgr.GetMsgByID(101001);
            if isEmulator then
                local isTencentEmulator = EmulatorSystem.is_tencent_simulator(emulatorName);
                if (isTencentEmulator) then
                    tips = DataMgr.GetMsgByID(110137);
                else
                    tips = DataMgr.GetMsgByID(110423);
                end
                CommonMessageBoxUI:ShowPanel(1, title, tips);
                EmulatorCheck_FirstinLobby = false
            else
               -- LobbyUI.DoCheckBLETip();
            end
        end
    else
        log("CheckEmulatorTip, but white_simulator_list is nil");
        EmulatorSystem.waitWhiteListForShowTip = true;
    end
end

BP_Lobby_MainPlayer_slottype = 0
BP_Lobby_MainPlayer_newItemID = 0

function LobbyUI.OnMainPlayerLogicPuton(slottype, newItemID)
    log("OnMainPlayerLogicPuton "..slottype.." "..newItemID)
    BP_Lobby_MainPlayer_slottype = slottype
    BP_Lobby_MainPlayer_newItemID = newItemID

    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "OnMainPlayerPuton")
end

-- 点击地图下载按钮，弹出下载弹窗
function EventLobby_DownloadOnShow()
    TeamUpModelUI.SetEvilEntranceVisible(false)
end

-- 隐藏地图下载按钮，收起下载弹窗
function EventLobby_DownloadOnHide()
    TeamUpModelUI.SetEvilEntranceVisible(true)
end

-- 一周年动背景音切换按钮显示隐藏 (always show for all skins)
function LobbyUI.UpdateLobbySkin(eventType, eventID, skinId)
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowAnniversaryBgMusicSwitch");
    -- Apply lobby skin theme to Start button + map preview (same as SwitchLobbySkin does)
    pcall(function()
        if skinId and skinId ~= 0 then
            BP_Global_Setting_LobbySkinId = skinId
            BP_Global_Cur_Lobby_Skin_Id = skinId
            BP_Lobby_CurSkinId = skinId
        end
        local curSkin = BP_Global_Setting_LobbySkinId or BP_Global_Cur_Lobby_Skin_Id or 10003
        if _G.writeLog then _G.writeLog("UpdateLobbySkin: skinId=" .. tostring(skinId) .. " curSkin=" .. tostring(curSkin) .. " sending SetLobbySkinTheme") end
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetLobbySkinTheme")
    end)
end

-- 一周年切换背景音乐 (override: spoof skin to Anniversary so C++ plays alt BGM)
function EventLobby_ChangeAnniversaryBgMusic()
    local realSkinId = BP_Lobby_CurSkinId
    local realCurId = BP_Global_Cur_Lobby_Skin_Id
    BP_Lobby_CurSkinId = LobbyUI.eSkinId.Anniversary
    BP_Global_Cur_Lobby_Skin_Id = LobbyUI.eSkinId.Anniversary
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SwitchLobbyBgm")
    BP_Lobby_CurSkinId = realSkinId
    BP_Global_Cur_Lobby_Skin_Id = realCurId
end

-- 编辑器Q按钮模拟测试网络断开
function EventSimulateTestReConnect()
    --测试代码
    NetUtil.ShowConnectionMsgBox(0,"")
end

function LobbyUI.CanResetLobbyCamera()
    if UIManager.GetUI(eUIType.eRoleInfoUI) then
        return not RoleInfoUI.IsShow
    end
    return true
end

--生存模式入口检测
function LobbyUI.IsTeamUpEnterOpen()
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_TEAMUP_ENTER, false) then
        BP_Lobby_TeamUpEnterOpen = false
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateTeamUpEnter")
        return
    end
    BP_Lobby_TeamUpEnterOpen = true
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateTeamUpEnter")
end

--大厅潘多拉神秘商店入口
local function GetLobbyBP()
    local Lobby_Logic_BP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP");
    return Lobby_Logic_BP and Lobby_Logic_BP.Lobby_BP or nil;
end

function LobbyUI.UpdateMysteriousShopEnter()
    log("LobbyUI.UpdateMysteriousShopEnter");
    local pandoraSystem = require("client.pandora.pandora_system");
    if not pandoraSystem.CheckSysOpen()  then
        return;
    end

    local Lobby_BP = GetLobbyBP();
    if pandoraSystem.ActIsReady(BP_ENUM_MODULE_PANDORA_MYSTERIOUS_SHOP) then
        Lobby_BP.Button_MysteriousShop_Enter:SetVisibility(UEnums.ESlateVisibility.Visible);
    else
        Lobby_BP.Button_MysteriousShop_Enter:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
end

function LobbyUI.UpdateMysteriousShopRedPoint(eventType, eventID, actId)
    log("LobbyUI.UpdateMysteriousShopRedPoint: " .. tostring(actId));
    if tonumber(actId) ~= BP_ENUM_MODULE_PANDORA_MYSTERIOUS_SHOP then
        return;
    end

    LobbyUI.RefreshMysteriousShopRedPoint();
end

function LobbyUI.RefreshMysteriousShopRedPoint()
    log("LobbyUI.RefreshMysteriousShopRedPoint");
    local pandoraSystem = require("client.pandora.pandora_system");
    if not pandoraSystem.CheckSysOpen()  then
        return;
    end

    local Lobby_BP = GetLobbyBP();
    if pandoraSystem.ActHasRedPoint(BP_ENUM_MODULE_PANDORA_MYSTERIOUS_SHOP) then
        Lobby_BP.reddot_MysteriousShop_Enter:SetVisibility(UEnums.ESlateVisibility.Visible);
    else
        Lobby_BP.reddot_MysteriousShop_Enter:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
end

function LobbyUI.RefreshLabTips()
    local PlayerPrefsSystem = require("client.tools.playerprefs")
    local newTips = PlayerPrefsSystem.LoadFileToTable(PlayerPrefsSystem.ePlayerPrefsType.eLobbyLabTips, true)
    local Lobby_BP = GetLobbyBP();
    if newTips == nil then
        BP_Lobby_LabTips_Show = true
        Lobby_BP.LabNewbieTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    else
        BP_Lobby_LabTips_Show = false
        Lobby_BP.LabNewbieTips:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
end

local function EnterMysteriousShop()
    local util = require("ui.util")
    local sound_config = require("client.slua.config.sound")
    util.PlayAudio(sound_config.click, GetLobbyBP())

    local pandoraSystem = require("client.pandora.pandora_system");
    if not pandoraSystem.CheckSysOpen()  then
        return;
    end
    if not pandoraSystem.ActIsReady(BP_ENUM_MODULE_PANDORA_MYSTERIOUS_SHOP)  then
        return;
    end

    log("LobbyUI.EnterMysteriousShop");
    pandoraSystem.EnterMysteriousShop();
end

function LobbyUI.RegistControlEvent()
    log("LobbyUI.RegistControlEvent");
    local Lobby_BP = GetLobbyBP();
    local Button_MysteriousShop_Enter = Lobby_BP.Button_MysteriousShop_Enter;
    LobbyUI.onButtonMysteriousShopClickDelegate = Button_MysteriousShop_Enter.OnClicked:Add(EnterMysteriousShop)

    Lobby_BP.Button_huiliu.OnClicked:Add(function()

        local ComeBackMgr = require("client.slua.logic.come_back.come_back_mgr")

        if not ComeBackMgr.HasActivity() then
            DataMgr.ShowNoticeByID(4002);
            return
        end

        GlobalData:JumpUrl("game://?module=1001300&id=100000")
    end)
end

function LobbyUI.CheckShowComeBack()
    local Lobby_BP = GetLobbyBP();
    if Lobby_BP then
        local ComeBackMgr = require("client.slua.logic.come_back.come_back_mgr")
        log("ComeBackMgr.HasActivity:" .. tostring(ComeBackMgr.HasActivity()))
        Lobby_BP.Button_huiliu:SetVisibility(UIUtil.BoolToVisible(ComeBackMgr.HasActivity(), true, true))
        Lobby_BP.TextBlock_43:SetText(FuncUtil.LocalizeResFormat(6993))

        local hasRed = ComeBackMgr.HasComeBackDailyGiftRedDot() or ComeBackMgr.HasTaskBackflowRedDot()
        Lobby_BP.Image_reddot:SetVisibility(UIUtil.BoolToVisible(hasRed))
    end
end

function LobbyUI.UnregistControlEvent()
    log("LobbyUI.UnregistControlEvent");
    local Lobby_BP = GetLobbyBP();
    local Button_MysteriousShop_Enter = Lobby_BP.Button_MysteriousShop_Enter;
    if Button_MysteriousShop_Enter and LobbyUI.onButtonMysteriousShopClickDelegate then
        Button_MysteriousShop_Enter.OnClicked:Remove(LobbyUI.onButtonMysteriousShopClickDelegate)
        LobbyUI.onButtonMysteriousShopClickDelegate = nil
    end

    Lobby_BP.Button_huiliu.OnClicked:Clear()
end
--大厅潘多拉神秘商店入口

function LobbyUI.ShowDirectPurchaseBanner(eventType, eventID, vars)
    log("LobbyUI.ShowDirectPurchaseBanner");
    --[[
    local actInfoList = ActivitySystem.GetActivityInfoListByType(ActivityType.NEW_BANNER_PURCHASE);
    if not actInfoList or #actInfoList == 0 then
        DataMgr.ShowNoticeByID(6942);
        log_error("LobbyUI.ShowDirectPurchaseBanner no activity info!!!");
        return;
    end
    ]]
    local activityId = tonumber(vars.dpid);
    local actInfo = ActivitySystem.GetActivityByID(activityId);
    if not actInfo then
        DataMgr.ShowNoticeByID(4002);
        log("[Direct_Purchase_By_Ativity_UI.ShowUI] has none Direct_Purchase_By_Ativity activity info!!!");
        return;
    end
    local uiManager = require("ui.manager");
    if uiManager then
        local ui = uiManager.ShowUI(uiManager.UI_Config.direct_purchase_banner);
        ui:InitUI(activityId)
    end
end

--wegame小助手相关
function LobbyUI.OnGetWegameUrl(eventType, eventID, vars)
    log_tree("LobbyUI.OnGetWegameUrl",vars);
    local logic_platform = require("client.slua.logic.setting.logic_platform")
    --未绑定的才会显示绑定窗口
    if logic_platform then
        if logic_platform.IsBindingPlatform("wegame") then
            ShowNotice(7101);
            return;
        end
        
        --判断是否符合地区
        if logic_platform.CheckIsRegionAvailable() then
            logic_platform.SetPlatformInfo("wegame",vars);
            local uiManager = require("ui.manager");
            if uiManager then
                local ui = uiManager.ShowUI(uiManager.UI_Config.setting_platform_popup);
                ui:InitBindingUI("wegame");
            end
        else
            DataMgr.ShowNoticeByID(7051);
        end
    end
    Client.ClearAdjustDeepLink();
end

function LobbyUI.UpdateActivityBtnRedDot()
    local is_lobby_show_red = ActivitySystem.HasActBtnRedPoint()
    UpdateLobbyActivityRedPoint(is_lobby_show_red)
end

-- writeLog: file-based logging fallback (uses _G.writeLog from bp_login.lua if available)
if not _G.writeLog then
    local logFile = (_G._paths and _G._paths.logFile) or (_G._package_path.."/lobby_fix_log.txt")
    _G.writeLog = function(msg)
        pcall(function()
            local f = io.open(logFile, "a")
            if f then
                f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg .. "\n")
                f:close()
            end
        end)
    end
end

_G.writeLog("bp_lobby.lua loaded")

return LobbyUI;
