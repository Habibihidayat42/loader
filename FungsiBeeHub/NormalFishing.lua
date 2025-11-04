-- 🎣 AUTO CLICK FISHING v1.0 (Human-like version)
-- ⚙️ Simulates legit auto clicking instead of instant minigame calls

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local fishing = {
    Running = false,
    TotalFish = 0,
    ClickDelay = 0.05, -- waktu antar klik cepat
    CastDelay = 0.8,   -- waktu tunggu setelah lempar kail
    BiteDelay = 2.0,   -- waktu tunggu rata-rata sampai tanda "!"
    ToggleKey = Enum.KeyCode.F
}

-----------------------------------------------------------
-- Fungsi Klik Otomatis
-----------------------------------------------------------
local function Click()
    -- Meniru klik kiri mouse
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(fishing.ClickDelay)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-----------------------------------------------------------
-- Fungsi Memancing
-----------------------------------------------------------
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    print("🎣 Auto Click Fishing Started!")

    task.spawn(function()
        while fishing.Running do
            ---------------------------------------------------
            -- 1️⃣ Lempar kail
            ---------------------------------------------------
            Click()
            print("🎯 Cast rod!")
            task.wait(fishing.CastDelay)

            ---------------------------------------------------
            -- 2️⃣ Tunggu ikan menggigit (simulasi tanda '!')
            ---------------------------------------------------
            local randomBite = fishing.BiteDelay + math.random() * 1.5 -- random biar natural
            task.wait(randomBite)

            ---------------------------------------------------
            -- 3️⃣ Klik cepat untuk tarik ikan
            ---------------------------------------------------
            print("⚡ Fish bite detected! Pulling rod...")
            for i = 1, math.random(3, 6) do -- klik cepat beberapa kali
                Click()
                task.wait(fishing.ClickDelay)
            end

            ---------------------------------------------------
            -- 4️⃣ Hitung hasil & loop ulang
            ---------------------------------------------------
            fishing.TotalFish += 1
            print(("🐟 Fish caught! Total: %d"):format(fishing.TotalFish))
            task.wait(math.random(0.3, 0.7)) -- delay natural
        end
    end)
end

function fishing.Stop()
    fishing.Running = false
    print("🛑 Auto Click Fishing Stopped.")
end

-----------------------------------------------------------
-- Toggle Keybind
-----------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == fishing.ToggleKey then
        if fishing.Running then
            fishing.Stop()
        else
            fishing.Start()
        end
    end
end)

print("✅ Auto Click Fishing ready! Press [F] to toggle.")
