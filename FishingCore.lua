-- ⚡ INSTANT BITE FISHING CORE v32.0 (NORMAL SYNC MODE)
-- File ini berisi logika fishing tanpa GUI
-- GUI harus menggunakan fungsi-fungsi yang di-expose dari module ini

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

if _G.FishingCore then
    _G.FishingCore.Stop()
    task.wait(0.1)
end

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

local FishingCore = {
    Running = false,
    WaitingHook = false,
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.12,
        CancelDelay = 0.05,
        HookDelay = 0.06,
        ChargeToRequestDelay = 0.05,
        FallbackTimeout = 1.5,
    },
    OnStatusChanged = nil,
    OnFishCaught = nil,
}

_G.FishingCore = FishingCore

local function log(msg)
    print("[FishingCore] " .. msg)
end

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not FishingCore.Running or not FishingCore.WaitingHook then return end
    if typeof(state) ~= "string" then return end

    local s = string.lower(state)
    if s:find("hook") or s:find("bite") then
        FishingCore.WaitingHook = false

        task.spawn(function()
            task.wait(FishingCore.Settings.HookDelay)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("⚡ Hook -> FishingCompleted fired (synced)")

            task.wait(FishingCore.Settings.CancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)

            task.wait(FishingCore.Settings.FishingDelay)
            if FishingCore.Running then FishingCore.Cast() end
        end)
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not FishingCore.Running then return end
    FishingCore.WaitingHook = false
    FishingCore.TotalFish = FishingCore.TotalFish + 1
    local weight = data and data.Weight or 0
    log(("🐟 Fish caught: %s (%.2f kg)"):format(tostring(name or "Fish"), weight))

    if FishingCore.OnFishCaught then
        FishingCore.OnFishCaught(FishingCore.TotalFish, name, weight)
    end

    task.spawn(function()
        task.wait(FishingCore.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(FishingCore.Settings.FishingDelay)
        if FishingCore.Running then FishingCore.Cast() end
    end)
end)

function FishingCore.Cast()
    if not FishingCore.Running or FishingCore.WaitingHook then return end
    FishingCore.WaitingHook = true

    task.spawn(function()
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)

        pcall(function() RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)

        task.wait(FishingCore.Settings.ChargeToRequestDelay)

        pcall(function() RF_RequestMinigame:InvokeServer(1.95, 0.5, tick()) end)
        log("🎯 Cast sent (Charge -> Request)")

        task.delay(FishingCore.Settings.FallbackTimeout, function()
            if FishingCore.Running and FishingCore.WaitingHook then
                FishingCore.WaitingHook = false
                log("⏱️ Fallback timeout — forcing complete")
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(FishingCore.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(FishingCore.Settings.FishingDelay)
                if FishingCore.Running then FishingCore.Cast() end
            end
        end)
    end)
end

function FishingCore.Start()
    if FishingCore.Running then return end
    FishingCore.Running = true
    FishingCore.TotalFish = 0
    
    if FishingCore.OnStatusChanged then
        FishingCore.OnStatusChanged(true, 0)
    end
    
    log("🚀 Normal Sync mode started")
    FishingCore.Cast()
end

function FishingCore.Stop()
    FishingCore.Running = false
    FishingCore.WaitingHook = false
    
    if FishingCore.OnStatusChanged then
        FishingCore.OnStatusChanged(false, FishingCore.TotalFish)
    end
    
    log("🛑 Stopped")
end

function FishingCore.Toggle()
    if FishingCore.Running then 
        FishingCore.Stop() 
    else 
        FishingCore.Start() 
    end
end

function FishingCore.GetStatus()
    return {
        Running = FishingCore.Running,
        TotalFish = FishingCore.TotalFish,
        WaitingHook = FishingCore.WaitingHook,
    }
end

function FishingCore.UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        if FishingCore.Settings[key] ~= nil then
            FishingCore.Settings[key] = value
            log(("Setting updated: %s = %.2f"):format(key, value))
        end
    end
end

log("✅ FishingCore initialized")
return FishingCore
