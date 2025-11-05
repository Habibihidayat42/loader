-- 🐝 Bee Hub GUI v3.5 (Honeycomb Unified Edition)
-- Theme: Honey Gold | Auto-load InstantFishing & Instant2XSpeed cores
-- Author: HabibiHidayat42
-- Repo: https://github.com/Habibihidayat42/loader

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RAW_BASE = "https://raw.githubusercontent.com/Habibihidayat42/loader/main/FungsiBeeHub/"
local CORES = {
    InstantFishing = RAW_BASE .. "InstantFishing.lua",
    Instant2XSpeed = RAW_BASE .. "Instant2XSpeed.lua"
}

-- 🎯 Fetch core safely
local function safeFetch(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and res and res:find("return") then
        local fn = loadstring(res)
        if fn then
            local ok2, result = pcall(fn)
            if ok2 then return result end
        end
    end
    return nil
end

-- 🟡 Colors
local COLOR_BG = Color3.fromRGB(38, 30, 20)
local COLOR_PANEL = Color3.fromRGB(255, 200, 60)
local COLOR_ACCENT = Color3.fromRGB(255, 170, 30)
local COLOR_TEXT = Color3.fromRGB(20, 12, 6)

-- 🐝 GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeeHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 🍯 Window
local window = Instance.new("Frame")
window.Name = "BeeHubMain"
window.Size = UDim2.new(0, 460, 0, 400)
window.Position = UDim2.new(0, 40, 0, 120)
window.BackgroundColor3 = COLOR_BG
window.BorderSizePixel = 0
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)
window.Parent = screenGui

-- 🧭 Sidebar
local sidebar = Instance.new("Frame", window)
sidebar.Size = UDim2.new(0, 96, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(26, 20, 12)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", sidebar)
title.Size = UDim2.new(1, 0, 0, 48)
title.Text = "🐝 Bee Hub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = COLOR_PANEL
title.TextSize = 20
title.BackgroundTransparency = 1

-- 🪟 Content
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, -96, 1, 0)
content.Position = UDim2.new(0, 96, 0, 0)
content.BackgroundTransparency = 1

-- 🔘 Minimize
local btnMin = Instance.new("TextButton", sidebar)
btnMin.Size = UDim2.new(0, 70, 0, 30)
btnMin.Position = UDim2.new(0, 13, 1, -40)
btnMin.Text = "MIN"
btnMin.TextColor3 = COLOR_TEXT
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 14
btnMin.BackgroundColor3 = COLOR_PANEL
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(1, 0)

local minIcon = Instance.new("TextButton", screenGui)
minIcon.Size = UDim2.new(0, 56, 0, 56)
minIcon.Position = window.Position
minIcon.BackgroundColor3 = COLOR_PANEL
minIcon.Text = "🐝"
minIcon.TextColor3 = COLOR_TEXT
minIcon.Font = Enum.Font.GothamBold
minIcon.TextSize = 18
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1, 0)
minIcon.Visible = false

local minimized = false
local function minimize()
	if minimized then return end
	minimized = true
	ContextActionService:UnbindAction("BlockMovement")
	window.Visible = false
	minIcon.Visible = true
end
local function restore()
	if not minimized then return end
	minimized = false
	minIcon.Visible = false
	window.Visible = true
	ContextActionService:BindAction("BlockMovement", function() return Enum.ContextActionResult.Sink end, false,
		Enum.UserInputType.MouseMovement, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch,
		Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)
end
btnMin.MouseButton1Click:Connect(minimize)
minIcon.MouseButton1Click:Connect(restore)

-- 🧲 Modal input lock
ContextActionService:BindAction("BlockMovement", function() return Enum.ContextActionResult.Sink end, false,
	Enum.UserInputType.MouseMovement, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch,
	Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)

-- 🎮 Draggable
local dragging, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
window.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = window.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		update(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ⚙️ Helper buat slider
local function createSlider(parent, label, key, min, max, default, y, settingsTable)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0, 320, 0, 40)
	frame.Position = UDim2.new(0, 20, 0, y)
	frame.BackgroundTransparency = 1

	local text = Instance.new("TextLabel", frame)
	text.Size = UDim2.new(1, 0, 0, 18)
	text.Text = label .. ": " .. default
	text.TextColor3 = Color3.fromRGB(255, 255, 200)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.Gotham
	text.TextSize = 14
	text.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame", frame)
	bar.Size = UDim2.new(1, -10, 0, 8)
	bar.Position = UDim2.new(0, 0, 0, 22)
	bar.BackgroundColor3 = Color3.fromRGB(80, 60, 30)
	bar.BorderSizePixel = 0
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

	local fill = Instance.new("Frame", bar)
	fill.BackgroundColor3 = COLOR_PANEL
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

	local dragging = false
	local function updateSlider(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local val = math.round((min + rel * (max - min)) * 100) / 100
		fill.Size = UDim2.new(rel, 0, 1, 0)
		text.Text = label .. ": " .. val
		settingsTable[key] = val
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateSlider(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- 🌊 Main content
local mainFrame = Instance.new("Frame", content)
mainFrame.Size = UDim2.new(1, -20, 1, -20)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundTransparency = 1

local header = Instance.new("TextLabel", mainFrame)
header.Size = UDim2.new(1, 0, 0, 24)
header.Text = "Bee Hub — Unified Fishing Controls"
header.TextColor3 = COLOR_PANEL
header.Font = Enum.Font.GothamBold
header.TextSize = 18
header.BackgroundTransparency = 1

local status = Instance.new("TextLabel", mainFrame)
status.Position = UDim2.new(0, 0, 0, 26)
status.Size = UDim2.new(1, 0, 0, 22)
status.Text = "Loading cores..."
status.TextColor3 = Color3.fromRGB(255, 255, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left

-- 🧩 Load cores automatically
task.spawn(function()
	local fishing = safeFetch(CORES.InstantFishing)
	local speed = safeFetch(CORES.Instant2XSpeed)

	if fishing then
		status.Text = "✅ InstantFishing core loaded."
	else
		status.Text = "❌ Failed to load InstantFishing.lua"
	end
	task.wait(0.2)
	if speed then
		status.Text = status.Text .. "\n✅ Instant2XSpeed core loaded."
	else
		status.Text = status.Text .. "\n❌ Failed to load Instant2XSpeed.lua"
	end

	if fishing and speed then
		task.wait(0.5)
		status.Text = "✅ All cores loaded successfully!"
	else
		status.Text = status.Text .. "\n⚠️ Some cores failed."
	end
end)

-- 🎣 Instant Fishing Section
local IF_label = Instance.new("TextLabel", mainFrame)
IF_label.Text = "⚡ Instant Fishing"
IF_label.Font = Enum.Font.GothamBold
IF_label.TextSize = 16
IF_label.TextColor3 = COLOR_PANEL
IF_label.BackgroundTransparency = 1
IF_label.Position = UDim2.new(0, 0, 0, 60)
IF_label.Size = UDim2.new(1, 0, 0, 24)

local fishingSettings = {}
createSlider(mainFrame, "Hook Delay", "HookDelay", 0.01, 0.25, 0.06, 86, fishingSettings)
createSlider(mainFrame, "Fishing Delay", "FishingDelay", 0.05, 1.0, 0.12, 126, fishingSettings)
createSlider(mainFrame, "Cancel Delay", "CancelDelay", 0.01, 0.25, 0.05, 166, fishingSettings)

-- ⚡ Instant 2X Speed Section
local S2_label = Instance.new("TextLabel", mainFrame)
S2_label.Text = "⚡ Instant 2X Speed"
S2_label.Font = Enum.Font.GothamBold
S2_label.TextSize = 16
S2_label.TextColor3 = COLOR_PANEL
S2_label.BackgroundTransparency = 1
S2_label.Position = UDim2.new(0, 0, 0, 210)
S2_label.Size = UDim2.new(1, 0, 0, 24)

local speedSettings = {}
createSlider(mainFrame, "Fishing Delay", "FishingDelay", 0.0, 1.0, 0.3, 236, speedSettings)
createSlider(mainFrame, "Cancel Delay", "CancelDelay", 0.01, 0.2, 0.05, 276, speedSettings)

print("🐝 Bee Hub v3.5 fully loaded.")
