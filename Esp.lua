-- [[ Hoshi Hub Remake для Murder Mystery 2 ]] --
-- Оригинальный дизайн взят из Screenshot_2026-07-01-17-39-20-746_com.android.chrome.jpg

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Sidebar = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")

-- Настройки ScreenGui
ScreenGui.Name = "HoshiHub_MM2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Главное окно
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 330)
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет двигать интерфейс

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

-- Боковое меню (Sidebar)
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Sidebar.Size = UDim2.new(0, 130, 1, 0)

local SidebarCorner = Instance.new("UICorner", Sidebar)
SidebarCorner.CornerRadius = UDim.new(0, 8)

-- Заголовок "Hoshi"
Title.Name = "Title"
Title.Parent = Sidebar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 10)
Title.Size = UDim2.new(0, 100, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoshi"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Список для кнопок в боковом меню
local MenuList = Instance.new("Frame", Sidebar)
MenuList.BackgroundTransparency = 1
MenuList.Position = UDim2.new(0, 0, 0, 50)
MenuList.Size = UDim2.new(1, 0, 1, -50)

UIListLayout.Parent = MenuList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Контентная зона (Основная панель)
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ContentFrame.Position = UDim2.new(0, 140, 0, 10)
ContentFrame.Size = UDim2.new(1, -150, 1, -20)

-- Заголовок секции Фарма
local SectionTitle = Instance.new("TextLabel", ContentFrame)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Size = UDim2.new(1, 0, 0, 25)
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.Text = "AUTO FARM"
SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SectionTitle.TextSize = 14
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

--- Контейнер для функции авто-фарма
local FarmCard = Instance.new("Frame", ContentFrame)
FarmCard.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
FarmCard.Position = UDim2.new(0, 0, 0, 35)
FarmCard.Size = UDim2.new(1, 0, 0, 60)
Instance.new("UICorner", FarmCard).CornerRadius = UDim.new(0, 6)

local FarmLabel = Instance.new("TextLabel", FarmCard)
FarmLabel.BackgroundTransparency = 1
FarmLabel.Position = UDim2.new(0, 15, 0, 0)
FarmLabel.Size = UDim2.new(0, 200, 1, 0)
FarmLabel.Font = Enum.Font.Gotham
FarmLabel.Text = "Auto Farm Coins"
FarmLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmLabel.TextSize = 14
FarmLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Переключатель (Toggle)
local ToggleBtn = Instance.new("TextButton", FarmCard)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleBtn.Position = UDim2.new(1, -65, 0, 17)
ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
ToggleBtn.Text = ""
local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)

local ToggleCircle = Instance.new("Frame", ToggleBtn)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleCircle.Position = UDim2.new(0, 4, 0, 3)
ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)

-- Функция создания вкладки в меню (для визуала)
local function createTab(name, active)
    local Tab = Instance.new("TextButton", MenuList)
    Tab.BackgroundTransparency = 1
    Tab.Size = UDim2.new(1, 0, 0, 35)
    Tab.Font = Enum.Font.Gotham
    Tab.Text = "   " .. name
    Tab.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 140)
    Tab.TextSize = 13
    Tab.TextXAlignment = Enum.TextXAlignment.Left
end

createTab("Farm", true)
createTab("Shop & Gacha", false)
createTab("Settings", false)

-- [[ ЛОГИКА АВТОФАРМА МОНЕТ ДЛЯ MM2 ]] --
local _G = getgenv and getgenv() or _G
_G.CoinFarm = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция плавного перемещения (Tween) к монете
local function teleportToCoin(coin)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        -- Телепортируем персонажа чуть выше монеты для безопасного подбора
        hrp.CFrame = coin.CFrame + Vector3.new(0, 1, 0)
    end
end

-- Основной цикл фарма
task.spawn(function()
    while task.wait(0.5) do
        if _G.CoinFarm then
            -- Ищем контейнер с монетами на карте MM2
            local container = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Innocent")
            local map = container and container:FindFirstChildOfClass("Model")
            local coinContainer = map and (map:FindFirstChild("CoinContainer") or map:FindFirstChild("Coins"))
            
            if coinContainer then
                for _, coin in pairs(coinContainer:GetChildren()) do
                    if _G.CoinFarm and coin:IsA("BasePart") and coin.Name == "Coin_Sub" then
                        teleportToCoin(coin)
                        task.wait(0.3) -- Небольшая задержка, чтобы античит не кикал
                    end
                end
            end
        end
    end
end)

-- Обработка клика по кнопке-переключателю
ToggleBtn.MouseButton1Click:Connect(function()
    _G.CoinFarm = not _G.CoinFarm
    
    if _G.CoinFarm then
        -- Включено (Стиль кнопки меняется на зеленый/активный)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
        ToggleCircle:TweenPosition(UDim2.new(0, 26, 0, 3), "Out", "Linear", 0.1, true)
    else
        -- Выключено
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        ToggleCircle:TweenPosition(UDim2.new(0, 4, 0, 3), "Out", "Linear", 0.1, true)
    end
end)
