-- Fish It Script by Grok (Mirip Chiyo/Seraphin) - October 2025
-- Library: OrionLib (Auto-load jika belum ada)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variables Global
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local autoFishEnabled = false
local autoSellEnabled = false
local autoEquipEnabled = false
local autoFarmEnabled = false
local autoBuyEnabled = false
local autoOpenCratesEnabled = false
local autoEnchantEnabled = false
local teleportEnabled = false
local speedBoost = 16
local jumpBoost = 50
local antiAFK = false
local farmThreshold = 10000  -- Coins threshold
local sellInterval = 60  -- Detik

-- Functions Utama
local function fireRemote(remoteName, args)
    if ReplicatedStorage:FindFirstChild(remoteName) then
        ReplicatedStorage[remoteName]:FireServer(unpack(args or {}))
    end
end

-- Auto Fishing Function
local function autoFish()
    spawn(function()
        while autoFishEnabled do
            wait(0.1)
            -- Charge rod (simulasi click)
            fireRemote("ChargeRod", {})
            wait(2)  -- Wait for cast
            fireRemote("CastLine", {})
            wait(3)  -- Wait for bite
            fireRemote("StartMinigame", {})  -- Blatant mode: instant win
            fireRemote("CompleteMinigame", {perfect = true})
            fireRemote("ReelIn", {})
        end
    end)
end

-- Auto Sell Function
local function autoSell()
    spawn(function()
        while autoSellEnabled do
            wait(sellInterval)
            fireRemote("SellInventory", {})
        end
    end)
end

-- Auto Equip Best Rod/Bobber
local function autoEquip()
    spawn(function()
        while autoEquipEnabled do
            wait(5)
            -- Logic sederhana: Equip item dengan value tertinggi (asumsi remote ada)
            local bestRod = "BestRod"  -- Ganti dengan logic scan inventory
            fireRemote("EquipItem", {bestRod})
        end
    end)
end

-- Auto Farm Coins/Enchant Stones
local function autoFarm()
    spawn(function()
        while autoFarmEnabled do
            wait(1)
            local coins = LocalPlayer.leaderstats.Coins.Value  -- Asumsi leaderstats
            if coins < farmThreshold then
                autoFish()  -- Jalankan fishing untuk farm
            else
                print("Threshold reached!")
                autoFarmEnabled = false
            end
        end
    end)
end

-- Auto Buy Best Items
local function autoBuy()
    spawn(function()
        while autoBuyEnabled do
            wait(10)
            fireRemote("BuyItem", {"BestRod"})  -- Beli rod/bobber/weather
            fireRemote("BuyWeather", {"Storm"})  -- Contoh weather
        end
    end)
end

-- Auto Open Crates
local function autoOpenCrates(crateType)
    spawn(function()
        while autoOpenCratesEnabled do
            wait(1)
            fireRemote("OpenCrate", {crateType})
        end
    end)
end

-- Auto Enchant Rod
local function autoEnchant(rodName, desiredEnchant)
    spawn(function()
        while autoEnchantEnabled do
            wait(2)
            fireRemote("UseEnchantStone", {rodName})
            -- Check if enchanted (simulasi)
            if math.random(1,10) == 1 then  -- 10% chance success
                print("Enchant success!")
                autoEnchantEnabled = false
            end
        end
    end)
end

-- Teleport Function
local function teleportTo(position)
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
end

local teleports = {
    KohanaIsland = Vector3.new(0, 10, 0),  -- Koordinat contoh, sesuaikan
    CoralReefs = Vector3.new(100, 10, 100),
    -- Tambah lebih banyak
}

-- Anti-AFK
local function antiAFKLoop()
    spawn(function()
        while antiAFK do
            wait(60)
            fireRemote("AntiAFK", {})  -- Asumsi remote
            LocalPlayer.Character.Humanoid:Move(Vector3.new(0,0,0.1))
        end
    end)
end

-- Speed/Jump Boost
local function applyBoosts()
    LocalPlayer.Character.Humanoid.WalkSpeed = speedBoost
    LocalPlayer.Character.Humanoid.JumpPower = jumpBoost
end

-- FPS Booster (Hapus efek particle dll)
local function fpsBoost()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Explosion") then
            v.Enabled = false
        end
    end
end

-- GUI Creation
local Window = OrionLib:MakeWindow({
    Name = "Fish It Hub by Grok (Mirip Chiyo/Seraphin)",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FishItHub"
})

-- Tab 1: Auto Farm
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FarmTab:AddToggle("Auto Fish", ToggleInfo, function(state)
    autoFishEnabled = state
    if state then autoFish() end
end)

FarmTab:AddToggle("Auto Sell", ToggleInfo, function(state)
    autoSellEnabled = state
    if state then autoSell() end
end)

FarmTab:AddSlider("Sell Interval (sec)", SliderInfo, function(value)
    sellInterval = value
end, 1, 300, 60)

FarmTab:AddToggle("Auto Equip", ToggleInfo, function(state)
    autoEquipEnabled = state
    if state then autoEquip() end
end)

FarmTab:AddToggle("Auto Farm (to Threshold)", ToggleInfo, function(state)
    autoFarmEnabled = state
    if state then autoFarm() end
end)

FarmTab:AddSlider("Farm Threshold (Coins)", SliderInfo, function(value)
    farmThreshold = value
end, 1000, 1000000, 10000)

-- Tab 2: Auto Buy & Enchant
local BuyTab = Window:MakeTab({
    Name = "Auto Buy & Enchant",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

BuyTab:AddToggle("Auto Buy Best", ToggleInfo, function(state)
    autoBuyEnabled = state
    if state then autoBuy() end
end)

BuyTab:AddToggle("Auto Open Crates", ToggleInfo, function(state)
    autoOpenCratesEnabled = state
    if state then autoOpenCrates("Common") end  -- Ganti type
end)

local enchantRod = BuyTab:AddTextbox("Rod Name for Enchant")
local desiredEnc = BuyTab:AddTextbox("Desired Enchant")

BuyTab:AddButton("Start Auto Enchant", function()
    local rod = enchantRod.Value
    local enc = desiredEnc.Value
    autoEnchantEnabled = true
    autoEnchant(rod, enc)
end)

-- Tab 3: Teleports & Misc
local TeleTab = Window:MakeTab({
    Name = "Teleports & Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleTab:AddDropdown("Select Island", DropdownInfo, {"KohanaIsland", "CoralReefs"}, function(selected)
    teleportTo(teleports[selected])
end)

TeleTab:AddToggle("Speed Boost", ToggleInfo, function(state)
    if state then applyBoosts() else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

TeleTab:AddSlider("Walk Speed", SliderInfo, function(value)
    speedBoost = value
    applyBoosts()
end, 16, 100, 16)

TeleTab:AddToggle("Infinite Jump", ToggleInfo, function(state)
    if state then
        local UserInputService = game:GetService("UserInputService")
        UserInputService.JumpRequest:Connect(function()
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end)
    end
end)

TeleTab:AddToggle("Anti-AFK", ToggleInfo, function(state)
    antiAFK = state
    if state then antiAFKLoop() end
end)

TeleTab:AddButton("FPS Boost", fpsBoost)

-- Init
fpsBoost()  -- Jalankan sekali
OrionLib:Init()
print("Fish It Hub Loaded! Nikmati farming-nya :)")
