-- Телепорт ко всем предметам лута на карте
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Создаём интерфейс
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "LootCollectorGUI"

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, -25)
button.Text = "Телепорт к луту"
button.BackgroundColor3 = Color3.fromRGB(170, 0, 170)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 20

-- Функция телепортации ко всем предметам по очереди
local function teleportToLoot()
    -- Ищем папку Loot (возможные пути)
    local lootFolder = workspace:FindFirstChild("Loot") 
        or workspace:FindFirstChild("Drops") 
        or workspace:FindFirstChild("Items")

    -- Если папка не найдена, ищем по всем объектам в workspace
    if not lootFolder then
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Folder") and child.Name:lower():find("loot") then
                lootFolder = child
                break
            end
        end
    end

    if not lootFolder then
        warn("Папка с лутом не найдена! Проверьте название в игре.")
        return
    end

    local items = lootFolder:GetChildren()
    if #items == 0 then
        print("Нет предметов для сбора.")
        return
    end

    -- Телепортируемся к каждому предмету с задержкой
    local delayTime = 0.5 -- Задержка между телепортами (секунды)
    
    for i, item in ipairs(items) do
        if item:IsA("BasePart") then
            task.wait(delayTime)
            humanoidRootPart.CFrame = CFrame.new(item.Position + Vector3.new(0, 3, 0))
            print("Телепорт к: " .. item.Name .. " (" .. i .. "/" .. #items .. ")")
        end
    end
end

button.MouseButton1Click:Connect(teleportToLoot)
