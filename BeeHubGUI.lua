-- BeeHubGUI.lua (Honeycomb Edition) - v3
-- Sidebar: Instant Fishing & Instant 2X Speed
-- Sliders update the cores' _G.FishingScript.Settings in real-time
-- When GUI visible: blocks camera & movement inputs (modal)
-- Replace RAW URLs below if you change filenames/paths

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== CONFIG: raw URLs to your GitHub raw files ==========
local RAW_BASE = "https://raw.githubusercontent.com/Habibihidayat42/loader/main/FungsiBeeHub/"
local RAW_INSTANT_FISHING = RAW_BASE .. "InstantFishing.lua"
local RAW_INSTANT_2X = RAW_BASE .. "Instant2XSpeed.lua"
-- ===============================================================

-- Theme
local COLOR_BG = Color3.fromRGB(38, 30, 20)
local COLOR_PANEL = Color3.fromRGB(255, 200, 60)
local COLOR_ACCENT = Color3.fromRGB(255, 170, 30)
local COLOR_TEXT = Color3.fromRGB(20, 12, 6)
local COLOR_SUB = Color3.fromRGB(220,220,200)

-- Fetch helper (tries HttpGet; if your executor doesn't allow, modify to readfile)
local function fetchRaw(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 10 then return res end
    return nil
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeeHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Root window
local window = Instance.new("Frame", screenGui)
window.Name = "BeeHubMain"
window.Size = UDim2.new(0, 460, 0, 400)
window.Position = UDim2.new(0, 40, 0, 90)
window.BackgroundColor3 = COLOR_BG
window.BorderSizePixel = 0
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)

-- Header (drag)
local header = Instance.new("Frame", window)
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -48, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Bee Hub"
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
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(1, 0)

-- Sidebar (left)
local sidebar = Instance.new("Frame", window)
sidebar.Size = UDim2.new(0, 100, 1, -48)
sidebar.Position = UDim2.new(0, 0, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(26,20,12)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,10)

local function makeHoneyBtn(parent, y, label)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 68, 0, 68)
    btn.Position = UDim2.new(0, 16, 0, y)
    btn.BackgroundColor3 = COLOR_PANEL
    btn.BorderSizePixel = 0
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local inner = Instance.new("TextLabel", btn)
    inner.Size = UDim2.new(1, -10, 1, -10)
    inner.Position = UDim2.new(0,5,0,5)
    inner.BackgroundColor3 = COLOR_ACCENT
    inner.BorderSizePixel = 0
    inner.Text = label
    inner.Font = Enum.Font.GothamBold
    inner.TextSize = 12
    inner.TextColor3 = COLOR_TEXT
    inner.BackgroundTransparency = 0
    Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 8)
    return btn
end

local btnMain = makeHoneyBtn(sidebar, 12, "Instant\nFishing")
local btn2x   = makeHoneyBtn(sidebar, 96, "Instant\n2X")
local btnSettings = makeHoneyBtn(sidebar, 180, "Settings")

-- Content container
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, -100, 1, -48)
content.Position = UDim2.new(0, 100, 0, 48)
content.BackgroundTransparency = 1

-- Pages
local pages = {}
local function newPage(name)
    local f = Instance.new("Frame", content)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundTransparency = 1
    f.Visible = false
    pages[name] = f
    return f
end

local pageMain = newPage("Main")
local page2x   = newPage("2X")
local pageSettings = newPage("Settings")
pages["Main"].Visible = true

-- Modal input blocking: function to enable/disable blocking so camera/controls behind GUI don't react
local CAS = ContextActionService
local blockActionName = "BeeHubBlockInput"
local blockInputsList = {
    Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
    Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right,
    Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift,
    Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1,
    Enum.UserInputType.MouseButton2
}
local function blockAction(actionName, inputState, inputObject)
    return Enum.ContextActionResult.Sink
end
local modalActive = false
local function setModal(active)
    if active and not modalActive then
        -- Bind all keys and mouse movement to sink
        CAS:BindAction(blockActionName, blockAction, false, unpack(blockInputsList))
        modalActive = true
    elseif not active and modalActive then
        CAS:UnbindAction(blockActionName)
        modalActive = false
    end
end

-- Helper: show a page
local function showPage(name)
    for k,v in pairs(pages) do v.Visible = (k == name) end
    -- enable modal blocking when any page is visible (i.e. window shown)
    setModal(true)
end

btnMain.MouseButton1Click:Connect(function() showPage("Main") end)
btn2x.MouseButton1Click:Connect(function() showPage("2X") end)
btnSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

-- Minimize / restore
local minimized = false
local minIcon = Instance.new("TextButton", screenGui)
minIcon.Size = UDim2.new(0, 56, 0, 56)
minIcon.Position = UDim2.new(0, 24, 0, 90)
minIcon.BackgroundColor3 = COLOR_PANEL
minIcon.Text = "🐝"
minIcon.TextColor3 = COLOR_TEXT
minIcon.Font = Enum.Font.GothamBold
minIcon.Visible = false
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1,0)

btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        minimized = true
        window.Visible = false
        minIcon.Visible = true
        setModal(false) -- allow camera when minimized
    else
        minimized = false
        window.Visible = true
        minIcon.Visible = false
        setModal(true)
    end
end)
minIcon.MouseButton1Click:Connect(function()
    minimized = false
    window.Visible = true
    minIcon.Visible = false
    setModal(true)
end)

-- Dragging support (mouse & touch)
do
    local dragging=false
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- ---------- Page: Main (Instant Fishing) ----------
do
    local p = pageMain
    local title = Instance.new("TextLabel", p)
    title.Position = UDim2.new(0,12,0,8)
    title.Size = UDim2.new(1,-24,0,28)
    title.BackgroundTransparency = 1
    title.Text = "Instant Fishing"
    title.TextColor3 = COLOR_PANEL
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local runBtn = Instance.new("TextButton", p)
    runBtn.Position = UDim2.new(0,12,0,44)
    runBtn.Size = UDim2.new(0,200,0,36)
    runBtn.Text = "RUN InstantFishing (Load Core)"
    runBtn.Font = Enum.Font.GothamBold
    runBtn.TextSize = 14
    runBtn.BackgroundColor3 = COLOR_PANEL
    runBtn.TextColor3 = COLOR_TEXT
    Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0,8)

    local startBtn = Instance.new("TextButton", p)
    startBtn.Position = UDim2.new(0,220,0,44)
    startBtn.Size = UDim2.new(0,110,0,36)
    startBtn.Text = "START"
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 14
    startBtn.BackgroundColor3 = Color3.fromRGB(60,200,80)
    startBtn.TextColor3 = COLOR_TEXT
    Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,8)

    local stopBtn = Instance.new("TextButton", p)
    stopBtn.Position = UDim2.new(0,340,0,44)
    stopBtn.Size = UDim2.new(0,110,0,36)
    stopBtn.Text = "STOP"
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 14
    stopBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
    stopBtn.TextColor3 = COLOR_TEXT
    Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,8)

    local status = Instance.new("TextLabel", p)
    status.Position = UDim2.new(0,12,0,88)
    status.Size = UDim2.new(1,-24,0,28)
    status.BackgroundTransparency = 1
    status.Text = "Status: Idle"
    status.Font = Enum.Font.Gotham
    status.TextColor3 = COLOR_SUB
    status.TextXAlignment = Enum.TextXAlignment.Left

    -- slider config for InstantFishing (ke mirror GUI internal)
    local sliderCfg = {
        { key="FishingDelay", label="Fishing Delay", min=0.05, max=1.0, default=0.12, y=130 },
        { key="CancelDelay", label="Cancel Delay", min=0.01, max=0.5, default=0.05, y=190 },
        { key="HookDelay", label="Hook Delay", min=0.01, max=0.5, default=0.06, y=250 },
        { key="ChargeToRequestDelay", label="Charge->Request Delay", min=0.0, max=0.2, default=0.05, y=310 },
        { key="FallbackTimeout", label="Fallback Timeout", min=0.2, max=3.0, default=1.5, y=370 },
    }

    local sliders = {}

    local function createSlider(parent, cfg)
        local cont = Instance.new("Frame", parent)
        cont.Position = UDim2.new(0,12,0,cfg.y)
        cont.Size = UDim2.new(0,340,0,36)
        cont.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", cont)
        lbl.Size = UDim2.new(1,0,0,18)
        lbl.Position = UDim2.new(0,0,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextColor3 = COLOR_SUB
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", cont)
        bar.Size = UDim2.new(1,0,0,8)
        bar.Position = UDim2.new(0,0,0,18)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,80)
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)

        local fill = Instance.new("Frame", bar)
        local rel = (cfg.default - cfg.min) / (cfg.max - cfg.min)
        fill.Size = UDim2.new(rel,0,1,0)
        fill.BackgroundColor3 = COLOR_PANEL
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)

        lbl.Text = string.format("%s: %.2f", cfg.label, cfg.default)
        cfg.value = cfg.default
        sliders[cfg.key] = cfg

        local dragging = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local conn
                conn = UserInputService.InputChanged:Connect(function(inp)
                    if not dragging then return end
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                        local relx = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,0,1)
                        fill.Size = UDim2.new(relx,0,1,0)
                        local v = cfg.min + relx * (cfg.max - cfg.min)
                        v = math.floor(v*100)/100
                        cfg.value = v
                        lbl.Text = string.format("%s: %.2f", cfg.label, v)
                        -- update core if loaded
                        if _G.FishingScript and _G.FishingScript.Settings and _G.FishingScript.Settings[cfg.key] ~= nil then
                            _G.FishingScript.Settings[cfg.key] = v
                        end
                    end
                end)
                UserInputService.InputEnded:Wait()
                dragging = false
                conn:Disconnect()
            end
        end)
    end

    for _,cfg in ipairs(sliderCfg) do createSlider(pageMain, cfg) end

    -- RUN core
    runBtn.MouseButton1Click:Connect(function()
        status.Text = "Status: fetching core..."
        local raw = fetchRaw(RAW_INSTANT_FISHING)
        if not raw then
            status.Text = "Status: failed to fetch core (HttpGet blocked?)"
            return
        end
        local ok, res = pcall(function()
            local fn = loadstring(raw)
            if not fn then error("loadstring failed") end
            return fn()
        end)
        if ok and res then
            _G.FishingScript = res
            -- apply slider values to core Settings
            for k, cfg in pairs(sliders) do
                if _G.FishingScript.Settings and _G.FishingScript.Settings[k] ~= nil then
                    _G.FishingScript.Settings[k] = cfg.value
                end
            end
            status.Text = "Status: core loaded"
        else
            status.Text = "Status: core error: "..tostring(res)
        end
    end)

    -- Start / Stop buttons call core functions if available
    startBtn.MouseButton1Click:Connect(function()
        if _G.FishingScript and type(_G.FishingScript.Start) == "function" then
            pcall(function() _G.FishingScript.Start() end)
            status.Text = "Status: running"
        end
    end)
    stopBtn.MouseButton1Click:Connect(function()
        if _G.FishingScript and type(_G.FishingScript.Stop) == "function" then
            pcall(function() _G.FishingScript.Stop() end)
            status.Text = "Status: stopped"
        end
    end)
end

-- ---------- Page: Instant 2X ----------
do
    local p = page2x
    local title = Instance.new("TextLabel", p)
    title.Position = UDim2.new(0,12,0,8)
    title.Size = UDim2.new(1,-24,0,28)
    title.BackgroundTransparency = 1
    title.Text = "Instant 2X Speed"
    title.TextColor3 = COLOR_PANEL
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local runBtn = Instance.new("TextButton", p)
    runBtn.Position = UDim2.new(0,12,0,44)
    runBtn.Size = UDim2.new(0,200,0,36)
    runBtn.Text = "RUN Instant2XSpeed (Load Core)"
    runBtn.Font = Enum.Font.GothamBold
    runBtn.TextSize = 14
    runBtn.BackgroundColor3 = COLOR_PANEL
    runBtn.TextColor3 = COLOR_TEXT
    Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0,8)

    local startBtn = Instance.new("TextButton", p)
    startBtn.Position = UDim2.new(0,220,0,44)
    startBtn.Size = UDim2.new(0,110,0,36)
    startBtn.Text = "START"
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 14
    startBtn.BackgroundColor3 = Color3.fromRGB(60,200,80)
    startBtn.TextColor3 = COLOR_TEXT
    Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,8)

    local stopBtn = Instance.new("TextButton", p)
    stopBtn.Position = UDim2.new(0,340,0,44)
    stopBtn.Size = UDim2.new(0,110,0,36)
    stopBtn.Text = "STOP"
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 14
    stopBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
    stopBtn.TextColor3 = COLOR_TEXT
    Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,8)

    local status = Instance.new("TextLabel", p)
    status.Position = UDim2.new(0,12,0,88)
    status.Size = UDim2.new(1,-24,0,28)
    status.BackgroundTransparency = 1
    status.Text = "Status: Idle"
    status.Font = Enum.Font.Gotham
    status.TextColor3 = COLOR_SUB
    status.TextXAlignment = Enum.TextXAlignment.Left

    -- slider config for 2X
    local sliderCfg2x = {
        { key="FishingDelay", label="Fishing Delay", min=0.0, max=1.0, default=0.3, y=130 },
        { key="CancelDelay", label="Cancel Delay", min=0.01, max=0.25, default=0.05, y=190 },
    }
    local sliders2 = {}

    local function createSlider(parent, cfg)
        local cont = Instance.new("Frame", parent)
        cont.Position = UDim2.new(0,12,0,cfg.y)
        cont.Size = UDim2.new(0,340,0,36)
        cont.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", cont)
        lbl.Size = UDim2.new(1,0,0,18)
        lbl.Position = UDim2.new(0,0,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextColor3 = COLOR_SUB
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", cont)
        bar.Size = UDim2.new(1,0,0,8)
        bar.Position = UDim2.new(0,0,0,18)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,80)
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)

        local fill = Instance.new("Frame", bar)
        local rel = (cfg.default - cfg.min) / (cfg.max - cfg.min)
        fill.Size = UDim2.new(rel,0,1,0)
        fill.BackgroundColor3 = COLOR_PANEL
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)

        lbl.Text = string.format("%s: %.2f", cfg.label, cfg.default)
        cfg.value = cfg.default
        sliders2[cfg.key] = cfg

        local dragging = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local conn
                conn = UserInputService.InputChanged:Connect(function(inp)
                    if not dragging then return end
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                        local relx = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,0,1)
                        fill.Size = UDim2.new(relx,0,1,0)
                        local v = cfg.min + relx * (cfg.max - cfg.min)
                        v = math.floor(v*100)/100
                        cfg.value = v
                        lbl.Text = string.format("%s: %.2f", cfg.label, v)
                        -- update core if loaded
                        if _G.FishingScript and _G.FishingScript.Settings and _G.FishingScript.Settings[cfg.key] ~= nil then
                            _G.FishingScript.Settings[cfg.key] = v
                        end
                    end
                end)
                UserInputService.InputEnded:Wait()
                dragging = false
                conn:Disconnect()
            end
        end)
    end

    for _,cfg in ipairs(sliderCfg2x) do createSlider(page2x, cfg) end

    -- load core
    runBtn.MouseButton1Click:Connect(function()
        status.Text = "Status: fetching core..."
        local raw = fetchRaw(RAW_INSTANT_2X)
        if not raw then
            status.Text = "Status: failed to fetch core (HttpGet blocked?)"
            return
        end
        local ok, res = pcall(function()
            local fn = loadstring(raw)
            if not fn then error("loadstring failed") end
            return fn()
        end)
        if ok and res then
            _G.FishingScript = res
            -- apply slider values to core Settings
            for k, cfg in pairs(sliders2) do
                if _G.FishingScript.Settings and _G.FishingScript.Settings[k] ~= nil then
                    _G.FishingScript.Settings[k] = cfg.value
                end
            end
            status.Text = "Status: core loaded"
        else
            status.Text = "Status: core error: "..tostring(res)
        end
    end)

    startBtn.MouseButton1Click:Connect(function()
        if _G.FishingScript and type(_G.FishingScript.Start) == "function" then
            pcall(function() _G.FishingScript.Start() end)
            status.Text = "Status: running"
        end
    end)
    stopBtn.MouseButton1Click:Connect(function()
        if _G.FishingScript and type(_G.FishingScript.Stop) == "function" then
            pcall(function() _G.FishingScript.Stop() end)
            status.Text = "Status: stopped"
        end
    end)
end

-- Settings page (simple)
do
    local p = pageSettings
    local t = Instance.new("TextLabel", p)
    t.Position = UDim2.new(0,12,0,12)
    t.Size = UDim2.new(1,-24,0,120)
    t.BackgroundTransparency = 1
    t.Text = "Bee Hub GUI v3\n- Drag window header to move (supports touch)\n- When window open, camera and movement are blocked.\n- Sliders directly write to _G.FishingScript.Settings if core loaded."
    t.Font = Enum.Font.Gotham
    t.TextSize = 14
    t.TextColor3 = COLOR_SUB
    t.TextWrapped = true
end

-- restore modal when window initially visible
setModal(true)

print("Bee Hub GUI v3 loaded.")
