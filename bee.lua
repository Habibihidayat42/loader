-- FishIt Hub by ZOKADA (v1.3)
-- Auto Fish sekarang otomatis memakai rod sebelum melempar

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--== CONFIG ==--
local CONFIG = {
	AutoFish = true,
	AutoReel = true,
	FishTimeout = 8,
	AutoCastDelay = 1,
	CastKey = Enum.KeyCode.F,
	ReelKey = Enum.KeyCode.G,
}

local state = {
	isFishing = false,
	lastCastTime = 0,
}

--== FIND REMOTES (opsional) ==--
local CastEvent, ReelEvent
for _,v in pairs(ReplicatedStorage:GetDescendants()) do
	if v:IsA("RemoteEvent") then
		local n = v.Name:lower()
		if n:find("cast") then CastEvent = v end
		if n:find("reel") or n:find("catch") then ReelEvent = v end
	end
end

--== UTILITY ==--
local function equipRod()
	local rod = character:FindFirstChild("FishingRod")
	if not rod then
		local bpRod = player.Backpack:FindFirstChild("FishingRod")
		if bpRod then
			bpRod.Parent = character
			-- tunggu sampai benar-benar ada di tangan
			repeat task.wait() until character:FindFirstChild("FishingRod")
			print("[FishIt] Rod equipped automatically")
			return character:FindFirstChild("FishingRod")
		end
	end
	return rod
end

local function getRod()
	return character:FindFirstChild("FishingRod") or player.Backpack:FindFirstChild("FishingRod")
end

local function castRod()
	local rod = equipRod()
	if not rod then return end

	if CastEvent then
		CastEvent:FireServer()
	else
		pcall(function() rod:Activate() end)
	end
	state.isFishing = true
	state.lastCastTime = tick()
	print("[FishIt] Cast sent!")
end

local function reelIn()
	local rod = getRod()
	if not rod then return end

	if ReelEvent then
		ReelEvent:FireServer()
	else
		pcall(function() rod:Activate() end)
		task.wait(0.4)
		pcall(function() rod:Destroy() end)
	end
	state.isFishing = false
	print("[FishIt] Reel complete!")
end

local function hasFish()
	local rod = character:FindFirstChild("FishingRod")
	return rod and rod:FindFirstChild("Fish")
end

--== AUTO LOOP ==--
task.spawn(function()
	while task.wait(0.2) do
		if CONFIG.AutoFish then
			if not state.isFishing and tick() - state.lastCastTime > CONFIG.AutoCastDelay then
				castRod()
			elseif state.isFishing and hasFish() and CONFIG.AutoReel then
				task.wait(CONFIG.FishTimeout)
				reelIn()
			end
		end
	end
end)

--== MANUAL KEYBINDS ==--
UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == CONFIG.CastKey and not state.isFishing then
		castRod()
	elseif i.KeyCode == CONFIG.ReelKey and state.isFishing then
		reelIn()
	end
end)

print("✅ FishIt Hub Loaded (Auto-Equip + Auto Fish Fix)")
