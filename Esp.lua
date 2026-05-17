-- Авто-телепорт к луту с кнопкой включения/выключения
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === НАСТРОЙКИ ===
local CHECK_INTERVAL = 0.3
local TELEPORT_OFFSET = Vector3.new(0, 2, 0)
local DISTANCE_THRESHOLD = 3

-- === ПОИСК ПАПКИ С ЛУТОМ ===
local LOOT_FOLDER = workspace:FindFirstChild("Loot")
if not LOOT_FOLDER then
    LOOT_FOLDER = workspace:FindFirstChild("loot")
end
if not LOOT_FOLDER then
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild("Loot") then
            LOOT_FOLDER = child.Loot
            break
        end
    end
end

if not LOOT_FOLDER then
    warn("Папка Loot не найдена!")
    return
end

-- === СОЗДАНИЕ КНОПКИ ===
local gui = Instance.new("ScreenGui")
gui.Name = "AutoLootGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0, 10, 1, -60)  -- левый нижний угол
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Text = "🔘 АВТО ЛУТ: ВКЛ"
button.Parent = gui

-- Можно перетаскивать кнопку (зажал и двигаешь)
local dragging = false
local dragStartPos
local buttonStartPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        buttonStartPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        button.Position = UDim2.new(
            buttonStartPos.X.Scale,
            buttonStartPos.X.Offset + delta.X,
            buttonStartPos.Y.Scale,
            buttonStartPos.Y.Offset + delta.Y
        )
    end
end)

-- === ЛОГИКА ТЕЛЕПОРТА ===
local enabled = true
local connectionCount = 0
local childAddedConnection = nil
local heartbeatConnection = nil

local function teleportToPart(targetPart)
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart and targetPart and targetPart.Parent then
        local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
        if distance > DISTANCE_THRESHOLD then
            humanoidRootPart.CFrame = CFrame.new(targetPart.Position + TELEPORT_OFFSET)
            print("Телепорт к:", targetPart.Parent.Name)
        end
    end
end

local function processLoot(lootModel)
    if not enabled then return end
    task.wait(0.05)
    
    local targetPart = lootModel.PrimaryPart
    if not targetPart then
        targetPart = lootModel:FindFirstChildWhichIsA("BasePart")
    end
    
    if targetPart then
        teleportToPart(targetPart)
    end
end

local function onLootAdded(loot)
    processLoot(loot)
end

local function enableAutoLoot()
    if enabled then return end
    enabled = true
    button.Text = "🔘 АВТО ЛУТ: ВКЛ"
    button.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
    
    childAddedConnection = LOOT_FOLDER.ChildAdded:Connect(onLootAdded)
    
    -- Обработка уже существующего лута
    for _, loot in pairs(LOOT_FOLDER:GetChildren()) do
        task.spawn(function() processLoot(loot) end)
    end
end

local function disableAutoLoot()
    if not enabled then return end
    enabled = false
    button.Text = "⭕ АВТО ЛУТ: ВЫКЛ"
    button.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    
    if childAddedConnection then
        childAddedConnection:Disconnect()
        childAddedConnection = nil
    end
end

button.MouseButton1Click:Connect(function()
    if enabled then
        disableAutoLoot()
    else
        enableAutoLoot()
    end
end)

-- Запускаем по умолчанию
enableAutoLoot()

print("Скрипт загружен! Кнопка в левом нижнем углу")
