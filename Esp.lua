-- ТВОЙ ПЕРВЫЙ GUI
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")

screenGui.Parent = game.Players.LocalPlayer.PlayerGui
mainFrame.Parent = screenGui

-- Просто сделай его заметным
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Скругли углы (сразу учимся делать красиво)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

print("✅ Моё первое окно создано!")
