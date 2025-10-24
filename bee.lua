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
local MainTab = Window:CreateTab("Fishing", 4483362458) -- Icon ID for fishing rod

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
            while getgenv().AutoFarmEnabled do
               local player = game.Players.LocalPlayer
               local char = player.Character
               if char then
                  local tool = char:FindFirstChildOfClass("Tool")
                  if tool and tool.Name:find("Rod") then -- Asumsi tool adalah rod
                     -- Cast line
                     tool:Activate()
                     wait(2) -- Wait for potential bite
                     
                     -- Check if fish caught (bite detected)
                     local bobber = tool:FindFirstChild("Bobbers") and tool.Bobbers:FindFirstChild("Bobber")
                     if bobber and bobber:FindFirstChild("Fish") and bobber.Fish.Value then
                        -- Reel in
                        tool:Activate()
                        wait(0.5)
                     end
                  end
               end
               wait(1) -- Loop delay
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
            while getgenv().AutoSellEnabled do
               -- Fire remote to sell (sesuaikan path remote jika beda)
               pcall(function()
                  game:GetService("ReplicatedStorage").Remotes.SellFish:FireServer() -- Asumsi remote name
               end)
               wait(5) -- Sell every 5 sec
            end
         end)
      end
   end,
})

-- Speed Slider
local SpeedSlider = MainTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 100},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      local char = game.Players.LocalPlayer.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.WalkSpeed = Value
      end
   end,
})

-- Infinite Jump Toggle
local InfJumpToggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      getgenv().InfJumpEnabled = Value
      local UserInputService = game:GetService("UserInputService")
      local player = game.Players.LocalPlayer
      UserInputService.JumpRequest:Connect(function()
         if getgenv().InfJumpEnabled then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
               char.Humanoid:ChangeState("Jumping")
            end
         end
      end)
   end,
})

-- Teleport Button
local TeleportButton = MainTab:CreateButton({
   Name = "Teleport to Spawn",
   Callback = function()
      local player = game.Players.LocalPlayer
      local char = player.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0) -- Koordinat spawn default, sesuaikan jika perlu
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
            while getgenv().AntiAFKEnabled do
               local char = game.Players.LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -0.1) -- Gerak kecil
                  wait(60) -- Setiap 1 menit
               end
            end
         end)
      end
   end,
})

local Section2 = MainTab:CreateSection("Info")
MainTab:CreateParagraph({
   Title = "Catatan",
   Content = "Script dasar ini siap pakai. Jika fitur tidak jalan, cek remote events di game (F9 console). Update script jika game patch."
})

-- Destroy GUI on close
Rayfield:Destroy()
