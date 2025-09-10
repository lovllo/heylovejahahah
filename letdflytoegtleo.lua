-- Services
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer

-- Multi-track URLs
local tracksURLs = {
    ["BC - 1"] = "https://raw.githubusercontent.com/fyybisnis4-gif/Fyy/refs/heads/main/CP1.json",
    ["CP 1 - CP 2"] = "https://raw.githubusercontent.com/fyybisnis4-gif/Fyy/refs/heads/main/CP2.json",
    ["CP 2 - CP 3"] = "https://raw.githubusercontent.com/fyybisnis4-gif/Fyy/refs/heads/main/CP2-2.json",
    ["CP 3 - CP 4"] = "https://raw.githubusercontent.com/fyybisnis4-gif/Fyy/refs/heads/main/CP3.json",
    ["CP 4 - CP 5"] = "https://raw.githubusercontent.com/fyybisnis4-gif/Fyy/refs/heads/main/CP4.json",
    ["CP 5 - SUMMIT"] = "https://raw.githubusercontent.com/fyybisnis4-gif/Fyy/refs/heads/main/CP5.json",
}

local savedTracks = {}

-- Load Tracks
for name, url in pairs(tracksURLs) do
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and data and data.points then
        savedTracks[name] = {}
        for _, p in ipairs(data.points) do
            table.insert(savedTracks[name], Vector3.new(p[1], p[2], p[3]))
        end
    else
        savedTracks[name] = {}
    end
end

-- Variables
local running = false
local speed = 0.01 -- default speed

local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Replay function
local function playTrack(track)
    if not track or #track < 2 then return end
    local hrp = getHRP()
    for i = 1, #track do
        if not running then break end
        hrp.CFrame = CFrame.new(track[i])
        task.wait(speed)
    end
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MT_Arunika"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 300)
Frame.Position = UDim2.new(0.5, -150, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "MT Arunika"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.TextScaled = true

local speedBox = Instance.new("TextBox", Frame)
speedBox.Size = UDim2.new(0.9, 0, 0, 40)
speedBox.Position = UDim2.new(0.05, 0, 0, 40)
speedBox.PlaceholderText = "Speed (default 0.01)"
speedBox.Text = tostring(speed)
speedBox.TextColor3 = Color3.fromRGB(180, 180, 180)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBox.TextScaled = true
speedBox.ClearTextOnFocus = false

speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(speedBox.Text)
        if val and val > 0 then
            speed = val
        else
            speedBox.Text = tostring(speed)
        end
    end
end)

-- Scrollable Button Frame
local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(0.9, 0, 0, 180)
Scroll.Position = UDim2.new(0.05, 0, 0, 75)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 240)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Track Order
local orderedTrackNames = {
    "BC - 1", "CP 1 - CP 2", "CP 2 - CP 3",
    "CP 3 - CP 4", "CP 4 - CP 5", "CP 5 - SUMMIT"
}

-- Individual Track Buttons
for _, name in ipairs(orderedTrackNames) do
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextScaled = true

    btn.MouseButton1Click:Connect(function()
        if running then return end
        running = true
        coroutine.wrap(function()
            playTrack(savedTracks[name])
            running = false
        end)()
    end)
end

-- Auto Summit Button
local autoBtn = Instance.new("TextButton", Scroll)
autoBtn.Size = UDim2.new(1, 0, 0, 35)
autoBtn.Text = "Auto Summit"
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 30, 0)
autoBtn.TextColor3 = Color3.fromRGB(180, 255, 180)
autoBtn.TextScaled = true

-- Respawn function using Health = 0
local function respawnPlayer()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
    player.CharacterAdded:Wait()
end

-- Auto Summit logic
local function autoSummit()
    if running then return end
    running = true
    while running do
        for _, name in ipairs(orderedTrackNames) do
            if not running then return end
            playTrack(savedTracks[name])
            if not running then return end
            task.wait(8) -- wait between tracks
        end
        task.wait(3) -- wait before respawn
        if not running then return end
        respawnPlayer()
        task.wait(2) -- wait for character to load
    end
end

autoBtn.MouseButton1Click:Connect(function()
    if running then return end
    coroutine.wrap(function()
        autoSummit()
        running = false
    end)()
end)

-- STOP Button
local stopBtn = Instance.new("TextButton", Frame)
stopBtn.Size = UDim2.new(0.9, 0, 0, 40)
stopBtn.Position = UDim2.new(0.05, 0, 0, 240)
stopBtn.Text = "STOP"
stopBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
stopBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
stopBtn.TextScaled = true

stopBtn.MouseButton1Click:Connect(function()
    running = false
end)

-- Minimize Button
local closeBtn = Instance.new("TextButton", Frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    local logoBtn = Instance.new("TextButton", ScreenGui)
    logoBtn.Size = UDim2.new(0, 40, 0, 40)
    logoBtn.Position = UDim2.new(0, 50, 0, 50)
    logoBtn.Text = "Fyy"
    logoBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoBtn.TextScaled = true
    Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

    logoBtn.MouseButton1Click:Connect(function()
        Frame.Visible = true
        logoBtn:Destroy()
    end)
end)

-- Drag Function
local function setupDrag(target)
    local dragging, dragStart, startPos
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    target.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end
setupDrag(Frame)
