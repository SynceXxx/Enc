-- SynceLib.lua
-- SynceHub Universal UI Library
-- Created by SynceHub Team

local SynceLib = {}
SynceLib.__index = SynceLib
SynceLib.Version = "1.0.0"

-- Services
local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer

-- Sound effects
local Sounds = {
    Click = "rbxassetid://6895079853",
    Toggle = "rbxassetid://6895079853", 
    Hover = "rbxassetid://10066931761",
    Minimize = "rbxassetid://6895079853",
    Dropdown = "rbxassetid://6895079853",
    Success = "rbxassetid://6026984224",
    Error = "rbxassetid://6026984224"
}

local function playSound(soundId, volume)
    volume = volume or 0.5
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:ShowNotification(message, success)
    if not self.GUI then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = success and "rbxassetid://6026984224" or "rbxassetid://6026984224"
    sound.Volume = success and 0.5 or 0.4
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
    
    spawn(function()
        local n = self.GUI:FindFirstChild("NotifContainer")
        if not n then
            n = Instance.new("Frame")
            n.Name = "NotifContainer"
            n.Size = UDim2.new(0, 280, 1, 0)
            n.Position = UDim2.new(1, -290, 0, 10)
            n.BackgroundTransparency = 1
            n.ZIndex = 1000
            n.Parent = self.GUI
            
            local l = Instance.new("UIListLayout")
            l.Padding = UDim.new(0, 8)
            l.SortOrder = Enum.SortOrder.LayoutOrder
            l.VerticalAlignment = Enum.VerticalAlignment.Top
            l.Parent = n
        end
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel = 0
        f.ZIndex = 1001
        f.LayoutOrder = #self.NotifQueue + 1
        f.Parent = n
        
        table.insert(self.NotifQueue, f)
        
        local c = Instance.new("UICorner", f)
        c.CornerRadius = UDim.new(0, 12)
        
        local st = Instance.new("UIStroke", f)
        st.Color = Color3.fromRGB(200, 200, 210)
        st.Thickness = 2
        st.Transparency = 0.5
        
        local i = Instance.new("ImageLabel")
        i.Size = UDim2.new(0, 24, 0, 24)
        i.Position = UDim2.new(0, 12, 0, 12)
        i.BackgroundTransparency = 1
        i.Image = success and "rbxassetid://140507950554297" or "rbxassetid://118025272389341"
        i.ImageColor3 = Color3.fromRGB(200, 200, 210)
        i.ZIndex = 1002
        i.Parent = f
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -52, 1, 0)
        t.Position = UDim2.new(0, 44, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = message
        t.TextColor3 = Color3.fromRGB(240, 240, 245)
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextWrapped = true
        t.TextYAlignment = Enum.TextYAlignment.Center
        t.ZIndex = 1002
        t.Parent = f
        
        local h = 48
        f.Position = UDim2.new(1, 20, 0, 0)
        T:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, h),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(0.4)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
        task.wait(2.5)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        T:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        T:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play()
        T:Create(st, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        task.wait(0.3)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        f:Destroy()
        
        for i, v in ipairs(self.NotifQueue) do
            if v == f then
                table.remove(self.NotifQueue, i)
                break
            end
        end
    end)
end

function Window:Destroy()
    self.Destroyed = true
    _G.SynceHubLoaded = false
    
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    if self.OnDestroy then
        self.OnDestroy()
    end
    
    if self.GUI then self.GUI:Destroy() end
    if self.MobileButton then self.MobileButton:Destroy() end
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab:AddSection(name)
    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(1, 0, 0, 28)
    s.BackgroundTransparency = 1
    s.Text = name
    s.TextColor3 = self.Colors.sc
    s.Font = Enum.Font.GothamBold
    s.TextSize = 10
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.LayoutOrder = self:GetNextOrder()
    s.Parent = self.Container
    
    return s
end

function Tab:AddButton(config)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, self.ButtonHeight)
    b.BackgroundColor3 = self.Colors.cd
    b.Text = ""
    b.LayoutOrder = self:GetNextOrder()
    b.Parent = self.Container
    
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", b).Color = self.Colors.br
    
    if config.Icon then
        local ic = Instance.new("ImageLabel")
        ic.Size = UDim2.new(0, 20, 0, 20)
        ic.Position = UDim2.new(1, -34, 0.5, -10)
        ic.BackgroundTransparency = 1
        ic.Image = "rbxassetid://" .. config.Icon
        ic.ImageColor3 = self.Colors.ts
        ic.Parent = b
    end
    
    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.new(1, -50, 1, 0)
    tx.Position = UDim2.new(0, 14, 0, 0)
    tx.BackgroundTransparency = 1
    tx.Text = config.Name
    tx.TextColor3 = self.Colors.tx
    tx.Font = Enum.Font.GothamBold
    tx.TextSize = self.FontSize
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.Parent = b
    
    b.MouseEnter:Connect(function()
        T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = self.Colors.ch}):Play()
    end)
    
    b.MouseLeave:Connect(function()
        T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = self.Colors.cd}):Play()
    end)
    
    b.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.4)
        if config.Callback then
            config.Callback()
        end
    end)
    
    return b
end

function Tab:AddToggle(config)
    local ca = Instance.new("Frame")
    ca.Size = UDim2.new(1, 0, 0, self.ButtonHeight)
    ca.BackgroundColor3 = self.Colors.cd
    ca.LayoutOrder = self:GetNextOrder()
    ca.Parent = self.Container
    
    Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", ca).Color = self.Colors.br
    
    -- Icon support
    if config.Icon then
        local ic = Instance.new("ImageLabel")
        ic.Size = UDim2.new(0, 22, 0, 22)
        ic.Position = UDim2.new(0, 14, 0.5, -11)
        ic.BackgroundTransparency = 1
        ic.Image = "rbxassetid://" .. config.Icon
        ic.ImageColor3 = self.Colors.ts
        ic.Parent = ca
    end
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -100, 1, 0)
    lb.Position = UDim2.new(0, config.Icon and 44 or 14, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = config.Name
    lb.TextColor3 = self.Colors.tx
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = self.FontSize
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextYAlignment = Enum.TextYAlignment.Center
    lb.Parent = ca
    
    local value = config.Default or false
    self.Config[config.Flag or config.Name] = value
    
    local tg = Instance.new("TextButton")
    tg.Size = UDim2.new(0, 44, 0, 24)
    tg.Position = UDim2.new(1, -56, 0.5, -12)
    tg.BackgroundColor3 = value and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 65)
    tg.Text = ""
    tg.Parent = ca
    
    Instance.new("UICorner", tg).CornerRadius = UDim.new(1, 0)
    
    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(0, 20, 0, 20)
    tb.Position = value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    tb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tb.Parent = tg
    
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)
    
    tg.MouseButton1Click:Connect(function()
        playSound(Sounds.Toggle, 0.3)
        value = not value
        self.Config[config.Flag or config.Name] = value
        
        T:Create(tg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = value and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 65)
        }):Play()
        T:Create(tb, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Position = value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }):Play()
        
        if config.Callback then
            config.Callback(value)
        end
    end)
    
    return {
        SetValue = function(self, newValue)
            value = newValue
            self.Config[config.Flag or config.Name] = value
            tg.BackgroundColor3 = value and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 65)
            tb.Position = value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        end
    }
end

function Tab:AddSlider(config)
    local ca = Instance.new("Frame")
    ca.Size = UDim2.new(1, 0, 0, self.ButtonHeight + 10)
    ca.BackgroundColor3 = self.Colors.cd
    ca.LayoutOrder = self:GetNextOrder()
    ca.Parent = self.Container
    
    Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", ca).Color = self.Colors.br
    
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or min
    self.Config[config.Flag or config.Name] = value
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.6, 0, 0, 20)
    lb.Position = UDim2.new(0, 14, 0, 8)
    lb.BackgroundTransparency = 1
    lb.Text = config.Name
    lb.TextColor3 = self.Colors.tx
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = self.FontSize
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = ca
    
    -- Editable value box
    local vL = Instance.new("TextBox")
    vL.Size = UDim2.new(0, 60, 0, 24)
    vL.Position = UDim2.new(1, -74, 0, 6)
    vL.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    vL.Text = tostring(value)
    vL.TextColor3 = self.Colors.tx
    vL.Font = Enum.Font.GothamBold
    vL.TextSize = self.FontSize
    vL.TextXAlignment = Enum.TextXAlignment.Center
    vL.ClearTextOnFocus = false
    vL.Parent = ca
    
    Instance.new("UICorner", vL).CornerRadius = UDim.new(0, 8)
    
    local sB = Instance.new("Frame")
    sB.Size = UDim2.new(1, -28, 0, 6)
    sB.Position = UDim2.new(0, 14, 1, -16)
    sB.BackgroundColor3 = self.Colors.ch
    sB.BorderSizePixel = 0
    sB.Parent = ca
    
    Instance.new("UICorner", sB).CornerRadius = UDim.new(1, 0)
    
    local sF = Instance.new("Frame")
    sF.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    sF.BackgroundColor3 = self.Colors.ac
    sF.BorderSizePixel = 0
    sF.Parent = sB
    
    Instance.new("UICorner", sF).CornerRadius = UDim.new(1, 0)
    
    local sN = Instance.new("Frame")
    sN.Size = UDim2.new(0, 16, 0, 16)
    sN.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
    sN.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sN.BorderSizePixel = 0
    sN.Parent = sB
    
    Instance.new("UICorner", sN).CornerRadius = UDim.new(1, 0)
    
    -- Update slider visual
    local function updateSlider(val)
        val = math.clamp(val, min, max)
        value = val
        self.Config[config.Flag or config.Name] = val
        vL.Text = tostring(val)
        local pct = (val - min) / (max - min)
        sF.Size = UDim2.new(pct, 0, 1, 0)
        sN.Position = UDim2.new(pct, -8, 0.5, -8)
    end
    
    -- TextBox edit support
    vL.FocusLost:Connect(function()
        local val = tonumber(vL.Text)
        if val then
            val = math.clamp(math.floor(val), min, max)
            updateSlider(val)
            if config.Callback then config.Callback(val) end
        else
            vL.Text = tostring(value)
        end
    end)
    
    -- Dragging logic
    local dG = false
    
    sB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dG = true
            playSound(Sounds.Click, 0.2)
            
            local mP = i.Position.X
            local sP = sB.AbsolutePosition.X
            local sW = sB.AbsoluteSize.X
            local pct = math.clamp((mP - sP) / sW, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            
            updateSlider(val)
            if config.Callback then config.Callback(val) end
        end
    end)
    
    sB.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dG = false
        end
    end)
    
    sN.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dG = true
            playSound(Sounds.Click, 0.2)
        end
    end)
    
    sN.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dG = false
        end
    end)
    
    table.insert(self.Window.Connections, U.InputChanged:Connect(function(i)
        if dG and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local mP = i.Position.X
            local sP = sB.AbsolutePosition.X
            local sW = sB.AbsoluteSize.X
            local pct = math.clamp((mP - sP) / sW, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            
            updateSlider(val)
            if config.Callback then config.Callback(val) end
        end
    end))
    
    return {
        SetValue = function(self, newValue)
            updateSlider(newValue)
        end
    }
end

function Tab:AddDropdown(config)
    local ca = Instance.new("Frame")
    ca.Size = UDim2.new(1, 0, 0, self.ButtonHeight)
    ca.BackgroundColor3 = self.Colors.cd
    ca.ClipsDescendants = false
    ca.LayoutOrder = self:GetNextOrder()
    ca.Parent = self.Container
    
    Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", ca).Color = self.Colors.br
    
    local value = config.Default or (config.Options[1] or "None")
    self.Config[config.Flag or config.Name] = value
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.42, 0, 1, 0)
    lb.Position = UDim2.new(0, 14, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = config.Name
    lb.TextColor3 = self.Colors.tx
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = self.FontSize
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextYAlignment = Enum.TextYAlignment.Center
    lb.Parent = ca
    
    local db = Instance.new("TextButton")
    db.Size = UDim2.new(0.54, -14, 0, 32)
    db.Position = UDim2.new(0.46, 0, 0.5, -16)
    db.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    db.Text = ""
    db.Parent = ca
    
    Instance.new("UICorner", db).CornerRadius = UDim.new(0, 8)
    
    local dbText = Instance.new("TextLabel")
    dbText.Size = UDim2.new(1, -36, 1, 0)
    dbText.Position = UDim2.new(0, 10, 0, 0)
    dbText.BackgroundTransparency = 1
    dbText.Text = value
    dbText.TextColor3 = self.Colors.tx
    dbText.Font = Enum.Font.GothamMedium
    dbText.TextSize = self.FontSize - 1
    dbText.TextTruncate = Enum.TextTruncate.AtEnd
    dbText.TextXAlignment = Enum.TextXAlignment.Left
    dbText.Parent = db
    
    local dbIcon = Instance.new("ImageLabel")
    dbIcon.Size = UDim2.new(0, 16, 0, 16)
    dbIcon.Position = UDim2.new(1, -22, 0.5, -8)
    dbIcon.BackgroundTransparency = 1
    dbIcon.Image = "rbxassetid://91662102247848"
    dbIcon.ImageColor3 = self.Colors.ts
    dbIcon.Parent = db
    
    local dL = Instance.new("Frame")
    dL.Name = "DropList"
    dL.Size = UDim2.new(0, 0, 0, 0)
    dL.BackgroundColor3 = self.Colors.cd
    dL.Visible = false
    dL.ZIndex = 999
    dL.ClipsDescendants = true
    dL.Parent = self.MainFrame
    
    Instance.new("UICorner", dL).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", dL).Color = self.Colors.br
    
    local dS = Instance.new("ScrollingFrame")
    dS.Size = UDim2.new(1, 0, 1, 0)
    dS.BackgroundTransparency = 1
    dS.ScrollBarThickness = 2
    dS.ScrollBarImageColor3 = self.Colors.sc
    dS.BorderSizePixel = 0
    dS.CanvasSize = UDim2.new(0, 0, 0, 0)
    dS.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dS.Parent = dL
    
    local dLY = Instance.new("UIListLayout")
    dLY.Padding = UDim.new(0, 2)
    dLY.Parent = dS
    
    local function updateDropdown()
        for _, child in pairs(dS:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local options = type(config.Options) == "function" and config.Options() or config.Options
        
        for _, opt in ipairs(options) do
            local dI = Instance.new("TextButton")
            dI.Size = UDim2.new(1, -8, 0, 32)
            dI.BackgroundColor3 = opt == value and self.Colors.al or Color3.fromRGB(40, 40, 45)
            dI.Text = tostring(opt)
            dI.TextColor3 = self.Colors.tx
            dI.Font = Enum.Font.GothamMedium
            dI.TextSize = self.FontSize - 1
            dI.TextXAlignment = Enum.TextXAlignment.Left
            dI.Parent = dS
            
            Instance.new("UICorner", dI).CornerRadius = UDim.new(0, 8)
            local dIPad = Instance.new("UIPadding", dI)
            dIPad.PaddingLeft = UDim.new(0, 10)
            
            dI.MouseEnter:Connect(function()
                if opt ~= value then
                    T:Create(dI, TweenInfo.new(0.15), {BackgroundColor3 = self.Colors.ch}):Play()
                end
            end)
            
            dI.MouseLeave:Connect(function()
                if opt ~= value then
                    T:Create(dI, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
                end
            end)
            
            dI.MouseButton1Click:Connect(function()
                playSound(Sounds.Dropdown, 0.25)
                value = opt
                self.Config[config.Flag or config.Name] = opt
                dbText.Text = tostring(opt)
                dL.Visible = false
                updateDropdown()
                
                if config.Callback then
                    config.Callback(opt)
                end
            end)
        end
    end
    
    db.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.3)
        updateDropdown()
        dL.Visible = not dL.Visible
        
        if dL.Visible then
            local absPos = db.AbsolutePosition
            local absSize = db.AbsoluteSize
            dL.Position = UDim2.new(0, absPos.X - self.MainFrame.AbsolutePosition.X, 0, absPos.Y - self.MainFrame.AbsolutePosition.Y + absSize.Y + 4)
            local options = type(config.Options) == "function" and config.Options() or config.Options
            local maxH = math.min(#options * 34 + 10, 200)
            T:Create(dL, TweenInfo.new(0.2), {Size = UDim2.new(0, absSize.X, 0, maxH)}):Play()
        end
    end)
    
    return {
        SetValue = function(self, newValue)
            value = newValue
            self.Config[config.Flag or config.Name] = newValue
            dbText.Text = tostring(newValue)
            updateDropdown()
        end,
        Refresh = function(self)
            updateDropdown()
        end
    }
end

function Tab:AddInput(config)
    local ca = Instance.new("Frame")
    ca.Size = UDim2.new(1, 0, 0, self.ButtonHeight)
    ca.BackgroundColor3 = self.Colors.cd
    ca.LayoutOrder = self:GetNextOrder()
    ca.Parent = self.Container
    
    Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", ca).Color = self.Colors.br
    
    local value = config.Default or ""
    self.Config[config.Flag or config.Name] = value
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.48, 0, 1, 0)
    lb.Position = UDim2.new(0, 14, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = config.Name
    lb.TextColor3 = self.Colors.tx
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = self.FontSize
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextYAlignment = Enum.TextYAlignment.Center
    lb.Parent = ca
    
    local ib = Instance.new("TextBox")
    ib.Size = UDim2.new(0.48, -14, 0, 32)
    ib.Position = UDim2.new(0.52, 0, 0.5, -16)
    ib.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ib.Text = value
    ib.TextColor3 = self.Colors.tx
    ib.Font = Enum.Font.GothamMedium
    ib.TextSize = self.FontSize
    ib.PlaceholderText = config.Placeholder or "Enter value..."
    ib.PlaceholderColor3 = self.Colors.ts
    ib.ClearTextOnFocus = false
    ib.TextXAlignment = Enum.TextXAlignment.Center
    ib.Parent = ca
    
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 8)
    
    ib.FocusLost:Connect(function()
        local val = ib.Text
        
        if config.NumberOnly then
            val = tonumber(val)
            if val then
                self.Config[config.Flag or config.Name] = val
                if config.Callback then config.Callback(val) end
            else
                ib.Text = tostring(self.Config[config.Flag or config.Name])
            end
        else
            self.Config[config.Flag or config.Name] = val
            if config.Callback then config.Callback(val) end
        end
    end)
    
    return {
        SetValue = function(self, newValue)
            ib.Text = tostring(newValue)
            self.Config[config.Flag or config.Name] = newValue
        end
    }
end

function Tab:AddLabel(text)
    local ca = Instance.new("Frame")
    ca.Size = UDim2.new(1, 0, 0, 32)
    ca.BackgroundTransparency = 1
    ca.LayoutOrder = self:GetNextOrder()
    ca.Parent = self.Container
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -28, 1, 0)
    lb.Position = UDim2.new(0, 14, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = text
    lb.TextColor3 = self.Colors.ts
    lb.Font = Enum.Font.GothamMedium
    lb.TextSize = self.FontSize - 1
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextYAlignment = Enum.TextYAlignment.Center
    lb.Parent = ca
    
    return {
        SetText = function(self, newText)
            lb.Text = newText
        end
    }
end

function Tab:GetNextOrder()
    self.OrderCount = self.OrderCount + 1
    return self.OrderCount
end

-- Create Window Function
function SynceLib:CreateWindow(config)
    if _G.SynceHubLoaded then
        warn("SynceHub already loaded!")
        return
    end
    
    _G.SynceHubLoaded = true
    
    local window = setmetatable({}, Window)
    
    -- Configuration
    window.Title = config.Title or "SynceHub"
    window.Game = config.Game or "Universal"
    window.Version = config.Version or "[v1.0]"
    window.Keybind = config.Keybind or Enum.KeyCode.RightShift
    window.Config = {}
    window.Connections = {}
    window.NotifQueue = {}
    window.Destroyed = false
    window.OnDestroy = config.OnDestroy
    
    local isMobile = U.TouchEnabled and not U.KeyboardEnabled
    local sS = workspace.CurrentCamera.ViewportSize
    local w = isMobile and math.min(310, sS.X - 24) or 320
    local h = isMobile and math.min(480, sS.Y - 100) or 460
    local bH = isMobile and 46 or 44
    local p = 12
    local fS = isMobile and 14 or 13
    
    -- Color scheme
    local Co = {
        bg = Color3.fromRGB(20, 20, 25),
        cd = Color3.fromRGB(30, 30, 35),
        ch = Color3.fromRGB(40, 40, 45),
        ac = Color3.fromRGB(0, 122, 255),
        al = Color3.fromRGB(25, 45, 70),
        tx = Color3.fromRGB(240, 240, 245),
        ts = Color3.fromRGB(150, 150, 160),
        br = Color3.fromRGB(50, 50, 55),
        sc = Color3.fromRGB(120, 120, 130),
        warn = Color3.fromRGB(88, 101, 242)
    }
    
    -- Create main GUI
    local g = Instance.new("ScreenGui")
    g.Name = "SynceHub"
    g.ResetOnSpawn = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local m = Instance.new("Frame")
    m.Name = "Main"
    m.Size = UDim2.new(0, w, 0, h)
    m.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3 = Co.bg
    m.BorderSizePixel = 0
    m.ClipsDescendants = true
    m.Parent = g
    
    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 16)
    
    -- Shadow
    local sh = Instance.new("ImageLabel")
    sh.Size = UDim2.new(1, 30, 1, 30)
    sh.Position = UDim2.new(0, -15, 0, -15)
    sh.BackgroundTransparency = 1
    sh.Image = "rbxassetid://5554236805"
    sh.ImageColor3 = Color3.new(0, 0, 0)
    sh.ImageTransparency = 0.3
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(23, 23, 277, 277)
    sh.ZIndex = 0
    sh.Parent = m
    
    -- Header
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 52)
    hd.BackgroundTransparency = 1
    hd.Parent = m
    
    local tL = Instance.new("TextLabel")
    tL.Size = UDim2.new(1, -60, 0, 20)
    tL.Position = UDim2.new(0, p, 0, 12)
    tL.BackgroundTransparency = 1
    tL.Text = window.Title
    tL.TextColor3 = Co.tx
    tL.Font = Enum.Font.GothamBold
    tL.TextSize = 18
    tL.TextXAlignment = Enum.TextXAlignment.Left
    tL.Parent = hd
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -60, 0, 14)
    st.Position = UDim2.new(0, p, 0, 33)
    st.BackgroundTransparency = 1
    st.Text = window.Game .. " | " .. window.Version
    st.TextColor3 = Co.ts
    st.Font = Enum.Font.Gotham
    st.TextSize = 11
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = hd
    
    -- Close button
    local clBtn = Instance.new("TextButton")
    clBtn.Size = UDim2.new(0, 32, 0, 32)
    clBtn.Position = UDim2.new(1, -p-32, 0, 10)
    clBtn.BackgroundColor3 = Co.ch
    clBtn.Text = "×"
    clBtn.TextColor3 = Co.ts
    clBtn.Font = Enum.Font.GothamBold
    clBtn.TextSize = 20
    clBtn.Parent = hd
    
    Instance.new("UICorner", clBtn).CornerRadius = UDim.new(0, 10)
    
    clBtn.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.3)
        window:Destroy()
    end)
    
    -- Minimize button
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 32, 0, 32)
    cb.Position = UDim2.new(1, -p-70, 0, 10)
    cb.BackgroundColor3 = Co.ch
    cb.Text = "−"
    cb.TextColor3 = Co.ts
    cb.Font = Enum.Font.GothamBold
    cb.TextSize = 16
    cb.Parent = hd
    
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 10)
    
    local mn = false
    local fSz = m.Size
    
    cb.MouseButton1Click:Connect(function()
        playSound(Sounds.Minimize, 0.3)
        mn = not mn
        if mn then
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, w, 0, 52)}):Play()
            cb.Text = "□"
        else
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = fSz}):Play()
            cb.Text = "−"
        end
    end)
    
    -- Content area
    local cA = Instance.new("Frame")
    cA.Size = UDim2.new(1, 0, 1, -52)
    cA.Position = UDim2.new(0, 0, 0, 52)
    cA.BackgroundTransparency = 1
    cA.Parent = m
    
    -- Scroll container
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, -p*2, 1, -p*2)
    sc.Position = UDim2.new(0, p, 0, p)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 4
    sc.ScrollBarImageColor3 = Co.sc
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = cA
    
    local lY = Instance.new("UIListLayout")
    lY.Padding = UDim.new(0, 8)
    lY.SortOrder = Enum.SortOrder.LayoutOrder
    lY.Parent = sc
    
    -- Dragging
    local dS, sPos
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or 
           i.UserInputType == Enum.UserInputType.Touch then
            dS = i.Position
            sPos = m.Position
        end
    end)
    
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or 
           i.UserInputType == Enum.UserInputType.Touch then
            dS = nil
        end
    end)
    
    table.insert(window.Connections, U.InputChanged:Connect(function(i)
        if dS and (i.UserInputType == Enum.UserInputType.MouseMovement or 
                   i.UserInputType == Enum.UserInputType.Touch) then
            local dt = i.Position - dS
            m.Position = UDim2.new(
                sPos.X.Scale, sPos.X.Offset + dt.X,
                sPos.Y.Scale, sPos.Y.Offset + dt.Y
            )
        end
    end))
    
    -- Keybind toggle
    table.insert(window.Connections, U.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == window.Keybind then
            m.Visible = not m.Visible
        end
    end))
    
    -- Parent GUI
    pcall(function()
        g.Parent = game:GetService("CoreGui")
    end)
    
    if not g.Parent then
        g.Parent = L:WaitForChild("PlayerGui")
    end
    
    window.GUI = g
    window.MainFrame = m
    window.Container = sc
    window.Colors = Co
    window.ButtonHeight = bH
    window.FontSize = fS
    
    -- Mobile button
    if isMobile then
        local BUTTON_TRANSPARENCY = 0.10
        
        local mB = Instance.new("Frame")
        mB.Size = UDim2.new(0, 100, 0, 32)
        mB.Position = UDim2.new(0, 10, 0, 10)
        mB.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        mB.BackgroundTransparency = BUTTON_TRANSPARENCY
        mB.BorderSizePixel = 0
        mB.Parent = g
        
        Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 16)
        
        local mStroke = Instance.new("UIStroke", mB)
        mStroke.Color = Color3.fromRGB(60, 60, 70)
        mStroke.Thickness = 1.5
        mStroke.Transparency = 0.3
        
        local mI = Instance.new("ImageLabel")
        mI.Size = UDim2.new(0, 20, 0, 20)
        mI.Position = UDim2.new(0, 8, 0.5, -10)
        mI.BackgroundTransparency = 1
        mI.Image = "rbxassetid://114167695335193"
        mI.ImageColor3 = Color3.fromRGB(255, 255, 255)
        mI.Parent = mB
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, -36, 1, 0)
        btnText.Position = UDim2.new(0, 32, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = "Hide"
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnText.Font = Enum.Font.GothamBold
        btnText.TextSize = 15
        btnText.TextXAlignment = Enum.TextXAlignment.Center
        btnText.TextYAlignment = Enum.TextYAlignment.Center
        btnText.Parent = mB
        
        local mT = Instance.new("TextButton")
        mT.Size = UDim2.new(1, 0, 1, 0)
        mT.BackgroundTransparency = 1
        mT.Text = ""
        mT.Parent = mB
        
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local wasDragged = false
        
        mT.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mB.Position
                wasDragged = false
            end
        end)
        
        mT.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                
                if not wasDragged then
                    m.Visible = not m.Visible
                    
                    if m.Visible then
                        playSound(Sounds.Click, 0.5)
                        btnText.Text = "Hide"
                        mI.Image = "rbxassetid://114167695335193"
                    else
                        playSound(Sounds.Click, 0.4)
                        btnText.Text = "Show"
                        mI.Image = "rbxassetid://99334701468696"
                    end
                end
            end
        end)
        
        table.insert(window.Connections, U.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                    wasDragged = true
                end
                
                mB.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end))
        
        window.MobileButton = mB
    end
    
    -- Entrance animation
    m.Position = UDim2.new(1, 20, 0.5, -h/2)
    task.wait(0.1)
    T:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    }):Play()
    task.wait(0.3)
    playSound(Sounds.Success, 0.4)
    task.wait(0.2)
    window:ShowNotification("SynceHub " .. window.Version .. " loaded!", true)
    
    -- Add Tab function
    function window:AddTab(name)
        local tab = setmetatable({}, Tab)
        tab.Name = name
        tab.Window = self
        tab.Container = sc
        tab.MainFrame = m
        tab.Colors = Co
        tab.ButtonHeight = bH
        tab.FontSize = fS
        tab.OrderCount = 0
        tab.Config = self.Config
        
        return tab
    end
    
    return window
end

return SynceLib
