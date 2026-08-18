local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Dark/refs/heads/main/Dark%20hab.lua"))()

local Window = Library:Window({Name = "Мое Окно", SubName = "Тестовая сборка"})
local Page = Window:Page({Name = "Главная", Icon = "1234567890"})
local Section = Page:Section("Настройки")

local MyToggle = Section:Toggle({
    Name = "Активировать функцию",
    Flag = "MyToggle",
    Default = true,
    Callback = function(Value)
        print("Переключатель: " .. tostring(Value))
    end
})

local MySlider = Section:Slider({
    Name = "Скорость",
    Flag = "Speed",
    Default = 50,
    Min = 0,
    Max = 100,
    Suffix = "%",
    Callback = function(Value)
        print("Скорость: " .. tostring(Value))
    end
})
