local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- [ НАСТРОЙКИ ] --
getgenv().WallhackEnabled = false
getgenv().ShowNames = false
getgenv().ShowHealth = false
getgenv().HitboxEnabled = false
getgenv().BHopEnabled = false
getgenv().WatermarkEnabled = true
getgenv().HitboxSize = 3.0 
getgenv().AccentColor = Color3.fromRGB(0, 180, 255)
getgenv().SliderDragging = false -- Флаг для блокировки перетаскивания меню

-- [ ЭФФЕКТ РАЗМЫТИЯ ] --
local Blur = Lighting:FindFirstChild("NL_Blur") or Instance.new("BlurEffect")
Blur.Name = "NL_Blur"; Blur.Parent = Lighting; Blur.Size = 0; Blur.Enabled = true

if CoreGui:FindFirstChild("NL_ANIM_TOGGLES") then CoreGui:FindFirstChild("NL_ANIM_TOGGLES"):Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "NL_ANIM_TOGGLES"

-- [ WATERMARK SYSTEM + AUTO-SIZE ] --
local Watermark = Instance.new("Frame", ScreenGui)
Watermark.Name = "Watermark"
-- AutomaticSize позволяет рамке сжиматься под контент
Watermark.AutomaticSize = Enum.AutomaticSize.XY
Watermark.Size = UDim2.new(0, 0, 0, 25) -- Базовая высота, ширина автоматическая
Watermark.Position = UDim2.new(0, 20, 0, 20)
Watermark.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
Watermark.BorderSizePixel = 0
Watermark.Active = true
Watermark.Visible = getgenv().WatermarkEnabled
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 4)

local WM_Stroke = Instance.new("UIStroke", Watermark)
WM_Stroke.Color = Color3.fromRGB(40, 40, 45)
WM_Stroke.Thickness = 1

-- UIListLayout и UIPadding для правильного авто-размера
local WM_Layout = Instance.new("UIListLayout", Watermark)
WM_Layout.FillDirection = Enum.FillDirection.Horizontal
WM_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
WM_Layout.VerticalAlignment = Enum.VerticalAlignment.Center
WM_Layout.Padding = UDim.new(0, 0)

local WM_Padding = Instance.new("UIPadding", Watermark)
WM_Padding.PaddingLeft = UDim.new(0, 10)
WM_Padding.PaddingRight = UDim.new(0, 10) -- Одинаковые отступы слева и справа

local WM_Text = Instance.new("TextLabel", Watermark)
-- TextLabel тоже подстраивается под текст
WM_Text.AutomaticSize = Enum.AutomaticSize.XY
WM_Text.Size = UDim2.new(0, 0, 0, 0)
WM_Text.BackgroundTransparency = 1
WM_Text.TextColor3 = Color3.new(1, 1, 1)
WM_Text.Font = Enum.Font.GothamMedium
WM_Text.TextSize = 12
WM_Text.RichText = true
WM_Text.TextXAlignment = Enum.TextXAlignment.Left

local wmDragging, wmDragInput, wmDragStart, wmStartPos
Watermark.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        wmDragging = true
        wmDragStart = input.Position
        wmStartPos = Watermark.Position
    end
end)

Watermark.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        wmDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == wmDragInput and wmDragging then
        local delta = input.Position - wmDragStart
        Watermark.Position = UDim2.new(wmStartPos.X.Scale, wmStartPos.X.Offset + delta.X, wmStartPos.Y.Scale, wmStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        wmDragging = false
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if getgenv().WatermarkEnabled then
        local fps = math.floor(1/dt)
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        -- Обновляем текст, рамка изменится сама
        WM_Text.Text = string.format("neverlose<font color='#%s'>.cc</font>  |  %d fps  |  %d ms", getgenv().AccentColor:ToHex(), fps, ping)
        Watermark.Visible = true
    else
        Watermark.Visible = false
    end
end)

-- [ UI STRUCTURE ] --
local MainCanvas = Instance.new("CanvasGroup", ScreenGui)
MainCanvas.Size = UDim2.new(0, 520, 0, 400); MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5); MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0); MainCanvas.BackgroundColor3 = Color3.fromRGB(8, 10, 15); MainCanvas.GroupTransparency = 1; MainCanvas.Visible = false; MainCanvas.BorderSizePixel = 0; Instance.new("UICorner", MainCanvas)

local RightBg = Instance.new("Frame", MainCanvas); RightBg.Size = UDim2.new(1, -140, 1, 0); RightBg.Position = UDim2.new(0, 140, 0, 0); RightBg.BackgroundColor3 = Color3.fromRGB(8, 10, 15); RightBg.BorderSizePixel = 0; RightBg.ZIndex = 0
local MainFrame = Instance.new("Frame", MainCanvas); MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundTransparency = 1; MainFrame.ZIndex = 1
local UIScale = Instance.new("UIScale", MainCanvas); UIScale.Scale = 0.8

local menuVisible = false
local isAnimating = false

local function ToggleMenu()
    if isAnimating then return end
    isAnimating = true
    if not menuVisible then
        MainCanvas.Visible = true
        TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
        TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        TweenService:Create(Blur, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = 20}):Play()
        menuVisible = true
    else
        TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
        TweenService:Create(Blur, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = 0}):Play()
        local closeTween = TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.8})
        closeTween:Play(); closeTween.Completed:Wait()
        MainCanvas.Visible = false; menuVisible = false
    end
    task.wait(0.1); isAnimating = false
end

-- [ SIDEBAR ] --
local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(12, 14, 22); Sidebar.BorderSizePixel = 0; Instance.new("UICorner", Sidebar)
local Logo = Instance.new("TextLabel", Sidebar); Logo.RichText = true; Logo.Text = "neverlose<font color='#00b4ff'>.cc</font>"; Logo.Size = UDim2.new(1, 0, 0, 45); Logo.Position = UDim2.new(0, 0, 0, 10); Logo.BackgroundTransparency = 1; Logo.TextColor3 = Color3.new(1,1,1); Logo.Font = Enum.Font.GothamBold; Logo.TextSize = 20
local Author = Instance.new("TextLabel", Sidebar); Author.Text = "by @s1lnt"; Author.Size = UDim2.new(1, -20, 0, 20); Author.Position = UDim2.new(0, 15, 0, 42); Author.BackgroundTransparency = 1; Author.TextColor3 = Color3.fromRGB(150, 150, 150); Author.Font = Enum.Font.GothamMedium; Author.TextSize = 10; Author.TextXAlignment = Enum.TextXAlignment.Left

local TabInd = Instance.new("Frame", Sidebar); TabInd.Size = UDim2.new(0, 3, 0, 24); TabInd.Position = UDim2.new(0, 2, 0, 78); TabInd.BackgroundColor3 = getgenv().AccentColor; Instance.new("UICorner", TabInd); TabInd.ZIndex = 10
local Pages = Instance.new("Frame", MainFrame); Pages.Position = UDim2.new(0, 150, 0, 20); Pages.Size = UDim2.new(1, -165, 1, -40); Pages.BackgroundTransparency = 1

local function CreatePage(n)
    local p = Instance.new("ScrollingFrame", Pages); p.Name = n; p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0; Instance.new("UIListLayout", p).Padding = UDim.new(0, 8); return p
end
local CombatPage = CreatePage("Combat"); local VisualsPage = CreatePage("Visuals"); local MiscPage = CreatePage("Misc"); local MenuPage = CreatePage("Menu")

-- [ ЭЛЕМЕНТЫ УПРАВЛЕНИЯ ] --
local TogglesList = {}
local function CreateToggle(parent, text, callback)
    local Container = Instance.new("Frame", parent); Container.Size = UDim2.new(1, -10, 0, 35); Container.BackgroundColor3 = Color3.fromRGB(15, 17, 26); Instance.new("UICorner", Container)
    local Lbl = Instance.new("TextLabel", Container); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(1, -50, 1, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Color3.fromRGB(140, 140, 140); Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local BG = Instance.new("Frame", Container); BG.Size = UDim2.new(0, 34, 0, 16); BG.Position = UDim2.new(1, -40, 0.5, -8); BG.BackgroundColor3 = Color3.fromRGB(30, 35, 45); Instance.new("UICorner", BG).CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame", BG); Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new(0, 2, 0.5, -6); Dot.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""
    local t = {On = false, BG = BG}
    t.Update = function(state)
        t.On = state
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = t.On and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
        TweenService:Create(BG, TweenInfo.new(0.2), {BackgroundColor3 = t.On and getgenv().AccentColor or Color3.fromRGB(30, 35, 45)}):Play()
        TweenService:Create(Lbl, TweenInfo.new(0.2), {TextColor3 = t.On and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 140)}):Play()
        callback(t.On)
    end
    Btn.MouseButton1Click:Connect(function() t.Update(not t.On) end)
    TogglesList[text] = t
    return t
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Container = Instance.new("Frame", parent); Container.Size = UDim2.new(1, -10, 0, 45); Container.BackgroundColor3 = Color3.fromRGB(15, 17, 26); Instance.new("UICorner", Container)
    local Lbl = Instance.new("TextLabel", Container); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.TextColor3 = Color3.fromRGB(140, 140, 140); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local SliderPart = Instance.new("Frame", Container); SliderPart.Size = UDim2.new(1, -20, 0, 4); SliderPart.Position = UDim2.new(0, 10, 0, 30); SliderPart.BackgroundColor3 = Color3.fromRGB(30, 35, 45); SliderPart.BorderSizePixel = 0; Instance.new("UICorner", SliderPart)
    local Fill = Instance.new("Frame", SliderPart); Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = getgenv().AccentColor; Fill.BorderSizePixel = 0; Instance.new("UICorner", Fill)
    local Dot = Instance.new("Frame", Fill); Dot.Size = UDim2.new(0, 10, 0, 10); Dot.Position = UDim2.new(1, -5, 0.5, -5); Dot.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Dot)
    local Val = Instance.new("TextLabel", Container); Val.Text = tostring(default); Val.Position = UDim2.new(1, -40, 0, 5); Val.Size = UDim2.new(0, 30, 0, 15); Val.TextColor3 = getgenv().AccentColor; Val.BackgroundTransparency = 1; Val.Font = Enum.Font.GothamMedium; Val.TextSize = 11
    
    local dragging = false
    local function Move()
        local percent = math.clamp((UserInputService:GetMouseLocation().X - SliderPart.AbsolutePosition.X) / SliderPart.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        local value = math.floor((min + (max - min) * percent) * 10) / 10
        Val.Text = tostring(value); callback(value)
    end

    SliderPart.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
            getgenv().SliderDragging = true -- БЛОКИРУЕМ МЕНЮ
            Move() 
        end 
    end)
    
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
            getgenv().SliderDragging = false -- РАЗБЛОКИРУЕМ МЕНЮ
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(i) 
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then 
            Move() 
        end 
    end)
    
    return {Fill = Fill, Val = Val}
end

-- [ КОНТЕНТ СТРАНИЦ ] --
CreateToggle(CombatPage, "Enable Hitbox", function(s) getgenv().HitboxEnabled = s end)
local HB_Slider = CreateSlider(CombatPage, "Hitbox Size", 1.0, 3.0, 2.0, function(v) getgenv().HitboxSize = v end)

CreateToggle(VisualsPage, "Enable Wallhack", function(s) 
    getgenv().WallhackEnabled = s 
    if not s then
        if TogglesList["Show Names"] then TogglesList["Show Names"].Update(false) end
        if TogglesList["Show Health"] then TogglesList["Show Health"].Update(false) end
    end
end)
CreateToggle(VisualsPage, "Show Names", function(s) getgenv().ShowNames = s end)
CreateToggle(VisualsPage, "Show Health", function(s) getgenv().ShowHealth = s end)
CreateToggle(MiscPage, "BunnyHop", function(s) getgenv().BHopEnabled = s end)

-- [ MENU PAGE ] --
local WM_Tog = CreateToggle(MenuPage, "Enable Watermark", function(s) getgenv().WatermarkEnabled = s end)
WM_Tog.Update(true)

local function CreateCol(c, n)
    -- Уменьшен размер кнопок цветов (высота 30 вместо 35, текст 13 вместо 14)
    local b = Instance.new("TextButton", MenuPage); b.Size = UDim2.new(1, -10, 0, 30); b.BackgroundColor3 = Color3.fromRGB(20, 23, 33); b.Text = n; b.TextColor3 = c; b.Font = Enum.Font.GothamMedium; b.TextSize = 13; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() 
        getgenv().AccentColor = c; TabInd.BackgroundColor3 = c; Logo.Text = "neverlose<font color='#"..c:ToHex().."'>.cc</font>"
        HB_Slider.Fill.BackgroundColor3 = c; HB_Slider.Val.TextColor3 = c
        for _, t in pairs(TogglesList) do if t.On then TweenService:Create(t.BG, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play() end end
    end)
end
CreateCol(Color3.fromRGB(0, 180, 255), "Neverlose Blue"); CreateCol(Color3.fromRGB(150, 80, 255), "Purple Dream"); CreateCol(Color3.fromRGB(0, 255, 130), "Acid Green")
CreateCol(Color3.fromRGB(255, 0, 0), "Red Style"); CreateCol(Color3.fromRGB(0, 255, 255), "Cyan Style"); CreateCol(Color3.fromRGB(255, 255, 0), "Yellow Style")

local function AddSocialLink(txt, col)
    local l = Instance.new("TextLabel", MenuPage); l.Size = UDim2.new(1, -10, 0, 25); l.BackgroundTransparency = 1; l.Text = "  " .. txt; l.TextColor3 = col; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
end
AddSocialLink("Discord: _s1lnt", Color3.fromRGB(114, 137, 218))
AddSocialLink("Tg: t.me/archiv33d", Color3.fromRGB(0, 136, 204))
AddSocialLink("Github: github.com/sylent345", Color3.fromRGB(200, 200, 200))

-- [ ТАБЫ ] --
local TabButtons = {}
local function CreateTab(n, y)
    local Container = Instance.new("Frame", Sidebar); Container.Size = UDim2.new(1, -10, 0, 35); Container.Position = UDim2.new(0, 5, 0, y); Container.BackgroundTransparency = 1; Instance.new("UICorner", Container)
    local t = Instance.new("TextButton", Container); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = n; t.TextColor3 = Color3.fromRGB(140, 140, 140); t.Font = Enum.Font.GothamMedium; t.TextSize = 14; t.ZIndex = 5
    TabButtons[n] = {Btn = t, Box = Container}
    t.MouseButton1Click:Connect(function() 
        for name, data in pairs(TabButtons) do
            local isTarget = (name == n)
            TweenService:Create(data.Btn, TweenInfo.new(0.2), {TextColor3 = isTarget and Color3.new(1,1,1) or Color3.fromRGB(140, 140, 140)}):Play()
            TweenService:Create(data.Box, TweenInfo.new(0.2), {BackgroundTransparency = isTarget and 0.92 or 1, BackgroundColor3 = Color3.new(1,1,1)}):Play()
            Pages[name].Visible = isTarget
        end
        TweenService:Create(TabInd, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0, y + 5)}):Play() 
    end)
end
CreateTab("Combat", 75); CreateTab("Visuals", 115); CreateTab("Misc", 155); CreateTab("Menu", 195)
CombatPage.Visible = true; TabButtons["Combat"].Btn.TextColor3 = Color3.new(1,1,1)

-- [ ЛОГИКА ESP И ХИТБОКСОВ ] --
local function UpdateESP(p)
    local char = p.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not getgenv().WallhackEnabled then if root then for _, o in pairs(root:GetChildren()) do if o.Name:find("NL_") then o:Destroy() end end end return end
    if not char or not root or not hum or hum.Health <= 0 then return end
    
    local box = root:FindFirstChild("NL_Box") or Instance.new("CylinderHandleAdornment", root)
    if box.Name ~= "NL_Box" then box.Name = "NL_Box"; box.Adornee = root; box.AlwaysOnTop = true; box.ZIndex = 5; box.Transparency = 0.6; box.Height = 5.2; box.Radius = 1.8; box.CFrame = CFrame.Angles(math.rad(90), 0, 0) end
    box.Color3 = getgenv().AccentColor

    local hpBar = root:FindFirstChild("NL_HP_Bar"); local hpBg = root:FindFirstChild("NL_HP_BG")
    if getgenv().ShowHealth then
        if not hpBar then
            hpBg = Instance.new("BoxHandleAdornment", root); hpBg.Name = "NL_HP_BG"; hpBg.Adornee = root; hpBg.AlwaysOnTop = true; hpBg.Size = Vector3.new(0.2, 5.2, 0.1); hpBg.Color3 = Color3.new(0,0,0); hpBg.CFrame = CFrame.new(-2, 0, 0); hpBg.ZIndex = 4
            hpBar = Instance.new("BoxHandleAdornment", root); hpBar.Name = "NL_HP_Bar"; hpBar.Adornee = root; hpBar.AlwaysOnTop = true; hpBar.ZIndex = 6
        end
        local hpP = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        hpBar.Size = Vector3.new(0.21, 5.2 * hpP, 0.11); hpBar.CFrame = CFrame.new(-2, -(2.6 * (1 - hpP)), 0); hpBar.Color3 = Color3.fromHSV(hpP * 0.3, 1, 1)
    else if hpBar then hpBar:Destroy(); hpBg:Destroy() end end

    local nameGui = root:FindFirstChild("NL_NameGui")
    if getgenv().ShowNames then
        if not nameGui then
            nameGui = Instance.new("BillboardGui", root); nameGui.Name = "NL_NameGui"; nameGui.Adornee = root; nameGui.AlwaysOnTop = true; nameGui.Size = UDim2.new(0, 100, 0, 20); nameGui.ExtentsOffset = Vector3.new(0, 3.8, 0)
            local t = Instance.new("TextLabel", nameGui); t.Name = "L"; t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; t.TextSize = 11; t.TextStrokeTransparency = 0.5
        end
        nameGui.L.Text = p.Name
    else if nameGui then nameGui:Destroy() end end
end

RunService.RenderStepped:Connect(function()
    if getgenv().BHopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Jump = true end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            UpdateESP(p)
            if p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                if getgenv().HitboxEnabled then
                    head.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize); head.Transparency = 0.7; head.CanCollide = false
                else
                    head.Size = Vector3.new(1.15, 1.15, 1.15); head.Transparency = 0; head.CanCollide = true
                end
            end
        end
    end
end)

-- [ MAIN MENU DRAG SYSTEM ] --
local dragging, dragInput, dragStart, startPos
MainCanvas.InputBegan:Connect(function(input)
    -- Проверка: если мы крутим слайдер, меню НЕ двигается
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not getgenv().SliderDragging then 
        dragging = true; dragStart = input.Position; startPos = MainCanvas.Position 
    end
end)
MainCanvas.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainCanvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end end)
ToggleMenu()