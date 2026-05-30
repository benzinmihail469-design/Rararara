-- ПОИСК WinBlock14 И ВЫВОД КООРДИНАТ

local Workspace = game:GetService("Workspace")

print("🔍 ИЩУ WinBlock14...")
print("==========================================")

local function findWinBlock()
    -- Ищем все объекты с именем WinBlock14
    local allObjects = Workspace:GetDescendants()
    
    for _, obj in pairs(allObjects) do
        if obj.Name == "WinBlock14" then
            print("✅ НАЙДЕНО!")
            print("📌 Имя: " .. obj.Name)
            print("📁 Тип: " .. obj.ClassName)
            print("📍 Путь: " .. obj:GetFullName())
            
            -- Координаты
            if obj:IsA("BasePart") then
                print("🎯 Позиция: X=" .. math.floor(obj.Position.X) .. 
                      ", Y=" .. math.floor(obj.Position.Y) .. 
                      ", Z=" .. math.floor(obj.Position.Z))
            elseif obj:FindFirstChild("HumanoidRootPart") then
                local root = obj.HumanoidRootPart
                print("🎯 Позиция: X=" .. math.floor(root.Position.X) .. 
                      ", Y=" .. math.floor(root.Position.Y) .. 
                      ", Z=" .. math.floor(root.Position.Z))
            elseif obj:FindFirstChild("Head") then
                local head = obj.Head
                print("🎯 Позиция: X=" .. math.floor(head.Position.X) .. 
                      ", Y=" .. math.floor(head.Position.Y) .. 
                      ", Z=" .. math.floor(head.Position.Z))
            else
                print("⚠️ Нет позиции (не BasePart)")
            end
            
            -- Родитель
            print("📂 Родитель: " .. obj.Parent.Name)
            print("")
            
            -- Показываем все части внутри
            print("📦 Содержимое:")
            for _, child in pairs(obj:GetChildren()) do
                print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        end
    end
end

findWinBlock()

print("==========================================")
print("💡 Если ничего не найдено, проверь написание")
print("   Имя должно быть точным: WinBlock14")
