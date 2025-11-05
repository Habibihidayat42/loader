-- 🐝 Bee Hub GUI v2.0 (Honeycomb Edition)
-- Tema madu, hexagon aesthetic, sidebar kiri, minimize, slider delay control
-- Ganti URL di bawah dengan URL raw ke FungsiBeeHub/InstantFishing.lua kamu

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 🟡 Ganti ini ke URL raw GitHub kamu
local RAW_INSTANT_FISHING_URL = "https://raw.githubusercontent.com/Habibihidayat42/loader/main/FungsiBeeHub/InstantFishing.lua"

-- 🎯 Utility fetch
local function fetchRaw(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok then return res end
    return nil
end

-- 🎨 Warna tema madu
local COLOR_BG = Color3.fromRGB(38, 30, 20)
local COLOR_PANEL = Color3.fromRGB(255, 200, 60)
local COLOR_ACCENT = Color3.fromRGB(255, 170, 30)
local COLOR_TEXT = Color3.fromRGB(20, 12, 6)

-- 🖼️ GUI Root
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeeHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 🍯 Window utama
local window = Instance.new("Frame")
window.Name = "BeeHubMain"
window.Size = UDim2.new(0, 440, 0, 370)
window.Position = UDim2.new(0, 40, 0, 120)
window.BackgroundColor3 = COLOR_BG
window.BorderSizePixel = 0
window.Parent = screenGui
local corner = Instance.new("UICorner", window)
corner.CornerRadius = UDim.new(0, 12)

-- 🔸 Header (judul + minimize)
local header = Instance.new("Frame", window)
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -48, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐝 Bee Hub"
title.TextColor3 = COLOR_PANEL
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0, 36, 0, 36)
btnMin.Position = UDim2.new(1, -44, 0.5, -18)
btnMin.BackgroundColor3 = COLOR_PANEL
btnMin.Text = "-"
btnMin.TextColor3 = COLOR_TEXT
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 18
local minCorner = Instance.new("UICorner", btnMin)
minCorner.CornerRadius = UDim.new(1, 0)

-- 🍯 Sidebar kiri
local sidebar = Instance.new("Frame", window)
sidebar.Size = UDim2.new(0, 96, 1, -48)
sidebar.Position = UDim2.new(0, 0, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(26, 20, 12)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

-- 📄 Konten kanan
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, -96, 1, -48)
content.Position = UDim2.new(0, 96, 0, 48)
content.BackgroundTransparency = 1

-- Fungsi buat tombol hexagon
local function createHoneyButton(parent, y, label)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0, 64, 0, 64)
	btn.Position = UDim2.new(0, 16, 0, y)
	btn.BackgroundColor3 = COLOR_PANEL
	btn.Text = ""
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	local inner = Instance.new("TextLabel", btn)
	inner.Size = UDim2.new(1, -10, 1, -10)
	inner.Position = UDim2.new(0, 5, 0, 5)
	inner.BackgroundColor3 = COLOR_ACCENT
	inner.BorderSizePixel = 0
	inner.Text = label
	inner.TextColor3 = COLOR_TEXT
	inner.Font = Enum.Font.GothamBold
	inner.TextSize = 11
	Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 8)
	return btn
end

-- Tombol sidebar
local mainBtn = createHoneyButton(sidebar, 16, "Main")
local settingsBtn = createHoneyButton(sidebar, 96, "Settings")
local aboutBtn = createHoneyButton(sidebar, 176, "About")

-- 📑 Pages
local pages = {}
local function newPage(name)
	local frame = Instance.new("Frame", content)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	pages[name] = frame
	return frame
end

local mainPage = newPage("Main")
mainPage.Visible = true

local settingsPage = newPage("Settings")
local aboutPage = newPage("About")

-- Fungsi ganti halaman
local function showPage(name)
	for k, v in pairs(pages) do
		v.Visible = (k == name)
	end
end
mainBtn.MouseButton1Click:Connect(function() showPage("Main") end)
settingsBtn.MouseButton1Click:Connect(function() showPage("Settings") end)
aboutBtn.MouseButton1Click:Connect(function() showPage("About") end)

-- 🌊 MAIN PAGE (Instant Fishing)
local titleMain = Instance.new("TextLabel", mainPage)
titleMain.Text = "Instant Fishing"
titleMain.Position = UDim2.new(0, 12, 0, 8)
titleMain.Size = UDim2.new(1, -24, 0, 30)
titleMain.BackgroundTransparency = 1
titleMain.TextColor3 = COLOR_PANEL
titleMain.Font = Enum.Font.GothamBold
titleMain.TextSize = 18
titleMain.TextXAlignment = Enum.TextXAlignment.Left

local runBtn = Instance.new("TextButton", mainPage)
runBtn.Position = UDim2.new(0, 12, 0, 44)
runBtn.Size = UDim2.new(0, 180, 0, 36)
runBtn.Text = "RUN Instant Fishing"
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 14
runBtn.TextColor3 = COLOR_TEXT
runBtn.BackgroundColor3 = COLOR_PANEL
Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel", mainPage)
status.Position = UDim2.new(0, 12, 0, 88)
status.Size = UDim2.new(1, -24, 0, 28)
status.Text = "Status: Idle"
status.Font = Enum.Font.Gotham
status.TextColor3 = Color3.fromRGB(220,220,220)
status.TextSize = 14
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left

-- ⚙️ SLIDERS (FishingDelay, CancelDelay, HookDelay)
local sliderSettings = {
	{ key = "FishingDelay", label = "Fishing Delay", min = 0.05, max = 1.0, default = 0.12, y = 130 },
	{ key = "CancelDelay", label = "Cancel Delay", min = 0.02, max = 0.5, default = 0.05, y = 190 },
	{ key = "HookDelay", label = "Hook Delay", min = 0.02, max = 0.5, default = 0.06, y = 250 },
}

local sliders = {}

local function createSlider(parent, cfg)
	local container = Instance.new("Frame", parent)
	container.Position = UDim2.new(0, 12, 0, cfg.y)
	container.Size = UDim2.new(0, 320, 0, 40)
	container.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel", container)
	lbl.Text = cfg.label .. ": " .. cfg.default
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.fromRGB(255,255,200)
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame", container)
	bar.Size = UDim2.new(1, -20, 0, 8)
	bar.Position = UDim2.new(0, 0, 0, 24)
	bar.BackgroundColor3 = Color3.fromRGB(80,60,30)
	bar.BorderSizePixel = 0
	local barCorner = Instance.new("UICorner", bar)
	barCorner.CornerRadius = UDim.new(0, 4)

	local fill = Instance.new("Frame", bar)
	fill.BackgroundColor3 = COLOR_PANEL
	fill.Size = UDim2.new((cfg.default - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

	local dragging = false
	local function updateFill(inputX)
		local rel = math.clamp((inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		local val = math.round((cfg.min + rel * (cfg.max - cfg.min)) * 100) / 100
		lbl.Text = cfg.label .. ": " .. val
		cfg.value = val
		-- update ke core kalau sudah ada
		if _G.FishingScript and _G.FishingScript.Settings then
			_G.FishingScript.Settings[cfg.key] = val
		end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFill(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFill(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	cfg.value = cfg.default
	sliders[cfg.key] = cfg
end

for _, cfg in ipairs(sliderSettings) do
	createSlider(mainPage, cfg)
end

-- 🚀 Jalankan core
runBtn.MouseButton1Click:Connect(function()
	status.Text = "Status: Fetching core..."
	local raw = fetchRaw(RAW_INSTANT_FISHING_URL)
	if not raw then
		status.Text = "Status: Failed to fetch core!"
		return
	end
	local ok, res = pcall(function()
		local fn = loadstring(raw)
		if not fn then error("loadstring failed") end
		return fn()
	end)
	if ok and res then
		status.Text = "Status: Core loaded!"
		_G.FishingScript = res
		-- apply slider values
		for k, cfg in pairs(sliders) do
			if res.Settings[k] then
				res.Settings[k] = cfg.value
			end
		end
	else
		status.Text = "Status: Error running core"
	end
end)

-- 🐝 About Page
local aboutText = Instance.new("TextLabel", aboutPage)
aboutText.Size = UDim2.new(1, -24, 0, 120)
aboutText.Position = UDim2.new(0, 12, 0, 12)
aboutText.Text = "Bee Hub GUI v2.0\nHoneycomb themed UI for your BeeHub fishing scripts.\n🐝 Author: HabibiHidayat42"
aboutText.TextColor3 = Color3.fromRGB(230,230,200)
aboutText.Font = Enum.Font.Gotham
aboutText.TextSize = 14
aboutText.BackgroundTransparency = 1
aboutText.TextWrapped = true
aboutText.TextXAlignment = Enum.TextXAlignment.Left
aboutText.TextYAlignment = Enum.TextYAlignment.Top

-- 🔘 Minimize
local minimized = false
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

local function minimize()
	if minimized then return end
	minimized = true
	local tween = TweenService:Create(window, TweenInfo.new(0.2), {Size = UDim2.new(0, 56, 0, 56)})
	tween:Play()
	tween.Completed:Wait()
	window.Visible = false
	minIcon.Visible = true
end

local function restore()
	if not minimized then return end
	minimized = false
	window.Visible = true
	window.Size = UDim2.new(0, 440, 0, 370)
	minIcon.Visible = false
end

btnMin.MouseButton1Click:Connect(minimize)
minIcon.MouseButton1Click:Connect(restore)

-- 🎮 Draggable window (mouse + touch)
local dragging, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
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

print("🐝 Bee Hub GUI v2.0 loaded successfully!")
