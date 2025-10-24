-- Fish It Hub v2.1 by Grok (Modern UI + Fixed Auto Farm)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function CreateGUI()
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("FishItHub") then
        LocalPlayer.PlayerGui.FishItHub:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FishItHub"
    gui.Parent = LocalPlayer.PlayerGui
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 420)
    frame.Position = UDim2.new(0.65, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Parent = gui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 255, 150)
    stroke.Thickness = 1.2

    -- Header
    local titleBar = Instance.new("Frame", frame)
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Text = "🎣 Fish It Hub v2.1"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 10, 0, 0)

    local minimize = Instance.new("TextButton", titleBar)
    minimize.Size = UDim2.new(0, 45, 1, 0)
    minimize.Position = UDim2.new(1, -45, 0, 0)
    minimize.Text = "-"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 24
    minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimize.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 10)

    -- Scroll area
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 1, -45)
    scroll.Position = UDim2.new(0, 0, 0, 45)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)

    -- Auto update scroll
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    -- Drag Logic
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Minimize
    local minimized = false
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        minimize.Text = minimized and "+" or "-"
        scroll.Visible = not minimized
        frame.Size = minimized and UDim2.new(0, 240, 0, 45) or UDim2.new(0, 240, 0, 420)
    end)

    -- Component creators
    local function ripple(button)
        button.MouseButton1Click:Connect(function()
            button.BackgroundTransparency = 0.4
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        end)
    end

    local function CreateButton(text, callback)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.Text = text
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        ripple(btn)
        btn.MouseButton1Click:Connect(callback)
    end

    local function CreateToggle(name, callback)
        local toggle = Instance.new("TextButton", scroll)
        toggle.Size = UDim2.new(1, -10, 0, 40)
        toggle.Text = name .. ": OFF"
        toggle.Font = Enum.Font.Gotham
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        toggle.TextSize = 14
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)
        ripple(toggle)

        local state = false
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = name .. (state and ": ON" or ": OFF")
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(45, 45, 45)
            callback(state)
        end)
    end

    local function CreateSlider(name, min, max, callback)
        local frame = Instance.new("Frame", scroll)
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = name .. ": " .. min
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1

        local slider = Instance.new("Frame", frame)
        slider.Size = UDim2.new(1, 0, 0, 20)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 8)

        local fill = Instance.new("Frame", slider)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

        local dragging = false
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                local value = math.floor(min + (max - min) * percent)
                label.Text = name .. ": " .. value
                callback(value)
            end
        end)
    end

    ----------------------------------------------------------------
    -- 🐟 Fixed Auto Farm Feature
    ----------------------------------------------------------------
    CreateToggle("Auto Farm", function(state)
        getgenv().AutoFarmEnabled = state

        if state then
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "Auto Farm: ON",
                Duration = 3
            })

            task.spawn(function()
                while getgenv().AutoFarmEnabled do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if not char then return end

                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool and tool.Name:lower():find("rod") then
                            tool:Activate()
                            print("[FishItHub] Lempar kail...")
                            task.wait(1)

                            local bobber
                            for i = 1, 5 do
                                if tool:FindFirstChild("Bobbers") and tool.Bobbers:FindFirstChild("Bobber") then
                                    bobber = tool.Bobbers.Bobber
                                    break
                                end
                                task.wait(0.3)
                            end
                            if not bobber then
                                print("[FishItHub] Tidak menemukan Bobber, ulangi...")
                                task.wait(1)
                                return
                            end

                            local timeout = 0
                            while timeout < 10 and getgenv().AutoFarmEnabled do
                                if bobber:FindFirstChild("Fish") and bobber.Fish.Value ~= nil then
                                    print("[FishItHub] Ikan menggigit! Menarik...")
                                    tool:Activate()
                                    task.wait(0.5)
                                    break
                                end
                                task.wait(0.5)
                                timeout += 0.5
                            end

                            task.wait(math.random(1, 2)) -- Natural delay
                        else
                            print("[FishItHub] Tidak ada Rod aktif.")
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "Auto Farm: OFF",
                Duration = 3
            })
        end
    end)

    ----------------------------------------------------------------
    -- 🌊 Other Features
    ----------------------------------------------------------------
    CreateToggle("Auto Sell", function(s)
        getgenv().AutoSellEnabled = s
        if s then
            task.spawn(function()
                while getgenv().AutoSellEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.SellFish:FireServer()
                    end)
                    task.wait(5)
                end
            end)
        end
    end)

    CreateSlider("Walk Speed", 16, 100, function(v)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end)

    CreateButton("Teleport to Spawn", function()
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end)

    StarterGui:SetCore("SendNotification", {
        Title = "Fish It Hub v2.1",
        Text = "Modern UI Loaded & Auto Farm Fixed!",
        Duration = 5
    })
end

CreateGUI()
