-- Fish It Hub v2.0 by Grok (Custom GUI Mobile-Optimized for Delta Android)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Function to Create GUI
local function CreateGUI()
    if LocalPlayer.PlayerGui:FindFirstChild("FishItHub") then
        LocalPlayer.PlayerGui.FishItHub:Destroy()
        print("[FishItHub] Destroying old GUI")
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FishItHub"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = true
    
    -- Main Frame (Mobile-Friendly)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 400)
    Frame.Position = UDim2.new(0.7, 0, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Visible = true
    Frame.Parent = ScreenGui
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.Text = "Fish It Hub v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame
    
    -- Minimize Button (Large for Touch)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 60, 0, 60)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 28
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Parent = Frame
    
    -- ScrollFrame for Features
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, 0, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 50)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.Parent = Frame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = ScrollFrame
    
    -- Minimize Logic
    local isMinimized = false
    MinimizeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isMinimized = not isMinimized
            MinimizeButton.Text = isMinimized and "+" or "-"
            Frame.Size = isMinimized and UDim2.new(0, 200, 0, 60) or UDim2.new(0, 200, 0, 400)
            ScrollFrame.Visible = not isMinimized
            print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "GUI " .. (isMinimized and "Minimized" or "Maximized"),
                Duration = 3
            })
        end
    end)
    
    -- Drag Logic (Touch-Optimized)
    local dragging, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            print("[FishItHub] Drag Started")
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            print("[FishItHub] Drag Ended")
        end
    end)
    
    -- Function to create Toggle Button
    local function CreateToggle(name, callback)
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(1, -10, 0, 45)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        ToggleButton.Text = name .. ": OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 14
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Parent = ScrollFrame
        local state = false
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                ToggleButton.Text = name .. (state and ": ON" or ": OFF")
                ToggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
                callback(state)
                print("[FishItHub] " .. name .. ": " .. (state and "ON" or "OFF"))
            end
        end)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    -- Function to create Button
    local function CreateButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 45)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.Font = Enum.Font.SourceSans
        Button.Parent = ScrollFrame
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                callback()
                print("[FishItHub] " .. name .. " Clicked")
            end
        end)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    -- Function to create Slider
    local function CreateSlider(name, min, max, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -10, 0, 65)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ScrollFrame
    
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 25)
        Label.BackgroundTransparency = 1
        Label.Text = name .. ": " .. min
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.Font = Enum.Font.SourceSans
        Label.Parent = SliderFrame
    
        local Slider = Instance.new("TextButton")
        Slider.Size = UDim2.new(1, -10, 0, 25)
        Slider.Position = UDim2.new(0, 5, 0, 30)
        Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Slider.Text = ""
        Slider.Parent = SliderFrame
    
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        Fill.Parent = Slider
    
        local dragging = false
        Slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        Slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local relativeX = (input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X
                relativeX = math.clamp(relativeX, 0, 1)
                local value = math.floor(min + (max - min) * relativeX)
                Fill.Size = UDim2.new(relativeX, 0, 1, 0)
                Label.Text = name .. ": " .. value
                callback(value)
                print("[FishItHub] " .. name .. ": " .. value)
            end
        end)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    -- Create Toggles/Buttons/Sliders
    CreateToggle("Auto Farm", function(state)
        getgenv().AutoFarmEnabled = state
        if state then
            spawn(function()
                while getgenv().AutoFarmEnabled do
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool and tool.Name:find("Rod") then
                            tool:Activate()
                            wait(2)
                            local bobber = tool:FindFirstChild("Bobbers") and tool.Bobbers:FindFirstChild("Bobber")
                            if bobber and bobber:FindFirstChild("Fish") and bobber.Fish.Value then
                                tool:Activate()
                                wait(0.5)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end)
    
    CreateToggle("Auto Sell", function(state)
        getgenv().AutoSellEnabled = state
        if state then
            spawn(function()
                while getgenv().AutoSellEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.SellFish:FireServer()
                    end)
                    wait(5)
                end
            end)
        end
    end)
    
    CreateSlider("Walk Speed", 16, 100, function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end)
    
    CreateToggle("Infinite Jump", function(state)
        getgenv().InfJumpEnabled = state
        UserInputService.JumpRequest:Connect(function()
            if getgenv().InfJumpEnabled then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState("Jumping")
                end
            end
        end)
    end)
    
    CreateButton("Teleport to Spawn", function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end)
    
    CreateToggle("Anti-AFK", function(state)
        getgenv().AntiAFKEnabled = state
        if state then
            spawn(function()
                while getgenv().AntiAFKEnabled do
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -0.1)
                        wait(60)
                    end
                end
            end)
        end
    end)
    
    CreateToggle("Auto Upgrade", function(state)
        getgenv().AutoUpgradeEnabled = state
        if state then
            spawn(function()
                while getgenv().AutoUpgradeEnabled do
                    pcall(function()
                        local remotes = game:GetService("ReplicatedStorage").Remotes
                        if remotes:FindFirstChild("UpgradeRod") then
                            remotes.UpgradeRod:FireServer()
                        end
                        if remotes:FindFirstChild("UpgradeReel") then
                            remotes.UpgradeReel:FireServer()
                        end
                    end)
                    wait(10)
                end
            end)
        end
    end)
    
    CreateToggle("ESP (Fish/Bobber)", function(state)
        getgenv().ESPEnabled = state
        if state then
            spawn(function()
                while getgenv().ESPEnabled do
                    pcall(function()
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v.Name == "Bobber" or (v:FindFirstChild("Fish") and v.Fish.Value) then
                                local highlight = v:FindFirstChild("Highlight")
                                if not highlight then
                                    highlight = Instance.new("Highlight")
                                    highlight.Name = "Highlight"
                                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                                    highlight.Parent = v
                                end
                            end
                        end
                    end)
                    wait(1)
                end
                -- Cleanup highlights when disabled
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:FindFirstChild("Highlight") then
                        v.Highlight:Destroy()
                    end
                end
            end)
        end
    end)
    
    CreateToggle("Auto Fish Rarity", function(state)
        getgenv().AutoRarityEnabled = state
        if state then
            spawn(function()
                while getgenv().AutoRarityEnabled do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool and tool.Name:find("Rod") then
                                local bobber = tool:FindFirstChild("Bobbers") and tool.Bobbers:FindFirstChild("Bobber")
                                if bobber and bobber:FindFirstChild("Fish") and bobber.Fish.Value then
                                    local fish = bobber.Fish.Value
                                    if fish:FindFirstChild("Rarity") and fish.Rarity.Value == "Rare" or fish.Rarity.Value == "Legendary" then
                                        tool:Activate()
                                        wait(0.5)
                                    end
                                end
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end)
    
    -- Info Label
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -10, 0, 80)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Script by Grok\nTap 2x: Auto Farm\n3x: Auto Sell\n4x: Auto Upgrade\nRight Shift: Toggle\nTap -/+: Minimize\nTap & Drag: Geser"
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.SourceSans
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = ScrollFrame
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    
    print("[FishItHub] GUI Created Successfully")
    return ScreenGui
end

-- Initial Create
local CurrentGUI = CreateGUI()

-- Recreate on Character Added (Respawn Fix)
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    print("[FishItHub] Recreating GUI on Respawn")
    CurrentGUI = CreateGUI()
end)

-- Visibility Check Loop (Anti-Disappear)
spawn(function()
    while true do
        if not LocalPlayer.PlayerGui:FindFirstChild("FishItHub") then
            print("[FishItHub] GUI Missing - Recreating")
            CurrentGUI = CreateGUI()
        end
        wait(5)
    end
end)

-- Toggle GUI Visibility
local guiVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        if CurrentGUI and CurrentGUI:FindFirstChild("Frame") then
            CurrentGUI.Frame.Visible = guiVisible
            print("[FishItHub] GUI Visibility: " .. (guiVisible and "Shown" or "Hidden"))
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "GUI " .. (guiVisible and "Shown" or "Hidden"),
                Duration = 3
            })
        end
    end
end)

-- Fallback Keybinds (Tap 2x/3x/4x)
local tapCount = 0
local lastTap = 0
UserInputService.TouchTap:Connect(function()
    local currentTime = tick()
    if currentTime - lastTap < 0.5 then
        tapCount = tapCount + 1
    else
        tapCount = 1
    end
    lastTap = currentTime
    
    if tapCount == 2 then
        getgenv().AutoFarmEnabled = not getgenv().AutoFarmEnabled
        StarterGui:SetCore("SendNotification", {
            Title = "Fish It Hub",
            Text = "Auto Farm: " .. (getgenv().AutoFarmEnabled and "ON" or "OFF"),
            Duration = 3
        })
        print("[FishItHub] Auto Farm: " .. (getgenv().AutoFarmEnabled and "ON" or "OFF"))
        if getgenv().AutoFarmEnabled then
            spawn(function()
                while getgenv().AutoFarmEnabled do
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool and tool.Name:find("Rod") then
                            tool:Activate()
                            wait(2)
                            local bobber = tool:FindFirstChild("Bobbers") and tool.Bobbers:FindFirstChild("Bobber")
                            if bobber and bobber:FindFirstChild("Fish") and bobber.Fish.Value then
                                tool:Activate()
                                wait(0.5)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    elseif tapCount == 3 then
        getgenv().AutoSellEnabled = not getgenv().AutoSellEnabled
        StarterGui:SetCore("SendNotification", {
            Title = "Fish It Hub",
            Text = "Auto Sell: " .. (getgenv().AutoSellEnabled and "ON" or "OFF"),
            Duration = 3
        })
        print("[FishItHub] Auto Sell: " .. (getgenv().AutoSellEnabled and "ON" or "OFF"))
        if getgenv().AutoSellEnabled then
            spawn(function()
                while getgenv().AutoSellEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.SellFish:FireServer()
                    end)
                    wait(5)
                end
            end)
        end
    elseif tapCount == 4 then
        getgenv().AutoUpgradeEnabled = not getgenv().AutoUpgradeEnabled
        StarterGui:SetCore("SendNotification", {
            Title = "Fish It Hub",
            Text = "Auto Upgrade: " .. (getgenv().AutoUpgradeEnabled and "ON" or "OFF"),
            Duration = 3
        })
        print("[FishItHub] Auto Upgrade: " .. (getgenv().AutoUpgradeEnabled and "ON" or "OFF"))
        if getgenv().AutoUpgradeEnabled then
            spawn(function()
                while getgenv().AutoUpgradeEnabled do
                    pcall(function()
                        local remotes = game:GetService("ReplicatedStorage").Remotes
                        if remotes:FindFirstChild("UpgradeRod") then
                            remotes.UpgradeRod:FireServer()
                        end
                        if remotes:FindFirstChild("UpgradeReel") then
                            remotes.UpgradeReel:FireServer()
                        end
                    end)
                    wait(10)
                end
            end)
        end
    end
end)

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Fish It Hub v2.0 Loaded!",
    Text = "GUI aktif. Tap -/+: Minimize, Tap & Drag: Geser, Tap 2x: Auto Farm, 3x: Auto Sell, 4x: Auto Upgrade. Cek Delta Logs.",
    Duration = 10
})
