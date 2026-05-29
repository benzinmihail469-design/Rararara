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

-- Создаём несколько GUI с разным приоритетом
local backgroundGui = Instance.new("ScreenGui")
backgroundGui.Name = "BackgroundGUI"
backgroundGui.DisplayOrder = 1  -- Нижний приоритет
backgroundGui.Parent = game.Players.LocalPlayer.PlayerGui

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "MainGUI"
mainGui.DisplayOrder = 2  -- Средний приоритет
mainGui.Parent = game.Players.LocalPlayer.PlayerGui

local popupGui = Instance.new("ScreenGui")
popupGui.Name = "PopupGUI"
popupGui.DisplayOrder = 100  -- Высокий приоритет (поверх всех)
popupGui.Parent = game.Players.LocalPlayer.PlayerGui

-- Чем выше DisplayOrder, тем выше GUI
-- GUI с DisplayOrder = 100 будет поверх GUI с DisplayOrder = 1
