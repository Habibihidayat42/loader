-- INSTANT BITE FISHING v31.1 (CORE FUNCTIONS ONLY)
-- File ini berisi fungsi core tanpa GUI
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local InstantFishing = {}
InstantFishing.__index = InstantFishing

function InstantFishing.new()
    local self = setmetatable({}, InstantFishing)
    
    self.Running = false
    self.WaitingHook = false
    self.TotalFish = 0
    self.Settings = {
        FishingDelay = 0.12,
        CancelDelay = 0.05,
        HookDelay = 0.06,
        ChargeToRequestDelay = 0.05,
        FallbackTimeout = 1.5,
    }
    
    self:InitializeNetReferences()
    self:SetupEventListeners()
    
    return self
end

function InstantFishing:InitializeNetReferences()
    local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

    self.RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
    self.RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
    self.RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
    self.RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
    self.RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
    self.RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")
end

function InstantFishing:Log(msg)
    print("[InstantFishing] " .. msg)
end

function InstantFishing:SetupEventListeners()
    self.RE_MinigameChanged.OnClientEvent:Connect(function(state)
        if not self.Running or not self.WaitingHook then return end
        if typeof(state) ~= "string" then return end

        local s = string.lower(state)
        if s:find("hook") or s:find("bite") then
            self.WaitingHook = false

            task.spawn(function()
                task.wait(self.Settings.HookDelay)
                pcall(function() self.RE_FishingCompleted:FireServer() end)
                self:Log("Hook -> FishingCompleted fired (synced)")

                task.wait(self.Settings.CancelDelay)
                pcall(function() self.RF_CancelFishingInputs:InvokeServer() end)

                task.wait(self.Settings.FishingDelay)
                if self.Running then self:Cast() end
            end)
        end
    end)

    self.RE_FishCaught.OnClientEvent:Connect(function(name, data)
        if not self.Running then return end
        self.WaitingHook = false
        self.TotalFish = self.TotalFish + 1
        local weight = data and data.Weight or 0
        self:Log(("Fish caught: %s (%.2f kg)"):format(tostring(name or "Fish"), weight))

        if self.OnFishCaught then
            self.OnFishCaught(self.TotalFish, name, weight)
        end

        task.spawn(function()
            task.wait(self.Settings.CancelDelay)
            pcall(function() self.RF_CancelFishingInputs:InvokeServer() end)
            task.wait(self.Settings.FishingDelay)
            if self.Running then self:Cast() end
        end)
    end)
end

function InstantFishing:Cast()
    if not self.Running or self.WaitingHook then return end
    self.WaitingHook = true

    task.spawn(function()
        pcall(function() self.RF_CancelFishingInputs:InvokeServer() end)

        pcall(function() self.RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)

        task.wait(self.Settings.ChargeToRequestDelay)

        pcall(function() self.RF_RequestMinigame:InvokeServer(1.95, 0.5, tick()) end)
        self:Log("Cast sent (Charge -> Request)")

        task.delay(self.Settings.FallbackTimeout, function()
            if self.Running and self.WaitingHook then
                self.WaitingHook = false
                self:Log("Fallback timeout — forcing complete")
                pcall(function() self.RE_FishingCompleted:FireServer() end)
                task.wait(self.Settings.CancelDelay)
                pcall(function() self.RF_CancelFishingInputs:InvokeServer() end)
                task.wait(self.Settings.FishingDelay)
                if self.Running then self:Cast() end
            end
        end)
    end)
end

function InstantFishing:Start()
    if self.Running then return end
    self.Running = true
    self.TotalFish = 0
    self:Log("Started")
    
    if self.OnStatusChanged then
        self.OnStatusChanged(true)
    end
    
    self:Cast()
end

function InstantFishing:Stop()
    self.Running = false
    self.WaitingHook = false
    self:Log("Stopped")
    
    if self.OnStatusChanged then
        self.OnStatusChanged(false)
    end
end

function InstantFishing:Toggle()
    if self.Running then
        self:Stop()
    else
        self:Start()
    end
end

function InstantFishing:IsRunning()
    return self.Running
end

function InstantFishing:GetTotalFish()
    return self.TotalFish
end

function InstantFishing:UpdateSettings(settings)
    for key, value in pairs(settings) do
        if self.Settings[key] ~= nil then
            self.Settings[key] = value
        end
    end
end

return InstantFishing
