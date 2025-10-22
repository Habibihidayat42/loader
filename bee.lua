-- =====================================================
-- Bee Hub - Project Tugas Kuliah untuk Fish It (Roblox)
-- Dibuat oleh: Bee - Untuk Delta Executor
-- Features: Speed, Jump, Fly, ESP Players, Teleport, Auto Fish (Blatant/Legit + Kualitas)
-- Fleksibel untuk rod apa saja, optimized untuk Floral Bait
-- UI: Rayfield Library (Populer & Stabil di Delta)
-- Auto Farm Dihapus
-- =====================================================

-- Load Rayfield UI Library
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then
    warn("Failed to load Rayfield library: " .. tostring(Rayfield))
    return
end

-- Buat Window Utama
local Window = Rayfield:CreateWindow({
   Name = "Bee Hub v1.8 (Fish It Auto Fish - Fleksibel Rod)",
   LoadingTitle = "Loading Bee Hub...",
   LoadingSubtitle = "by Bee",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "BeeHub",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Fungsi Auto-Equip Tool (Fleksibel untuk rod apa saja)
local function equipTool()
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack
    local tool = backpack:FindFirstChildOfClass("Tool")
    if tool then
        local success, err = pcall(function()
            tool.Parent = player.Character
            wait(0.7) -- Delay untuk pastikan equip
        end)
        if success then
            return tool
        else
            warn("Failed to equip tool: " .. err)
            return nil
        end
    else
        warn("No tool found in backpack!")
    end
    return nil
end

-- Tab 1: Movement
local MovementTab = Window:CreateTab("Movement", 4483362458)

local SpeedSlider = MovementTab:CreateSlider({
   Name = "Player Speed",
   Range = {16, 500},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      local success, err = pcall(function()
         local char = game.Players.LocalPlayer.Character
         if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
         end
      end)
      if not success then
         warn("Speed error: " .. err)
      end
   end,
})

local JumpSlider = MovementTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 500},
   Increment = 1,
   Suffix = " Jump",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
      local success, err = pcall(function()
         local char = game.Players.LocalPlayer.Character
         if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
         end
      end)
      if not success then
         warn("Jump error: " .. err)
      end
   end,
})

local FlyToggle = MovementTab:CreateToggle({
   Name = "Fly (Noclip Style)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      local success, err = pcall(function()
         _G.FlyEnabled = Value
         local player = game.Players.LocalPlayer
         local char = player.Character or player.CharacterAdded:Wait()
         local humanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
         
         if Value then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = humanoidRootPart
            
            spawn(function()
               while _G.FlyEnabled do
                  local cam = workspace.CurrentCamera.CFrame
                  bodyVelocity.Velocity = (cam.LookVector * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) and 50 or 0)) +
                                          (cam.LookVector * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) and -50 or 0)) +
                                          (Vector3.new(0,1,0) * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) and 50 or 0)) +
                                          (Vector3.new(0,-1,0) * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) and 50 or 0))
                  wait()
               end
               bodyVelocity:Destroy()
            end)
         end
      end)
      if not success then
         warn("Fly error: " .. err)
      end
   end,
})

-- Tab 2: Visuals
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local ESPToggle = VisualsTab:CreateToggle({
   Name = "Player ESP (Box + Name)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      local success, err = pcall(function()
         _G.ESPEnabled = Value
         if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
               if player ~= game.Players.LocalPlayer and player.Character then
                  local esp = Instance.new("BillboardGui")
                  esp.Parent = player.Character:FindFirstChild("Head")
                  esp.Size = UDim2.new(0, 200, 0, 50)
                  esp.StudsOffset = Vector3.new(0, 2, 0)
                  
                  local nameLabel = Instance.new("TextLabel")
                  nameLabel.Parent = esp
                  nameLabel.Size = UDim2.new(1, 0, 1, 0)
                  nameLabel.BackgroundTransparency = 1
                  nameLabel.Text = player.Name
                  nameLabel.TextColor3 = Color3.new(1, 0, 0)
                  nameLabel.TextStrokeTransparency = 0
                  nameLabel.TextScaled = true
                  nameLabel.Font = Enum.Font.SourceSansBold
               end
            end
         else
            for _, obj in pairs(workspace:GetDescendants()) do
               if obj:IsA("BillboardGui") and obj:FindFirstChild("TextLabel") then
                  obj:Destroy()
               end
            end
         end
      end)
      if not success then
         warn("ESP error: " .. err)
      end
   end,
})

-- Tab 3: Teleport
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

local PlayerList = {}
for _, player in pairs(game.Players:GetPlayers()) do
   table.insert(PlayerList, player.Name)
end

local TeleportDropdown = TeleportTab:CreateDropdown({
   Name = "Teleport to Player",
   Options = PlayerList,
   CurrentOption = "Select Player",
   MultipleOptions = false,
   Flag = "TeleportDropdown",
   Callback = function(Option)
      local success, err = pcall(function()
         local targetPlayer = game.Players:FindFirstChild(Option)
         if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({
               Title = "Teleported!",
               Content = "To " .. Option,
               Duration = 3,
               Image = 4483362458,
            })
         end
      end)
      if not success then
         warn("Teleport error: " .. err)
      end
   end,
})

-- Auto-refresh player list
game.Players.PlayerAdded:Connect(function()
   wait(1)
   Rayfield:LoadConfiguration()
end)

-- Tab 4: Auto Features (Hanya Auto Fish)
local AutoTab = Window:CreateTab("Auto Features", 4483362458)

-- Auto Fish Mode Dropdown
local AutoFishMode = "Legit"
local AutoFishModeDropdown = AutoTab:CreateDropdown({
   Name = "Auto Fish Mode",
   Options = {"Blatant", "Legit"},
   CurrentOption = "Legit",
   Flag = "AutoFishMode",
   Callback = function(Option)
      local success, err = pcall(function()
         AutoFishMode = Option
         Rayfield:Notify({
            Title = "Auto Fish Mode Changed",
            Content = "Mode set to: " .. Option,
            Duration = 3,
         })
      end)
      if not success then
         warn("Auto Fish Mode error: " .. err)
      end
   end,
})

-- Auto Fish Quality Dropdown
local AutoFishQuality = "OK"
local AutoFishQualityDropdown = AutoTab:CreateDropdown({
   Name = "Target Fish Quality",
   Options = {"Perfect", "Amazing", "OK", "Poor"},
   CurrentOption = "OK",
   Flag = "AutoFishQuality",
   Callback = function(Option)
      local success, err = pcall(function()
         AutoFishQuality = Option
         Rayfield:Notify({
            Title = "Fish Quality Changed",
            Content = "Targeting: " .. Option,
            Duration = 3,
         })
      end)
      if not success then
         warn("Fish Quality error: " .. err)
      end
   end,
})

-- Auto Fish Toggle (Fleksibel untuk rod apa saja)
local AutoFishToggle = AutoTab:CreateToggle({
   Name = "Auto Fish (Fish It - Fleksibel Rod)",
   CurrentValue = false,
   Flag = "AutoFishToggle",
   Callback = function(Value)
      local success, err = pcall(function()
         _G.AutoFishEnabled = Value
         if not Value then return end
         
         local player = game.Players.LocalPlayer
         local char = player.Character or player.CharacterAdded:Wait()
         local root = char:WaitForChild("HumanoidRootPart", 5)
         if not root then
            warn("No HumanoidRootPart found!")
            _G.AutoFishEnabled = false
            Rayfield:Notify({
               Title = "Auto Fish Error",
               Content = "Character not loaded! Please respawn.",
               Duration = 5,
            })
            return
         end
         
         local tool = char:FindFirstChildOfClass("Tool") or equipTool()
         if not tool then
            warn("No fishing tool found in character or backpack!")
            _G.AutoFishEnabled = false
            Rayfield:Notify({
               Title = "Auto Fish Error",
               Content = "No fishing tool found! Check backpack for fishing rod.",
               Duration = 5,
            })
            return
         end
         
         Rayfield:Notify({
            Title = "Auto Fish Started",
            Content = "Using tool: " .. tool.Name .. ", Mode: " .. AutoFishMode .. ", Quality: " .. AutoFishQuality,
            Duration = 5,
         })
         
         spawn(function()
            while _G.AutoFishEnabled do
               if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                  warn("Character lost! Stopping Auto Fish.")
                  _G.AutoFishEnabled = false
                  Rayfield:Notify({
                     Title = "Auto Fish Stopped",
                     Content = "Character not found! Please respawn.",
                     Duration = 5,
                  })
                  break
               end
               
               -- Pastikan tool masih ada
               if not char:FindFirstChildOfClass("Tool") then
                  tool = equipTool()
                  if not tool then
                     warn("No fishing tool equipped!")
                     _G.AutoFishEnabled = false
                     Rayfield:Notify({
                        Title = "Auto Fish Error",
                        Content = "Tool unequipped! Check backpack for fishing rod.",
                        Duration = 5,
                     })
                     break
                  end
               end
               
               if AutoFishMode == "Blatant" then
                  -- Blatant: Cari Floral Bait atau fish-related object
                  local foundTarget = false
                  for _, obj in pairs(workspace:GetDescendants()) do
                     if obj:IsA("Part") and (obj.Name == "Floral Bait" or obj.Name:lower():match("fish")) then
                        root.CFrame = obj.CFrame + Vector3.new(0, 3, 0) -- Offset agar tidak stuck
                        tool:Activate()
                        wait(0.1)
                        tool:Activate()
                        foundTarget = true
                        Rayfield:Notify({
                           Title = "Fish Targeted!",
                           Content = "Teleported to: " .. obj.Name,
                           Duration = 3,
                        })
                        wait(0.3)
                     end
                  end
                  if not foundTarget then
                     tool:Activate()
                     wait(0.3)
                     tool:Activate()
                     Rayfield:Notify({
                        Title = "No Target Found",
                        Content = "Casting anyway...",
                        Duration = 3,
                     })
                     wait(0.7)
                  end
               else
                  -- Legit: Simulasi cast dan deteksi bite untuk Fish It
                  tool:Activate()
                  local biteDetected = false
                  local startTime = tick()
                  local maxWait = AutoFishQuality == "Perfect" and 1 or
                                  AutoFishQuality == "Amazing" and 2 or
                                  AutoFishQuality == "OK" and 3 or 5
                  
                  while tick() - startTime < maxWait and _G.AutoFishEnabled do
                     for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Part") and obj.Name == "Floral Bait" then
                           local velocity = obj.Velocity.Magnitude
                           if velocity > 0.015 then -- Sensitivitas lebih rendah untuk Fish It
                              biteDetected = true
                              Rayfield:Notify({
                                 Title = "Bite Detected!",
                                 Content = "Floral Bait moving! Velocity: " .. velocity,
                                 Duration = 3,
                              })
                              break
                           end
                        elseif obj:IsA("ProximityPrompt") and obj.Parent.Name:lower():match("fish") then
                           fireproximityprompt(obj)
                           biteDetected = true
                           Rayfield:Notify({
                              Title = "Bite Detected!",
                              Content = "Proximity prompt triggered",
                              Duration = 3,
                           })
                           break
                        end
                     end
                     if biteDetected then break end
                     wait(0.02) -- Cek lebih cepat untuk responsivitas
                  end
                  
                  if biteDetected then
                     local reelDelay = AutoFishQuality == "Perfect" and 0.02 or
                                      AutoFishQuality == "Amazing" and 0.08 or
                                      AutoFishQuality == "OK" and 0.2 or 0.4
                     wait(reelDelay)
                     tool:Activate()
                     Rayfield:Notify({
                        Title = "Fish Caught!",
                        Content = "Quality: " .. AutoFishQuality,
                        Duration = 3,
                     })
                  else
                     warn("No bite detected, recasting...")
                     Rayfield:Notify({
                        Title = "No Bite",
                        Content = "Recasting...",
                        Duration = 3,
                     })
                     tool:Activate()
                  end
                  wait(1 + math.random(0.5, 1.5))
               end
            end
         end)
      end)
      if not success then
         warn("Auto Fish error: " .. err)
         _G.AutoFishEnabled = false
         Rayfield:Notify({
            Title = "Auto Fish Error",
            Content = "Error: " .. err,
            Duration = 5,
         })
      end
   end,
})

-- Notifikasi Selamat Datang
Rayfield:Notify({
   Title = "Bee Hub v1.8 Loaded!",
   Content = "Auto Fish fleksibel untuk rod apa saja! Check backpack jika error.",
   Duration = 5,
   Image = 4483362458,
})

print("Bee Hub v1.8 Loaded Successfully!")
