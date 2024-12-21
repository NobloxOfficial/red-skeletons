local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables
local framesEnabled = true
local tracersEnabled = true

local function createSkeletonEspAndTracerForCharacter(character, localCharacter)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local head = character:WaitForChild("Head")
    local torso = character:WaitForChild("UpperTorso") or character:WaitForChild("Torso")
    local leftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("LeftArm")
    local rightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("RightArm")
    local leftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("LeftLeg")
    local rightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("RightLeg")
    local leftLowerArm = character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("LeftForearm")
    local rightLowerArm = character:FindFirstChild("RightLowerArm") or character:FindFirstChild("RightForearm")
    local leftLowerLeg = character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("LeftShin")
    local rightLowerLeg = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("RightShin")

    
    

    -- Update frame color and line position every frame
    local function updateEsp()
        if character.Parent and localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
            local rootPosition = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            local headPosition = Camera:WorldToViewportPoint(head.Position)
            local torsoPosition = Camera:WorldToViewportPoint(torso.Position)
            local leftUpperArmPosition = leftUpperArm and Camera:WorldToViewportPoint(leftUpperArm.Position) or torsoPosition
            local rightUpperArmPosition = rightUpperArm and Camera:WorldToViewportPoint(rightUpperArm.Position) or torsoPosition
            local leftUpperLegPosition = leftUpperLeg and Camera:WorldToViewportPoint(leftUpperLeg.Position) or rootPosition
            local rightUpperLegPosition = rightUpperLeg and Camera:WorldToViewportPoint(rightUpperLeg.Position) or rootPosition
            local leftLowerArmPosition = leftLowerArm and Camera:WorldToViewportPoint(leftLowerArm.Position) or leftUpperArmPosition
            local rightLowerArmPosition = rightLowerArm and Camera:WorldToViewportPoint(rightLowerArm.Position) or rightUpperArmPosition
            local leftLowerLegPosition = leftLowerLeg and Camera:WorldToViewportPoint(leftLowerLeg.Position) or leftUpperLegPosition
            local rightLowerLegPosition = rightLowerLeg and Camera:WorldToViewportPoint(rightLowerLeg.Position) or rightUpperLegPosition

            -- Head to torso
            lines[1].From = Vector2.new(torsoPosition.X, torsoPosition.Y)
            lines[1].To = Vector2.new(headPosition.X, headPosition.Y)

            -- Torso to hips
            lines[2].From = Vector2.new(torsoPosition.X, torsoPosition.Y)
            lines[2].To = Vector2.new(rootPosition.X, rootPosition.Y)

            -- Left arm
            lines[3].From = Vector2.new(torsoPosition.X, torsoPosition.Y)
            lines[3].To = Vector2.new(leftUpperArmPosition.X, leftUpperArmPosition.Y)
            lines[4].From = Vector2.new(leftUpperArmPosition.X, leftUpperArmPosition.Y)
            lines[4].To = Vector2.new(leftLowerArmPosition.X, leftLowerArmPosition.Y)

            -- Right arm
            lines[5].From = Vector2.new(torsoPosition.X, torsoPosition.Y)
            lines[5].To = Vector2.new(rightUpperArmPosition.X, rightUpperArmPosition.Y)
            lines[6].From = Vector2.new(rightUpperArmPosition.X, rightUpperArmPosition.Y)
            lines[6].To = Vector2.new(rightLowerArmPosition.X, rightLowerArmPosition.Y)

            -- Left leg
            lines[7].From = Vector2.new(rootPosition.X, rootPosition.Y)
            lines[7].To = Vector2.new(leftUpperLegPosition.X, leftUpperLegPosition.Y)
            lines[8].From = Vector2.new(leftUpperLegPosition.X, leftUpperLegPosition.Y)
            lines[8].To = Vector2.new(leftLowerLegPosition.X, leftLowerLegPosition.Y)

            -- Right leg
            lines[9].From = Vector2.new(rootPosition.X, rootPosition.Y)
            lines[9].To = Vector2.new(rightUpperLegPosition.X, rightUpperLegPosition.Y)
            lines[10].From = Vector2.new(rightUpperLegPosition.X, rightUpperLegPosition.Y)
            lines[10].To = Vector2.new(rightLowerLegPosition.X, rightLowerLegPosition.Y)

            for _, line in ipairs(lines) do
                line.Visible = framesEnabled
            end

            -- Update tracer position
            local localRootPosition = Camera:WorldToViewportPoint(localCharacter.HumanoidRootPart.Position)
            tracer.From = Vector2.new(localRootPosition.X, localRootPosition.Y)
            tracer.To = Vector2.new(rootPosition.X, rootPosition.Y)
            tracer.Visible = tracersEnabled
        else
            for _, line in ipairs(lines) do
                line.Visible = false
            end
            tracer.Visible = false
        end
    end

    RunService.RenderStepped:Connect(updateEsp)
end

local function onCharacterAdded(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            createSkeletonEspAndTracerForCharacter(character, LocalPlayer.Character)
        end)
        if player.Character then
            createSkeletonEspAndTracerForCharacter(player.Character, LocalPlayer.Character)
        end
    end
end

-- Apply skeleton ESP and tracers to the local player's character
local function onLocalCharacterAdded(character)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createSkeletonEspAndTracerForCharacter(player.Character, character)
        end
    end
end

-- Connect to local player's character spawning
LocalPlayer.CharacterAdded:Connect(onLocalCharacterAdded)
if LocalPlayer.Character then
    onLocalCharacterAdded(LocalPlayer.Character)
end

-- Connect to other players' characters spawning
Players.PlayerAdded:Connect(onCharacterAdded)
for _, player in pairs(Players:GetPlayers()) do
    onCharacterAdded(player)
end

-- Clean up frames and tracers when characters are removed
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do
            if item:IsA("BillboardGui") or item:IsA("Line") then
                item:Destroy()
            end
        end
    end
end)

-- Create a cleaner UI for toggling frames and tracers
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local function createStyledButton(text, position)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Darker grey
    button.BackgroundTransparency = 0.5
    button.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Bright red
    button.BorderSizePixel = 1
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.AutoButtonColor = false

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = button

    button.Parent = ScreenGui
    return button
end

local framesButton = createStyledButton("Toggle ESP", UDim2.new(1, -200, 0, 10))
framesButton.MouseButton1Click:Connect(function()
    framesEnabled = not framesEnabled
    framesButton.BackgroundColor3 = framesEnabled and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 0, 0)
end)

local tracersButton = createStyledButton("Toggle Tracers", UDim2.new(1, -200, 0, 60))
tracersButton.MouseButton1Click:Connect(function()
    tracersEnabled = not tracersEnabled
    tracersButton.BackgroundColor3 = tracersEnabled and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 0, 0)
end)

ScreenGui.Parent = LocalPlayer.PlayerGui
