-- FISH IT AUTO FARM HUB - EDUKASI (Oktober 2025)
-- Fitur: Auto Fish, Auto Sell, Teleport, Auto Perfect Cast, Infinite Bait, ESP, Speed Hack
-- Versi Ditingkatkan: UI Modern dengan Fluent, Organisasi Lebih Baik, Animasi Tween, dan Validasi Fungsi

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
    SpeedHackEnabled = false,
    Speed = 100,
    SellInterval = 30,
    ESPEnabled = false
}

-- === REMOTE EVENTS (ditemukan via Explorer) ===
local FishRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Fish")
local SellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SellFish")
local CastRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CastRod")

-- === FUNGSI UTAMA ===

-- 1. Auto Perfect Cast dengan Monitoring Lebih Akurat
local function AutoPerfectCast()
    if not Config.AutoPerfect then return end
    spawn(function()
        while Config.AutoPerfect do
            if LocalPlayer:FindFirstChild("PlayerGui") then
                local gui = LocalPlayer.PlayerGui:FindFirstChild("FishingGui")
                if gui and gui:FindFirstChild("PerfectBar") then
                    local bar = gui.PerfectBar.Fill
                    -- Improved range for better accuracy
                    if bar.Size.X.Scale >= 0.45 and bar.Size.X.Scale <= 0.55 then
                        CastRemote:FireServer("Perfect")
                    end
                end
            end
            wait(0.05) -- Reduced wait for faster response
        end
    end)
end

-- 2. Auto Fish (Catch Fish Otomatis) dengan Delay Adaptif
local function AutoFish()
    if not Config.AutoFish then return end
    spawn(function()
        while Config.AutoFish do
            FishRemote:FireServer()
            wait(0.3) -- Adjusted for better performance without spamming
        end
    end)
end

-- 3. Auto Sell (Jual Ikan Otomatis) dengan Interval Dinamis
local function AutoSell()
    if not Config.AutoSell then return end
    spawn(function()
        while Config.AutoSell do
            SellRemote:FireServer()
            wait(Config.SellInterval)
        end
    end)
end

-- 4. Infinite Bait (Bait Tidak Habis) dengan Check Lebih Efisien
local function InfiniteBait()
    if not Config.InfiniteBait then return end
    spawn(function()
        while Config.InfiniteBait do
            local bait = LocalPlayer:FindFirstChild("Bait")
            if bait and bait.Value < 100 then -- Increased threshold for realism
                bait.Value = 9999
            end
            wait(0.5)
        end
    end)
end

-- 5. Teleport ke Spot Terbaik dengan Tween Animasi (Smooth Teleport)
local function TeleportToSpot(spotName)
    local spot = Workspace:FindFirstChild("FishingSpots"):FindFirstChild(spotName or "DeepSea")
    if spot then
        local targetCFrame = spot.CFrame + Vector3.new(0, 5, 0)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(RootPart, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- 6. Speed Hack dengan Smooth Transition
local function ApplySpeedHack()
    if Config.SpeedHackEnabled then
        if Humanoid.WalkSpeed ~= Config.Speed then
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
            TweenService:Create(Humanoid, tweenInfo, {WalkSpeed = Config.Speed}):Play()
        end
    else
        if Humanoid.WalkSpeed ~= 16 then
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
            TweenService:Create(Humanoid, tweenInfo, {WalkSpeed = 16}):Play()
        end
    end
end

-- 7. ESP (Lihat Ikan dari Jauh) dengan Update Dinamis dan Warna Berdasarkan Rarity
local ESPInstances = {}
local function CreateESP()
    if not Config.ESPEnabled then
        for _, esp in pairs(ESPInstances) do
            if esp then esp:Destroy() end
        end
        ESPInstances = {}
        return
    end
    
    for _, fish in pairs(Workspace.Fishes:GetChildren()) do
        if not fish:FindFirstChild("ESP") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP"
            billboard.Adornee = fish
            billboard.Size = UDim2.new(0, 150, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = fish

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = fish.Name .. " [" .. (fish.Rarity.Value or "Common") .. "]"
            text.TextStrokeTransparency = 0.5
            text.Font = Enum.Font.GothamBold
            text.TextSize = 14

            -- Warna berdasarkan rarity (contoh sederhana)
            local rarity = fish.Rarity.Value or "Common"
            if rarity == "Rare" then
                text.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif rarity == "Epic" then
                text.TextColor3 = Color3.fromRGB(255, 0, 255)
            else
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            text.Parent = billboard
            table.insert(ESPInstances, billboard)
        end
    end
end

-- === UI MODERN dengan Fluent (Ditambahkan Tab, Dropdown, Color Picker jika perlu) ===
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fish It Hub - Edukasi (V2 Modern UI)",
    SubTitle = "by Habibihidayat42",
    TabWidth = 120,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true, -- Efek blur modern
    Theme = "Dark" -- Tema modern dark mode
})

-- Tab Utama: Farming
local FarmTab = Window:AddTab({ Title = "Farming", Icon = "fish" })

FarmTab:AddToggle("AutoFish", {
    Title = "Auto Fish",
    Description = "Otomatis menangkap ikan",
    Default = false,
    Callback = function(value)
        Config.AutoFish = value
        if value then AutoFish() end
    end
})

FarmTab:AddToggle("AutoPerfect", {
    Title = "Auto Perfect Cast",
    Description = "Timing sempurna otomatis",
    Default = false,
    Callback = function(value)
        Config.AutoPerfect = value
        if value then AutoPerfectCast() end
    end
})

FarmTab:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Description = "Jual ikan otomatis",
    Default = false,
    Callback = function(value)
        Config.AutoSell = value
        if value then AutoSell() end
    end
})

FarmTab:AddSlider("SellInterval", {
    Title = "Sell Interval (detik)",
    Description = "Interval jual ikan",
    Min = 10,
    Max = 120,
    Default = 30,
    Rounding = 1,
    Callback = function(value)
        Config.SellInterval = value
    end
})

FarmTab:AddToggle("InfiniteBait", {
    Title = "Infinite Bait",
    Description = "Umpan tak terbatas",
    Default = false,
    Callback = function(value)
        Config.InfiniteBait = value
        if value then InfiniteBait() end
    end
})

-- Tab Movement
local MoveTab = Window:AddTab({ Title = "Movement", Icon = "running" })

MoveTab:AddToggle("SpeedHack", {
    Title = "Speed Hack",
    Description = "Kecepatan bergerak lebih cepat",
    Default = false,
    Callback = function(value)
        Config.SpeedHackEnabled = value
        ApplySpeedHack()
    end
})

MoveTab:AddSlider("Speed", {
    Title = "Speed Value",
    Description = "Atur kecepatan (default 100)",
    Min = 50,
    Max = 500,
    Default = 100,
    Rounding = 1,
    Callback = function(value)
        Config.Speed = value
        if Config.SpeedHackEnabled then ApplySpeedHack() end
    end
})

MoveTab:AddDropdown("TeleportSpot", {
    Title = "Teleport to Spot",
    Values = {"DeepSea", "River", "Lake"}, -- Tambahkan spot lain jika ada
    Default = 1,
    Multi = false,
    Callback = function(value)
        TeleportToSpot(value)
    end
})

MoveTab:AddButton({
    Title = "Teleport Now",
    Description = "Teleport ke spot terbaik",
    Callback = function()
        TeleportToSpot()
    end
})

-- Tab Visuals
local VisualTab = Window:AddTab({ Title = "Visuals", Icon = "eye" })

VisualTab:AddToggle("ESP", {
    Title = "Fish ESP",
    Description = "Tampilkan info ikan dari jauh",
    Default = false,
    Callback = function(value)
        Config.ESPEnabled = value
        CreateESP()
    end
})

-- Tab Settings (Tambahan untuk Modern Feel)
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

SettingsTab:AddButton({
    Title = "Unload Script",
    Description = "Hentikan semua fungsi",
    Callback = function()
        for key, _ in pairs(Config) do
            Config[key] = false
        end
        Humanoid.WalkSpeed = 16
        CreateESP() -- Clear ESP
        Window:Destroy()
    end
})

-- === LOOP UTAMA dengan RunService untuk Efisiensi ===
RunService.Heartbeat:Connect(function()
    CreateESP()
    ApplySpeedHack()
end)

-- Notifikasi Awal
Fluent:Notify({
    Title = "Fish It Hub Loaded",
    Content = "Enjoy fishing with modern UI! 🎣",
    Duration = 5
})

print("Fish It Hub V2 loaded! Modern UI active.")
