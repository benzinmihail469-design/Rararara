-- 1. Загружаем библиотеку
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/J0se-j/My-Lua-Library/refs/heads/main/Booting-the-library.lua"))()

-- 2. Создаем главное окно (с настройками сохранения)
local Window = Library:CreateWindow({
    Name = "Мой Супер Скрипт",        -- Название вашего меню
    LoadingTitle = "Загрузка...",     -- Текст во время загрузки
    ToggleUIKeybind = Enum.KeyCode.K, -- Какая клавиша открывает/закрывает меню (K)
    ConfigurationSaving = {           -- Сохранение настроек (очень удобно)
        Enabled = true,
        FolderName = "MyCoolScript",  -- Папка, где будут лежать сохранения
        FileName = "Settings"
    }
})

-- 3. Создаем вкладку
local MainTab = Window:CreateTab("Главная", 4483362458) -- Число это ID иконки (необязательно)

-- 4. Внутри вкладки создаем секцию
local Section = MainTab:CreateSection("Управление")

-- 5. Добавляем элементы в секцию

-- Кнопка
Section:CreateButton({
    Name = "Нажми меня!",
    Callback = function()
        print("Кнопка нажата!") -- Здесь пишем ваш код
    end
})

-- Ползунок (Слайдер)
Section:CreateSlider({
    Name = "Громкость",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(Value)
        print("Громкость теперь: " .. Value)
        -- Здесь можно поменять громкость звукам в игре
    end
})
