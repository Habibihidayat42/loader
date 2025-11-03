-- 🍯 BEE HUB - INSTANT BITE FISHING GUI v32.1
-- GUI dengan tema madu dan lebah
-- 3 Slider: Hook Delay, Fishing Delay, Cancel Delay

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local FishingCore = require(script.Parent.FishingCore)

if _G.FishingGUI then
    _G.FishingGUI:Destroy()
    task.wait(0.1)
end

local FishingGUI = {}

local gui
local StatusLabel
local FishLabel
local ToggleButton

local function log(msg)
    print("[BeeHub GUI] " .. msg)
end

local function createHexagonalSlider(parent, name, settingKey, defaultValue, min, max, yPosition, honeyColor)
    local sliderFrame = Instance.new("Frame", parent)
    sliderFrame.Size = UDim2.new(1, -20, 0, 45)
    sliderFrame.Position = UDim2.new(0, 10, 0, yPosition)
    sliderFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "🍯 " .. name .. ": " .. string.format("%.2fs", defaultValue)
    label.TextColor3 = Color3.fromRGB(139, 69, 19)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderContainer = Instance.new("Frame", sliderFrame)
    sliderContainer.Size = UDim2.new(1, 0, 0, 16)
    sliderContainer.Position = UDim2.new(0, 0, 0, 25)
    sliderContainer.BackgroundColor3 = Color3.fromRGB(205, 133, 63)
    sliderContainer.BorderSizePixel = 0
    Instance.new("UICorner", sliderContainer).CornerRadius = UDim.new(0, 8)

    local sliderBg = Instance.new("Frame", sliderContainer)
    sliderBg.Size = UDim2.new(1, -8, 1, -8)
    sliderBg.Position = UDim2.new(0, 4, 0, 4)
    sliderBg.BackgroundColor3 = Color3.fromRGB(160, 82, 45)
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 6)

    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = honeyColor
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)

    local gradient = Instance.new("UIGradient", fill)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(0.5, honeyColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 165, 32))
    }
    gradient.Rotation = 90

    local honeydrop = Instance.new("Frame", fill)
    honeydrop.Size = UDim2.new(0, 20, 0, 20)
    honeydrop.Position = UDim2.new(1, -10, 0.5, -10)
    honeydrop.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    honeydrop.BorderSizePixel = 0
    Instance.new("UICorner", honeydrop).CornerRadius = UDim.new(1, 0)
    
    local dropGradient = Instance.new("UIGradient", honeydrop)
    dropGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 165, 0))
    }

    local btn = Instance.new("TextButton", sliderBg)
    btn.Size = UDim2.new(1, 0, 2, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    btn.MouseButton1Down:Connect(function()
        local conn
        conn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * rel
                val = math.floor(val * 100) / 100
                fill.Size = UDim2.new(rel, 0, 1, 0)
                label.Text = "🍯 " .. name .. ": " .. string.format("%.2fs", val)
                
                FishingCore.UpdateSettings({[settingKey] = val})
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and conn then
                conn:Disconnect()
            end
        end)
    end)
end

function FishingGUI.Create()
    if gui then gui:Destroy() end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "BeeHubFishingGUI"
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
    _G.FishingGUI = gui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 340, 0, 320)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local mainGradient = Instance.new("UIGradient", mainFrame)
    mainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 193, 37)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(218, 165, 32)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(184, 134, 11))
    }
    mainGradient.Rotation = 135

    local outerBorder = Instance.new("Frame", mainFrame)
    outerBorder.Size = UDim2.new(1, 8, 1, 8)
    outerBorder.Position = UDim2.new(0, -4, 0, -4)
    outerBorder.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
    outerBorder.BorderSizePixel = 0
    outerBorder.ZIndex = 0
    Instance.new("UICorner", outerBorder).CornerRadius = UDim.new(0, 18)

    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(255, 185, 15)
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
    
    local headerGradient = Instance.new("UIGradient", header)
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 165, 0))
    }
    headerGradient.Rotation = 90

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "🐝 BEE HUB 🍯"
    title.TextColor3 = Color3.fromRGB(139, 69, 19)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    
    local subtitle = Instance.new("TextLabel", header)
    subtitle.Size = UDim2.new(1, 0, 0, 15)
    subtitle.Position = UDim2.new(0, 0, 1, -18)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "INSTANT BITE FISHING"
    subtitle.TextColor3 = Color3.fromRGB(101, 51, 0)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11

    local statsFrame = Instance.new("Frame", mainFrame)
    statsFrame.Size = UDim2.new(1, -20, 0, 45)
    statsFrame.Position = UDim2.new(0, 10, 0, 60)
    statsFrame.BackgroundColor3 = Color3.fromRGB(205, 133, 63)
    statsFrame.BorderSizePixel = 0
    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 12)
    
    local statsGradient = Instance.new("UIGradient", statsFrame)
    statsGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(222, 184, 135)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(205, 133, 63))
    }

    StatusLabel = Instance.new("TextLabel", statsFrame)
    StatusLabel.Size = UDim2.new(0.5, -10, 1, 0)
    StatusLabel.Position = UDim2.new(0, 10, 0, 0)
    StatusLabel.Text = "🐝 STOPPED"
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(139, 0, 0)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 15
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    FishLabel = Instance.new("TextLabel", statsFrame)
    FishLabel.Size = UDim2.new(0.5, -10, 1, 0)
    FishLabel.Position = UDim2.new(0.5, 0, 0, 0)
    FishLabel.BackgroundTransparency = 1
    FishLabel.Text = "🎣 Fish: 0"
    FishLabel.TextColor3 = Color3.fromRGB(34, 139, 34)
    FishLabel.Font = Enum.Font.GothamBold
    FishLabel.TextSize = 15
    FishLabel.TextXAlignment = Enum.TextXAlignment.Right

    createHexagonalSlider(mainFrame, "Hook Delay", "HookDelay", 
        FishingCore.Settings.HookDelay, 0.01, 0.25, 115, 
        Color3.fromRGB(255, 215, 0))
    
    createHexagonalSlider(mainFrame, "Fishing Delay", "FishingDelay", 
        FishingCore.Settings.FishingDelay, 0.05, 1.0, 165, 
        Color3.fromRGB(255, 185, 15))
    
    createHexagonalSlider(mainFrame, "Cancel Delay", "CancelDelay", 
        FishingCore.Settings.CancelDelay, 0.01, 0.25, 215, 
        Color3.fromRGB(255, 140, 0))

    ToggleButton = Instance.new("TextButton", mainFrame)
    ToggleButton.Size = UDim2.new(1, -20, 0, 40)
    ToggleButton.Position = UDim2.new(0, 10, 0, 270)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 181, 46)
    ToggleButton.Text = "🐝 START FISHING 🎣"
    ToggleButton.TextColor3 = Color3.fromRGB(101, 51, 0)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.BorderSizePixel = 0
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)
    
    local btnGradient = Instance.new("UIGradient", ToggleButton)
    btnGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 165, 0))
    }
    btnGradient.Rotation = 90
    
    local btnStroke = Instance.new("UIStroke", ToggleButton)
    btnStroke.Color = Color3.fromRGB(139, 69, 19)
    btnStroke.Thickness = 3
    
    ToggleButton.MouseButton1Click:Connect(function()
        FishingCore.Toggle()
    end)

    log("🍯 Bee Hub GUI created successfully")
end

FishingCore.OnStatusChanged = function(isRunning, totalFish)
    if isRunning then
        if StatusLabel then
            StatusLabel.Text = "🐝 BUZZING"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
        end
        if ToggleButton then
            ToggleButton.Text = "🛑 STOP FISHING"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            local btnGradient = ToggleButton:FindFirstChildOfClass("UIGradient")
            if btnGradient then
                btnGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(205, 133, 63)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 82, 45))
                }
            end
        end
        if FishLabel then
            FishLabel.Text = "🎣 Fish: 0"
        end
    else
        if StatusLabel then
            StatusLabel.Text = "🐝 STOPPED"
            StatusLabel.TextColor3 = Color3.fromRGB(139, 0, 0)
        end
        if ToggleButton then
            ToggleButton.Text = "🐝 START FISHING 🎣"
            ToggleButton.TextColor3 = Color3.fromRGB(101, 51, 0)
            local btnGradient = ToggleButton:FindFirstChildOfClass("UIGradient")
            if btnGradient then
                btnGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 165, 0))
                }
            end
        end
    end
end

FishingCore.OnFishCaught = function(totalFish, fishName, weight)
    if FishLabel then
        FishLabel.Text = "🎣 Fish: " .. totalFish
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        FishingCore.Toggle()
    end
end)

FishingGUI.Create()
log("✅ Bee Hub GUI initialized and ready 🍯🐝")

return FishingGUI
