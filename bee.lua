-- FISH IT AUTO FARM HUB - EDUKASI (Oktober 2025) - DELTA COMPATIBLE V3 BASIC UI
-- UI: Very Basic (Buttons Only) - Loads Directly with Features Visible
-- All features appear on load in a simple UI frame
-- Safeguards for nil values, no complex drag/slider

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === REMOTES (with checks) ===
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local FishRemote = Remotes and Remotes:FindFirstChild("Fish")
local SellRemote = Remotes and Remotes:FindFirstChild("SellFish")
local CastRemote = Remotes and Remotes:FindFirstChild("CastRod")

if not (FishRemote and SellRemote and CastRemote) then
    warn("Remotes not found! Some features may not work.")
end

-- === CONFIG ===
local Config = {
    AutoFish = false,
    AutoSell = false,
    AutoPerfect = false,
    InfiniteBait = false,
    SpeedHack = false,
    ESP = false,
    Speed = 100,
    SellInterval = 30
}

-- === CHARACTER HANDLER ===
local Character, Humanoid, RootPart
local function SetupCharacter(newChar)
    Character = newChar or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
end
SetupCharacter()
LocalPlayer.CharacterAdded:Connect(SetupCharacter)

-- === MAIN FUNCTIONS ===

-- Auto Perfect Cast
spawn(function()
    while true do
        wait(0.05)
        if Config.AutoPerfect and CastRemote and PlayerGui:FindFirstChild("FishingGui") then
            local gui = PlayerGui.FishingGui
            local perfectBar = gui:FindFirstChild("PerfectBar")
            if perfectBar then
                local fill = perfectBar:FindFirstChild("Fill")
                if fill and fill.Size.X.Scale >= 0.45 and fill.Size.X.Scale <= 0.55 then
                    CastRemote:FireServer("Perfect")
                end
            end
        end
    end
end)

-- Auto Fish
spawn(function()
    while true do
        wait(0.3)
        if Config.AutoFish and FishRemote then
            FishRemote:FireServer()
        end
    end
end)

-- Auto Sell
spawn(function()
    while true do
        if Config.AutoSell and SellRemote then
            SellRemote:FireServer()
        end
        wait(Config.SellInterval)
    end
end)

-- Infinite Bait
spawn(function()
    while true do
        wait(0.5)
        if Config.InfiniteBait then
            local bait = LocalPlayer:FindFirstChild("Bait")
            if bait and bait.Value < 100 then
                bait.Value = 9999
            end
        end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if Humanoid then
        Humanoid.WalkSpeed = Config.SpeedHack and Config.Speed or 16
    end
end)

-- ESP (Simplified)
local ESPInstances = {}
RunService.RenderStepped:Connect(function()
    if not Config.ESP then
        for _, inst in pairs(ESPInstances) do
            if inst then inst:Destroy() end
        end
        ESPInstances = {}
        return
    end

    local fishes = Workspace:FindFirstChild("Fishes")
    if not fishes then return end

    for _, fish in pairs(fishes:GetChildren()) do
        if not fish:FindFirstChild("ESP") then
            local billboard = Instance.new("BillboardGui", fish)
            billboard.Name = "ESP"
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true

            local text = Instance.new("TextLabel", billboard)
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = fish.Name .. " [Rarity: ?]"
            text.TextColor3 = Color3.fromRGB(255, 0, 0)
            text.TextStrokeTransparency = 0
            text.Font = Enum.Font.SourceSansBold

            table.insert(ESPInstances, billboard)
        end
    end
end)

-- Teleport (Basic, no Tween)
local function TeleportTo(spotName)
    local spots = Workspace:FindFirstChild("FishingSpots")
    if spots and RootPart then
        local spot = spots:FindFirstChild(spotName or "DeepSea")
        if spot then
            RootPart.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

-- === BASIC UI (Simple Frame with Buttons - Loads Directly) ===
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Function to Create Toggle Button
local function CreateToggleButton(text, configKey)
    local Button = Instance.new("TextButton", MainFrame)
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = text .. ": OFF"
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 18

    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        Config[configKey] = enabled
        Button.Text = text .. ": " .. (enabled and "ON" or "OFF")
        Button.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
end

-- Function to Create Action Button
local function CreateActionButton(text, callback)
    local Button = Instance.new("TextButton", MainFrame)
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    Button.Text = text
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 18
    Button.MouseButton1Click:Connect(callback)
end

-- Add All Features to UI (Muncul Langsung Saat Load)
CreateToggleButton("Auto Fish", "AutoFish")
CreateToggleButton("Auto Perfect Cast", "AutoPerfect")
CreateToggleButton("Auto Sell", "AutoSell")
CreateToggleButton("Infinite Bait", "InfiniteBait")
CreateToggleButton("Speed Hack", "SpeedHack")
CreateToggleButton("ESP", "ESP")
CreateActionButton("Teleport to Deep Sea", function() TeleportTo("DeepSea") end)
CreateActionButton("Set Speed to 100", function() Config.Speed = 100 end)
CreateActionButton("Set Sell Interval to 30s", function() Config.SellInterval = 30 end)
CreateActionButton("Close UI", function() ScreenGui:Destroy() end)

print("Fish It Hub V3 Basic UI Loaded! All features visible on screen.")
