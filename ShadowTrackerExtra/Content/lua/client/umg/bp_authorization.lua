AuthorizationUI = AuthorizationUI or
{
    --是否增加登录失败数次,手动点击的才能加，第一次自动鉴权不加
    addLoginTryCount = 0;
}

--第一次登录自动鉴权
BP_AutoAuthLogin = 1;
--输入用户名
BP_QQID = ""
BP_QQPasswd = ""
BP_GameVersion = ""
--微信是否安装，如果没有安卓，微信登录按钮需隐藏
BP_WECHAT_INSTALL = 0
--登录尝试次数
BP_LoginCount = 0;
--记录开始登录的时间
BP_LoginTime = 0;
--登录限制检查结果
BP_LoginCheck = 0;
--当前鉴权TOKEN有效性
BP_TokenIsValid = 0;

BP_DeviceNameBeforeAuthLogin = "";

BP_DeviceLimit = 0; -- -1: refuse, 0: tips, 1: normal

HasShowDeviceLimit = false;

BP_MaxLoginTypeNum = 5;

BP_PrivacyPolicyVersion = 0;
BP_UserAgreementVersion = 0;

-- 排序后的登录类型列表, 空就是没有
BP_ARRAY_LoginTypeOrderList =
{
    "",
    "",
    "",
    "",
    "",
    "",
}

-- 登录平台
BP_AuthLoginChannel = "none";

-- GM login panel (restored from 0.11.1 — was removed in 0.13.4)
UnrealLogoUI = UnrealLogoUI or {}
function UnrealLogoUI.ShowUI()
    if not bp_unreal_logo then
        log("UnrealLogoUI: bp_unreal_logo nil, can't show")
        return
    end
    LuaClassObj.HandleDynamicCreation(bp_unreal_logo);
    LuaClassObj.HandleUIMessage(bp_unreal_logo, "UIShow");
end
function UnrealLogoUI.HideUI()
    if not bp_unreal_logo then return end
    LuaClassObj.HandleUIMessage(bp_unreal_logo, "UIHide");
end

--注册Widget
function bp_authorization_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_authorization,
		{
			{Path="/Game/UMG/UI_BP/Login/Authorization_BP.Authorization_BP_C", Container="Default", ZOrder=0},
            {Path="/Game/UMG/UI_BP/Login/Login_SplashScreen.Login_SplashScreen_C", Container="Default", ZOrder=0}
		},
		{"Update", "Login"},
		false,
		false
	); 
    EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, AuthorizationUI.HandleIOSCheck);

    -- Register UnrealLogoUI widget (bp_unreal_logo.lua was deleted from 0.13.4 OBB)
    pcall(function()
        LuaClassObj.SubUIWidgetList(bp_unreal_logo,
            {
                {Path = "/Game/UMG/UI_BP/Login/Unreal_UIBP.Unreal_UIBP_C", Container = "Default", ZOrder = 50},
            },
            {"Login", "CreateRole"},
            false, false, true
        );
    end)
end

function AuthorizationUI.HandleIOSCheck()
    -- body
    if GlobalData:IsIOSCheck() then
        LuaClassObj.SubCollapseWidgetList(bp_authorization,
        "Authorization_BP_C",
        {
            "Button_2",
            "Button_0",
            "Button_Help",
            "Button_Repair",
            "btnHelpLogin",
            "18+",
        }
    );
    LuaClassObj.HandleCollapseWidgetList(bp_authorization, "Authorization_BP_C");
    end
end
function EventFetchInfo()

end

-- rainpan: 自动登录
function EventQuickLogin()
	log("bp_authorization start QuickLogin");
    
	LoginSystem.quickLogin();
end

-- rainpan：自动登录超时清空登录态，避免杀进程重登时仍然卡在之前那个登录渠道中
function EventClearChannelID()
	log("bp_authorization start EventCleanChannelID");
    
	Client.ClearChannelID(NetInterface);
end

--开始鉴权流程
function EventStartAuthorization()
	log("bp_authorization start authorization");

    EventLoginCheck();
    if(BP_LoginCheck == 1) then
        return;
    end

	if BP_QQID ~= "" and BP_QQPasswd ~= "" then
		Client.InitLoginAccount(NetInterface, tonumber(BP_QQID), BP_QQPasswd);
		LoginSystem.sendLogin(2);
	else
		LoginSystem.sendLogin(6);
	end
end

--强退游戏
function QuitGame()
	log("QuitGame");
    LuaClassObj.HandleUIMessage(bp_global, "quitGame");
end

--自动登录前做一些事情
--目前流程：更新-》内存提示-》停服公告-》登录前公告-》自动登录
function EventBeforeAuthLogin()
	local function doNext()
		IMSDKNoticeUI.ShowNoticeBeforeLogin();
	end
	local memoryStaus = Client.GetMemoryStats();
	local availablePhysical = memoryStaus.AvailablePhysical / 1048576;
	if availablePhysical == 0 or availablePhysical > 100 then
		--内存足够，进行下一步操作
		doNext();
	else
		--内存不足，弹出提示，之后进行下一步操作
		local tip = "";
		local msgConfig = Client.GetTableData("LocalizeRes", 101014);
		if msgConfig then
			tip = msgConfig.TextValue;
		end
        local tipTitle = Client.GetTableData("LocalizeRes", "101001").TextValue;
		CommonMessageBoxUI:ShowPanel(1, tipTitle, tip, doNext, doNext);
	end
	log("availablePhysical：" .. tostring(availablePhysical));
end

function EventShowNoticeBeforeLogin()
	log("[HHF]EventShowMaintenanceIMSDKNotice")
	IMSDKNoticeUI.ShowNoticeBeforeLogin();
end

function AuthorizationUI.ContinueAutoLogin()
	log("[HHF]AuthorizationUI.ContinueAutoLogin");
	LuaClassObj.HandleUIMessage(bp_authorization, "doAutoLogin");
end

function EventAutoAuthLogin()
	log("EventAutoAuthLogin"..BP_AutoAuthLogin);
    --只有第一次自动鉴权
    BP_AutoAuthLogin = 0;
end

function EventGetPrivacyPolicyVersion()
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" then
        BP_PrivacyPolicyVersion = LongTxt.PrivacyPolicy_jp_Version;
    elseif strRegion == "KOREA" then
        BP_PrivacyPolicyVersion = LongTxt.PrivacyAgreement_kr_Version;
    elseif strRegion == "VNG" then
        BP_PrivacyPolicyVersion = LongTxt.VNGPrivacyPolicy_Version;
    elseif strRegion == "TW" then
        BP_PrivacyPolicyVersion = LongTxt.TWPrivacyPolicy_Version;
    else
        BP_PrivacyPolicyVersion = LongTxt.PrivacyPolicy_Global_Version;
    end
end

function EventGetUserAgreementVersion()
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" then
        BP_UserAgreementVersion = LongTxt.UserAgreement_jp_Version;
    elseif strRegion == "KOREA" then
        BP_UserAgreementVersion = LongTxt.UserAgreement_kr_Version;
    elseif strRegion == "VNG" then
        BP_UserAgreementVersion = LongTxt.VNGUserLicence_Version;
    elseif strRegion == "TW" then
        BP_UserAgreementVersion = LongTxt.TWUserLicence_Version;
    else
        BP_UserAgreementVersion = LongTxt.UserAgreement_Global_Version;
    end
end

function AuthorizationUI.CheckPrivacyPolicy()
    log("checkPrivacyPolicy");
    LuaClassObj.HandleUIMessage(bp_authorization, "CheckPrivacyPolicy");
end

local function checkUserAgreement()
    log("[CCW] checkAgreement");
    LuaClassObj.HandleUIMessage(bp_authorization, "CheckUserAgreement");
    --LuaClassObj.HandleUIMessage(bp_authorization, "AutoLogin");
end

function EventAskForUserAgreement()
    local strRegion = Client.GetPublishRegion();
    local btnOKText = DataMgr.GetMsgByID(301346);
    local btnCancleText = DataMgr.GetMsgByID(4111);

    local tips = Client.GetTableData("LocalizeRes", "7217").TextValue;
    if strRegion == "GLOBAL" then
        --全球版加"腾讯游戏"
        tips = Client.GetTableData("LocalizeRes", "4432").TextValue;
    end

    local function rejectPolicy()
        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local text = Client.GetTableData("LocalizeRes", "4485").TextValue
        local btnOK = Client.GetTableData("LocalizeRes", "4410").TextValue;
        local btnCancel = Client.GetTableData("LocalizeRes", "4486").TextValue;
        SettingGDPRUI:ShowNoticeBox(0, title, text, btnCancel, btnOK, nil, EventAskForUserAgreement);
    end

    if strRegion == "JAPAN" then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.UserAgreement_title_jp, LongTxt.UserAgreement_content_jp, btnOKText, btnCancleText, checkUserAgreement, nil, tips);
    elseif strRegion == "KOREA" then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.UserAgreement_title_kr, LongTxt.UserAgreement_content_kr, btnOKText, btnCancleText, checkUserAgreement, nil, tips);
    elseif strRegion == "VNG"  then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.VNGUserLicenceTitle, LongTxt.VNGUserLicenceContent, btnOKText, btnCancleText, checkUserAgreement, nil, tips);
    elseif strRegion == "TW"  then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.TWUserLicenceTitle, LongTxt.TWUserLicenceContent, btnOKText, btnCancleText, checkUserAgreement, nil, tips);
    else
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.service_title_en, LongTxt.service_content_en, btnOKText, btnCancleText, checkUserAgreement, rejectPolicy, tips);
        end
end

function EventAskForPrivacyPolicy()
    local strRegion = Client.GetPublishRegion();
    local btnOKText = DataMgr.GetMsgByID(301346);
    local btnCancleText = DataMgr.GetMsgByID(4111);

    local tips = Client.GetTableData("LocalizeRes", "4431").TextValue;

    local function rejectPolicy()
        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local text = Client.GetTableData("LocalizeRes", "4485").TextValue
        local btnOK = Client.GetTableData("LocalizeRes", "4410").TextValue;
        local btnCancel = Client.GetTableData("LocalizeRes", "4486").TextValue;

        SettingGDPRUI:ShowNoticeBox(0, title, text, btnCancel, btnOK, nil, EventAskForPrivacyPolicy);

    end

    if strRegion == "JAPAN" then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.PrivacyAgreement_title_jp, LongTxt.PrivacyAgreement_content_jp, btnOKText, btnCancleText, AuthorizationUI.CheckPrivacyPolicy, nil, tips);
    elseif strRegion == "KOREA" then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.PrivacyAgreement_title_kr, LongTxt.PrivacyAgreement_content_kr, btnOKText, btnCancleText, AuthorizationUI.CheckPrivacyPolicy, nil, tips);
    elseif strRegion == "VNG" then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.VNGPrivacyPolicyTitle, LongTxt.VNGPrivacyPolicyContent, btnOKText, btnCancleText, AuthorizationUI.CheckPrivacyPolicy, nil, tips);
    elseif strRegion == "TW" then
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.TWPrivacyPolicyTitle, LongTxt.TWPrivacyPolicyContent, btnOKText, btnCancleText, AuthorizationUI.CheckPrivacyPolicy, nil, tips);
    else
        CommonNoticeBoxUI:ShowMessageBox(4, LongTxt.PrivacyAgreement_title_en, LongTxt.PrivacyAgreement_content_en, btnOKText, btnCancleText, AuthorizationUI.CheckPrivacyPolicy, rejectPolicy, tips);
    end
end

function EventShowPushShortTips()
    log("EventShowPushTips");
	local title = DataMgr.GetMsgByID(101001);
	local notice = "배틀그라운드 모바일 이용 약관 동의\n (푸시 알림 수신 동의 포함)가 처리되었습니다.\n " .. os.date("%Y년/%m월/%d일/%H시/%M분", os.time());
	CommonMessageBoxUI:ShowPanel(1, title, notice);
end

function EventShowPushLongTips()
    log("EventShowPushTips");
	local title = DataMgr.GetMsgByID(101001);
	local notice = "배틀그라운드 모바일 이용 약관 동의 \n(푸시 알림 수신 동의 포함) 및 개인정보 수집 및 이용 동의가 처리되었습니다.\n " .. os.date("%Y년/%m월/%d일/%H시/%M분", os.time());
	CommonMessageBoxUI:ShowPanel(1, title, notice);
end

function EventShowPushTipsThenLogin()
    log("EventShowPushTipsThenLogin");
	local title = DataMgr.GetMsgByID(101001);
	local notice = "배틀그라운드 모바일 이용 약관 동의 \n(푸시 알림 수신 동의 포함) 및 개인정보 수집 및 이용 동의가 처리되었습니다.\n " .. os.date("%Y년/%m월/%d일/%H시/%M분", os.time());
	--SettingGDPRUI:ShowNoticeBox(3, title, notice, Client.GetTableData("LocalizeRes", "301346").TextValue, nil, AuthorizationUI.AutoLogin, nil, nil, 3);
	CommonMessageBoxUI:ShowPanel(1, title, notice, AuthorizationUI.AutoLogin);
end

function AuthorizationUI.AutoLogin()
	log("AuthorizationUI.AutoLogin");
	LuaClassObj.HandleUIMessage(bp_authorization, "AutoLogin");
end

--展示许可服务
function EventShowService()
	log("EventShowService");
    --local language = Client.GetCurrentLanguage();
    --log("EventShowService: " .. language);
	local strRegion = Client.GetPublishRegion();
	log("bp_authorization EventShowService strRegion = " .. strRegion);
	
	if strRegion == "JAPAN" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.UserAgreement_title_jp, LongTxt.UserAgreement_content_jp);
	elseif strRegion == "KOREA" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.UserAgreement_title_kr, LongTxt.UserAgreement_content_kr);
	elseif strRegion == "VNG" then
        PopUpNoticeUI.ShowMessageBox(LongTxt.VNGUserLicenceTitle, LongTxt.VNGUserLicenceContent);
    elseif strRegion == "TW" then
        PopUpNoticeUI.ShowMessageBox(LongTxt.TWUserLicenceTitle, LongTxt.TWUserLicenceContent);
    else
		PopUpNoticeUI.ShowMessageBox(LongTxt.service_title_en, LongTxt.service_content_en);		
	end
end

--展示隐私服务
function EventShowPrivacyAgreement()
	log("EventShowPrivacyAgreement");
	local strRegion = Client.GetPublishRegion() ;
	log("bp_authorization EventShowPrivacyAgreement strRegion = " .. strRegion);

	if strRegion == "JAPAN" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_jp, LongTxt.PrivacyAgreement_content_jp);
	elseif strRegion == "KOREA" then
        PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_kr, LongTxt.PrivacyAgreement_content_kr);
    elseif strRegion == "VNG" then
        PopUpNoticeUI.ShowMessageBox(LongTxt.VNGPrivacyPolicyTitle, LongTxt.VNGPrivacyPolicyContent);
    elseif strRegion == "TW" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.TWPrivacyPolicyTitle, LongTxt.TWPrivacyPolicyContent);
	else
		PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_en, LongTxt.PrivacyAgreement_content_en);		
	end
end

--展示拒绝用户协议
function EventShowRefuse()
	log("EventShowRefuse");
	local msg1 = Client.GetTableData("LocalizeRes", "101001");
	local msg2 = Client.GetTableData("LocalizeRes", "101008");
    CommonMessageBoxUI:ShowPanel(2, msg1.TextValue, msg2.TextValue, QuitGame, nil)
end

--展示游客数据提示
function EventShowTouristNotice()

    local function acceptTouristNotice()
        LuaClassObj.HandleUIMessage(bp_authorization, "AcceptTouristNotice");
        --LoginSystem.sendLogin(BP_ENUM_PLAYFORM_TOURIST);
    end

	log("EventShowTouristNotice");
	local msg1 = Client.GetTableData("LocalizeRes", "101001");
	local msg2 = Client.GetTableData("LocalizeRes", "4647");
    CommonMessageBoxUI:ShowPanel(1, msg1.TextValue, msg2.TextValue, acceptTouristNotice, nil, DataMgr.GetMsgByID(110036));
end

function EventCheckWeChatInstalled()
    if Client.IsInstallWX(NetInterface) then
        BP_WECHAT_INSTALL = 1;
    else
        BP_WECHAT_INSTALL = 0;
    end
end

--获得界面版本号和TOKEN有效性
function EventGameVersion()
	log("EventGameVersion");
    BP_GameVersion = Client.GetAppVersion();
    log("EventGameVersion"..tostring(BP_GameVersion));
    if(Client.GetLoginChannel(NetInterface) == 0) then
        BP_TokenIsValid = 0;
    else
        BP_TokenIsValid = 1;
    end

	log("TokenIsValid:"..BP_TokenIsValid);
    is_emulator = Client.IsEmulatorWhenInit();
    log("IsEmulatorWhenInit:"..tostring(is_emulator));
end

function EventAuthShowButtons()
	log("EventAuthShowButtons");
    ConnectionWaitingUI:Hide(1);
end

-- 快速登录 1.展示菊花 2.隐藏登录按钮
function AuthorizationUI.QuickLoginWaiting()
	log("bp_authorization QuickLoginWaiting");
    ConnectionWaitingUI:Show(1);
	LuaClassObj.HandleUIMessage(bp_authorization, "hideButtons");
end

-- 快速登录/登录 超时处理
function EventLoginTimeOut()
	log("bp_authorization EventLoginTimeOut");
    ConnectionWaitingUI:Hide(1);
	LuaClassObj.HandleUIMessage(bp_authorization, "showButtons");
	-- 提示：取消鉴权
	DataMgr.ShowNoticeByID("101711");
end

function AuthorizationUI.GetTime()
    local curTime = os.time();
    local remainTime = math.abs(BP_LoginTime - curTime);
    
    --登录限制时长保护，最多5min
    if(remainTime > BP_ENUM_LOGINLIMIT_TIME2 and BP_LoginTime > curTime) then
        
        BP_LoginTime = curTime + BP_ENUM_LOGINLIMIT_TIME2;
        --save to prefs
        local PlayerPrefs = slua.loadClass("/Game/UMG/UI_Utility/PlayerPrefs.PlayerPrefs");
        if PlayerPrefs then
            PlayerPrefs = PlayerPrefs:LoadData();
            PlayerPrefs:SetTime(BP_LoginTime);
        end

        remainTime = BP_ENUM_LOGINLIMIT_TIME2;
    end

    local min = math.floor(remainTime / 60);
    local sec = remainTime % 60;
    --local text = string.format("登录过于频繁，请%d分后再尝试！", min, sec);
    local text = string.format(Client.GetTableData("LocalizeRes", "301162").TextValue, min);
    if(min == 0) then
        --text = string.format("登录过于频繁，请%d秒后再尝试！", sec);
        text = string.format(Client.GetTableData("LocalizeRes", "301163").TextValue, sec);
    end
    return curTime, text
end

function EventRedoAutoAuthorization()
	log("EventRedoAutoAuthorization");

    local function RedoAutoAuthorization()
        log("RedoAutoAuthorization");
        LuaClassObj.HandleUIMessage(bp_authorization, "showButtons");
    end

    local curTime,text = AuthorizationUI.GetTime()

    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    local msg = Client.GetTableData("LocalizeRes", "103015").TextValue;

    if (BP_LoginCount > BP_ENUM_LOGINLIMIT_COUNT2 and curTime < BP_LoginTime) then
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, RedoAutoAuthorization, nil,nil,nil,AuthorizationUI.TimerInvoke1);
    elseif (BP_LoginCount > BP_ENUM_LOGINLIMIT_COUNT1 and curTime < BP_LoginTime ) then
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, RedoAutoAuthorization, nil,nil,nil,AuthorizationUI.TimerInvoke2);
    else
        CommonMessageBoxUI:ShowPanel(1, title, msg, RedoAutoAuthorization);
    end
end

function EventUpdateLoginTime()
    if( AuthorizationUI.addLoginTryCount == 1) then
        if(BP_LoginCount > BP_ENUM_LOGINLIMIT_COUNT2) then
            BP_LoginTime = os.time() + BP_ENUM_LOGINLIMIT_TIME2;
        elseif ( BP_LoginCount > BP_ENUM_LOGINLIMIT_COUNT1) then
            BP_LoginTime = os.time() + BP_ENUM_LOGINLIMIT_TIME1;
        end
    end
end

function EventAddLoginCount()
    log("EventAddLoginCount "..AuthorizationUI.addLoginTryCount);

    if( AuthorizationUI.addLoginTryCount == 1) then
        BP_LoginCount = BP_LoginCount + 1;
    end
end

function EventClearLoginLimit()
    log("EventClearLoginLimit")
    BP_LoginCount = 0;
    BP_LoginTime = 0;
end

function EventLoginCheck()
    log("EventLoginCheck "..os.time().." : " .. BP_LoginTime)

    local curTime, text = AuthorizationUI.GetTime()
    if(curTime > BP_LoginTime) then
        log("EventLoginCheck "..curTime.." : " .. BP_LoginTime)
        BP_LoginCheck = 0;
        return;
    end

    local function RedoAutoAuthorization()
        log("RedoAutoAuthorization");
        LuaClassObj.HandleUIMessage(bp_authorization, "showButtons");
    end

    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    if (BP_LoginCount > BP_ENUM_LOGINLIMIT_COUNT2) then
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, RedoAutoAuthorization, nil,nil,nil,AuthorizationUI.TimerInvoke1);
        BP_LoginCheck = 1;
        return;
    elseif (BP_LoginCount > BP_ENUM_LOGINLIMIT_COUNT1) then
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, RedoAutoAuthorization, nil,nil,nil,AuthorizationUI.TimerInvoke2);
        BP_LoginCheck = 1;
        return;
    end
end

function AuthorizationUI.TimerInvoke1()
    local curTime, text = AuthorizationUI.GetTime()
    if(curTime > BP_LoginTime) then
        CommonMessageBoxUI:HidePanel();
        return;
    end
    CommonMessageBoxUI:UpdateMsg(text)
end

function AuthorizationUI.TimerInvoke2()

    local curTime, text = AuthorizationUI.GetTime()
    if(curTime > BP_LoginTime) then
        CommonMessageBoxUI:HidePanel();
        return;
    end
    CommonMessageBoxUI:UpdateMsg(text)
end
--注销帐号
function EventLogout()
	log("bp_authorization EventLogout");
	Client.Logout(NetInterface);
end

function EventClickKefu()
    --KefuSystem.OpenLoginKefuURL();
end

function EventDeleteSavedDir()
    log("EventDeleteSavedDir")

    PufferDownloader.DeleteAllOldPak()

    local function Exit()
        Client.ExitGame();
    end

	local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    local msg = Client.GetTableData("LocalizeRes", "101714").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg, 
        function()
        --退出游戏
        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
    end);
    
    local param = {};
    Client.GEMReportEvent(GameFrontendHUD, "UserRepair", param);
end

-- 打开语言设置
function EventEnterLanguageSetting()
    log("enter language setting ui");
    SettingLanguageUI.ShowUIInLoginPanel();
    Client.BuglyLog(NetInterface, 4, "Login", "EnterLang");
end

function EventOpenRepairDailog()
    log("EventOpenRepairDailog")
    LoginRepairUI.ShowUI();

    Client.BuglyLog(NetInterface, 4, "Login", "LoginRepairUI.ShowUI");
end

function EventUnrealLogoBtnClick()
    log("EventUnrealLogoBtnClick");
    UnrealLogoUI.ShowUI();
end

-- 日韩版添加
-- GC登录超时提示，引导玩家去手机设置里登录GameCenter
function EventGCLoginTimeOut()
    log("EventGCLoginTimeOut")

    ConnectionWaitingUI:Hide(1);

    local title = "";
    local msg = Client.GetTableData("LocalizeRes", "4142").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg);
end

-- 获取登录类型配置
function EventGetLoginTypeList()

    BP_ARRAY_LoginTypeOrderList = FuncUtil.GetLoginTypeList(BP_ARRAY_LoginTypeOrderList);
    
end

function EventAuthShowConnect()
    ConnectionWaitingUI:Hide(1);
end

function EventAuthHideConnect()
    ConnectionWaitingUI:Show(1);
end

function EventStartLogin()
    LoginUI.initServerList();
    LuaClassObj.HandleUIMessage(bp_authorization, "hideButtons");
    LuaClassObj.HandleDynamicCreation(bp_login);
    LuaClassObj.HandleUIMessage(bp_login, "UIShow");
end

-- 如果mini版本没有下载首包，则不能正常登录，弹窗拦截之
function EventLoginWithoutBasePakInNoMiniVersion()
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",301137)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local content = ""
	local contentConfig = Client.GetTableData("LocalizeRes",5052) -- 资源文件缺失，请联系客服或重启游戏重试
	if contentConfig then
		content = contentConfig.TextValue
	end
	
	local helpLabel = ""
	local helpConfig = Client.GetTableData("LocalizeRes",4539) -- 帮助
	if helpConfig then
		helpLabel = helpConfig.TextValue
	end

	local exitLabel = ""
	local exitConfig = Client.GetTableData("LocalizeRes",4486) -- 退出
	if exitConfig then
		exitLabel = exitConfig.TextValue
	end

	LuaClassObj.HandleUIMessage(bp_versionupdate, "OnFinished");
    CommonMessageBoxUI:ShowPanel(2,title, content,
		function()
		    --退出游戏
		    LuaClassObj.HandleUIMessage(bp_global, "quitGame");
		end,
        function()
            AuthorizationUI.delayTimerID = Timer.InsertTimer(
                1, 
				function()
					Timer.RemoveTimer(AuthorizationUI.delayTimerID);
					VersionUpdate.OnRepairOverMaxTime();
				end,
			    false, true);
			Client.HelpshiftShowConversion();
		end,
		exitLabel,
		helpLabel
    );

    local param = {};
    Client.GEMReportEvent(GameFrontendHUD, "LoginWithoutBase", param);
end

function EventShowNotInstallWechatMsg()
    local title = "";
    local msg = Client.GetTableData("LocalizeRes", "110126").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg);
end

function EventShowNotInstallVkMsg()
    local title = "";
    local msg = Client.GetTableData("LocalizeRes", "4303").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg);
end

-- 初始化鉴权环境
function AuthorizationUI.InitIMSDKEnv()
    --直连默认正式鉴权，非直连默认测试鉴权
    if globalConfig.IsDirectConnect() == false then
        Client.InitIMSDKEnv(NetInterface, 0);
    else
        Client.InitIMSDKEnv(NetInterface, 1);
    end
end