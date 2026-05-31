local Players = game:GetService("Players")
local localplayer = Players.LocalPlayer
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyGui"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 200)  -- 300x200 пикселей
frame.Position = UDim2.new(0.5, -150, 0.5, -100)  -- Центр экрана
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corners = Instance.new("UICorner")
corners.CornerRadius = UDim.new(0, 12)
corners.Parent = frame

