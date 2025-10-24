-- FISH IT AUTO FARM HUB - EDUKASI (Oktober 2025) - DELTA COMPATIBLE V2
-- UI: Custom Modern (No External Lib) - 100% Work on Delta Executor
-- Fix: Tambah safeguards untuk nil references, improved ESP check, auto-respawn full handle
-- Fitur: Auto Fish, Auto Sell, Perfect Cast, Infinite Bait, ESP, Speed, Teleport

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === REMOTES (dengan check jika ada) ===
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local FishRemote = Remotes and Remotes:FindFirstChild("Fish")
local SellRemote = Remotes and Remotes:FindFirstChild("SellFish")
local CastRemote = Remotes and Remotes:FindFirstChild("CastRod")

if not (FishRemote and SellRemote and CastRemote) then
    warn("Remotes tidak ditemukan! Script mungkin tidak berfungsi penuh.")
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

-- === FUNGSI UTAMA ===

-- Auto Perfect Cast
spawn(function()
    while true do
        wait(0.05)
        if Config.AutoPerfect and CastRemote and LocalPlayer.PlayerGui:FindFirstChild("FishingGui") then
            local gui = LocalPlayer.PlayerGui.FishingGui
            if gui:FindFirstChild("PerfectBar") then
                local bar = gui.PerfectBar.Fill
                if bar.Size.X.Scale >= 0.45 and bar.Size.X.Scale <= 0.55 then
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
            if bait and bait:IsA("IntValue") and bait.Value < 100 then
                bait.Value = 9999
            end
        end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if Humanoid then
        if Config.SpeedHack then
            Humanoid.WalkSpeed = Config.Speed
        else
            Humanoid.WalkSpeed = 16
        end
    end
end)

-- ESP
local ESPBoxes = {}
RunService.RenderStepped:Connect(function()
    if not Config.ESP then
        for _, items in pairs(ESPBoxes) do
            if items.box then items.box:Destroy() end
            if items.label then items.label:Destroy() end
        end
        ESPBoxes = {}
        return
    end

    local fishesFolder = Workspace:FindFirstChild("Fishes")
    if not fishesFolder then return end

    for _, fish in pairs(fishesFolder:GetChildren()) do
        if fish:IsA("Model") and fish:FindFirstChild("PrimaryPart") and not ESPBoxes[fish] then
            local primary = fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")
            if not primary then continue end

            local box = Instance.new("BoxHandleAdornment")
            box.Size = fish:GetExtentsSize() + Vector3.new(1,1,1)
            box.Adornee = primary
            box.Color3 = Color3.fromRGB(0, 255, 0)
            box.Transparency = 0.7
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Parent = primary

            local label = Instance.new("BillboardGui")
            label.Adornee = primary
            label.Size = UDim2.new(0, 200, 0, 50)
            label.StudsOffset = Vector3.new(0, 3, 0)
            label.AlwaysOnTop = true
            label.Parent = primary

            local text = Instance.new("TextLabel", label)
            text.Size = UDim2.new(1,0,1,0)
            text.BackgroundTransparency = 1
            text.Text = fish.Name .. " [" .. (fish:FindFirstChild("Rarity") and fish.Rarity.Value or "?") .. "]"
            text.TextColor3 = Color3.fromRGB(0, 255, 0)
            text.TextStrokeTransparency = 0
            text.Font = Enum.Font.GothamBold
            text.TextSize = 16

            ESPBoxes[fish] = {box = box, label = label}
        end
    end
end)

-- Teleport dengan Tween jika memungkinkan
local function TeleportTo(spotName)
    local fishingSpots = Workspace:FindFirstChild("FishingSpots")
    if not (fishingSpots and RootPart) then return end

    local spot = fishingSpots:FindFirstChild(spotName or "DeepSea")
    if spot then
        local target = spot.CFrame + Vector3.new(0, 5, 0)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(RootPart, tweenInfo, {CFrame = target})
        tween:Play()
    end
end

-- === CUSTOM MODERN UI (NO EXTERNAL LIB) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 500)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Fish It Hub - Delta Edition V2"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
local closeCorner = Instance.new("UICorner", CloseBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollingDirection = Enum.ScrollingDirection.Y
Content.ScrollBarThickness = 5
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Content
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- === UI ELEMENTS ===
local function CreateToggle(name, text, callback)
    local Toggle = Instance.new("Frame")
    local Label = Instance.new("TextLabel")
    local Btn = Instance.new("TextButton")
    local Corner = Instance.new("UICorner")

    Toggle.Size = UDim2.new(1, 0, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Toggle.Parent = Content

    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Toggle

    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Parent = Toggle

    Btn.Size = UDim2.new(0, 50, 0, 25)
    Btn.Position = UDim2.new(1, -65, 0.5, -12.5)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Toggle
    local btnCorner = Instance.new("UICorner", Btn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Btn.Text = enabled and "ON" or "OFF"
        Btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        callback(enabled)
    end)

    return Toggle
end

local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Content
    local corner = Instance.new("UICorner", Btn)
    corner.CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateSlider(text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    local Label = Instance.new("TextLabel")
    local SliderBg = Instance.new("Frame")
    local SliderFill = Instance.new("Frame")
    local ValueLabel = Instance.new("TextLabel")

    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Frame.Parent = Content
    local corner = Instance.new("UICorner", Frame)
    corner.CornerRadius = UDim.new(0, 8)

    Label.Size = UDim2.new(0.6, 0, 0.5, 0)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    SliderBg.Size = UDim2.new(0.9, 0, 0, 8)
    SliderBg.Position = UDim2.new(0.05, 0, 0.6, 0)
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    SliderBg.Parent = Frame
    local bgCorner = Instance.new("UICorner", SliderBg)
    bgCorner.CornerRadius = UDim.new(0, 4)

    SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    SliderFill.Parent = SliderBg
    local fillCorner = Instance.new("UICorner", SliderFill)
    fillCorner.CornerRadius = UDim.new(0, 4)

    ValueLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = Frame

    local dragging = false
    local mouse = LocalPlayer:GetMouse()
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    SliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local percent = math.clamp((mouse.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)

    callback(default)
end

-- === ADD UI ELEMENTS ===
CreateToggle("AutoFish", "Auto Fish", function(v) Config.AutoFish = v end)
CreateToggle("AutoPerfect", "Auto Perfect Cast", function(v) Config.AutoPerfect = v end)
CreateToggle("AutoSell", "Auto Sell", function(v) Config.AutoSell = v end)
CreateSlider("Sell Interval (s)", 10, 120, 30, function(v) Config.SellInterval = v end)
CreateToggle("InfiniteBait", "Infinite Bait", function(v) Config.InfiniteBait = v end)
CreateToggle("SpeedHack", "Speed Hack", function(v) Config.SpeedHack = v end)
CreateSlider("Speed Value", 50, 300, 100, function(v) Config.Speed = v end)
CreateToggle("ESP", "Fish ESP", function(v) Config.ESP = v end)
CreateButton("Teleport to Deep Sea", function() TeleportTo("DeepSea") end)
CreateButton("Close UI", function()
    ScreenGui:Destroy()
    print("Fish It Hub ditutup.")
end)

-- Drag UI
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("Fish It Hub - Delta Edition V2 Loaded! UI Modern & Stabil dengan Safeguards")
