-- ⚡ ULTRA SPEED AUTO FISHING v30.0 (Extended Slider Range)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- Auto-stop any previous fishing scripts
if _G.FishingScript then
    _G.FishingScript.Stop()
    if _G.FishingScript.GUI then
        _G.FishingScript.GUI:Destroy()
    end
    task.wait(0.1)
end

local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

-- Fishing settings dengan range yang lebih luas
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    ToggleKey = "F",
    
    -- ⚙️ SLIDER DENGAN RANGE LEBIH BESAR
    Settings = {
        FishingDelay = 0.5,    -- Range lebih besar untuk rod lambat
        CancelDelay = 0.1,     -- Range lebih besar untuk rod lambat
    },
    
    GUI = nil
}

_G.FishingScript = fishing

local function log(msg)
    print(("[Fishing] %s"):format(msg))
end

-- 🎯 HOOK DETECTION
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        
        -- ⚡ TARIK IKAN DULU - PASTIKAN IKAN NAIK
        task.wait(0.05)
        RE_FishingCompleted:FireServer()
        log("✅ Hook terdeteksi — ikan ditarik.")
        
        -- CANCEL INPUTS SETELAH BERHASIL TARIK IKAN
        task.wait(fishing.Settings.CancelDelay)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
            log("🔄 Cancel inputs - reset cepat!")
        end)
        
        -- ⏳ TUNGGU FISHING DELAY YANG DIATUR
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end)

-- 🐟 FISH CAUGHT
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        local weight = data and data.Weight or 0
        log("🐟 Ikan tertangkap: " .. tostring(name) .. " (" .. string.format("%.2f", weight) .. " kg)")
        fishing.UpdateStats()
        
        -- CANCEL INPUTS SETELAH IKAN MASUK INVENTORY
        task.wait(fishing.Settings.CancelDelay)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
            log("🔄 Cancel inputs - reset cepat!")
        end)
        
        -- ⏳ TUNGGU FISHING DELAY YANG DIATUR
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end)

-- 🎣 CAST FUNCTION
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    fishing.UpdateStats()
    
    pcall(function()
        -- 1️⃣ LEMPAR KAIL
        RF_ChargeFishingRod:InvokeServer({[4] = tick()})
        log("⚡ Lempar pancing.")
        task.wait(0.15)

        -- 2️⃣ MULAI MINIGAME & TUNGGU TANDA SERU
        RF_RequestMinigame:InvokeServer(1.95, 0.5, tick())
        log("🎯 Menunggu hook...")
        fishing.WaitingHook = true

        -- 3️⃣ FALLBACK DENGAN TIMEOUT YANG LEBIH PANJANG
        task.delay(3.0, function() -- Timeout lebih panjang untuk rod lambat
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                RE_FishingCompleted:FireServer()
                log("⚠️ Timeout — fallback tarik.")
                
                -- CANCEL INPUTS PADA TIMEOUT
                task.wait(fishing.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                    log("🔄 Cancel timeout - reset cepat!")
                end)
                
                -- ⏳ TUNGGU FISHING DELAY YANG DIATUR
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
    end)
end

-- 🎨 GUI DENGAN SLIDER RANGE LEBIH BESAR
function fishing.CreateGUI()
    if fishing.GUI then
        fishing.GUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FishingControlGUI"
    gui.Parent = localPlayer.PlayerGui
    fishing.GUI = gui

    -- Main Frame (sedikit lebih besar untuk info)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 280)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ FISHING CONTROL v30.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = header

    -- Stats
    fishing.StatusLabel = Instance.new("TextLabel")
    fishing.StatusLabel.Size = UDim2.new(0.5, -5, 0, 25)
    fishing.StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    fishing.StatusLabel.BackgroundTransparency = 1
    fishing.StatusLabel.Text = "STOPPED"
    fishing.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    fishing.StatusLabel.TextSize = 12
    fishing.StatusLabel.Font = Enum.Font.GothamBold
    fishing.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    fishing.StatusLabel.Parent = mainFrame

    fishing.FishLabel = Instance.new("TextLabel")
    fishing.FishLabel.Size = UDim2.new(0.5, -5, 0, 25)
    fishing.FishLabel.Position = UDim2.new(0.5, 5, 0, 45)
    fishing.FishLabel.BackgroundTransparency = 1
    fishing.FishLabel.Text = "Fish: 0"
    fishing.FishLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    fishing.FishLabel.TextSize = 12
    fishing.FishLabel.Font = Enum.Font.Gotham
    fishing.FishLabel.TextXAlignment = Enum.TextXAlignment.Left
    fishing.FishLabel.Parent = mainFrame

    -- Simple Slider Function dengan range lebih besar
    local function createSlider(name, defaultValue, min, max, yPosition, color, description)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, -20, 0, 50)
        sliderFrame.Position = UDim2.new(0, 10, 0, yPosition)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = mainFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. string.format("%.2fs", defaultValue)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        -- Description
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 12)
        desc.Position = UDim2.new(0, 0, 0, 15)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        desc.TextSize = 9
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = sliderFrame

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 6)
        sliderBg.Position = UDim2.new(0, 0, 0, 30)
        sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        sliderBg.Parent = sliderFrame

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = sliderBg

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = color
        fill.Parent = sliderBg

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 2, 0)
        button.Position = UDim2.new(0, 0, -0.5, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = sliderBg

        local value = defaultValue
        
        button.MouseButton1Down:Connect(function()
            local connection
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    value = min + (max - min) * relativeX
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    label.Text = name .. ": " .. string.format("%.2fs", value)
                    
                    if name == "Fishing Delay" then
                        fishing.Settings.FishingDelay = value
                    elseif name == "Cancel Delay" then
                        fishing.Settings.CancelDelay = value
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end)
        
        return sliderFrame
    end

    -- 2 SLIDER DENGAN RANGE LEBIH BESAR
    createSlider("Fishing Delay", 0.5, 0.1, 3.0, 75, Color3.fromRGB(0, 170, 255), "Delay setelah cancel (0.1-3.0s)")
    createSlider("Cancel Delay", 0.1, 0.01, 1.0, 130, Color3.fromRGB(255, 100, 100), "Delay sebelum cancel (0.01-1.0s)")

    -- Preset Buttons
    local presetsFrame = Instance.new("Frame")
    presetsFrame.Size = UDim2.new(1, -20, 0, 30)
    presetsFrame.Position = UDim2.new(0, 10, 0, 185)
    presetsFrame.BackgroundTransparency = 1
    presetsFrame.Parent = mainFrame

    local function createPresetButton(text, fishingDelay, cancelDelay, xPos, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.3, -5, 1, 0)
        btn.Position = UDim2.new(xPos, 0, 0, 0)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.Parent = presetsFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            fishing.Settings.FishingDelay = fishingDelay
            fishing.Settings.CancelDelay = cancelDelay
            log("🎯 Preset " .. text .. " applied!")
        end)
    end

    createPresetButton("FAST", 0.1, 0.01, 0.0, Color3.fromRGB(0, 200, 0))
    createPresetButton("MEDIUM", 0.5, 0.1, 0.33, Color3.fromRGB(255, 165, 0))
    createPresetButton("SLOW", 1.5, 0.3, 0.66, Color3.fromRGB(255, 50, 50))

    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 35)
    toggleBtn.Position = UDim2.new(0, 10, 0, 225)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    toggleBtn.Text = "START FISHING"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = toggleBtn

    toggleBtn.MouseButton1Click:Connect(function()
        fishing.Toggle()
    end)

    fishing.ToggleButton = toggleBtn
end

-- Update stats
function fishing.UpdateStats()
    if fishing.FishLabel then
        fishing.FishLabel.Text = "Fish: " .. fishing.TotalFish
    end
end

-- ▶️ Start Fishing
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.StatusLabel.Text = "RUNNING"
    fishing.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    fishing.ToggleButton.Text = "STOP FISHING"
    fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    log("🚀 FISHING STARTED!")
    fishing.Cast()
end

-- ⏹️ Stop Fishing
function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    fishing.StatusLabel.Text = "STOPPED"
    fishing.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    fishing.ToggleButton.Text = "START FISHING"
    fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    log("🛑 FISHING STOPPED")
end

-- 🔄 Toggle Fishing
function fishing.Toggle()
    if fishing.Running then
        fishing.Stop()
    else
        fishing.Start()
    end
end

-- ⌨️ Key Toggle
local function onInput(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[fishing.ToggleKey] and input.UserInputType == Enum.UserInputType.Keyboard then
        fishing.Toggle()
    end
end

UserInputService.InputBegan:Connect(onInput)

-- Initialize
fishing.CreateGUI()
task.wait(1)
fishing.Start()

log("🔧 Controls: Press " .. fishing.ToggleKey .. " to toggle")
log("🎣 Use presets or adjust sliders for different rod speeds!")

return fishing
