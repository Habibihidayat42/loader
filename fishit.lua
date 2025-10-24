-- FISH IT AUTO FARM HUB - EDUKASI (Oktober 2025)
-- Fitur: Auto Fish, Auto Sell, Teleport, Auto Perfect Cast, Infinite Bait, ESP

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- === CONFIG ===
local Config = {
    AutoFish = false,
    AutoSell = false,
    AutoPerfect = false,
    InfiniteBait = false,
    TeleportToBestSpot = false,
    Speed = 100,
    SellInterval = 30
}

-- === REMOTE EVENTS (ditemukan via Explorer) ===
local FishRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Fish")
local SellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SellFish")
local CastRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CastRod")

-- === FUNGSI UTAMA ===

-- 1. Auto Cast & Perfect Timing
local function AutoPerfectCast()
    if not Config.AutoPerfect then return end
    spawn(function()
        while Config.AutoPerfect do
            if LocalPlayer:FindFirstChild("PlayerGui") then
                local gui = LocalPlayer.PlayerGui:FindFirstChild("FishingGui")
                if gui and gui:FindFirstChild("PerfectBar") then
                    local bar = gui.PerfectBar.Fill
                    if bar.Size.X.Scale >= 0.45 and bar.Size.X.Scale <= 0.55 then
                        CastRemote:FireServer("Perfect")
                    end
                end
            end
            wait(0.1)
        end
    end)
end

-- 2. Auto Fish (Catch Fish Otomatis)
local function AutoFish()
    if not Config.AutoFish then return end
    spawn(function()
        while Config.AutoFish do
            FishRemote:FireServer()
            wait(0.5)
        end
    end)
end

-- 3. Auto Sell (Jual Ikan Otomatis)
local function AutoSell()
    if not Config.AutoSell then return end
    spawn(function()
        while Config.AutoSell do
            SellRemote:FireServer()
            wait(Config.SellInterval)
        end
    end)
end

-- 4. Infinite Bait (Bait Tidak Habis)
local function InfiniteBait()
    if not Config.InfiniteBait then return end
    spawn(function()
        while Config.InfiniteBait do
            local bait = LocalPlayer:FindFirstChild("Bait")
            if bait and bait.Value < 10 then
                bait.Value = 999
            end
            wait(1)
        end
    end)
end

-- 5. Teleport ke Spot Terbaik (contoh: Deep Sea)
local function TeleportToSpot()
    if not Config.TeleportToBestSpot then return end
    local spot = Workspace:FindFirstChild("FishingSpots"):FindFirstChild("DeepSea")
    if spot then
        RootPart.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
    end
end

-- 6. Speed Hack
local function SpeedHack()
    if Humanoid.WalkSpeed ~= Config.Speed then
        Humanoid.WalkSpeed = Config.Speed
    end
end

-- 7. ESP (Lihat Ikan dari Jauh)
local function CreateESP()
    for _, fish in pairs(Workspace.Fishes:GetChildren()) do
        if not fish:FindFirstChild("ESP") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP"
            billboard.Adornee = fish
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = fish

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = fish.Name .. " [" .. fish.Rarity.Value .. "]"
            text.TextColor3 = Color3.fromRGB(255, 0, 0)
            text.TextStrokeTransparency = 0
            text.Font = Enum.Font.SourceSansBold
            text.Parent = billboard
        end
    end
end

-- === GUI SEDERHANA (menggunakan Fluent atau bisa ganti Synapse X GUI) ===
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fish It Hub - Edukasi",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460)
})

local MainTab = Window:AddTab({ Title = "Main" })

MainTab:AddToggle("AutoFish", {
    Title = "Auto Fish",
    Default = false,
    Callback = function(value)
        Config.AutoFish = value
        if value then AutoFish() end
    end
})

MainTab:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Default = false,
    Callback = function(value)
        Config.AutoSell = value
        if value then AutoSell() end
    end
})

MainTab:AddToggle("AutoPerfect", {
    Title = "Auto Perfect Cast",
    Default = false,
    Callback = function(value)
        Config.AutoPerfect = value
        if value then AutoPerfectCast() end
    end
})

MainTab:AddSlider("SellInterval", {
    Title = "Sell Interval (detik)",
    Min = 10,
    Max = 120,
    Default = 30,
    Callback = function(value)
        Config.SellInterval = value
    end
})

MainTab:AddButton("Teleport to Deep Sea", function()
    Config.TeleportToBestSpot = true
    TeleportToSpot()
    wait(1)
    Config.TeleportToBestSpot = false
end)

MainTab:AddToggle("InfiniteBait", {
    Title = "Infinite Bait",
    Default = false,
    Callback = function(value)
        Config.InfiniteBait = value
        if value then InfiniteBait() end
    end
})

MainTab:AddToggle("SpeedHack", {
    Title = "Speed Hack",
    Default = false,
    Callback = function(value)
        if value then
            Config.Speed = 100
            SpeedHack()
        else
            Humanoid.WalkSpeed = 16
        end
    end
})

-- === LOOP UTAMA ===
spawn(function()
    while true do
        CreateESP()
        SpeedHack()
        wait(1)
    end
end)

print("Fish It Hub loaded! Enjoy fishing! 🎣")
