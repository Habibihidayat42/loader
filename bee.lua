-- // Fish It Auto Fish GUI (clean rebuild version)
-- // Created by ChatGPT, safe reimplementation
-- // Works with most executors (Delta, Fluxus, Synapse, etc.)

-- SETTINGS
local CONFIG = {
    remotePath = "game:GetService('ReplicatedStorage').Remotes.Fish", -- ubah kalau perlu
    actionDelay = 2.5, -- waktu tunggu antar aksi (lempar & tarik)
    autoStart = false, -- mulai otomatis saat dijalankan
    logLimit = 30, -- jumlah log yang ditampilkan di GUI
}

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- STATE
local running = false
local logs = {}
local stopSignal = false

-- FUNCTION: Logging
local function log(msg)
    local t = os.date("%H:%M:%S")
    local text = ("[%s] %s"):format(t, tostring(msg))
    table.insert(logs, text)
    if #logs > CONFIG.logLimit then table.remove(logs, 1) end
    print(text)
end

-- FUNCTION: Get Remote
local function getRemote()
    local success, result = pcall(function()
        local chunk = loadstring("return " .. CONFIG.remotePath)
        return chunk and chunk()
    end)
    if success and result then
        return result
    else
        log("⚠️ Gagal menemukan Remote. Cek path di config.")
        return nil
    end
end

-- FUNCTION: Auto Fish Logic
local function doFish()
    local remote = getRemote()
    if not remote then return end

    -- Biasanya ada dua tahap: lempar & tarik
    pcall(function()
        if remote.FireServer then
            remote:FireServer("Cast") -- lempar pancing
            log("🎣 Lempar pancing...")
            task.wait(1.5)
            remote:FireServer("Reel") -- tarik pancing
            log("🐟 Tarik pancing...")
        elseif remote.InvokeServer then
            remote:InvokeServer("Cast")
            task.wait(1.5)
            remote:InvokeServer("Reel")
        else
            log("⚠️ Remote tidak punya FireServer/InvokeServer.")
        end
    end)
end

-- FUNCTION: Main Loop
local function startAutoFish()
    if running then return end
    running = true
    stopSignal = false
    log("▶️ Auto Fish dimulai...")

    task.spawn(function()
        while not stopSignal do
            doFish()
            task.wait(CONFIG.actionDelay)
        end
        running = false
        log("⏹️ Auto Fish dihentikan.")
    end)
end

local function stopAutoFish()
    stopSignal = true
end

-- GUI SETUP
if CoreGui:FindFirstChild("FishItAutoGui") then
    CoreGui:FindFirstChild("FishItAutoGui"):Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "FishItAutoGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 220)
frame.Position = UDim2.new(0.05, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "🎣 Fish It Auto Fisher"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local startBtn = Instance.new("TextButton", frame)
startBtn.Text = "Start"
startBtn.Size = UDim2.new(0.45, -5, 0, 40)
startBtn.Position = UDim2.new(0.025, 0, 0.15, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(20, 150, 20)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextSize = 18

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Text = "Stop"
stopBtn.Size = UDim2.new(0.45, -5, 0, 40)
stopBtn.Position = UDim2.new(0.525, 0, 0.15, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.TextSize = 18

local pathLabel = Instance.new("TextLabel", frame)
pathLabel.Size = UDim2.new(1, -10, 0, 20)
pathLabel.Position = UDim2.new(0.025, 0, 0.38, 0)
pathLabel.Text = "Remote Path:"
pathLabel.TextColor3 = Color3.new(1,1,1)
pathLabel.BackgroundTransparency = 1
pathLabel.Font = Enum.Font.SourceSans
pathLabel.TextSize = 16
pathLabel.TextXAlignment = Enum.TextXAlignment.Left

local pathBox = Instance.new("TextBox", frame)
pathBox.Size = UDim2.new(1, -10, 0, 24)
pathBox.Position = UDim2.new(0.025, 0, 0.48, 0)
pathBox.Text = CONFIG.remotePath
pathBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
pathBox.TextColor3 = Color3.new(1,1,1)
pathBox.Font = Enum.Font.SourceSans
pathBox.TextSize = 16
pathBox.ClearTextOnFocus = false

local delayLabel = Instance.new("TextLabel", frame)
delayLabel.Text = "Delay (detik): " .. CONFIG.actionDelay
delayLabel.Size = UDim2.new(1, -10, 0, 20)
delayLabel.Position = UDim2.new(0.025, 0, 0.62, 0)
delayLabel.TextColor3 = Color3.new(1,1,1)
delayLabel.BackgroundTransparency = 1
delayLabel.Font = Enum.Font.SourceSans
delayLabel.TextSize = 16
delayLabel.TextXAlignment = Enum.TextXAlignment.Left

local delaySlider = Instance.new("TextBox", frame)
delaySlider.Size = UDim2.new(1, -10, 0, 24)
delaySlider.Position = UDim2.new(0.025, 0, 0.72, 0)
delaySlider.Text = tostring(CONFIG.actionDelay)
delaySlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
delaySlider.TextColor3 = Color3.new(1,1,1)
delaySlider.Font = Enum.Font.SourceSans
delaySlider.TextSize = 16
delaySlider.ClearTextOnFocus = false

local logBox = Instance.new("TextBox", frame)
logBox.Size = UDim2.new(1, -10, 0, 60)
logBox.Position = UDim2.new(0.025, 0, 0.84, 0)
logBox.Text = "Logs..."
logBox.ClearTextOnFocus = false
logBox.TextWrapped = true
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.MultiLine = true
logBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
logBox.TextColor3 = Color3.fromRGB(200,200,200)
logBox.Font = Enum.Font.SourceSans
logBox.TextSize = 14

-- Button events
startBtn.MouseButton1Click:Connect(function()
    CONFIG.remotePath = pathBox.Text
    CONFIG.actionDelay = tonumber(delaySlider.Text) or CONFIG.actionDelay
    startAutoFish()
end)

stopBtn.MouseButton1Click:Connect(function()
    stopAutoFish()
end)

-- Log updater
task.spawn(function()
    while gui.Parent do
        task.wait(0.5)
        if #logs > 0 then
            logBox.Text = table.concat(logs, "\n")
        end
    end
end)

log("✅ Script Auto Fish loaded.")
log("Tekan Start untuk mulai, atau ubah Remote Path di GUI.")
