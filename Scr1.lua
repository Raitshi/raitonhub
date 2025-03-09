local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local collectingEnabled = false
local autoStoreEnabled = false
local serverHopEnabled = false
local autoBuyEnabled = false -- Единственная декларация
local FlightSpeed = 350
local espCache = {}
local activeTweens = {}
local collectCoroutine = nil
local lastPurchaseTime = nil
local COOLDOWN_DURATION = 7200 -- 2 часа
local NOTIFICATION_DURATION = 3
local SAVE_FILE = "lastPurchaseTime_" .. player.UserId .. ".txt" -- Уникальный файл для каждого аккаунта

local wantedFruits = {
    ["Kilo Fruit"] = true, ["Spin Fruit"] = true, ["Chop Fruit"] = true, ["Sprint Fruit"] = true,
["Bomb Fruit"] = true, ["Smoke Fruit"] = true, ["Spike Fruit"] = true, ["Flame Fruit"] = true,
["Falcon Fruit"] = true, ["Ice Fruit"] = true, ["Sand Fruit"] = true, ["Dark Fruit"] = true,
["Revive Fruit"] = true, ["Diamond Fruit"] = true, ["Light Fruit"] = true, ["Rubber Fruit"] = true,
["Barrier Fruit"] = true, ["Magma Fruit"] = true, ["Quake Fruit"] = true,["Spider Fruit"] = true, ["Phoenix Fruit"] = true, ["Buddha Fruit"] = true,
["Portal Fruit"] = true, ["Rumble Fruit"] = true, ["Paw Fruit"] = true, ["Blizzard Fruit"] = true,
["Gravity Fruit"] = true, ["Dough Fruit"] = true, ["Shadow Fruit"] = true, ["Venom Fruit"] = true,
["Control Fruit"] = true, ["Spirit Fruit"] = true, ["Dragon Fruit"] = true, ["Leopard Fruit"] = true,
["Kitsune Fruit"] = true, ["T-Rex Fruit"] = true, ["Mammoth Fruit"] = true, ["Gas Fruit"] = true, ["Yeti Fruit"] = true
}

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
end)

local function disableCollisions()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        print("[Коллизии] Коллизии персонажа отключены")
    end
end

local function enableCollisions()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        print("[Коллизии] Коллизии персонажа включены")
    end
end

local function createESP(fruit)
    if espCache[fruit] then return end
    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("Part") or fruit:FindFirstChildOfClass("MeshPart")
    if handle then
        print("[ESP] Создаю ESP для: " .. (fruit.Name == "" and "Безымянный фрукт" or fruit.Name) .. " на " .. tostring(handle.Position))
        local BillboardGui = Instance.new("BillboardGui")
        BillboardGui.Parent = handle
        BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        BillboardGui.AlwaysOnTop = true
        BillboardGui.Size = UDim2.new(0, 100, 0, 50)
        
        local NameLabel = Instance.new("TextLabel", BillboardGui)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        NameLabel.Position = UDim2.new(0, 0, 0, 0)
        NameLabel.Font = Enum.Font.GothamBlack
        NameLabel.TextColor3 = Color3.fromRGB(139, 0, 0)
        NameLabel.TextScaled = true
        NameLabel.TextSize = 30
        NameLabel.TextXAlignment = Enum.TextXAlignment.Center
        NameLabel.Text = "[" .. (fruit.Name == "" and "Безымянный фрукт" or fruit.Name) .. "]"
        NameLabel.TextStrokeTransparency = 0
        NameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        local DistanceLabel = Instance.new("TextLabel", BillboardGui)
        DistanceLabel.BackgroundTransparency = 1
        DistanceLabel.Size = UDim2.new(0, 80, 0, 20)
        DistanceLabel.Position = UDim2.new(0.5, -39, 0.5, -2)
        DistanceLabel.Font = Enum.Font.SourceSansBold
        DistanceLabel.TextSize = 20
        DistanceLabel.TextColor3 = Color3.fromRGB(139, 0, 0)
        DistanceLabel.TextXAlignment = Enum.TextXAlignment.Center
        DistanceLabel.TextStrokeTransparency = 0
        DistanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not handle or not hrp or not BillboardGui.Parent then
                if connection then connection:Disconnect() end
                if BillboardGui then BillboardGui:Destroy() end
                return
            end
            local distance = (hrp.Position - handle.Position).Magnitude
            DistanceLabel.Text = math.floor(distance) .. " м"
        end)

        espCache[fruit] = BillboardGui
    end
end

local function disableESP()
    for fruit, gui in pairs(espCache) do
        gui:Destroy()
    end
    table.clear(espCache)
    print("[ESP] Отключены все ESP")
end

local function stopAllTweens()
    for _, tween in pairs(activeTweens) do
        if tween then
            tween:Cancel()
        end
    end
    table.clear(activeTweens)
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        hrp.Anchored = false
        humanoid.PlatformStand = false
    end
    if collectCoroutine then
        coroutine.close(collectCoroutine)
        collectCoroutine = nil
    end
    print("[Телепорт] Все активные твины и корутина остановлены, коллизии восстановлены")
    enableCollisions()
end

local function storeFruit(fruit)
    if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_") then
        local fruitName = fruit.Name
        local split = string.split(fruitName, " ")
        local word = split[1]
        local args = {
            [1] = "StoreFruit",
            [2] = word .. "-" .. word,
            [3] = fruit
        }
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
        end)
        if success and result then
            print("[Хранение] Успешно сохранён: " .. fruitName)
            return true
        else
            print("[Хранение] Не удалось сохранить: " .. fruitName .. " (Ошибка: " .. (result or "Неизвестно") .. ")")
            return false
        end
    else
        print("[Хранение] CommF_ не найден в ReplicatedStorage.Remotes")
        return false
    end
end

local function collectFruit(fruit)
    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("Part") or fruit:FindFirstChildOfClass("MeshPart")
    if not handle then
        print("[Сбор] Handle не найден для " .. (fruit.Name == "" and "Безымянный фрукт" or fruit.Name))
        return
    end

    local fruitName = fruit.Name == "" and "Безымянный фрукт" or fruit.Name
    print("[Сбор] Пытаюсь собрать: " .. fruitName .. " на " .. tostring(handle.Position))
    local targetPosition = handle.Position + Vector3.new(0, 5, 0)
    local startPosition = hrp.Position
    local distance = (startPosition - targetPosition).Magnitude
    local speed = FlightSpeed

    local duplicateFruit = nil
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name == fruitName then
            duplicateFruit = item
            break
        end
    end
    
    if duplicateFruit then
        print("[Сбор] Найден дубликат фрукта в рюкзаке: " .. duplicateFruit.Name .. ". Сначала сохраню его.")
        if storeFruit(duplicateFruit) then
            task.wait(0.5)
        else
            print("[Сбор] Пропускаю сбор из-за ошибки сохранения")
            return
        end
    end

    if not character or not hrp or not humanoid then
        print("[Ошибка] Персонаж, hrp или humanoid не найдены")
        return
    end

    disableCollisions()
    task.wait(0.1)
    print("[Debug] Коллизии отключены")

    local connection
    local elapsed = 0
    local totalTime = distance / speed
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not hrp or not collectingEnabled or not handle or not handle.Parent then
            if connection then connection:Disconnect() end
            enableCollisions() -- Восстанавливаем коллизии, если фрукт исчез
            print("[Сбор] Телепортация остановлена: фрукт исчез или сбор отключён")
            return
        end

        elapsed = elapsed + deltaTime
        local t = math.min(elapsed / totalTime, 1)
        local newPosition = startPosition:Lerp(targetPosition, t)
        hrp.CFrame = CFrame.new(newPosition)

        if t >= 1 then
            if connection then connection:Disconnect() end
        end
    end)

    repeat task.wait() until not connection.Connected

    enableCollisions()
    print("[Debug] Коллизии включены обратно")

    if collectingEnabled then
        task.wait(0)
        local pickedFruit = player.Backpack:FindFirstChild(fruitName) or character:FindFirstChild(fruitName)
        if pickedFruit then
            print("[Сбор] Успешно подобран фрукт: " .. pickedFruit.Name)
            if espCache[fruit] then
                espCache[fruit]:Destroy()
                espCache[fruit] = nil
            end
        else
            print("[Сбор] Не удалось подобрать фрукт: " .. fruitName)
        end
    end
end

local function findFruits()
    local fruits = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if (obj:IsA("Tool") or obj:IsA("Model")) then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part") or obj:FindFirstChildOfClass("MeshPart")
            if handle and handle:FindFirstChild("TouchInterest") then
                if not CollectionService:HasTag(obj, "PendingFruit") then
                    CollectionService:AddTag(obj, "PendingFruit")
                    print("[Поиск] Помечен потенциальный фрукт: " .. (obj.Name == "" and "Безымянный фрукт" or obj.Name) .. " на " .. tostring(handle.Position))
                end
                table.insert(fruits, obj)
            end
        end
    end
    return fruits
end

local function startAutoCollect()
    while collectingEnabled do
        local fruits = findFruits()
        if #fruits > 0 then
            print("[АвтоСбор] Найдено " .. #fruits .. " фруктов")
            for _, fruit in pairs(fruits) do
                if collectingEnabled then
                    createESP(fruit)
                    collectFruit(fruit)
                    task.wait(1)
                else
                    break
                end
            end
        else
            print("[АвтоСбор] Фрукты на сервере не найдены")
        end
        task.wait(0.1)
    end
end

local function startAutoStore()
    while autoStoreEnabled do
        local pickedFruit = nil
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and wantedFruits[item.Name] then
                pickedFruit = item
                break
            end
        end
        if not pickedFruit then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") and wantedFruits[item.Name] then
                    pickedFruit = item
                    break
                end
            end
        end
        if pickedFruit then
            print("[АвтоХранение] Найден фрукт: " .. pickedFruit.Name)
            storeFruit(pickedFruit)
        end
        task.wait(3)
    end
end

-- Логика автопокупки
local function loadLastPurchaseTime()
    if isfile(SAVE_FILE) then
        local content = readfile(SAVE_FILE)
        local time = tonumber(content)
        if time then
            print("[AutoBuyFruit] Загружено время последней покупки из файла: " .. time)
            return time
        else
            warn("[AutoBuyFruit] Ошибка при чтении файла, время сброшено")
            return nil
        end
    end
    print("[AutoBuyFruit] Файл времени покупки не найден, устанавливаю как nil")
    return nil
end

local function saveLastPurchaseTime(time)
    writefile(SAVE_FILE, tostring(time))
    print("[AutoBuyFruit] Время последней покупки сохранено: " .. time)
end

local function getBeli()
    local maxWaitTime = 10
    local waitTime = 0.5
    local attempts = 0
    local maxAttempts = math.floor(maxWaitTime / waitTime)

    while attempts < maxAttempts do
        if player.Data and player.Data:FindFirstChild("Beli") and player.Data.Beli.Value ~= nil then
            return player.Data.Beli.Value
        end
        print("[AutoBuyFruit] Ожидание загрузки данных Beli... (попытка " .. (attempts + 1) .. "/" .. maxAttempts .. ")")
        task.wait(waitTime)
        attempts = attempts + 1
    end
    warn("[AutoBuyFruit] Не удалось загрузить данные Beli после " .. maxWaitTime .. " секунд")
    return nil
end

local function canBuyFruit()
    if not lastPurchaseTime then
        return true
    end
    local timeSinceLastPurchase = tick() - lastPurchaseTime
    if timeSinceLastPurchase >= COOLDOWN_DURATION then
        print("[AutoBuyFruit] Кулдаун 2 часа закончился, можно снова покупать")
        return true
    else
        local remainingTime = math.ceil(COOLDOWN_DURATION - timeSinceLastPurchase)
        print("[AutoBuyFruit] Кулдаун активен, осталось ждать: " .. remainingTime .. " секунд")
        return false
    end
end

local function showNotification(message, color)
    local ScreenGui = player:WaitForChild("PlayerGui")
    local NotificationFrame = ScreenGui:FindFirstChild("NotificationFrame")
    if not NotificationFrame then
        NotificationFrame = Instance.new("Frame")
        NotificationFrame.Name = "NotificationFrame"
        NotificationFrame.Size = UDim2.new(0, 300, 0, 50)
        NotificationFrame.Position = UDim2.new(0, 10, 0, 10)
        NotificationFrame.BackgroundColor3 = color
        NotificationFrame.BorderSizePixel = 0
        NotificationFrame.Parent = ScreenGui

        local UICorner = Instance.new("UICorner", NotificationFrame)
        UICorner.CornerRadius = UDim.new(0, 10)

        local TextLabel = Instance.new("TextLabel", NotificationFrame)
        TextLabel.Size = UDim2.new(1, -10, 1, -10)
        TextLabel.Position = UDim2.new(0, 5, 0, 5)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextColor3 = Color3.new(1, 1, 1)
        TextLabel.Font = Enum.Font.Code
        TextLabel.TextSize = 16
        TextLabel.Text = message
    else
        NotificationFrame.TextLabel.Text = message
        NotificationFrame.BackgroundColor3 = color
    end

    NotificationFrame.Visible = true
    TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {Position = UDim2.new(0, 10, 0, 70)}):Play()
    
    task.delay(NOTIFICATION_DURATION, function()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {Position = UDim2.new(0, 10, 0, 10)}):Play()
        task.wait(0.5)
        NotificationFrame.Visible = false
    end)
end

local function buyRandomFruit()
    print("[AutoBuyFruit] Проверяю баланс Beli перед покупкой...")
    local beli = getBeli()
    if beli == nil then
        warn("[AutoBuyFruit] Не удалось получить баланс Beli, пропускаю покупку")
        showNotification("Ошибка: Не удалось загрузить Beli", Color3.fromRGB(255, 0, 0))
        return false
    end
    print("[AutoBuyFruit] Текущий баланс Beli: " .. beli)

    local minPrice = 50000
    if beli < minPrice then
        warn("[AutoBuyFruit] Недостаточно Beli для покупки (нужно минимум " .. minPrice .. ")")
        showNotification("Недостаточно Beli (" .. minPrice .. ")", Color3.fromRGB(255, 165, 0))
        return false
    end

    lastPurchaseTime = loadLastPurchaseTime() -- Загружаем перед проверкой
    if not canBuyFruit() then
        showNotification("Кулдаун активен", Color3.fromRGB(255, 165, 0))
        return false
    end

    print("[AutoBuyFruit] Пытаюсь купить случайный фрукт у дилера...")
    showNotification("Попытка покупки...", Color3.fromRGB(255, 255, 0))
    local success, result = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end)

    if success then
        print("[AutoBuyFruit] Результат от дилера: " .. tostring(result) .. " (Тип: " .. typeof(result) .. ")")
        if result == true or (typeof(result) == "string" and result ~= "Cooldown" and result ~= "NotEnoughMoney") then
            print("[AutoBuyFruit] Успешно куплен случайный фрукт!")
            lastPurchaseTime = tick()
            saveLastPurchaseTime(lastPurchaseTime)
            if typeof(result) == "string" then
                print("[AutoBuyFruit] Куплен фрукт: " .. result)
                showNotification("Куплен фрукт: " .. result, Color3.fromRGB(0, 255, 0))
            else
                showNotification("Фрукт успешно куплен!", Color3.fromRGB(0, 255, 0))
            end
            return true
        elseif result == "Cooldown" then
            warn("[AutoBuyFruit] Кулдаун активен, покупка отклонена дилером")
            showNotification("Кулдаун активен", Color3.fromRGB(255, 165, 0))
            lastPurchaseTime = tick()
            saveLastPurchaseTime(lastPurchaseTime)
            return false
        elseif result == "NotEnoughMoney" then
            warn("[AutoBuyFruit] Недостаточно Beli, покупка отклонена")
            showNotification("Недостаточно Beli", Color3.fromRGB(255, 165, 0))
            return false
        else
            warn("[AutoBuyFruit] Неизвестный результат от дилера: " .. tostring(result))
            showNotification("Неизвестная ошибка", Color3.fromRGB(255, 0, 0))
            return false
        end
    else
        warn("[AutoBuyFruit] Ошибка при покупке фрукта: " .. tostring(result))
        showNotification("Ошибка покупки: " .. tostring(result), Color3.fromRGB(255, 0, 0))
        return false
    end
end

local function startAutoBuy()
    print("[AutoBuyFruit] Запуск автоматической покупки случайных фруктов")
    while autoBuyEnabled do
        if game:IsLoaded() then
            -- Обновляем player для нового аккаунта
            local player = game:GetService("Players").LocalPlayer
            if not player then
                print("[AutoBuyFruit] Игрок не найден, жду...")
                task.wait(1)
                continue
            end
            
            local beli = getBeli()
            if beli and beli >= 50000 then -- Минимальная цена фрукта
                print("[AutoBuyFruit] Пытаюсь купить случайный фрукт...")
                local success, result = pcall(function()
                    return ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
                end)
                
                if success then
                    if result == true or (typeof(result) == "string" and result ~= "Cooldown" and result ~= "NotEnoughMoney") then
                        print("[AutoBuyFruit] Успешно куплен фрукт: " .. (typeof(result) == "string" and result or "Неизвестный"))
                        showNotification("Куплен фрукт: " .. (typeof(result) == "string" and result or "Неизвестный"), Color3.fromRGB(0, 255, 0))
                    elseif result == "Cooldown" then
                        print("[AutoBuyFruit] Кулдаун активен, жду следующую попытку")
                    elseif result == "NotEnoughMoney" then
                        print("[AutoBuyFruit] Недостаточно Beli: " .. beli)
                    else
                        print("[AutoBuyFruit] Неизвестный результат: " .. tostring(result))
                    end
                else
                    warn("[AutoBuyFruit] Ошибка покупки: " .. tostring(result))
                end
            else
                print("[AutoBuyFruit] Недостаточно Beli или данные не загружены: " .. tostring(beli))
            end
        else
            print("[AutoBuyFruit] Игра не загружена, жду...")
            game.Loaded:Wait()
        end
        -- Задержка 5 минут (300 секунд) между попытками
        local elapsed = 0
        while elapsed < 30 and autoBuyEnabled do
            task.wait(1)
            elapsed = elapsed + 1
        end
    end
    print("[AutoBuyFruit] Автоматическая покупка остановлена")
end
game.DescendantAdded:Connect(function(child)
    if (child:IsA("Tool") or child:IsA("Model")) then
        local handle = child:FindFirstChild("Handle") or child:FindFirstChildOfClass("Part") or child:FindFirstChildOfClass("MeshPart")
        if handle and handle:FindFirstChild("TouchInterest") then
            if not CollectionService:HasTag(child, "PendingFruit") then
                CollectionService:AddTag(child, "PendingFruit")
                print("[DescendantAdded] Новый потенциальный фрукт: " .. (child.Name == "" and "Безымянный фрукт" or child.Name) .. " на " .. tostring(handle.Position))
            end
            if collectingEnabled then
                createESP(child)
                collectFruit(child)
            end
        end
    end
end)

-- Server Hop логика
local BLOX_FRUITS_PLACE_ID = 2753915549
local visitedServers = {}
local ServerHopSettings = {}
local ServerHopFileName = "bloxfruitsServerHop.json"
local lastResetTime = tick()

local function SaveServerHopSettings()
    local HttpService = game:GetService("HttpService")
    writefile(ServerHopFileName, HttpService:JSONEncode(ServerHopSettings))
end

local function ReadServerHopSettings()
    local s, e = pcall(function()
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONDecode(readfile(ServerHopFileName))
    end)
    if s then
        return e
    else
        SaveServerHopSettings()
        return ReadServerHopSettings()
    end
end
ServerHopSettings = ReadServerHopSettings()

local function resetVisitedServers()
    if tick() - lastResetTime >= 3600 then
        print("[NewServerHop] Прошёл час, обнуляю список посещённых серверов")
        visitedServers = {}
        ServerHopSettings = {}
        SaveServerHopSettings()
        lastResetTime = tick()
    end
end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Предполагается, что эти переменные определены
local serverHopEnabled = true -- Переключатель, который вы используете
local visitedServers = {} or {}
local ServerHopSettings = {} or {}
local BLOX_FRUITS_PLACE_ID = 2753915549 -- PlaceID для Blox Fruits
local function SaveServerHopSettings() end -- Функция для сохранения настроек, если она определена
local function resetVisitedServers() visitedServers = {} end
local function showNotification(message, color)
    -- Предполагается, что эта функция определена в вашем GUI
    print("Уведомление: " .. message) -- Замените на реальную функцию, если есть
end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Предполагается, что эти переменные определены
local serverHopEnabled = true -- Переключатель
local visitedServers = {} or {}
local ServerHopSettings = {} or {}
local BLOX_FRUITS_PLACE_ID = 2753915549 -- PlaceID для Blox Fruits
local function SaveServerHopSettings() end -- Функция для сохранения настроек
local function resetVisitedServers() visitedServers = {} end
local function showNotification(message, color)
    -- Предполагается, что эта функция определена в вашем GUI
    print("Уведомление: " .. message) -- Замените на реальную функцию, если есть
end
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BLOX_FRUITS_PLACE_ID = 2753915549 -- PlaceID для Blox Fruits
local visitedServers = {}
local ServerHopSettings = {}
local ServerHopFileName = "bloxfruitsServerHop.json"

local function SaveServerHopSettings()
    local HttpService = game:GetService("HttpService")
    writefile(ServerHopFileName, HttpService:JSONEncode(ServerHopSettings))
end

local function ReadServerHopSettings()
    local s, e = pcall(function()
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONDecode(readfile(ServerHopFileName))
    end)
    if s then
        return e
    else
        SaveServerHopSettings()
        return ReadServerHopSettings()
    end
end
ServerHopSettings = ReadServerHopSettings()

local function resetVisitedServers()
    if tick() - lastResetTime >= 3600 then
        print("[NewServerHop] Прошёл час, обнуляю список посещённых серверов")
        visitedServers = {}
        ServerHopSettings = {}
        SaveServerHopSettings()
        lastResetTime = tick()
    end
end

-- Зависимости
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Переменные
local BLOX_FRUITS_PLACE_ID = 2753915549 -- PlaceID для Blox Fruits
local visitedServers = {}
local ServerHopSettings = {}
local ServerHopFileName = "bloxfruitsServerHop.json"
local lastResetTime = tick()
local serverHopEnabled = false -- Переменная для управления Server Hop (должна управляться через GUI)

-- Функции сохранения и чтения настроек
local function SaveServerHopSettings()
    local HttpService = game:GetService("HttpService")
    writefile(ServerHopFileName, HttpService:JSONEncode(ServerHopSettings))
end

local function ReadServerHopSettings()
    local s, e = pcall(function()
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONDecode(readfile(ServerHopFileName))
    end)
    if s then
        return e
    else
        SaveServerHopSettings()
        return ReadServerHopSettings()
    end
end
ServerHopSettings = ReadServerHopSettings()

-- Функция сброса посещённых серверов
local function resetVisitedServers()
    if tick() - lastResetTime >= 3600 then
        print("[NewServerHop] Прошёл час, обнуляю список посещённых серверов")
        visitedServers = {}
        ServerHopSettings = {}
        SaveServerHopSettings()
        lastResetTime = tick()
    end
end

-- Функция телепортации на новый сервер
local function serverHop()
    print("[NewServerHop] Начало попытки телепортации")
    local currentServerId = game.JobId or "unknown"
    print("[NewServerHop] Текущий сервер ID: " .. tostring(currentServerId))

    if currentServerId ~= "unknown" then
        visitedServers[currentServerId] = true
        ServerHopSettings[currentServerId] = { Time = tick() }
        SaveServerHopSettings()
        print("[NewServerHop] Текущий сервер добавлен в исключения")
    else
        warn("[NewServerHop] Не удалось получить JobId, продолжение возможно")
    end

    if not game:IsLoaded() then
        warn("[NewServerHop] Игра не загружена, ожидание...")
        game.Loaded:Wait()
    end
    local player = Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        warn("[NewServerHop] Игрок или персонаж не готовы, пропускаю телепортацию")
        return false
    end

    local maxAttempts = 3
    local attempt = 1

    while attempt <= maxAttempts and serverHopEnabled do
        print("[NewServerHop] Попытка телепортации #" .. attempt)
        print("[NewServerHop] Проверка состояния игры...")
        if not game:IsLoaded() then
            warn("[NewServerHop] Игра не загружена во время попытки #" .. attempt)
            break
        end

        local success, teleportError = pcall(function()
            print("[NewServerHop] Выполняю телепортацию на Place ID: " .. BLOX_FRUITS_PLACE_ID)
            TeleportService:Teleport(BLOX_FRUITS_PLACE_ID, Players.LocalPlayer)
        end)

        if not success then
            warn("[NewServerHop] Ошибка телепортации (попытка " .. attempt .. "): " .. tostring(teleportError))
            if string.find(tostring(teleportError), "279") then
                warn("[NewServerHop] Обнаружена ошибка 279, начинаю переподключение...")
                showNotification("Ошибка 279: Начинаю переподключение...", Color3.fromRGB(255, 0, 0))
                local retrySuccess, retryError = pcall(function()
                    task.wait(5)
                    print("[NewServerHop] Пытаюсь переподключиться к новому серверу...")
                    TeleportService:Teleport(BLOX_FRUITS_PLACE_ID, Players.LocalPlayer)
                end)
                if retrySuccess then
                    print("[NewServerHop] Переподключение успешно инициировано")
                    showNotification("Переподключение инициировано, ожидайте загрузки...", Color3.fromRGB(0, 255, 0))
                    return true
                else
                    warn("[NewServerHop] Ошибка при переподключении: " .. tostring(retryError))
                    showNotification("Ошибка при переподключении: " .. tostring(retryError), Color3.fromRGB(255, 0, 0))
                end
            else
                warn("[NewServerHop] Другая ошибка: " .. tostring(teleportError))
            end
            attempt = attempt + 1
            task.wait(30)
            continue
        end

        print("[NewServerHop] Ожидаю загрузки нового сервера...")
        local loadTimeout = 40
        local elapsed = 0
        local disconnected = false

        local connection
        connection = game:GetService("NetworkClient").ChildRemoved:Connect(function(child)
            if child.Name == "ClientReplicator" then
                disconnected = true
                warn("[NewServerHop] Обнаружено отключение во время ожидания загрузки")
                if connection then connection:Disconnect() end
            end
        end)

        while elapsed < loadTimeout and not game:IsLoaded() and not disconnected do
            task.wait(1)
            elapsed = elapsed + 1
            print("[NewServerHop] Ожидание загрузки... (" .. elapsed .. "с из " .. loadTimeout .. "с)")
        end

        if connection then connection:Disconnect() end

        if disconnected then
            warn("[NewServerHop] Отключение произошло, пытаюсь переподключиться")
            showNotification("Отключение: Пытаюсь переподключиться...", Color3.fromRGB(255, 0, 0))
            local retrySuccess, retryError = pcall(function()
                task.wait(5)
                print("[NewServerHop] Пытаюсь переподключиться к новому серверу...")
                TeleportService:Teleport(BLOX_FRUITS_PLACE_ID, Players.LocalPlayer)
            end)
            if retrySuccess then
                print("[NewServerHop] Переподключение успешно инициировано")
                showNotification("Переподключение инициировано, ожидайте загрузки...", Color3.fromRGB(0, 255, 0))
                return true
            else
                warn("[NewServerHop] Ошибка при переподключении: " .. tostring(retryError))
                showNotification("Ошибка при переподключении: " .. tostring(retryError), Color3.fromRGB(255, 0, 0))
                return false
            end
        end

        if not game:IsLoaded() then
            warn("[NewServerHop] Тайм-аут загрузки нового сервера")
            attempt = attempt + 1
            task.wait(30)
            continue
        end

        local newServerId = game.JobId or "unknown"
        print("[NewServerHop] Новый сервер ID: " .. tostring(newServerId))
        if newServerId == "unknown" or (newServerId == currentServerId and attempt < maxAttempts) then
            warn("[NewServerHop] Не удалось переключиться на новый сервер или вернулись на текущий")
            attempt = attempt + 1
            task.wait(30)
            continue
        else
            print("[NewServerHop] Успешно подключился к новому серверу: " .. newServerId)
            visitedServers[newServerId] = true
            ServerHopSettings[newServerId] = { Time = tick() }
            SaveServerHopSettings()
            return true
        end
    end

    warn("[NewServerHop] Не удалось выполнить телепортацию после " .. maxAttempts .. " попыток")
    showNotification("Не удалось переподключиться. Проверьте сеть или перезапустите игру.", Color3.fromRGB(255, 0, 0))
    return false
end

-- Функция цикла Server Hop с остановкой при фруктах
local function startServerHop()
    print("[NewServerHop] Запуск цикла Server Hop")
    while serverHopEnabled do
        -- Проверка фруктов перед задержкой
        local fruits = findFruits()
        if #fruits > 0 then
            print("[NewServerHop] Обнаружено " .. #fruits .. " фруктов, приостанавливаю Server Hop")
            while #findFruits() > 0 and serverHopEnabled do
                task.wait(5)
                print("[NewServerHop] Фрукты всё ещё присутствуют, жду...")
            end
            if not serverHopEnabled then
                print("[NewServerHop] Server Hop выключен во время ожидания")
                break
            end
            print("[NewServerHop] Фрукты исчезли, продолжаю Server Hop")
        end

        -- Оригинальная задержка 75 секунд
        print("[NewServerHop] Ожидаю 65 секунд перед следующей попыткой телепортации...")
        task.wait(75)

        if serverHopEnabled then
            if game:IsLoaded() then
                local success = false
                while not success and serverHopEnabled do
                    -- Проверка фруктов перед телепортацией
                    if #findFruits() > 0 then
                        print("[NewServerHop] Фрукт обнаружен перед телепортацией, жду...")
                        while #findFruits() > 0 and serverHopEnabled do
                            task.wait(5)
                        end
                        if not serverHopEnabled then break end
                    end

                    print("[NewServerHop] Попытка найти новый сервер...")
                    success = serverHop()
                    if not success then
                        print("[NewServerHop] Ошибка или сервер полон, повтор через 2 секунды...")
                        task.wait(2)
                    end
                end
            else
                warn("[NewServerHop] Игра не загружена, жду загрузки...")
                game.Loaded:Wait()
            end
        end
    end
    print("[NewServerHop] Цикл Server Hop остановлен")
end-- GUI с вкладками
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FruitCollectorGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("ImageLabel", ScreenGui)
Frame.Size = UDim2.new(0, 500, 0, 210)
Frame.Position = UDim2.new(0.5, -250, 0.5, -120)
Frame.Image = "rbxassetid://111940581899257"
Frame.BackgroundTransparency = 1
Frame.ImageTransparency = 1
Frame.BorderSizePixel = 0
local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 20)

local minimizedFrame
minimizedFrame = Instance.new("TextButton", ScreenGui)
minimizedFrame.Size = UDim2.new(0, 100, 0, 30)
minimizedFrame.Position = UDim2.new(0.5, -10, 0.5, -15)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizedFrame.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizedFrame.Font = Enum.Font.Code
minimizedFrame.TextSize = 14
minimizedFrame.Text = "Открыть"
minimizedFrame.Visible = false
minimizedFrame.BorderSizePixel = 0
minimizedFrame.ZIndex = 10
local minimizedCorner = Instance.new("UICorner", minimizedFrame)
minimizedCorner.CornerRadius = UDim.new(0, 15)

-- Вкладки как маленькие квадратики под кнопкой закрытия
local Tab1Button = Instance.new("TextButton", Frame)
Tab1Button.Size = UDim2.new(0, 20, 0, 20)
Tab1Button.Position = UDim2.new(1, -30, 0, 55)
Tab1Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tab1Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Tab1Button.Font = Enum.Font.Code
Tab1Button.TextSize = 14
Tab1Button.Text = "1"
Tab1Button.BorderSizePixel = 0
local Tab1Corner = Instance.new("UICorner", Tab1Button)
Tab1Corner.CornerRadius = UDim.new(0, 5)

local Tab2Button = Instance.new("TextButton", Frame)
Tab2Button.Size = UDim2.new(0, 20, 0, 20)
Tab2Button.Position = UDim2.new(1, -30, 0, 85)
Tab2Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tab2Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Tab2Button.Font = Enum.Font.Code
Tab2Button.TextSize = 14
Tab2Button.Text = "2"
Tab2Button.BorderSizePixel = 0
local Tab2Corner = Instance.new("UICorner", Tab2Button)
Tab2Corner.CornerRadius = UDim.new(0, 5)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function animateTransparency(object, target)
    if object:IsA("GuiObject") then
        if object:IsA("ImageLabel") then
            TweenService:Create(object, tweenInfo, {ImageTransparency = target}):Play()
        elseif object:IsA("TextButton") or object:IsA("TextLabel") then
            TweenService:Create(object, tweenInfo, {BackgroundTransparency = target, TextTransparency = target}):Play()
        end
    end
    for _, child in pairs(object:GetChildren()) do
        animateTransparency(child, target)
    end
end

local function openFrame()
    print("[GUI] Открываем основное окно")
    Frame.Visible = true
    animateTransparency(Frame, 0)
    for _, button in pairs(Frame:GetChildren()) do
        if button:IsA("TextButton") and button ~= Tab1Button and button ~= Tab2Button then
            for _, child in pairs(button:GetChildren()) do
                if child:IsA("Frame") then
                    if child.Name == "Toggle" then
                        TweenService:Create(child, tweenInfo, {BackgroundTransparency = 0}):Play()
                    elseif child.Name == "Fill" then
                        TweenService:Create(child, tweenInfo, {BackgroundTransparency = child.Size.X.Offset > 0 and 0 or 0.5}):Play()
                    end
                end
            end
        end
    end
end

local function closeFrame()
    print("[GUI] Закрываем основное окно")
    local lastFramePosition = Frame.Position
    animateTransparency(Frame, 1)
    for _, button in pairs(Frame:GetChildren()) do
        if button:IsA("TextButton") then
            for _, child in pairs(button:GetChildren()) do
                if child:IsA("Frame") then
                    if child.Name == "Toggle" or child.Name == "Fill" then
                        TweenService:Create(child, tweenInfo, {BackgroundTransparency = 1}):Play()
                    end
                end
            end
        end
    end
    local tween = TweenService:Create(Frame, tweenInfo, {ImageTransparency = 1})
    tween.Completed:Connect(function()
        print("[GUI] Основное окно скрыто, показываем мини-меню")
        Frame.Visible = false
        if minimizedFrame then
            minimizedFrame.Position = lastFramePosition
            minimizedFrame.Visible = true
            minimizedFrame.BackgroundTransparency = 1
            minimizedFrame.TextTransparency = 1
            TweenService:Create(minimizedFrame, tweenInfo, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        end
    end)
    tween:Play()
end

local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Frame.InputChanged:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseMovement then 
        dragInput = input 
    end 
end)

local minimizedDragging, minimizedDragInput, minimizedDragStart, minimizedStartPos
minimizedFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        minimizedDragging = true
        minimizedDragStart = input.Position
        minimizedStartPos = minimizedFrame.Position
        print("[GUI] Начато перетаскивание мини-меню")
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                minimizedDragging = false 
                print("[GUI] Закончено перетаскивание мини-меню")
            end
        end)
    end
end)
minimizedFrame.InputChanged:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseMovement then 
        minimizedDragInput = input 
    end 
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    if minimizedDragging and input == minimizedDragInput then
        if minimizedFrame then
            local delta = input.Position - minimizedDragStart
            minimizedFrame.Position = UDim2.new(minimizedStartPos.X.Scale, minimizedStartPos.X.Offset + delta.X, minimizedStartPos.Y.Scale, minimizedStartPos.Y.Offset + delta.Y)
        else
            print("[GUI] Ошибка: minimizedFrame не существует при попытке перетаскивания")
        end
    end
end)

minimizedFrame.MouseButton1Click:Connect(function() 
    if minimizedFrame then
        print("[GUI] Нажата кнопка 'Открыть' в мини-меню")
        local lastMinimizedPosition = minimizedFrame.Position
        minimizedFrame.Visible = false
        Frame.Position = lastMinimizedPosition
        openFrame()
    else
        print("[GUI] Ошибка: minimizedFrame не существует при клике")
    end
end)

local closeButton = Instance.new("TextButton", Frame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Font = Enum.Font.Code
closeButton.TextSize = 14
closeButton.Text = "X"
closeButton.BorderSizePixel = 0
closeButton.BackgroundTransparency = 1
local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 15)

local minimizeButton = Instance.new("TextButton", Frame)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -80, 0, 10)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizeButton.Font = Enum.Font.Code
minimizeButton.TextSize = 14
minimizeButton.Text = "-"
minimizeButton.BorderSizePixel = 0
minimizeButton.BackgroundTransparency = 1
local minimizeCorner = Instance.new("UICorner", minimizeButton)
minimizeCorner.CornerRadius = UDim.new(0, 15)

minimizeButton.MouseButton1Click:Connect(function() 
    if Frame.Visible then 
        print("[GUI] Нажата кнопка сворачивания")
        closeFrame()
    end 
end)
closeButton.MouseButton1Click:Connect(function() 
    print("[GUI] Нажата кнопка закрытия")
    closeFrame()
    if minimizedFrame then
        minimizedFrame.Visible = false
    end
    ScreenGui:Destroy()
end)

local HttpService = game:GetService("HttpService")
local fileName = "FruitCollectorSettings.json"

local function saveSettings(settings)
    local json = HttpService:JSONEncode(settings)
    writefile(fileName, json)
    print("[Сохранение] Настройки сохранены в " .. fileName)
end

local function loadSettings()
    if isfile(fileName) then
        local json = readfile(fileName)
        local success, result = pcall(function()
            return HttpService:JSONDecode(json)
        end)
        if success then
            print("[Загрузка] Настройки загружены из " .. fileName)
            return result
        else
            print("[Ошибка] Не удалось загрузить настройки: " .. result)
        end
    else
        print("[Загрузка] Файл настроек не найден, используются значения по умолчанию")
    end
    return {["Teleport Fruit"] = false, ["ESP Fruit"] = false, ["Auto Store Fruit"] = false, ["Server Hop"] = false, ["Auto Buy Fruit"] = false}
end

local savedSettings = loadSettings()

local function createToggleButton(text, posY, callback)
    local Button = Instance.new("TextButton", Frame)
    Button.Size = UDim2.new(0, 200, 0, 30)
    Button.Position = UDim2.new(0, 20, 0, posY - 10)
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextColor3 = Color3.fromRGB(0, 0, 0)
    Button.Font = Enum.Font.Code
    Button.TextSize = 14
    Button.Text = " " .. text
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.BorderSizePixel = 0
    Button.BackgroundTransparency = 1
    local UICorner = Instance.new("UICorner", Button)
    UICorner.CornerRadius = UDim.new(0, 15)
    local Fill = Instance.new("Frame", Button)
    Fill.Name = "Fill"
    Fill.Size = UDim2.new(0, 0, 0, 20)
    Fill.Position = UDim2.new(1, -55, 0.5, -10)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Fill.BackgroundTransparency = 0.5
    Fill.BorderSizePixel = 0
    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(1, 0)
    local Toggle = Instance.new("Frame", Button)
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 20, 0, 20)
    Toggle.Position = UDim2.new(1, -55, 0.5, -10)
    Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Toggle.BorderSizePixel = 0
    local ToggleCorner = Instance.new("UICorner", Toggle)
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    local isOn = savedSettings[text] or false
    local buttonTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    if isOn then
        Fill.Size = UDim2.new(0, 50, 0, 20)
        Toggle.Position = UDim2.new(1, -25, 0.5, -10)
        Fill.BackgroundTransparency = 0
        callback(true)
    end

    Button.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            Fill:TweenSize(UDim2.new(0, 50, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            Toggle:TweenPosition(UDim2.new(1, -25, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            TweenService:Create(Fill, buttonTweenInfo, {BackgroundTransparency = 0}):Play()
            if text == "Teleport Fruit" then
                disableCollisions()
            end
        else
            Fill:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            Toggle:TweenPosition(UDim2.new(1, -55, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            TweenService:Create(Fill, buttonTweenInfo, {BackgroundTransparency = 0.5}):Play()
            if text == "Teleport Fruit" then
                stopAllTweens()
            end
        end
        callback(isOn)
        savedSettings[text] = isOn
        saveSettings(savedSettings)
    end)
    return Button
end

-- Разделение кнопок на вкладки
local tab1Buttons = {
    {text = "Teleport Fruit", posY = 50, callback = function(isOn)
        collectingEnabled = isOn
        if isOn then
            collectCoroutine = coroutine.create(startAutoCollect)
            coroutine.resume(collectCoroutine)
        else
            stopAllTweens()
        end
    end},
    {text = "ESP Fruit", posY = 90, callback = function(isOn)
        if isOn then
            local fruits = findFruits()
            for _, fruit in pairs(fruits) do
                createESP(fruit)
            end
        else
            disableESP()
        end
    end},
    {text = "Auto Store Fruit", posY = 130, callback = function(isOn)
        autoStoreEnabled = isOn
        if isOn then
            task.spawn(startAutoStore)
        end
    end},
    {text = "Server Hop", posY = 170, callback = function(isOn)
        serverHopEnabled = isOn
        if isOn then
            print("[NewServerHop] Кнопка включена, запускаю Server Hop с задержкой 65 секунд")
            task.spawn(startServerHop)
        else
            print("[NewServerHop] Кнопка выключена, останавливаю Server Hop")
            serverHopEnabled = false
        end
    end}
}

local tab2Buttons = {
    {text = "Auto Buy Fruit", posY = 50, callback = function(isOn)
        autoBuyEnabled = isOn
        if isOn then
            print("[AutoBuyFruit] Включена автопокупка фруктов через GUI")
            task.spawn(startAutoBuy)
        else
            print("[AutoBuyFruit] Выключена автопокупка фруктов через GUI")
            autoBuyEnabled = false
        end
    end}
}

local allButtons = {}
for _, btn in pairs(tab1Buttons) do
    local button = createToggleButton(btn.text, btn.posY, btn.callback)
    table.insert(allButtons, button)
end
for _, btn in pairs(tab2Buttons) do
    local button = createToggleButton(btn.text, btn.posY, btn.callback)
    button.Visible = false -- Скрываем вторую вкладку по умолчанию
    table.insert(allButtons, button)
end

Tab1Button.MouseButton1Click:Connect(function()
    Tab1Button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Tab2Button.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    for i, button in pairs(allButtons) do
        button.Visible = (i <= #tab1Buttons)
    end
end)

Tab2Button.MouseButton1Click:Connect(function()
    Tab1Button.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Tab2Button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    for i, button in pairs(allButtons) do
        button.Visible = (i > #tab1Buttons)
    end
end)

local TitleLabel = Instance.new("ImageLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0, 100, 0, 20)
TitleLabel.Position = UDim2.new(0, 10, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.ImageTransparency = 0
TitleLabel.BorderSizePixel = 0
TitleLabel.ZIndex = 2
TitleLabel.Parent = Frame

local TitleText = Instance.new("ImageLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(0, 100, 0, 20)
TitleText.Position = UDim2.new(0, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.ImageTransparency = 0
TitleText.Image = "rbxassetid://101220483366180"
TitleText.ZIndex = 3
TitleText.Parent = TitleLabel

print("[GUI] Запускаем скрипт")
openFrame()
