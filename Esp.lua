-- ПОИСК WinBlock14 (ИСПРАВЛЕННЫЙ)

local Workspace = game:GetService("Workspace")

local searchQuery = "WinBlock14"

print("🔍 ИЩУ: " .. searchQuery)
print("==========================================")

local foundAny = false

-- Проходим по всем объектам в Workspace
for _, obj in pairs(Workspace:GetDescendants()) do
    -- Проверяем имя
    if obj.Name == searchQuery then
        foundAny = true
        
        -- Определяем тип объекта
        local icon = ""
        if obj:IsA("Folder") then
            icon = "📁"
        elseif obj:IsA("Model") then
            icon = "🧩"
        elseif obj:IsA("Part") or obj:IsA("BasePart") then
            icon = "🔲"
        elseif obj:IsA("Script") then
            icon = "📜"
        else
            icon = "📄"
        end
        
        print(icon .. " Найдено: " .. obj.Name .. " (" .. obj.ClassName .. ")")
        print("   📍 Полный путь: " .. obj:GetFullName())
        
        -- Координаты (если это Part)
        if obj:IsA("BasePart") then
            print("   🎯 Позиция: X=" .. math.floor(obj.Position.X) .. 
                  ", Y=" .. math.floor(obj.Position.Y) .. 
                  ", Z=" .. math.floor(obj.Position.Z))
        end
        
        -- Показываем родителя
        print("   📂 Родитель: " .. obj.Parent.Name)
        print("")
    end
end

if not foundAny then
    print("❌ " .. searchQuery .. " НЕ НАЙДЕН!")
    print("")
    print("📋 Вот что есть в Workspace:")
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("win") or obj.Name:lower():find("block") then
            print("   - " .. obj.Name)
        end
    end
end

print("==========================================")
