-- Single File Version - Script Loader (FIXED VERSION)
-- รันไฟล์เดียวใน Executor ได้เลย ไม่ต้องใช้ GitHub
-- แก้ไขการดึงรูปภาพให้ใช้ Direct URL แทน Thumbnail API

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- ========================================
-- CONFIGURATION - แก้ไขตรงนี้
-- ========================================

local MAPS_CONFIG = {
    {
        placeId = 1537690962,
        status = "Working • Updated 2025",
        statusColor = Color3.fromRGB(96, 211, 148),
        scriptUrl = "https://raw.githubusercontent.com/example/script1.lua",
        buttonColor = Color3.fromRGB(96, 211, 148)
    },
    {
        placeId = 142823291,
        status = "Working • Premium",
        statusColor = Color3.fromRGB(96, 211, 148),
        scriptUrl = "https://raw.githubusercontent.com/example/script2.lua",
        buttonColor = Color3.fromRGB(96, 211, 148)
    },
    {
        placeId = 606849621,
        status = "Working • Fast",
        statusColor = Color3.fromRGB(96, 211, 148),
        scriptUrl = "https://raw.githubusercontent.com/example/script3.lua",
        buttonColor = Color3.fromRGB(96, 211, 148)
    },
    {
        placeId = 292439477,
        status = "Patched • Not Working",
        statusColor = Color3.fromRGB(220, 88, 88),
        scriptUrl = "",
        buttonColor = Color3.fromRGB(220, 88, 88)
    },
}

local UI_CONFIG = {
    BackgroundColor = Color3.fromRGB(16, 18, 26),
    PanelColor = Color3.fromRGB(31, 35, 48),
    AccentColor = Color3.fromRGB(96, 211, 148),
    WarningColor = Color3.fromRGB(255, 193, 7),
    ErrorColor = Color3.fromRGB(220, 88, 88),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 170, 190),
    CardHeight = 90,
    CardSpacing = 12,
    CornerRadius = 12,
}

-- ========================================
-- LOADER CONTROLLER
-- ========================================

local LoaderController = {}
LoaderController.__index = LoaderController

function LoaderController.new()
    local self = setmetatable({}, LoaderController)
    self.placeCache = {}
    self.activeNotifications = {}
    return self
end

function LoaderController:FetchPlaceInfo(placeId)
    if self.placeCache[placeId] then
        return self.placeCache[placeId]
    end
    
    local success, result = pcall(function()
        local detailsUrl = "https://games.roblox.com/v1/games/multiget-place-details?placeIds=" .. tostring(placeId)
        local detailsResponse = game:HttpGet(detailsUrl)
        local detailsData = HttpService:JSONDecode(detailsResponse)
        
        if not detailsData or #detailsData == 0 then
            return nil
        end
        
        local place = detailsData[1]
        local placeName = place.name
        
        local imageUrl = "https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid=" .. tostring(placeId) .. "&fmt=png&wd=420&ht=420"
        
        return {
            name = placeName,
            thumbnailUrl = imageUrl,
            description = place.description or "",
            creator = place.builder or "Unknown"
        }
    end)
    
    if success and result then
        self.placeCache[placeId] = result
        return result
    else
        return {
            name = "Place #" .. tostring(placeId),
            thumbnailUrl = "https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid=" .. tostring(placeId) .. "&fmt=png&wd=420&ht=420",
            description = "Failed to load info",
            creator = "Unknown"
        }
    end
end

function LoaderController:CreateNotification(text, color)
    local ScreenGui = self.ScreenGui
    
    local iconMap = {
        ["✓"] = "rbxassetid://12817454402",
        ["❌"] = "rbxassetid://6790887263",
        ["⏳"] = "rbxassetid://6846329320",
        ["⚙️"] = "rbxassetid://7059346373",
        ["📢"] = "rbxassetid://4458855809",
        ["⚠️"] = "rbxassetid://6068827451",
    }
    
    local iconPrefix = text:match("^[✓❌⏳⚙️📢⚠️]")
    local iconAsset = iconMap[iconPrefix] or "rbxassetid://4458855809"
    local shouldRotate = (iconPrefix == "⏳" or iconPrefix == "⚙️")
    
    local notificationHeight = 70
    local notificationSpacing = 10
    local baseOffset = 90
    
    local yOffset = baseOffset
    for i = #self.activeNotifications, 1, -1 do
        if self.activeNotifications[i] and self.activeNotifications[i].Parent then
            yOffset = yOffset + notificationHeight + notificationSpacing
        else
            table.remove(self.activeNotifications, i)
        end
    end
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 320, 0, notificationHeight)
    Notification.Position = UDim2.new(1, 0, 1, -yOffset)
    Notification.BackgroundColor3 = color or UI_CONFIG.AccentColor
    Notification.BackgroundTransparency = 0.15
    Notification.BorderSizePixel = 0
    Notification.ZIndex = 10
    Notification.Parent = ScreenGui
    
    table.insert(self.activeNotifications, Notification)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Notification
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color or UI_CONFIG.AccentColor
    Stroke.Transparency = 0.5
    Stroke.Thickness = 2
    Stroke.Parent = Notification
    
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.new(0, 46, 0, 46)
    IconFrame.Position = UDim2.new(0, 12, 0.5, -23)
    IconFrame.BackgroundColor3 = color or UI_CONFIG.AccentColor
    IconFrame.BackgroundTransparency = 0.7
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = Notification
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = IconFrame
    
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 28, 0, 28)
    Icon.Position = UDim2.new(0.5, -14, 0.5, -14)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconAsset
    Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.Parent = IconFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -75, 1, -10)
    Label.Position = UDim2.new(0, 65, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text:gsub("^[✓❌]%s*", "")
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.TextWrapped = true
    Label.Parent = Notification
    
    TweenService:Create(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -330, 1, -yOffset)
    }):Play()
    
    if shouldRotate then
        local rotationTween = TweenService:Create(Icon, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
            Rotation = 360
        })
        rotationTween:Play()
    else
        TweenService:Create(IconFrame, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Rotation = 360
        }):Play()
    end
    
    task.delay(3.5, function()
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 1, -yOffset)
        }):Play()
        task.wait(0.3)
        Notification:Destroy()
        
        for i, notif in ipairs(self.activeNotifications) do
            if notif == Notification then
                table.remove(self.activeNotifications, i)
                break
            end
        end
        
        self:RepositionNotifications()
    end)
end

function LoaderController:RepositionNotifications()
    local notificationHeight = 70
    local notificationSpacing = 10
    local baseOffset = 90
    
    for i = #self.activeNotifications, 1, -1 do
        if not self.activeNotifications[i] or not self.activeNotifications[i].Parent then
            table.remove(self.activeNotifications, i)
        end
    end
    
    for i, notif in ipairs(self.activeNotifications) do
        local newYOffset = baseOffset + ((i - 1) * (notificationHeight + notificationSpacing))
        
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -330, 1, -newYOffset)
        }):Play()
    end
end

function LoaderController:LoadScript(mapData)
    if mapData.scriptUrl == "" or not mapData.scriptUrl then
        self:CreateNotification("❌ Script not available!", UI_CONFIG.ErrorColor)
        return
    end
    
    self:CreateNotification("⏳ Loading " .. mapData.name .. "...", UI_CONFIG.WarningColor)
    
    task.wait(0.5)
    
    local success, result = pcall(function()
        local scriptContent = game:HttpGet(mapData.scriptUrl)
        return loadstring(scriptContent)
    end)
    
    if success and result then
        self:CreateNotification("⚙️ Executing " .. mapData.name .. "...", UI_CONFIG.WarningColor)
        
        local executeSuccess, executeError = pcall(result)
        if executeSuccess then
            self:CreateNotification("✓ " .. mapData.name .. " loaded!", UI_CONFIG.AccentColor)
        else
            self:CreateNotification("❌ Execution error!", UI_CONFIG.ErrorColor)
            warn("Execution error:", executeError)
        end
    else
        self:CreateNotification("❌ Failed to load script!", UI_CONFIG.ErrorColor)
        warn("Load error:", result)
    end
end

function LoaderController:CreateMapCard(mapData, parent, index)
    local placeInfo = self:FetchPlaceInfo(mapData.placeId)
    
    local Card = Instance.new("Frame")
    Card.Name = "Card_" .. index
    Card.Size = UDim2.new(1, -24, 0, UI_CONFIG.CardHeight)
    Card.BackgroundColor3 = UI_CONFIG.PanelColor
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = false
    Card.Parent = parent
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, UI_CONFIG.CornerRadius)
    CardCorner.Parent = Card
    
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(255, 255, 255)
    CardStroke.Transparency = 0.95
    CardStroke.Thickness = 1
    CardStroke.Parent = Card
    
    local CardPadding = Instance.new("UIPadding")
    CardPadding.PaddingLeft = UDim.new(0, 12)
    CardPadding.PaddingRight = UDim.new(0, 12)
    CardPadding.PaddingTop = UDim.new(0, 12)
    CardPadding.PaddingBottom = UDim.new(0, 12)
    CardPadding.Parent = Card
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = Card
    
    local Thumbnail = Instance.new("ImageLabel")
    Thumbnail.Name = "Thumbnail"
    Thumbnail.Size = UDim2.new(0, 66, 0, 66)
    Thumbnail.Position = UDim2.new(0, 0, 0, 0)
    Thumbnail.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    Thumbnail.BorderSizePixel = 0
    Thumbnail.Image = placeInfo.thumbnailUrl
    Thumbnail.ScaleType = Enum.ScaleType.Crop
    Thumbnail.Parent = Card
    
    local ThumbCorner = Instance.new("UICorner")
    ThumbCorner.CornerRadius = UDim.new(0, 8)
    ThumbCorner.Parent = Thumbnail
    
    local ThumbStroke = Instance.new("UIStroke")
    ThumbStroke.Color = Color3.fromRGB(255, 255, 255)
    ThumbStroke.Transparency = 0.92
    ThumbStroke.Thickness = 1
    ThumbStroke.Parent = Thumbnail
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -190, 0, 24)
    Title.Position = UDim2.new(0, 78, 0, 4)
    Title.BackgroundTransparency = 1
    Title.Text = placeInfo.name
    Title.TextColor3 = UI_CONFIG.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Top
    Title.TextScaled = true
    Title.Parent = Card
    
    local TitleTextSize = Instance.new("UITextSizeConstraint")
    TitleTextSize.MaxTextSize = 16
    TitleTextSize.MinTextSize = 10
    TitleTextSize.Parent = Title
    
    mapData.name = placeInfo.name
    
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -190, 0, 18)
    Status.Position = UDim2.new(0, 78, 0, 30)
    Status.BackgroundTransparency = 1
    Status.Text = mapData.status
    Status.TextColor3 = mapData.statusColor or UI_CONFIG.TextSecondary
    Status.Font = Enum.Font.GothamMedium
    Status.TextSize = 12
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextYAlignment = Enum.TextYAlignment.Top
    Status.Parent = Card
    
    local LoadButton = Instance.new("TextButton")
    LoadButton.Name = "LoadButton"
    LoadButton.Size = UDim2.new(0, 100, 0, 36)
    LoadButton.Position = UDim2.new(1, -100, 0.5, -18)
    LoadButton.BackgroundColor3 = mapData.buttonColor
    LoadButton.BorderSizePixel = 0
    LoadButton.Text = "LOAD"
    LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadButton.Font = Enum.Font.GothamBold
    LoadButton.TextSize = 14
    LoadButton.AutoButtonColor = false
    LoadButton.Parent = Card
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = LoadButton
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = mapData.buttonColor
    ButtonStroke.Transparency = 0.7
    ButtonStroke.Thickness = 1
    ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ButtonStroke.Parent = LoadButton
    
    LoadButton.MouseEnter:Connect(function()
        local brighterColor = Color3.fromRGB(
            math.min(255, mapData.buttonColor.R * 255 + 30),
            math.min(255, mapData.buttonColor.G * 255 + 30),
            math.min(255, mapData.buttonColor.B * 255 + 30)
        )
        
        TweenService:Create(LoadButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 105, 0, 38),
            BackgroundColor3 = brighterColor
        }):Play()
        
        TweenService:Create(ButtonStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Transparency = 0.3
        }):Play()
        
        TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(38, 42, 58)
        }):Play()
    end)
    
    LoadButton.MouseLeave:Connect(function()
        TweenService:Create(LoadButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 100, 0, 36),
            BackgroundColor3 = mapData.buttonColor
        }):Play()
        
        TweenService:Create(ButtonStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Transparency = 0.7
        }):Play()
        
        TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = UI_CONFIG.PanelColor
        }):Play()
    end)
    
    LoadButton.MouseButton1Down:Connect(function()
        TweenService:Create(LoadButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 98, 0, 34)
        }):Play()
    end)
    
    LoadButton.MouseButton1Up:Connect(function()
        TweenService:Create(LoadButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 105, 0, 38)
        }):Play()
    end)
    
    LoadButton.MouseButton1Click:Connect(function()
        self:LoadScript(mapData)
    end)
    
    Card.BackgroundTransparency = 1
    local descendants = Card:GetDescendants()
    for _, child in pairs(descendants) do
        if child:IsA("GuiObject") then
            child.BackgroundTransparency = 1
        end
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextTransparency = 1
        end
        if child:IsA("ImageLabel") then
            child.ImageTransparency = 1
        end
        if child:IsA("UIStroke") then
            child.Transparency = 1
        end
    end
    
    task.delay(index * 0.05, function()
        TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        }):Play()
        
        for _, child in pairs(descendants) do
            local targetTransparency = 0
            
            if child:IsA("GuiObject") and child.Name ~= "Shadow" and child.Name ~= "Thumbnail" then
                if child.Name == "LoadButton" then
                    targetTransparency = 0
                else
                    targetTransparency = 1
                end
            elseif child:IsA("ImageLabel") and child.Name == "Shadow" then
                targetTransparency = 0.7
            elseif child:IsA("ImageLabel") and child.Name == "Thumbnail" then
                targetTransparency = 0
            elseif child:IsA("UIStroke") then
                if child.Parent.Name == "Thumbnail" then
                    targetTransparency = 0.92
                else
                    targetTransparency = 0.95
                end
            end
            
            if child:IsA("GuiObject") then
                TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = targetTransparency
                }):Play()
            end
            
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextTransparency = 0
                }):Play()
            end
            
            if child:IsA("ImageLabel") then
                TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    ImageTransparency = targetTransparency
                }):Play()
            end
            
            if child:IsA("UIStroke") then
                TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Transparency = targetTransparency
                }):Play()
            end
        end
        
        if index == #MAPS_CONFIG then
            task.wait(0.5)
            local parent = Card.Parent
            if parent and parent:IsA("ScrollingFrame") then
                local layout = parent:FindFirstChildOfClass("UIListLayout")
                if layout then
                    parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 225)
                end
            end
        end
    end)
end

function LoaderController:CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TadHubLoaderGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui
    
    self.ScreenGui = ScreenGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -187, 0.5, -197)
    MainFrame.BackgroundColor3 = UI_CONFIG.BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.93
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    local UIScale = Instance.new("UIScale")
    UIScale.Parent = MainFrame
    
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        UIScale.Scale = 0.7
        MainFrame.Size = UDim2.new(0, 600, 0, 480)
        MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
    end
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "Tad Hub Loader"
    Title.TextColor3 = UI_CONFIG.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -40, 0, 15)
    Subtitle.Position = UDim2.new(0, 20, 0, 40)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Select and load your scripts"
    Subtitle.TextColor3 = UI_CONFIG.TextSecondary
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -50, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 88, 88)
    CloseButton.BackgroundTransparency = 0.9
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = UI_CONFIG.TextPrimary
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.7
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.9
        }):Play()
    end)
    
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Size = UDim2.new(1, -24, 1, -80)
    ScrollFrame.Position = UDim2.new(0, 12, 0, 68)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = UI_CONFIG.AccentColor
    ScrollFrame.ScrollBarImageTransparency = 0.3
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.ScrollingEnabled = true
    ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ScrollFrame.Active = true
    ScrollFrame.ClipsDescendants = true
    ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    ScrollFrame.ZIndex = 2
    ScrollFrame.Parent = MainFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, UI_CONFIG.CardSpacing)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ScrollFrame
    
    local function updateCanvasSize()
        local contentHeight = ListLayout.AbsoluteContentSize.Y
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 225)
    end
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    
    task.wait(0.1)
    updateCanvasSize()
    
    for index, mapData in ipairs(MAPS_CONFIG) do
        self:CreateMapCard(mapData, ScrollFrame, index)
    end
    
    task.wait(0.2)
    local contentHeight = ListLayout.AbsoluteContentSize.Y
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 225)
    
    local dragging = false
    local dragInput, mousePos, framePos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            MainFrame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local targetSize = UDim2.new(0, 650, 0, 520)
    local targetPos = UDim2.new(0.5, -325, 0.5, -260)
    
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        targetSize = UDim2.new(0, 600, 0, 480)
        targetPos = UDim2.new(0.5, -300, 0.5, -240)
    end
    
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPos
    }):Play()
end

function LoaderController:Init()
    self:CreateGUI()
end

local loader = LoaderController.new()
loader:Init()

print("✓ Script Loader initialized!")
