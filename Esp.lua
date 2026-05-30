-- ПОИСК WinBlock14 (БЕЗ ОШИБОК)

local Workspace = game:GetService("Workspace")

print("🔍 НАЧИНАЮ ПОИСК WinBlock14...")
print("==========================================")

local found = false

-- Функция для рекурсивного поиска
local function searchForObject(parent, searchName)
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == searchName then
            print("✅ НАЙДЕНО!")
            print("   Имя: " .. child.Name)
            print("   Тип: " .. child.ClassName)
            print("   Путь: " .. child:GetFullName())
            
            if child:IsA("BasePart") then
                print("   Позиция: X=" .. math.floor(child.Position.X) .. 
                      " Y=" .. math.floor(child.Position.Y) .. 
                      " Z=" .. math.floor(child.Position.Z))
            end
            
            print("   Родитель: " .. child.Parent.Name)
            return true
        end
        
        -- Рекурсивно ищем глубже
        if child:GetChildren() and #child:GetChildren() > 0 then
            local deeper = searchForObject(child, searchName)
            if deeper then return true end
        end
    end
    return false
end

-- Запускаем поиск
found = searchForObject(Workspace, "WinBlock14")

if not found then
    print("❌ WinBlock14 НЕ НАЙДЕН")
    print("")
    print("📋 ВОТ ВСЕ ОБЪЕКТЫ В WORKSPACE:")
    
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") then
            count = count + 1
            if count <= 50 then -- Ограничиваем вывод, чтобы не спамить
                print("   " .. count .. ". " .. obj.Name .. " (" .. obj.ClassName .. ")")
            end
        end
    end
    
    if count > 50 then
        print("   ... и ещё " .. (count - 50) .. " объектов")
    end
end

print("==========================================")
