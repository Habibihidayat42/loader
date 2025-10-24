-- Fish It Hub v1.9 by Grok (Synapse UI Mobile-Optimized for Delta Android)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Load Synapse UI Library
local success, SynapseUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/SynapseTeam/SynapseUI/main/SynapseUI.lua"))()
end)

if not success then
    StarterGui:SetCore("SendNotification", {
        Title = "Fish It Hub Error",
        Text = "Synapse UI gagal load. Pakai tap 2x: Auto Farm, 3x: Auto Sell.",
        Duration = 10
    })
    print("[FishItHub] Synapse UI failed to load: " .. tostring(SynapseUI))
    
    -- Fallback Keybinds (Tap 2x/3x)
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
        end
    end)
    return
end

-- Create Synapse UI Window
local Window = SynapseUI:CreateWindow({
    Title = "Fish It Hub v1.9",
    Size = UDim2.new(0, 200, 0, 350),
    Position = UDim2.new(0.7, 0, 0.1, 0),
    Draggable = true, -- Synapse UI built-in draggable
})

-- Main Tab
local MainTab = Window:CreateTab("Fishing")

-- Minimize Button
local isMinimized = false
MainTab:CreateButton({
    Text = "Minimize/Maximize",
    Callback = function()
        isMinimized = not isMinimized
        local frame = Window:GetFrame()
        if frame then
            frame.Size = isMinimized and UDim2.new(0, 200, 0, 50) or UDim2.new(0, 200, 0, 350)
            frame:FindFirstChild("Content").Visible = not isMinimized
            print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "GUI " .. (isMinimized and "Minimized" or "Maximized"),
                Duration = 3
            })
        end
    end
})

-- Auto Farm Toggle
MainTab:CreateToggle({
    Text = "Auto Farm (Cast & Reel)",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarmEnabled = state
        print("[FishItHub] Auto Farm: " .. (state and "ON" or "OFF"))
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
    end
})

-- Auto Sell Toggle
MainTab:CreateToggle({
    Text = "Auto Sell Fish",
    Default = false,
    Callback = function(state)
        getgenv().AutoSellEnabled = state
        print("[FishItHub] Auto Sell: " .. (state and "ON" or "OFF"))
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
    end
})

-- Walk Speed Slider
MainTab:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
            print("[FishItHub] Walk Speed: " .. value)
        end
    end
})

-- Infinite Jump Toggle
MainTab:CreateToggle({
    Text = "Infinite Jump",
    Default = false,
    Callback = function(state)
        getgenv().InfJumpEnabled = state
        print("[FishItHub] Infinite Jump: " .. (state and "ON" or "OFF"))
        UserInputService.JumpRequest:Connect(function()
            if getgenv().InfJumpEnabled then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState("Jumping")
                end
            end
        end)
    end
})

-- Teleport Button
MainTab:CreateButton({
    Text = "Teleport to Spawn",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            print("[FishItHub] Teleport to Spawn")
        end
    end
})

-- Anti-AFK Toggle
MainTab:CreateToggle({
    Text = "Anti-AFK",
    Default = false,
    Callback = function(state)
        getgenv().AntiAFKEnabled = state
        print("[FishItHub] Anti-AFK: " .. (state and "ON" or "OFF"))
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
    end
})

-- Info Label
MainTab:CreateLabel({
    Text = "Script by Grok\nTap 2x: Auto Farm, 3x: Auto Sell\nRight Shift: Toggle GUI\nCek Delta Logs jika error"
})

-- Recreate on Character Added (Respawn Fix)
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    print("[FishItHub] Recreating GUI on Respawn")
    Window = SynapseUI:CreateWindow({
        Title = "Fish It Hub v1.9",
        Size = UDim2.new(0, 200, 0, 350),
        Position = UDim2.new(0.7, 0, 0.1, 0),
        Draggable = true
    })
    MainTab = Window:CreateTab("Fishing")
    MainTab:CreateButton({
        Text = "Minimize/Maximize",
        Callback = function()
            isMinimized = not isMinimized
            local frame = Window:GetFrame()
            if frame then
                frame.Size = isMinimized and UDim2.new(0, 200, 0, 50) or UDim2.new(0, 200, 0, 350)
                frame:FindFirstChild("Content").Visible = not isMinimized
                print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
                StarterGui:SetCore("SendNotification", {
                    Title = "Fish It Hub",
                    Text = "GUI " .. (isMinimized and "Minimized" or "Maximized"),
                    Duration = 3
                })
            end
        end
    })
    MainTab:CreateToggle({
        Text = "Auto Farm (Cast & Reel)",
        Default = false,
        Callback = function(state)
            getgenv().AutoFarmEnabled = state
            print("[FishItHub] Auto Farm: " .. (state and "ON" or "OFF"))
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
        end
    })
    MainTab:CreateToggle({
        Text = "Auto Sell Fish",
        Default = false,
        Callback = function(state)
            getgenv().AutoSellEnabled = state
            print("[FishItHub] Auto Sell: " .. (state and "ON" or "OFF"))
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
        end
    })
    MainTab:CreateSlider({
        Text = "Walk Speed",
        Min = 16,
        Max = 100,
        Default = 16,
        Callback = function(value)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = value
                print("[FishItHub] Walk Speed: " .. value)
            end
        end
    })
    MainTab:CreateToggle({
        Text = "Infinite Jump",
        Default = false,
        Callback = function(state)
            getgenv().InfJumpEnabled = state
            print("[FishItHub] Infinite Jump: " .. (state and "ON" or "OFF"))
            UserInputService.JumpRequest:Connect(function()
                if getgenv().InfJumpEnabled then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:ChangeState("Jumping")
                    end
                end
            end)
        end
    })
    MainTab:CreateButton({
        Text = "Teleport to Spawn",
        Callback = function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                print("[FishItHub] Teleport to Spawn")
            end
        end
    })
    MainTab:CreateToggle({
        Text = "Anti-AFK",
        Default = false,
        Callback = function(state)
            getgenv().AntiAFKEnabled = state
            print("[FishItHub] Anti-AFK: " .. (state and "ON" or "OFF"))
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
        end
    })
    MainTab:CreateLabel({
        Text = "Script by Grok\nTap 2x: Auto Farm, 3x: Auto Sell\nRight Shift: Toggle GUI\nCek Delta Logs jika error"
    })
end)

-- Toggle GUI Visibility
local guiVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        local frame = Window and Window:GetFrame()
        if frame then
            frame.Visible = guiVisible
            print("[FishItHub] GUI Visibility: " .. (guiVisible and "Shown" or "Hidden"))
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "GUI " .. (guiVisible and "Shown" or "Hidden"),
                Duration = 3
            })
        end
    end
end)

-- Visibility Check Loop (Anti-Disappear)
spawn(function()
    while true do
        if not LocalPlayer.PlayerGui:FindFirstChild("SynapseUI") then
            print("[FishItHub] GUI Missing - Recreating")
            Window = SynapseUI:CreateWindow({
                Title = "Fish It Hub v1.9",
                Size = UDim2.new(0, 200, 0, 350),
                Position = UDim2.new(0.7, 0, 0.1, 0),
                Draggable = true
            })
            MainTab = Window:CreateTab("Fishing")
            MainTab:CreateButton({
                Text = "Minimize/Maximize",
                Callback = function()
                    isMinimized = not isMinimized
                    local frame = Window:GetFrame()
                    if frame then
                        frame.Size = isMinimized and UDim2.new(0, 200, 0, 50) or UDim2.new(0, 200, 0, 350)
                        frame:FindFirstChild("Content").Visible = not isMinimized
                        print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
                        StarterGui:SetCore("SendNotification", {
                            Title = "Fish It Hub",
                            Text = "GUI " .. (isMinimized and "Minimized" or "Maximized"),
                            Duration = 3
                        })
                    end
                end
            })
            MainTab:CreateToggle({
                Text = "Auto Farm (Cast & Reel)",
                Default = false,
                Callback = function(state)
                    getgenv().AutoFarmEnabled = state
                    print("[FishItHub] Auto Farm: " .. (state and "ON" or "OFF"))
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
                end
            })
            MainTab:CreateToggle({
                Text = "Auto Sell Fish",
                Default = false,
                Callback = function(state)
                    getgenv().AutoSellEnabled = state
                    print("[FishItHub] Auto Sell: " .. (state and "ON" or "OFF"))
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
                end
            })
            MainTab:CreateSlider({
                Text = "Walk Speed",
                Min = 16,
                Max = 100,
                Default = 16,
                Callback = function(value)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = value
                        print("[FishItHub] Walk Speed: " .. value)
                    end
                end
            })
            MainTab:CreateToggle({
                Text = "Infinite Jump",
                Default = false,
                Callback = function(state)
                    getgenv().InfJumpEnabled = state
                    print("[FishItHub] Infinite Jump: " .. (state and "ON" or "OFF"))
                    UserInputService.JumpRequest:Connect(function()
                        if getgenv().InfJumpEnabled then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("Humanoid") then
                                char.Humanoid:ChangeState("Jumping")
                            end
                        end
                    end)
                end
            })
            MainTab:CreateButton({
                Text = "Teleport to Spawn",
                Callback = function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                        print("[FishItHub] Teleport to Spawn")
                    end
                end
            })
            MainTab:CreateToggle({
                Text = "Anti-AFK",
                Default = false,
                Callback = function(state)
                    getgenv().AntiAFKEnabled = state
                    print("[FishItHub] Anti-AFK: " .. (state and "ON" or "OFF"))
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
                end
            })
            MainTab:CreateLabel({
                Text = "Script by Grok\nTap 2x: Auto Farm, 3x: Auto Sell\nRight Shift: Toggle GUI\nCek Delta Logs jika error"
            })
        end
        wait(5)
    end
end)

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Fish It Hub v1.9 Loaded!",
    Text = "Synapse UI aktif. Tap Minimize/Maximize, Tap & Drag, Tap 2x: Auto Farm, 3x: Auto Sell. Cek Delta Logs.",
    Duration = 10
})
