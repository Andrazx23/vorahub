loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    warn("⚠️ UI failed to loaded!")
    return
else
    print("✓ UI loaded successfully!")
end

local Window = WindUI:CreateWindow({
    Title = "VORAHUB",
    Icon = "rbxassetid://129615590266896",
    Author = "Fish It | Premium",
    Folder = "VORA_HUB",
    Size = UDim2.fromOffset(260, 290),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,
    User = {
        Enabled = false,
        Anonymous = false,
        Callback = function()
            WindUI:SetTheme("Dark")
        end,
    },                                                             
})                                                   

Window:EditOpenButton({ Enabled = false })
Window:SetToggleKey(nil)

local Vora = Instance.new('ScreenGui')
local Button = Instance.new('ImageButton')
local Corner = Instance.new('UICorner')
local Scale = Instance.new('UIScale')
local Stroke = Instance.new("UIStroke")
local Gradient = Instance.new("UIGradient")

Vora.Name = 'BilqisImup'
Vora.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Vora.ResetOnSpawn = false
Vora.Parent = game:GetService('CoreGui')

Button.Name = 'BilqisGemoy'
Button.Parent = Vora
Button.BackgroundTransparency = 0
Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Button.Size = UDim2.new(0, 40, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 50)
Button.Image = 'rbxassetid://129615590266896'
Button.Draggable = true

Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Button
Scale.Scale = 1
Scale.Parent = Button

local TweenService = game:GetService("TweenService")
Button.MouseEnter:Connect(function()
    TweenService:Create(Scale, TweenInfo.new(0.1), { Scale = 1.2 }):Play()
end)
Button.MouseLeave:Connect(function()
    TweenService:Create(Scale, TweenInfo.new(0.1), { Scale = 1 }):Play()
end)

Stroke.Thickness = 3
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.LineJoinMode = Enum.LineJoinMode.Round
Stroke.Color = Color3.fromRGB(173, 216, 230)
Stroke.Parent = Button

Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(173, 216, 230)),
    ColorSequenceKeypoint.new(0.15, Color3.fromRGB(173, 216, 230)),
    ColorSequenceKeypoint.new(0.30, Color3.fromRGB(173, 216, 230)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(173, 216, 230)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(173, 216, 230)),
    ColorSequenceKeypoint.new(0.85, Color3.fromRGB(173, 216, 230)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(173, 216, 230))
})

Gradient.Rotation = 0
Gradient.Parent = Stroke

local isWindowOpen = true
Button.MouseButton1Click:Connect(function()
    if isWindowOpen then
        Window:Close()
    else
        Window:Open()
    end
    isWindowOpen = not isWindowOpen
end)

Window:OnDestroy(function()
    if Vora then
        Vora:Destroy()
    end
end)

WindUI:Notify({
    Title = "VORA HUB Loaded",
    Content = "UI loaded successfully!",
    Duration = 3,
    Icon = "bell",
})

local Info = Window:Tab({
    Title = "Info",
    Icon = "info",
})

Info:Section({
    Title = "Community Support",
    TextXAlignment = "Left",
    TextSize = 17,
})

Info:Button({
    Title = "Discord",
    Desc = "click to copy link",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/vorahub")
            WindUI:Notify({Title = "Discord", Content = "Link Copied To Clipboard", Duration = 3}) 
        end
    end
})


Info:Section({
    Title = "Every time there is a game update or someone reports something, I will fix it as soon as possible.",
    TextXAlignment = "Left",
    TextSize = 17,
})

getgenv().host = game:GetService("Players").LocalPlayer

local function applyZoom()
    host.CameraMaxZoomDistance = math.huge
    host.CameraMinZoomDistance = 0.1
end

applyZoom()

host.CharacterAdded:Connect(function()
    task.wait(0.1)
    applyZoom()
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local Replion = require(ReplicatedStorage.Packages.Replion)
local FishingController = require(ReplicatedStorage.Controllers.FishingController)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local VendorUtility = require(ReplicatedStorage.Shared.VendorUtility)
local Data = Replion.Client:WaitReplion("Data")
local Items = ReplicatedStorage:WaitForChild("Items")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local NetService = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local sellAllItems = NetService:WaitForChild("RF/SellAllItems")
local enchan = NetService:WaitForChild("RE/ActivateEnchantingAltar")
local oxygenRemote = NetService:WaitForChild("URE/UpdateOxygen")
local radar = NetService:WaitForChild("RF/UpdateFishingRadar")
local autoon = NetService:WaitForChild("RF/UpdateAutoFishingState")
local equipTool = NetService:WaitForChild("RE/EquipToolFromHotbar")
local CoreGui = game:GetService("CoreGui")
local tradeFunc = Net["RF/InitiateTrade"]
local RETextNotification = Net["RE/TextNotification"]
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local TradingController = require(ReplicatedStorage.Controllers.ItemTradingController)

local RE = {
    FavoriteItem = Net:FindFirstChild("RE/FavoriteItem"),
    FavoriteStateChanged = Net:FindFirstChild("RE/FavoriteStateChanged"),
    FishingCompleted = Net:FindFirstChild("RE/FishingCompleted"),
    FishCaught = Net:FindFirstChild("RE/FishCaught"),
    EquipItem = Net:FindFirstChild("RE/EquipItem"),
    ActivateAltar = Net:FindFirstChild("RE/ActivateEnchantingAltar"),
    EquipTool = Net:FindFirstChild("RE/EquipToolFromHotbar"),
}

local equipItemRemote = RE.EquipItem or Net:FindFirstChild("RE/EquipItem")
local equipToolRemote = RE.EquipTool or Net:FindFirstChild("RE/EquipToolFromHotbar")
local activateAltarRemote = RE.ActivateAltar or Net:FindFirstChild("RE/ActivateEnchantingAltar")

local st = {
    canFish = true,
}

local blockedFunctions = {
    "OnCooldown",
}

local function patchFishingController()
    local fishingModule = ReplicatedStorage.Controllers:FindFirstChild("FishingController")
    if not fishingModule then return end

    local ok, FC = pcall(require, fishingModule)
    if not ok or type(FC) ~= "table" then return end

    for key, fn in pairs(FC) do
        if type(fn) == "function" and table.find(blockedFunctions, key) then
            FC[key] = function(...)
                return false
            end
        end
    end

end

patchFishingController()
------------------ Variable ------------------------
_G.AutoFarm = false
_G.AutoRod = false
_G.AutoSells = false
_G.InfiniteJump = false
_G.Radar = false
_G.AntiAFK = false
_G.AutoReconnect = false
autoFavEnabled = false

------------------ Fishing logic -------------------]

local function instant()
    NetService:WaitForChild("RF/ChargeFishingRod"):InvokeServer(1)
    task.wait(0.2)
    NetService:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(1, 0.921, 17819.019)
    task.wait(delayfishing)
    NetService:WaitForChild("RE/FishingCompleted"):FireServer(1)
end

------------------- Main Tab -----------------------
local Exclusive = Window:Tab({
    Title = "Exclusive",
    Icon = "star",
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "landmark"
})

local MainSection = MainTab:Section({
    Title = "Main",
    TextXAlignment = "Left",
    TextSize = 17,
})

local AutoRod = MainTab:Toggle({
    Title = "Auto Rod",
    Desc = false,
    Icon = false,
    Type = "Toggle",
    Value = false,
    Callback = function(Value) 
        _G.AutoRod = Value
        if Value then
            equipTool:FireServer(1)
        else return end
    end
})

local CurrentOption = "Instant"

local Dropdown = MainTab:Dropdown({
    Title = "Mode",
    Desc = false,
    Values = { "Instant", "Legit" },
    Value = "Instant",
    Multi = false,
    AllowNone = false,
    Callback = function(Option)
        CurrentOption = Option
    end
})

local AutoFarm = MainTab:Toggle({
    Title = "Auto Farm",
    Desc = false,
    Icon = false,
    Type = "Toggle",
    Value = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            if CurrentOption == "Instant" then
                WindUI:Notify({
                    Title = "AutoFarm",
                    Content = "Instant Mode ON",
                    Duration = 3
                })
                task.spawn(function()
                    while _G.AutoFarm and CurrentOption == "Instant" do
                        pcall(instant)
                        task.wait(0.1)
                    end
                end)
            elseif CurrentOption == "Legit" then
                WindUI:Notify({
                    Title = "AutoFarm",
                    Content = "Legit Mode ON",
                    Duration = 3
                })
                task.spawn(function()
                    while _G.AutoFarm and CurrentOption == "Legit" do
                        pcall(function()
                            FishingController:RequestChargeFishingRod(Vector2.new(0, 0), true)
                            local guid = FishingController.GetCurrentGUID and FishingController:GetCurrentGUID()
                            if guid then
                                while _G.AutoFarm
                                and CurrentOption == "Legit"
                                and guid == FishingController:GetCurrentGUID() do
                                    FishingController:FishingMinigameClick()
                                    task.wait(math.random(0, 3) / 100)
                                end
                            end
                        end)
                        task.wait(0.25)
                    end
                end)
            end

        -- ======================= WHEN AUTOFARM TURNS OFF =======================
        else
            WindUI:Notify({
                Title = "AutoFarm",
                Content = "AutoFarm OFF",
                Duration = 3
            })

            _G.AutoFarm = false
            pcall(autooff)
            pcall(cancel)
        end
    end
})

MainTab:Input({ 
    Title = "Fishing Delay",
    Placeholder = "Contoh: 1.0",
    Default = 1.0,
    Callback = function(value)
        delayfishing = value
    end
})

MainTab:Section({
    Title = "Sell",
    Icon = "hand-coins",
    TextXAlignment = "Left",
    TextSize = 17,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.AutoSells = false

local selldelay = 0
local countdelay = 0
local currentCount = 0

local label = LocalPlayer.PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize

label:GetPropertyChangedSignal("ContentText"):Connect(function()
    local text = label.ContentText
    currentCount = tonumber(string.match(text, "^(%d+)")) or 0
end)

local sellAllItems = NetService:WaitForChild("RF/SellAllItems")

local function SafeSell()
    pcall(function()
        sellAllItems:InvokeServer()
    end)
end

local function AutoSellLoop()
    while _G.AutoSells do

        if selldelay == 0 and countdelay > 0 then
            if currentCount >= countdelay then
                SafeSell()
                task.wait(0.3)
            end
            task.wait(0.1)

        elseif selldelay > 0 and countdelay == 0 then
            SafeSell()
            task.wait(selldelay)

        else
            WindUI:Notify({
                Title = "Yang Bener Hitam",
                Content = "ISI SATU AJA (Sell Delay Atau Sell By Count).",
                Duration = 3,
                Icon = "warn",
            })
            break
        end
    end
end

local function StartAutoSell()
    if _G.AutoSells then return end
    _G.AutoSells = true
    task.spawn(AutoSellLoop)
end

local function StopAutoSell()
    _G.AutoSells = false
end

MainTab:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(v)
        if v then
            StartAutoSell()
        else
            StopAutoSell()
        end
    end
})

MainTab:Input({
    Title = "Sell Delay",
    Placeholder = "Contoh: 10",
    Default = 0,
    Callback = function(txt)
        selldelay = tonumber(txt) or 0
        print("Sell delay set ke:", selldelay)
    end
})

MainTab:Input({
    Title = "Sell By Count",
    Placeholder = "Contoh: 100",
    Default = 0,
    Callback = function(txt)
        countdelay = tonumber(txt) or 0
        print("Sell count set ke:", countdelay)
    end
})

MainTab:Section({
    Title = "Auto Favorite",
    Icon = "star",
    TextXAlignment = "Left",
    TextSize = 17,
})

local REFishCaught = RE.FishCaught or Net:WaitForChild("RE/FishCaught")
local REFishingCompleted = RE.FishingCompleted or Net:WaitForChild("RE/FishingCompleted")

if REFishCaught then
    REFishCaught.OnClientEvent:Connect(function()
        st.canFish = true
    end)
end

if REFishingCompleted then
    REFishingCompleted.OnClientEvent:Connect(function()
        st.canFish = true
    end)
end

tierToRarity = {
    [1] = "Uncommon",
    [2] = "Common",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret"
}

fishNames = {}
for _, module in ipairs(Items:GetChildren()) do
    if module:IsA("ModuleScript") then
        local ok, data = pcall(require, module)
        if ok and data.Data and data.Data.Type == "Fish" then
            table.insert(fishNames, data.Data.Name)
        end
    end
end
table.sort(fishNames)

local favState, selectedName, selectedRarity = {}, {}, {}

if RE.FavoriteStateChanged then
    RE.FavoriteStateChanged.OnClientEvent:Connect(function(uuid, fav)
        if uuid then favState[uuid] = fav end
    end)
end

local function checkAndFavorite(item)
    if not st.autoFavEnabled then return end
    local info = ItemUtility.GetItemDataFromItemType("Items", item.Id)
    if not info or info.Data.Type ~= "Fish" then return end

    local rarity = tierToRarity[info.Data.Tier]
    local nameMatches = table.find(selectedName, info.Data.Name)
    local rarityMatches = table.find(selectedRarity, rarity)
    local isFav = favState[item.UUID] or item.Favorited or false
    local shouldFav = (nameMatches or rarityMatches) and not isFav

    if shouldFav and RE.FavoriteItem then
        RE.FavoriteItem:FireServer(item.UUID, true)
        favState[item.UUID] = true
    end
end

local function scanInventory()
    if not st.autoFavEnabled then return end
    local inv = Data:GetExpect({ "Inventory", "Items" })
    if not inv then return end
    for _, item in ipairs(inv) do checkAndFavorite(item) end
end

Data:OnChange({ "Inventory", "Items" }, function()
    if st.autoFavEnabled then scanInventory() end
end)

function getPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

MainTab:Dropdown({
    Title = "Favorite by Name",
    Values = #fishNames > 0 and fishNames or { "No Data" },
    Multi = true,
    SearchBarEnabled = true,
    AllowNone = true,
    Default = {},
    Callback = function(opts)
        selectedName = opts or {}
        if st.autoFavEnabled then scanInventory() end
    end
})

MainTab:Dropdown({
    Title = "Favorite by Rarity",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    Multi = true,
    SearchBarEnabled = true,
    AllowNone = true,
    Default = {},
    Callback = function(opts)
        selectedRarity = opts or {}
        if st.autoFavEnabled then scanInventory() end
    end
})

MainTab:Toggle({
    Title = "Start Auto Favorite",
    Default = false,
    Callback = function(state)
        st.autoFavEnabled = state
        if st.autoFavEnabled then scanInventory() end
    end
})

MainTab:Button({
    Title = "Unfavorite All",
    Callback = function()
        local inv = Data:GetExpect({ "Inventory", "Items" })
        if not inv then return end
        for _, item in ipairs(inv) do
            if (item.Favorited or favState[item.UUID]) and RE.FavoriteItem then
                RE.FavoriteItem:FireServer(item.UUID, false)
                favState[item.UUID] = false
            end
        end
    end
})

local AutoTab = Window:Tab({
    Title = "Auto",
    Icon = "cpu"
})

AutoTab:Section({
    Title = "Auto Trade",
    Icon = "hand",
    TextXAlignment = "Left",
    TextSize = 17,
})

local TradeState         = {
    selectedPlayer = nil,
    selectedItem   = nil,
    tradeAmount    = 1,
    trading        = false,
    successCount   = 0,
    totalToTrade   = 0,
    awaiting       = false,
    currentGrouped = {},
    lastResult     = nil
}


function getGroupedByType(typeName)
    local items = Data:GetExpect({ "Inventory", "Items" })
    local grouped, values = {}, {}
    for _, item in ipairs(items) do
        local info = ItemUtility.GetItemDataFromItemType("Items", item.Id)
        if info and info.Data.Type == typeName then
            local name = info.Data.Name
            grouped[name] = grouped[name] or { count = 0, uuids = {} }
            grouped[name].count += (item.Quantity or 1)
            table.insert(grouped[name].uuids, item.UUID)
        end
    end
    for name, data in pairs(grouped) do
        table.insert(values, ("%s | Total %dx"):format(name, data.count))
    end
    return grouped, values
end

local tradeParagraph = AutoTab:Paragraph({
    Title = "Trade Status",
    Desc = "<font color='#999999'>Progress : Idle</font>",
    RichText = true
})

local function setStatus(text)
    if not text then
        text = "<font color='#999999'>Progress : Idle</font>"
    end
    tradeParagraph:SetDesc(text)
end

AutoTab:Dropdown({
    Title = "Select Item",
    Values = { "None" },
    Multi = false,
    Value = "None",
    Callback = function(value)
        if not value or value == "None" then
            TradeState.selectedItem = nil
        else
            TradeState.selectedItem = value:match("^(.-) %|") or value
        end
        setStatus(nil)
    end
})

AutoTab:Input({
    Title = "Amount to Trade",
    Placeholder = "Enter Number",
    Default = "1",
    Callback = function(value)
        TradeState.tradeAmount = tonumber(value) or 1
        setStatus(nil)
    end
})

AutoTab:Button({
    Title = "Refresh Fish",
    Callback = function()
        TradeState.currentGrouped, values = getGroupedByType("Fish")
        itemDropdown:Refresh(values)
    end
})

AutoTab:Button({
    Title = "Refresh Stone",
    Callback = function()
        TradeState.currentGrouped, values = getGroupedByType("Enchant Stones")
        itemDropdown:Refresh(values)
    end
})

local playerList = {}

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        table.insert(playerList, plr.Name)
    end
end

if #playerList == 0 then
    table.insert(playerList, "None")
end

AutoTab:Dropdown({
    Title = "Select Player",
    Values = playerList,
    Value = playerList[1] or "None",
    Multi = false,
    Callback = function(value)
        if value == "None" then
            TradeState.selectedPlayer = nil
        else
            TradeState.selectedPlayer = value
        end
        setStatus(nil)
    end
})

AutoTab:Button({
    Title = "Refresh Player",
    Callback = function()
        local names = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                table.insert(names, plr.Name)
            end
        end
        playerDropdown:Refresh(names)
    end
})

RETextNotification.OnClientEvent:Connect(function(data)
    if not TradeState.trading then return end
    if not data or not data.Text then return end
    local msg = data.Text

    if msg:find("Trade completed") then
        TradeState.awaiting = false
        TradeState.lastResult = "completed"
        setStatus("<font color='#00cc66'>Progress : Trade success</font>")
    elseif msg:find("Sent trade request") then
        setStatus("<font color='#daa520'>Progress : Waiting player...</font>")
    end
end)

TradingController.CompletedTrade = function()
    if TradeState.trading then
        TradeState.awaiting = false
        TradeState.lastResult = "completed"
    end
end
TradingController.OnTradeCancelled = function()
    if TradeState.trading then
        TradeState.awaiting = false
        TradeState.lastResult = "declined"
    end
end

function sendTrade(target, uuid, itemName)
    while TradeState.trading do
        TradeState.awaiting = true
        TradeState.lastResult = nil
        setStatus("<font color='#3399ff'>Sending " .. (itemName or "Item") .. "...</font>")

        pcall(function()
            tradeFunc:InvokeServer(target.UserId, uuid)
        end)

        local startTime = tick()
        while TradeState.trading and TradeState.awaiting do
            task.wait()
            if tick() - startTime > 6 then
                TradeState.awaiting = false
                TradeState.lastResult = "timeout"
                break
            end
        end

        if TradeState.lastResult == "completed" then
            TradeState.successCount += 1
            setStatus("<font color='#00cc66'>Success : " .. (itemName or "Item") .. "</font>")
            return true
        elseif TradeState.lastResult == "declined" or TradeState.lastResult == "timeout" then
            setStatus("<font color='#999999'>Skipped " .. (itemName or "Item") .. "</font>")
            return false
        else
            setStatus("<font color='#ffaa00'>Retrying " .. (itemName or "Item") .. "...</font>")
            task.wait(0.5)
        end
    end
    return false
end

function startTrade()
    if TradeState.trading then return end
    if not TradeState.selectedPlayer or not TradeState.selectedItem then
        return warn("Not Completed")
    end

    TradeState.trading = true
    TradeState.successCount = 0

    local itemData = TradeState.currentGrouped[TradeState.selectedItem]
    if not itemData then
        setStatus("<font color='#ff3333'>Item not found</font>")
        TradeState.trading = false
        return
    end

    local target = Players:FindFirstChild(TradeState.selectedPlayer)
    if not target then
        setStatus("<font color='#ff3333'>Player not found</font>")
        TradeState.trading = false
        return
    end

    local uuids = itemData.uuids
    TradeState.totalToTrade = math.min(TradeState.tradeAmount, #uuids)

    local i = 1
    while TradeState.trading and TradeState.successCount < TradeState.totalToTrade do
        local uuid = uuids[i]
        if not uuid then break end

        local ok = sendTrade(target, uuid, TradeState.selectedItem)

        -- naik item kalau sukses atau skip
        if ok or TradeState.lastResult == "declined" or TradeState.lastResult == "timeout" then
            i += 1
        end
    end

    TradeState.trading = false
    setStatus(string.format(
        "<font color='#66ccff'>Progress : All trades finished! (%d/%d)</font>",
        TradeState.successCount,
        TradeState.totalToTrade
    ))

    tradeParagraph.Desc = [[
<font color="rgb(255,105,180)">🌌 </font>
<font color="rgb(135,206,250)">VORAHUB TRADING COMPLETE!</font>
<font color="rgb(255,105,180)"> 🌌</font>
]]
end


AutoTab:Toggle({
    Title = "Auto Trade",
    Default = false,
    Callback = function(state)
        if state then
            spawn(startTrade)
        else
            TradeState.trading = false
            TradeState.awaiting = false
            setStatus("<font color='#999999'>Progress : Idle</font>")
        end
    end
})

AutoTab:Section({
    Title = "Auto Accept Trade",
    Icon = "hand",
    TextXAlignment = "Left",
    TextSize = 17,
})

AutoTab:Toggle({
    Title = "Auto Accept Trade",
    Value = _G.AutoAccept,
    Callback = function(value)
        _G.AutoAccept = value
    end
})

spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoAccept then
            pcall(function()
                local promptGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Prompt")
                if promptGui and promptGui:FindFirstChild("Blackout") then
                    local blackout = promptGui.Blackout
                    if blackout:FindFirstChild("Options") then
                        local options = blackout.Options
                        local yesButton = options:FindFirstChild("Yes")                    
                        if yesButton then
                            local vr = game:GetService("VirtualInputManager") 
                            local absPos = yesButton.AbsolutePosition
                            local absSize = yesButton.AbsoluteSize                          
                            local clickX = absPos.X + (absSize.X / 2)
                            local clickY = absPos.Y + (absSize.Y / 2) + 50 
                            vr:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                            task.wait(0.03)
                            vr:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)  
                        end
                    end
                end
            end)
        end
    end
end)

if getconnections then
    for _, conn in ipairs(getconnections(RETextNotification.OnClientEvent)) do
        if typeof(conn.Function) == "function" then
            local oldFn = conn.Function
            conn:Disable()
            RETextNotification.OnClientEvent:Connect(function(data)
                if data and data.Text then
                    if data.Text ~= "Sending trades too fast!"
                        and data.Text ~= "One or more people are already in a trade!"
                        and data.Text ~= "Trade was declined" then
                        oldFn(data)
                    end
                end
            end)
        end
    end
end

AutoTab:Section({
    Title = "Enchant Features",
    TextXAlignment = "Left",
    TextSize = 17,
})

function gStone()
    local it = Data:GetExpect({ "Inventory", "Items" })
    local t = 0
    for _, v in ipairs(it) do
        local i = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if i and i.Data.Type == "Enchant Stones" then t += v.Quantity or 1 end
    end
    return t
end

local enchantNames = {
    "Big Hunter 1", "Cursed 1", "Empowered 1", "Glistening 1",
    "Gold Digger 1", "Leprechaun 1", "Leprechaun 2",
    "Mutation Hunter 1", "Mutation Hunter 2", "Prismatic 1",
    "Reeler 1", "Stargazer 1", "Stormhunter 1", "XPerienced 1"
}

local enchantIdMap = {
    ["Big Hunter 1"] = 3, ["Cursed 1"] = 12, ["Empowered 1"] = 9,
    ["Glistening 1"] = 1, ["Gold Digger 1"] = 4, ["Leprechaun 1"] = 5,
    ["Leprechaun 2"] = 6, ["Mutation Hunter 1"] = 7, ["Mutation Hunter 2"] = 14,
    ["Prismatic 1"] = 13, ["Reeler 1"] = 2, ["Stargazer 1"] = 8,
    ["Stormhunter 1"] = 11, ["XPerienced 1"] = 10
}

function countDisplayImageButtons()
    local success, backpackGui = pcall(function() return LocalPlayer.PlayerGui.Backpack end)
    if not success or not backpackGui then return 0 end
    local display = backpackGui:FindFirstChild("Display")
    if not display then return 0 end
    local imageButtonCount = 0
    for _, child in ipairs(display:GetChildren()) do
        if child:IsA("ImageButton") then
            imageButtonCount += 1
        end
    end
    return imageButtonCount
end

function findEnchantStones()
    if not Data then return {} end
    local inventory = Data:GetExpect({ "Inventory", "Items" })
    if not inventory then return {} end
    local stones = {}
    for _, item in pairs(inventory) do
        local def = ItemUtility:GetItemData(item.Id)
        if def and def.Data and def.Data.Type == "Enchant Stones" then
            table.insert(stones, { UUID = item.UUID, Quantity = item.Quantity or 1 })
        end
    end
    return stones
end

function getEquippedRodName()
    local equipped = Data:Get("EquippedItems") or {}
    local rods = Data:GetExpect({ "Inventory", "Fishing Rods" }) or {}
    for _, uuid in pairs(equipped) do
        for _, rod in ipairs(rods) do
            if rod.UUID == uuid then
                local itemData = ItemUtility:GetItemData(rod.Id)
                if itemData and itemData.Data and itemData.Data.Name then
                    return itemData.Data.Name
                elseif rod.ItemName then
                    return rod.ItemName
                end
            end
        end
    end
    return "None"
end

function getCurrentRodEnchant()
    if not Data then return nil end
    local equipped = Data:Get("EquippedItems") or {}
    local rods = Data:GetExpect({ "Inventory", "Fishing Rods" }) or {}
    for _, uuid in pairs(equipped) do
        for _, rod in ipairs(rods) do
            if rod.UUID == uuid and rod.Metadata and rod.Metadata.EnchantId then
                return rod.Metadata.EnchantId
            end
        end
    end
    return nil
end

local Paragraph = AutoTab:Paragraph({
    Title = "Enchanting Features",
    Desc = "Loading...",
    RichText = true
})

spawn(LPH_NO_VIRTUALIZE(function()
    while task.wait(1) do
        local stones = findEnchantStones()
        local totalStones = 0
        for _, s in ipairs(stones) do
            totalStones += s.Quantity or 0
        end
        local rodName = getEquippedRodName()
        local currentEnchantId = getCurrentRodEnchant()
        local currentEnchantName = "None"
        if currentEnchantId then
            for name, id in pairs(enchantIdMap) do
                if id == currentEnchantId then
                    currentEnchantName = name
                    break
                end
            end
        end
        local desc =
            "Rod Active <font color='rgb(0,191,255)'>= " .. rodName .. "</font>\n" ..
            "Enchant Now <font color='rgb(200,0,255)'>= " .. currentEnchantName .. "</font>\n" ..
            "Enchant Stone Left <font color='rgb(255,215,0)'>= " .. totalStones .. "</font>"
        Paragraph:SetDesc(desc)
    end
end))

AutoTab:Button({
    Title = "Teleport to Altar",
    Callback = function()
        local targetCFrame = CFrame.new(3234.83667, -1302.85486, 1398.39087, 0.464485794, -1.12043161e-07, -0.885580599, 6.74793981e-08, 1, -9.11265872e-08, 0.885580599, -1.74314394e-08, 0.464485794)
        local character = LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = targetCFrame
            end
        end
    end
})

AutoTab:Button({
    Title = "Teleport to Second Altar",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local targetCFrame = CFrame.new(1481, 128, -592)
            character:PivotTo(targetCFrame)
        end
    end
})

AutoTab:Dropdown({
    Title = "Target Enchant",
    Values = enchantNames,
    Value = _G.TargetEnchant or enchantNames[1],
    Callback = function(selected)
        _G.TargetEnchant = selected
    end
})

AutoTab:Toggle({
    Title = "Auto Enchant",
    Value = _G.AutoEnchant,
    Callback = function(value)
        _G.AutoEnchant = value
    end
})

function getData(stoneId)
    local rod, ench, stones, uuids = "None", "None", 0, {}
    local equipped = Data:Get("EquippedItems") or {}
    local rods = Data:Get({ "Inventory", "Fishing Rods" }) or {}

    for _, u in pairs(equipped) do
        for _, r in ipairs(rods) do
            if r.UUID == u then
                local d = ItemUtility:GetItemData(r.Id)
                rod = (d and d.Data.Name) or r.ItemName or "None"
                if r.Metadata and r.Metadata.EnchantId then
                    local e = ItemUtility:GetEnchantData(r.Metadata.EnchantId)
                    ench = (e and e.Data.Name) or "None"
                end
            end
        end
    end

    for _, it in pairs(Data:GetExpect({ "Inventory", "Items" })) do
        local d = ItemUtility:GetItemData(it.Id)
        if d and d.Data.Type == "Enchant Stones" and it.Id == stoneId then
            stones += 1
            table.insert(uuids, it.UUID)
        end
    end
    return rod, ench, stones, uuids
end

AutoTab:Button({
    Title = "Start Double Enchant",
    Callback = function()
        task.spawn(function()
            local rod, ench, s, uuids = getData(246)
            if rod == "None" or s <= 0 then return end

            local slot, start = nil, tick()
            while tick() - start < 5 do
                for sl, id in pairs(Data:Get("EquippedItems") or {}) do
                    if id == uuids[1] then slot = sl end
                end
                if slot then break end
                equipItemRemote:FireServer(uuids[1], "EnchantStones")
                task.wait(0.3)
            end
            if not slot then return end

            equipToolRemote:FireServer(slot)
            task.wait(0.2)
            activateAltarRemote2:FireServer()
        end)
    end
})

spawn( LPH_NO_VIRTUALIZE( function()
    while task.wait() do
        if _G.AutoEnchant then
            local currentEnchantId = getCurrentRodEnchant()
            local targetEnchantId = enchantIdMap[_G.TargetEnchant]

            if currentEnchantId == targetEnchantId then
                _G.AutoEnchant = false
                break
            end

            local enchantStones = findEnchantStones()
            if #enchantStones > 0 then
                local enchantStone = enchantStones[1]
                local args = { enchantStone.UUID, "Enchant Stones" }
                pcall(function()
                    equipItemRemote:FireServer(unpack(args))
                end)

                task.wait(1)

                local imageButtonCount = countDisplayImageButtons()
                local slotNumber = imageButtonCount - 2
                if slotNumber < 1 then slotNumber = 1 end

                pcall(function()
                    equipToolRemote:FireServer(slotNumber)
                end)

                task.wait(1)

                pcall(function()
                    activateAltarRemote:FireServer()
                end)
            end

            task.wait(5)
        end
    end
end))

------------------ Player Tab ------------------
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user"
})

PlayerTab:Input({ 
    Title = "Walk Speed",
    Placeholder = "Contoh: 18",
    Default = "18",
    Callback = function(value)
        local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = tonumber(value) or 18
        end
    end
})

PlayerTab:Input({ 
    Title = "Jump Power",
    Placeholder = "Contoh: 50",
    Default = "50",
    Callback = function(value)
        local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = tonumber(value) or 50
        end
    end
})

local UserInputService = game:GetService("UserInputService")

local InfiniteJump = PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = false,
    Icon = false,
    Type = "Toggle",
    Value = false,
    Callback = function(Value)
        _G.InfiniteJump = Value
        if Value then
            print("✅ Infinite Jump Active")
            InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if _G.InfiniteJump then
                    local character = Player.Character or Player.CharacterAdded:Wait()
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            print("❌ Infinite Jump Inactive")
            end
        end
})

PlayerTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        task.spawn(function()
            local Player = game:GetService("Players").LocalPlayer
            while _G.Noclip do
                task.wait(0.1)
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide == true then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
})

PlayerTab:Toggle({
    Title = "Radar",
    Default = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        local Replion = require(ReplicatedStorage.Packages.Replion).Client:GetReplion("Data")
        local NetFunction = require(ReplicatedStorage.Packages.Net):RemoteFunction("UpdateFishingRadar")

        if Replion and NetFunction:InvokeServer(state) then
            local sound = require(ReplicatedStorage.Shared.Soundbook).Sounds.RadarToggle:Play()
            sound.PlaybackSpeed = 1 + math.random() * 0.3

            local c = Lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")
            if c then
                require(ReplicatedStorage.Packages.spr).stop(c)

                local time = require(ReplicatedStorage.Controllers.ClientTimeController)
                local profile = time._getLightingProfile and time:_getLightingProfile() or {}
                local correction = profile.ColorCorrection or {}
                correction.Brightness = correction.Brightness or 0.04
                correction.TintColor = correction.TintColor or Color3.fromRGB(255,255,255)

                if state then
                    c.TintColor = Color3.fromRGB(42, 226, 118)
                    c.Brightness = 0.4
                else
                    c.TintColor = Color3.fromRGB(255, 0, 0)
                    c.Brightness = 0.2
                end

                require(ReplicatedStorage.Packages.spr).target(c, 1, 1, correction)
            end

            require(ReplicatedStorage.Packages.spr).stop(Lighting)
            Lighting.ExposureCompensation = 1
            require(ReplicatedStorage.Packages.spr).target(Lighting, 1, 2, {ExposureCompensation = 0})
        end
    end
})

PlayerTab:Toggle({
    Title = "Diving Gear",
    Default = false,
    Callback = function(state)
        _G.DivingGear = state
        local RemoteFolder = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        if state then
            RemoteFolder["RF/EquipOxygenTank"]:InvokeServer(105)
        else
            RemoteFolder["RF/UnequipOxygenTank"]:InvokeServer()
        end
    end
})

local FlyGui = PlayerTab:Button({
    Title = "FlyGui V3",
    Desc = false,
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        Notify("Fly GUI Activated")
    end
})

local Shop = Window:Tab({
    Title = "Shop",
    Icon = "badge-dollar-sign",
})

Shop:Section({   
    Title = "Buy Rod",  
    TextXAlignment = "Left",  
    TextSize = 17,  
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local RFPurchaseFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]  

local rods = {  
    ["Luck Rod"] = 79,  
    ["Carbon Rod"] = 76,  
    ["Grass Rod"] = 85,
    ["Demascus Rod"] = 77,  
    ["Ice Rod"] = 78,  
    ["Lucky Rod"] = 4,  
    ["Midnight Rod"] = 80,  
    ["Steampunk Rod"] = 6,  
    ["Chrome Rod"] = 7,  
    ["Astral Rod"] = 5,  
    ["Ares Rod"] = 126,  
    ["Angler Rod"] = 168,
    ["Bamboo Rod"] = 258
}  

local rodNames = {  
    "Luck Rod (350 Coins)", "Carbon Rod (900 Coins)", "Grass Rod (1.5k Coins)", "Demascus Rod (3k Coins)",  
    "Ice Rod (5k Coins)", "Lucky Rod (15k Coins)", "Midnight Rod (50k Coins)", "Steampunk Rod (215k Coins)",  
    "Chrome Rod (437k Coins)", "Astral Rod (1M Coins)", "Ares Rod (3M Coins)", "Angler Rod (8M Coins)",
    "Bamboo Rod (12M Coins)"
}  

local rodKeyMap = {  
    ["Luck Rod (350 Coins)"]="Luck Rod",  
    ["Carbon Rod (900 Coins)"]="Carbon Rod",  
    ["Grass Rod (1.5k Coins)"]="Grass Rod",  
    ["Demascus Rod (3k Coins)"]="Demascus Rod",  
    ["Ice Rod (5k Coins)"]="Ice Rod",  
    ["Lucky Rod (15k Coins)"]="Lucky Rod",  
    ["Midnight Rod (50k Coins)"]="Midnight Rod",  
    ["Steampunk Rod (215k Coins)"]="Steampunk Rod",  
    ["Chrome Rod (437k Coins)"]="Chrome Rod",  
    ["Astral Rod (1M Coins)"]="Astral Rod",  
    ["Ares Rod (3M Coins)"]="Ares Rod",  
    ["Angler Rod (8M Coins)"]="Angler Rod",
    ["Bamboo Rod (12M Coins)"]="Bamboo Rod"
}  

local selectedRod = rodNames[1]  

Shop:Dropdown({  
    Title = "Select Rod",  
    Values = rodNames,  
    Value = selectedRod,  
    Callback = function(value)  
        selectedRod = value  
    end  
})  

Shop:Button({  
    Title="Buy Rod",  
    Callback=function()  
        local key = rodKeyMap[selectedRod]  
        if key and rods[key] then  
            local success, err = pcall(function()  
                RFPurchaseFishingRod:InvokeServer(rods[key])  
            end)  
            if success then  
                WindUI:Notify({Title="Rod Purchase", Content="Purchased "..selectedRod, Duration=3})  
            else  
                WindUI:Notify({Title="Rod Purchase Error", Content=tostring(err), Duration=5})  
            end  
        end  
    end  
})

local Section = Shop:Section({
    Title = "Buy Baits",
    TextXAlignment = "Left",
    TextSize = 17,
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local RFPurchaseBait = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]  

local baits = {
    ["TopWater Bait"] = 10,
    ["Lucky Bait"] = 2,
    ["Midnight Bait"] = 3,
    ["Chroma Bait"] = 6,
    ["Dark Mater Bait"] = 8,
    ["Corrupt Bait"] = 15,
    ["Aether Bait"] = 16
}

local baitNames = {
    "TopWater Bait (100 Coins)",
    "Lucky Bait (1k Coins)",
    "Midnight Bait (3k Coins)",
    "Chroma Bait (290k Coins)",
    "Dark Mater Bait (630k Coins)",
    "Corrupt Bait (1.15M Coins)",
    "Aether Bait (3.7M Coins)"
}

local baitKeyMap = {
    ["TopWater Bait (100 Coins)"] = "TopWater Bait",
    ["Lucky Bait (1k Coins)"] = "Lucky Bait",
    ["Midnight Bait (3k Coins)"] = "Midnight Bait",
    ["Chroma Bait (290k Coins)"] = "Chroma Bait",
    ["Dark Mater Bait (630k Coins)"] = "Dark Mater Bait",
    ["Corrupt Bait (1.15M Coins)"] = "Corrupt Bait",
    ["Aether Bait (3.7M Coins)"] = "Aether Bait"
}

local selectedBait = baitNames[1]  

Shop:Dropdown({  
    Title = "Select Bait",  
    Values = baitNames,  
    Value = selectedBait,  
    Callback = function(value)  
        selectedBait = value  
    end  
})  

Shop:Button({  
    Title = "Buy Bait",  
    Callback = function()  
        local key = baitKeyMap[selectedBait]  
        if key and baits[key] then  
            local success, err = pcall(function()  
                RFPurchaseBait:InvokeServer(baits[key])  
            end)  
            if success then  
                WindUI:Notify({Title = "Bait Purchase", Content = "Purchased " .. selectedBait, Duration = 3})  
            else  
                WindUI:Notify({Title = "Bait Purchase Error", Content = tostring(err), Duration = 5})  
            end  
        end  
    end  
})

Shop:Section({
    Title = "Buy Weather Event",
    Icon = "cloud-drizzle",
    TextXAlignment = "Left",
    TextSize = 17,
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RFPurchaseWeatherEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]

-- Data cuaca
local weathers = {
    ["Wind"] = "Wind",
    ["Cloudy"] = "Cloudy",
    ["Snow"] = "Snow",
    ["Storm"] = "Storm",
    ["Radiant"] = "Radiant",
    ["Shark Hunt"] = "Shark Hunt"
}

-- Nama tampilan
local weatherNames = {
    "Windy (10k Coins)",
    "Cloudy (20k Coins)",
    "Snow (15k Coins)",
    "Stormy (35k Coins)",
    "Radiant (50k Coins)",
    "Shark Hunt (300k Coins)"
}

-- Mapping nama → key internal
local weatherKeyMap = {
    ["Windy (10k Coins)"] = "Wind",
    ["Cloudy (20k Coins)"] = "Cloudy",
    ["Snow (15k Coins)"] = "Snow",
    ["Stormy (35k Coins)"] = "Storm",
    ["Radiant (50k Coins)"] = "Radiant",
    ["Shark Hunt (300k Coins)"] = "Shark Hunt"
}

local selectedWeathers = {}
local autoBuyRunning = false

Shop:Dropdown({
    Title = "Select Weather Events",
    Values = weatherNames,
    Value = selectedWeathers,
    Multi = true,
    Callback = function(values)
        selectedWeathers = values
    end
})

-- Toggle untuk mulai beli semua weather terpilih terus-menerus
Shop:Toggle({
    Title = "Auto Buy Selected Weathers",
    Desc = "Continuously purchase all selected weather events while ON",
    Default = false,
    Callback = function(state)
        autoBuyRunning = state

        if state then
            if #selectedWeathers == 0 then
                WindUI:Notify({
                    Title = "⚠️ No Selection",
                    Content = "Please select at least one weather event before enabling.",
                    Duration = 3
                })
                autoBuyRunning = false
                return
            end

            WindUI:Notify({
                Title = "🌤️ Auto Buy Enabled",
                Content = "Auto-purchase started. It will keep buying until turned off.",
                Duration = 3
            })

            -- Jalankan loop di thread terpisah
            task.spawn(function()
                while autoBuyRunning do
                    for _, selected in ipairs(selectedWeathers) do
                        local key = weatherKeyMap[selected]
                        if key and weathers[key] then
                            local success, err = pcall(function()
                                RFPurchaseWeatherEvent:InvokeServer(weathers[key])
                            end)
                        else
                            WindUI:Notify({
                                Title = "⚠️ Invalid Weather",
                                Content = "Invalid selection: " .. tostring(selected),
                                Duration = 3
                            })
                        end
                    end

                    task.wait(2) -- jeda antar siklus beli (atur sesuai kebutuhan)
                end
            end)
        else
            WindUI:Notify({
                Title = "🛑 Auto Buy Disabled",
                Content = "Weather auto-purchase stopped.",
                Duration = 3
            })
        end
    end
})


local Shop = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
})

Shop:Section({ 
    Title = "Island",
    Icon = "tree-palm",
    TextXAlignment = "Left",
    TextSize = 17,
})

local IslandLocations = {
    ["Ancient Ruins"] = Vector3.new(6009, -585, 4691),
    ["Ancient Jungle"] = Vector3.new(1518, 1, -186),
    ["Coral Refs"] = Vector3.new(-2855, 47, 1996),
    ["Crater Island"] = Vector3.new(997, 1, 5012),
    ["Classic Island"] = Vector3.new(1438, 45, 2778),
    ["Enchant Room"] = Vector3.new(3221, -1303, 1406),
    ["Enchant Room 2"] = Vector3.new(1480, 126, -585),
    ["Esoteric Island"] = Vector3.new(1990, 5, 1398),
    ["Fisherman Island"] = Vector3.new(-175, 3, 2772),
    ["Iron Cavern"] = Vector3.new(-8790, -585, 94),
    ["Iron Cafe"] = Vector3.new(-8643, -547, 160),
    ["Kohana Volcano"] = Vector3.new(-545.302429, 17.1266193, 118.870537),
    ["Konoha"] = Vector3.new(-603, 3, 719),
    ["Lost Isle"] = Vector3.new(-3643, 1, -1061),
    ["Sacred Temple"] = Vector3.new(1498, -23, -644),
    ["Sysyphus Statue"] = Vector3.new(-3783.26807, -135.073914, -949.946289),
    ["Treasure Room"] = Vector3.new(-3600, -267, -1575),
    ["Tropical Grove"] = Vector3.new(-2091, 6, 3703),
    ["Weather Machine"] = Vector3.new(-1508, 6, 1895),
}

local SelectedIsland = nil

local IslandDropdown = Shop:Dropdown({
    Title = "Select Island",
    Values = (function()
        local keys = {}
        for name in pairs(IslandLocations) do
            table.insert(keys, name)
        end
        table.sort(keys)
        return keys
    end)(),
    Callback = function(Value)
        SelectedIsland = Value
    end
})

Shop:Button({
    Title = "Teleport to Island",
    Callback = function()
        if SelectedIsland and IslandLocations[SelectedIsland] and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(IslandLocations[SelectedIsland])
        end
    end
})

Shop:Section({ 
    Title = "Tp To Player",
    TextXAlignment = "Left",
    TextSize = 17,
})

local SelectedPlayer = nil

local FishingDropdown = Shop:Dropdown({
    Title = "Select Player",
    Values = (function()
        local players = {}
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Name ~= Player.Name then
                table.insert(players, plr.Name)
            end
        end
        table.sort(players)
        return players
    end)(),
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

local function RefreshPlayerList()
    local list = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr.Name ~= Player.Name then
            table.insert(list, plr.Name)
        end
    end
    table.sort(list)
    FishingDropdown:Refresh(list)
end

game.Players.PlayerAdded:Connect(RefreshPlayerList)
game.Players.PlayerRemoving:Connect(RefreshPlayerList)

Shop:Button({
    Title = "Teleport to Player",
    Callback = function()
        if SelectedPlayer then
            local target = game.Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame =
                        target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
    end
})


local Section = Shop:Section({
    Title = "Location NPC",
    TextXAlignment = "Left",
    TextSize = 17,
})

local NPC_Locations = {
    ["Alex"] = Vector3.new(43,17,2876),
    ["Aura kid"] = Vector3.new(70,17,2835),
    ["Billy Bob"] = Vector3.new(84,17,2876),
    ["Boat Expert"] = Vector3.new(32,9,2789),
    ["Esoteric Gatekeeper"] = Vector3.new(2101,-30,1350),
    ["Jeffery"] = Vector3.new(-2771,4,2132),
    ["Joe"] = Vector3.new(144,20,2856),
    ["Jones"] = Vector3.new(-671,16,596),
    ["Lava Fisherman"] = Vector3.new(-593,59,130),
    ["McBoatson"] = Vector3.new(-623,3,719),
    ["Ram"] = Vector3.new(-2838,47,1962),
    ["Ron"] = Vector3.new(-48,17,2856),
    ["Scott"] = Vector3.new(-19,9,2709),
    ["Scientist"] = Vector3.new(-6,17,2881),
    ["Seth"] = Vector3.new(107,17,2877),
    ["Silly Fisherman"] = Vector3.new(97,9,2694),
    ["Tim"] = Vector3.new(-604,16,609),
}

local SelectedNPC = nil

local NPCDropdown = Shop:Dropdown({
    Title = "Select NPC",
    Values = (function()
        local keys = {}
        for name in pairs(NPC_Locations) do
            table.insert(keys, name)
        end
        table.sort(keys)
        return keys
    end)(),
    Callback = function(Value)
        SelectedNPC = Value
    end
})

Shop:Button({
    Title = "Teleport to NPC",
    Callback = function()
        if SelectedNPC and NPC_Locations[SelectedNPC] and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(NPC_Locations[SelectedNPC])
        end
    end
})

local Section = Shop:Section({
    Title = "Event Teleporter",
    TextXAlignment = "Left",
    TextSize = 17,
})

-- ⚙️ Auto Event TP System (Multi-select Dropdown + Spam Teleport)

local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
	character = c
	hrp = c:WaitForChild("HumanoidRootPart")
end)

-- Settings
local megCheckRadius = 150

-- Control states
local autoEventTPEnabled = false
local selectedEvents = {}
local createdEventPlatform = nil

-- Event configurations (with priority)
local eventData = {
	["Worm Hunt"] = {
		TargetName = "Model",
		Locations = {
			Vector3.new(2190.85, -1.4, 97.575), 
			Vector3.new(-2450.679, -1.4, 139.731), 
			Vector3.new(-267.479, -1.4, 5188.531),
			Vector3.new(-327, -1.4, 2422)
		},
		PlatformY = 107,
		Priority = 1,
		Icon = "fish"
	},
	["Megalodon Hunt"] = {
		TargetName = "Megalodon Hunt",
		Locations = {
			Vector3.new(-1076.3, -1.4, 1676.2),
			Vector3.new(-1191.8, -1.4, 3597.3),
			Vector3.new(412.7, -1.4, 4134.4),
		},
		PlatformY = 107,
		Priority = 2,
		Icon = "anchor"
	},
	["Ghost Shark Hunt"] = {
		TargetName = "Ghost Shark Hunt",
		Locations = {
			Vector3.new(489.559, -1.35, 25.406), 
			Vector3.new(-1358.216, -1.35, 4100.556), 
			Vector3.new(627.859, -1.35, 3798.081)
		},
		PlatformY = 107,
		Priority = 3,
		Icon = "fish"
	},
	["Shark Hunt"] = {
		TargetName = "Shark Hunt",
		Locations = {
			Vector3.new(1.65, -1.35, 2095.725),
			Vector3.new(1369.95, -1.35, 930.125),
			Vector3.new(-1585.5, -1.35, 1242.875),
			Vector3.new(-1896.8, -1.35, 2634.375)
		},
		PlatformY = 107,
		Priority = 4,
		Icon = "fish"
	},
}

local eventNames = {}
for name in pairs(eventData) do
	table.insert(eventNames, name)
end

-- Utility
local function destroyEventPlatform()
	if createdEventPlatform and createdEventPlatform.Parent then
		createdEventPlatform:Destroy()
		createdEventPlatform = nil
	end
end

local function createAndTeleportToPlatform(targetPos, y)
	destroyEventPlatform()

	local platform = Instance.new("Part")
	platform.Size = Vector3.new(5, 1, 5)
	platform.Position = Vector3.new(targetPos.X, y, targetPos.Z)
	platform.Anchored = true
	platform.Transparency = 1
	platform.CanCollide = true
	platform.Name = "EventPlatform"
	platform.Parent = Workspace
	createdEventPlatform = platform

	hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 3, 0))
end

local function runMultiEventTP()
	while autoEventTPEnabled do
		local sorted = {}
		for _, e in ipairs(selectedEvents) do
			if eventData[e] then
				table.insert(sorted, eventData[e])
			end
		end
		table.sort(sorted, function(a, b) return a.Priority < b.Priority end)

		for _, config in ipairs(sorted) do
			local foundTarget, foundPos = nil, nil

			if config.TargetName == "Model" then
				local menuRings = Workspace:FindFirstChild("!!! MENU RINGS")
				if menuRings then
					for _, props in ipairs(menuRings:GetChildren()) do
						if props.Name == "Props" then
							local model = props:FindFirstChild("Model")
							if model and model.PrimaryPart then
								for _, loc in ipairs(config.Locations) do
									if (model.PrimaryPart.Position - loc).Magnitude <= megCheckRadius then
										foundTarget = model
										foundPos = model.PrimaryPart.Position
										break
									end
								end
							end
						end
						if foundTarget then break end
					end
				end
			else
				for _, loc in ipairs(config.Locations) do
					for _, d in ipairs(Workspace:GetDescendants()) do
						if d.Name == config.TargetName then
							local pos = d:IsA("BasePart") and d.Position or (d.PrimaryPart and d.PrimaryPart.Position)
							if pos and (pos - loc).Magnitude <= megCheckRadius then
								foundTarget = d
								foundPos = pos
								break
							end
						end
					end
					if foundTarget then break end
				end
			end

			if foundTarget and foundPos then
				createAndTeleportToPlatform(foundPos, config.PlatformY)
			end
		end
		task.wait(0.05)
	end
	destroyEventPlatform()
end

Shop:Dropdown({
	Title = "Select Events",
	Values = eventNames,
	Multi = true,
	AllowNone = true,
	Callback = function(values)
		selectedEvents = values
		print("[EventTP] Selected Events:", table.concat(values, ", "))
	end
})

Shop:Toggle({
	Title = "Auto Event TP",
	Icon = "zap",
	Type = "Toggle",
	Value = false,
	Callback = function(state)
		autoEventTPEnabled = state
		if state then
			task.spawn(runMultiEventTP)
		else
		end
	end
})



local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local Toggle = SettingsTab:Toggle({
    Title = "AntiAFK",
    Desc = "Prevent Roblox from kicking you when idle",
    Icon = false,
    Type = false,
    Default = false,
    Callback = function(state)
        _G.AntiAFK = state
        local VirtualUser = game:GetService("VirtualUser")

        if state then
            task.spawn(function()
                while _G.AntiAFK do
                    task.wait(60)
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)

            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "AntiAFK loaded!",
                Text = "Coded By nat.sh",
                Button1 = "Nigger",
                Duration = 5
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "AntiAFK Disabled",
                Text = "Stopped AntiAFK",
                Duration = 3
            })
        end
    end
})

local Toggle = SettingsTab:Toggle({
    Title = "Auto Reconnect",
    Desc = "Automatic reconnect if disconnected",
    Icon = false,
    Default = false,
    Callback = function(state)
        _G.AutoReconnect = state
        if state then
            task.spawn(function()
                while _G.AutoReconnect do
                    task.wait(2)

                    local reconnectUI = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
                    if reconnectUI then
                        local prompt = reconnectUI:FindFirstChild("promptOverlay")
                        if prompt then
                            local button = prompt:FindFirstChild("ButtonPrimary")
                            if button and button.Visible then
                                firesignal(button.MouseButton1Click)
                            end
                        end
                    end
                end
            end)
        end
    end
})

SettingsTab:Section({
    Title = 'Hide Identity Features',
    TextXAlignment = 'Left',
    TextSize = 17,
})

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local function getOverhead(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    return hrp:WaitForChild("Overhead")
end

local overhead = getOverhead(Character)
local header = overhead.Content.Header
local levelLabel = overhead.LevelContainer.Label

local defaultHeader = header.Text
local defaultLevel = levelLabel.Text
local customHeader = defaultHeader
local customLevel = defaultLevel

local keepHidden = false
local rgbThread = nil

SettingsTab:Input({
    Title = "Hide Name",
    Placeholder = "Input Name",
    Default = defaultHeader,
    Callback = function(value)
        customHeader = value
        if keepHidden then
            header.Text = customHeader
        end
    end
})

SettingsTab:Input({
    Title = "Hide Level",
    Placeholder = "Input Level",
    Default = defaultLevel,
    Callback = function(value)
        customLevel = value
        if keepHidden then
            levelLabel.Text = customLevel
        end
    end
})

SettingsTab:Toggle({
    Title = "Hide Identity (RGB Blink)",
    Default = false,
    Callback = function(state)
        keepHidden = state

        if state then
            header.Text = customHeader
            levelLabel.Text = customLevel

            if rgbThread then
                task.cancel(rgbThread)
            end

            rgbThread = task.spawn(function()
                local hue = 0
                while keepHidden do
                    hue = (hue + 0.003) % 1

                    -- Warna pastel 100% terang
                    local color = Color3.fromHSV(hue, 0.35, 1)
                    -- Saturation 0.35 = hindari warna gelap
                    -- Value 1 = selalu terang

                    pcall(function()
                        header.TextColor3 = color
                        levelLabel.TextColor3 = color
                    end)

                    task.wait(0.03)
                end
            end)
        else
            if rgbThread then
                task.cancel(rgbThread)
                rgbThread = nil
            end

            header.Text = defaultHeader
            levelLabel.Text = defaultLevel

            header.TextColor3 = Color3.new(1,1,1)
            levelLabel.TextColor3 = Color3.new(1,1,1)
        end
    end
})

Player.CharacterAdded:Connect(function(newChar)
    local overhead = getOverhead(newChar)
    header = overhead.Content.Header
    levelLabel = overhead.LevelContainer.Label

    if keepHidden then
        header.Text = customHeader
        levelLabel.Text = customLevel
    end
end)


SettingsTab:Section({ 
    Title = "Server",
    TextXAlignment = "Left",
    TextSize = 17,
})

SettingsTab:Button({
    Title = "Rejoin Server",
    Desc = "Reconnect to current server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

SettingsTab:Button({
    Title = "Server Hop",
    Desc = "Switch to another server",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        
        local function GetServers()
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
            local response = HttpService:JSONDecode(game:HttpGet(url))
            return response.data
        end

        local function FindBestServer(servers)
            for _, server in ipairs(servers) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    return server.id
                end
            end
            return nil
        end
        local servers = GetServers()
        local serverId = FindBestServer(servers)
        if serverId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, game.Players.LocalPlayer)
        else
            warn("⚠️ No suitable server found!")
        end
    end
})

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

_G.Wurl = _G.Wurl or ""
_G.WebhookEnabled = _G.WebhookEnabled or false

local req = (syn and syn.request) or (http and http.request) or http_request or request

local function isValidWebhookURL(url)
    return string.find(url, "discord%.com") and string.find(url, "webhook")
end

local PremiumSection = Exclusive:Section({
    Title = "Premium",
    TextXAlignment = "Left",
    TextSize = 17,
})

local stopAnimConnections = {}
local function setAnim(v)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    for _, c in ipairs(stopAnimConnections) do c:Disconnect() end
    stopAnimConnections = {}

    if v then
        for _, t in ipairs(hum:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
            t:Stop(0)
        end
        local c = hum:FindFirstChildOfClass("Animator").AnimationPlayed:Connect(function(t)
            task.defer(function() t:Stop(0) end)
        end)
        table.insert(stopAnimConnections, c)
    else
        for _, c in ipairs(stopAnimConnections) do c:Disconnect() end
        stopAnimConnections = {}
    end
end

Exclusive:Toggle({
    Title = "No Animation",
    Desc = "",
    Value = false,
    Callback = setAnim
})

local freezeConnection
local originalCFrame

Exclusive:Toggle({
    Title = "Freeze Character",
    Default = false,
    Callback = function(state)
        _G.FreezeCharacter = state
        if state then
            local character = game.Players.LocalPlayer.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    originalCFrame = root.CFrame
                    freezeConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        if _G.FreezeCharacter and root then
                            root.CFrame = originalCFrame
                        end
                    end)
                end
            end
        else
            if freezeConnection then
                freezeConnection:Disconnect()
                freezeConnection = nil
            end
        end
    end
})

Exclusive:Toggle({
    Title = "Disable Notification",
    Default = true,
    Callback = function(state)
        disableNotifs = state
        if state then
            for _, ev in ipairs({
                Net["RE/ObtainedNewFishNotification"],
                Net["RE/TextNotification"],
                Net["RE/ClaimNotification"],
                Net["RE/DisplaySystemMessage"],
                Net["RE/PlayVFX"],
            }) do
                if ev and ev.OnClientEvent then
                    for _, conn in ipairs(getconnections(ev.OnClientEvent)) do
                        conn:Disconnect()
                    end
                end
            end
        end
    end
})

Exclusive:Toggle({
    Title = "Disable Char Effect",
    Default = false,
    Callback = function(state)
        disableCharFx = state
        if state then
            local effectEvents = {
                Net["RE/PlayFishingEffect"]
            }

            for _, ev in ipairs(effectEvents) do
                if ev and ev.OnClientEvent then
                    for _, conn in ipairs(getconnections(ev.OnClientEvent)) do
                        conn:Disconnect()
                    end
                    ev.OnClientEvent:Connect(function() end)
                end
            end

            if FishingController then
                if not _fxBackup then
                    _fxBackup = {
                        PlayFishingEffect = FishingController.PlayFishingEffect,
                        ReplicateCutscene = FishingController.ReplicateCutscene
                    }
                end
                FishingController.PlayFishingEffect = function() end
                FishingController.ReplicateCutscene = function() end
            end
        else
            if _fxBackup then
                for k, v in pairs(_fxBackup) do
                    FishingController[k] = v
                end
            end
        end
    end
})

Exclusive:Toggle({
    Title = "Delete Fishing Effects",
    Default = false,
    Callback = function(state)
        delEffects = state
        if state then
            spawn(LPH_NO_VIRTUALIZE(function()
                while delEffects do
                    local cosmetic = workspace:FindFirstChild("CosmeticFolder")
                    if cosmetic then
                        cosmetic:Destroy()
                    end
                    task.wait(60)
                end
            end))
        end
    end
})

Exclusive:Toggle({
    Title = "Hide Rod On Hand",
    Default = false,
    Callback = function(state)
        hideRod = state
        if state then
            spawn(LPH_NO_VIRTUALIZE(function()
                while hideRod do
                    for _, char in ipairs(workspace.Characters:GetChildren()) do
                        local toolFolder = char:FindFirstChild("!!!EQUIPPED_TOOL!!!")
                        if toolFolder then
                            toolFolder:Destroy()
                        end
                    end
                    task.wait(1)
                end
            end))
        end
    end
})

Exclusive:Section({
    Title = "Blantant",
})

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local speedMultiplier = 100

local fishingKeywords = {
    "RodThrow",
    "ReelStart",
    "Reeling",
    "Reelfish",
    "CatchFish",
    "FishCaught",
    "Fish",
}

local function isFishingAnimation(animName)
    animName = animName:lower()
    for _, key in ipairs(fishingKeywords) do
        if string.find(animName, key:lower()) then
            return true
        end
    end
    return false
end

lp.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.AnimationPlayed:Connect(function(track)
        local anim = track.Animation
        if not anim then return end
        local name = anim.Name or anim.AnimationId
        if isFishingAnimation(name) then
            track.PlaybackSpeed = speedMultiplier
            print("[FAST-FISH] Boosted:", name, "->", speedMultiplier.."x")
        end
    end)
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Config = {
    blantant = false,
    cancel = 1.55,
    complete = 0.5
}

local Net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local charge, requestminigame, fishingcomplete, equiprod, cancelinput, ReplicateTextEffect
pcall(function()
    charge = Net:WaitForChild("RF/ChargeFishingRod")
    requestminigame = Net:WaitForChild("RF/RequestFishingMinigameStarted")
    fishingcomplete = Net:WaitForChild("RE/FishingCompleted")
    equiprod = Net:WaitForChild("RE/EquipToolFromHotbar")
    cancelinput = Net:WaitForChild("RF/CancelFishingInputs")
    ReplicateTextEffect = Net:WaitForChild("RE/ReplicateTextEffect")
end)

local mainThread = nil
local equipThread = nil

local exclaimDetected = false

ReplicateTextEffect.OnClientEvent:Connect(function(data)
    local char = LocalPlayer.Character
    if not char or not data.TextData or not data.TextData.AttachTo then return end

    if data.TextData.AttachTo:IsDescendantOf(char) and data.TextData.Text == "!" then
        exclaimDetected = true
    end
end)

local function StartCast()
    task.spawn(function()
        pcall(function()
            local ok = cancelinput:InvokeServer()
            if not ok then
                repeat
                    ok = cancelinput:InvokeServer()
                until ok
            end

            local charged = charge:InvokeServer(math.huge)
            if not charged then
                repeat
                    charged = charge:InvokeServer(math.huge)
                until charged
            end

            requestminigame:InvokeServer(1, 0.05, 1731873.1873)
        end)
    end)

    task.spawn(function()
        exclaimDetected = false

        local timeout = 15
        local timer = 0

        while timer < timeout and not exclaimDetected and Config.blantant do
            task.wait(0.01)
            timer += 0.01
        end

        if not exclaimDetected or not Config.blantant then return end

        task.wait(Config.complete)

        if Config.blantant then
            pcall(fishingcomplete.FireServer, fishingcomplete)
        end
    end)
end

local function MainLoop()
    equipThread = task.spawn(function()
        while Config.blantant do
            pcall(equiprod.FireServer, equiprod, 1)
            task.wait(1.5)
        end
    end)

    while Config.blantant do
        StartCast()
        task.wait(Config.cancel)
        if not Config.blantant then break end
        task.wait(0.1)
    end
end

local function Toggle(state)
    Config.blantant = state

    if state then
        if mainThread then task.cancel(mainThread) end
        if equipThread then task.cancel(equipThread) end
        mainThread = task.spawn(MainLoop)
    else
        if mainThread then task.cancel(mainThread) end
        if equipThread then task.cancel(equipThread) end
        mainThread = nil
        equipThread = nil
        pcall(cancelinput.InvokeServer, cancelinput)
    end
end

Exclusive:Toggle({
    Title = "Blantant",
    Value = Config.blantant,
    Callback = function(val)
        Toggle(val)
    end
})

Exclusive:Input({
    Title = "Delay Bait",
    Placeholder = "1.55",
    Default = tostring(Config.cancel),
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            Config.cancel = num
        end
    end
})

Exclusive:Input({
    Title = "Delay Reel",
    Placeholder = "0.5",
    Default = tostring(Config.complete),
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            Config.complete = num
        end
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages._Index
local NetService = Packages["sleitnick_net@0.2.0"].net

local FishingController = require(ReplicatedStorage.Controllers.FishingController)

local oldClick = FishingController.RequestFishingMinigameClick
local oldCharge = FishingController.RequestChargeFishingRod

local autoPerf = false

task.spawn(function()
    while task.wait() do
        if autoPerf then
            NetService["RF/UpdateAutoFishingState"]:InvokeServer(true)
        end
    end
end)

Exclusive:Toggle({
    Title = "Auto Perfection",
    Value = autoPerf,
    Callback = function(state)
        autoPerf = state
        
        if autoPerf then
            FishingController.RequestFishingMinigameClick = function(...) end
            FishingController.RequestChargeFishingRod = function(...) end
            print("Auto Perfection ON — Click & Charge disabled")

        else
            NetService["RF/UpdateAutoFishingState"]:InvokeServer(false)
            FishingController.RequestFishingMinigameClick = oldClick
            FishingController.RequestChargeFishingRod = oldCharge
            print("Auto Perfection OFF — Functions restored")
        end
    end
})

Exclusive:Section({ Title = "Webhook Fish Caught", TextXAlignment = "Left", TextSize = 17 })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local httpRequest = syn and syn.request or http and http.request or http_request or (fluxus and fluxus.request) or
    request
if not httpRequest then return end

local ItemUtility, Replion, DataService
local fishDB = {}
local rarityList = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" }
local tierToRarity = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "SECRET"
}
local knownFishUUIDs = {}

pcall(function()
    ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    Replion = require(ReplicatedStorage.Packages.Replion)
    DataService = Replion.Client:WaitReplion("Data")
end)

function buildFishDatabase()
    local RS = game:GetService("ReplicatedStorage")
    local itemsContainer = RS:WaitForChild("Items")
    if not itemsContainer then return end

    for _, itemModule in ipairs(itemsContainer:GetChildren()) do
        local success, itemData = pcall(require, itemModule)
        if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
            local data = itemData.Data
            if data.Id and data.Name then
                fishDB[data.Id] = {
                    Name = data.Name,
                    Tier = data.Tier,
                    Icon = data.Icon,
                    SellPrice = itemData.SellPrice
                }
            end
        end
    end
end
function getInventoryFish()
    if not (DataService and ItemUtility) then return {} end
    local inventoryItems = DataService:GetExpect({ "Inventory", "Items" })
    local fishes = {}
    for _, v in pairs(inventoryItems) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data.Type == "Fish" then
            table.insert(fishes, { Id = v.Id, UUID = v.UUID, Metadata = v.Metadata })
        end
    end
    return fishes
end

function getPlayerCoins()
    if not DataService then return "N/A" end
    local success, coins = pcall(function() return DataService:Get("Coins") end)
    if success and coins then return string.format("%d", coins):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") end
    return "N/A"
end

function getThumbnailURL(assetString)
    local assetId = assetString:match("rbxassetid://(%d+)")
    if not assetId then return nil end
    local api = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png",
        assetId)
    local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(api)) end)
    return success and response and response.data and response.data[1] and response.data[1].imageUrl
end

function sendTestWebhook()
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then
        WindUI:Notify({ Title = "Error", Content = "Webhook URL Empty" })
        return
    end

    local payload = {
        username = "VoraHub Webhook",
        avatar_url = "https://cdn.discordapp.com/attachments/1434789394929287178/1448926732705988659/Swuppie.jpg?ex=693d09ac&is=693bb82c&hm=88d4c68207470eb4abc79d9b68227d85171aded5d3d99e9a76edcd823862f5fe",
        embeds = {{
            title = "Test Webhook Connected",
            description = "Webhook connection successful!",
            color = 0x00FF00
        }}
    }

    pcall(function()
        httpRequest({
            Url = _G.WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

function sendNewFishWebhook(newlyCaughtFish)
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then return end

    local newFishDetails = fishDB[newlyCaughtFish.Id]
    if not newFishDetails then return end

    local newFishRarity = tierToRarity[newFishDetails.Tier] or "Unknown"
    if #_G.WebhookRarities > 0 and not table.find(_G.WebhookRarities, newFishRarity) then return end

    local fishWeight = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.Weight and string.format("%.2f Kg", newlyCaughtFish.Metadata.Weight)) or "N/A"
    local mutation   = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.VariantId and tostring(newlyCaughtFish.Metadata.VariantId)) or "None"
    local sellPrice  = (newFishDetails.SellPrice and ("$"..string.format("%d", newFishDetails.SellPrice):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "").." Coins")) or "N/A"
    local currentCoins = getPlayerCoins()

    local totalFishInInventory = #getInventoryFish()
    local backpackInfo = string.format("%d/4500", totalFishInInventory)

    local playerName = game.Players.LocalPlayer.Name

    local payload = {
        content = nil,
        embeds = {{
            title = "VoraHub Fish caught!",
            description = string.format("Congrats! **%s** You obtained new **%s** here for full detail fish :", playerName, newFishRarity),
            url = "https://discord.gg/vorahub",
            color = 8900346,
            fields = {
                { name = "Name Fish :",        value = "```\n"..newFishDetails.Name.."```" },
                { name = "Rarity :",           value = "```"..newFishRarity.."```" },
                { name = "Weight :",           value = "```"..fishWeight.."```" },
                { name = "Mutation :",         value = "```"..mutation.."```" },
                { name = "Sell Price :",       value = "```"..sellPrice.."```" },
                { name = "Backpack Counter :", value = "```"..backpackInfo.."```" },
                { name = "Current Coin :",     value = "```"..currentCoins.."```" },
            },
            footer = {
                text = "VoraHub Webhook",
                icon_url = "https://cdn.discordapp.com/attachments/1434789394929287178/1448926732705988659/Swuppie.jpg?ex=693d09ac&is=693bb82c&hm=88d4c68207470eb4abc79d9b68227d85171aded5d3d99e9a76edcd823862f5fe"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            thumbnail = {
                url = getThumbnailURL(newFishDetails.Icon)
            }
        }},
        username = "VoraHub Webhook",
        avatar_url = "https://cdn.discordapp.com/attachments/1434789394929287178/1448926732705988659/Swuppie.jpg?ex=693d09ac&is=693bb82c&hm=88d4c68207470eb4abc79d9b68227d85171aded5d3d99e9a76edcd823862f5fe",
        attachments = {}
    }

    pcall(function()
        httpRequest({
            Url = _G.WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

U = Exclusive:Input({
    Title = "URL Webhook",
    Placeholder = "Paste your Discord Webhook URL here",
    Value = _G.WebhookURL or "",
    Callback = function(text)
        _G.WebhookURL = text
    end
})

V = Exclusive:Dropdown({
    Title = "Rarity Filter",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    Value = _G.WebhookRarities or {},
    Callback = function(selected_options)
        _G.WebhookRarities = selected_options
    end
})

WU = Exclusive:Toggle({
    Title = "Send Webhook",
    Value = _G.DetectNewFishActive or false,
    Callback = function(state)
        _G.DetectNewFishActive = state
    end
})

Exclusive:Button({
    Title = "Test Webhook",
    Callback = sendTestWebhook
})

Exclusive:Section({ Title = "Webhook Whatsapp Fish Caught", TextXAlignment = "Left", TextSize = 17 })

function sendFishToWhatsApp_API(fish)
    if not _G.WA_NumberID or _G.WA_NumberID == "" or
       not _G.WA_AccessToken or _G.WA_AccessToken == "" or
       not _G.WA_TargetPhone or _G.WA_TargetPhone == "" then
        warn("[VoraHub WA] Missing WhatsApp API credentials")
        return
    end

    local fishInfo = fishDB[fish.Id]
    if not fishInfo then return end

    local rarity = tierToRarity[fishInfo.Tier] or "Unknown"
    if #_G.WebhookRarities > 0 and not table.find(_G.WebhookRarities, rarity) then
        return
    end

    local weight   = (fish.Metadata and fish.Metadata.Weight and string.format("%.2f Kg", fish.Metadata.Weight)) or "N/A"
    local mutation = (fish.Metadata and fish.Metadata.VariantId and tostring(fish.Metadata.VariantId)) or "None"
    local price    = (fishInfo.SellPrice and ("$"..fishInfo.SellPrice)) or "N/A"
    local coins    = getPlayerCoins()
    local totalFish = #getInventoryFish()

    local thumbnail = getThumbnailURL(fishInfo.Icon)
    if not thumbnail then return end

    local caption = string.format(
        "🎣 *New Fish Caught!*\n\n" ..
        "🐟 *Name:* %s\n" ..
        "⭐ *Rarity:* %s\n" ..
        "⚖️ *Weight:* %s\n" ..
        "🧬 *Mutation:* %s\n" ..
        "💰 *Sell Price:* %s\n" ..
        "🎒 *Backpack:* %d/4500\n" ..
        "🪙 *Coins:* %s\n\n" ..
        "— VoraHub Auto Fishing",
        fishInfo.Name, rarity, weight, mutation, price, totalFish, coins
    )

    httpRequest({
        Url = "https://graph.facebook.com/v21.0/" .. _G.WA_NumberID .. "/messages",
        Method = "POST",
        Headers = {
            ["Authorization"] = "Bearer " .. _G.WA_AccessToken,
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            messaging_product = "whatsapp",
            to = _G.WA_TargetPhone,
            type = "image",
            image = {
                link = thumbnail,
                caption = caption
            }
        })
    })
end

_G.FonnteToken        = "eJ2K4skattShv2iwYXCU"                     -- Token API Fonnte (lu isi sendiri)
_G.WA_TargetPhone     = ""                     -- Nomor tujuan WA (62xxxx)
_G.WebhookRarities    = {}                     -- List rarity yg mau dikirim (multi)
_G.DetectNewFishActive = false                 -- Toggle on/off webhook


function sendFonnteMessage(number, message, imageURL)
    local payload = {
        target = number,
        message = message,
        image = imageURL
    }

    httpRequest({
        Url = "https://api.fonnte.com/send",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = _G.FonnteToken
        },
        Body = HttpService:JSONEncode(payload)
    })
end
function sendNewFishWA(fish)
    local info = fishDB[fish.Id]
    if not info then return end

    local rarity = tierToRarity[info.Tier] or "Unknown"

    if #_G.WebhookRarities > 0 and not table.find(_G.WebhookRarities, rarity) then
        return
    end

    local weight   = fish.Metadata.Weight and string.format("%.2f Kg", fish.Metadata.Weight) or "N/A"
    local variant  = fish.Metadata.VariantId or "None"
    local iconURL  = getThumbnailURL(info.Icon)
    local playerName = game.Players.LocalPlayer.Name

    local msg = "🐟 New Fish Caught 🐟\n" .. "*" .. playerName .. "*" .. " Has Caught An *".. rarity .."* Fish!!!\n\n" ..
                "• Name: " .. info.Name .. "\n" ..
                "• Rarity: " .. rarity .. "\n" ..
                "• Weight: " .. weight .. "\n" ..
                "• Variant: " .. variant .. "\n" ..
                "• Sell Price: " .. tostring(info.SellPrice)

    sendFonnteMessage(_G.WA_TargetPhone, msg, iconURL)
end

Exclusive:Input({
    Title = "Target Phone (62...)",
    Placeholder = "Nomor WhatsApp",
    Value = _G.WA_TargetPhone,
    Callback = function(t)
        _G.WA_TargetPhone = t
    end
})

Exclusive:Dropdown({
    Title = "Rarity Filter",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    Value = _G.WebhookRarities,
    Callback = function(opts)
        _G.WebhookRarities = opts
    end
})

Exclusive:Toggle({
    Title = "Send WA Notification",
    Value = _G.DetectNewFishActive,
    Callback = function(s)
        _G.DetectNewFishActive = s
    end
})

Exclusive:Button({
    Title = "Test WhatsApp",
    Callback = function()
        sendFonnteMessage(_G.WA_TargetPhone, "Test berhasil! Webhook WhatsApp aktif.", nil)
    end
})

buildFishDatabase()

spawn( LPH_NO_VIRTUALIZE( function()
    local initialFishList = getInventoryFish()
    for _, fish in ipairs(initialFishList) do
        if fish and fish.UUID then
            knownFishUUIDs[fish.UUID] = true
        end
    end
end))

spawn( LPH_NO_VIRTUALIZE( function()
    while wait(0.1) do
        if _G.DetectNewFishActive then
            local currentFishList = getInventoryFish()
            for _, fish in ipairs(currentFishList) do
                if fish and fish.UUID and not knownFishUUIDs[fish.UUID] then
                    knownFishUUIDs[fish.UUID] = true
                    sendNewFishWebhook(fish)
                    sendNewFishWA(fish)
                end
            end
        end
        wait(3)
    end
end))
