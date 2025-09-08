-- === Load Rayfield ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- === Buat Window Utama ===
local Window = Rayfield:CreateWindow({
    Name = "Fox",
    Icon = 0,
    LoadingTitle = "Fox Loader",
    LoadingSubtitle = "by Fox",
    ShowText = "Fox Script",
    Theme = "Ocean",
    ToggleUIKeybind = Enum.KeyCode.K,
    DisableRayfieldPrompts = true,
    KeySystem = false,
    KeySettings = {},
    ConfigurationSaving = { 
        Enabled = true, 
        FolderName = "FoxConfigs", 
        FileName = "FoxConfig" 
    }
})

-- === Tab Arunika V2 ===
local arunikaTab = Window:CreateTab("Arunika V2", 4483362458)

-- Tombol Run Auto Arunika
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

-- === DAUN V2 ===
local RunDaunV2ButtonEnabled = true
CreateMenuButton(arunikaTab, "Auto Walk Daun V2", function()
    if not RunDaunV2ButtonEnabled then
        Rayfield:Notify({
            Title = "Run Walk Daun",
            Content = "⚠️ Fitur ini sudah dijalankan / dikunci!",
            Duration = 4
        })
        return
    end

    loadstring(game:HttpGet("https://raw.githubusercontent.com/lovllo/howtoforgetyou/main/dan.lua"))()

    Rayfield:Notify({
        Title = "Run Walk Daun",
        Content = "✅ Script berhasil dijalankan!",
        Duration = 4
    })

    RunDaunV2ButtonEnabled = false
end)

-- === Tab Antartika ===
local antartikaTab = Window:CreateTab("Antartika", 4483362458)

-- Variabel untuk kontrol RunSummit
local running = false
local lastDrink = 0
local lastRefill = 0
local currentPos = 1
local player = game:GetService("Players").LocalPlayer

-- Fungsi RunSummit
local function RunSummit()
    local data = player:WaitForChild("Expedition Data", 10)
    if not data then
        warn("Expedition Data not found")
    end
    local coins = data and data:FindFirstChild("Coins")
    local lastCoin = coins and coins.Value or 0

    TeleportTo(positions[currentPos])

    while running do
        local now = tick()

        if now - lastDrink >= 30 then
            AutoDrink()
            lastDrink = now
        end

        if now - lastRefill >= 180 then
            local refillFolder = Workspace:FindFirstChild("Locally_Imported_Parts")
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

        if coins and coins.Value > lastCoin then
            lastCoin = coins.Value
            if currentPos >= #positions then
                TeleportTo(Vector3.new(10952, 313, 122))
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

-- Tombol Start RunSummit
CreateMenuButton(antartikaTab, "Start Antartika Run", function()
    if running then
        Rayfield:Notify({
            Title = "Antartika",
            Content = "⚠️ Sudah berjalan!",
            Duration = 3
        })
        return
    end

    running = true
    Rayfield:Notify({
        Title = "Antartika",
        Content = "✅ RunSummit Antartika dimulai!",
        Duration = 3
    })

    coroutine.wrap(function()
        RunSummit()
    end)()
end)

-- Tombol Stop RunSummit
CreateMenuButton(antartikaTab, "Stop Antartika Run", function()
    if not running then return end
    running = false
    Rayfield:Notify({
        Title = "Antartika",
        Content = "⛔ RunSummit Antartika dihentikan!",
        Duration = 3
    })
end)

-- Load konfigurasi Rayfield
Rayfield:LoadConfiguration()
