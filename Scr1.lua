local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local collectingEnabled = false
local autoStoreEnabled = false
local serverHopEnabled = false
local autoBuyEnabled = false
local antiAfkEnabled = false -- Новая переменная для анти-АФК
local FlightSpeed = 300
local activeConnections = {}
local espCache = {}
local lastPurchaseTime = nil
local COOLDOWN_DURATION = 7200 -- 2 часа
local NOTIFICATION_DURATION = 3
local SAVE_FILE = "lastPurchaseTime_" .. player.UserId .. ".txt"

local BLOX_FRUITS_PLACE_ID = 2753915549
local visitedServers = {}
local ServerHopSettings = {}
local ServerHopFileName = "bloxfruitsServerHop.json"
local lastResetTime = tick()

local wantedFruits = {
    ["Kilo Fruit"] = true, ["Spin Fruit"] = true, ["Chop Fruit"] = true, ["Sprint Fruit"] = true,
    ["Bomb Fruit"] = true, ["Smoke Fruit"] = true, ["Spike Fruit"] = true, ["Flame Fruit"] = true,
    ["Falcon Fruit"] = true, ["Ice Fruit"] = true, ["Sand Fruit"] = true, ["Dark Fruit"] = true,
    ["Revive Fruit"] = true, ["Diamond Fruit"] = true, ["Light Fruit"] = true, ["Rubber Fruit"] = true,
    ["Barrier Fruit"] = true, ["Magma Fruit"] = true, ["Quake Fruit"] = true, ["Spider Fruit"] = true,
    ["Phoenix Fruit"] = true, ["Buddha Fruit"] = true, ["Portal Fruit"] = true, ["Rumble Fruit"] = true,
    ["Paw Fruit"] = true, ["Blizzard Fruit"] = true, ["Gravity Fruit"] = true, ["Dough Fruit"] = true,
    ["Shadow Fruit"] = true, ["Venom Fruit"] = true, ["Control Fruit"] = true, ["Spirit Fruit"] = true,
    ["Dragon Fruit"] = true, ["Leopard Fruit"] = true, ["Kitsune Fruit"] = true, ["T-Rex Fruit"] = true,
    ["Mammoth Fruit"] = true, ["Gas Fruit"] = true, ["Yeti Fruit"] = true
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
        print("[ESP] Создаю ESP для: " .. (fruit.Name == "" and "Безымянный фрукт" or fruit.Name))
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

local function findNearestFruit()
    local fruits = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part") or obj:FindFirstChildOfClass("MeshPart")
            if handle and handle:FindFirstChild("TouchInterest") then
                local distance = (hrp.Position - handle.Position).Magnitude
                table.insert(fruits, {obj = obj, dist = distance})
            end
        end
    end

    table.sort(fruits, function(a, b) return a.dist < b.dist end)
    return fruits[1] and fruits[1].obj or nil
end

local function collectFruit(fruit)
    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("Part") or fruit:FindFirstChildOfClass("MeshPart")
    if not handle or not handle.Parent then return end

    print("[Сбор] Телепорт к фрукту: " .. fruit.Name)
    local targetPosition = handle.Position + Vector3.new(0, 1, 0)
    local startPosition = hrp.Position
    local distance = (startPosition - targetPosition).Magnitude
    local speed = FlightSpeed
    local totalTime = distance / speed

    disableCollisions()
    local elapsed = 0
    local lastJumpTime = tick()

    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not hrp or not handle or not handle.Parent or not fruit.Parent or not collectingEnabled then
            print("[Сбор] Фрукт исчез или сбор отключён, отменяю сбор.")
            connection:Disconnect()
            enableCollisions()
            return
        end

        elapsed = elapsed + deltaTime
        local t = math.min(elapsed / totalTime, 1)
        local newPosition = startPosition:Lerp(targetPosition, t)
        hrp.CFrame = CFrame.new(newPosition)

        if tick() - lastJumpTime >= 5 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            print("[Сбор] Выполнен прыжок для предотвращения застревания")
            lastJumpTime = tick()
        end

        if t >= 1 then
            if not fruit.Parent then
                print("[Сбор] Фрукт был подобран другим игроком.")
                connection:Disconnect()
                enableCollisions()
                return
            end

            connection:Disconnect()
            enableCollisions()
            task.wait(0.5)

            local pickedFruit = player.Backpack:FindFirstChild(fruit.Name) or character:FindFirstChild(fruit.Name)
            if pickedFruit then
                print("[Сбор] Успешно подобран фрукт: " .. pickedFruit.Name)
                if espCache[fruit] then
                    espCache[fruit]:Destroy()
                    espCache[fruit] = nil
                end
            else
                print("[Сбор] Не удалось подобрать фрукт: " .. fruit.Name)
            end
        end
    end)
    table.insert(activeConnections, connection)
end

local function startAutoCollect()
    while collectingEnabled do
        local fruit = findNearestFruit()
        if fruit then
            collectFruit(fruit)
            task.wait(1)
        else
            print("[АвтоСбор] Фрукты не найдены, проверяю снова...")
        end
        task.wait(0.5)
    end
end

local function stopAllConnections()
    for _, connection in pairs(activeConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    table.clear(activeConnections)
    enableCollisions()
    print("[Телепорт] Все активные соединения остановлены, коллизии восстановлены")
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
        if time then return time end
    end
    return nil
end

local function saveLastPurchaseTime(time)
    writefile(SAVE_FILE, tostring(time))
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
        task.wait(waitTime)
        attempts = attempts + 1
    end
    return nil
end

local function canBuyFruit()
    if not lastPurchaseTime then return true end
    local timeSinceLastPurchase = tick() - lastPurchaseTime
    return timeSinceLastPurchase >= COOLDOWN_DURATION
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
    local beli = getBeli()
    if beli == nil then
        showNotification("Ошибка: Не удалось загрузить Beli", Color3.fromRGB(255, 0, 0))
        return false
    end

    local minPrice = 50000
    if beli < minPrice then
        showNotification("Недостаточно Beli (" .. minPrice .. ")", Color3.fromRGB(255, 165, 0))
        return false
    end

    lastPurchaseTime = loadLastPurchaseTime()
    if not canBuyFruit() then
        showNotification("Кулдаун активен", Color3.fromRGB(255, 165, 0))
        return false
    end

    showNotification("Попытка покупки...", Color3.fromRGB(255, 255, 0))
    local success, result = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end)

    if success then
        if result == true or (typeof(result) == "string" and result ~= "Cooldown" and result ~= "NotEnoughMoney") then
            lastPurchaseTime = tick()
            saveLastPurchaseTime(lastPurchaseTime)
            if typeof(result) == "string" then
                showNotification("Куплен фрукт: " .. result, Color3.fromRGB(0, 255, 0))
            else
                showNotification("Фрукт успешно куплен!", Color3.fromRGB(0, 255, 0))
            end
            return true
        elseif result == "Cooldown" then
            showNotification("Кулдаун активен", Color3.fromRGB(255, 165, 0))
            lastPurchaseTime = tick()
            saveLastPurchaseTime(lastPurchaseTime)
            return false
        elseif result == "NotEnoughMoney" then
            showNotification("Недостаточно Beli", Color3.fromRGB(255, 165, 0))
            return false
        else
            showNotification("Неизвестная ошибка", Color3.fromRGB(255, 0, 0))
            return false
        end
    else
        showNotification("Ошибка покупки: " .. tostring(result), Color3.fromRGB(255, 0, 0))
        return false
    end
end

local function startAutoBuy()
    while autoBuyEnabled do
        if game:IsLoaded() then
            local player = Players.LocalPlayer
            if not player then
                task.wait(1)
                continue
            end
            
            local beli = getBeli()
            if beli and beli >= 50000 then
                buyRandomFruit()
            end
        else
            game.Loaded:Wait()
        end
        task.wait(30)
    end
end

-- Server Hop логика
local function SaveServerHopSettings()
    writefile(ServerHopFileName, HttpService:JSONEncode(ServerHopSettings))
end

local function ReadServerHopSettings()
    local s, e = pcall(function()
        return HttpService:JSONDecode(readfile(ServerHopFileName))
    end)
    if s then return e else SaveServerHopSettings() return ReadServerHopSettings() end
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

local function serverHop()
    print("[NewServerHop] Начало попытки телепортации")
    local currentServerId = game.JobId or "unknown"
    if currentServerId ~= "unknown" then
        visitedServers[currentServerId] = true
        ServerHopSettings[currentServerId] = { Time = tick() }
        SaveServerHopSettings()
    end

    if not game:IsLoaded() then game.Loaded:Wait() end
    local player = Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false end

    local maxAttempts = 3
    local attempt = 1

    while attempt <= maxAttempts and serverHopEnabled do
        local success, teleportError = pcall(function()
            TeleportService:Teleport(BLOX_FRUITS_PLACE_ID, Players.LocalPlayer)
        end)

        if not success then
            warn("[NewServerHop] Ошибка телепортации (попытка " .. attempt .. "): " .. tostring(teleportError))
            attempt = attempt + 1
            task.wait(30)
            continue
        end

        local loadTimeout = 40
        local elapsed = 0
        while elapsed < loadTimeout and not game:IsLoaded() do
            task.wait(1)
            elapsed = elapsed + 1
        end

        if not game:IsLoaded() then
            attempt = attempt + 1
            task.wait(30)
            continue
        end

        local newServerId = game.JobId or "unknown"
        if newServerId == "unknown" or newServerId == currentServerId then
            attempt = attempt + 1
            task.wait(30)
            continue
        else
            visitedServers[newServerId] = true
            ServerHopSettings[newServerId] = { Time = tick() }
            SaveServerHopSettings()
            return true
        end
    end

    warn("[NewServerHop] Не удалось выполнить телепортацию после " .. maxAttempts .. " попыток")
    return false
end

local function startServerHop()
    while serverHopEnabled do
        local fruits = findNearestFruit()
        if fruits then
            print("[NewServerHop] Обнаружен фрукт, жду его сбора")
            while findNearestFruit() and serverHopEnabled do task.wait(5) end
            if not serverHopEnabled then break end
        end

        task.wait(75)
        if serverHopEnabled then
            if game:IsLoaded() then
                local success = false
                while not success and serverHopEnabled do
                    if findNearestFruit() then
                        while findNearestFruit() and serverHopEnabled do task.wait(5) end
                        if not serverHopEnabled then break end
                    end
                    success = serverHop()
                    if not success then task.wait(2) end
                end
            else
                game.Loaded:Wait()
            end
        end
    end
end

-- Анти-АФК логика
local antiAfkConnection
local function startAntiAfk()
    if antiAfkConnection then antiAfkConnection:Disconnect() end
    antiAfkConnection = player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("[Anti-AFK] Симулирован клик для предотвращения AFK")
    end)
    print("[Anti-AFK] Анти-АФК включён")
end

local function stopAntiAfk()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
        print("[Anti-AFK] Анти-АФК отключён")
    end
end

-- GUI с вкладками
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
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end 
end)

local minimizedDragging, minimizedDragInput, minimizedDragStart, minimizedStartPos
minimizedFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        minimizedDragging = true
        minimizedDragStart = input.Position
        minimizedStartPos = minimizedFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then minimizedDragging = false end
        end)
    end
end)
minimizedFrame.InputChanged:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseMovement then minimizedDragInput = input end 
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
        end
    end
end)

minimizedFrame.MouseButton1Click:Connect(function() 
    if minimizedFrame then
        minimizedFrame.Visible = false
        Frame.Position = minimizedFrame.Position
        openFrame()
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
    if Frame.Visible then closeFrame() end 
end)
closeButton.MouseButton1Click:Connect(function() 
    closeFrame()
    if minimizedFrame then minimizedFrame.Visible = false end
    ScreenGui:Destroy()
end)

local fileName = "FruitCollectorSettings.json"

local function saveSettings(settings)
    local json = HttpService:JSONEncode(settings)
    writefile(fileName, json)
end

local function loadSettings()
    if isfile(fileName) then
        local json = readfile(fileName)
        local success, result = pcall(function()
            return HttpService:JSONDecode(json)
        end)
        if success then return result end
    end
    return {["Teleport Fruit"] = false, ["ESP Fruit"] = false, ["Auto Store Fruit"] = false, ["Server Hop"] = false, ["Auto Buy Fruit"] = false, ["Anti AFK"] = false}
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
            if text == "Teleport Fruit" then disableCollisions() end
        else
            Fill:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            Toggle:TweenPosition(UDim2.new(1, -55, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            TweenService:Create(Fill, buttonTweenInfo, {BackgroundTransparency = 0.5}):Play()
            if text == "Teleport Fruit" then stopAllConnections() end
        end
        callback(isOn)
        savedSettings[text] = isOn
        saveSettings(savedSettings)
    end)
    return Button
end

local tab1Buttons = {
    {text = "Teleport Fruit", posY = 50, callback = function(isOn)
        collectingEnabled = isOn
        if isOn then task.spawn(startAutoCollect) else stopAllConnections() end
    end},
    {text = "ESP Fruit", posY = 90, callback = function(isOn)
        if isOn then
            local fruit = findNearestFruit()
            if fruit then createESP(fruit) end
            Workspace.DescendantAdded:Connect(function(child)
                if isOn and (child:IsA("Tool") or child:IsA("Model")) then
                    local handle = child:FindFirstChild("Handle") or child:FindFirstChildOfClass("Part") or child:FindFirstChildOfClass("MeshPart")
                    if handle and handle:FindFirstChild("TouchInterest") then createESP(child) end
                end
            end)
        else
            disableESP()
        end
    end},
    {text = "Auto Store Fruit", posY = 130, callback = function(isOn)
        autoStoreEnabled = isOn
        if isOn then task.spawn(startAutoStore) end
    end},
    {text = "Server Hop", posY = 170, callback = function(isOn)
        serverHopEnabled = isOn
        if isOn then task.spawn(startServerHop) end
    end}
}

local tab2Buttons = {
    {text = "Auto Buy Fruit", posY = 50, callback = function(isOn)
        autoBuyEnabled = isOn
        if isOn then task.spawn(startAutoBuy) end
    end},
    {text = "Anti AFK", posY = 90, callback = function(isOn)
        antiAfkEnabled = isOn
        if isOn then startAntiAfk() else stopAntiAfk() end
    end}
}

local allButtons = {}
for _, btn in pairs(tab1Buttons) do
    local button = createToggleButton(btn.text, btn.posY, btn.callback)
    table.insert(allButtons, button)
end
for _, btn in pairs(tab2Buttons) do
    local button = createToggleButton(btn.text, btn.posY, btn.callback)
    button.Visible = false
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

openFrame()
