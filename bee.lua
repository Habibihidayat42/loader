--// FishIt Hub v1.4 by ZOKADA (Fix AutoFish + Default OFF)
--// Stable version for Delta / Arceus X / Codex

--== SERVICES ==--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local gui = Instance.new("ScreenGui")
gui.Name = "FishItHub_UI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

--== CONFIG ==--
local CONFIG = {
    AutoFish = false,    -- DEFAULT: OFF
    AutoReel = false,    -- DEFAULT: OFF
    FishTimeout = 8,
    AutoCastDelay = 1,
}

local state = {
    isFishing = false,
    lastCastTime = 0,
}

--== FIND REMOTE EVENTS ==--
local CastEvent, ReelEvent
for _,v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local n = v.Name:lower()
        if n:find("cast") or n:find("start") then CastEvent = v end
        if n:find("reel") or n:find("catch") or n:find("end") then ReelEvent = v end
    end
end

--== FUNCTIONS ==--
local function equipRod()
    local rod = character:FindFirstChild("FishingRod")
    if not rod then
        local bpRod = player.Backpack:FindFirstChild("FishingRod")
        if bpRod then
            bpRod.Parent = character
            repeat task.wait() until character:FindFirstChild("FishingRod")
            print("[FishIt] Rod equipped automatically!")
            return character:FindFirstChild("FishingRod")
        end
    end
    return rod
end

local function getRod()
    return character:FindFirstChild("FishingRod") or player.Backpack:FindFirstChild("FishingRod")
end

local function castRod()
    local rod = equipRod()
    if not rod then
        warn("[FishIt] No Fishing Rod found!")
        return
    end

    if CastEvent then
        CastEvent:FireServer()
    else
        pcall(function() rod:Activate() end)
    end

    state.isFishing = true
    state.lastCastTime = tick()
    print("[FishIt] 🎣 Casting rod...")
end

local function reelIn()
    local rod = getRod()
    if not rod then return end

    if ReelEvent then
        ReelEvent:FireServer()
    else
        pcall(function() rod:Activate() end)
        task.wait(0.5)
        pcall(function() rod:Destroy() end)
    end
    state.isFishing = false
    print("[FishIt] 💰 Reel in complete!")
end

local function hasFish()
    local rod = character:FindFirstChild("FishingRod")
    return rod and rod:FindFirstChild("Fish")
end

--== AUTO LOOP ==--
task.spawn(function()
    while task.wait(0.2) do
        if CONFIG.AutoFish then
            if not state.isFishing and tick() - state.lastCastTime > CONFIG.AutoCastDelay then
                castRod()
            elseif state.isFishing and hasFish() and CONFIG.AutoReel then
                task.wait(CONFIG.FishTimeout)
                reelIn()
            end
        end
    end
end)

--== UI CREATION ==--
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 220)
Frame.Position = UDim2.new(0.5, -150, 0.5, -110)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = gui

local Title = Instance.new("TextLabel")
Title.Text = "🎣 FishIt Hub by ZOKADA"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Parent = Frame

local function makeButton(text, yPos, colorOff, colorOn, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. ": OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = colorOff
    btn.Parent = Frame

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = text .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and colorOn or colorOff
        callback(enabled)
    end)
    return btn
end

makeButton("Auto Fish", 50, Color3.fromRGB(100, 0, 0), Color3.fromRGB(0, 150, 0), function(v)
    CONFIG.AutoFish = v
end)

makeButton("Auto Reel", 100, Color3.fromRGB(100, 0, 0), Color3.fromRGB(0, 150, 0), function(v)
    CONFIG.AutoReel = v
end)

local TimeoutLabel = Instance.new("TextLabel")
TimeoutLabel.Size = UDim2.new(1, -20, 0, 20)
TimeoutLabel.Position = UDim2.new(0, 10, 0, 160)
TimeoutLabel.BackgroundTransparency = 1
TimeoutLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeoutLabel.Font = Enum.Font.Gotham
TimeoutLabel.TextSize = 14
TimeoutLabel.Text = "Fish Timeout: " .. CONFIG.FishTimeout
TimeoutLabel.Parent = Frame

print("✅ FishIt Hub Loaded v1.4 (Default OFF + AutoEquip Fix)")
