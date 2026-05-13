local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SlimeRNGGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🟢 Slime RNG"
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.Parent = mainFrame

local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, -20, 0, 70)
resultLabel.Position = UDim2.new(0, 10, 0, 55)
resultLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
resultLabel.Text = "Нажми Roll"
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextScaled = true
resultLabel.TextColor3 = Color3.new(1,1,1)
resultLabel.Parent = mainFrame

local resultCorner = Instance.new("UICorner")
resultCorner.CornerRadius = UDim.new(0, 10)
resultCorner.Parent = resultLabel

local rollButton = Instance.new("TextButton")
rollButton.Size = UDim2.new(0.8, 0, 0, 45)
rollButton.Position = UDim2.new(0.1, 0, 0, 145)
rollButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
rollButton.Text = "ROLL"
rollButton.Font = Enum.Font.GothamBold
rollButton.TextSize = 24
rollButton.TextColor3 = Color3.new(1,1,1)
rollButton.Parent = mainFrame

local rollCorner = Instance.new("UICorner")
rollCorner.CornerRadius = UDim.new(0, 10)
rollCorner.Parent = rollButton

-- RNG таблица
local slimes = {
    {name = "Common Slime", chance = 50, color = Color3.fromRGB(120,255,120)},
    {name = "Blue Slime", chance = 25, color = Color3.fromRGB(80,170,255)},
    {name = "Golden Slime", chance = 15, color = Color3.fromRGB(255,220,0)},
    {name = "Shadow Slime", chance = 8, color = Color3.fromRGB(120,0,120)},
    {name = "Galaxy Slime", chance = 2, color = Color3.fromRGB(255,0,255)}
}

local function rollSlime()
    local rng = math.random(1,100)
    local count = 0

    for _, slime in ipairs(slimes) do
        count += slime.chance

        if rng <= count then
            return slime
        end
    end
end

rollButton.MouseButton1Click:Connect(function()
    rollButton.Text = "ROLLING..."

    for i = 1, 10 do
        resultLabel.Text = slimes[math.random(1,#slimes)].name
        task.wait(0.05)
    end

    local slime = rollSlime()

    resultLabel.Text = slime.name
    resultLabel.TextColor3 = slime.color

    rollButton.Text = "ROLL"
end)
```

## Что делает скрипт

* Создаёт GUI окно.
* Есть кнопка Roll.
* Выпадает случайный слайм.
* У каждого слайма свой шанс.
* Цвет текста меняется под редкость.

## Куда вставлять

1. Открой Roblox Studio.
2. StarterGui → Insert Object → LocalScript.
3. Вставь код.
4. Запусти игру.
