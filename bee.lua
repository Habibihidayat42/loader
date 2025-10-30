-- Fish It Hub Dasar by Grok (Compatible with Delta)
-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Fish It Hub v1.0",
   LoadingTitle = "Loading Dasar Script...",
   LoadingSubtitle = "by Grok | Inspired by Chiyo/Atomic",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "FishItHub",
      FileName = "Config"
   },
   KeySystem = false -- No key needed
})

-- Tab Utama
local MainTab = Window:CreateTab("Fishing", 4483362458)

local Section1 = MainTab:CreateSection("Fitur Farming")

-- Auto Farm Toggle
local AutoFarmToggle = MainTab:CreateToggle({
   Name = "Auto Farm (Cast & Reel)",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
      getgenv().AutoFarmEnabled = Value
      if Value then
         spawn(function()
            while getgenv().AutoFarmEnabled and task.wait(1) do
               local player = game.Players.LocalPlayer
               local char = player.Character
               if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                  -- Cari fishing rod
                  local tool = nil
                  for _, item in pairs(player.Backpack:GetChildren()) do
                     if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fishing")) then
                        tool = item
                        break
                     end
                  end
                  
                  if not tool and char:FindFirstChildOfClass("Tool") then
                     tool = char:FindFirstChildOfClass("Tool")
                  end
                  
                  if tool then
                     -- Equip tool
                     if char:FindFirstChildOfClass("Tool") ~= tool then
                        player.Character.Humanoid:EquipTool(tool)
                        task.wait(0.5)
                     end
                     
                     -- Cast fishing
                     tool:Activate()
                     
                     -- Tunggu dan cek bobber
                     local startTime = tick()
                     local bobberFound = false
                     
                     while tick() - startTime < 10 and getgenv().AutoFarmEnabled do
                        task.wait(0.5)
                        -- Cari bobber di workspace
                        for _, obj in pairs(workspace:GetChildren()) do
                           if obj.Name == "Bobber" and obj:FindFirstChild("Owner") and obj.Owner.Value == player then
                              bobberFound = true
                              -- Tunggu sampai ada fish
                              if obj:FindFirstChild("FishCaught") and obj.FishCaught.Value == true then
                                 -- Reel in
                                 tool:Activate()
                                 task.wait(1)
                                 break
                              end
                           end
                        end
                        if bobberFound then break end
                     end
                     
                     -- Jika tidak ada bobber dalam 10 detik, reel anyway
                     if not bobberFound then
                        tool:Activate()
                     end
                     
                     task.wait(1)
                  end
               end
            end
         end)
      end
   end,
})

-- Auto Sell Toggle
local AutoSellToggle = MainTab:CreateToggle({
   Name = "Auto Sell Fish",
   CurrentValue = false,
   Flag = "AutoSell",
   Callback = function(Value)
      getgenv().AutoSellEnabled = Value
      if Value then
         spawn(function()
            while getgenv().AutoSellEnabled and task.wait(3) do
               pcall(function()
                  -- Coba berbagai remote event yang biasa digunakan di fishing games
                  local remotes = {
                     "SellAllFish",
                     "SellFish",
                     "Sell",
                     "SellAll",
                     "TradeFish"
                  }
                  
                  for _, remoteName in pairs(remotes) do
                      pcall(function()
                         game:GetService("ReplicatedStorage").Remotes[remoteName]:FireServer()
                      end)
                  end
               end)
            end
         end)
      end
   end,
})

-- Auto Upgrade Toggle
local AutoUpgradeToggle = MainTab:CreateToggle({
   Name = "Auto Upgrade Rod",
   CurrentValue = false,
   Flag = "AutoUpgrade",
   Callback = function(Value)
      getgenv().AutoUpgradeEnabled = Value
      if Value then
         spawn(function()
            while getgenv().AutoUpgradeEnabled and task.wait(5) do
               pcall(function()
                  -- Coba upgrade rod
                  local remotes = {
                     "UpgradeRod",
                     "Upgrade",
                     "UpgradeTool"
                  }
                  
                  for _, remoteName in pairs(remotes) do
                      pcall(function()
                         game:GetService("ReplicatedStorage").Remotes[remoteName]:FireServer()
                      end)
                  end
               end)
            end
         end)
      end
   end,
})

local Section2 = MainTab:CreateSection("Player Modifications")

-- Speed Slider
local SpeedSlider = MainTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      getgenv().WalkSpeedValue = Value
      local player = game.Players.LocalPlayer
      local char = player.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.WalkSpeed = Value
      end
      
      -- Auto apply ketika respawn
      player.CharacterAdded:Connect(function(character)
         task.wait(1)
         if character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue or 16
         end
      end)
   end,
})

-- Jump Power Slider
local JumpSlider = MainTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      getgenv().JumpPowerValue = Value
      local player = game.Players.LocalPlayer
      local char = player.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.JumpPower = Value
      end
      
      player.CharacterAdded:Connect(function(character)
         task.wait(1)
         if character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = getgenv().JumpPowerValue or 50
         end
      end)
   end,
})

-- Infinite Jump Toggle
local InfJumpToggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      getgenv().InfJumpEnabled = Value
   end,
})

-- Apply Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
   if getgenv().InfJumpEnabled then
      local player = game.Players.LocalPlayer
      local char = player.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid:ChangeState("Jumping")
      end
   end
end)

local Section3 = MainTab:CreateSection("Teleports")

-- Teleport to Fishing Spot
local TeleportFishingButton = MainTab:CreateButton({
   Name = "Teleport to Best Fishing Spot",
   Callback = function()
      local player = game.Players.LocalPlayer
      local char = player.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         -- Cari area fishing terbaik (biasanya dekat air)
         local bestSpot = nil
         for _, part in pairs(workspace:GetChildren()) do
            if part:IsA("Part") and part.Name:lower():find("water") or part.Name:lower():find("lake") or part.Name:lower():find("river") then
               bestSpot = part.Position + Vector3.new(0, 5, 0)
               break
            end
         end
         
         if not bestSpot then
            -- Default spot jika tidak ditemukan
            bestSpot = Vector3.new(0, 20, 0)
         end
         
         char.HumanoidRootPart.CFrame = CFrame.new(bestSpot)
      end
   end,
})

-- Teleport to Sell Spot
local TeleportSellButton = MainTab:CreateButton({
   Name = "Teleport to Sell Spot",
   Callback = function()
      local player = game.Players.LocalPlayer
      local char = player.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         -- Cari NPC atau tempat jual ikan
         local sellSpot = nil
         for _, npc in pairs(workspace:GetChildren()) do
            if npc:IsA("Model") and (npc.Name:lower():find("npc") or npc.Name:lower():find("merchant") or npc.Name:lower():find("seller")) then
               sellSpot = npc:GetPivot().Position + Vector3.new(0, 3, 0)
               break
            end
         end
         
         if not sellSpot then
            sellSpot = Vector3.new(50, 20, 0) -- Default spot
         end
         
         char.HumanoidRootPart.CFrame = CFrame.new(sellSpot)
      end
   end,
})

-- Anti-AFK Toggle
local AntiAFKToggle = MainTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(Value)
      getgenv().AntiAFKEnabled = Value
      if Value then
         spawn(function()
            while getgenv().AntiAFKEnabled and task.wait(30) do
               pcall(function()
                  local virtualUser = game:GetService("VirtualUser")
                  virtualUser:CaptureController()
                  virtualUser:ClickButton2(Vector2.new())
               end)
            end
         end)
      end
   end,
})

local Section4 = MainTab:CreateSection("Info & Support")
MainTab:CreateParagraph({
   Title = "Cara Penggunaan",
   Content = "1. Pastikan punya fishing rod di inventory\n2. Auto Farm akan otomatis cast dan reel\n3. Auto Sell akan jual ikan setiap 3 detik\n4. Gunakan teleport untuk pindah lokasi"
})

MainTab:CreateParagraph({
   Title = "Troubleshooting",
   Content = "Jika fitur tidak work: \n- Cek F9 untuk error message\n- Pastikan game tidak di-patch\n- Update script jika perlu"
})

-- Load settings ketika character spawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
   task.wait(2)
   if getgenv().WalkSpeedValue then
      character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
   end
   if getgenv().JumpPowerValue then
      character.Humanoid.JumpPower = getgenv().JumpPowerValue
   end
end)

Rayfield:LoadConfiguration() -- Load saved settings
