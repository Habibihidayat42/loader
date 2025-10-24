-- Fish It Hub v1.4 by Grok (Minimize + Draggable GUI for Delta)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
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
    
    -- Main Frame
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 400)
    Frame.Position = UDim2.new(0.7, 0, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Visible = true
    Frame.Parent = ScreenGui
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.Text = "Fish It Hub v1.4"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizeButton.Position = UDim2.new(1, -40, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Parent = Frame
    
    -- Scrolling Frame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, 0, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 50)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.Parent = Frame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollFrame
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Minimize Logic
    local isMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        MinimizeButton.Text = isMinimized and "+" or "-"
        Frame.Size = isMinimized and UDim2.new(0, 300, 0, 50) or UDim2.new(0, 300, 0, 400)
        ScrollFrame.Visible = not isMinimized
        print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
    end)
    
    -- Drag Logic
    local dragging, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Function to create Toggle Button
    local function CreateToggle(name, callback)
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(1, -10, 0, 40)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        ToggleButton.Text = name .. ": OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 16
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Parent = ScrollFrame
        local state = false
        ToggleButton.MouseButton1Click:Connect(function()
            state = not state
            ToggleButton.Text = name .. (state and ": ON" or ": OFF")
            ToggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
            callback(state)
        end)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    -- Function to create Button
    local function CreateButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 40)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 16
        Button.Font = Enum.Font.SourceSans
        Button.Parent = ScrollFrame
        Button.MouseButton1Click:Connect(callback)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    -- Function to create Slider
    local function CreateSlider(name, min, max, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -10, 0, 60)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ScrollFrame
    
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Text = name .. ": " .. min
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 16
        Label.Font = Enum.Font.SourceSans
        Label.Parent = SliderFrame
    
        local Slider = Instance.new("TextButton")
        Slider.Size = UDim2.new(1, -10, 0, 20)
        Slider.Position = UDim2.new(0, 5, 0, 25)
        Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Slider.Text = ""
        Slider.Parent = SliderFrame
    
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        Fill.Parent = Slider
    
        local dragging = false
        Slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        Slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = (input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X
                relativeX = math.clamp(relativeX, 0, 1)
                local value = math.floor(min + (max - min) * relativeX)
                Fill.Size = UDim2.new(relativeX, 0, 1, 0)
                Label.Text = name .. ": " .. value
                callback(value)
            end
        end)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    -- Create Toggles/Buttons/Sliders
    CreateToggle("Auto Farm (Cast & Reel)", function(state)
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
    
    CreateToggle("Auto Sell Fish", function(state)
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
    
    -- Info Label
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -10, 0, 60)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Script by Grok\nCek console (F9) untuk debug\nToggle: Right Shift\nMinimize: -/+ Button"
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextSize = 14
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
        end
    end
end)

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Fish It Hub v1.4 Loaded!",
    Text = "GUI aktif. Right Shift: toggle, -/+: minimize, Drag: geser. Cek F9 jika error.",
    Duration = 10
})
