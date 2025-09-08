-- ===== Fox Script Loader =====
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Fox",
    LoadingTitle = "Fox Loader",
    LoadingSubtitle = "by Fox",
    ShowText = "Fox Script",
    Theme = "Ocean",
    ToggleUIKeybind = Enum.KeyCode.K,
    KeySystem = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FoxConfigs",
        FileName = "FoxConfig"
    }
})

-- ===== Tab Arunika V2 =====
local arunikaTab = Window:CreateTab("Arunika V2")

arunikaTab:CreateButton({
    Name = "Run Auto Arunika",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lovllo/howtoforgetyou/main/nka.lua"))()
        Rayfield:Notify({
            Title = "Arunika V2",
            Content = "✅ Auto Arunika berhasil dijalankan!",
            Duration = 4
        })
    end
})

-- ===== Tab Daun V2 =====
local daunTab = Window:CreateTab("Daun V2")
local RunDaunV2ButtonEnabled = true

daunTab:CreateButton({
    Name = "Auto Walk Daun V2",
    Callback = function()
        if not RunDaunV2ButtonEnabled then
            Rayfield:Notify({
                Title = "Daun V2",
                Content = "⚠️ Fitur sudah dijalankan!",
                Duration = 4
            })
            return
        end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lovllo/howtoforgetyou/main/dan.lua"))()
        Rayfield:Notify({
            Title = "Daun V2",
            Content = "✅ Script berhasil dijalankan!",
            Duration = 4
        })
        RunDaunV2ButtonEnabled = false
    end
})

-- ===== Tab Antartika =====
local antartikaTab = Window:CreateTab("Antartika")

local running = false
local currentPos = 1
local lastDrink = 0
local lastRefill = 0
local positions = {
    Vector3.new(-3719, 225, 234),
    Vector3.new(1790, 105, -138),
    Vector3.new(5892, 321, -20),
    Vector3.new(8992, 596, 103),
    Vector3.new(11002, 549, 128)
}

local refillMap = {
    [1] = "Refill1",
    [2] = "Refill2",
    [3] = "Refill3",
    [4] = "Refill4",
    [5] = "Refill5"
}

local function TeleportTo(pos)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function AutoDrink()
    -- contoh auto drink
    print("Auto minum dijalankan")
end

local function RunSummit()
    local player = game.Players.LocalPlayer
    local data = player:WaitForChild("Expedition Data",10)
    local coins = data and data:FindFirstChild("Coins")
    local lastCoin = coins and coins.Value or 0

    TeleportTo(positions[currentPos])

    while running do
        local now = tick()

        -- auto minum setiap 30 detik
        if now - lastDrink >= 30 then
            AutoDrink()
            lastDrink = now
        end

        -- auto refill setiap 3 menit
        if now - lastRefill >= 180 then
            local refillFolder = workspace:FindFirstChild("Locally_Imported_Parts")
            if refillFolder then
                local targetRefillName = refillMap[currentPos]
                if targetRefillName and refillFolder:FindFirstChild(targetRefillName) then
                    local prevPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
                    TeleportTo(refillFolder[targetRefillName].Position)
                    task.wait(0.5)
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                        task.wait(0.5)
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
                        task.wait(0.5)
                    end
                    if prevPos then TeleportTo(prevPos) end
                end
            end
            lastRefill = now
        end

        -- cek coin
        if coins and coins.Value > lastCoin then
            lastCoin = coins.Value
            if currentPos >= #positions then
                TeleportTo(Vector3.new(10952,313,122))
                pcall(function() if player.Character then player.Character:BreakJoints() end end)
                player.CharacterAdded:Wait()
                task.wait(1)
                currentPos = 1
                TeleportTo(positions[currentPos])
            else
                currentPos = currentPos + 1
                TeleportTo(positions[currentPos])
            end
        end

        -- pola maju-mundur
        local charHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if charHRP then
            charHRP.CFrame = charHRP.CFrame * CFrame.new(0,0,10)
            task.wait(5)
            TeleportTo(positions[currentPos])
            task.wait(5)
            charHRP.CFrame = charHRP.CFrame * CFrame.new(0,0,10)
            task.wait(5)
            TeleportTo(positions[currentPos])
            task.wait(5)
        else
            task.wait(1)
        end
    end
end

antartikaTab:CreateButton({
    Name = "Start Antartika Run",
    Callback = function()
        running = true
        task.spawn(RunSummit)
        Rayfield:Notify({
            Title = "Antartika",
            Content = "✅ RunSummit dimulai!",
            Duration = 4
        })
    end
})

antartikaTab:CreateButton({
    Name = "Stop Antartika Run",
    Callback = function()
        running = false
        Rayfield:Notify({
            Title = "Antartika",
            Content = "⛔ RunSummit dihentikan!",
            Duration = 4
        })
    end
})

-- ===== Load Configuration =====
Rayfield:LoadConfiguration()
