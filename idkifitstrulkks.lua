local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Status fitur
local antiFallDamageEnabled = true

-- Fungsi setup karakter
local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    -- Anti-fall damage
    humanoid.StateChanged:Connect(function(_, newState)
        if not antiFallDamageEnabled then return end
        if newState == Enum.HumanoidStateType.Freefall then
            humanoid:SetAttribute("FallStartY", root.Position.Y)
        elseif newState == Enum.HumanoidStateType.Landed then
            local startY = humanoid:GetAttribute("FallStartY") or root.Position.Y
            local fallDistance = startY - root.Position.Y
            if fallDistance > 20 and humanoid.Health > 0 then
                humanoid.Health = humanoid.Health + humanoid.FloorMaterial
            end
        end
    end)
end

-- Pasang setiap respawn
player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    setupCharacter(player.Character)
end

-- GUI tombol ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 140, 0, 50)
button.Position = UDim2.new(0, 20, 0, 20)
button.Text = "Anti-Fall: ON"
button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = screenGui

button.MouseButton1Click:Connect(function()
    antiFallDamageEnabled = not antiFallDamageEnabled
    if antiFallDamageEnabled then
        button.Text = "Anti-Fall: ON"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        button.Text = "Anti-Fall: OFF"
        button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)
