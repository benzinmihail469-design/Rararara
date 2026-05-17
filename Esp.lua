-- ⚔️ DARK FANTASY GUI для Slime RNG (без ESP) ⚔️
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

-- === НАСТРОЙКИ ТЕЛЕПОРТА ===
local TELEPORT_OFFSET = Vector3.new(0, 2, 0)
local DISTANCE_THRESHOLD = 3
local PLAY_SOUND = true
local SOUND_ID = "rbxassetid://9120384036"

-- === ИГНОР-ЛИСТ ЛУТА ===
local IGNORED_LOOT = {
    -- "Trash",   -- раскомментируй если нужно
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
end

-- === СОЗДАНИЕ ЗВУКА ===
local teleportSound = nil
if PLAY_SOUND then
    teleportSound = Instance.new("Sound")
    teleportSound.SoundId = SOUND_ID
    teleportSound.Volume = 0.4
end

-- === ЦВЕТА ===
local C = {
    BG = Color3.fromRGB(18, 16, 22),
    Header = Color3.fromRGB(28, 24, 38),
    Accent = Color3.fromRGB(138, 92, 200),
    AccentDark = Color3.fromRGB(100, 60, 155),
    Text = Color3.fromRGB(240, 235, 255),
    TextDim = Color3.fromRGB(170, 160, 190),
    Button = Color3.fromRGB(38, 34, 48),
    ButtonHover = Color3.fromRGB(55, 48, 70),
    Red = Color3.fromRGB(180, 60, 80),
    Green = Color3.fromRGB(70, 140, 100),
}

-- === СОЗДАНИЕ ГЛАВНОГО GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkFantasyGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Задний фон (затемнение)
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.6
overlay.Visible = false
overlay.Parent = screenGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 550)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
mainFrame.BackgroundColor3 = C.BG
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = C.Accent
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Заголовок с драгом
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = C.Header
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚔️ SLIME RNG | ТЁМНЫЙ ФАНТАЗИ ⚔️"
title.TextColor3 = C.Text
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundColor3 = C.Red
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.Text
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

-- Кнопка сворачивания
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 1, 0)
minimizeBtn.Position = UDim2.new(1, -80, 0, 0)
minimizeBtn.BackgroundColor3 = C.AccentDark
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = C.Text
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar

-- Кнопка открытия (когда свернуто)
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 60, 0, 60)
openButton.Position = UDim2.new(0, 20, 1, -80)
openButton.BackgroundColor3 = C.Accent
openButton.Text = "⚔️"
openButton.TextColor3 = C.Text
openButton.TextSize = 30
openButton.Font = Enum.Font.GothamBold
openButton.BorderSizePixel = 1
openButton.BorderColor3 = C.AccentDark
openButton.Visible = true
openButton.Parent = screenGui

-- === ВКЛАДКИ ===
local tabButtonsFrame = Instance.new("Frame")
tabButtonsFrame.Size = UDim2.new(1, 0, 0, 45)
tabButtonsFrame.Position = UDim2.new(0, 0, 0, 45)
tabButtonsFrame.BackgroundColor3 = C.Button
tabButtonsFrame.BorderSizePixel = 0
tabButtonsFrame.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 1, -90)
tabContainer.Position = UDim2.new(0, 0, 0, 90)
tabContainer.BackgroundColor3 = C.BG
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

-- Список вкладок
local tabs = {"MAIN", "PLAYER", "INFO", "DISCORD", "НАСТРОЙКИ"}
local currentTab = nil
local tabContents = {}

-- Функция создания вкладки
local function createTab(tabName)
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -20)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 6
    container.ScrollBarImageColor3 = C.Accent
    container.Visible = false
    container.Parent = tabContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = container
    
    return container
end

-- Создаём все вкладки
for _, tab in pairs(tabs) do
    tabContents[tab] = createTab(tab)
end

-- Функция переключения вкладки
local function switchTab(tabName)
    if currentTab then
        tabContents[currentTab].Visible = false
    end
    currentTab = tabName
    tabContents[tabName].Visible = true
end

-- Создаём кнопки вкладок
local tabButtons = {}
for i, tab in pairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, -10)
    btn.Position = UDim2.new(0, 10 + (i-1)*105, 0, 5)
    btn.BackgroundColor3 = C.Button
    btn.Text = tab
    btn.TextColor3 = C.TextDim
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = C.AccentDark
    btn.Parent = tabButtonsFrame
    
    btn.MouseEnter:Connect(function()
        if tabContents[tab].Visible then return end
        btn.BackgroundColor3 = C.ButtonHover
    end)
    btn.MouseLeave:Connect(function()
        if tabContents[tab].Visible then return end
        btn.BackgroundColor3 = C.Button
    end)
    
    btn.MouseButton1Click:Connect(function()
        switchTab(tab)
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = C.Button
            b.TextColor3 = C.TextDim
        end
        btn.BackgroundColor3 = C.AccentDark
        btn.TextColor3 = C.Text
    end)
    
    tabButtons[tab] = btn
end

-- === НАПОЛНЕНИЕ ВКЛАДКИ MAIN ===
local mainTab = tabContents["MAIN"]

-- Статус авто-лута
local autoLootEnabled = true
local lootStatusLabel = Instance.new("TextLabel")
lootStatusLabel.Size = UDim2.new(0, 300, 0, 40)
lootStatusLabel.BackgroundColor3 = C.Button
lootStatusLabel.Text = "🔘 АВТО-ЛУТ: ВКЛЮЧЁН"
lootStatusLabel.TextColor3 = C.Green
lootStatusLabel.TextSize = 16
lootStatusLabel.Font = Enum.Font.GothamBold
lootStatusLabel.Parent = mainTab

local lootToggleBtn = Instance.new("TextButton")
lootToggleBtn.Size = UDim2.new(0, 200, 0, 35)
lootToggleBtn.BackgroundColor3 = C.Accent
lootToggleBtn.Text = "ВЫКЛЮЧИТЬ"
lootToggleBtn.TextColor3 = C.Text
lootToggleBtn.TextSize = 14
lootToggleBtn.Font = Enum.Font.GothamBold
lootToggleBtn.Parent = mainTab

-- Телепорт к ближайшему луту
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0, 250, 0, 45)
teleportBtn.BackgroundColor3 = C.Accent
teleportBtn.Text = "📦 ТЕЛЕПОРТ К БЛИЖАЙШЕМУ ЛУТУ"
teleportBtn.TextColor3 = C.Text
teleportBtn.TextSize = 16
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.Parent = mainTab

-- Радиус поиска
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0, 250, 0, 25)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Радиус поиска: " .. DISTANCE_THRESHOLD
radiusLabel.TextColor3 = C.TextDim
radiusLabel.TextSize = 14
radiusLabel.Parent = mainTab

local radiusSlider = Instance.new("TextButton")
radiusSlider.Size = UDim2.new(0, 200, 0, 30)
radiusSlider.BackgroundColor3 = C.Button
radiusSlider.Text = "▲ УВЕЛИЧИТЬ ▼"
radiusSlider.TextColor3 = C.TextDim
radiusSlider.TextSize = 12
radiusSlider.Parent = mainTab

-- === НАПОЛНЕНИЕ ВКЛАДКИ PLAYER ===
local playerTab = tabContents["PLAYER"]

local playerStats = Instance.new("TextLabel")
playerStats.Size = UDim2.new(0, 350, 0, 100)
playerStats.BackgroundColor3 = C.Button
playerStats.Text = "Загрузка..."
playerStats.TextColor3 = C.Text
playerStats.TextSize = 14
playerStats.TextWrapped = true
playerStats.Parent = playerTab

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 150, 0, 35)
refreshBtn.BackgroundColor3 = C.Accent
refreshBtn.Text = "🔄 ОБНОВИТЬ"
refreshBtn.TextColor3 = C.Text
refreshBtn.TextSize = 14
refreshBtn.Parent = playerTab

-- === НАПОЛНЕНИЕ ВКЛАДКИ INFO ===
local infoTab = tabContents["INFO"]

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(0, 400, 0, 200)
infoText.BackgroundColor3 = C.Button
infoText.Text = "⚔️ SLIME RNG - Тёмный Фантези\n\n📦 Авто-телепорт к луту\n🔊 Звук при телепорте\n🚫 Игнор-лист лута\n\n🎮 Создано специально для Slime RNG"
infoText.TextColor3 = C.TextDim
infoText.TextSize = 14
infoText.TextWrapped = true
infoText.Parent = infoTab

-- === НАПОЛНЕНИЕ ВКЛАДКИ DISCORD ===
local discordTab = tabContents["DISCORD"]

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 300, 0, 50)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "💬 ПРИСОЕДИНИТЬСЯ К DISCORD"
discordBtn.TextColor3 = C.Text
discordBtn.TextSize = 16
discordBtn.Font = Enum.Font.GothamBold
discordBtn.Parent = discordTab

local discordLink = Instance.new("TextLabel")
discordLink.Size = UDim2.new(0, 300, 0, 30)
discordLink.BackgroundTransparency = 1
discordLink.Text = "discord.gg/slime_rng"
discordLink.TextColor3 = C.Accent
discordLink.TextSize = 14
discordLink.Parent = discordTab

-- === НАПОЛНЕНИЕ ВКЛАДКИ НАСТРОЙКИ ===
local settingsTab = tabContents["НАСТРОЙКИ"]

local themeBtn = Instance.new("TextButton")
themeBtn.Size = UDim2.new(0, 250, 0, 40)
themeBtn.BackgroundColor3 = C.Button
themeBtn.Text = "🎨 СМЕНИТЬ ТЕМУ (в разработке)"
themeBtn.TextColor3 = C.TextDim
themeBtn.TextSize = 14
themeBtn.Parent = settingsTab

local soundToggleBtn = Instance.new("TextButton")
soundToggleBtn.Size = UDim2.new(0, 250, 0, 40)
soundToggleBtn.BackgroundColor3 = C.Button
soundToggleBtn.Text = "🔊 ЗВУК: ВКЛЮЧЁН"
soundToggleBtn.TextColor3 = C.TextDim
soundToggleBtn.TextSize = 14
soundToggleBtn.Parent = settingsTab

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0, 200, 0, 45)
unloadBtn.BackgroundColor3 = C.Red
unloadBtn.Text = "❌ ВЫГРУЗИТЬ ЧИТ"
unloadBtn.TextColor3 = C.Text
unloadBtn.TextSize = 16
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.Parent = settingsTab

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 200, 0, 30)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "Version: 1.0"
versionLabel.TextColor3 = C.TextDim
versionLabel.TextSize = 12
versionLabel.Parent = settingsTab

-- === ЛОГИКА АВТО-ЛУТА ===
local childAddedConnection = nil

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
    if teleportSound then
        teleportSound.Parent = player.Character or player.CharacterAdded:Wait()
        teleportSound:Play()
    end
end

local function teleportToPart(targetPart)
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and targetPart and targetPart.Parent then
        local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
        if distance > DISTANCE_THRESHOLD then
            humanoidRootPart.CFrame = CFrame.new(targetPart.Position + TELEPORT_OFFSET)
            playTeleportSound()
        end
    end
end

local function teleportToNearestLoot()
    if not LOOT_FOLDER then return end
    local nearest = nil
    local nearestDist = math.huge
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, loot in pairs(LOOT_FOLDER:GetChildren()) do
        if loot:IsA("Model") and not shouldIgnore(loot.Name) then
            local part = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = part
                end
            end
        end
    end
    
    if nearest then
        teleportToPart(nearest)
    end
end

local function processLoot(lootModel)
    if not autoLootEnabled then return end
    if shouldIgnore(lootModel.Name) then return end
    task.wait(0.05)
    local targetPart = lootModel.PrimaryPart or lootModel:FindFirstChildWhichIsA("BasePart")
    if targetPart then
        teleportToPart(targetPart)
    end
end

local function onLootAdded(loot)
    if loot:IsA("Model") then
        processLoot(loot)
    end
end

local function enableAutoLoot()
    if autoLootEnabled then return end
    autoLootEnabled = true
    lootStatusLabel.Text = "🔘 АВТО-ЛУТ: ВКЛЮЧЁН"
    lootStatusLabel.TextColor3 = C.Green
    lootToggleBtn.Text = "ВЫКЛЮЧИТЬ"
    if LOOT_FOLDER then
        childAddedConnection = LOOT_FOLDER.ChildAdded:Connect(onLootAdded)
        for _, loot in pairs(LOOT_FOLDER:GetChildren()) do
            task.spawn(function() processLoot(loot) end)
        end
    end
end

local function disableAutoLoot()
    if not autoLootEnabled then return end
    autoLootEnabled = false
    lootStatusLabel.Text = "⭕ АВТО-ЛУТ: ВЫКЛЮЧЕН"
    lootStatusLabel.TextColor3 = C.Red
    lootToggleBtn.Text = "ВКЛЮЧИТЬ"
    if childAddedConnection then
        childAddedConnection:Disconnect()
        childAddedConnection = nil
    end
end

-- Кнопки MAIN
lootToggleBtn.MouseButton1Click:Connect(function()
    if autoLootEnabled then disableAutoLoot() else enableAutoLoot() end
end)

teleportBtn.MouseButton1Click:Connect(function()
    teleportToNearestLoot()
end)

radiusSlider.MouseButton1Click:Connect(function()
    DISTANCE_THRESHOLD = (DISTANCE_THRESHOLD % 20) + 3
    radiusLabel.Text = "Радиус поиска: " .. DISTANCE_THRESHOLD
end)

-- Кнопки PLAYER
local function updatePlayerStats()
    local character = player.Character
    if not character then
        playerStats.Text = "Персонаж не загружен"
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local pos = hrp and hrp.Position or Vector3.zero
    playerStats.Text = string.format(
        "📊 СТАТИСТИКА ИГРОКА\n\n👤 Имя: %s\n📍 Позиция: %.1f, %.1f, %.1f\n❤️ Здоровье: N/A\n💰 Монеты: N/A",
        player.Name, pos.X, pos.Y, pos.Z
    )
end

refreshBtn.MouseButton1Click:Connect(function()
    updatePlayerStats()
end)

-- Кнопки НАСТРОЙКИ
local soundEnabled = PLAY_SOUND
soundToggleBtn.MouseButton1Click:Connect(function()
    soundEnabled = not soundEnabled
    PLAY_SOUND = soundEnabled
    soundToggleBtn.Text = soundEnabled and "🔊 ЗВУК: ВКЛЮЧЁН" or "🔇 ЗВУК: ВЫКЛЮЧЕН"
end)

unloadBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Discord кнопка
discordBtn.MouseButton1Click:Connect(function()
    setclipboard or toclipboard and (setclipboard or toclipboard)("discord.gg/slime_rng")
    discordBtn.Text = "✅ СКОПИРОВАНО!"
    task.wait(1)
    discordBtn.Text = "💬 ПРИСОЕДИНИТЬСЯ К DISCORD"
end)

-- === ДРАГ И ОКНО ===
local dragging = false
local dragStart, frameStart

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale,
            frameStart.X.Offset + delta.X,
            frameStart.Y.Scale,
            frameStart.Y.Offset + delta.Y
        )
    end
end)

-- Управление окном
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tabContainer.Visible = not minimized
    tabButtonsFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 500, 0, 45) or UDim2.new(0, 500, 0, 550)
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    overlay.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    overlay.Visible = true
    openButton.Visible = false
    if minimized then
        minimized = false
        tabContainer.Visible = true
        tabButtonsFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 500, 0, 550)
    end
end)

-- Анимация появления
mainFrame.BackgroundTransparency = 1
overlay.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()

-- Запуск
switchTab("MAIN")
tabButtons["MAIN"].BackgroundColor3 = C.AccentDark
tabButtons["MAIN"].TextColor3 = C.Text
enableAutoLoot()
updatePlayerStats()

print("✅ Dark Fantasy GUI загружен! Нажми кнопку ⚔️ в левом нижнем углу")
