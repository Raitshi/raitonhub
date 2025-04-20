-- ✅ Обновление: безопасная коллизия без краша + поддержка Model и Tool фруктов

local function getSafeCollisionTargets()
    local result = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            if not obj:IsDescendantOf(character) and obj.Name ~= "Terrain" and obj.Name ~= "Camera" then
                for _, item in ipairs(obj:GetDescendants()) do
                    if item:IsA("BasePart") then
                        table.insert(result, item)
                    end
                end
            end
        end
    end
    return result
end

local function disableCollisionsProperly(char)
    local targets = getSafeCollisionTargets()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            for _, other in ipairs(targets) do
                local constraint = Instance.new("NoCollisionConstraint")
                constraint.Part0 = part
                constraint.Part1 = other
                constraint.Parent = part
            end
        end
    end
end

local function enableCollisionsProperly(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            for _, obj in ipairs(part:GetChildren()) do
                if obj:IsA("NoCollisionConstraint") then
                    obj:Destroy()
                end
            end
        end
    end
end

--! json library
--! cryptography library
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local CONV={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+CONV[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
local lEncode, lDecode, lDigest = a3, aw, Z;

-- Обёртка для print с ограничением частоты
local lastPrintTime = 0
local printBuffer = {}
local PRINT_INTERVAL = 5 -- Интервал в секундах

local function bufferedPrint(message)
    table.insert(printBuffer, message)
end

local function flushPrintBuffer()
    if #printBuffer > 0 then
        for _, message in ipairs(printBuffer) do
            print(message)
        end
        printBuffer = {}
    end
end

spawn(function()
    while true do
        local currentTime = tick()
        if currentTime - lastPrintTime >= PRINT_INTERVAL then
            flushPrintBuffer()
            lastPrintTime = currentTime
        end
        task.wait(0.1)
    end
end)

-- platoboost library
local service = 2975
local secret = "3771b2c0-1820-479a-b048-ff8ac014a444"
local useNonce = true

local onMessage = function(message)
    print("[Platoboost]: " .. message)
    local success, err = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Platoboost Status",
            Text = message,
            Duration = 5
        })
    end)
    if not success then print("Notification error: " .. err) end
end

-- Ждём полной загрузки игры
print("[Init] Ожидание загрузки игры...")
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("[Init] Игра загружена")

-- Получаем необходимые сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Ждём LocalPlayer
local player
if not Players.LocalPlayer then
    print("[Init] Ожидание LocalPlayer через PlayerAdded...")
    local connection
    connection = Players.PlayerAdded:Connect(function(newPlayer)
        player = newPlayer
        connection:Disconnect()
    end)
    local elapsed = 0
    while not player and elapsed < 10 do
        task.wait(1)
        elapsed = elapsed + 1
    end
else
    player = Players.LocalPlayer
end
if not player then
    warn("[Init] Ошибка: LocalPlayer не найден")
    onMessage("Error: LocalPlayer not found")
    return
end
print("[Init] LocalPlayer найден: " .. player.Name)

-- Ждём PlayerGui
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("[Init] Ошибка: PlayerGui не найден")
    onMessage("Error: PlayerGui not found")
    return
end
print("[Init] PlayerGui найден")

-- Ждём Backpack
local backpack = player:WaitForChild("Backpack", 10)
if not backpack then
    warn("[Init] Ошибка: Backpack не найден")
    onMessage("Error: Backpack not found")
    return
end
print("[Init] Backpack найден")

-- Проверка PlaceId
local validPlaceIds = {
    [2753915549] = true, -- Основной режим Blox Fruits (First Sea)
    [4442272183] = true, -- Второй мир (Second Sea)
    [7449423635] = true  -- Третий мир (Third Sea)
}

if not validPlaceIds[game.PlaceId] then
    warn("[Init] Этот скрипт работает только в Blox Fruits. Ожидаемые PlaceId: 2753915549, 4442272183, 7449423635. Текущий PlaceId: " .. game.PlaceId)
    onMessage("Этот скрипт работает только в Blox Fruits!")
    return
end
print("[Init] PlaceId проверен: " .. game.PlaceId)

-- Инициализация переменных для Fruit Sniper
if _G.SelectedFruits == nil then
    _G.SelectedFruits = {} -- Таблица для хранения выбранных фруктов
end
if _G.AutoBuyRunning == nil then
    _G.AutoBuyRunning = false -- Переменная для отслеживания состояния автоматической покупки
end

local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor, fGetHwid = 
    setclipboard or toclipboard, 
    request or http_request or syn.request, 
    string.char, tostring, string.sub, os.time, math.random, math.floor, 
    gethwid or function() return player.UserId end

local cachedLink, cachedTime = "", 0
local host = "https://api.platoboost.com"
print("[Init] Проверка хоста: " .. host)
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
})
if hostResponse and hostResponse.StatusCode and hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net"
    print("[Init] Хост изменён на: " .. host)
else
    print("[Init] Хост подтверждён: " .. host)
end

function cacheLink()
    if cachedTime + (10*60) < fOsTime() then
        print("[Platoboost] Запрос нового линка...")
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({service = service, identifier = lDigest(fGetHwid())}),
            Headers = {["Content-Type"] = "application/json"}
        })
        if response and response.StatusCode then
            print("[Platoboost] Response StatusCode: ", response.StatusCode)
            print("[Platoboost] Response Body: ", response.Body)
            if response.StatusCode == 200 then
                local decoded
                local success, err = pcall(function()
                    decoded = lDecode(response.Body)
                end)
                if not success then
                    onMessage("Failed to parse server response: " .. tostring(err))
                    print("[Platoboost] Failed to parse JSON: ", err)
                    return false, "Failed to parse response"
                end
                if decoded.success then
                    cachedLink = decoded.data.url
                    cachedTime = fOsTime()
                    print("[Platoboost] Новый линк: " .. cachedLink)
                    return true, cachedLink
                else
                    onMessage("Error: " .. (decoded.message or "Unknown"))
                    return false, decoded.message
                end
            elseif response.StatusCode == 429 then
                onMessage("Rate limited, wait 20s")
                return false, "Rate limited"
            else
                onMessage("Status code: " .. response.StatusCode)
                return false, "Unknown error"
            end
        else
            onMessage("No server response")
            return false, "No response"
        end
    else
        print("[Platoboost] Использую кэшированный линк: " .. cachedLink)
        return true, cachedLink
    end
end

local generateNonce = function()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end

local copyLink = function()
    local success, link = cacheLink()
    if success then
        fSetClipboard(link)
        onMessage("Link copied! Open in browser.")
        print("[Platoboost] Скопирован линк: " .. link)
    else
        onMessage("Failed to copy: " .. link)
    end
end

local redeemKey = function(key)
    local nonce = generateNonce()
    local endpoint = host .. "/public/redeem/" .. fToString(service)
    local body = {identifier = lDigest(fGetHwid()), key = key}
    if useNonce then body.nonce = nonce end
    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = {["Content-Type"] = "application/json"}
    })
    if response and response.StatusCode then
        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body)
            if decoded.success then
                if decoded.data.valid then
                    if useNonce then
                        if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                            return true
                        else
                            onMessage("Integrity verification failed")
                            return false
                        end
                    else
                        return true
                    end
                else
                    onMessage("Invalid key")
                    return false
                end
            else
                onMessage(decoded.message)
                return false
            end
        elseif response.StatusCode == 429 then
            onMessage("Rate limited, wait 20s")
            return false
        else
            onMessage("Invalid status code")
            return false
        end
    else
        onMessage("No server response")
        return false
    end
end

local requestSending = false
local verifyKey = function(key)
    if requestSending then
        onMessage("Request already sending")
        return false
    end
    requestSending = true
    local nonce = generateNonce()
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key
    if useNonce then endpoint = endpoint .. "&nonce=" .. nonce end
    local response = fRequest({Url = endpoint, Method = "GET"})
    requestSending = false
    if response and response.StatusCode then
        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body)
            if decoded.success then
                if decoded.data.valid then
                    if useNonce then
                        if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                            return true
                        else
                            onMessage("Integrity failed")
                            return false
                        end
                    else
                        return true
                    end
                else
                    if fStringSub(key, 1, 4) == "KEY_" then
                        return redeemKey(key)
                    else
                        onMessage("Invalid key")
                        return false
                    end
                end
            else
                onMessage(decoded.message)
                return false
            end
        elseif response.StatusCode == 429 then
            onMessage("Rate limited, wait 20s")
            return false
        else
            onMessage("Invalid status code")
            return false
        end
    else
        onMessage("No server response")
        return false
    end
end

local keyFileName = "saved_key.txt"
local function saveKey(key)
    local hasWritefile = false
    local success, _ = pcall(function()
        return type(writefile) == "function"
    end)
    if success then
        hasWritefile = true
    end

    if hasWritefile then
        local writeSuccess, writeError = pcall(function()
            writefile(keyFileName, key)
        end)
        if writeSuccess then
            print("[Platoboost] Ключ сохранён: " .. key)
        else
            print("[Platoboost] Не удалось сохранить ключ: " .. tostring(writeError))
            onMessage("Warning: Could not save key to file")
        end
    else
        print("[Platoboost] Функция writefile недоступна, пропускаю сохранение ключа")
        onMessage("Warning: Key saving not supported in this environment")
    end
end

local function loadKey()
    local hasReadfile = false
    local hasIsfile = false
    local successRead, _ = pcall(function()
        return type(readfile) == "function"
    end)
    local successIsfile, _ = pcall(function()
        return type(isfile) == "function"
    end)
    if successRead then hasReadfile = true end
    if successIsfile then hasIsfile = true end

    if hasReadfile and hasIsfile and isfile(keyFileName) then
        local success, key = pcall(readfile, keyFileName)
        if success then
            print("[Platoboost] Загружен ключ: " .. key)
            return key
        else
            print("[Platoboost] Не удалось загрузить ключ: " .. tostring(key))
        end
    end
    return nil
end

-- Функция для выбора команды Pirates
local function joinPiratesTeam()
    if player.Neutral == false and player.Team ~= nil then
        print("[AutoJoin] Вы уже в команде: " .. (player.Team and player.Team.Name or "Неизвестно"))
        return false
    end

    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if remote then
        print("[AutoJoin] Выбираю Pirates через CommF_...")
        local args1 = {
            [1] = "SetTeam",
            [2] = "Pirates"
        }
        remote:InvokeServer(unpack(args1))
        task.wait(1)
    else
        print("[AutoJoin] CommF_ не найден")
        return false
    end

    if player.Team and player.Team.Name == "Pirates" then
        print("[AutoJoin] Успешно выбрана команда Pirates!")
        return true
    else
        print("[AutoJoin] Не удалось выбрать Pirates. Текущая команда: " .. (player.Team and player.Team.Name or "Нет команды"))
        return false
    end
end

-- Задаём свой вебхук
local WEBHOOK_URL = "https://discord.com/api/webhooks/1362805475619508437/Cl5naW5xzGwKWEma3JbKQaiYS7ZexJv9zEKIcNqGgzv9HKORJUWhotV9eGpORlB83teL"

-- Фрукты, которые хотим отслеживать
local wantedFruitsForWebhook = {
    ["Gas Fruit"] = true,
    ["Mammoth Fruit"] = true,
    ["Dragon Fruit"] = true,
    ["Leopard Fruit"] = true,
    ["Kitsune Fruit"] = true,
    ["T-Rex Fruit"] = true,
    ["Yeti Fruit"] = true,
    ["Dough Fruit"] = true,
    ["Gravity Fruit"] = true,
}

-- Цвета фрукта
local fruitColors = {
    ["Gas Fruit"] = 0x111111,
    ["Dough Fruit"] = 0xF5DEB3,
    ["Mammoth Fruit"] = 0x8B0000,
    ["Dragon Fruit"] = 0xFF0000,
    ["Leopard Fruit"] = 0xD4AF37,
    ["Kitsune Fruit"] = 0x0099FF,
    ["T-Rex Fruit"] = 0x00FF00,
    ["Yeti Fruit"] = 0xB0E0E6,
    ["Buddha Fruit"] = 0xFFFF00,
    ["Gravity Fruit"] = 0x800080,
}

-- Иконки фруктов
local fruitImages = {
    ["Gas Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/7/7e/GasFruit.png",
    ["Mammoth Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/d/d3/MammothFruit.png",
    ["Dragon Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/4/43/DragonFruit.png",
    ["Leopard Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/8/8c/LeopardFruit.png",
    ["Kitsune Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/c/c3/KitsuneFruit.png",
    ["T-Rex Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/e/ea/T-RexFruit.png",
    ["Dough Fruit"] = "https://static.wikia.nocookie.net/blox-fruits/images/c/c6/DoughB.png/revision/latest?cb=20231028095419&path-prefix=ru",
    ["Yeti Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/1/14/YetiFruit.png",
    ["Buddha Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/7/72/BuddhaFruit.png",
    ["Gravity Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/2/22/GravityFruit.png",
}

-- Функция отправки вебхука
local function sendDiscordWebhook(fruitName, playerName)
    local req = (request or http_request or syn.request)
    if not req then
        warn("[Webhook] Инжектор не поддерживает запросы!")
        return
    end
    if not WEBHOOK_URL then
        warn("[Webhook] WEBHOOK_URL не задан!")
        return
    end

    local embed = {
        title = "🌟 Найден редкий фрукт!",
        description = string.format("**🍉 Фрукт:** `%s`\n**👤 Игрок:** `%s`", fruitName, playerName),
        color = fruitColors[fruitName] or 0xFFFFFF,
        thumbnail = {
            url = fruitImages[fruitName] or "https://i.imgur.com/OS4J4yB.png"
        },
        fields = {
            {
                name = "🕒 Время",
                value = os.date("%d.%m.%Y %H:%M:%S"),
                inline = true
            }
        },
        footer = {
            text = "Blox Fruits Sniper",
            icon_url = "https://i.imgur.com/G9bDaPH.png"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local payload = {
        username = "Тайно Сосал",
        avatar_url = "https://www.meme-arsenal.com/memes/9b41f27d01e721f6f7f14f0df05870b5.jpg",
        content = "@here",
        embeds = { embed }
    }

    local success, response = pcall(function()
        return req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not success then
        warn("[Webhook] Ошибка отправки вебхука: " .. tostring(response))
    else
        print("[Webhook] Ответ сервера: ", response.StatusCode)
    end
end

-- Таблица для предотвращения дублей
local sentFruits = {}

-- Функция проверки и отправки уведомления
local function tryNotify(tool)
    if tool:IsA("Tool") and wantedFruitsForWebhook[tool.Name] and not sentFruits[tool] then
        sentFruits[tool] = true
        print("[Webhook] Отправка уведомления для фрукта: " .. tool.Name)
        sendDiscordWebhook(tool.Name, player.Name)
    else
        print("[Webhook] Инструмент не соответствует условиям: " .. tool.Name)
    end
end

-- Функция проверки существующих инструментов
local function checkExistingTools(container)
    if not container then
        print("[Webhook] Контейнер не найден")
        return
    end
    print("[Webhook] Проверка существующих инструментов в " .. container.Name)
    for _, item in ipairs(container:GetChildren()) do
        if item:IsA("Tool") then
            print("[Webhook] Найден инструмент: " .. item.Name)
            tryNotify(item)
        end
    end
end

-- Функция обработки контейнера
local function processContainer(container)
    if not container then
        print("[Webhook] Контейнер не существует")
        return
    end
    print("[Webhook] Настройка обработки для контейнера: " .. container.Name)
    checkExistingTools(container) -- Проверяем существующие инструменты
    container.ChildAdded:Connect(function(item)
        print("[Webhook] Новый инструмент добавлен в " .. container.Name .. ": " .. item.Name)
        tryNotify(item)
    end)
end

-- Запускаем обработку фруктов в отдельной задаче с задержкой
task.spawn(function()
    print("[Webhook] Запуск обработки фруктов...")

    -- Ждём Backpack
    local backpack = player:WaitForChild("Backpack", 10)
    if not backpack then
        warn("[Webhook] Backpack не найден после ожидания")
        return
    end
    print("[Webhook] Backpack найден для обработки")

    -- Обрабатываем Backpack
    processContainer(backpack)

    -- Обрабатываем Character при появлении
    player.CharacterAdded:Connect(function(char)
        print("[Webhook] Новый Character загружен")
        local character = char
        processContainer(character)
        checkExistingTools(character)
    end)

    -- Если Character уже существует
    if player.Character then
        print("[Webhook] Character уже существует, обработка...")
        processContainer(player.Character)
        checkExistingTools(player.Character)
    end

    -- Дополнительная проверка существующих инструментов с задержкой
    task.wait(5) -- Даём игре больше времени на загрузку
    print("[Webhook] Проверка существующих инструментов после задержки")
    local success, err = pcall(function()
        checkExistingTools(player.Backpack)
        if player.Character then
            checkExistingTools(player.Character)
        end
    end)
    if not success then
        warn("[Webhook] Ошибка при проверке инструментов: " .. tostring(err))
    end
end)

local function createGUI()
    print("Creating Key GUI...")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    print("screenGui created:", screenGui)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    print("frame created:", frame)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 280, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Key Verification"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0, 260, 0, 30)
    keyInput.Position = UDim2.new(0, 20, 0, 50)
    keyInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    keyInput.PlaceholderText = "Enter your key..."
    keyInput.Text = ""
    keyInput.Font = Enum.Font.SourceSans
    keyInput.TextSize = 16
    keyInput.Parent = frame
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 5)
    inputCorner.Parent = keyInput

    local useButton = Instance.new("TextButton")
    useButton.Size = UDim2.new(0, 100, 0, 30)
    useButton.Position = UDim2.new(0, 100, 0, 150)
    useButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    useButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    useButton.Font = Enum.Font.SourceSansBold
    useButton.TextSize = 16
    useButton.Text = "Use Key"
    useButton.Parent = frame
    local useCorner = Instance.new("UICorner")
    useCorner.CornerRadius = UDim.new(0, 5)
    useCorner.Parent = useButton

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Text = "X"
    closeButton.BorderSizePixel = 0
    closeButton.Parent = frame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton

    print("useButton created:", useButton)
    if useButton then
        useButton.MouseButton1Click:Connect(function()
            print("Use button clicked")
            local key = keyInput.Text
            if key == "" then
                onMessage("Enter a key first!")
                return
            end
            local success, isValid = pcall(verifyKey, key)
            if success and isValid then
                onMessage("Key verified!")
                screenGui:Destroy()
                saveKey(key)
                runMainScript()
            else
                onMessage("Invalid key!")
            end
        end)
    else
        warn("useButton is nil, cannot attach MouseButton1Click event")
    end

  print("closeButton created:", closeButton)
    if closeButton then
        closeButton.MouseButton1Click:Connect(function()
            print("Close button clicked")
            frame.Visible = false
            screenGui:Destroy()
        end)
    else
        warn("closeButton is nil, cannot attach MouseButton1Click event")
    end
end

-- Инициализация переменных для Fruit Sniper
if _G.SelectedFruits == nil then
    _G.SelectedFruits = {} -- Таблица для хранения выбранных фруктов
end
if _G.AutoBuyRunning == nil then
    _G.AutoBuyRunning = false -- Переменная для отслеживания состояния автоматической покупки
end

-- Функция покупки фрукта
-- Функция покупки фрукта
function BuyFruit(fruitName)
    if not fruitName or fruitName == "" then
        warn("Фрукт не выбран! Пожалуйста, выберите фрукт из списка.")
        return false
    end

    print("Проверка Beli перед покупкой...")
    local playerBeli
    local success, beli = pcall(function()
        return game:GetService("Players").LocalPlayer:WaitForChild("Data"):WaitForChild("Beli").Value
    end)
    if not success then
        warn("Ошибка получения Beli: " .. tostring(beli))
        return false
    end
    playerBeli = beli
    print("У вас " .. playerBeli .. " Beli")

    print("Проверка ассортимента перед покупкой...")
    local success, fruits = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("GetFruits")
    end)
    if not success then
        warn("Ошибка получения ассортимента: " .. tostring(fruits))
        return false
    end
    print("Ассортимент фруктов:")
    local fruitAvailable = false
    local fruitPrice = 0
    for _, fruitData in pairs(fruits) do
        if fruitData.Name and fruitData.Price then
            print(fruitData.Name .. ": " .. fruitData.Price .. " Beli")
            if fruitData.Name == fruitName then
                fruitAvailable = true
                fruitPrice = fruitData.Price
            end
        end
    end

    if not fruitAvailable then
        print("Фрукт " .. fruitName .. " отсутствует в магазине!")
        return false
    end

    if playerBeli < fruitPrice then
        warn("Недостаточно Beli! Нужно " .. fruitPrice .. " Beli, у вас " .. playerBeli .. " Beli.")
        return false
    end

    print("Попытка купить фрукт: " .. fruitName)
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("PurchaseRawFruit", fruitName)
    end)
    if success then
        print("Результат покупки: " .. tostring(result))
        if result == true then
            print("Фрукт успешно куплен: " .. fruitName)
            return true
        else
            warn("Покупка не удалась: сервер вернул " .. tostring(result))
            return false
        end
    else
        warn("Ошибка при покупке: " .. tostring(result))
        return false
    end
end

-- Задаём свой вебхук
local WEBHOOK_URL = "https://discord.com/api/webhooks/1362805475619508437/Cl5naW5xzGwKWEma3JbKQaiYS7ZexJv9zEKIcNqGgzv9HKORJUWhotV9eGpORlB83teL"

-- Фрукты, которые хотим отслеживать
local wantedFruitsForWebhook = {
    ["Gas Fruit"] = true,
    ["Mammoth Fruit"] = true,
    ["Dragon Fruit"] = true,
    ["Leopard Fruit"] = true,
    ["Kitsune Fruit"] = true,
    ["T-Rex Fruit"] = true,
    ["Yeti Fruit"] = true,
    ["Dough Fruit"] = true,
    ["Gravity Fruit"] = true,
}

-- Цвета фрукта
local fruitColors = {
    ["Gas Fruit"] = 0x111111,
    ["Dough Fruit"] = 0xF5DEB3,
    ["Mammoth Fruit"] = 0x8B0000,
    ["Dragon Fruit"] = 0xFF0000,
    ["Leopard Fruit"] = 0xD4AF37,
    ["Kitsune Fruit"] = 0x0099FF,
    ["T-Rex Fruit"] = 0x00FF00,
    ["Yeti Fruit"] = 0xB0E0E6,
    ["Buddha Fruit"] = 0xFFFF00,
    ["Gravity Fruit"] = 0x800080,
}

-- Иконки фруктов
local fruitImages = {
    ["Gas Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/7/7e/GasFruit.png",
    ["Mammoth Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/d/d3/MammothFruit.png",
    ["Dragon Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/4/43/DragonFruit.png",
    ["Leopard Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/8/8c/LeopardFruit.png",
    ["Kitsune Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/c/c3/KitsuneFruit.png",
    ["T-Rex Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/e/ea/T-RexFruit.png",
    ["Dough Fruit"] = "https://static.wikia.nocookie.net/blox-fruits/images/c/c6/DoughB.png/revision/latest?cb=20231028095419&path-prefix=ru",
    ["Yeti Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/1/14/YetiFruit.png",
    ["Buddha Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/7/72/BuddhaFruit.png",
    ["Gravity Fruit"] = "https://static.wikia.nocookie.net/roblox-blox-piece/images/2/22/GravityFruit.png",
}

-- Функция отправки вебхука
local function sendDiscordWebhook(fruitName, playerName)
    local HttpService = game:GetService("HttpService")
    local req = (request or http_request or syn.request)
    if not req then
        warn("[Webhook] Инжектор не поддерживает запросы!")
        return
    end
    if not WEBHOOK_URL then
        warn("[Webhook] WEBHOOK_URL не задан!")
        return
    end

    local embed = {
        title = "🌟 Найден редкий фрукт!",
        description = string.format("**🍉 Фрукт:** `%s`\n**👤 Игрок:** `%s`", fruitName, playerName),
        color = fruitColors[fruitName] or 0xFFFFFF,
        thumbnail = {
            url = fruitImages[fruitName] or "https://i.imgur.com/OS4J4yB.png"
        },
        fields = {
            {
                name = "🕒 Время",
                value = os.date("%d.%m.%Y %H:%M:%S"),
                inline = true
            }
        },
        footer = {
            text = "Blox Fruits Sniper",
            icon_url = "https://i.imgur.com/G9bDaPH.png"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local payload = {
        username = "Тайно Сосал",
        avatar_url = "https://www.meme-arsenal.com/memes/9b41f27d01e721f6f7f14f0df05870b5.jpg",
        content = "@here",
        embeds = { embed }
    }

    local success, response = pcall(function()
        return req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not success then
        warn("[Webhook] Ошибка: " .. tostring(response))
    else
        print("[Webhook] Ответ сервера: ", response.StatusCode)
    end
end

-- Таблица для предотвращения дублей
local sentFruits = {}

-- Функция проверки и отправки уведомления
local function tryNotify(tool)
    if tool:IsA("Tool") and wantedFruitsForWebhook[tool.Name] and not sentFruits[tool] then
        sentFruits[tool] = true
        print("[Webhook] Отправка уведомления для фрукта: " .. tool.Name)
        sendDiscordWebhook(tool.Name, game:GetService("Players").LocalPlayer.Name)
    end
end

-- Функция проверки существующих инструментов
local function checkExistingTools(container)
    if not container then
        print("[Webhook] Контейнер не найден")
        return
    end
    print("[Webhook] Проверка существующих инструментов в " .. container.Name)
    for _, item in ipairs(container:GetChildren()) do
        if item:IsA("Tool") then
            print("[Webhook] Найден инструмент: " .. item.Name)
            tryNotify(item)
        end
    end
end

-- Функция обработки контейнера
local function processContainer(container)
    if not container then
        print("[Webhook] Контейнер не существует")
        return
    end
    print("[Webhook] Настройка обработки для контейнера: " .. container.Name)
    checkExistingTools(container) -- Проверяем существующие инструменты
    container.ChildAdded:Connect(function(item)
        print("[Webhook] Новый инструмент добавлен в " .. container.Name .. ": " .. item.Name)
        tryNotify(item)
    end)
end

-- Инициализация
local player = game:GetService("Players").LocalPlayer

-- Ждём полной загрузки игры
print("[Webhook] Ожидание загрузки игры...")
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("[Webhook] Игра загружена")

-- Ждём игрока
while not player do
    player = game:GetService("Players").LocalPlayer
    if not player then
        print("[Webhook] Ожидание LocalPlayer...")
        task.wait(1)
    end
end
print("[Webhook] LocalPlayer найден: " .. player.Name)

-- Ждём Backpack
local backpack = player:WaitForChild("Backpack", 10)
if not backpack then
    warn("[Webhook] Backpack не найден")
    return
end
print("[Webhook] Backpack найден")

-- Обрабатываем Backpack
processContainer(backpack)

-- Обрабатываем Character при появлении
player.CharacterAdded:Connect(function(char)
    print("[Webhook] Новый Character загружен")
    local character = char
    processContainer(character)
    -- Проверяем инструменты в Character при загрузке
    checkExistingTools(character)
end)

-- Если Character уже существует
if player.Character then
    print("[Webhook] Character уже существует, обработка...")
    processContainer(player.Character)
    checkExistingTools(player.Character)
end

-- Проверка существующих инструментов с задержкой
task.spawn(function()
    task.wait(2) -- Даём время на загрузку
    print("[Webhook] Проверка существующих инструментов после задержки")
    local success, err = pcall(function()
        checkExistingTools(player.Backpack)
        if player.Character then
            checkExistingTools(player.Character)
        end
    end)
    if not success then
        warn("[Webhook] Ошибка при проверке инструментов: " .. tostring(err))
    end
end)



-- Функция для автоматической покупки фруктов
local function startFruitSnipe()
    while _G.AutoBuyRunning do
        if #_G.SelectedFruits == 0 then
        else
            for _, fruit in pairs(_G.SelectedFruits) do
                BuyFruit(fruit)
            end
        end
        task.wait(0.5) -- Задержка 0.5 секунды, как в исходном коде
    end
    print("Автоматическая покупка остановлена.")
end

local function runMainScript()
    print("Running main script...")

    -- Пытаемся выбрать команду Pirates с повторными попытками
    local maxAttempts = 1
    local attempt = 1
    local success = false
    while attempt <= maxAttempts and not success do
        print("[AutoJoin] Попытка " .. attempt .. " выбрать команду Pirates...")
        success = joinPiratesTeam()
        if not success then
            print("[AutoJoin] Попытка " .. attempt .. " не удалась, жду 2 секунды...")
            task.wait(2)
        end
        attempt = attempt + 1
    end
    if success then
        print("[AutoJoin] Команда Pirates успешно выбрана")
    else
        print("[AutoJoin] Не удалось выбрать команду Pirates после " .. maxAttempts .. " попыток")
    end

    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CollectionService = game:GetService("CollectionService")
    local RunService = game:GetService("RunService")
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local VirtualUser = game:GetService("VirtualUser")

    local PlaceIds = {
        ["First Sea"] = 2753915549,
        ["Second Sea"] = 4442272183,
        ["Third Sea"] = 7449423635
    }
    local usedServerIds = {}
    local maxPlayersThreshold = 10 -- Серверы с игроками <= 10
    local cursor = ""
    local playerId = Players.LocalPlayer.UserId -- Получаем UserId игрока
    local visitedFile = "visited_" .. playerId .. ".txt" -- Уникальный файл для посещённых серверов
    local lastClearFile = "last_clear_" .. playerId .. ".txt" -- Файл для хранения времени последнего очищения
    local PRINT_COOLDOWN = 3
    local ENABLE_LOGS = true
    local CLEAR_INTERVAL = 20 * 60 -- 20 минут в секундах

    -- Читаем посещённые серверы из уникального файла
    if isfile(visitedFile) then
        for line in readfile(visitedFile):gmatch("[^\r\n]+") do
            usedServerIds[line] = true
        end
    end

    -- Функция для логирования
    local function log(message)
        print("[LOG] " .. message)
    end

    -- Функция очистки файла посещённых серверов
    local function clearVisitedFile()
        if isfile(visitedFile) then
            delfile(visitedFile)
            usedServerIds = {}
            log("🧹 Файл посещённых серверов очищен")
            -- Сохраняем время последнего очищения
            writefile(lastClearFile, tostring(os.time()))
        end
    end

    -- Проверка и запуск таймера очистки
    local function setupClearTimer()
        -- Проверяем, нужно ли очистить файл при запуске
        if isfile(lastClearFile) then
            local lastClearTime = tonumber(readfile(lastClearFile)) or 0
            local currentTime = os.time()
            if currentTime - lastClearTime >= CLEAR_INTERVAL then
                clearVisitedFile() -- Очищаем сразу, если прошло ≥20 минут
            end
        else
            -- Если файла нет, создаём его и очищаем
            clearVisitedFile()
        end

        -- Запускаем фоновую задачу для очистки каждые 20 минут
        task.spawn(function()
            while true do
                task.wait(CLEAR_INTERVAL)
                clearVisitedFile()
            end
        end)
    end

    -- Определяем море по PlaceId
    local currentPlaceId = game.PlaceId
    local selectedSea
    for sea, placeId in pairs(PlaceIds) do
        if currentPlaceId == placeId then
            selectedSea = sea
            break
        end
    end
    if not selectedSea then
        print("❌ Неизвестный мир (PlaceId: " .. currentPlaceId .. ")")
        return
    end
    local PlaceId = PlaceIds[selectedSea]

    print("🚀 Хоп запущен! Мир: " .. selectedSea)

    -- Функция для получения HumanoidRootPart
    local function getHRP()
        local player = Players.LocalPlayer
        if not player.Character then
            player.CharacterAdded:Wait()
        end
        local character = player.Character
        local hrp = character:WaitForChild("HumanoidRootPart")
        return hrp
    end

    -- Функция для проверки, взят ли фрукт игроком
    local function isHeldByPlayer(obj)
        local parent = obj.Parent
        if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character == parent then
                    return true
                end
            end
        end
        return false
    end

    -- Функция поиска ближайшего фрукта
   local function findClosestFruit()
    local hrp = getHRP()
    if not hrp then 
        print("[⚠️] getHRP вернул nil — персонаж не найден")
        return nil 
    end

        local fruits = {}
        local fruitFolder = workspace:FindFirstChild("Fruits") or workspace:FindFirstChild("FruitFolder")
        local containers = {workspace}
        if fruitFolder then
            table.insert(containers, fruitFolder)
        end

        for _, container in ipairs(containers) do
            for _, obj in ipairs(container:GetChildren()) do
                if (obj:IsA("Tool") or obj:IsA("Model")) and obj.Name:lower():find("fruit") then
                    if not (obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid")) then
                        if not isHeldByPlayer(obj) then
                            if not (obj.Name:lower():find("dealer") or obj.Name:lower():find("gacha")) then
                                local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                                if handle and handle:IsDescendantOf(workspace) then
                                    local dist = (hrp.Position - handle.Position).Magnitude
                                    table.insert(fruits, {obj = obj, dist = dist})
                                end
                            end
                        end
                    end
                end
            end
        end

        table.sort(fruits, function(a, b) return a.dist < b.dist end)
        return fruits[1] and fruits[1].obj or nil
    end

    -- Функция безопасной записи в файл посещённых серверов
    local function safeWriteVisited(serverId)
        writefile(visitedFile, serverId .. "\n", true) -- Записываем в уникальный файл
    end

    -- Функция хопа на новый сервер
   local function hopToNewServer()
        -- Случайная задержка для снижения нагрузки на API
        task.wait(math.random(0.5, 1.5))
        
        local ok, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor))
        end)
        
        -- Проверка на ошибку 429 (Too Many Requests)
        if not ok and tostring(response):find("429") then
            print("⚠️ Превышен лимит запросов, жду 10 сек...")
            task.wait(10)
            return false
        end
        
        if ok and response.data and #response.data > 0 then
            local validServers = {}
            for _, s in ipairs(response.data) do
                if s.playing <= maxPlayersThreshold and s.playing < s.maxPlayers and not usedServerIds[s.id] then
                    table.insert(validServers, s)
                end
            end
            
            if #validServers > 0 then
                local randomIndex = math.random(1, #validServers)
                local selectedServer = validServers[randomIndex]
                usedServerIds[selectedServer.id] = true
                print("🔗 Хоп на " .. selectedServer.id .. " (" .. selectedServer.playing .. " игроков)")
                
                -- Записываем сервер в уникальный файл
                safeWriteVisited(selectedServer.id)
                
                TeleportService:TeleportToPlaceInstance(PlaceId, selectedServer.id)
                return true
            end
            cursor = response.nextPageCursor or ""
        else
            print("❌ Нет серверов. Cursor: " .. cursor)
            cursor = ""
        end
        return false
    end


    -- Запускаем таймер очистки
    setupClearTimer()

    -- Основной цикл с поиском фруктов и хопом
    -- Файл для хранения выбранных фруктов
    local SELECTED_FRUITS_FILE = "SelectedFruits.json"
    local HttpService = game:GetService("HttpService")

    -- Функция для сохранения выбранных фруктов
    local function saveSelectedFruits()
        print("[Отладка] Пытаюсь сохранить фрукты...")

        local hasWritefile = pcall(function()
            return type(writefile) == "function"
        end)

        if not hasWritefile then
            print("[Ошибка] Функция writefile недоступна в этой среде. Сохранение невозможно.")
            onMessage("Сохранение фруктов не поддерживается в этой среде!")
            return false
        else
            print("[Отладка] Функция writefile доступна")
        end

        local success, json = pcall(function()
            return HttpService:JSONEncode(_G.SelectedFruits)
        end)
        if not success then
            print("[Ошибка] Не удалось преобразовать фрукты в JSON: " .. tostring(json))
            onMessage("Ошибка при сохранении фруктов!")
            return false
        else
            print("[Отладка] JSON успешно создан: " .. json)
        end

        local writeSuccess, writeError = pcall(function()
            writefile(SELECTED_FRUITS_FILE, json)
        end)
        if writeSuccess then
            return true
        else
            print("[Ошибка] Не удалось записать файл: " .. tostring(writeError))
            onMessage("Не удалось сохранить фрукты!")
            return false
        end
    end

    -- Функция для загрузки выбранных фруктов
    local function loadSelectedFruits()
        print("[Отладка] Пытаюсь загрузить фрукты...")

        local hasReadfile = pcall(function()
            return type(readfile) == "function"
        end)
        local hasIsfile = pcall(function()
            return type(isfile) == "function"
        end)

        if not hasReadfile or not hasIsfile then
            print("[Ошибка] Функции readfile или isfile недоступны. Загрузка невозможна.")
            _G.SelectedFruits = {}
            return
        else
            print("[Отладка] Функции readfile и isfile доступны")
        end

        if isfile(SELECTED_FRUITS_FILE) then
            local success, content = pcall(function()
                return readfile(SELECTED_FRUITS_FILE)
            end)
            if not success then
                print("[Ошибка] Не удалось прочитать файл: " .. tostring(content))
                _G.SelectedFruits = {}
                return
            else
                print("[Отладка] Файл прочитан: " .. content)
            end

            local decodeSuccess, result = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if decodeSuccess and result then
                _G.SelectedFruits = result
            else
                print("[Ошибка] Не удалось декодировать JSON: " .. tostring(result))
                _G.SelectedFruits = {}
            end
        else
            _G.SelectedFruits = {}
        end
    end

local function createFruitSniperGUI()
    -- Создаём ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FruitSniperGUI"
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Основной фрейм
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Select Fruits"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    -- Кнопка закрытия (белая)
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Text = "X"
    closeButton.Parent = frame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Прокручиваемый фрейм для списка фруктов
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 5
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.Parent = frame

    -- UIListLayout для списка фруктов
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollingFrame

    -- Получаем список фруктов
    local FruitList = {}
    local success, fruits = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("GetFruits")
    end)
    if success then
        for _, fruitData in pairs(fruits) do
            if fruitData.Name then
                table.insert(FruitList, fruitData.Name)
            end
        end
        for _, fruitName in pairs(FruitList) do
        end
    else
        warn("Ошибка получения списка фруктов: " .. tostring(fruits))
        FruitList = {
            "Bomb-Bomb", "Spike-Spike", "Chop-Chop", "Spring-Spring", "Kilo-Kilo",
            "Smoke-Smoke", "Spin-Spin", "Flame-Flame", "Bird-Bird: Falcon", "Ice-Ice",
            "Sand-Sand", "Dark-Dark", "Revive-Revive", "Diamond-Diamond", "Light-Light",
            "Love-Love", "Rubber-Rubber", "Barrier-Barrier", "Magma-Magma", "Door-Door",
            "Quake-Quake", "Human-Human: Buddha", "String-String", "Bird-Bird: Phoenix",
            "Rumble-Rumble", "Paw-Paw", "Gravity-Gravity", "Dough-Dough", "Shadow-Shadow",
            "Venom-Venom", "Control-Control", "Soul-Soul", "Dragon-Dragon", "T-Rex-T-Rex",
            "Mammoth-Mammoth", "Leopard-Leopard", "Kitsune-Kitsune", "Gas-Gas",
            "Blizzard-Blizzard", "Portal-Portal", "Sound-Sound", "Ghost-Ghost", "Pain-Pain",
            "Rocket-Rocket"
        }
        print("Используется статический список фруктов.")
    end

    -- Создаём кнопки для каждого фрукта
    for i, fruitName in ipairs(FruitList) do
        local fruitButton = Instance.new("TextButton")
        fruitButton.Size = UDim2.new(1, -10, 0, 30)
        fruitButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        fruitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        fruitButton.Font = Enum.Font.SourceSans
        fruitButton.TextSize = 16
        fruitButton.Text = " " .. fruitName
        fruitButton.TextXAlignment = Enum.TextXAlignment.Left
        fruitButton.Parent = scrollingFrame
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = fruitButton

        -- Фрейм для переключателя
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(0, 50, 0, 20)
        toggleFrame.Position = UDim2.new(1, -60, 0.5, -10)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        toggleFrame.BackgroundTransparency = 0.5
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = fruitButton
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleFrame

       -- Индикатор выбора (кружок)
local checkFrame = Instance.new("Frame")
checkFrame.Size = UDim2.new(0, 20, 0, 20)
checkFrame.Position = UDim2.new(0, 0, 0, 0)
checkFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Всегда чёрный
checkFrame.Parent = toggleFrame
local checkCorner = Instance.new("UICorner")
checkCorner.CornerRadius = UDim.new(1, 0)
checkCorner.Parent = checkFrame

-- Проверяем, выбран ли фрукт
local isSelected = table.find(_G.SelectedFruits, fruitName) ~= nil
if isSelected then
    checkFrame.Position = UDim2.new(1, -20, 0, 0)
    toggleFrame.BackgroundTransparency = 0
    -- Убрали изменение цвета на зелёный
end

-- Анимация для переключателя
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function animateToggle(selected)
    toggleFrame.BackgroundTransparency = selected and 0 or 0.5
    local targetPosition = selected and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
    game:GetService("TweenService"):Create(checkFrame, tweenInfo, {Position = targetPosition}):Play()
end

        -- Обработчик нажатия
        fruitButton.MouseButton1Click:Connect(function()
            if table.find(_G.SelectedFruits, fruitName) then
                for j, selectedFruit in ipairs(_G.SelectedFruits) do
                    if selectedFruit == fruitName then
                        table.remove(_G.SelectedFruits, j)
                        animateToggle(false)
                        print("Удалён фрукт: " .. fruitName)
                        break
                    end
                end
            else
                table.insert(_G.SelectedFruits, fruitName)
                animateToggle(true)
                print("Добавлен фрукт: " .. fruitName)
            end
            saveSelectedFruits() -- Строка 685
            print("Текущий список фруктов: " .. table.concat(_G.SelectedFruits, ", "))
        end)
    end

    -- Обновляем CanvasSize для прокрутки
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #FruitList * 35)

    -- Добавляем возможность перетаскивания
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart", 10)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not hrp or not humanoid then
        print("[Ошибка] Не удалось найти HumanoidRootPart или Humanoid")
        onMessage("Ошибка: Персонаж не инициализирован")
        return
    end

    local collectingEnabled = false
    local autoStoreEnabled = false
    local serverHopEnabled = false
    local autoBuyEnabled = false
    local antiAfkEnabled = false
    local FlightSpeed = 300
    local activeConnections = {}
    local espCache = {}
    local lastPurchaseTime = nil
    local COOLDOWN_DURATION = 7200
    local NOTIFICATION_DURATION = 3
    local SAVE_FILE = "lastPurchaseTime_" .. player.UserId .. ".txt"

    local wantedFruits = {
        ["Kilo Fruit"] = true, ["Spin Fruit"] = true, ["Pain Fruit"] = true, ["Chop Fruit"] = true, ["Sprint Fruit"] = true,
        ["Bomb Fruit"] = true, ["Smoke Fruit"] = true, ["Spike Fruit"] = true, ["Flame Fruit"] = true,
        ["Falcon Fruit"] = true, ["Ice Fruit"] = true, ["Sand Fruit"] = true, ["Dark Fruit"] = true,
        ["Revive Fruit"] = true, ["Diamond Fruit"] = true, ["Light Fruit"] = true, ["Rubber Fruit"] = true,
        ["Barrier Fruit"] = true, ["Magma Fruit"] = true, ["Quake Fruit"] = true, ["Spider Fruit"] = true,
        ["Phoenix Fruit"] = true, ["Buddha Fruit"] = true, ["Portal Fruit"] = true, ["Rumble Fruit"] = true,
        ["Paw Fruit"] = true, ["Blizzard Fruit"] = true, ["Gravity Fruit"] = true, ["Dough Fruit"] = true,
        ["Shadow Fruit"] = true, ["Venom Fruit"] = true, ["Control Fruit"] = true, ["Spirit Fruit"] = true,
        ["Dragon Fruit"] = true, ["Leopard Fruit"] = true, ["Kitsune Fruit"] = true, ["T-Rex Fruit"] = true,
        ["Mammoth Fruit"] = true, ["Gas Fruit"] = true, ["Yeti Fruit"] = true, ["Blade Fruit"] = true,
        ["Rocket Fruit"] = true, ["Ghost Fruit"] = true, ['Love Fruit'] = true, ["Creation Fruit"] = true, 
        ["Eagle Fruit"] = true
    }

    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        hrp = newChar:WaitForChild("HumanoidRootPart", 10)
        humanoid = newChar:WaitForChild("Humanoid", 10)
        if not hrp or not humanoid then
            print("[Ошибка] Не удалось обновить HumanoidRootPart или Humanoid после респавна")
        end
    end)

    local function disableCollisions()
        -- Функция уже есть в твоем скрипте, оставляем без изменений
    end

    local function enableCollisions()
        -- Функция уже есть в твоем скрипте, оставляем без изменений
    end

    local function createESP(fruit)
    if espCache[fruit] then return end

    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("Part") or fruit:FindFirstChildOfClass("MeshPart")
    if not handle or not handle:IsDescendantOf(workspace) then
        return -- ❌ Не добавляем ESP на мусор или удалённые объекты
    end

    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Parent = handle
    BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 100, 0, 50)
    BillboardGui.Name = "FruitESP"

    local NameLabel = Instance.new("TextLabel")
    NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.Position = UDim2.new(0, 0, 0, 0)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    NameLabel.TextScaled = true
    NameLabel.Text = "[" .. fruit.Name .. "]"
    NameLabel.TextStrokeTransparency = 0
    NameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    NameLabel.Parent = BillboardGui

    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    DistanceLabel.Font = Enum.Font.Gotham
    DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DistanceLabel.TextScaled = true
    DistanceLabel.Text = "..."
    DistanceLabel.Parent = BillboardGui

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not handle or not handle:IsDescendantOf(workspace) or not hrp then
            if connection then connection:Disconnect() end
            if BillboardGui then BillboardGui:Destroy() end
            espCache[fruit] = nil
            return
        end
        local dist = (hrp.Position - handle.Position).Magnitude
        DistanceLabel.Text = math.floor(dist) .. " м"
    end)

    espCache[fruit] = BillboardGui
end

   local function disableESP()
        for fruit, gui in pairs(espCache) do
            gui:Destroy()
        end
        table.clear(espCache)
    end

    local CollectionService = game:GetService("CollectionService")

    -- Убедимся, что lastMessageTime и MESSAGE_INTERVAL инициализированы
    if not lastMessageTime then
        lastMessageTime = 0
    end
    if not MESSAGE_INTERVAL then
        MESSAGE_INTERVAL = 15
    end

    local lastLogTime = 0
    local LOG_INTERVAL = 10
    local fruitCache = {} -- Кэш для фруктов

    local function findNearestFruit()
        local fruits = {}
        local workspace = game:GetService("Workspace")

        -- Проверяем объекты в Workspace
    for _, obj in pairs(workspace:GetChildren()) do
        -- Проверяем, является ли объект Model с именем "Fruit" или содержит "Fruit" в названии
        if obj:IsA("Model") and (obj.Name == "Fruit" or string.find(obj.Name:lower(), "fruit")) then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part") or obj:FindFirstChildOfClass("MeshPart")
            if handle and handle:IsDescendantOf(workspace) then
                -- Проверяем, не находится ли фрукт у игрока (в рюкзаке или в руках)
                if not obj:IsDescendantOf(player.Character) and not obj:IsDescendantOf(player.Backpack) then
                    fruitCache[obj] = true
                    local distance = (hrp.Position - handle.Position).Magnitude
                    table.insert(fruits, {obj = obj, dist = distance})
                else
                    bufferedPrint("[Поиск Фруктов] Пропускаю фрукт " .. obj.Name .. ", он уже у игрока")
                end
            end
        -- Проверяем Tool (подобранные фрукты)
        elseif obj:IsA("Tool") and string.find(obj.Name:lower(), "fruit") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part") or obj:FindFirstChildOfClass("MeshPart")
            if handle and handle:IsDescendantOf(workspace) then
                -- Проверяем, не находится ли фрукт у игрока (в рюкзаке или в руках)
                if not obj:IsDescendantOf(player.Character) and not obj:IsDescendantOf(player.Backpack) then
                    fruitCache[obj] = true
                    local distance = (hrp.Position - handle.Position).Magnitude
                    table.insert(fruits, {obj = obj, dist = distance})
                else
                    bufferedPrint("[Поиск Фруктов] Пропускаю фрукт " .. obj.Name .. ", он уже у игрока")
                end
            end
        end
    end

       -- Проверяем папку Fruits, если она существует
    local fruitFolder = workspace:FindFirstChild("Fruits") or workspace:FindFirstChild("FruitFolder")
    if fruitFolder then
        for _, obj in pairs(fruitFolder:GetChildren()) do
            if obj:IsA("Model") and (obj.Name == "Fruit" or string.find(obj.Name:lower(), "fruit")) then
                local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part") or obj:FindFirstChildOfClass("MeshPart")
                if handle and handle:IsDescendantOf(workspace) then
                    -- Проверяем, не находится ли фрукт у игрока
                    if not obj:IsDescendantOf(player.Character) and not obj:IsDescendantOf(player.Backpack) then
                        fruitCache[obj] = true
                        local distance = (hrp.Position - handle.Position).Magnitude
                        table.insert(fruits, {obj = obj, dist = distance})
                    else
                        bufferedPrint("[Поиск Фруктов] Пропускаю фрукт " .. obj.Name .. ", он уже у игрока")
                    end
                end
            end
        end
    end

      -- Чистим кэш от удалённых фруктов
    for obj in pairs(fruitCache) do
        if not obj:IsDescendantOf(workspace) then
            fruitCache[obj] = nil
        end
    end

-- Логирование
    if #fruits == 0 and tick() - lastLogTime >= LOG_INTERVAL then
        print("[Поиск Фруктов] Фрукты не найдены")
        lastLogTime = tick()
    elseif #fruits > 0 and tick() - lastLogTime >= LOG_INTERVAL then
        print("[Поиск Фруктов] Найден: " .. fruits[1].obj.Name .. " на расстоянии " .. math.floor(fruits[1].dist) .. " м")
        lastLogTime = tick()
    end

    -- Сортируем по расстоянию и возвращаем ближайший
    table.sort(fruits, function(a, b) return a.dist < b.dist end)
    return fruits[1] and fruits[1].obj or nil
end

    local function collectFruit(fruit)
    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("Part") or fruit:FindFirstChildOfClass("MeshPart")
    if not handle or not handle:IsDescendantOf(workspace) then
        return -- Убрали лог, чтобы не спамило
    end

    if fruit:IsDescendantOf(player.Character) or fruit:IsDescendantOf(player.Backpack) then
        return
    end

    if not humanoid or not hrp then return end

    if humanoid:GetState() == Enum.HumanoidStateType.Seated then
        humanoid.Sit = false
        task.wait(0.1)
    end

    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end

  local targetPosition
local success = pcall(function()
    targetPosition = handle.Position + Vector3.new(0, 2, 0)
end)
if not success or not targetPosition then return end

    local startPosition = hrp.Position
    local distance = (startPosition - targetPosition).Magnitude
    local speed = FlightSpeed or 300
    local totalTime = distance / speed

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp

    local tweenInfo = TweenInfo.new(totalTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    currentTween = tween

    local startTick = tick()
    tween:Play()

    local completed = false
    local tweenConnection = tween.Completed:Connect(function()
        completed = true
    end)

    while not completed and tick() - startTick < totalTime + 0.5 do
        if not collectingEnabled then
            tween:Cancel()
            tweenConnection:Disconnect()
            currentTween = nil
            break
        end
        if not handle:IsDescendantOf(workspace) then
            tween:Cancel()
            tweenConnection:Disconnect()
            currentTween = nil
            break
        end
        if fruit:IsDescendantOf(player.Character) or fruit:IsDescendantOf(player.Backpack) then
            tween:Cancel()
            tweenConnection:Disconnect()
            currentTween = nil
            break
        end
        task.wait(0.016)
    end

    if currentTween then
        currentTween = nil
    end
    tweenConnection:Disconnect()
    bodyVelocity:Destroy()

    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end

    hrp.Velocity = Vector3.zero
    hrp.Anchored = true
    task.wait(0.1)
    hrp.Anchored = false

    local pickedFruit = nil
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and wantedFruits[item.Name] then
            pickedFruit = item
            break
        end
    end
    if not pickedFruit then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and wantedFruits[item.Name] then
                pickedFruit = item
                break
            end
        end
    end

    if pickedFruit and espCache[fruit] then
        espCache[fruit]:Destroy()
        espCache[fruit] = nil
    end
end

    local function startAutoCollect()
        task.wait(0.1) -- Задержка при старте, чтобы GUI не лагал
        while collectingEnabled do
            if character and hrp and humanoid then
                local fruit = findNearestFruit()
                if fruit then
                    if _G.FruitESPEnabled then -- проверка глобального флага
                        createESP(fruit)
                    end
                    collectFruit(fruit)
                    task.wait(0.5) -- Задержка после сбора
                else
                    task.wait(1) -- Задержка без фруктов
                end
            else
                character = player.Character
                if character then
                    hrp = character:FindFirstChild("HumanoidRootPart")
                    humanoid = character:FindFirstChild("Humanoid")
                end
                task.wait(1)
            end
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
                return true
            else
                return false
            end
        else
            bufferedPrint("[Хранение] CommF_ не найден в ReplicatedStorage.Remotes")
            return false
        end
    end

 local function getFruitCountInInventory(inventory, fruitKey)
    local count = 0
    for _, item in ipairs(inventory) do
        if item.Type == "Blox Fruit" and item.Name == fruitKey then
            count = count + 1
        end
    end
    return count
end

local function startAutoStore()
    while autoStoreEnabled do
        local fruitsToStore = {}

        -- Фрукты в руках
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and wantedFruits[item.Name] then
                table.insert(fruitsToStore, item)
            end
        end

        -- Фрукты в рюкзаке
        for _, item in pairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") and wantedFruits[item.Name] then
                table.insert(fruitsToStore, item)
            end
        end

        if #fruitsToStore == 0 then
            task.wait(0.5)
            continue
        end

        -- Получаем инвентарь
        local inventory
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
        end)

        if success then
            inventory = result
        else
            bufferedPrint("[Хранение] Ошибка загрузки инвентаря: " .. tostring(result))
            task.wait(1)
            continue
        end

        -- Получаем список геймпассов
        local hasStoragePass = false
        local suc, gamepasses = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetGamePass")
        end)
        if suc and gamepasses and table.find(gamepasses, "FruitStorage") then
            hasStoragePass = true
        end

        for _, pickedFruit in ipairs(fruitsToStore) do
    local fruitName = pickedFruit.Name
    local currentCount = getFruitCountInInventory(inventory, fruitName)
    local maxCount = hasStoragePass and 4 or 1

    if currentCount < maxCount then
        local success = storeFruit(pickedFruit)
        if success then
            bufferedPrint("[Хранение] Сохранён фрукт: " .. fruitName)
        else
            bufferedPrint("[Хранение] Ошибка сохранения: " .. fruitName)
        end
    else
        bufferedPrint("[Хранение] Нет места для фрукта: " .. fruitName .. " (" .. currentCount .. "/" .. maxCount .. ")")
    end

    task.wait(0.1)
end
        task.wait(0.5)
    end
    bufferedPrint("[Хранение] Автохранение остановлено")
end




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
        task.delay(NOTIFICATION_DURATION, function()
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

    local function startServerHop()
    print("[Server Hop] Функция запущена")
    while serverHopEnabled do
        print("[Server Hop] Ищу фрукты...")
        local fruit = findNearestFruit() -- Предполагается, что эта функция у тебя есть
        if fruit then
            print("[Server Hop] Фрукт найден: " .. fruit.Name)
            -- Ждём, пока фрукт исчезнет
            while findNearestFruit() and serverHopEnabled do
                task.wait(5)
            end
        else
            print("[Server Hop] Фруктов нет, жду 5 секунд")
            task.wait(5)
        end

        if serverHopEnabled then
            print("[Server Hop] Прыгаю на новый сервер")
            hopToNewServer() -- Предполагается, что эта функция у тебя есть
        end
        task.wait(0.1)
    end
    print("[Server Hop] Функция остановлена")
end

-- Привязка кнопки в GUI с логами
local tab1Buttons = {
    {text = "Server Hop", posY = 170, callback = function(isOn)
        serverHopEnabled = isOn
        print("[Server Hop] Кнопка: " .. (isOn and "включена" or "выключена"))
        if isOn then
            task.spawn(startServerHop) -- Запускаем функцию в фоне
        end
    end}
}

    -- Workspace.DescendantAdded:Connect
    Workspace.DescendantAdded:Connect(function(child)
        if collectingEnabled then
            if (child:IsA("Model") and child.Name == "Fruit") or CollectionService:HasTag(child, "Fruit") then
                local handle = child:FindFirstChild("Handle") or child:FindFirstChildOfClass("Part") or child:FindFirstChildOfClass("MeshPart")
                if handle then
                    local name = child.Name or "Без имени"
                    local fruitName = name
                    if child:IsA("Model") then
                        local fruitNameValue = child:FindFirstChild("FruitName") or child:FindFirstChild("Name")
                        if fruitNameValue and fruitNameValue:IsA("StringValue") then
                            fruitName = fruitNameValue.Value
                        end

                        local attributeName = child:GetAttribute("FruitName") or child:GetAttribute("Name")
                        if attributeName then
                            fruitName = attributeName
                        end

                        if handle and handle.Name ~= "Handle" then
                            fruitName = handle.Name
                        end

                        local extractedName = string.match(name, "%[(.-)%]")
                        if extractedName then
                            fruitName = extractedName
                        end
                    end

                    if collectingEnabled then
                        collectFruit(child)
                    end
                    if savedSettings["ESP Fruit"] then
                        createESP(child)
                    end
                end
            end
        end
    end)

-- Далее идёт создание GUI
    local ScreenGui = Instance.new("ScreenGui", playerGui)
    ScreenGui.Name = "FruitCollectorGui"
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("ImageLabel", ScreenGui)
    Frame.Size = UDim2.new(0, 500, 0, 210)
    Frame.Position = UDim2.new(0.5, -250, 0.5, -120)
    Frame.Image = "rbxassetid://111940581899257" -- Фон восстановлен
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
    minimizedFrame.Text = "Open"
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
                object.ImageTransparency = target
            elseif object:IsA("TextButton") or object:IsA("TextLabel") then
                object.BackgroundTransparency = target
                object.TextTransparency = target
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
                            child.BackgroundTransparency = 0
                        elseif child.Name == "Fill" then
                            child.BackgroundTransparency = child.Size.X.Offset > 0 and 0 or 0.5
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
                            child.BackgroundTransparency = 1
                        end
                    end
                end
            end
        end
        Frame.ImageTransparency = 1
        Frame.Visible = false
        if minimizedFrame then
            minimizedFrame.Position = lastFramePosition
            minimizedFrame.Visible = true
            minimizedFrame.BackgroundTransparency = 1
            minimizedFrame.TextTransparency = 1
            minimizedFrame.BackgroundTransparency = 0
            minimizedFrame.TextTransparency = 0
        end
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
        return {["Teleport Fruit"] = false, ["ESP Fruit"] = false, ["Auto Store Fruit"] = false, ["Server Hop"] = false, ["Auto Buy Fruit"] = false, ["Anti AFK"] = false, ["Auto Buy Fruits"] = false}
    end

    local savedSettings = loadSettings()

local function createSimpleButton(text, posY, callback)
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

        Button.MouseButton1Click:Connect(function()
            callback()
        end)
        return Button
    end

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
        Button.BackgroundTransparency = 0
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
            character = player.Character
            if character then
                hrp = character:FindFirstChild("HumanoidRootPart")
                humanoid = character:FindFirstChild("Humanoid")
            end
            if character and hrp and humanoid then
                callback(true)
            end
        end

        Button.MouseButton1Click:Connect(function()
            isOn = not isOn
            if isOn then
                Fill.Size = UDim2.new(0, 50, 0, 20)
                Toggle.Position = UDim2.new(1, -25, 0.5, -10)
                Fill.BackgroundTransparency = 0
                if text == "Teleport Fruit" then disableCollisions() end
            else
                Fill.Size = UDim2.new(0, 0, 0, 20)
                Toggle.Position = UDim2.new(1, -55, 0.5, -10)
                Fill.BackgroundTransparency = 0.5
                if text == "Teleport Fruit" then stopAllConnections() end
            end
            character = player.Character
            if character then
                hrp = character:FindFirstChild("HumanoidRootPart")
                humanoid = character:FindFirstChild("Humanoid")
            end
            if character and hrp and humanoid then
                callback(isOn)
            end
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
        {text = "Anti AFK", posY = 50, callback = function(isOn)
            antiAfkEnabled = isOn
            print("[Anti-AFK] Анти-АФК " .. (isOn and "включён" or "отключён"))
        end},
        {text = "Auto Buy Random Fruit", posY = 90, callback = function(isOn)
            autoBuyEnabled = isOn
            if isOn then task.spawn(startAutoBuy) end
        end},
        {text = "Auto Buy Fruits", posY = 130, callback = function(isOn)
            _G.AutoBuyRunning = isOn
            if isOn then task.spawn(startFruitSnipe) end
        end},
        {text = "Select Fruit", posY = 170, callback = function()
            createFruitSniperGUI()
        end, useSimpleButton = true}
    }

    local allButtons = {}
    for _, btn in pairs(tab1Buttons) do
        local button = createToggleButton(btn.text, btn.posY, btn.callback)
        table.insert(allButtons, button)
    end
    for _, btn in pairs(tab2Buttons) do
        local button
        if btn.useSimpleButton then
            button = createSimpleButton(btn.text, btn.posY, btn.callback)
        else
            button = createToggleButton(btn.text, btn.posY, btn.callback)
        end
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
    TitleText.ZIndex = 1
    TitleText.Parent = TitleLabel

    openFrame()

    local lastResetCheck = tick()
    spawn(function()
        while true do
            local currentTime = tick()
            if currentTime - lastResetCheck >= 60 then
                if currentTime - lastResetTime >= 14400 then
                    stopAllConnections()
                    lastResetTime = currentTime
                    bufferedPrint("[Сброс] Выполнен сброс соединений (каждые 4 часа)")
                end
                lastResetCheck = currentTime
            end
            task.wait(1)
        end
    end)
end

local savedKey = loadKey()
if savedKey then
    local success, isValid = pcall(verifyKey, savedKey)
    if success and isValid then
        print("[Main] Ключ валиден, запускаю основной скрипт...")
        runMainScript()
    else
        print("[Main] Ключ невалиден, создаю GUI...")
        createGUI()
    end
else
    print("[Main] Ключ не найден, создаю GUI...")
    createGUI()
end

print("[Main] Инициализация основного скрипта...")
runMainScript()
