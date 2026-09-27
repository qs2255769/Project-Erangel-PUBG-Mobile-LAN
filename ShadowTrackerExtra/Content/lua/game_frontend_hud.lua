local HUD = {}

local frontendUtils = nil
if slua_GameFrontendHUD then
    frontendUtils = slua_GameFrontendHUD:GetUtils()
end
local gameStatusListener = {}

function HUD.AddToContainer(containerName, widget, zOrder)
    local container = frontendUtils:GetGlobalUIContainer(containerName)
    assert(container ~= nil, string.format("Can't get global ui container [%s]", containerName))
    container:AddWidgetWithZOrder(widget, zOrder)
end

function HUD.RemoveFromContainer(containerName, widget)
    local container = frontendUtils:GetGlobalUIContainer(containerName)
    container:RemoveWidget(widget)
end

function HUD.SetGameStatusListener(func)
    assert(type(func) == "function", "parameter must be function type")
	table.insert(gameStatusListener, func)
end

function HUD._OnGameStatusChange(status)
    if _G._wl then _G._wl("GAMESTATUS_CHANGE: status=" .. tostring(status) .. " mapLoading=" .. tostring(_G._shootingRangeLoading) .. " inCustomBattle=" .. tostring(_G._inCustomBattle)) end

    -- MAP LOADER GUARD: When loading a custom map via GameplayStatics.OpenLevel,
    -- the C++ engine fires OnSwitchGameStatusEvent("Lobby") during the map transition.
    -- Redirect "Lobby" to "Fighting" when loading a custom map.
    if _G._shootingRangeLoading and status == "Lobby" then
        if _G._wl then _G._wl("game_frontend_hud: REDIRECT Lobby->Fighting during custom map load") end
        -- CRITICAL: Re-register ingame's SubUIWidgetList with "Lobby" added to statuses.
        -- C++ game status is "Lobby" and we cannot change it (SetGameStatus doesn't exist).
        -- By adding "Lobby" to the status list, InGameUIManager will keep the battle HUD
        -- visible even though C++ thinks we're in Lobby mode.
        pcall(function()
            if ingame and InGameUIManager and InGameUIManager.SubUIWidgetList then
                InGameUIManager.SubUIWidgetList(ingame,
                    {
                        {Path="/Game/BluePrints/ControlInput/MainControlPanelTochButton.MainControlPanelTochButton_C", Container="Default", ZOrder=0},
                    },
                    {"Lobby", "Fighting", "Training"},
                    false,
                    true,
                    false
                )
                if _G._wl then _G._wl("game_frontend_hud: re-registered ingame for Lobby status") end
            end
        end)
        status = "Fighting"
        -- Map has loaded — the NEW ingame instance is now available.
        -- Reset HUD flags so TrySetFightingHUD retries with the new ingame.
        _G._fightingBattleUIShown = false
        _G._fightingModeSwitchFired = false
    end

    if next(gameStatusListener) ~=nil then
		for key, func in pairs(gameStatusListener) do
            local ok, err = pcall(func, status)
            if not ok and _G._wl then
                _G._wl("game_frontend_hud: LISTENER CRASH status=" .. tostring(status) .. " err=" .. tostring(err))
            end
		end
    end
end

if slua_GameFrontendHUD then
    slua_GameFrontendHUD.OnSwitchGameStatusEvent:Add(HUD._OnGameStatusChange)
end

return HUD
