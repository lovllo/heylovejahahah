-- ===== Fox Antartika Final Loader =====
local player = game.Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Fox Antartika",
    LoadingTitle = "Fox Loader",
    LoadingSubtitle = "Antartika Final",
    ShowText = "Fox Script",
    Theme = "Ocean",
    ToggleUIKeybind = Enum.KeyCode.K,
    KeySystem = false,
    ConfigurationSaving = { Enabled = true, FolderName = "FoxConfigs", FileName = "FoxConfig" }
})

-- Tab Antartika
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
    Vector3.new(11002, 555, 128)
}

local refillMap = {
    [1] = "Refill1",
    [2] = "Refill2",
    [3] = "Refill3",
    [4] = "Refill4",
    [5] = "Refill5"
}

local totalPositions = #positions

local function TeleportTo(pos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos) + Vector3.new(0,5,0)
    end
end

local function AutoDrink()
    print("Auto minum dijalankan")
end

-- ===== RunSummit persis seperti Pastebin =====
local function RunSummit()
    local data = player:WaitForChild("Expedition Data",10)
    if not data then warn("Expedition Data not found") return end
    local coins = data:FindFirstChild("Coins")
    local lastCoin = coins and coins.Value or 0

    currentPos = 1
    TeleportTo(positions[currentPos])
    Rayfield:Notify({Title="Antartika", Content="Mulai posisi "..currentPos.." / "..totalPositions, Duration=2})

    while running do
        local now = tick()

        -- Auto minum setiap 30 detik
        if now - lastDrink >= 30 then
            AutoDrink()
            lastDrink = now
        end

        -- Auto refill setiap 3 menit
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

        -- Cek coin dan update posisi
        if coins and coins.Value > lastCoin then
            lastCoin = coins.Value
            if currentPos >= totalPositions then
                TeleportTo(Vector3.new(10952, 313, 122)) -- respawn di summit
                pcall(function() if player.Character then player.Character:BreakJoints() end end)
                player.CharacterAdded:Wait()
                task.wait(1)
                currentPos = 1
                TeleportTo(positions[currentPos])
            else
                currentPos = currentPos + 1
                TeleportTo(positions[currentPos])
            end
            Rayfield:Notify({Title="Antartika Progress", Content="Pos "..currentPos.." / "..totalPositions, Duration=2})
        end

        -- Pola maju-mundur tiap posisi (sama persis Pastebin)
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

-- Tombol Start / Stop RunSummit
antartikaTab:CreateButton({
    Name="Start RunSummit",
    Callback=function()
        if running then return end
        running = true
        task.spawn(RunSummit)
        Rayfield:Notify({Title="Antartika", Content="✅ RunSummit dimulai!", Duration=4})
    end
})
antartikaTab:CreateButton({
    Name="Stop RunSummit",
    Callback=function()
        running = false
        Rayfield:Notify({Title="Antartika", Content="⛔ RunSummit dihentikan!", Duration=4})
    end
})

-- Tombol teleport langsung Pos 1–5 (AMAN)
for i, pos in ipairs(positions) do
    antartikaTab:CreateButton({
        Name = "Teleport Pos "..i,
        Callback = function()
            TeleportTo(pos)
            Rayfield:Notify({Title="Antartika Teleport", Content="✅ Teleported to Pos "..i, Duration=2})
        end
    })
end

Rayfield:LoadConfiguration()
