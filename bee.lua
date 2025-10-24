-- Fish It Hub v1.7 by Grok (Rayfield UI, Mobile-Optimized for Delta Android)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Load Rayfield Library
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    -- Fallback if Rayfield fails to load
    StarterGui:SetCore("SendNotification", {
        Title = "Fish It Hub Error",
        Text = "Rayfield gagal load. Pakai fallback keybinds: Tap 2x Auto Farm, 3x Auto Sell.",
        Duration = 10
    })
    print("[FishItHub] Rayfield failed to load: " .. tostring(Rayfield))
    
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

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "Fish It Hub v1.7",
    LoadingTitle = "Loading Mobile GUI...",
    LoadingSubtitle = "by Grok | Android Optimized",
    ConfigurationSaving = {
        Enabled = false, -- Disable config save to avoid Android issues
        FolderName = nil,
        FileName = nil
    },
    KeySystem = false
})

-- Make Window Draggable (Custom for Touch)
local Frame = Window.ScreenGui:FindFirstChild("Main") -- Rayfield's main frame
if Frame then
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
end

-- Main Tab
local MainTab = Window:CreateTab("Fishing", 4483362458)

-- Minimize Button
local isMinimized = false
MainTab:CreateButton({
    Name = "Minimize/Maximize",
    Callback = function()
        isMinimized = not isMinimized
        if Frame then
            Frame.Size = isMinimized and UDim2.new(0, 200, 0, 50) or UDim2.new(0, 200, 0, 350)
            Frame:FindFirstChild("MainFrame").Visible = not isMinimized -- Hide content when minimized
            print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "GUI " .. (isMinimized and "Minimized" or "Maximized"),
                Duration = 3
            })
        end
    end,
})

-- Auto Farm Toggle
MainTab:CreateToggle({
    Name = "Auto Farm (Cast & Reel)",
    CurrentValue = false,
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
    end,
})

-- Auto Sell Toggle
MainTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
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
    end,
})

-- Teleport Button
MainTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            print("[FishItHub] Teleport to Spawn")
        end
    end,
})

-- Anti-AFK Toggle
MainTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
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
    end,
})

-- Info Section
MainTab:CreateParagraph({
    Title = "Info",
    Content = "Script by Grok\nTap 2x: Auto Farm, 3x: Auto Sell\nRight Shift: Toggle GUI\nCek Delta Logs jika error"
})

-- Recreate on Character Added (Respawn Fix)
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    print("[FishItHub] Recreating GUI on Respawn")
    Window = Rayfield:CreateWindow({
        Name = "Fish It Hub v1.7",
        LoadingTitle = "Loading Mobile GUI...",
        LoadingSubtitle = "by Grok | Android Optimized",
        KeySystem = false
    })
    -- Re-apply drag logic
    Frame = Window.ScreenGui:FindFirstChild("Main")
    if Frame then
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
    end
    -- Recreate tab and buttons (same as above)
    MainTab = Window:CreateTab("Fishing", 4483362458)
    MainTab:CreateButton({
        Name = "Minimize/Maximize",
        Callback = function()
            isMinimized = not isMinimized
            if Frame then
                Frame.Size = isMinimized and UDim2.new(0, 200, 0, 50) or UDim2.new(0, 200, 0, 350)
                Frame:FindFirstChild("MainFrame").Visible = not isMinimized
                print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
                StarterGui:SetCore("SendNotification", {
                    Title = "Fish It Hub",
                    Text = "GUI " .. (isMinimized and "Minimized" or "Maximized"),
                    Duration = 3
                })
            end
        end,
    })
    MainTab:CreateToggle({
        Name = "Auto Farm (Cast & Reel)",
        CurrentValue = false,
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
        end,
    })
    MainTab:CreateToggle({
        Name = "Auto Sell Fish",
        CurrentValue = false,
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
        end,
    })
    MainTab:CreateButton({
        Name = "Teleport to Spawn",
        Callback = function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                print("[FishItHub] Teleport to Spawn")
            end
        end,
    })
    MainTab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
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
        end,
    })
    MainTab:CreateParagraph({
        Title = "Info",
        Content = "Script by Grok\nTap 2x: Auto Farm, 3x: Auto Sell\nRight Shift: Toggle GUI\nCek Delta Logs jika error"
    })
end)

-- Visibility Check Loop (Anti-Disappear)
spawn(function()
    while true do
        if not LocalPlayer.PlayerGui:FindFirstChild("Rayfield") then
            print("[FishItHub] GUI Missing - Recreating")
            Window = Rayfield:CreateWindow({
                Name = "Fish It Hub v1.7",
                LoadingTitle = "Loading Mobile GUI...",
                LoadingSubtitle = "by Grok | Android Optimized",
                KeySystem = false
            })
            Frame = Window.ScreenGui:FindFirstChild("Main")
            if Frame then
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
            end
            MainTab = Window:CreateTab("Fishing", 4483362458)
            MainTab:CreateButton({
                Name = "Minimize/Maximize",
                Callback = function()
                    isMinimized = not isMinimized
                    if Frame then
                        Frame.Size = isMinimized and UDim2.new(0, 200, 0, 50) or UDim2.new(0, 200, 0, 350)
                        Frame:FindFirstChild("MainFrame").Visible = not isMinimized
                        print("[FishItHub] GUI " .. (isMinimized and "Minimized" or "Maximized"))
                        StarterGui:SetCore("SendNotification", {
                            Title = "Fish It Hub",
                            Text = "GUI " .. (isMinimized and "Minimized" or "Maximized"),
                            Duration = 3
                        })
                    end
                end,
            })
            MainTab:CreateToggle({
                Name = "Auto Farm (Cast & Reel)",
                CurrentValue = false,
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
                end,
            })
            MainTab:CreateToggle({
                Name = "Auto Sell Fish",
                CurrentValue = false,
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
                end,
            })
            MainTab:CreateButton({
                Name = "Teleport to Spawn",
                Callback = function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                        print("[FishItHub] Teleport to Spawn")
                    end
                end,
            })
            MainTab:CreateToggle({
                Name = "Anti-AFK",
                CurrentValue = false,
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
                end,
            })
            MainTab:CreateParagraph({
                Title = "Info",
                Content = "Script by Grok\nTap 2x: Auto Farm, 3x: Auto Sell\nRight Shift: Toggle GUI\nCek Delta Logs jika error"
            })
        end
        wait(5)
    end
end)

-- Toggle GUI Visibility
local guiVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        if Frame then
            Frame.Visible = guiVisible
            print("[FishItHub] GUI Visibility: " .. (guiVisible and "Shown" or "Hidden"))
            StarterGui:SetCore("SendNotification", {
                Title = "Fish It Hub",
                Text = "GUI " .. (guiVisible and "Shown" or "Hidden"),
                Duration = 3
            })
        end
    end
end)

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Fish It Hub v1.7 Loaded!",
    Text = "Rayfield GUI aktif. Tap Minimize/Maximize, Tap & Drag, Tap 2x: Auto Farm, 3x: Auto Sell. Cek Delta Logs.",
    Duration = 10
})
