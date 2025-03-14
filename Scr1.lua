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
local serverHopEnabled = false
local FlightSpeed = 350
local activeTweens = {}
local collectCoroutine = nil

local BLOX_FRUITS_PLACE_ID = 2753915549
local visitedServers = {}
local resetTime = 1200 -- 20 минут в секундах
local waitTime = 10 -- 10 секунд перед хопом

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

local function stopAllTweens()
    for _, tween in pairs(activeTweens) do
        if tween then
            tween:Cancel()
        end
    end
    table.clear(activeTweens)
    if character then
        hrp.Anchored = false
        humanoid.PlatformStand = false
    end
    if collectCoroutine then
        coroutine.close(collectCoroutine)
        collectCoroutine = nil
    end
    enableCollisions()
end

local function collectFruit(fruit)
    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("Part") or fruit:FindFirstChildOfClass("MeshPart")
    if not handle then return end

    local targetPosition = handle.Position + Vector3.new(0, 5, 0)
    local startPosition = hrp.Position
    local distance = (startPosition - targetPosition).Magnitude
    local speed = FlightSpeed

    disableCollisions()
    task.wait(0.1)

    local connection
    local elapsed = 0
    local totalTime = distance / speed
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not hrp or not collectingEnabled or not handle or not handle.Parent then
            if connection then connection:Disconnect() end
            enableCollisions()
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

    if collectingEnabled then
        task.wait(0)
        local pickedFruit = player.Backpack:FindFirstChild(fruit.Name) or character:FindFirstChild(fruit.Name)
        if pickedFruit then
            print("[Сбор] Успешно подобран фрукт: " .. pickedFruit.Name)
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
            for _, fruit in pairs(fruits) do
                if collectingEnabled then
                    collectFruit(fruit)
                    task.wait(1)
                else
                    break
                end
            end
        end
        task.wait(0.1)
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
    local fruits = findFruits()
    if #fruits > 0 then
        print("[ServerHop] Обнаружены фрукты, жду их сбора перед хопом")
        while #findFruits() > 0 and serverHopEnabled do
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

-- GUI
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
minimizedFrame.Position = UDim2.new(0.5, -10, 0.5, -15)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizedFrame.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizedFrame.Font = Enum.Font.Code
minimizedFrame.TextSize = 14
minimizedFrame.Text = "Открыть"
minimizedFrame.Visible = false
minimizedFrame.BorderSizePixel = 0
local minimizedCorner = Instance.new("UICorner", minimizedFrame)
minimizedCorner.CornerRadius = UDim.new(0, 15)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function animateTransparency(object, target)
    if object:IsA("GuiObject") then
        if object:IsA("ImageLabel") then
            TweenService:Create(object, tweenInfo, {ImageTransparency = target}):Play()
        elseif object:IsA("TextButton") then
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
    local Toggle = Instance.new("Frame", Button)
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 20, 0, 20)
    Toggle.Position = UDim2.new(1, -55, 0.5, -10)
    Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Toggle.BorderSizePixel = 0

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

createToggleButton("Teleport Fruit", 50, function(isOn)
    collectingEnabled = isOn
    if isOn then
        collectCoroutine = coroutine.create(startAutoCollect)
        coroutine.resume(collectCoroutine)
    else
        stopAllTweens()
    end
end)

createToggleButton("Server Hop", 90, function(isOn)
    serverHopEnabled = isOn
    if isOn then
        task.spawn(startServerHop)
    end
end)

openFrame()
