-- MapPath.lua
-- Central map list for the lobby fix mod's offline map selection.
-- Add a new entry here and it will automatically appear in the
-- map selection UI and be loadable via Start Match
--
-- Fields per entry:
--   map_id       unique numeric id shown to the UI
--   name         display name in the map selection list
--   path         UE4 package path used by GameplayStatics.OpenLevel
--   mode_team_id optional ModeTeamTable id used for the lobby icon (nil = no icon)
--   mode_id      optional gameplay mode id passed in the travel URL (?ModeId=)
--   game_mode    optional native GameMode override (?game= travel option; nil = map default)
--   mapid        optional Map.lua map id passed in the travel URL (?mapid=), matching the
--                original DS protocol in Server/PacketCallbacks.lua sync_game_param
--   medical      optional starting-bag consumables: { {itemId, count}, ... }
-- GameMode paths below are the authoritative BTMode entries from the game's own
-- ServerLuaCSV/BTMode.lua. Every BR map MUST carry an explicit game_mode: without
-- it the engine uses the map's baked-in default, which for PUBG_Forest is the
-- DESERT GameMode (BP_BattleRoyaleGameMode_Desert_1_C) - wrong zone, no vehicles,
-- broken collision/streaming, spawn-island zone kills.
_G._MAP_LIST = {
    { map_id = 1001, name = "Training",  path = "/Game/Maps/Shooting_Range/shooting_test/shooting_range4",  mode_team_id = nil, mapid = 2, icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/EMode/EMode_AllWeapon" },
    { map_id = 1002, name = "Erangel",   path = "/Game/Maps/PUBG_Forest/PUBG_Forest",                       mode_team_id = 1001, mode_id = 1001, mapid = 1, game_mode = "/Game/BluePrints/Core/Forest/BP_BattleRoyaleGameMode_PUBG.BP_BattleRoyaleGameMode_PUBG_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/IslandMap", medical = { { 601001, 5 }, { 601003, 2 }, { 601004, 3 } } },
    { map_id = 1003, name = "TDM",       path = "/Game/Maps/TD_Factory_Depot/TD_Factory_Depot_Mian",        mode_id = 12021, mode_team_id = 12021, mapid = 22, ai_count = 6, game_mode = "/Game/BluePrints/Core/TeamDeathMatchGameMode/BP_BRGameMode_TeamDeathMatch_TPP.BP_BRGameMode_TeamDeathMatch_TPP_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/TModMap01" },
    { map_id = 1004, name = "Miramar",   path = "/Game/Maps/PUBG_Desert/PUBG_Desert",                       mode_id = 1004, mode_team_id = nil, mapid = 10, game_mode = "/Game/BluePrints/Core/Desert/BP_BattleRoyaleGameMode_Desert_1.BP_BattleRoyaleGameMode_Desert_1_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/DesertMap" },
    { map_id = 1005, name = "Sanhok",    path = "/Game/Maps/PUBG_Savage/PUBG_Savage_Main",                  mode_id = 1082, mode_team_id = nil, mapid = 7, game_mode = "/Game/BluePrints/Core/SanHok/BP_BattleRoyaleGameMode_SanHok_1.BP_BattleRoyaleGameMode_SanHok_1_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/RainforestMap" },
    { map_id = 1006, name = "Vikendi",   path = "/Game/Maps/PUBG_DihorOtok/DihorOtok_Main",                 mode_id = 1107, mode_team_id = nil, mapid = 16, game_mode = "/Game/BluePrints/Core/DihorOtok/BP_BattleRoyaleGameMode_DihorOtok_1.BP_BattleRoyaleGameMode_DihorOtok_1_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/ChristmasMap" },
    { map_id = 12012, name = "Zombie: Survive Till Dawn", path = "/Game/Maps/PUBG_Forest/PUBG_Forest", mode_id = 12012, mode_team_id = 12012, mapid = 20, game_mode = "/Game/BluePrints/Core/ZombieSurvive/BP_ZombieSurviveGameMode_Four.BP_ZombieSurviveGameMode_Four_C", icon_path = "/Game/Arts/UI/HUD/Survive_RcityMap/Survive_RcityMap" },
}

-- Marker used by client_entry.lua logging to confirm where the list was loaded from.
_G._MAP_LIST_loaded_from = "MapPath.lua"

-- Default map used when Start Match has no valid selection.
_G._DEFAULT_MAP_PATH = (_G._MAP_LIST[1] and _G._MAP_LIST[1].path) or "/Game/Maps/Shooting_Range/shooting_test/shooting_range4"
