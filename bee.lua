--// Library & Services
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Dropbox/main/Kavo.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Flags
local flags = {
    autoFish = false,
    autoSell = false,
    teleportZone = nil
}

--// Lokasi Contoh Teleport
local TeleportLocations = {
    ["Main Island"] = CFrame.new(50, 10, 50),
    ["Fishing Spot 1"] = CFrame.new(100, 10, 200),
    ["NPC Shop"] = CFrame.new(0, 10, 100),
    ["Event Island"] = CFrame.new(300, 10, 400)
}

--// Window Setup
local Window = Library.CreateLib("Fish It GUI - Delta (v3.0)", "DarkTheme")
local MainTab = Window:NewTab("Main")
local TeleportTab = Window:NewTab("Teleport")

local MainSection = MainTab:NewSection("Fishing Automation")
local TeleportSection = TeleportTab:NewSection("Teleport")

--------------------------------------------------------------
-- AUTO FISH — versi diperbaiki total
--------------------------------------------------------------
MainSection:NewToggle("Auto Fish (Stable)", "Tangkap ikan otomatis", function(state)
	flags.autoFish = state

	if state then
		StarterGui:SetCore("SendNotification", {Title = "Fish It", Text = "Auto Fish: ON", Duration = 3})
		spawn(function()
			while flags.autoFish do
				pcall(function()
					local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
					local tool = char:FindFirstChildOfClass("Tool")

					-- pastikan pemain memegang alat pancing
					if not tool or not tool.Name:lower():find("rod") then
						for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
							if t.Name:lower():find("rod") then
								char.Humanoid:EquipTool(t)
								wait(1)
								break
							end
						end
					end

					-- kalau sudah memegang rod, aktifkan lempar
					if tool and tool:FindFirstChild("Bobbers") == nil then
						tool:Activate()
						wait(1.5)
					end

					-- cari bobber di tool
					local bobber
					if tool:FindFirstChild("Bobbers") then
						bobber = tool.Bobbers:FindFirstChild("Bobber")
					end

					if bobber then
						-- tunggu ikan menggigit
						local timeout = 0
						while timeout < 12 and flags.autoFish do
							if bobber:FindFirstChild("Fish") and bobber.Fish.Value ~= nil then
								print("[FishIt] Ikan menggigit, menarik...")
								tool:Activate()
								wait(0.6)
								break
							end
							wait(0.4)
							timeout += 0.4
						end
					end
					wait(1)
				end)
				wait(0.5)
			end
		end)
	else
		StarterGui:SetCore("SendNotification", {Title = "Fish It", Text = "Auto Fish: OFF", Duration = 3})
	end
end)

--------------------------------------------------------------
-- AUTO SELL
--------------------------------------------------------------
MainSection:NewToggle("Auto Sell", "Jual semua ikan otomatis", function(state)
	flags.autoSell = state

	if state then
		spawn(function()
			while flags.autoSell do
				pcall(function()
					local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SellFish")
					if remote then
						remote:FireServer("All")
						print("[FishIt] Jual semua ikan.")
					end
				end)
				wait(5)
			end
		end)
	end
end)

--------------------------------------------------------------
-- TELEPORT
--------------------------------------------------------------
TeleportSection:NewDropdown("Pilih Lokasi", "Pilih tujuan teleport", {"Main Island", "Fishing Spot 1", "NPC Shop", "Event Island"}, function(selected)
	flags.teleportZone = selected
end)

TeleportSection:NewButton("Teleport", "Pindah ke zona terpilih", function()
	if flags.teleportZone and TeleportLocations[flags.teleportZone] then
		HumanoidRootPart.CFrame = TeleportLocations[flags.teleportZone]
		StarterGui:SetCore("SendNotification", {Title = "Fish It", Text = "Teleport ke " .. flags.teleportZone, Duration = 2})
	else
		StarterGui:SetCore("SendNotification", {Title = "Fish It", Text = "Pilih zona dulu!", Duration = 2})
	end
end)

--------------------------------------------------------------
-- RESET CHARACTER LISTENER
--------------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)
