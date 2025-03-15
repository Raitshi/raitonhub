--! json library
--! cryptography library
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local CONV={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+CONV[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
local lEncode, lDecode, lDigest = a3, aw, Z;

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

print("Waiting for game load...")
repeat task.wait(1) until game:IsLoaded()
print("Game loaded!")

-- Проверка PlaceId
local validPlaceIds = {
    [2753915549] = true, -- Основной режим Blox Fruits (First Sea)
    [4442272183] = true, -- Второй мир (Second Sea)
    [7449423635] = true  -- Третий мир (Third Sea)
}

if not validPlaceIds[game.PlaceId] then
    warn("Этот скрипт работает только в Blox Fruits. Ожидаемые PlaceId: 2753915549, 4442272183, 7449423635. Текущий PlaceId: " .. game.PlaceId)
    onMessage("Этот скрипт работает только в Blox Fruits!")
    return
end

local Players = game:GetService("Players")
local player
local maxWaitTime = 10
local elapsed = 0
while not player and elapsed < maxWaitTime do
    player = Players.LocalPlayer
    if not player then
        print("Waiting for LocalPlayer...")
        task.wait(1)
        elapsed = elapsed + 1
    end
end

if not player then
    onMessage("Error: LocalPlayer not found")
    return
end
print("LocalPlayer: " .. player.Name)

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    onMessage("Error: PlayerGui not found")
    return
end

local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor, fGetHwid = 
    setclipboard or toclipboard, 
    request or http_request or syn_request, 
    string.char, tostring, string.sub, os.time, math.random, math.floor, 
    gethwid or function() return player.UserId end

local cachedLink, cachedTime = "", 0
local host = "https://api.platoboost.com"
print("Checking host: " .. host)
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
})
if hostResponse and hostResponse.StatusCode and hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net"
    print("Host changed to: " .. host)
else
    print("Host confirmed: " .. host)
end

function cacheLink()
    if cachedTime + (10*60) < fOsTime() then
        print("Requesting new link...")
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({service = service, identifier = lDigest(fGetHwid())}),
            Headers = {["Content-Type"] = "application/json"}
        })
        if response and response.StatusCode then
            if response.StatusCode == 200 then
                local decoded = lDecode(response.Body)
                if decoded.success then
                    cachedLink = decoded.data.url
                    cachedTime = fOsTime()
                    print("New link: " .. cachedLink)
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
        print("Using cached link: " .. cachedLink)
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
        print("Copied: " .. link)
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
            print("Key saved: " .. key)
        else
            print("Failed to save key: " .. tostring(writeError))
            onMessage("Warning: Could not save key to file")
        end
    else
        print("writefile function not available, skipping key save")
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
            print("Loaded key: " .. key)
            return key
        else
            print("Failed to load key: " .. tostring(key))
        end
    end
    return nil
end

local function createGUI()
    print("Creating Key GUI...")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Полностью чёрный фон
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 280, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Key Verification"
    title.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый текст для контраста
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0, 260, 0, 30)
    keyInput.Position = UDim2.new(0, 20, 0, 50)
    keyInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Белое поле для ввода
    keyInput.TextColor3 = Color3.fromRGB(0, 0, 0) -- Чёрный текст внутри поля
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
    useButton.Position = UDim2.new(0, 40, 0, 150)
    useButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Белая кнопка Use Key
    useButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- Чёрный текст
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
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Белый фон кнопки
    closeButton.TextColor3 = Color3.fromRGB(255, 0, 0) -- Красный текст
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Text = "X"
    closeButton.BorderSizePixel = 0
    closeButton.Parent = frame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton

    -- Анимация при наведении и клике для кнопки Close
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    end)
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        task.wait(0.1)
        TweenService:Create(closeButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        screenGui:Destroy()
    end)

    useButton.MouseButton1Click:Connect(function()
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
end

local function runMainScript()
    print("Running main script...")
    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CollectionService = game:GetService("CollectionService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local VirtualUser = game:GetService("VirtualUser")

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
        hrp = newChar:WaitForChild("HumanoidRootPart", 10)
        humanoid = newChar:WaitForChild("Humanoid", 10)
        if not hrp or not humanoid then
            print("[Ошибка] Не удалось обновить HumanoidRootPart или Humanoid после респавна")
        end
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
            local success, err = pcall(function()
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
            end)
            if not success then
                print("[ESP] Ошибка создания ESP: " .. err)
            end
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

        if not humanoid or not hrp then
            print("[Сбор] Humanoid или HumanoidRootPart отсутствуют, прерываю.")
            return
        end

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

    local ScreenGui = Instance.new("ScreenGui", playerGui)
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
end

local savedKey = loadKey()
if savedKey then
    local success, isValid = pcall(verifyKey, savedKey)
    if success and isValid then
        runMainScript()
    else
        createGUI()
    end
else
    createGUI()
end
