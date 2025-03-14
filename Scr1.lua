local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local collectingEnabled = false
local autoStoreEnabled = false
local serverHopEnabled = false
local autoBuyEnabled = false
local FlightSpeed = 300 -- Из второго скрипта
local activeConnections = {} -- Из второго скрипта
local espCache = {}
local lastPurchaseTime = nil
local COOLDOWN_DURATION = 7200 -- 2 часа
local NOTIFICATION_DURATION = 3
local SAVE_FILE = "lastPurchaseTime_" .. player.UserId .. ".txt"

local BLOX_FRUITS_PLACE_ID = 2753915549
local visitedServers = {}
local resetTime = 1200 -- 20 минут в секундах
local waitTime = 10 -- 10 секунд перед хопом

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
    end
end

local function enableCollisions()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
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
        if time then
            return time
        end
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
    if not lastPurchaseTime then
        return true
    end
    local timeSinceLastPurchase = tick() - lastPurchaseTime
    if timeSinceLastPurchase >= COOLDOWN_DURATION then
        return true
    else
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

-- Функция для сброса списка посещенных серверов
spawn(function()
    while true do
        wait(resetTime)
        visitedServers = {}
    end
end)

-- Функция для получения списка серверов
local function getServers()
    local servers = {}
    local cursor = ""

    repeat
        local url = "https://games.roblox.com/v1/games/"..BLOX_FRUITS_PLACE_ID.."/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)

        if data and data.data then
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and not visitedServers[server.id] then
                    table.insert(servers, server.id)
                end
            end
        end

        cursor = data.nextPageCursor or ""
        wait(1)
    until cursor == "" or #servers >= 1

    return servers
end

-- Функция для попытки перехода на сервер
local function attemptServerHop()
    local fruit = findNearestFruit()
    if fruit then
        print("[ServerHop] Обнаружен фрукт, жду его сбора перед хопом")
        while findNearestFruit() and serverHopEnabled do
            task.wait(5)
        end
        if not serverHopEnabled then return end
    end

    local servers = getServers()
    while #servers > 0 do
        local newServer = servers[math.random(1, #servers)]
        visitedServers[newServer] = true

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(BLOX_FRUITS_PLACE_ID, newServer, player)
        end)

        if success then
            return
        else
            warn("[ServerHop] Не удалось подключиться к серверу: "..err)
            table.remove(servers, table.find(servers, newServer))
        end

        wait(1)
    end

    warn("[ServerHop] Не найдено доступных серверов! Повтор через 5 секунд...")
    wait(5)
    attemptServerHop()
end

-- Основной цикл Server Hop
local function startServerHop()
    while serverHopEnabled do
        wait(waitTime)
        attemptServerHop()
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

local minimizedFrame = Instance.new("TextButton", ScreenGui)
minimizedFrame.Size = UDim2.new(0, 100, 0, 30)
minimizedFrame.Position = UDim2.new(0.5, -50, 0.5, -15)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizedFrame.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizedFrame.Font = Enum.Font.Code
minimizedFrame.TextSize = 14
minimizedFrame.Text = "Открыть"
minimizedFrame.Visible = false
minimizedFrame.BorderSizePixel = 0
local minimizedCorner = Instance.new("UICorner", minimizedFrame)
minimizedCorner.CornerRadius = UDim.new(0, 15)

local TabFrame = Instance.new("Frame", Frame)
TabFrame.Size = UDim2.new(0, 60, 0, 120)
TabFrame.Position = UDim2.new(1, -70, 0, 50)
TabFrame.BackgroundTransparency = 1
TabFrame.BorderSizePixel = 0

local Tab1Button = Instance.new("TextButton", TabFrame)
Tab1Button.Size = UDim2.new(0, 40, 0, 40)
Tab1Button.Position = UDim2.new(0, 10, 0, 10)
Tab1Button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
Tab1Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Tab1Button.Font = Enum.Font.Code
Tab1Button.TextSize = 18
Tab1Button.Text = "1"
Tab1Button.BorderSizePixel = 0
local Tab1Corner = Instance.new("UICorner", Tab1Button)
Tab1Corner.CornerRadius = UDim.new(0, 20)

local Tab2Button = Instance.new("TextButton", TabFrame)
Tab2Button.Size = UDim2.new(0, 40, 0, 40)
Tab2Button.Position = UDim2.new(0, 10, 0, 70)
Tab2Button.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
Tab2Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Tab2Button.Font = Enum.Font.Code
Tab2Button.TextSize = 18
Tab2Button.Text = "2"
Tab2Button.BorderSizePixel = 0
local Tab2Corner = Instance.new("UICorner", Tab2Button)
Tab2Corner.CornerRadius = UDim.new(0, 20)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function animateTransparency(object, target)
    if object:IsA("GuiObject") then
        if object:IsA("ImageLabel") then
            TweenService:Create(object, tweenInfo, {ImageTransparency = target}):Play()
        elseif object:IsA("TextButton") or object:IsA("Frame") then
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
end

local function closeFrame()
    animateTransparency(Frame, 1)
    local tween = TweenService:Create(Frame, tweenInfo, {ImageTransparency = 1})
    tween.Completed:Connect(function()
        Frame.Visible = false
        minimizedFrame.Visible = true
        TweenService:Create(minimizedFrame, tweenInfo, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    end)
    tween:Play()
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dragging = true
        local dragStart = input.Position
        local startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
end)

minimizedFrame.MouseButton1Click:Connect(function()
    minimizedFrame.Visible = false
    openFrame()
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

closeButton.MouseButton1Click:Connect(function()
    closeFrame()
    ScreenGui:Destroy()
end)

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
    FillCorner.CornerRadius = UDim.new(0, 10)
    local Toggle = Instance.new("Frame", Button)
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 20, 0, 20)
    Toggle.Position = UDim2.new(1, -55, 0.5, -10)
    Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Toggle.BorderSizePixel = 0
    local ToggleCorner = Instance.new("UICorner", Toggle)
    ToggleCorner.CornerRadius = UDim.new(0, 10)

    Button.MouseButton1Click:Connect(function()
        local isOn = Fill.Size.X.Offset == 0
        if isOn then
            Fill:TweenSize(UDim2.new(0, 50, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            Toggle:TweenPosition(UDim2.new(1, -25, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            TweenService:Create(Fill, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        else
            Fill:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            Toggle:TweenPosition(UDim2.new(1, -55, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            TweenService:Create(Fill, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        end
        callback(not isOn)
    end)
    return Button
end

local tab1Buttons = {
    createToggleButton("Teleport Fruit", 50, function(isOn)
        collectingEnabled = isOn
        if isOn then
            task.spawn(startAutoCollect)
        else
            stopAllConnections()
        end
    end),
    createToggleButton("ESP Fruit", 90, function(isOn)
        if isOn then
            local fruit = findNearestFruit()
            if fruit then createESP(fruit) end
            Workspace.DescendantAdded:Connect(function(child)
                if isOn and (child:IsA("Tool") or child:IsA("Model")) then
                    local handle = child:FindFirstChild("Handle") or child:FindFirstChildOfClass("Part") or child:FindFirstChildOfClass("MeshPart")
                    if handle and handle:FindFirstChild("TouchInterest") then
                        createESP(child)
                    end
                end
            end)
        else
            disableESP()
        end
    end),
    createToggleButton("Auto Store Fruit", 130, function(isOn)
        autoStoreEnabled = isOn
        if isOn then
            task.spawn(startAutoStore)
        end
    end),
    createToggleButton("Server Hop", 170, function(isOn)
        serverHopEnabled = isOn
        if isOn then
            task.spawn(startServerHop)
        end
    end)
}

local tab2Buttons = {
    createToggleButton("Auto Buy Fruit", 50, function(isOn)
        autoBuyEnabled = isOn
        if isOn then
            task.spawn(startAutoBuy)
        end
    end)
}

Tab1Button.MouseButton1Click:Connect(function()
    Tab1Button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Tab2Button.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    for _, button in pairs(tab1Buttons) do
        button.Visible = true
    end
    for _, button in pairs(tab2Buttons) do
        button.Visible = false
    end
end)

Tab2Button.MouseButton1Click:Connect(function()
    Tab1Button.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Tab2Button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    for _, button in pairs(tab1Buttons) do
        button.Visible = false
    end
    for _, button in pairs(tab2Buttons) do
        button.Visible = true
    end
end)

-- Изначально показываем первую вкладку
for _, button in pairs(tab2Buttons) do
    button.Visible = false
end

openFrame()
