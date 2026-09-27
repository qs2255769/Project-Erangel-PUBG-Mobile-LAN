CreateRoleUI = CreateRoleUI or 
{
    --换装时缓存
    sex = 0,
    head = 0,
    race = 0,
    hairType = 0,
    hairColor = 0,
    
    --重置卡ID
    cardID = 1601001,
    createRoleNameInit = false,
    platformName = "",
    
    --标记界面是否显示
    isShowing = false;
}

BP_STRUCT_CreateRole_AvatarInfo =
{
    avatar_id = 0,
    remain_time = 0,
    has_item = false,
    is_new = false,
}

--玩家名字
BP_CreateRole_Name = "";
--玩家游戏性别 1：男性 2：女性
BP_CreateRole_Sex = 1;
--玩家种族（脸型） 1-6
BP_ARRAY_CreateRole_Races = 
{
    BP_STRUCT_CreateRole_AvatarInfo = _G.BP_STRUCT_CreateRole_AvatarInfo,
};
BP_CreateRole_Race = 1;
BP_CreateRole_HeadId = 0;
--玩家发型
BP_ARRAY_CreateRole_Hairs = 
{
    BP_STRUCT_CreateRole_AvatarInfo = _G.BP_STRUCT_CreateRole_AvatarInfo,
};
BP_CreateRole_HairType = 1;
--玩家发色
BP_CreateRole_HairColor = 1;

--玩家胡须
BP_ARRAY_CreateRole_Beards =
{
    BP_STRUCT_CreateRole_AvatarInfo = _G.BP_STRUCT_CreateRole_AvatarInfo,
}

BP_ARRAY_CreateRole_BeardColors =
{
    BP_STRUCT_CreateRole_AvatarInfo = _G.BP_STRUCT_CreateRole_AvatarInfo,
}

--胡子类型
BP_CreateRole_BeardType = 0;
BP_CreateRole_BeardID = 0;
--胡子颜色
BP_CreateRole_BeardColor = 0;
BP_CreateRole_BeardColorID = 0;

--头发ID
BP_CreateRole_HairID = 0;
BP_CreateRole_Nation = "";
--模式切换创建角色:1/重置外观:2
BP_CreateRole_Mode = 1;
--重置需要的花费
BP_CreateRole_ModeCost = 3000;
--从大厅到换装1or换装到大厅0
BP_CreateRole_LobbyToAvatar = 0;
--形象重置卡个数
BP_CreateRole_CardCount = 0;
--是否使用UC券购买: 1=普通购买 2=UC券购买
BP_CreateRole_BuyMode = 1;

--选中提示信息
BP_STRUCT_CreateRole_SelectTip = 
{
    avatar_id = 0,
    avatar_name = "",
    remain_time_str = "",
    avatar_price = 0,
    show_price = true,
    has_item = false,
    is_ticket = false,
	pass_season = 0,
};

--选中购买信息
BP_STRUCT_CreateRole_BuyAvatarInfo =
{
    avatar_id = 0,--avatar表中的唯一id
    buy_time_type = 0,--avatar中的价格类型  1=重置购买 2=7天限定 3=30天限定 4=永久
    selected = 1,--是否选中
    owned = false,--是否已拥有
}
BP_Array_CreateRole_BuyAvatars =
{
    BP_STRUCT_CreateRole_BuyAvatarInfo = _G.BP_STRUCT_CreateRole_BuyAvatarInfo,
}
BP_ARRAY_CreateRole_UCBuyAvatars = 
{
    BP_STRUCT_CreateRole_BuyAvatarInfo = _G.BP_STRUCT_CreateRole_BuyAvatarInfo,
}
BP_CreateRole_Gold = 0;
BP_CreateRole_Ticket = 0;

--新的Avatar
BP_ARRAY_CreateRole_NewAvatarList =
{
    avatar_id = 0,
}
local newAvatarMap =
{
    -- key = avatar_id, value = true
}

BP_DefaultHat = 0;
BP_DefaultFace = 0;
BP_DefaultClose = 0;
BP_DefaultPlants = 0;
BP_DefaultShoes = 0;

local randomNameEndCount = 0;

local arrayAvatarInitTable = {};

local DEFAULT_BEARD_TYPE = 50001

-- 获取AvatarInit导表数据
local function GetArrayAvatarInit()
    if next(arrayAvatarInitTable) == nil then
        for k,v in pairs(Client.GetTable("AvatarInit")) do
            arrayAvatarInitTable[tonumber(k)] = v
            
        end
        return arrayAvatarInitTable;
    else
        return arrayAvatarInitTable;
    end
end

local function GoldChange(eventType, eventID, vars)
    CreateRoleUI:InitGold();
end

local function TicketChange(eventType, eventID, vars)
    CreateRoleUI:InitTicket();
end

  --注册Widget
function bp_createrole_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_createrole,
    {{Path="/Game/UMG/UI_BP/Lobby/Lobby_CreatingRole_UIBP.Lobby_CreatingRole_UIBP_C", Container="Default", ZOrder=0},
     {Path="/Game/UMG/UI_BP/Lobby/Lobby_AvatarAnim_UIBP.Lobby_AvatarAnim_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_COMMON_ITEM_GET_ZORDER},
     {Path="/Game/UMG/UI_BP/Lobby/Item/ResetPurchase_UIBP.ResetPurchase_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_COMMON_ITEM_GET_ZORDER},
    },
    {"CreateRole","Lobby"},
    false,
    true,
    true,
  true-- 动态创建
  );
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, CreateRoleUI.OnDepotDataChange);
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, GoldChange);
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, TicketChange);
end

--设置平台名字
function CreateRoleUI:SetPlatformName(name)
    CreateRoleUI.platformName = name;
    log("CreateRoleUI:SetPlatformName:"..name)
    if (CreateRoleUI.createRoleNameInit == false) then
        CreateRoleUI.createRoleNameInit = true;
        BP_CreateRole_Name = name;
    end
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end

--显示创建角色界面
function CreateRoleUI:Init()
    log("CreateRoleUI init")
    
    BP_CreateRole_Sex = 1
    BP_CreateRole_Race = 10007
    BP_CreateRole_HeadId = 0
    BP_CreateRole_HairType = 20001
    BP_CreateRole_HairColor = 1
    BP_CreateRole_HairID = 0
    BP_CreateRole_BeardType = DEFAULT_BEARD_TYPE
    BP_CreateRole_BeardID = 0
    BP_CreateRole_BeardColor = 60001
    BP_CreateRole_BeardColorID = 1
    BP_CreateRole_CardCount = 0
    EventGetCreateRoleHairID()

    CreateRoleUI:InitDefaultWearInfo()
    CreateRoleUI:InitRaces()
    CreateRoleUI:InitHairs()
    CreateRoleUI:InitBeards()
    CreateRoleUI:InitNewAvatarList()

    if(BP_CreateRole_Mode == 1) then 
        if ( BP_Platform == BP_ENUM_PLAYFORM_TOURIST) then
            -- 需求更新，去掉随机名字
            -- BP_CreateRole_Name = GetRandomName(BP_CreateRole_Sex);
            BP_CreateRole_Name = ""
        end
    end
    
    CreateRoleUI.isShowing = true;
    LuaClassObj.HandleDynamicCreation(bp_createrole);

    LuaClassObj.HandleUIMessage(bp_createrole, "UIShow");
    LuaClassObj.HandleUIMessage(bp_createrole, "SelectFemale");
end

function CreateRoleUI.RegistControlEvent()
    CreateRoleUI.UnregistControlEvent()

    local CDelegateContainer = require("client.utility.delegate_container")
    local delegateContainer = CDelegateContainer()
    CreateRoleUI.delegateContainer = delegateContainer

    CreateRoleUI.OnInitialize(delegateContainer)
end

function CreateRoleUI.UnregistControlEvent()
    if CreateRoleUI.delegateContainer then
        CreateRoleUI.delegateContainer:Dispose()
        CreateRoleUI.delegateContainer = nil
    end
end

function CreateRoleUI.GetAvatarListByType(avatarList, avatarType)
    local avatars = GetArrayAvatarInit();
    for k,v in pairs(avatars) do
        if v.AvatarType == avatarType then
            local show = true;

            if show then
                local avatar = {};
                avatar.avatar_id = k;
                avatar.remain_time = 0;
                avatar.has_item = true;
                avatar.is_new = true;
                avatar.pass_season = 0
                table.insert(avatarList, avatar);
            end
        end
    end

    table.sort(avatarList, function(a, b)
        return avatars[a.avatar_id].Sort < avatars[b.avatar_id].Sort
    end)
end

--初始化脸型
function CreateRoleUI:InitRaces()
    BP_ARRAY_CreateRole_Races = {}
    CreateRoleUI.GetAvatarListByType(BP_ARRAY_CreateRole_Races, 1)
end

--初始化发型
function CreateRoleUI:InitHairs()
    BP_ARRAY_CreateRole_Hairs = {};
    CreateRoleUI.GetAvatarListByType(BP_ARRAY_CreateRole_Hairs, 2)
end

function CreateRoleUI:InitBeards()
    BP_ARRAY_CreateRole_Beards = {}
    CreateRoleUI.GetAvatarListByType(BP_ARRAY_CreateRole_Beards, 5)

    BP_ARRAY_CreateRole_BeardColors = {}
    CreateRoleUI.GetAvatarListByType(BP_ARRAY_CreateRole_BeardColors, 6)
end

function CreateRoleUI:InitDefaultWearInfo()
    if(LobbySystem.PlayerDefaultWearInfo == nil)then
        log("Defalut WearInfo is nil");
        return;
    end
    BP_DefaultHat = LobbySystem.PlayerDefaultWearInfo[BP_CreateRole_Sex][1];
    BP_DefaultFace = LobbySystem.PlayerDefaultWearInfo[BP_CreateRole_Sex][2];
    BP_DefaultClose = LobbySystem.PlayerDefaultWearInfo[BP_CreateRole_Sex][3];
    BP_DefaultPlants = LobbySystem.PlayerDefaultWearInfo[BP_CreateRole_Sex][4];
    BP_DefaultShoes = LobbySystem.PlayerDefaultWearInfo[BP_CreateRole_Sex][5];
end

--初始化金钱和钻石
function CreateRoleUI:InitGold()
    BP_CreateRole_Gold = DataMgr.gold;
end

function CreateRoleUI:InitTicket()
    BP_CreateRole_Ticket = DataMgr.ticket;
end

function CreateRoleUI:InitNewAvatarList()
    BP_ARRAY_CreateRole_NewAvatarList = {}
    newAvatarMap = {}
    if next(DataMgr.avatarData.activate_avatar_list) ~= nil then
        for k, v in pairs(DataMgr.avatarData.activate_avatar_list) do
            if v == 1 then
                table.insert(BP_ARRAY_CreateRole_NewAvatarList, k)
                newAvatarMap[k] = true
            end
        end
    end
    log_tree("[LLP]CreateRoleUI:InitNewAvatarList:",BP_ARRAY_CreateRole_NewAvatarList);
end

function CreateRoleUI:SelectNewAvatarList(avatar_id)
    for k, v in pairs(BP_ARRAY_CreateRole_NewAvatarList) do
        if v == avatar_id then
            NetUtil.SendPkg("select_avatar", avatar_id);
            BP_ARRAY_CreateRole_NewAvatarList[k] = nil;
            newAvatarMap[avatar_id] = nil
        end
    end
    log_tree("[LLP]CreateRoleUI:SelectNewAvatarList:",BP_ARRAY_CreateRole_NewAvatarList);
end

function CreateRoleUI:Release()
    log("CreateRoleUI release");
end

--异常提示
function CreateRoleUI:ShowIllegalInfo(info)
    local text = "";
    if (info == "name-too-long") then
        text = Client.GetTableData("LocalizeRes", "990002").TextValue;
    elseif (info == "name-too-short") then
        text = Client.GetTableData("LocalizeRes", "990003").TextValue;
    elseif (info == "have-dirty-in-name") then
        text = Client.GetTableData("LocalizeRes", "990004").TextValue;
    elseif (info == "name-exist") then
        text = Client.GetTableData("LocalizeRes", "990005").TextValue;
    elseif (info == "bad-request") then
        text = Client.GetTableData("LocalizeRes", "990006").TextValue;
    else
        text = info;
    end
    log(text)
    PopUpNoticeUI.ShowNewNotice(text);
end

--返回随机名字
function GetRandomName(sex)
    local name = ""
    local  NameTabel = Client.GetTable("NameTable");
    if(NameTabel == nil) then
        return name;
    end
    local n = #NameTabel;
    local n0 = math.random(n)
    local n1 = math.random(n)
    if(BP_CreateRole_Sex == BP_ENUM_GENDER_MALE) then
        name = NameTabel[n0].b
    else
        name = NameTabel[n0].c
    end


    local endStr = "";
    local endRdm = math.random(10);
    
    if (endRdm > 5) then
        
        if (randomNameEndCount == 0) then
           randomNameEndCount = CreateRoleUI.CalculateRandomNameEndCount();
        end
        
        if (randomNameEndCount > 0) then
            local endIndex = math.random(randomNameEndCount);
            local endItem = NameTabel[endIndex];
            if (endItem ~= nil and endItem.d ~= nil) then
                endStr = endItem.d;
            end
        else
            log("GetRandomName randomNameEndCount == 0");
        end
    end
    name = NameTabel[n1].a .. name .. endStr;
    return name
end

function CreateRoleUI.CalculateRandomNameEndCount()    
   local endCount = 0;
   local  NameTabel = Client.GetTable("NameTable");
   local n = #NameTabel;
    for i = 1, n, 1 do
        local nameItem = NameTabel[i];
        if (nameItem ~= nil and nameItem.d ~= nil and string.len(nameItem.d) > 0) then
            endCount = endCount + 1;
        end
    end
    return endCount;
end

function CreateRoleUI.OnInitialize(delegateContainer)
    CreateRoleUI.OnChangeSex()

    local CreateRoleBP = UIUtil.GetWidgetByName("bp_createrole", "Lobby_CreatingRole_UIBP")
    if CreateRoleBP.WrapBox_Beard:GetChildrenCount() ~= 0 then
        CreateRoleBP.WrapBox_Beard:ClearChildren()
    end
    if CreateRoleBP.WrapBox_BeardColor:GetChildrenCount() ~= 0 then
        CreateRoleBP.WrapBox_BeardColor:ClearChildren()
    end

    for i, v in pairs(BP_ARRAY_CreateRole_Beards) do
        local roleItem = slua.loadUI("/Game/UMG/UI_BP/Lobby/Item/Lobby_RoleTypeItem_UIBP.Lobby_RoleTypeItem_UIBP")
        CreateRoleBP.WrapBox_Beard:AddChild(roleItem)

        delegateContainer:AddControlEvent(roleItem.Button_ItemIcon, "OnClicked", CreateRoleUI.OnBeardItemClicked, roleItem, i)
    end

    for i, v in pairs(BP_ARRAY_CreateRole_BeardColors) do
        local colorItem = slua.loadUI("/Game/UMG/UI_BP/Lobby/Item/Lobby_RoleColorItem_UIBP.Lobby_RoleColorItem_UIBP")
        CreateRoleBP.WrapBox_BeardColor:AddChild(colorItem)

        delegateContainer:AddControlEvent(colorItem.Button_Item, "OnClicked", CreateRoleUI.OnBeardColorItemClicked, colorItem, i)
    end

    CreateRoleUI.RefreshBeardItems()
    CreateRoleUI.RefreshBeardColorItems()
end

function CreateRoleUI.OnBeardItemClicked(widget, index)
    print("CreateRoleUI.OnBeardItemClicked:", index, BP_ARRAY_CreateRole_Beards[index], widget)
    BP_CreateRole_BeardType = BP_ARRAY_CreateRole_Beards[index].avatar_id

    CreateRoleUI.RefreshBeardID()
    CreateRoleUI:UpdateSelectTip(BP_CreateRole_BeardType)
    CreateRoleUI:UpdateButtonVisible()
    CreateRoleUI.RefreshBeardItems()
    CreateRoleUI.RefreshBeardColorItems()
    local CreateRoleBP = UIUtil.GetWidgetByName("bp_createrole", "Lobby_CreatingRole_UIBP")
    CreateRoleBP:RefreshUI()
end

function CreateRoleUI.RefreshBeardID()
    local avatarData = Client.GetTableData("AvatarInit", BP_CreateRole_BeardType)
    local beardId = BP_CreateRole_BeardID

    if avatarData and avatarData.Sex == BP_CreateRole_Sex then
        BP_CreateRole_BeardID = avatarData.BodyID
    else
        BP_CreateRole_BeardID = 0
    end

    if BP_CreateRole_BeardID == 0 then
        local KismetSystemLibrary = import("KismetSystemLibrary")
        local CreateRoleBP = UIUtil.GetWidgetByName("bp_createrole", "Lobby_CreatingRole_UIBP")
        print("PutOffEquipmentByResID", beardId )
        if beardId ~= 0 and KismetSystemLibrary.IsValid(CreateRoleBP.playerLobbyPawn) then
            CreateRoleBP.playerLobbyPawn:PutOffEquipmentByResID(beardId)
        end
        if avatarData.Sex ~= BP_CreateRole_Sex then
            BP_CreateRole_BeardColorID = 0
        else
            local avatarData = Client.GetTableData("AvatarInit", BP_CreateRole_BeardColor)
            if avatarData then
                BP_CreateRole_BeardColorID = avatarData.BeardColor
            end
        end
    end
end

function CreateRoleUI.OnBeardColorItemClicked(widget, index)
    print("CreateRoleUI.OnBeardColorItemClicked:", index, widget)
    local avatarId = BP_ARRAY_CreateRole_BeardColors[index].avatar_id
    BP_CreateRole_BeardColor = avatarId

    local avatarData = Client.GetTableData("AvatarInit", avatarId)
    if avatarData then
        BP_CreateRole_BeardColorID = avatarData.BeardColor
    else
        BP_CreateRole_BeardColorID = 0
    end
    CreateRoleUI:UpdateSelectTip(avatarId)
    CreateRoleUI:UpdateButtonVisible()
    CreateRoleUI.RefreshBeardItems()
    CreateRoleUI.RefreshBeardColorItems()
    local CreateRoleBP = UIUtil.GetWidgetByName("bp_createrole", "Lobby_CreatingRole_UIBP")
    CreateRoleBP:RefreshUI()
end

local avatarTypeMountedMap = {
    [5] = { currentSelect = "BP_CreateRole_BeardType"},
    [6] = { currentSelect = "BP_CreateRole_BeardColor"},
}

function CreateRoleUI.RefreshBearItem(widget, buyAvatarInfo)
    local avatarData = Client.GetTableData("AvatarInit", buyAvatarInfo.avatar_id)
    local avatarPath = avatarData.AvatarIcon
    if BP_CreateRole_Sex == 2 then
        avatarPath = avatarData.FemaleAvatarIcon
    end

    local util = require("ui.util")
    util.SetTexture(widget.Image_ItemIcon, avatarPath)

    widget.Image_new:SetVisibility(UIUtil.BoolToVisible(newAvatarMap[buyAvatarInfo.avatar_id], true))
    widget.Image_Lock:SetVisibility(UIUtil.BoolToVisible(buyAvatarInfo.remain_time < 0, true))
    widget.CanvasExperience:SetVisibility(UIUtil.BoolToVisible(buyAvatarInfo.has_item and buyAvatarInfo.remain_time < 0, true))
    widget.Image_Selected:SetVisibility(UIUtil.BoolToVisible(
            BP_STRUCT_CreateRole_SelectTip.avatar_id == buyAvatarInfo.avatar_id, true))

    local mountedData = avatarTypeMountedMap[avatarData.AvatarType]
    local isMounted = false
    if mountedData then
        isMounted = _G[mountedData.currentSelect] == buyAvatarInfo.avatar_id
        print("CreateRoleUI.RefreshBearItem", isMounted, _G[mountedData.currentSelect], buyAvatarInfo.avatar_id)
    end
    widget.Cornermark_Selected:SetVisibility(UIUtil.BoolToVisible(isMounted, true))
end

function CreateRoleUI.RefreshBearColorItem(widget, buyAvatarInfo)
    local avatarData = Client.GetTableData("AvatarInit", buyAvatarInfo.avatar_id)
    local avatarPath = avatarData.AvatarIcon
    if BP_CreateRole_Sex == 2 then
        avatarPath = avatarData.FemaleAvatarIcon
    end

    local util = require("ui.util")
    util.SetTexture(widget.Image_ItemColorIcon, avatarPath)

    widget.Image_Selected:SetVisibility(UIUtil.BoolToVisible(
            BP_STRUCT_CreateRole_SelectTip.avatar_id == buyAvatarInfo.avatar_id, true))
    widget.Image_NormalStateBox:SetVisibility(UIUtil.BoolToVisible(
            BP_STRUCT_CreateRole_SelectTip.avatar_id ~= buyAvatarInfo.avatar_id, true))

    local mountedData = avatarTypeMountedMap[avatarData.AvatarType]
    local isMounted = false
    if mountedData then
        isMounted = _G[mountedData.currentSelect] == buyAvatarInfo.avatar_id
    end
    widget.Cornermark_Selected:SetVisibility(UIUtil.BoolToVisible(isMounted, true))
end

function CreateRoleUI.RefreshBeardItems()
    local CreateRoleBP = UIUtil.GetWidgetByName("bp_createrole", "Lobby_CreatingRole_UIBP")
    for i, v in pairs(BP_ARRAY_CreateRole_Beards) do
        local widget = CreateRoleBP.WrapBox_Beard:GetChildAt(i - 1)
        CreateRoleUI.RefreshBearItem(widget, v)
    end
end

function CreateRoleUI.RefreshBeardColorItems()
    local CreateRoleBP = UIUtil.GetWidgetByName("bp_createrole", "Lobby_CreatingRole_UIBP")
    for i, v in pairs(BP_ARRAY_CreateRole_BeardColors) do
        local widget = CreateRoleBP.WrapBox_BeardColor:GetChildAt(i - 1)
        CreateRoleUI.RefreshBearColorItem(widget, v)
    end
end

function CreateRoleUI.OnChangeSex()
    local CreateRoleBP = UIUtil.GetWidgetByName("bp_createrole", "Lobby_CreatingRole_UIBP")
    local visibility = UEnums.ESlateVisibility.Collapsed
    if BP_CreateRole_Sex == 1 then
        visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
    end
    CreateRoleBP.InvalidationBox_Beard:SetVisibility(visibility)
    CreateRoleBP.InvalidationBox_BeardColor:SetVisibility(visibility)

    CreateRoleUI.RefreshBeardID()
end

--弹出重置角色面板
function CreateRoleUI.ShowResetAvatarUI()
    BP_CreateRole_LobbyToAvatar = 1;
    CreateRoleUI.isShowing = true;
    
    log("CreateRoleUI.ShowResetAvatarUI");
    LuaClassObj.HandleDynamicCreation(bp_createrole);
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)

    CreateRoleUI:DataMgrToAvatarData()

    local CDelegateContainer = require("client.utility.delegate_container")
    local delegateContainer = CDelegateContainer()
    CreateRoleUI.delegateContainer = delegateContainer
    CreateRoleUI.OnInitialize(delegateContainer)

    LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni");
    LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraFarImmediate");
end

--点击按钮随机名字
function EventRandomName()
    log("EventRandomName");
    BP_CreateRole_Name = GetRandomName(BP_CreateRole_Sex);
    
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end

--点击按钮选择男性
function EventSelectMale()
	log("EventSelectMale");
    BP_CreateRole_Sex = 1;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:InitDefaultWearInfo();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleSex());
    CreateRoleUI.OnChangeSex()
    CreateRoleUI.RefreshBeardItems()
    CreateRoleUI.RefreshBeardColorItems()
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end

--点击按钮选择女性
function EventSelectFeMale()
	log("EventSelectFeMale");
    BP_CreateRole_Sex = 2;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:InitDefaultWearInfo();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleSex());
    CreateRoleUI.OnChangeSex()
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end

--点击选择脸型
function EventSelectRace()
    log("BP_CreateRole_Race");
    CreateRoleUI:UpdateButtonVisible();
    EventGetCreateRoleHeadID();
    CreateRoleUI:UpdateSelectTip(BP_CreateRole_Race);
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end

--点击按钮选择发型
function EventSelectHairType()
    CreateRoleUI:UpdateButtonVisible();
    EventGetCreateRoleHairID();
    CreateRoleUI:UpdateSelectTip(BP_CreateRole_HairType);
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end

--点击按钮选择发色1
function EventSelectHairColor1()
	log("BP_CreateRole_HairColor 1");
    BP_CreateRole_HairColor = 1;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleHairColor());
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end
--点击按钮选择发色2
function EventSelectHairColor2()
	log("BP_CreateRole_HairColor 2");
    BP_CreateRole_HairColor = 2;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleHairColor());
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end
--点击按钮选择发色3
function EventSelectHairColor3()
	log("BP_CreateRole_HairColor 3");
    BP_CreateRole_HairColor = 3;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleHairColor());
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end
--点击按钮选择发色4
function EventSelectHairColor4()
	log("BP_CreateRole_HairColor 4");
    BP_CreateRole_HairColor = 4;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleHairColor());
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end
--点击按钮选择发色5
function EventSelectHairColor5()
	log("BP_CreateRole_HairColor 5");
    BP_CreateRole_HairColor = 5;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleHairColor());
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end
--点击按钮选择发色6
function EventSelectHairColor6()
	log("BP_CreateRole_HairColor 6");
    BP_CreateRole_HairColor = 6;
    CreateRoleUI:UpdateButtonVisible();
    CreateRoleUI:UpdateSelectTip(EventGetCreateRoleHairColor());
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
end

function EventUpdateCardCount()
    local itemData = DataMgr.GetHallDepotItemDataByResID(CreateRoleUI.cardID);
    if(itemData ~= nil) then
        BP_CreateRole_CardCount = itemData.count;
    else
        BP_CreateRole_CardCount = 0;
    end
    log("BP_CreateRole_CardCount:"..BP_CreateRole_CardCount);
end

--Avatar设置模式
function EventOpenAvatarResetPanel()
    BP_CreateRole_LobbyToAvatar = 1;
    CreateRoleUI.isShowing = true;
    
    log("EventOpenAvatarResetPanel");
    LuaClassObj.HandleDynamicCreation(bp_createrole);
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)

    CreateRoleUI:DataMgrToAvatarData()

    LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni");
    LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraFarImmediate");
end

--显示Avatar设置UI
function EventOpenAvatarResetPanelInter()
	log("EventOpenAvatarResetPanelInter xxx");
    BP_CreateRole_Mode = 2;
    EventUpdateCardCount();
    CreateRoleUI:DataMgrToAvatarData();

    LuaClassObj.HandleUIMessage(bp_createrole, "UIShow");
    LuaClassObj.HandleUIMessage(bp_createrole, "HideResetButton");
    LuaClassObj.HandleUIMessage(bp_createrole, "PlayFadeIn");

    CreateRoleUI.RefreshBeardItems()
    CreateRoleUI.RefreshBeardColorItems()
end

function CreateRoleUI.ClosePanel()
    if CreateRoleUI.isShowing then
        LuaClassObj.HandleUIMessage(bp_createrole, "UIHide");
    end
end

--还原Avatar设置
function EventCancelAvatarReset()
    log("EventCancelAvatarReset")
    
    CreateRoleUI:DataMgrToAvatarData();

    LuaClassObj.HandleUIMessage(bp_createrole, "CreateAvatar");
    LuaClassObj.HandleUIMessage(bp_createrole, "UIShow");
    LuaClassObj.HandleUIMessage(bp_createrole, "HideResetButton");
    LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraFar");

    CreateRoleUI.RefreshBeardItems()
    CreateRoleUI.RefreshBeardColorItems()
end

--关闭Avatar设置
function EventCloseAvatarResetPanel()
    log("EventCloseAvatarResetPanel")
    
    BP_CreateRole_Mode = 1;
    BP_CreateRole_LobbyToAvatar = 0;
    CreateRoleUI.isShowing = false;
    
    LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni");
    TeamAvatarManager.EnablePutonEvent(tostring(DataMgr.roleData.uid), true)
end

--关闭Avatar设置
function EventCloseAvatarResetPanelInter()
    if WarZoneRankUI.isShow then
        -- http://tapd.oa.com/20360302/bugtrace/bugs/view?bug_id=1020360302066032971
        -- 为了解决这个问题，先判断是不是从WarZoneRankUI中过来的
        -- 不直接调用EVENTID_WARDROBE_AVATAR_RESET_CLOSE事件是因为很多副作用
        -- 这个事件会通知到lobby, lobby会负责打开roleinfo界面, 然后引发界面错乱, 这个不应该是lobby去负责的
        -- 所以这里针对这个需求特地手动打开WarZoneRank界面，手动打开roleinfo界面
        -- 这个方法治标不治本，很可能之后也会出现类似问题
        -- 最终应该有一个类似ui堆栈的东西来管理界面，负责打开关闭
        WarZoneRankUI.WardRobeAvatarResetClose()
        LuaClassObj.HandleUIMessage(bp_roleinfo, "UIShow")

        -- 设置一下这个值，以防lobby重新打开roleinfo
        RoleInfo_JumpResetAvatar = false;
    else
        log("EventCloseAvatarResetPanelInter")
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, SceneType.AvatarReset)
    end
end

local function GatherBuyInfo(avatarId, buyList, ucBuyList)
    local info = {}
    info.avatar_id = avatarId
    info.selected = 1
    info.owned = false
    info.remain_time_str = ""

    local arrayAvatarInit = GetArrayAvatarInit()
    if arrayAvatarInit[avatarId].ForeverCost > 0 then
        -- info.remain_time_str = "剩余：永久"
        info.buy_time_type = 4
        if DataMgr.GetAvatarRemainTime(info.avatar_id) >= 0 then
            info.owned = true
        else
            table.insert(ucBuyList, info)
        end
    elseif arrayAvatarInit[avatarId].AcquireMode == 1 then
        info.buy_time_type = 1
    else
        info.buy_time_type = 0
        info.owned = DataMgr.GetAvatarRemainTime(info.avatar_id) >= 0
    end
    table.insert(buyList, info)
end

local function GatherAvatarBuyInfos(buyList, ucBuyList)
    if BP_CreateRole_Race ~= CreateRoleUI.race then
        GatherBuyInfo(BP_CreateRole_Race, buyList, ucBuyList)
    end

    if BP_CreateRole_HairType ~= CreateRoleUI.hairType then
        GatherBuyInfo(BP_CreateRole_HairType, buyList, ucBuyList)
    end

    if BP_CreateRole_BeardType ~= CreateRoleUI.beardType and BP_CreateRole_Sex == 1 then
        GatherBuyInfo(BP_CreateRole_BeardType, buyList, ucBuyList)
    end

    if BP_CreateRole_BeardColor ~= CreateRoleUI.beardColor and BP_CreateRole_Sex == 1 then
        GatherBuyInfo(BP_CreateRole_BeardColor, buyList, ucBuyList)
    end

    local arrayAvatarInit = GetArrayAvatarInit()

    if BP_CreateRole_HairColor ~= CreateRoleUI.hairColor then
        for k,v in pairs(arrayAvatarInit) do
            if v.AvatarType == 3 and BP_CreateRole_HairColor == v.HairColor then
                local info = {}
                info.avatar_id = k
                info.selected = 1
                info.owned = false
                info.buy_time_type = 1
                table.insert(buyList, info)
                break;
            end
        end
    end

    if BP_CreateRole_Sex ~= CreateRoleUI.sex then
        for k,v in pairs(arrayAvatarInit) do
            if v.AvatarType == 4 and BP_CreateRole_Sex == v.Sex then
                local info = {}
                info.avatar_id = k
                info.selected = 1
                info.owned = false
                info.buy_time_type = 1
                table.insert(buyList, info)
                break;
            end
        end
    end
end

--点击购买显示购买列表
function EventShowAvatarResetBuyPanel()
    BP_Array_CreateRole_BuyAvatars = {};
    BP_ARRAY_CreateRole_UCBuyAvatars = {}

    GatherAvatarBuyInfos(BP_Array_CreateRole_BuyAvatars, BP_ARRAY_CreateRole_UCBuyAvatars)

    if next(BP_ARRAY_CreateRole_UCBuyAvatars) ~= nil then
        --有需要花费UC券的avatar，弹出购买界面
        BP_CreateRole_BuyMode = 2;
        LuaClassObj.HandleUIMessage(bp_createrole, "ShowAvatarBuy");
    else
        --有需要花费的avatar，弹出购买界面
        BP_CreateRole_BuyMode = 1;
        LuaClassObj.HandleUIMessage(bp_createrole, "ShowAvatarBuy");
    end
end

--购买avatar
function EventBuyAvatar()
    local list = {}
    local function GetSelectedAvatar(array)
        for _, v in pairs(array) do
            if v.selected == 1 then
                list[v.avatar_id] = v.buy_time_type
            end
        end
    end

    if BP_CreateRole_BuyMode == 1 then
        GetSelectedAvatar(BP_Array_CreateRole_BuyAvatars)
    else
        GetSelectedAvatar(BP_ARRAY_CreateRole_UCBuyAvatars)
    end

    log_tree("EventBuyAvatar:", list);
    if next(list) ~= nil then
        NetUtil.SendPriorityPkg(false, "batch_buy_avatar_features_rsp", "batch_buy_avatar_features_req", list);
    end
end

--过滤不合法字符
function EventFilterName()
    _ , _ , BP_CreateRole_Name = FuncUtil:CheckName(BP_CreateRole_Name, true, 14);
    LuaClassObj.HandleUIMessage(bp_createrole, "UpdatePlayerName");
end

--还原Avatar数据
function CreateRoleUI:DataMgrToAvatarData()
    log("CreateRoleUI:DataMgrToAvatarData()");
    --DataMgr.avatarData.hairid
    if(DataMgr.avatarData.hairid < 500000) then
        log("log old style hairid = ".. DataMgr.avatarData.hairid);
        DataMgr.avatarData.hairid = 40601001;
    end
    LobbySystem.check_avatar_time();
    local data =  DataMgr.avatarData.hairid % (BP_ENUM_AVATAR_HAIR * 100000);
    local hairColor = math.floor(data / 1000);
    local hairtype = data % 1000;
    BP_CreateRole_Sex = DataMgr.avatarData.gamegender;
    BP_CreateRole_HeadId = DataMgr.avatarData.headid;
    CreateRoleUI:InitGold()
    CreateRoleUI:InitTicket()
    CreateRoleUI:InitRaces()
    CreateRoleUI:InitHairs()
    CreateRoleUI:InitBeards()

    CreateRoleUI:InitNewAvatarList()
    CreateRoleUI:GetCreateRoleHeadOrRace(false)
    for k,v in pairs(GetArrayAvatarInit()) do
        if v.AvatarType == 2 and hairtype == tonumber(v.Hair) then
            BP_CreateRole_HairType = k
            break
        end
    end
    BP_CreateRole_HairColor = hairColor
    BP_CreateRole_HairID = DataMgr.avatarData.hairid
    BP_CreateRole_BeardID = DataMgr.avatarData.beardid or 0
    BP_CreateRole_BeardType = DEFAULT_BEARD_TYPE
    for k, v in pairs(GetArrayAvatarInit()) do
        if v.AvatarType == 5 and v.BodyID == BP_CreateRole_BeardID then
            BP_CreateRole_BeardType = k
            break
        end
    end
    BP_CreateRole_BeardColorID = DataMgr.avatarData.beardcolorid or 0;
    BP_CreateRole_BeardColor = 60001
    if BP_CreateRole_BeardColorID ~= 0 then
        for k, v in pairs(GetArrayAvatarInit()) do
            if v.AvatarType == 6 and v.BeardColor == BP_CreateRole_BeardColorID then
                BP_CreateRole_BeardColor = k
                break
            end
        end
    end
    CreateRoleUI.sex = DataMgr.avatarData.gamegender;
    CreateRoleUI.head = DataMgr.avatarData.headid;
    CreateRoleUI.race = BP_CreateRole_Race;
    CreateRoleUI.hairType = BP_CreateRole_HairType;
    CreateRoleUI.hairColor = BP_CreateRole_HairColor;
    CreateRoleUI.beardType = BP_CreateRole_BeardType
    CreateRoleUI.beardColor = BP_CreateRole_BeardColor
    CreateRoleUI:UpdateSelectTip(BP_CreateRole_Race);
	log("DataMgrToAvatarData sex "..CreateRoleUI.sex);
	log("DataMgrToAvatarData head "..CreateRoleUI.head);
	log("DataMgrToAvatarData race "..CreateRoleUI.race);
	log("DataMgrToAvatarData hairType "..CreateRoleUI.hairType);
	log("DataMgrToAvatarData hairColor "..CreateRoleUI.hairColor);
end

--购买AVATAR
function CreateRoleUI:BuyAvatarOK(avatar_list)
    log_tree("[LLP]CreateRoleUI:BuyAvatarOK", avatar_list)
    log_tree("[LLP]CreateRoleUI:BuyAvatarOK Before", DataMgr.avatarData)
    local needRebuild = false;
    if( DataMgr.avatarData.gamegender ~= BP_CreateRole_Sex) then
        needRebuild = true;
    end
    if( DataMgr.avatarData.headid ~= BP_CreateRole_HeadId) then
        needRebuild = true;
    end
    --从avatar列表中设置信息
    local gamegender = DataMgr.avatarData.gamegender;
    local headid = DataMgr.avatarData.headid;
    local hairid = DataMgr.avatarData.hairid;
    local beardid = DataMgr.avatarData.beardid;
    local beardcolorid = DataMgr.avatarData.beardcolorid;
    local data =  hairid % (BP_ENUM_AVATAR_HAIR * 100000);
    local haircolor = math.floor(data / 1000);
    local hairtype = data % 1000;
    local avatars = GetArrayAvatarInit();
    for k,v in pairs(avatar_list) do
        local avatar = avatars[k];
        if avatar ~= nil then
            if avatar.AvatarType == 1 then
                --脸型
                headid = avatar.BodyID;
            elseif avatar.AvatarType == 2 then
                --发型
                hairtype = tonumber(avatar.Hair);
            elseif avatar.AvatarType == 3 then
                --发色
                haircolor = avatar.HairColor;
            elseif avatar.AvatarType == 4 then
                --性别
                gamegender = avatar.Sex;
            elseif avatar.AvatarType == 5 then
                beardid = avatar.BodyID
            elseif avatar.AvatarType == 6 then
                beardcolorid = avatar.BeardColor
            end
        end
    end
    DataMgr.avatarData.gamegender = gamegender;
    DataMgr.avatarData.headid = headid;
    DataMgr.avatarData.hairid = tonumber(string.format("%s%02s%03s", BP_ENUM_AVATAR_HAIR, haircolor, hairtype), 10);
    DataMgr.avatarData.beardid = beardid
    DataMgr.avatarData.beardcolorid = beardcolorid
    CreateRoleUI:DataMgrToAvatarData();
    CreateRoleUI.RefreshBeardItems()
    CreateRoleUI.RefreshBeardColorItems()
	-- 更新全局游戏性别
    GlobalData:SetGameGender(DataMgr.avatarData.gamegender);
    log_tree("[LLP]CreateRoleUI:BuyAvatarOK After", DataMgr.avatarData)
    LuaClassObj.HandleUIMessage(bp_createrole, "HideResetButton");
    LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraFar");
    LuaClassObj.HandleUIMessage(bp_createrole, "RefreshUI");
    return needRebuild;
end

function CreateRoleUI:GetCreateRoleHeadOrRace(r2h)
    --6个头ID
    local avatars = GetArrayAvatarInit();
    if(r2h) then
        BP_CreateRole_HeadId = avatars[BP_CreateRole_Race].BodyID;
    else
        BP_CreateRole_Race = 1;
        for i,v in ipairs(BP_ARRAY_CreateRole_Races) do
            if avatars[v.avatar_id].BodyID == BP_CreateRole_HeadId then
                BP_CreateRole_Race = v.avatar_id;
                break;
            end
        end
    end
end

function CreateRoleUI:UpdateButtonVisible()
    local show = false;
    if BP_CreateRole_Sex ~= CreateRoleUI.sex then
        show = true;
    end
    if BP_CreateRole_Race ~= CreateRoleUI.race then
        show = true;
    end
    if BP_CreateRole_HairType ~= CreateRoleUI.hairType then
        show = true;
    end
    if BP_CreateRole_HairColor ~= CreateRoleUI.hairColor then
        show = true;
    end
    if BP_CreateRole_BeardType ~= CreateRoleUI.beardType then
        show = true;
    end
    if BP_CreateRole_BeardColor ~= CreateRoleUI.beardColor then
        show = true;
    end

    if show then
        LuaClassObj.HandleUIMessage(bp_createrole, "ShowResetButton");
    else
        LuaClassObj.HandleUIMessage(bp_createrole, "HideResetButton");
    end
    LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraClosein");
end

--更新选中提示
function CreateRoleUI:UpdateSelectTip(avatar_id)
    BP_STRUCT_CreateRole_SelectTip.avatar_id = avatar_id;
    BP_STRUCT_CreateRole_SelectTip.is_ticket = false;
    DataMgr.avatarData.activate_avatar_list[avatar_id] = nil;
    CreateRoleUI:SelectNewAvatarList(avatar_id);
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_AVATAR_ACTIVATE);
    local avatar = GetArrayAvatarInit()[avatar_id];
    if avatar == nil then
        BP_STRUCT_CreateRole_SelectTip.avatar_name = "";
        BP_STRUCT_CreateRole_SelectTip.remain_time_str = "";
        BP_STRUCT_CreateRole_SelectTip.avatar_price = 0;
        BP_STRUCT_CreateRole_SelectTip.show_price = false;
        BP_STRUCT_CreateRole_SelectTip.has_item = false;
        return;
    end
    local headDepotItem = DataMgr.GetHallDepotItemDataByResID(avatar_id);
    BP_STRUCT_CreateRole_SelectTip.avatar_name = avatar.AvatarName;
    local remainTime = DataMgr.GetAvatarRemainTime(avatar_id);
    if remainTime > 0 then
        BP_STRUCT_CreateRole_SelectTip.avatar_name = FuncUtil.GetLocalizeResStr("990010");
        BP_STRUCT_CreateRole_SelectTip.remain_time_str = FuncUtil.TimeFormatExt(remainTime) .. FuncUtil.GetLocalizeResStr("990011");
        BP_STRUCT_CreateRole_SelectTip.avatar_price = 0;
        BP_STRUCT_CreateRole_SelectTip.show_price = false;
        BP_STRUCT_CreateRole_SelectTip.has_item = false;
    else
        BP_STRUCT_CreateRole_SelectTip.remain_time_str = "";
        if avatar_id == CreateRoleUI.race or avatar_id == CreateRoleUI.hairType or
        (avatar.AvatarType == 3 and avatar.HairColor == CreateRoleUI.hairColor) or
        (avatar.AvatarType == 4 and avatar.Sex == CreateRoleUI.sex) then
            BP_STRUCT_CreateRole_SelectTip.avatar_name = "";
            BP_STRUCT_CreateRole_SelectTip.avatar_price = 0;
            BP_STRUCT_CreateRole_SelectTip.show_price = false;
            BP_STRUCT_CreateRole_SelectTip.has_item = false;
        elseif avatar.AcquireMode == 1 then
            BP_STRUCT_CreateRole_SelectTip.avatar_name = FuncUtil.GetLocalizeResStr("990010");
            BP_STRUCT_CreateRole_SelectTip.avatar_price = avatar.ResetCost;
            BP_STRUCT_CreateRole_SelectTip.show_price = true;
            BP_STRUCT_CreateRole_SelectTip.has_item = headDepotItem ~= nil;
        else
            local beOwner = DataMgr.GetAvatarRemainTime(avatar_id) >= 0;
            if avatar.ForeverCost > 0 then
                BP_STRUCT_CreateRole_SelectTip.avatar_name = FuncUtil.GetLocalizeResStr("990010");
                BP_STRUCT_CreateRole_SelectTip.avatar_price = beOwner and 0 or avatar.ForeverCost;
                BP_STRUCT_CreateRole_SelectTip.is_ticket = not beOwner;
            --[[elseif avatar.MonthCost > 0 then
                BP_STRUCT_CreateRole_SelectTip.avatar_name = FuncUtil.GetLocalizeResStr("990010");
                BP_STRUCT_CreateRole_SelectTip.avatar_price = beOwner and 0 or avatar.MonthCost;
            elseif avatar.SevenCost > 0 then
                BP_STRUCT_CreateRole_SelectTip.avatar_name = FuncUtil.GetLocalizeResStr("990010");
                BP_STRUCT_CreateRole_SelectTip.avatar_price = beOwner and 0 or avatar.SevenCost;
            ]]
            end
            BP_STRUCT_CreateRole_SelectTip.show_price = true;
            BP_STRUCT_CreateRole_SelectTip.has_item = headDepotItem ~= nil;
        end
    end
	
	BP_STRUCT_CreateRole_SelectTip.pass_season = Client.GetTableData("AvatarInit", avatar_id).RoyalePassSeason
    -- royale pass获得的无价格
    if BP_STRUCT_CreateRole_SelectTip.pass_season > 0 then
        BP_STRUCT_CreateRole_SelectTip.show_price = false
    end
end

--获得当前选定的头ID
function EventGetCreateRoleHeadID()
    log("EventGetCreateRoleHeadID")
    CreateRoleUI:GetCreateRoleHeadOrRace(true)
end

--获取当前获得的头发ID
function EventGetCreateRoleHairID()
    log("EventGetCreateRoleHairID: HairType = :" .. BP_CreateRole_HairType);
    local avatar = GetArrayAvatarInit()[tonumber(BP_CreateRole_HairType)];
    local hairType = 1;
    if avatar ~= nil then
        hairType = tonumber(avatar.Hair);
    end
    local hairIdStr = string.format("%s%02s%03s", BP_ENUM_AVATAR_HAIR, BP_CreateRole_HairColor, hairType);
    BP_CreateRole_HairID = tonumber(hairIdStr, 10); 
    log("EventGetCreateRoleHairID:" .. BP_CreateRole_HairID);
end

--获取当前选定的发色avatar_id
function EventGetCreateRoleHairColor()
    local avatar_id = 0;
    for k,v in pairs(GetArrayAvatarInit()) do
        if v.AvatarType == 3 and BP_CreateRole_HairColor == v.HairColor then
            avatar_id = k;
            break;
        end
    end
    return avatar_id;
end

--获取当前选定的性别avatar_id
function EventGetCreateRoleSex()
    local avatar_id = 0;
    for k,v in pairs(GetArrayAvatarInit()) do
        if v.AvatarType == 4 and BP_CreateRole_Sex == v.Sex then
            avatar_id = k;
            break;
        end
    end
    return avatar_id;
end

function CreateRoleUI.OnDepotDataChange()
    log("CreateRoleUI OnDepotDataChange")
    EventUpdateCardCount();
    LuaClassObj.HandleUIMessage(bp_createrole, "UpdateCost");
end

--点击按钮进入大厅 (offline version from 0.11.1 mod)
function EventEnterLobby()
    log("EventEnterLobby from createrole:"..BP_CreateRole_Name);
    
    local ret, len, retStr = FuncUtil:CheckName(BP_CreateRole_Name, true);
    if ret then
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "990004").TextValue);
        return;
    elseif len > 14 then
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "990002").TextValue);
        return;
    elseif len == 0 then
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "990003").TextValue);
        return;
    end
    
    DeviceOSInfo.getDeviceOSInfo();
    EventGetCreateRoleHeadID()
    EventGetCreateRoleHairID();
    
    log("create_role: " .. BP_CreateRole_Name .. " " .. BP_CreateRole_Sex .. " " .. BP_CreateRole_HeadId .." " .. BP_CreateRole_HairID);

    pcall(function() ConnectionWaitingUI:Hide() end)
    pcall(function() LoadingUI:Init() end)
    pcall(function() LoadingUI.RefreshLoadPercent(1) end)

    if _G.writeLog then _G.writeLog("EventEnterLobby: setting DataMgr fields") end
    DataMgr.roleData.nickName = BP_CreateRole_Name
    DataMgr.roleData.uid = "10001"
    DataMgr.roleData.openID = "local_openid_10001"
    DataMgr.roleData.level = 100
    DataMgr.roleData.gender = BP_CreateRole_Sex
    DataMgr.roleData.gamegender = BP_CreateRole_Sex
    DataMgr.roleData.headid = BP_CreateRole_HeadId
    DataMgr.roleData.hairid = BP_CreateRole_HairID
    DataMgr.roleData.nation = BP_CreateRole_Nation or ""
    DataMgr.roleData.roleExp = 0
    DataMgr.gold = 999999
    DataMgr.ticket = 999999
    DataMgr.diamond = 999999
    DataMgr.rolewear = {}

    CreateRoleUI.respond = "ok"
    LobbySystem.isNewPlayer = true
    LobbySystem.firstCreateRole = true
    LoginSystem.isInLobby = true
    LoginSystem.isInitLogin = true
    LoginSystem.isRelogin = false

    BP_FAKE_CREATED_ROLE_NAME = DataMgr.roleData.nickName
    BP_PlayerName = DataMgr.roleData.nickName

    DataMgr.roleData.signature = ""
    DataMgr.roleData.headIconUrl = "30060"
    DataMgr.roleData.cur_avatar_box_id = 2002901
    DataMgr.roleData.qq_vip = 0
    DataMgr.roleData.xy_red_point = 0
    DataMgr.roleData.credit = 100
    DataMgr.roleData.alias = {id = 1, rank = 801, title = "Conqueror", nation = "US"}
    DataMgr.roleData.corps_alias_data = {}
    DataMgr.roleData.eugdpr = {}
    DataMgr.fp_token = 0
    DataMgr.gen_ticket = 0
    DataMgr.corps_money = 999999
    DataMgr.Recharge = 1
    DataMgr.wxsubscribe = 0
    DataMgr.qqsubscribe = 0
    DataMgr.anchor = 0
    DataMgr.fresher_type = 0
    DataMgr.modify_name_time = 0
    DataMgr.last_modify_nation_time = 0
    DataMgr.last_modify_nation_item_time = 0
    DataMgr.registertime = 0
    DataMgr.krjp_del_account_left_time = 0
    DataMgr.avatarData.headid = BP_CreateRole_HeadId
    DataMgr.avatarData.gamegender = BP_CreateRole_Sex
    DataMgr.avatarData.hairid = BP_CreateRole_HairID
    DataMgr.avatarData.avatar_list = {}
    DataMgr.avatarData.activate_avatar_list = {}
    DataMgr.rolewear_array = {{1}}
    DataMgr.rolewear_state = {}
    DataMgr.use_rolewear = 1
    DataMgr.parachute = ""
    DataMgr.planeSkinInsID = ""
    DataMgr.equipmentSkinInsIDTable = {}
    DataMgr.head_show = 0
    DataMgr.bag_level = 1
    DataMgr.helmet_level = 1
    DataMgr.double_card = {}
    DataMgr.SeasonInfo = {}
    DataMgrInit = true

    if _G.writeLog then _G.writeLog("EventEnterLobby: saving account to local_account.lua") end
    pcall(function() LocalAccountSystem.Save() end)
    if _G.writeLog then _G.writeLog("EventEnterLobby: loading saved account and entering lobby") end
    local saved = LocalAccountSystem.Load()
    if saved and saved.name and saved.name ~= "" then
        LocalAccountSystem.EnterLobby(saved)
    else
        if _G.writeLog then _G.writeLog("EventEnterLobby: FAILED to load saved account") end
    end
end

--点物品或金币TIPS
function  EventCreateRoleShowItemTips()
    CommonItemTipsUI:ShowPanel(CreateRoleUI.cardID, { x = 460,y = 500})
end

function  EventCreateRoleHideItemTips()
    CommonItemTipsUI:ClosePanel();
end

--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
    
end
function EventSetInfo_Push()
    
end

function bp_createrole_OnModeSwitched(gamestatus)
    log("bp_createrole_OnModeSwitched gamestatus = " .. gamestatus);
    status = string.lower(gamestatus);
    if status == "createrole" then
        LoadingUI.RefreshLoadPercent(1)
        --显示UI
        PopUpNoticeUI:Init();
        CreateRoleUI:Init();

        -- -1: refuse, 0: tips, 1: normal
        if (HasShowDeviceLimit == false) then
            LobbySystem.CheckDeviceTip();
        end
    else
        BP_CreateRole_LobbyToAvatar = 0;
        if CreateRoleUI.isShowing then
            log("close createroleui")
			CreateRoleUI.ClosePanel()
            CreateRoleUI.isShowing = false;
            EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, SceneType.AvatarReset)
            EventLeaveWardrobe()
        end
        BP_CreateRole_Name = CreateRoleUI.platformName;
        CreateRoleUI.createRoleNameInit = false;
    end
end



-- 打开语言设置
function EventEnterLanguageSetting()
    log("enter language setting ui");
    SettingLanguageUI.ShowUIInLoginPanel();
    Client.BuglyLog(NetInterface, 4, "Login", "EnterLang");
end

function EventCreateRolePanelLogOut()
    local function LogOut()
        log("...log out from createRolePanel...");
        
        LoginSystem.sendLogout();
    end

    CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "102012").TextValue, Client.GetTableData("LocalizeRes", "111019").TextValue, LogOut);
end

function CreateRoleUI.RoleInfoJump()
    BP_CreateRole_LobbyToAvatar = 1;
    CreateRoleUI.isShowing = true;
    
    log("CreateRoleUI.RoleInfoJump");
    LuaClassObj.HandleDynamicCreation(bp_createrole);
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
    LobbySystem.SendDefaultWearInfoReq();
    CreateRoleUI:DataMgrToAvatarData();
    LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni");
    LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraFarImmediate");
end

_G.GatherAvatarBuyInfos = GatherAvatarBuyInfos

return CreateRoleUI