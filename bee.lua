--// FishIttt.lua UI Version by ZOKADA x GPT
--// Ringan dan kompatibel dengan Delta Executor

--===[ SERVICES ]===--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--===[ CONFIG ]===--
local CONFIG = {
    AutoFish = true,
    AutoReel = true,
    FishTimeout = 10,
    AutoCastDelay = 1,
    CastKey = Enum.KeyCode.F,
    ReelKey = Enum.KeyCode.G
}

local state = {
    isFishing = false,
    currentFish = nil,
    lastCastTime = 0,
}

--===[ UI BUATAN SENDIRI TANPA LIBRARY ]===--

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "FishItUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 220)
main.Position = UDim2.new(0.5, -140, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Text = "🎣 FishIt Hub by ZOKADA"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.Parent = main

-- Function to create toggle buttons
local function createToggle(name, default, posY, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = default and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(120, 40, 40)
    button.Text = name .. ": " .. (default and "ON" or "OFF")
    button.Font = Enum.Font.Gotham
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Parent = main

    button.MouseButton1Click:Connect(function()
        default = not default
        button.BackgroundColor3 = default and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(120, 40, 40)
        button.Text = name .. ": " .. (default and "ON" or "OFF")
        callback(default)
    end)
end

-- Function to create sliders (for delays)
local function createSlider(name, min, max, default, posY, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.Text = name .. ": " .. default
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Parent = main

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 10)
    sliderFrame.Position = UDim2.new(0, 10, 0, posY + 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = main

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame

    local dragging = false

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relX)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

--===[ UI ELEMENTS ]===--
createToggle("Auto Fish", CONFIG.AutoFish, 40, function(val) CONFIG.AutoFish = val end)
createToggle("Auto Reel", CONFIG.AutoReel, 80, function(val) CONFIG.AutoReel = val end)
createSlider("Fish Timeout", 2, 15, CONFIG.FishTimeout, 120, function(val) CONFIG.FishTimeout = val end)
createSlider("Auto Cast Delay", 0, 5, CONFIG.AutoCastDelay, 170, function(val) CONFIG.AutoCastDelay = val end)

--===[ CORE LOGIC ]===--
local function getFishingRod()
    return character:FindFirstChild("FishingRod")
end

local function castRod()
    local rod = getFishingRod()
    if rod then
        rod:Activate()
        state.isFishing = true
        state.lastCastTime = tick()
        print("🎣 CASTED!")
    end
end

local function reelIn()
    local rod = getFishingRod()
    if rod then
        rod:Destroy()
        state.isFishing = false
        print("💰 REELED & SOLD!")
    end
end

local function checkForFish()
    local rod = getFishingRod()
    if rod and rod:FindFirstChild("Fish") then
        state.currentFish = rod.Fish
        return true
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        if CONFIG.AutoFish and not state.isFishing then
            if tick() - state.lastCastTime > CONFIG.AutoCastDelay then
                castRod()
            end
        end
        if state.isFishing and checkForFish() then
            if CONFIG.AutoReel then
                task.wait(CONFIG.FishTimeout)
                reelIn()
            end
        end
    end
end)

print("✅ FishIt Hub UI Loaded!")
