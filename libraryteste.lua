-- library_modernizada.lua
-- UI moderna para Alora (botões grandes, padding, fonte Gotham, espaçamento bonito)

local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local library = {
    flags = {},
    options = {},
    libColor = Color3.fromRGB(0,140,255)
}

-- Remove blur antigo
if Lighting:FindFirstChild("AloraBlur") then
    Lighting.AloraBlur:Destroy()
end
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "AloraBlur"
blurEffect.Size = 10
blurEffect.Parent = Lighting

-- Remove UI antiga
if CoreGui:FindFirstChild("sjorlib") then
    CoreGui.sjorlib:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "sjorlib"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Sombra
local shadow = Instance.new("Frame", gui)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.Size = UDim2.new(0, 540, 0, 480)
shadow.Position = UDim2.new(0.5, -270+5, 0.5, -240+5)
shadow.ZIndex = 0
local shadowCorner = Instance.new("UICorner", shadow)
shadowCorner.CornerRadius = UDim.new(0, 12)

-- MainFrame
local main = Instance.new("Frame", gui)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.Size = UDim2.new(0, 540, 0, 480)
main.Position = UDim2.new(0.5, -270, 0.5, -240)
main.ZIndex = 1
main.Active = true
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0,140,255)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.2

-- TitleBar
local titleBar = Instance.new("Frame", main)
titleBar.BackgroundColor3 = Color3.fromRGB(20,20,25)
titleBar.Size = UDim2.new(1,0,0,44)
titleBar.ZIndex = 2
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1,0,1,0)
titleLabel.Position = UDim2.new(0, 18, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Alora v1.2"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.BackgroundColor3 = Color3.fromRGB(35,35,40)
sidebar.Size = UDim2.new(0, 160, 1, -44)
sidebar.Position = UDim2.new(0, 0, 0, 44)
sidebar.ZIndex = 2
local sidebarCorner = Instance.new("UICorner", sidebar)
sidebarCorner.CornerRadius = UDim.new(0, 12)
local sidebarList = Instance.new("UIListLayout", sidebar)
sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
sidebarList.Padding = UDim.new(0, 10)
local sidebarPad = Instance.new("UIPadding", sidebar)
sidebarPad.PaddingTop = UDim.new(0, 16)
sidebarPad.PaddingLeft = UDim.new(0, 8)
sidebarPad.PaddingRight = UDim.new(0, 8)

-- Content
local content = Instance.new("Frame", main)
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, -170, 1, -54)
content.Position = UDim2.new(0, 170, 0, 54)
content.ZIndex = 2

-- Tabs
local tabs = {}
local currentTab = nil

function library:addTab(name)
    local tabBtn = Instance.new("TextButton", sidebar)
    tabBtn.Size = UDim2.new(1, 0, 0, 38)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 17
    tabBtn.TextColor3 = Color3.fromRGB(180,180,180)
    tabBtn.AutoButtonColor = false
    local tabBtnCorner = Instance.new("UICorner", tabBtn)
    tabBtnCorner.CornerRadius = UDim.new(0, 8)

    local tabPage = Instance.new("ScrollingFrame", content)
    tabPage.Size = UDim2.new(1,0,1,0)
    tabPage.BackgroundTransparency = 1
    tabPage.Visible = false
    tabPage.ScrollBarThickness = 8
    tabPage.CanvasSize = UDim2.new(0,0,0,0)
    tabPage.ZIndex = 2
    local tabPageList = Instance.new("UIListLayout", tabPage)
    tabPageList.SortOrder = Enum.SortOrder.LayoutOrder
    tabPageList.Padding = UDim.new(0, 18)
    local tabPagePad = Instance.new("UIPadding", tabPage)
    tabPagePad.PaddingTop = UDim.new(0, 18)
    tabPagePad.PaddingLeft = UDim.new(0, 8)
    tabPagePad.PaddingRight = UDim.new(0, 8)

    tabBtn.MouseButton1Click:Connect(function()
        for _,v in pairs(tabs) do
            v.btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
            v.btn.TextColor3 = Color3.fromRGB(180,180,180)
            v.page.Visible = false
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
        tabBtn.TextColor3 = Color3.fromRGB(255,255,255)
        tabPage.Visible = true
        currentTab = tabPage
    end)

    if not currentTab then
        tabBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
        tabBtn.TextColor3 = Color3.fromRGB(255,255,255)
        tabPage.Visible = true
        currentTab = tabPage
    end

    local tabObj = {btn = tabBtn, page = tabPage}
    table.insert(tabs, tabObj)

    function tabObj:createGroup(order)
        local group = Instance.new("Frame", tabPage)
        group.BackgroundColor3 = Color3.fromRGB(35,35,40)
        group.Size = UDim2.new(1, -8, 0, 0)
        group.AutomaticSize = Enum.AutomaticSize.Y
        group.LayoutOrder = order or 0
        local groupCorner = Instance.new("UICorner", group)
        groupCorner.CornerRadius = UDim.new(0, 8)
        local groupList = Instance.new("UIListLayout", group)
        groupList.SortOrder = Enum.SortOrder.LayoutOrder
        groupList.Padding = UDim.new(0, 10)
        local groupPad = Instance.new("UIPadding", group)
        groupPad.PaddingTop = UDim.new(0, 12)
        groupPad.PaddingLeft = UDim.new(0, 12)
        groupPad.PaddingRight = UDim.new(0, 12)
        groupPad.PaddingBottom = UDim.new(0, 12)

        -- Toggle
        function group:addToggle(args)
            local flag = args.flag or args.text
            library.flags[flag] = args.value or false
            local toggleBtn = Instance.new("TextButton", group)
            toggleBtn.Size = UDim2.new(1, 0, 0, 32)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            toggleBtn.Text = ""
            toggleBtn.AutoButtonColor = false
            local toggleCorner = Instance.new("UICorner", toggleBtn)
            toggleCorner.CornerRadius = UDim.new(0, 6)
            local box = Instance.new("Frame", toggleBtn)
            box.Size = UDim2.new(0, 22, 0, 22)
            box.Position = UDim2.new(0, 4, 0.5, -11)
            box.BackgroundColor3 = library.flags[flag] and library.libColor or Color3.fromRGB(30,30,30)
            local boxCorner = Instance.new("UICorner", box)
            boxCorner.CornerRadius = UDim.new(0, 5)
            local label = Instance.new("TextLabel", toggleBtn)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 34, 0, 0)
            label.Size = UDim2.new(1, -34, 1, 0)
            label.Font = Enum.Font.Gotham
            label.Text = args.text or flag
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left

            local function update(val)
                library.flags[flag] = val
                box.BackgroundColor3 = val and library.libColor or Color3.fromRGB(30,30,30)
                if args.callback then pcall(args.callback, val) end
            end

            toggleBtn.MouseButton1Click:Connect(function()
                update(not library.flags[flag])
            end)

            library.options[flag] = {type="toggle",changeState=update,skipflag=args.skipflag,oldargs=args}
            return toggleBtn
        end

        -- Button
        function group:addButton(args)
            local btn = Instance.new("TextButton", group)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(0,140,255)
            btn.Text = args.text or "Button"
            btn.Font = Enum.Font.GothamBold
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.TextSize = 16
            btn.AutoButtonColor = true
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                if args.callback then pcall(args.callback) end
            end)
            return btn
        end

        -- Slider
        function group:addSlider(args)
            local flag = args.flag
            library.flags[flag] = args.value or args.min or 0
            local sliderFrame = Instance.new("Frame", group)
            sliderFrame.Size = UDim2.new(1, 0, 0, 38)
            sliderFrame.BackgroundTransparency = 1
            local label = Instance.new("TextLabel", sliderFrame)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 0, 0, 0)
            label.Size = UDim2.new(1, 0, 0, 18)
            label.Font = Enum.Font.Gotham
            label.Text = (args.text or flag) .. ": " .. tostring(library.flags[flag])
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left
            local barBG = Instance.new("Frame", sliderFrame)
            barBG.BackgroundColor3 = Color3.fromRGB(40,40,45)
            barBG.Position = UDim2.new(0,0,0,22)
            barBG.Size = UDim2.new(1, 0, 0, 10)
            local barCorner = Instance.new("UICorner", barBG)
            barCorner.CornerRadius = UDim.new(1,0)
            local barFill = Instance.new("Frame", barBG)
            barFill.BackgroundColor3 = library.libColor
            barFill.Size = UDim2.new((library.flags[flag]-args.min)/(args.max-args.min),0,1,0)
            local fillCorner = Instance.new("UICorner", barFill)
            fillCorner.CornerRadius = UDim.new(1,0)
            local dragging = false
            barBG.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local x = math.clamp((UserInputService:GetMouseLocation().X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
                    local value = args.min + x * (args.max - args.min)
                    value = math.floor(value)
                    library.flags[flag] = value
                    barFill.Size = UDim2.new(x, 0, 1, 0)
                    label.Text = (args.text or flag) .. ": " .. tostring(value)
                    if args.callback then pcall(args.callback, value) end
                end
            end)
            library.options[flag] = {type="slider",changeState=function(v)
                library.flags[flag] = v
                local x = (v-args.min)/(args.max-args.min)
                barFill.Size = UDim2.new(x,0,1,0)
                label.Text = (args.text or flag) .. ": " .. tostring(v)
            end,skipflag=args.skipflag,oldargs=args}
            return sliderFrame
        end

        -- List
        function group:addList(args)
            local flag = args.flag
            library.flags[flag] = args.value or args.values[1]
            local btn = Instance.new("TextButton", group)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            btn.Text = (args.text or flag) .. ": " .. tostring(library.flags[flag])
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.TextSize = 16
            btn.AutoButtonColor = false
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                local menu = Instance.new("Frame", gui)
                menu.BackgroundColor3 = Color3.fromRGB(35,35,40)
                menu.Size = UDim2.new(0, 180, 0, #args.values*32+8)
                menu.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y+btn.AbsoluteSize.Y)
                menu.ZIndex = 100
                local menuCorner = Instance.new("UICorner", menu)
                menuCorner.CornerRadius = UDim.new(0, 8)
                for i,v in ipairs(args.values) do
                    local opt = Instance.new("TextButton", menu)
                    opt.Size = UDim2.new(1, -8, 0, 28)
                    opt.Position = UDim2.new(0, 4, 0, 4+(i-1)*32)
                    opt.BackgroundColor3 = Color3.fromRGB(40,40,45)
                    opt.Text = v
                    opt.Font = Enum.Font.Gotham
                    opt.TextColor3 = Color3.fromRGB(255,255,255)
                    opt.TextSize = 15
                    opt.AutoButtonColor = true
                    local optCorner = Instance.new("UICorner", opt)
                    optCorner.CornerRadius = UDim.new(0, 6)
                    opt.MouseButton1Click:Connect(function()
                        library.flags[flag] = v
                        btn.Text = (args.text or flag) .. ": " .. tostring(v)
                        if args.callback then pcall(args.callback, v) end
                        menu:Destroy()
                    end)
                end
                menu.MouseLeave:Connect(function() menu:Destroy() end)
            end)
            library.options[flag] = {type="list",changeState=function(v)
                library.flags[flag] = v
                btn.Text = (args.text or flag) .. ": " .. tostring(v)
            end,values=args.values,skipflag=args.skipflag,oldargs=args}
            return btn
        end

        -- Colorpicker (simples)
        function group:addColorpicker(args)
            local flag = args.flag
            library.flags[flag] = args.color or Color3.new(1,1,1)
            local btn = Instance.new("TextButton", group)
            btn.Size = UDim2.new(0, 38, 0, 32)
            btn.BackgroundColor3 = library.flags[flag]
            btn.Text = ""
            btn.AutoButtonColor = false
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                -- Simples: alterna entre algumas cores
                local c = library.flags[flag]
                if c == Color3.new(1,1,1) then
                    c = Color3.fromRGB(0,140,255)
                elseif c == Color3.fromRGB(0,140,255) then
                    c = Color3.fromRGB(255,0,0)
                else
                    c = Color3.new(1,1,1)
                end
                library.flags[flag] = c
                btn.BackgroundColor3 = c
                if args.callback then pcall(args.callback, c) end
            end)
            library.options[flag] = {type="colorpicker",changeState=function(v)
                library.flags[flag] = v
                btn.BackgroundColor3 = v
            end,skipflag=args.skipflag,oldargs=args}
            return btn
        end

        -- Textbox
        function group:addTextbox(args)
            local flag = args.flag
            library.flags[flag] = ""
            local box = Instance.new("TextBox", group)
            box.Size = UDim2.new(1, 0, 0, 32)
            box.BackgroundColor3 = Color3.fromRGB(40,40,45)
            box.Text = args.text or ""
            box.Font = Enum.Font.Gotham
            box.TextColor3 = Color3.fromRGB(255,255,255)
            box.TextSize = 16
            box.ClearTextOnFocus = false
            local boxCorner = Instance.new("UICorner", box)
            boxCorner.CornerRadius = UDim.new(0, 6)
            box.FocusLost:Connect(function()
                library.flags[flag] = box.Text
                if args.callback then pcall(args.callback, box.Text) end
            end)
            library.options[flag] = {type="textbox",changeState=function(v) box.Text = v end,skipflag=args.skipflag,oldargs=args}
            return box
        end

        -- Keybind (simples)
        function group:addKeybind(args)
            local flag = args.flag
            library.flags[flag] = args.key or Enum.KeyCode.Unknown
            local btn = Instance.new("TextButton", group)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            btn.Text = (args.text or flag) .. ": [" .. (library.flags[flag].Name or "None") .. "]"
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.TextSize = 16
            btn.AutoButtonColor = false
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            local listening = false
            btn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                btn.Text = (args.text or flag) .. ": [Press Key]"
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        library.flags[flag] = input.KeyCode
                        btn.Text = (args.text or flag) .. ": [" .. input.KeyCode.Name .. "]"
                        listening = false
                        if conn then conn:Disconnect() end
                        if args.callback then pcall(args.callback, input.KeyCode) end
                    end
                end)
            end)
            library.options[flag] = {type="keybind",changeState=function(v)
                library.flags[flag] = v
                btn.Text = (args.text or flag) .. ": [" .. (v.Name or "None") .. "]"
            end,skipflag=args.skipflag,oldargs=args}
            return btn
        end

        -- Divider
        function group:addDivider()
            local div = Instance.new("Frame", group)
            div.BackgroundColor3 = Color3.fromRGB(30,30,30)
            div.Size = UDim2.new(1,0,0,2)
            return div
        end

        return group
    end

    return tabObj
end

-- Unload
function library:unload()
    if Lighting:FindFirstChild("AloraBlur") then Lighting.AloraBlur:Destroy() end
    if CoreGui:FindFirstChild("sjorlib") then CoreGui.sjorlib:Destroy() end
end

return library, gui, content
