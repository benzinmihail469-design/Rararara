--[[
    GUI Script for Roblox
    Based on Neverlose Design Reference
    Uses the provided library.lua
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/library.lua"))() -- Убедись, что путь правильный или используй локальный файл, если он уже загружен
-- В данном случае предполагается, что библиотека уже загружена и находится в переменной Library

-- Проверка на наличие библиотеки
if not Library then
    warn("Library not found. Please ensure library.lua is loaded correctly.")
    return
end

-- Создание главного окна
local Window = Library:Window({
    Name = "Neverlose",
    SubName = "Cheat by @user",
    Logo = "rbxassetid://12187365364" -- Замени на подходящий ID логотипа
})

-- Функция для создания иконок (заглушка, реальные ID нужно подобрать)
local function getIcon(name)
    local icons = {
        Aimbot = "rbxassetid://12345678",
        Ragebot = "rbxassetid://87654321",
        ["Anti Aim"] = "rbxassetid://11223344",
        Legitbot = "rbxassetid://44332211",
        Visuals = "rbxassetid://55667788",
        Players = "rbxassetid://88776655",
        Weapon = "rbxassetid://99887766",
        Grenades = "rbxassetid://66778899",
        World = "rbxassetid://33445566",
        View = "rbxassetid://22334455",
        Miscellaneous = "rbxassetid://11002233",
        Main = "rbxassetid://33002211",
        Inventory = "rbxassetid://44005566",
        Scripts = "rbxassetid://55006677",
        Configs = "rbxassetid://66007788",
    }
    return icons[name] or "rbxassetid://12187365364" -- fallback icon
end

-- Создание вкладок (Tabs)
local tabAimbot = Window:Page({Name = "Aimbot", Icon = getIcon("Aimbot")})
local tabRagebot = Window:Page({Name = "Ragebot", Icon = getIcon("Ragebot")})
local tabAntiAim = Window:Page({Name = "Anti Aim", Icon = getIcon("Anti Aim")})
local tabLegitbot = Window:Page({Name = "Legitbot", Icon = getIcon("Legitbot")})
local tabVisuals = Window:Page({Name = "Visuals", Icon = getIcon("Visuals")})
local tabPlayers = Window:Page({Name = "Players", Icon = getIcon("Players")})
local tabWeapon = Window:Page({Name = "Weapon", Icon = getIcon("Weapon")})
local tabGrenades = Window:Page({Name = "Grenades", Icon = getIcon("Grenades")})
local tabWorld = Window:Page({Name = "World", Icon = getIcon("World")})
local tabView = Window:Page({Name = "View", Icon = getIcon("View")})
local tabMiscellaneous = Window:Page({Name = "Miscellaneous", Icon = getIcon("Miscellaneous")})
local tabMain = Window:Page({Name = "Main", Icon = getIcon("Main")})
local tabInventory = Window:Page({Name = "Inventory", Icon = getIcon("Inventory")})
local tabScripts = Window:Page({Name = "Scripts", Icon = getIcon("Scripts")})
local tabConfigs = Window:Page({Name = "Configs", Icon = getIcon("Configs")})

-- Создание секций и элементов для вкладки "Aimbot"
local aimbotSection = tabAimbot:Section({Name = "Aimbot Settings", Side = 1})

-- Toggle
local aimbotToggle = aimbotSection:Toggle({
    Name = "Enable Aimbot",
    Flag = "AimbotEnabled",
    Default = false,
    Callback = function(value)
        print("Aimbot enabled:", value)
    end
})

-- Slider
aimbotSection:Slider({
    Name = "FOV",
    Flag = "AimbotFOV",
    Default = 30,
    Min = 0,
    Max = 180,
    Suffix = "°",
    Decimals = 1,
    Callback = function(value)
        print("FOV set to:", value)
    end
})

-- Dropdown
aimbotSection:Dropdown({
    Name = "Target Selection",
    Flag = "AimbotTarget",
    Default = "Closest",
    Items = {"Closest", "Lowest Health", "Highest Health", "Crosshair"},
    Callback = function(value)
        print("Target selection:", value)
    end
})

-- Colorpicker
aimbotSection:Label("Aimbot Color"):Colorpicker({
    Flag = "AimbotColor",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Color selected:", color)
    end
})

-- Keybind
aimbotSection:Keybind({
    Name = "Aimbot Key",
    Flag = "AimbotKey",
    Default = Enum.KeyCode.LeftAlt,
    Mode = "Toggle",
    Callback = function(value)
        print("Aimbot toggled:", value)
    end
})

-- Секция для "Miscellaneous" с Movement, Other и About
local miscSection = tabMiscellaneous:Section({Name = "Movement", Side = 1})

-- Toggle для Movement
miscSection:Toggle({
    Name = "Auto Jump",
    Flag = "AutoJump",
    Default = false,
    Callback = function(value) print("Auto Jump:", value) end
})

miscSection:Toggle({
    Name = "Auto Strafe",
    Flag = "AutoStrafe",
    Default = false,
    Callback = function(value) print("Auto Strafe:", value) end
})

miscSection:Slider({
    Name = "Strafe Speed",
    Flag = "StrafeSpeed",
    Default = 50,
    Min = 0,
    Max = 100,
    Suffix = "%",
    Callback = function(value) print("Strafe Speed:", value) end
})

-- Секция "Other"
local otherSection = tabMiscellaneous:Section({Name = "Other", Side = 2})

-- Listbox (как пример для Configs, но разместим здесь для демонстрации)
local listboxExample = otherSection:Listbox({
    Name = "Example List",
    Flag = "ExampleList",
    Items = {"Item 1", "Item 2", "Item 3"},
    Multi = false,
    Callback = function(value) print("Selected:", value) end
})

-- Textbox
otherSection:Textbox({
    Name = "Input Name",
    Flag = "InputName",
    Placeholder = "Enter text...",
    Finished = true,
    Callback = function(value) print("Input:", value) end
})

-- Button
otherSection:Button({
    Name = "Send Notification",
    Callback = function()
        Library:Notification({
            Title = "Success!",
            Description = "You clicked the button!",
            Icon = "rbxassetid://101636617799068",
            Duration = 3
        })
    end
})

-- Search (реализован как часть Listbox через встроенный поиск, покажем отдельно в Configs)
-- Для демонстрации добавим отдельный Search в Configs

-- Секция "About Neverlose"
local aboutSection = tabMiscellaneous:Section({Name = "About Neverlose", Side = 2})
aboutSection:Label("Neverlose.cc - Premium Cheat")
aboutSection:Label("Version: 2.0.1")
aboutSection:Label("Status: Online")

-- Вкладка "Configs" с полноценным управлением
local configsSection = tabConfigs:Section({Name = "Config Manager", Side = 1})

-- Listbox для списка конфигов
local configList = configsSection:Listbox({
    Flag = "ConfigList",
    Items = {},
    Multi = false,
    Callback = function(value)
        print("Config selected:", value)
    end
})

-- Textbox для имени конфига
configsSection:Textbox({
    Name = "Config Name",
    Flag = "ConfigName",
    Placeholder = "Enter config name...",
    Finished = true,
    Callback = function(value) print("Config name:", value) end
})

-- Кнопки управления конфигами
configsSection:Button({
    Name = "Save Config",
    Callback = function()
        local name = Library.Flags["ConfigName"]
        if name and name ~= "" then
            print("Saving config:", name)
            -- Здесь должна быть логика сохранения
            Library:Notification({
                Title = "Config Saved",
                Description = "Config '" .. name .. "' saved successfully!",
                Icon = "rbxassetid://101636617799068",
                Duration = 3
            })
        else
            Library:Notification({
                Title = "Error",
                Description = "Please enter a config name.",
                Icon = "rbxassetid://130510492706892",
                Duration = 3
            })
        end
    end
})

configsSection:Button({
    Name = "Load Config",
    Callback = function()
        local selected = Library.Flags["ConfigList"]
        if selected then
            print("Loading config:", selected)
            Library:Notification({
                Title = "Config Loaded",
                Description = "Config '" .. selected .. "' loaded!",
                Icon = "rbxassetid://101636617799068",
                Duration = 3
            })
        else
            Library:Notification({
                Title = "Error",
                Description = "No config selected.",
                Icon = "rbxassetid://130510492706892",
                Duration = 3
            })
        end
    end
})

configsSection:Button({
    Name = "Delete Config",
    Callback = function()
        local selected = Library.Flags["ConfigList"]
        if selected then
            print("Deleting config:", selected)
            -- Здесь должна быть логика удаления
            Library:Notification({
                Title = "Config Deleted",
                Description = "Config '" .. selected .. "' deleted.",
                Icon = "rbxassetid://101636617799068",
                Duration = 3
            })
        else
            Library:Notification({
                Title = "Error",
                Description = "No config selected.",
                Icon = "rbxassetid://130510492706892",
                Duration = 3
            })
        end
    end
})

configsSection:Button({
    Name = "Refresh List",
    Callback = function()
        print("Refreshing config list...")
        -- Здесь должна быть логика обновления списка
        -- Для примера просто добавим фиктивные элементы
        local dummyConfigs = {"config1.json", "config2.json", "config3.json"}
        configList:Refresh(dummyConfigs)
        Library:Notification({
            Title = "Refreshed",
            Description = "Config list updated.",
            Icon = "rbxassetid://101636617799068",
            Duration = 2
        })
    end
})

-- Добавим несколько демо-конфигов в список для примера
task.wait(0.5) -- Даем время на инициализацию
local demoConfigs = {"default.json", "rage.json", "legit.json", "hvh.json"}
configList:Refresh(demoConfigs)

-- Создание водяного знака (Watermark)
Library:Watermark({
    "Neverlose",
    "CC",
    "v2.0"
})

-- Создание списка биндов (Keybind List) в правом верхнем углу
local keybindList = Library:KeybindList("Keybinds")
keybindList:SetVisibility(false) -- По умолчанию скрыт

-- Добавляем кнопку для отображения списка биндов в настройках
-- Для этого создадим секцию "UI Settings" в отдельной вкладке или используем существующую
-- Например, вкладка Main
local mainSection = tabMain:Section({Name = "UI Settings", Side = 1})
mainSection:Toggle({
    Name = "Show Keybinds",
    Flag = "ShowKeybinds",
    Default = false,
    Callback = function(value)
        keybindList:SetVisibility(value)
    end
})

-- Пример добавления биндов в список (они автоматически будут отображаться)
-- Предположим, что бинды создаются в других частях скрипта, но мы можем добавить демо-бинды
task.wait(1) -- Ждем инициализации
local demoKeybind = keybindList:Add("Aimbot", "LeftAlt")
demoKeybind:SetStatus(true)

-- Функция для сворачивания окна (минимизация)
-- В библиотеке нет встроенной функции минимизации, реализуем вручную
local minimized = false
local originalSize = Window.Items.MainFrame.Instance.Size
local originalPosition = Window.Items.MainFrame.Instance.Position
local minimizedSize = UDim2.new(0, 50, 0, 50) -- Маленькая иконка

-- Функция для сворачивания/разворачивания
local function toggleMinimize()
    minimized = not minimized
    local mainFrame = Window.Items.MainFrame.Instance
    if minimized then
        -- Сохраняем текущие размер и позицию
        originalSize = mainFrame.Size
        originalPosition = mainFrame.Position
        -- Уменьшаем окно
        mainFrame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = minimizedSize,
            Position = UDim2.new(0, 10, 1, -60) -- В правый нижний угол
        })
        -- Скрываем содержимое
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= mainFrame then
                child.Visible = false
            end
        end
    else
        -- Восстанавливаем размер и позицию
        mainFrame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = originalSize,
            Position = originalPosition
        })
        -- Показываем содержимое
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= mainFrame then
                child.Visible = true
            end
        end
    end
end

-- Добавляем кнопки управления окном (в правом верхнем углу)
-- Они уже есть в библиотеке (CloseButton и SettingsButton), но мы можем добавить минимизацию
-- Модифицируем существующую кнопку или добавим новую
-- Поскольку библиотека уже предоставляет CloseButton, мы можем добавить новую кнопку рядом

-- Создаем новую кнопку для минимизации
local minimizeButton = Instances:Create("TextButton", {
    Parent = Window.Items.MainFrame.Instance,
    Name = "MinimizeButton",
    FontFace = Library.Font,
    TextColor3 = Color3.fromRGB(0, 0, 0),
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    Text = "",
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(1, 0),
    BorderSizePixel = 0,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(1, -98, 0, 11), -- Рядом с кнопкой закрытия
    Size = UDim2.new(0, 32, 0, 32),
    ZIndex = 2,
    TextSize = 14,
    BackgroundColor3 = Color3.fromRGB(27, 25, 29)
})
minimizeButton:AddToTheme({BackgroundColor3 = "Element"})

local minimizeIcon = Instances:Create("ImageLabel", {
    Parent = minimizeButton,
    Name = "MinimizeIcon",
    ImageColor3 = Color3.fromRGB(240, 240, 240),
    ImageTransparency = 0.3,
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    Size = UDim2.new(0, 12, 0, 12),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Image = "rbxassetid://130510492706892", -- Временная иконка, замени на подходящую
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    ZIndex = 3,
    BorderSizePixel = 0,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
})
minimizeIcon:AddToTheme({ImageColor3 = "Text"})

-- Сделаем кнопку минимизации кликабельной
minimizeButton.MouseButton1Down:Connect(function()
    toggleMinimize()
end)

-- Добавляем возможность перетаскивания за заголовок
-- В библиотеке уже есть MakeDraggable, но он применяется ко всему окну
-- Мы можем ограничить перетаскивание только верхней частью

-- Для этого создадим невидимую область для перетаскивания в верхней части окна
local dragArea = Instances:Create("Frame", {
    Parent = Window.Items.MainFrame.Instance,
    Name = "DragArea",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 55),
    ZIndex = 10,
    BorderSizePixel = 0,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
})

-- Применяем draggable к этой области
local dragFrame = {
    Instance = dragArea
}
setmetatable(dragFrame, {__index = Instances})
dragFrame:MakeDraggable()

-- Инициализация окон
Window:Init()

print("GUI Loaded Successfully!")
