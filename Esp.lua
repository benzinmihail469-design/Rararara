-- Авто-телепорт к луту с дополнительными функциями
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === НАСТРОЙКИ ===
local TELEPORT_OFFSET = Vector3.new(0, 2, 0)
local DISTANCE_THRESHOLD = 3
local PLAY_SOUND = true  -- звук при телепорте (вкл/выкл)
local SOUND_ID = "rbxassetid://9120384036"  -- ID звука (можно заменить)

-- ⚠️ СПИСОК ЛУТА, КОТОРЫЙ НУЖНО ИГНОРИРОВАТЬ (добавляй названия моделей)
local IGNORED_LOOT = {
    "Trash",      -- пример
    "CommonChest",-- пример
    "Rock",       -- пример
    -- Добавь сюда названия лута, к которому НЕ надо телепортироваться
}

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

-- === СОЗДАНИЕ ЗВУКА (если нужно) ===
local teleportSound = nil
if PLAY_SOUND then
    teleportSound = Instance.new("Sound")
    teleportSound.SoundId = SOUND_ID
    teleportSound.Volume = 0.5
    teleportSound.Parent = player.Character or player.CharacterAdded:Wait()
end

-- === СОЗДАНИЕ КНОПКИ ===
local gui = Instance.new("ScreenGui")
gui.Name = "AutoLootGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 170, 0, 50)
button.Position = UDim2.new(0, 10, 1, -60)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Text = "🔘 АВТО ЛУТ: ВКЛ"
button.Parent = gui

-- Текст статуса (маленький)
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 170, 0, 20)
statusText.Position = UDim2.new(0, 10, 1, -35)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12
statusText.Text = "Игнорируется: " .. #IGNORED_LOOT .. " типов"
statusText.Parent = gui

-- Перетаскивание кнопки
local dragging = false
local dragStartPos, buttonStartPos

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
        statusText.Position = UDim2.new(
            buttonStartPos.X.Scale,
            buttonStartPos.X.Offset + delta.X,
            buttonStartPos.Y.Scale,
            buttonStartPos.Y.Offset + delta.Y + 55
        )
    end
end)

-- === ЛОГИКА ТЕЛЕПОРТА ===
local enabled = true
local childAddedConnection = nil

-- Загрузка сохранённого состояния
local saveKey = "AutoLootEnabled_" .. player.UserId
local savedState = game:GetService("HttpService"):JSONDecode(setting:GetValue(saveKey) or "true")
enabled = (savedState == true)

if not enabled then
    button.Text = "⭕ АВТО ЛУТ: ВЫКЛ"
    button.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
end

local function shouldIgnore(lootName)
    for _, name in pairs(IGNORED_LOOT) do
        if lootName:find(name) then
            return true
        end
    end
    return false
end

local function playTeleportSound()
    if not PLAY_SOUND then return end
    if not teleportSound or not teleportSound.Parent then
        teleportSound = Instance.new("Sound")
        teleportSound.SoundId = SOUND_ID
        teleportSound.Volume = 0.5
        teleportSound.Parent = player.Character or player.CharacterAdded:Wait()
    end
    teleportSound:Play()
end

local function teleportToPart(targetPart)
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart and targetPart and targetPart.Parent then
        local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
        if distance > DISTANCE_THRESHOLD then
            humanoidRootPart.CFrame = CFrame.new(targetPart.Position + TELEPORT_OFFSET)
            print("✨ Телепорт к:", targetPart.Parent.Name)
            playTeleportSound()
        end
    end
end

local function processLoot(lootModel)
    if not enabled then return end
    if shouldIgnore(lootModel.Name) then
        print("🚫 Игнорируем:", lootModel.Name)
        return
    end
    
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
    if loot:IsA("Model") then
        processLoot(loot)
    end
end

local function saveState()
    local success, err = pcall(function()
        setting:SetValue(saveKey, HttpService:JSONEncode(enabled))
    end)
    if not success then
        warn("Не удалось сохранить состояние:", err)
    end
end

local function enableAutoLoot()
    if enabled then return end
    enabled = true
    button.Text = "🔘 АВТО ЛУТ: ВКЛ"
    button.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
    
    childAddedConnection = LOOT_FOLDER.ChildAdded:Connect(onLootAdded)
    
    for _, loot in pairs(LOOT_FOLDER:GetChildren()) do
        task.spawn(function() processLoot(loot) end)
    end
    
    saveState()
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
    
    saveState()
end

button.MouseButton1Click:Connect(function()
    if enabled then
        disableAutoLoot()
    else
        enableAutoLoot()
    end
end)

-- Запуск с сохранённым состоянием
if enabled then
    enableAutoLoot()
else
    disableAutoLoot()
end

print("✅ Скрипт загружен! Кнопка в левом нижнем углу")
print("📋 Игнорируется типов лута:", #IGNORED_LOOT)
if PLAY_SOUND then
    print("🔊 Звук при телепорте: ВКЛ")
end
