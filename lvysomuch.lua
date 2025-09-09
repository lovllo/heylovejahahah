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
-- === Positions & data (from your original script) ===
-- Antartika
local positions = {
    Vector3.new(-3719, 225, 234),
    Vector3.new(1790, 105, -138),
    Vector3.new(5892, 321, -20),
    Vector3.new(8992, 596, 103),
    Vector3.new(11002, 549, 128),
}
local refillMap = {
    [1] = "WaterRefill_Camp1",
    [2] = "WaterRefill_Camp2",
    [3] = "WaterRefill_Camp3",
    [4] = "WaterRefill_Camp4",
}

-- Ravika
local TeleportsRavika = {
    Vector3.new(-785, 87, -652),
    Vector3.new(-986, 184, -79),
    Vector3.new(-955, 178, 807),
    Vector3.new(796, 186, 876),
    Vector3.new(971, 98, 136),
    Vector3.new(982, 144, -535),
    Vector3.new(401, 122, -230),
    Vector3.new(3, 435, 95), -- SUMMIT
}

-- Atin
local ATIN_SUMMIT = {
    Vector3.new(625, 1799, 3433),
    Vector3.new(777, 2184, 3934)
}

-- Sibuatan
local SIBUATAN_SUMMIT = Vector3.new(5394, 8109, 2207)

-- Sibayak
local TeleportsSibayak = {
    Vector3.new(-3348, 59, -4741),
    Vector3.new(-2163, 241, -4849),
    Vector3.new(-1994, 496, -4824),
    Vector3.new(-1584, 578, -4579),
    Vector3.new(-1521, 555, -5000),
    Vector3.new(-801, 545, -5374),
    Vector3.new(319, 856, -4444),
    Vector3.new(1091, 987, -5308),
    Vector3.new(1576, 1279, -5595), -- Summit
}
local FallPos = Vector3.new(1637, 1412, -5588)

-- Lauser
local TeleportsLauser = {
    Vector3.new(992, 207, 1042),
    Vector3.new(57, 397, 732),
    Vector3.new(421, 873, 195),
    Vector3.new(400, 1094, -127),
    Vector3.new(512, 1251, -779),
    Vector3.new(871, 1144, -1003), -- Summit
}
local FallPosLauser = Vector3.new(900, 1300, -1000)

-- Ckptw

local CkptwPositions = {
    Vector3.new(388, 309, -186),
    Vector3.new(101, 411, 617),
    Vector3.new(11, 600, 998),
    Vector3.new(873, 864, 581),
    Vector3.new(1618, 1079, 158),
    Vector3.new(2970, 1527, 709),
    Vector3.new(1802, 1981, 2159),
}

-- Daun
local DaunPositions = {
    Vector3.new(-622, 250, -384),
    Vector3.new(-1203, 261, -487),
    Vector3.new(-1399, 578, -950),
    Vector3.new(-1701, 816, -1400),
    Vector3.new(-3209, 1721, -2608),
}

-- Lawak
local LawakPositions = {
    Vector3.new(-251, 30, 18),
    Vector3.new(-191, 177, 247),
    Vector3.new(285, 321, -190),
    Vector3.new(409, 406, 161),
    Vector3.new(450, 391, -69),
    Vector3.new(530, 568, -314),
    Vector3.new(1441, 1129, -1300),
    Vector3.new(1794, 1478, -1961),
    Vector3.new(2872, 2625, -1882),
}
local LawakEnd = Vector3.new(2870, 2626, -1819)

-- Misc initial values
local _G = _G
_G.FyyInfJump = false
_G.FyyNoclip = false
_G.FyyESP = false

-- === Loop flags & other state ===
local running = false
local currentPos = 1
local lastDrink = tick()
local lastRefill = tick()
local ravikaLoop = false
local atinLoop = false
local sibuatanLoop = false
local SibayakLoop = false
local LauserLoop = false
local XYZLoop = false
local DaunLoop = false
local LawakLoop = false
local CkptwLoop = false


local savedPosition = nil
local posGUI = nil

-- === Helper functions (teleport, waitForHRP, countdown, steploop, autodrink, etc) ===
local function waitForHRP(character, timeout)
    timeout = timeout or 5
    local t0 = tick()
    while tick() - t0 < timeout do
        if character and character:FindFirstChild("HumanoidRootPart") then
            return character:FindFirstChild("HumanoidRootPart")
        end
        task.wait(0.1)
    end
    return nil
end

local function TeleportTo(pos)
    -- safe teleport: buat part sementara supaya player gak jatuh
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if typeof(pos) == "Vector3" then
        local tempPart = Instance.new("Part")
        tempPart.Anchored = true
        tempPart.CanCollide = true
        tempPart.Transparency = 1
        tempPart.Size = Vector3.new(10,1,10)
        tempPart.CFrame = CFrame.new(pos)
        tempPart.Parent = Workspace
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
        task.wait(1.2)
        if tempPart and tempPart.Parent then tempPart:Destroy() end
    elseif typeof(pos) == "CFrame" then
        hrp.CFrame = pos
    end
end

local function showCountdown(sec, title)
    title = title or "Auto Summit"
    for i = sec,1,-1 do
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = "Teleport dalam " .. i .. " detik",
                Duration = 1,
            })
        end)
        task.wait(1)
    end
end

local function StepLoop(times, stopFlag)
    local character = player.Character
    if not character then return end
    local hrp = waitForHRP(character, 5)
    if not hrp then return end
    for i = 1, times do
        if not stopFlag() then break end
        local forward = hrp.CFrame * CFrame.new(0, 0, -10)
        TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = forward}):Play()
        task.wait(1.2)
        if not stopFlag() then break end
        task.wait(3)
        local back = hrp.CFrame * CFrame.new(0, 0, 10)
        TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = back}):Play()
        task.wait(1.2)
        if not stopFlag() then break end
        task.wait(3)
    end
end

local function AutoDrink()
    -- trigger klik untuk minum (jika tersedia)
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:ClickButton1(Vector2.new(0,0))
    end)
    -- additional attempt: if drink is remote
    pcall(function()
        local data = player:FindFirstChild("Expedition Data")
        if data then
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum and hum:FindFirstChild("Drink") then
                pcall(function() hum.Drink:Invoke() end)
            end
        end
    end)
end

-- RunSummit (Antartika) — adapted from original script
local function RunSummit()
    local data = player:WaitForChild("Expedition Data", 10)
    if not data then
        warn("Expedition Data not found")
    end
    local coins = data and data:FindFirstChild("Coins")
    local lastCoin = coins and coins.Value or 0

    -- teleport to starting pos
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
            local refillFolder = Workspace:FindFirstChild("Locally_Imported_Parts")
            if refillFolder then
                local targetRefillName = refillMap[currentPos]
                if targetRefillName and refillFolder:FindFirstChild(targetRefillName) then
                    local prevPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
                    -- teleport ke refill
                    TeleportTo(refillFolder[targetRefillName].Position)
                    task.wait(0.5)
                    -- mundur 5 langkah → maju 5 langkah untuk trigger refill
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                        task.wait(0.5)
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
                        task.wait(0.5)
                    end
                    -- kembali ke posisi semula
                    if prevPos then TeleportTo(prevPos) end
                end
            end
            lastRefill = now
        end

        -- cek coin
        if coins and coins.Value > lastCoin then
            lastCoin = coins.Value
            if currentPos >= #positions then
                TeleportTo(Vector3.new(10952, 313, 122))
                pcall(function() if player.Character then player.Character:BreakJoints() end end)
                -- tunggu respawn
                player.CharacterAdded:Wait()
                task.wait(1)
                currentPos = 1
                TeleportTo(positions[currentPos])
            else
                currentPos = currentPos + 1
                TeleportTo(positions[currentPos])
            end
        end

        -- pola maju-mundur (adapted)
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

-- === Other helpers used by toggles already in original script ===

local function showCountdownAtin(sec) showCountdown(sec, "MT Atin") end
local function showCountdownSibuatan(sec) showCountdown(sec, "MT Sibuatan") end

-- === UI Creation: Tabs + All menu callbacks (full logic) ===

-- Tab: Auto Summit
local mountTab = Window:CreateTab("Auto Summit🔥", 4483362458)
mountTab:CreateSection("Auto Summit")

-- Expedition Antartika toggle (uses RunSummit)
CreateMenuToggle(mountTab, "Expedition Antartika⚡", false, function(Value)
    running = Value
    if Value then task.spawn(RunSummit) end
end)

-- MT Ravika
CreateMenuToggle(mountTab, "MT Ravika", false, function(Value)
    ravikaLoop = Value
    task.spawn(function()
        while ravikaLoop do
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                player.CharacterAdded:Wait()
                task.wait(3)
            end
            for _, pos in ipairs(TeleportsRavika) do
                if not ravikaLoop then break end
                TeleportTo(pos)
                task.wait(30)
            end
            if ravikaLoop and player.Character then
                pcall(function() player.Character:BreakJoints() end)
                player.CharacterAdded:Wait()
                hrp = player.Character:WaitForChild("HumanoidRootPart")
                task.wait(2)
            end
        end
    end)
end)

---------- ATIN

local AtinToggle = mountTab:CreateToggle({
    Name = "MT Atin",
    CurrentValue = false,
    Flag = "mt_atin_flag", -- <--- flag untuk save config
    Callback = function(Value)
        atinLoop = Value
        task.spawn(function()
            while atinLoop do
                -- Hitungan mundur sekali di awal
                showCountdown(5, "MT Atin")

                -- Teleport ke posisi 1
                TeleportTo(ATIN_SUMMIT[1])
                task.wait(5)

                if not atinLoop then break end

                -- Teleport ke posisi 2
                TeleportTo(ATIN_SUMMIT[2])
                task.wait(5)

                if not atinLoop then break end

                -- Rejoin server
                TeleportService:Teleport(game.PlaceId, player)
                task.wait(15)
            end
        end)
    end
})




-- MT Sibuatan
local SibuatanToggle = mountTab:CreateToggle({
    Name = "MT Sibuatan",
    CurrentValue = false,
    Flag = "mt_sibuatan_flag", -- <--- flag untuk save config
    Callback = function(Value)
        sibuatanLoop = Value
        task.spawn(function()
            while sibuatanLoop do
                showCountdown(10, "MT Sibuatan")
                TeleportTo(SIBUATAN_SUMMIT)
                task.wait(2)
                TeleportService:Teleport(game.PlaceId, player)
                task.wait(15)
            end
        end)
    end
})


-- MT Sibayak
CreateMenuToggle(mountTab, "MT Sibayak", false, function(Value)
    SibayakLoop = Value
    if SibayakLoop then
        task.spawn(function()
            while SibayakLoop do
                for i, pos in ipairs(TeleportsSibayak) do
                    if not SibayakLoop then break end
                    local character = player.Character or player.CharacterAdded:Wait()
                    local hrp = waitForHRP(character, 5)
                    if not hrp then break end
                    hrp.CFrame = CFrame.new(pos)
                    task.wait(0.5)
                    StepLoop(3, function() return SibayakLoop end)
                    if i == #TeleportsSibayak and SibayakLoop then
                        hrp.CFrame = CFrame.new(FallPos.X, FallPos.Y + 300, FallPos.Z)
                        player.CharacterAdded:Wait()
                        task.wait(1)
                    end
                end
            end
        end)
    end
end)

-- MT Lauser
CreateMenuToggle(mountTab, "MT Lauser", false, function(Value)
    LauserLoop = Value
    if LauserLoop then
        task.spawn(function()
            while LauserLoop do
                for i, pos in ipairs(TeleportsLauser) do
                    if not LauserLoop then break end
                    local character = player.Character or player.CharacterAdded:Wait()
                    local hrp = waitForHRP(character, 5)
                    if not hrp then break end
                    hrp.CFrame = CFrame.new(pos)
                    task.wait(0.5)
                    StepLoop(3, function() return LauserLoop end)
                    if i == #TeleportsLauser and LauserLoop then
                        hrp.CFrame = CFrame.new(FallPosLauser.X, FallPosLauser.Y + 300, FallPosLauser.Z)
                        player.CharacterAdded:Wait()
                        task.wait(1)
                    end
                end
            end
        end)
    end
end)

-- MT Yhahyuk
local player = game.Players.LocalPlayer

-- Fungsi bikin Timer GUI ala Arunika
local function createTimerGui()
    local existing = player.PlayerGui:FindFirstChild("ArunikaTimerGui")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ArunikaTimerGui"
    screenGui.Parent = player.PlayerGui

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(0, 200, 0, 40)
    timerLabel.Position = UDim2.new(0.5, 0, 0.12, 0)
    timerLabel.AnchorPoint = Vector2.new(0.5, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextScaled = true
    timerLabel.Visible = false
    timerLabel.TextStrokeTransparency = 0
    timerLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    timerLabel.Parent = screenGui

    return timerLabel
end

-- Fungsi timer blocking
local function showTimer(seconds, label)
    local TimerLabel = createTimerGui()
    TimerLabel.Visible = true
    for i = seconds,1,-1 do
        TimerLabel.Text = label .. "\nTunggu: " .. i
        task.wait(1)
    end
    TimerLabel.Visible = false
end

-- Fungsi HRP checker
local function waitForHRP(char, timeout)
    local t = 0
    repeat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    until t >= timeout
    return nil
end

-- Daftar checkpoint
local XYZPositions = {
    Vector3.new(-418, 249, 769),
    Vector3.new(-348, 388, 524),
    Vector3.new(288, 429, 504),
    Vector3.new(334, 490, 348),
    Vector3.new(212, 315, -146),
    Vector3.new(-602, 905, -515),
}

local XYZLoop = false

-- Toggle MT Yhahyuk
CreateMenuToggle(mountTab, "MT Yhahyuk", false, function(Value)
    XYZLoop = Value
    if not Value then return end

    task.spawn(function()
        while XYZLoop do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = waitForHRP(character, 5)
            if not hrp then warn("HRP tidak ditemukan"); break end

            for i, pos in ipairs(XYZPositions) do
                if not XYZLoop then break end

                character = player.Character or player.CharacterAdded:Wait()
                hrp = waitForHRP(character, 5)
                if not hrp then warn("HRP hilang di CP " .. i); break end

                hrp.CFrame = CFrame.new(pos)

                local delayTime = 3
                local label = "CP " .. i
                if i == 5 then
                    delayTime = math.random(50, 60)
                    label = label .. " (Random 50-60)"
                elseif i == 6 then
                    label = "Summit"
                end

                showTimer(delayTime, label)
            end

            -- Respawn karakter
            if XYZLoop and player.Character then
                local oldChar = player.Character
                pcall(function() oldChar:BreakJoints() end)

                -- Tunggu karakter baru spawn
                repeat task.wait(0.1) until player.Character ~= oldChar and player.Character:FindFirstChild("HumanoidRootPart")

                -- Tampilkan timer respawn
                showTimer(2, "Respawn")
            end
        end
    end)
end)



-- MT Daun
-- GUI Timer (sekali buat, bisa dipakai global)
local function setupTimerGui()
    local coreGui = game:GetService("CoreGui")
    local existing = coreGui:FindFirstChild("DaunTimerGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DaunTimerGui"
    ScreenGui.Parent = coreGui

    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Parent = ScreenGui
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0)
    TimerLabel.Size = UDim2.new(0, 240, 0, 60)
    TimerLabel.Position = UDim2.new(0.5, 0, 0, 50)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.Font = Enum.Font.SourceSansBold
    TimerLabel.TextScaled = true
    TimerLabel.Visible = false

    local stroke = Instance.new("UIStroke")
    stroke.Parent = TimerLabel
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0,0,0)

    return TimerLabel
end

local TimerLabel = setupTimerGui()

-- Fungsi countdown GUI
local function showTimer(seconds, label)
    TimerLabel.Visible = true
    for i = seconds, 1, -1 do
        if not DaunLoop then break end
        TimerLabel.Text = label .. "\nTunggu: " .. i .. " detik"
        task.wait(1)
    end
    TimerLabel.Visible = false
end

-- Fungsi HRP checker
local function waitForHRP(char, timeout)
    local t = 0
    repeat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    until t >= timeout
    return nil
end

-- === TOGGLE ===
CreateMenuToggle(mountTab, "MT Daun", false, function(Value)
    DaunLoop = Value
    if not Value then return end
    task.spawn(function()
        while DaunLoop do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = waitForHRP(character, 5)
            if not hrp then break end
            task.wait(0.5)

            for i, pos in ipairs(DaunPositions) do
                if not DaunLoop then break end
                if hrp and hrp.Parent then
                    hrp.CFrame = CFrame.new(pos)

                    -- logika delay pakai GUI timer
                    if i == #DaunPositions then
                        -- CP terakhir
                        showTimer(2, "CP " .. i .. " (Terakhir)")
                    elseif i == 3 then
                        local delay = math.random(90, 120)
                        showTimer(delay, "CP " .. i .. " (Random)")
                    elseif i == 4 then
                        local delay = math.random(90, 120)
                        showTimer(delay, "CP " .. i .. " (Random)")
                    else
                        showTimer(60, "CP " .. i)
                    end
                end
            end

            -- selesai → respawn & loop lagi
            if DaunLoop and player.Character then
                local char = player.Character
                pcall(function() player.Character:BreakJoints() end)
                repeat task.wait(0.1) until player.Character ~= char and player.Character:FindFirstChild("HumanoidRootPart")
                task.wait(0.5)
            end
        end
    end)
end)



-- MT Lawak
CreateMenuToggle(mountTab, "MT Lawak", false, function(Value)
    LawakLoop = Value
    if not Value then return end
    task.spawn(function()
        while LawakLoop do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = waitForHRP(character, 5)
            local humanoid = character:FindFirstChild("Humanoid")
            if not hrp or not humanoid then break end
            task.wait(0.5)
            for i, pos in ipairs(LawakPositions) do
                if not LawakLoop then break end
                if hrp and hrp.Parent and humanoid then
                    hrp.CFrame = CFrame.new(pos)
                    if i == #LawakPositions then
                        task.wait(2)
                        local backward = -hrp.CFrame.LookVector * 30
                        humanoid:MoveTo(hrp.Position + backward)
                        humanoid.MoveToFinished:Wait()
                        task.wait(1)
                        hrp.CFrame = CFrame.new(LawakEnd)
                        task.wait(5)
                    else
                        task.wait(2)
                    end
                end
            end
        end
    end)
end)

------- MT CKPTW

-- === SETUP GUI TIMER ===
local function setupTimerGui()
    local coreGui = game:GetService("CoreGui")
    local existing = coreGui:FindFirstChild("CkptwTimerGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CkptwTimerGui"
    ScreenGui.Parent = coreGui

    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Parent = ScreenGui
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0)
    TimerLabel.Size = UDim2.new(0, 240, 0, 60)
    TimerLabel.Position = UDim2.new(0.5, 0, 0, 50)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.Font = Enum.Font.SourceSansBold
    TimerLabel.TextScaled = true
    TimerLabel.Visible = false

    local stroke = Instance.new("UIStroke")
    stroke.Parent = TimerLabel
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0,0,0)

    return TimerLabel
end

local TimerLabel = setupTimerGui()

-- Fungsi countdown GUI
local function showTimer(seconds, label)
    TimerLabel.Visible = true
    for i = seconds, 1, -1 do
        if not CkptwLoop then break end
        TimerLabel.Text = label .. "\nTunggu: " .. i .. " detik"
        task.wait(1)
    end
    TimerLabel.Visible = false
end

-- Fungsi HRP checker
local function waitForHRP(char, timeout)
    local t = 0
    repeat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    until t >= timeout
    return nil
end

-- === TOGGLE ===
CreateMenuToggle(mountTab, "MT Ckptw", false, function(Value)
    CkptwLoop = Value
    if not Value then return end

    task.spawn(function()
        while CkptwLoop do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = waitForHRP(character, 5)
            if not hrp then break end
            task.wait(0.5)

            for i, pos in ipairs(CkptwPositions) do
                if not CkptwLoop then break end
                hrp.CFrame = CFrame.new(pos)

                -- delay antar checkpoint dengan GUI Timer
                if i == #CkptwPositions then
                    showTimer(3, "CP " .. i .. " (Terakhir)")
                else
                    showTimer(30, "CP " .. i)
                end
            end

            -- respawn karakter setelah checkpoint terakhir
            if CkptwLoop and player.Character then
                local oldChar = player.Character
                pcall(function() player.Character:BreakJoints() end)
                
                -- tunggu karakter baru spawn
                repeat task.wait(0.1) until player.Character ~= oldChar and player.Character:FindFirstChild("HumanoidRootPart")
                
                showTimer(2, "Respawn") -- ganti delay respawn jadi GUI Timer juga
            end
        end
    end)
end)




-- === Tab: MT Arunika (Teleport buttons) ===
local player = game.Players.LocalPlayer
local mountTab = mountTab
local MTArunikaLoop = false

-- Setup Timer GUI
local function setupTimerGui()
    local coreGui = game:GetService("CoreGui")
    local existing = coreGui:FindFirstChild("CkptwTimerGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CkptwTimerGui"
    ScreenGui.Parent = coreGui

    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Parent = ScreenGui
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0)
    TimerLabel.Size = UDim2.new(0, 240, 0, 60)
    TimerLabel.Position = UDim2.new(0.5, 0, 0, 50)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.Font = Enum.Font.SourceSansBold
    TimerLabel.TextScaled = true
    TimerLabel.Visible = false

    local stroke = Instance.new("UIStroke")
    stroke.Parent = TimerLabel
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0,0,0)

    return TimerLabel
end

local TimerLabel = setupTimerGui()

-- Countdown GUI
local function showTimer(seconds, label)
    TimerLabel.Visible = true
    for i = seconds,1,-1 do
        if not MTArunikaLoop then break end
        TimerLabel.Text = label .. "\nTunggu: " .. i .. " detik"
        task.wait(1)
    end
    TimerLabel.Visible = false
end

-- HRP checker
local function waitForHRP(char, timeout)
    local t = 0
    repeat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    until t >= timeout
    return nil
end

-- Toggle MT Arunika
local player = game.Players.LocalPlayer
local mountTab = mountTab
local MTArunikaLoop = false

-- Setup Timer GUI
local function setupTimerGui()
    local coreGui = game:GetService("CoreGui")
    local existing = coreGui:FindFirstChild("CkptwTimerGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CkptwTimerGui"
    ScreenGui.Parent = coreGui

    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Parent = ScreenGui
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0)
    TimerLabel.Size = UDim2.new(0, 240, 0, 60)
    TimerLabel.Position = UDim2.new(0.5, 0, 0, 50)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.Font = Enum.Font.SourceSansBold
    TimerLabel.TextScaled = true
    TimerLabel.Visible = false

    local stroke = Instance.new("UIStroke")
    stroke.Parent = TimerLabel
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0,0,0)

    return TimerLabel
end

local TimerLabel = setupTimerGui()

-- Countdown GUI
local function showTimer(seconds, label)
    TimerLabel.Visible = true
    for i = seconds,1,-1 do
        if not MTArunikaLoop then break end
        TimerLabel.Text = label .. "\nTunggu: " .. i .. " detik"
        task.wait(1)
    end
    TimerLabel.Visible = false
end

-- HRP checker
local function waitForHRP(char, timeout)
    local t = 0
    repeat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    until t >= timeout
    return nil
end

-- Toggle MT Arunika
CreateMenuToggle(mountTab, "MT Arunika", false, function(Value)
    MTArunikaLoop = Value
    if not Value then return end

    task.spawn(function()
        while MTArunikaLoop do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = waitForHRP(character, 5)
            if not hrp then break end
            task.wait(5)

            -- CP1
            hrp.CFrame = CFrame.new(136,142,-175)
            showTimer(3, "CP 1")

            -- CP2
            hrp.CFrame = CFrame.new(326,90,-434)
            showTimer(4, "CP 2")

            -- CP3
            hrp.CFrame = CFrame.new(477,170,-940)
            showTimer(5, "CP 3")

            -- CP4
            hrp.CFrame = CFrame.new(930,133,-626)
            showTimer(6, "CP 4")
            -- CP tambahan setelah delay
            hrp.CFrame = CFrame.new(-18,5,-422)
            showTimer(150, "NGUMPET CIK")

            -- CP5
            hrp.CFrame = CFrame.new(924,101,279)
            showTimer(2, "CP 5")
            -- CP tambahan setelah delay
            hrp.CFrame = CFrame.new(-18,5,-422)
            showTimer(150, "NGUMPET CIK MAU SUMMIT")

            -- Summit
            hrp.CFrame = CFrame.new(257, 325, 708)
            showTimer(3, "Summit (Terakhir)")

            -- Respawn
            if player.Character then
                player.Character:BreakJoints()
                repeat task.wait(0.1) until player.Character ~= character and player.Character:FindFirstChild("HumanoidRootPart")
                task.wait(2)
            end
        end
    end)
end)


------------

-- Bikin Tab Baru
local arunikaTab = Window:CreateTab("Auto Walk Mount", 4483362458)

-- Optional: Section di dalam Tab
arunikaTab:CreateSection("Auto Script")

-- Bikin Button di dalam Tab Arunika V2
-- Variable lock per button
-- Variable lock per button
local RunArunikaButtonEnabled = true

CreateMenuButton(arunikaTab, "Auto Walk Arunika V2", function()
    -- Lock button jika sudah dijalankan
    if not RunArunikaButtonEnabled then
        Rayfield:Notify({
            Title = "Run Auto Arunika",
            Content = "⚠️ Fitur ini sudah dijalankan / dikunci!",
            Duration = 4
        })
        return
    end

    -- Jalankan script
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lovllo/howtoforgetyou/main/nka.lua"))()

    -- Notif sukses
    Rayfield:Notify({
        Title = "Run Auto Arunika",
        Content = "✅ Script berhasil dijalankan!",
        Duration = 4
    })

    -- Lock button supaya tidak bisa dijalankan lagi
    RunArunikaButtonEnabled = false
end)



-------------------

-- === MT Batu Toggle ===
local BatuPositions = {
    Vector3.new(-122, 9, 544),
    Vector3.new(-40, 393, 674),
    Vector3.new(-297, 485, 779),
    Vector3.new(17, 573, 664),
    Vector3.new(587, 917, 637),
    Vector3.new(284, 1197, 182),
    Vector3.new(552, 1529, -581),
    Vector3.new(332, 1737, -261),
    Vector3.new(290, 1980, -204),
    Vector3.new(616, 3261, -66),
    Vector3.new(335, 3245, -32),
}

local MTBatuLoop = false

-- Fungsi auto interact khusus di depan karakter
local function AutoInteract()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local radius = 12 -- jarak sekitar 12 stud
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                local distance = (part.Position - hrp.Position).Magnitude
                if distance <= radius then
                    fireproximityprompt(obj)
                    break
                end
            end
        end
    end
end

CreateMenuToggle(mountTab, "MT Batu", false, function(Value)
    MTBatuLoop = Value
    if not Value then return end

    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        while MTBatuLoop do
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            
            for i, pos in ipairs(BatuPositions) do
                if not MTBatuLoop then break end
                hrp.CFrame = CFrame.new(pos)
                task.wait(2)

                -- Kalau di posisi terakhir → auto interact (SUMMIT)
                if i == #BatuPositions then
                    task.wait(1) -- kasih delay biar prompt muncul
                    AutoInteract()
                    task.wait(1)
                    -- Balik ke basecamp (pos pertama)
                    hrp.CFrame = CFrame.new(BatuPositions[1])
                end
            end
        end
    end)
end)




-- === Posisi Checkpoint ===
local YagatawPositions = {
    Vector3.new(-420, 191, 557),
    Vector3.new(-626, 579, 1136),
    Vector3.new(-900, 690, 1222),
    Vector3.new(-909, 819, 1760),
    Vector3.new(-476, 886, 1701),
    Vector3.new(-379, 1041, 2066),
    Vector3.new(-751, 1525, 2057),
    Vector3.new(-479, 1633, 2271),
    Vector3.new(2, 2493, 2044)
}

local player = game:GetService("Players").LocalPlayer

-- === Setup GUI Timer ===
local function setupTimerGui()
    local coreGui = game:GetService("CoreGui")
    local existing = coreGui:FindFirstChild("YagatawTimerGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "YagatawTimerGui"
    ScreenGui.Parent = coreGui

    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Parent = ScreenGui
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0)
    TimerLabel.Size = UDim2.new(0, 240, 0, 60)
    TimerLabel.Position = UDim2.new(0.5, 0, 0, 50)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.Font = Enum.Font.SourceSansBold
    TimerLabel.TextScaled = true
    TimerLabel.Visible = false

    local stroke = Instance.new("UIStroke")
    stroke.Parent = TimerLabel
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0,0,0)

    return TimerLabel
end

local TimerLabel = setupTimerGui()

-- Fungsi countdown GUI
local function showTimer(seconds, label)
    TimerLabel.Visible = true
    for i = seconds, 1, -1 do
        if not YagatawLoop then break end
        TimerLabel.Text = label .. "\nTunggu: " .. i .. " detik"
        task.wait(1)
    end
    TimerLabel.Visible = false
end

-- HRP Checker
local function waitForHRP(char, timeout)
    local t = 0
    repeat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    until t >= timeout
    return nil
end

-- Jalan maju–mundur
local function walkForwardAndBack(hrp, studs, step, delay)
    local forward = hrp.CFrame.LookVector.Unit
    local origin = hrp.CFrame.Position
    -- maju
    for d = 1, studs, step do
        if not YagatawLoop then return end
        hrp.CFrame = CFrame.new(origin + forward * d, origin + forward * (d+1))
        task.wait(delay)
    end
    -- mundur
    for d = studs, 0, -step do
        if not YagatawLoop then return end
        hrp.CFrame = CFrame.new(origin + forward * d, origin + forward * (d+1))
        task.wait(delay)
    end
end

-- === TOGGLE MENU ===
CreateMenuToggle(mountTab, "MT Yagataw", false, function(Value)
    YagatawLoop = Value
    if not Value then return end

    task.spawn(function()
        while YagatawLoop do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = waitForHRP(character, 5)
            if not hrp then break end
            task.wait(0.5)

            for i, pos in ipairs(YagatawPositions) do
                if not YagatawLoop then break end
                if hrp and hrp.Parent then
                    -- teleport
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
                    task.wait(3) -- delay render

                    -- jalan trigger
                    walkForwardAndBack(hrp, 15, 1, 0.05)

                    -- timer logic (semua 60 detik kecuali terakhir)
                    if i == #YagatawPositions then
                        showTimer(2, "CP " .. i .. " (Terakhir)")
                    else
                        showTimer(90, "CP " .. i)
                    end
                end
            end

            -- respawn kalau selesai
            if YagatawLoop and player.Character then
                local oldChar = player.Character
                pcall(function() oldChar:BreakJoints() end)
                repeat task.wait(0.1) until player.Character ~= oldChar and player.Character:FindFirstChild("HumanoidRootPart")
                task.wait(0.5)
            end
        end
    end)
end)


-- === SETUP GUI TIMER UNTUK KONOHA ===


local function setupTimerGui()
    local coreGui = game:GetService("CoreGui")
    local existing = coreGui:FindFirstChild("KonohaTimerGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KonohaTimerGui"
    ScreenGui.Parent = coreGui

    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Parent = ScreenGui
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0)
    TimerLabel.Size = UDim2.new(0, 240, 0, 60)
    TimerLabel.Position = UDim2.new(0.5, 0, 0, 50)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.Font = Enum.Font.SourceSansBold
    TimerLabel.TextScaled = true
    TimerLabel.Visible = false

    local stroke = Instance.new("UIStroke")
    stroke.Parent = TimerLabel
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0,0,0)

    return TimerLabel
end

local KonohaTimerLabel = setupTimerGui()

-- Fungsi countdown GUI
local function showKonohaTimer(seconds, label)
    KonohaTimerLabel.Visible = true
    for i = seconds, 1, -1 do
        if not KonohaLoop then break end
        KonohaTimerLabel.Text = label .. "\nTunggu: " .. i .. " detik"
        task.wait(1)
    end
    KonohaTimerLabel.Visible = false
end

-- Fungsi HRP checker
local function waitForHRP(char, timeout)
    local t = 0
    repeat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        task.wait(0.1)
        t = t + 0.1
    until t >= timeout
    return nil
end

-- === POSISI KONOHA ===
local KonohaPositions = {
    Vector3.new(812, 285, -577),
    Vector3.new(772, 517, -379),
    Vector3.new(-78, 473, 387),
    Vector3.new(179, 581, 700),
    Vector3.new(350, 585, 820),
    Vector3.new(794, 809, 625),
    Vector3.new(929, 1001, 606)
}

-- === TOGGLE ===
CreateMenuToggle(mountTab, "MT Konoha", false, function(Value)
    KonohaLoop = Value
    if not Value then return end

    task.spawn(function()
        while KonohaLoop do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = waitForHRP(character, 5)
            if not hrp then break end
            task.wait(0.5)

            for i, pos in ipairs(KonohaPositions) do
                if not KonohaLoop then break end
                hrp.CFrame = CFrame.new(pos)

                -- delay antar checkpoint pakai GUI Timer
                if i == #KonohaPositions then
                    showKonohaTimer(3, "CP " .. i .. " (Terakhir)")
                else
                    showKonohaTimer(32, "CP " .. i)
                end
            end

            -- respawn karakter setelah checkpoint terakhir
            if KonohaLoop and player.Character then
                local oldChar = player.Character
                pcall(function() player.Character:BreakJoints() end)

                -- tunggu karakter baru spawn
                repeat task.wait(0.1) until player.Character ~= oldChar and player.Character:FindFirstChild("HumanoidRootPart")

                showKonohaTimer(2, "Respawn")
            end
        end
    end)
end)
------------


CreateMenuToggle(mountTab, "Hell Expedition", false, function(Value)
    HellExpeditionLoop = Value
    if not Value then return end

    -- Spawn satu loop saja
    task.spawn(function()
        local player = game.Players.LocalPlayer

        local summitPositions = {
            Vector3.new(-102, 201, 272),
            Vector3.new(155, 249, 424),
            Vector3.new(484, 353, 311),
            Vector3.new(526, 413, -315),
            Vector3.new(-227, 541, -757),
            Vector3.new(-654, 541, -651),
            Vector3.new(-817, 434, 442),
            Vector3.new(-320, 410, 660),
            Vector3.new(347, 331, 717),
            Vector3.new(807, 637, 864),
            Vector3.new(1253, 825, 395),
            Vector3.new(1509, 1193, 18),
            Vector3.new(1000, 1193, -58),
            Vector3.new(-1513, 1874, -72)
        }

        local interactPosition = Vector3.new(-1368, 1883, -185)

        -- Fungsi teleport
        local function teleportTo(pos)
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
        end

        -- Fungsi auto interact
        local function autoInteract()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local distance = (prompt.Parent.Position - hrp.Position).Magnitude
                        if distance <= prompt.MaxActivationDistance then
                            pcall(function()
                                fireproximityprompt(prompt)
                            end)
                        end
                    end
                end
            end
        end

        -- Loop utama
        while HellExpeditionLoop do
            -- Teleport ke semua posisi summit
            for _, pos in ipairs(summitPositions) do
                if not HellExpeditionLoop then break end
                teleportTo(pos)
                task.wait(3)
            end

            -- Teleport ke tempat interact dan auto interact
            if HellExpeditionLoop then
                teleportTo(interactPosition)
                task.wait(0.5)
                autoInteract()
                task.wait(0.5)
            end
        end
    end)
end)

---------- HANAMI

local HanamiPositions = {
    Vector3.new(515, 141, -124),
    Vector3.new(360, 196, -613),
    Vector3.new(-94, 170, -489),
    Vector3.new(-934, 345, -512),
    Vector3.new(-1278, 478, -330),
    Vector3.new(-1976, 610, 132),
    Vector3.new(-2766, 669, 44),
    Vector3.new(-2598, 849, -323), -- summit
}

local MTHanamiloop = false

CreateMenuToggle(mountTab, "MT Hanami", false, function(Value)
    MTHanamiloop = Value
    if not Value then return end

    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        while MTHanamiloop do
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            task.wait(0.5)

            for i, pos in ipairs(HanamiPositions) do
                if not MTHanamiloop then break end
                hrp.CFrame = CFrame.new(pos)
                task.wait(3)

                -- Summit (pos terakhir)
                if i == #HanamiPositions then
                    task.wait(3) -- tunggu 5 detik di summit
                    -- Respawn balik ke awal
                    hrp.CFrame = CFrame.new(HanamiPositions[1])
                    break -- restart loop dari awal
                end
            end
        end
    end)
end)

------------- DAUN V2

local RunDaunV2ButtonEnabled = true

CreateMenuButton(arunikaTab, "Auto Walk Daun V2", function()
    -- Lock button jika sudah dijalankan
    if not RunDaunV2ButtonEnabled then
        Rayfield:Notify({
            Title = "Run Walk Daun",
            Content = "⚠️ Fitur ini sudah dijalankan / dikunci!",
            Duration = 4
        })
        return
    end

    -- Jalankan script
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lovllo/howtoforgetyou/main/dan.lua"))()


    -- Notif sukses
    Rayfield:Notify({
        Title = "Run Walk Daun",
        Content = "✅ Script berhasil dijalankan!",
        Duration = 4
    })

    -- Lock button supaya tidak bisa dijalankan lagi
    RunArunikaButtonEnabled = false
end)

-- Anti AFK Toggle (Rayfield) masuk PremiumTab
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AntiAFKLoop = false

CreateMenuToggle(PremiumTab, "Anti AFK", false, function(Value)
    AntiAFKLoop = Value
    if not Value then return end

    task.spawn(function()
        while AntiAFKLoop do
            task.wait(60) -- tiap 60 detik
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new()) -- klik kanan kosong biar dianggap aktif
        end
    end)
end)



Rayfield:LoadConfiguration()
