-- ===== Fox Antartika Loader with Teleport Buttons =====
local player = game.Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Fox Antartika",
    LoadingTitle = "Fox Loader",
    LoadingSubtitle = "Antartika Special",
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

-- Fungsi teleport aman
local function TeleportTo(pos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos) + Vector3.new(0,5,0)
    end
end

-- Tombol Start / Stop
antartikaTab:CreateButton({
    Name = "Start RunSummit",
    Callback = function()
        if running then return end
        running = true
        task.spawn(function()
            while running do
                TeleportTo(positions[currentPos])
                Rayfield:Notify({Title="Antartika", Content="Pos "..currentPos, Duration=2})
                currentPos = currentPos + 1
                if currentPos > #positions then
                    currentPos = 1
                    running = false
                    Rayfield:Notify({Title="Antartika", Content="✅ Sampai summit!", Duration=3})
                end
                task.wait(2) -- delay antar posisi
            end
        end)
    end
})
antartikaTab:CreateButton({
    Name = "Stop RunSummit",
    Callback = function()
        running = false
        Rayfield:Notify({Title="Antartika", Content="⛔ RunSummit dihentikan!", Duration=2})
    end
})

-- Tombol teleport langsung Pos 1–5
for i, pos in ipairs(positions) do
    antartikaTab:CreateButton({
        Name = "Teleport Pos "..i,
        Callback = function()
            TeleportTo(pos)
            Rayfield:Notify({Title="Antartika", Content="✅ Teleported to Pos "..i, Duration=2})
        end
    })
end

Rayfield:LoadConfiguration()
