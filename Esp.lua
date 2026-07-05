--[[
    Это основа твоего GUI без библиотек.
    Используй ScreenGuis, Frames, TextButtons и TextLabels.
    Для функций фарма смотри в сторону RemoteEvent/RemoteFunction.
]]

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Функция для создания базового окна (как у Pulse Hub)
local function CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    -- Эффект прозрачности
    MainFrame.BackgroundTransparency = 0.15

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = TitleBar

    -- Функция для перетаскивания окна
    local dragging = false
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return MainFrame
end

-- Функция для создания кнопок (как разделы Main)
local function CreateButton(parent, text, position, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Position = UDim2.new(0.05, 0, position, 0)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.Gotham
    Button.Parent = parent

    -- Эффект наведения
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
    end)
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end)

    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Создаем окно
local MainGui = CreateWindow("Pulse Hub")

-- Создаем кнопки разделов
local buttonPositions = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7}
local sections = {
    {"Sheriff", function() print("Sheriff functions") end},
    {"Murder", function() print("Murder functions") end},
    {"Auto Farm", function() print("Auto Farm functions") end},
    {"Teleport", function() print("Teleport functions") end},
    {"Fun/Troll", function() print("Fun/Troll functions") end},
    {"Visuals", function() print("Visuals functions") end},
    {"Settings", function() print("Settings functions") end}
}

for i, v in ipairs(sections) do
    CreateButton(MainGui, v[1], buttonPositions[i], v[2])
end

-- Пример подвала с информацией (как в Pulse Hub)
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -20)
Footer.BackgroundTransparency = 1
Footer.Text = "discord.gg/pulsezone | Session 00:00"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.TextScaled = true
Footer.Font = Enum.Font.Gotham
Footer.Parent = MainGui
