loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local VoraLib = {}
local Connections = {}


local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = TweenService:Create(object, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = pos})
		Tween:Play()
	end

	table.insert(Connections, topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					if connection then connection:Disconnect() end
				end
			end)
		end
	end))

	table.insert(Connections, topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end))

	table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end))
end

local function Create(className, properties)
	local instance = Instance.new(className)
	for k, v in pairs(properties) do
		instance[k] = v
	end
	return instance
end


local Theme = {
	Background = Color3.fromRGB(10, 12, 25), 
	Sidebar = Color3.fromRGB(15, 18, 32),
	ElementBackground = Color3.fromRGB(25, 30, 50),
	TextColor = Color3.fromRGB(255, 255, 255), 
	TextSecondary = Color3.fromRGB(180, 200, 230), 
	Accent = Color3.fromRGB(0, 190, 255), 
	Hover = Color3.fromRGB(35, 45, 70),
	Outline = Color3.fromRGB(40, 60, 90)
}


function VoraLib:CreateWindow(options)
    
	options = options or {}
	local TitleName = options.Name or "Vora Hub"
	local IntroEnabled = options.Intro or false
	
	
	local function GetParent()
		local Success, Parent = pcall(function()
			return (gethui and gethui()) or game:GetService("CoreGui")
		end)
		
		if not Success or not Parent then
			return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
		
		return Parent
	end

	local ScreenGui = Create("ScreenGui", {
		Name = "VoraHub",
		Parent = GetParent(),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	
	local ViewportSize = workspace.CurrentCamera.ViewportSize
	local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
	local InitialSize = IsMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 700, 0, 450)
	local InitialPosition = IsMobile and UDim2.new(0.5, -250, 0.5, -160) or UDim2.new(0.5, -350, 0.5, -225)
	
	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 0.05, 
		BorderSizePixel = 0,
		Position = InitialPosition,
		Size = InitialSize,
		ClipsDescendants = true
	})
	
	Create("UICorner", {
		CornerRadius = UDim.new(0, 10), 
		Parent = MainFrame
	})
	
	
	local MainStroke = Create("UIStroke", {
		Transparency = 0,
		Thickness = 1,
		Parent = MainFrame
	})
	
	Create("UIGradient", {
		Parent = MainStroke,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 190, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 18, 32))
		},
		Rotation = 45
	})

	
	local Header = Create("Frame", {
		Name = "Header",
		Parent = MainFrame,
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 45) 
	})
	
	Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = Header
	})
	
	
	Create("Frame", {
		Name = "BottomFiller",
		Parent = Header,
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
		ZIndex = 1
	})
	
	
	Create("Frame", {
		Parent = Header,
		BackgroundColor3 = Theme.Outline,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2
	})

	
	local Logo = Create("ImageLabel", {
		Name = "Logo",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 5),
		Size = UDim2.new(0, 35, 0, 35),
		Image = "rbxassetid://109951475872006",
		ImageColor3 = Theme.Accent,
		ZIndex = 2
	})

	
	local TitleLabel = Create("TextLabel", {
		Name = "Title",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 70, 0, 0),
		Size = UDim2.new(1, -160, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = TitleName,
		TextColor3 = Theme.TextColor,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2
	})
	
	
	if IntroEnabled then
		local StartSize = MainFrame.Size
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		MainFrame.BackgroundTransparency = 1
		
		TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = StartSize,
			BackgroundTransparency = 0.05
		}):Play()
	end
	
	
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = MainFrame,
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 45),
		Size = UDim2.new(0, 180, 1, -45)
	})
	
	
	Create("Frame", {
		Name = "Separator",
		Parent = Sidebar,
		BackgroundColor3 = Theme.Outline,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -2, 0, 0),
		Size = UDim2.new(0, 2, 1, 0)
	})

	
	local Controls = Create("Frame", {
		Name = "Controls",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -100, 0, 0),
		Size = UDim2.new(0, 100, 1, 0),
		ZIndex = 2
	})
	
	local UIListLayout = Create("UIListLayout", {
		Parent = Controls,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8)
	})
	
	Create("UIPadding", {
		Parent = Controls,
		PaddingRight = UDim.new(0, 15)
	})

	local IsMinimized = false
	local ToggleButton = Create("ImageButton", {
		Name = "ToggleUI",
		Parent = ScreenGui,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0.1, 0, 0.1, 0),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "rbxassetid://136076032343357", 
		ImageColor3 = Theme.TextColor,
		Visible = true, 
		Active = true,
		Draggable = true,
		ZIndex = 100
	})
	
	Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = ToggleButton
	})
	
	Create("UIStroke", {
		Color = Theme.Outline,
		Thickness = 1,
		Parent = ToggleButton
	})

	local function ToggleUI()
		IsMinimized = not IsMinimized
		
		if IsMinimized then
			MainFrame.Visible = false
		else
			MainFrame.Visible = true

			local OriginalSize = IsMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 700, 0, 450)
			MainFrame.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = OriginalSize
			}):Play()
		end
	end
	
	ToggleButton.MouseButton1Click:Connect(ToggleUI)

	local function CreateControlButton(name, icon, layoutOrder, callback)
		local Button = Create("ImageButton", {
			Name = name,
			Parent = Controls,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Size = UDim2.new(0, 20, 0, 20),
			Image = "rbxassetid://" .. icon,
			ImageColor3 = Theme.TextSecondary,
			AutoButtonColor = false
		})
		
		Button.MouseEnter:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.2), {ImageColor3 = Theme.TextColor}):Play()
		end)
		
		Button.MouseLeave:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.2), {ImageColor3 = Theme.TextSecondary}):Play()
		end)
		
		Button.MouseButton1Click:Connect(callback)
		return Button
	end

	CreateControlButton("Minimize", "71686683787518", 1, ToggleUI)

	
	local Window = {
		Tabs = {},
		Instance = ScreenGui
	}

	
	local NotificationHolder = Create("Frame", {
		Name = "NotificationHolder",
		Parent = ScreenGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 300, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		ZIndex = 100
	})

	Create("UIListLayout", {
		Parent = NotificationHolder,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10)
	})

	function Window:Notify(options)
		options = options or {}
		local Title = options.Title or "Notification"
		local Content = options.Content or "Message"
		local Duration = options.Duration or 3
		local Image = options.Image or "rbxassetid://109951475872006"

		local NotifyFrame = Create("Frame", {
			Name = "NotifyFrame",
			Parent = NotificationHolder,
			BackgroundColor3 = Theme.Sidebar,
			BackgroundTransparency = 0.1,
			Size = UDim2.new(1, 0, 0, 0), 
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true
		})

		Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = NotifyFrame })
		Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = NotifyFrame })

		local ContentFrame = Create("Frame", {
			Parent = NotifyFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 60)
		})

		local Icon = Create("ImageLabel", {
			Parent = ContentFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 12),
			Size = UDim2.new(0, 36, 0, 36),
			Image = Image,
			ImageColor3 = Theme.Accent
		})
		
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Icon })

		local TitleLabel = Create("TextLabel", {
			Parent = ContentFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 58, 0, 10),
			Size = UDim2.new(1, -68, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = Title,
			TextColor3 = Theme.TextColor,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local ContentLabel = Create("TextLabel", {
			Parent = ContentFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 58, 0, 30),
			Size = UDim2.new(1, -68, 0, 20),
			Font = Enum.Font.Gotham,
			Text = Content,
			TextColor3 = Theme.TextSecondary,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true
		})
		
		
		NotifyFrame.Position = UDim2.new(1, 320, 0, 0)
		TweenService:Create(NotifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		
		
		local ProgressBar = Create("Frame", {
			Parent = NotifyFrame,
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -2),
			Size = UDim2.new(1, 0, 0, 2)
		})
		
		TweenService:Create(ProgressBar, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

		task.delay(Duration, function()
			TweenService:Create(NotifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 320, 0, 0)}):Play()
			task.wait(0.5)
			NotifyFrame:Destroy()
		end)
	end

	
	local Maximized = false
	local DefaultSize = IsMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 700, 0, 450)
	local MaxSize = IsMobile and UDim2.new(0, 600, 0, 350) or UDim2.new(0, 900, 0, 600)
	local DefaultPos = IsMobile and UDim2.new(0.5, -250, 0.5, -160) or UDim2.new(0.5, -350, 0.5, -225)
	local MaxPos = IsMobile and UDim2.new(0.5, -300, 0.5, -175) or UDim2.new(0.5, -450, 0.5, -300)
	
	CreateControlButton("Maximize", "135582116755237", 2, function()
		Maximized = not Maximized
		if Maximized then
			TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = MaxSize,
				Position = MaxPos
			}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = DefaultSize,
				Position = DefaultPos
			}):Play()
		end
	end)

	CreateControlButton("Close", "121948938505669", 3, function()
		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.3)
		Window:Destroy()
	end)
	
	local ToggleKey = Enum.KeyCode.RightControl
	table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == ToggleKey then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end))

	
	local TabContainer = Create("ScrollingFrame", {
		Name = "TabContainer",
		Parent = Sidebar,
		Active = true,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 15),
		Size = UDim2.new(1, 0, 1, -25),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent
	})
	
	local ButtonsHolder = Create("Frame", {
		Name = "ButtonsHolder",
		Parent = TabContainer,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.Y
	})
	
	Create("UIListLayout", {
		Parent = ButtonsHolder,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})
	
	Create("UIPadding", {
		Parent = ButtonsHolder,
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10)
	})
	
	local SlidingIndicator = Create("Frame", {
		Name = "SlidingIndicator",
		Parent = TabContainer,
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 3, 0, 20),
		Visible = false,
		ZIndex = 2
	})

	Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = SlidingIndicator
	})

	
	local ContentContainer = Create("Frame", {
		Name = "ContentContainer",
		Parent = MainFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 180, 0, 45),
		Size = UDim2.new(1, -180, 1, -45)
	})

	MakeDraggable(Header, MainFrame)

	function Window:CreateTab(options)
		options = options or {}
		local TabName = options.Name or "Tab"
		local TabIcon = options.Icon or ""
		
		local Tab = {
			Active = false
		}
		
		local TabButton = Create("TextButton", {
			Name = TabName .. "Button",
			Parent = ButtonsHolder,
			BackgroundColor3 = Theme.ElementBackground,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 36),
			AutoButtonColor = false,
			ClipsDescendants = true,
			Text = ""
		})
		
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Parent = TabButton
		})
		
		local IconImage
		if TabIcon ~= "" then
			IconImage = Create("ImageLabel", {
				Parent = TabButton,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = TabIcon,
				ImageColor3 = Theme.TextSecondary
			})
		end
		
		local TabLabel = Create("TextLabel", {
			Parent = TabButton,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, TabIcon ~= "" and 40 or 15, 0, 0),
			Size = UDim2.new(1, TabIcon ~= "" and -40 or -15, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = TabName,
			TextColor3 = Theme.TextSecondary,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		TabButton.MouseEnter:Connect(function()
			if not Tab.Active then
				TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
				TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextColor}):Play()
				if IconImage then
					TweenService:Create(IconImage, TweenInfo.new(0.2), {ImageColor3 = Theme.TextColor}):Play()
				end
			end
		end)
		
		TabButton.MouseLeave:Connect(function()
			if not Tab.Active then
				TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
				if IconImage then
					TweenService:Create(IconImage, TweenInfo.new(0.2), {ImageColor3 = Theme.TextSecondary}):Play()
				end
			end
		end)
		
		local TabPage = Create("ScrollingFrame", {
			Name = TabName .. "Page",
			Parent = ContentContainer,
			Active = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Accent,
			Visible = false
		})
		
		Create("UIListLayout", {
			Parent = TabPage,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8)
		})
		
		Create("UIPadding", {
			Parent = TabPage,
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 15),
			PaddingRight = UDim.new(0, 10)
		})

		function Tab:Activate()
			for _, t in pairs(Window.Tabs) do
				if t ~= Tab then
					TweenService:Create(t.Instance, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
					TweenService:Create(t.Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
					if t.Icon then
						TweenService:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = Theme.TextSecondary}):Play()
					end
					t.Page.Visible = false
					t.Active = false
				end
			end
			
			Tab.Active = true
			TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.85}):Play()
			TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play() 
			if IconImage then
				TweenService:Create(IconImage, TweenInfo.new(0.3), {ImageColor3 = Theme.Accent}):Play()
			end
			
			TabPage.Visible = true

			if not SlidingIndicator.Visible then
				SlidingIndicator.Visible = true
				SlidingIndicator.Position = UDim2.new(0, 0, 0, TabButton.AbsolutePosition.Y - ButtonsHolder.AbsolutePosition.Y + 8)
			end
			
			local targetY = TabButton.AbsolutePosition.Y - ButtonsHolder.AbsolutePosition.Y + 8
			
			TweenService:Create(SlidingIndicator, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 0, targetY)
			}):Play()
		end

		TabButton.MouseButton1Click:Connect(function()
			
			task.spawn(function()
				local Mouse = Players.LocalPlayer:GetMouse()
				local Ripple = Create("Frame", {
					Parent = TabButton,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.8,
					BorderSizePixel = 0,
					Position = UDim2.new(0, Mouse.X - TabButton.AbsolutePosition.X, 0, Mouse.Y - TabButton.AbsolutePosition.Y),
					Size = UDim2.new(0, 0, 0, 0),
					ZIndex = 1
				})
				
				Create("UICorner", {
					CornerRadius = UDim.new(1, 0),
					Parent = Ripple
				})

				local Tween = TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 150, 0, 150),
					Position = UDim2.new(0, Mouse.X - TabButton.AbsolutePosition.X - 75, 0, Mouse.Y - TabButton.AbsolutePosition.Y - 75),
					BackgroundTransparency = 1
				})
				
				Tween:Play()
				Tween.Completed:Wait()
				Ripple:Destroy()
			end)

			Tab:Activate()
		end)
		
		Tab.Instance = TabButton
		Tab.Label = TabLabel
		Tab.Icon = IconImage
		Tab.Page = TabPage
		table.insert(Window.Tabs, Tab)
		
		if #Window.Tabs == 1 then
			Tab:Activate()
		end

		TabPage.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y + 20)
		end)

		
		
		function Tab:CreateSection(options)
			options = options or {}
			local SectionName = options.Name or "Section"
			local Icon = options.Icon
			
			local SectionContainer = Create("Frame", {
				Parent = TabPage,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30)
			})
			
			local ContentLayout = Create("UIListLayout", {
				Parent = SectionContainer,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			if Icon then
				local IconImage = Create("ImageLabel", {
					Parent = SectionContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 18, 0, 18),
					Image = Icon,
					ImageColor3 = Theme.TextColor,
					LayoutOrder = 1
				})
			end

			local SectionLabel = Create("TextLabel", {
				Name = "SectionLabel",
				Parent = SectionContainer,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Font = Enum.Font.GothamBold,
				Text = SectionName,
				TextColor3 = Theme.TextColor,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 2
			})
			
			
			
			
			
			local LineContainer = Create("Frame", {
				Parent = SectionContainer,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0), 
				LayoutOrder = 3
			})
			
			
			ContentLayout:Destroy()
			if Icon then SectionContainer:FindFirstChild("ImageLabel"):Destroy() end
			SectionLabel:Destroy()
			LineContainer:Destroy()
			
			
			local CurrentX = 0
			
			if Icon then
				Create("ImageLabel", {
					Parent = SectionContainer,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					Image = Icon,
					ImageColor3 = Theme.TextColor
				})
				CurrentX = 24
			end
			
			local Label = Create("TextLabel", {
				Name = "SectionLabel",
				Parent = SectionContainer,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, CurrentX, 0, 0),
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Font = Enum.Font.GothamBold,
				Text = SectionName,
				TextColor3 = Theme.TextColor,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			task.delay(0.05, function()
				local TextWidth = Label.TextBounds.X
				local LineX = CurrentX + TextWidth + 10
				
				local Separator = Create("Frame", {
					Parent = SectionContainer,
					BackgroundColor3 = Color3.fromRGB(60, 60, 70), 
					BorderSizePixel = 0,
					Position = UDim2.new(0, LineX, 0.5, 0),
					Size = UDim2.new(1, -LineX, 0, 2) 
				})
			end)
		end

        function Tab:CreateParagraph(options)
            options = options or {}
            local Title = options.Title or "Paragraph"
            local Content = options.Content or "Lorem ipsum dolor sit amet."
            
            local ParagraphFrame = Create("Frame", {
                Name = "ParagraphFrame",
                Parent = TabPage,
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = ParagraphFrame
            })
            
            Create("UIStroke", {
                Color = Theme.Outline,
                Transparency = 0.6,
                Thickness = 1,
                Parent = ParagraphFrame
            })
            
            local TitleLabel = Create("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = Title,
                TextColor3 = Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ContentLabel = Create("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 32),
                Size = UDim2.new(1, -24, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = Enum.Font.Gotham,
                Text = Content,
                TextColor3 = Theme.TextSecondary,
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                RichText = true
            })
            
            Create("UIPadding", {
                Parent = ParagraphFrame,
                PaddingBottom = UDim.new(0, 12)
            })
            
            local ParagraphObject = {
                Title = Title,
                Desc = Content
            }
            
            function ParagraphObject:SetTitle(newTitle)
                self.Title = newTitle
                TitleLabel.Text = newTitle
            end
            
            function ParagraphObject:SetDesc(newDesc)
                self.Desc = newDesc
                ContentLabel.Text = newDesc
            end
            
            function ParagraphObject:GetTitle()
                return self.Title
            end
            
            function ParagraphObject:GetDesc()
                return self.Desc
            end
            
            return ParagraphObject
        end

		function Tab:CreateLabel(options)
			options = options or {}
			local Text = options.Text or "Label"
			
			local LabelFrame = Create("Frame", {
				Name = "LabelFrame",
				Parent = TabPage,
				BackgroundColor3 = Theme.ElementBackground,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26)
			})
			
			local Label = Create("TextLabel", {
				Parent = LabelFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 5, 0, 0),
				Size = UDim2.new(1, -10, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = Text,
				TextColor3 = Theme.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			return Label
		end

		function Tab:CreateButton(options)
			options = options or {}
			local ButtonName = options.Name or "Button"
			local SubText = options.SubText
			local Icon = options.Icon
			local Callback = options.Callback or function() end
			
			local ButtonFrame = Create("Frame", {
				Name = "ButtonFrame",
				Parent = TabPage,
				BackgroundColor3 = Theme.ElementBackground,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, SubText and 50 or 38),
				ClipsDescendants = true
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ButtonFrame
			})
			
			local ButtonStroke = Create("UIStroke", {
				Color = Theme.Outline,
				Transparency = 0.5,
				Thickness = 1,
				Parent = ButtonFrame
			})
			
			local Button = Create("TextButton", {
				Name = "Button",
				Parent = ButtonFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = SubText and "" or ButtonName,
				TextColor3 = Theme.TextColor,
				TextSize = 14,
				AutoButtonColor = false,
				ZIndex = 2
			})
			
			if SubText then
				Create("TextLabel", {
					Parent = Button,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 8),
					Size = UDim2.new(1, -50, 0, 20),
					Font = Enum.Font.GothamBold,
					Text = ButtonName,
					TextColor3 = Theme.TextColor,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				Create("TextLabel", {
					Parent = Button,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 26),
					Size = UDim2.new(1, -50, 0, 14),
					Font = Enum.Font.Gotham,
					Text = SubText,
					TextColor3 = Theme.TextSecondary,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			end
			
			if Icon then
				Create("ImageLabel", {
					Parent = Button,
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.new(0, 20, 0, 20),
					Image = Icon,
					ImageColor3 = Theme.TextSecondary
				})
			end
			
			Button.MouseEnter:Connect(function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0.1}):Play()
				TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Theme.Accent, Transparency = 0.2}):Play()
			end)
			
			Button.MouseLeave:Connect(function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground, BackgroundTransparency = 0.2}):Play()
				TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Theme.Outline, Transparency = 0.5}):Play()
			end)
			
			Button.MouseButton1Click:Connect(function()
				
				task.spawn(function()
					local Mouse = Players.LocalPlayer:GetMouse()
					local Ripple = Create("Frame", {
						Parent = ButtonFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.8,
						BorderSizePixel = 0,
						Position = UDim2.new(0, Mouse.X - ButtonFrame.AbsolutePosition.X, 0, Mouse.Y - ButtonFrame.AbsolutePosition.Y),
						Size = UDim2.new(0, 0, 0, 0),
						ZIndex = 1
					})
					
					Create("UICorner", {
						CornerRadius = UDim.new(1, 0),
						Parent = Ripple
					})

					local Tween = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 200, 0, 200),
						Position = UDim2.new(0, Mouse.X - ButtonFrame.AbsolutePosition.X - 100, 0, Mouse.Y - ButtonFrame.AbsolutePosition.Y - 100),
						BackgroundTransparency = 1
					})
					
					Tween:Play()
					Tween.Completed:Wait()
					Ripple:Destroy()
				end)

				TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0}):Play()
				task.wait(0.1)
				TweenService:Create(ButtonFrame, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0.1}):Play()
				Callback()
			end)
		end
        function Tab:CreateToggle(options)
            options = options or {}
            local ToggleName = options.Name or "Toggle"
            local SubText = options.SubText
            local Default = options.Default or false
            local Values = options.Values or {}
            local Callback = options.Callback or function() end
            
            local Toggled = Default
            
            local ToggleFrame = Create("Frame", {
                Name = "ToggleFrame",
                Parent = TabPage,
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, SubText and 50 or 38)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = ToggleFrame
            })
            
            Create("UIStroke", {
                Color = Theme.Outline,
                Transparency = 0.5,
                Thickness = 1,
                Parent = ToggleFrame
            })
            
            local Label = Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, SubText and 8 or 0),
                Size = UDim2.new(1, -60, 0, SubText and 20 or 38),
                Font = SubText and Enum.Font.GothamBold or Enum.Font.GothamMedium,
                Text = ToggleName,
                TextColor3 = Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })
            
            if SubText then
                Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 26),
                    Size = UDim2.new(1, -60, 0, 14),
                    Font = Enum.Font.Gotham,
                    Text = SubText,
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center
                })
            end
            
            local SwitchBg = Create("Frame", {
                Parent = ToggleFrame,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(45, 45, 50),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 42, 0, 22)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SwitchBg
            })
            
            local SwitchCircle = Create("Frame", {
                Parent = SwitchBg,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(0, Toggled and 22 or 2, 0.5, 0),
                Size = UDim2.new(0, 18, 0, 18)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SwitchCircle
            })
            
            local Button = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })
            
            local function UpdateToggle()
                Toggled = not Toggled
                local TargetColor = Toggled and Theme.Accent or Color3.fromRGB(45, 45, 50)
                local TargetPos = UDim2.new(0, Toggled and 22 or 2, 0.5, 0)
                
                TweenService:Create(SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = TargetColor}):Play()
                TweenService:Create(SwitchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = TargetPos}):Play()
                
                if #Values > 0 then
                    Callback(Values[Toggled and 2 or 1]) 
                else
                    Callback(Toggled)
                end
            end
            
            Button.MouseButton1Click:Connect(UpdateToggle)
            
            if Default then
                Toggled = false
                UpdateToggle()
            end
        end

		function Tab:CreateSlider(options)
			options = options or {}
			local SliderName = options.Name or "Slider"
			local Min = options.Min or 0
			local Max = options.Max or 100
			local Default = options.Default or Min
			local Callback = options.Callback or function() end
			
			local SliderFrame = Create("Frame", {
				Name = "SliderFrame",
				Parent = TabPage,
				BackgroundColor3 = Theme.ElementBackground,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 55)
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = SliderFrame
			})
			
			Create("UIStroke", {
				Color = Theme.Outline,
				Transparency = 0.5,
				Thickness = 1,
				Parent = SliderFrame
			})
			
			local Label = Create("TextLabel", {
				Parent = SliderFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -24, 0, 20),
				Font = Enum.Font.GothamMedium,
				Text = SliderName,
				TextColor3 = Theme.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local ValueLabel = Create("TextLabel", {
				Parent = SliderFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -24, 0, 20),
				Font = Enum.Font.Gotham,
				Text = tostring(Default),
				TextColor3 = Theme.TextSecondary,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			
			local SliderBarBg = Create("Frame", {
				Parent = SliderFrame,
				BackgroundColor3 = Color3.fromRGB(50, 50, 55),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 12, 0, 38),
				Size = UDim2.new(1, -24, 0, 5)
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = SliderBarBg
			})
			
			local SliderFill = Create("Frame", {
				Parent = SliderBarBg,
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = SliderFill
			})
			
			local SliderKnob = Create("Frame", {
				Parent = SliderBarBg,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new((Default - Min) / (Max - Min), 0, 0.5, 0),
				Size = UDim2.new(0, 14, 0, 14),
				ZIndex = 2
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = SliderKnob
			})
			
			local SliderButton = Create("TextButton", {
				Parent = SliderBarBg,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				ZIndex = 3
			})
			
			local Dragging = false
			
			local function UpdateSlider(Input)
				local SizeX = SliderBarBg.AbsoluteSize.X
				local PosX = SliderBarBg.AbsolutePosition.X
				
				local Percent = math.clamp((Input.Position.X - PosX) / SizeX, 0, 1)
				local Value = math.floor(Min + ((Max - Min) * Percent))
				
				TweenService:Create(SliderFill, TweenInfo.new(0.05), {Size = UDim2.new(Percent, 0, 1, 0)}):Play()
				TweenService:Create(SliderKnob, TweenInfo.new(0.05), {Position = UDim2.new(Percent, 0, 0.5, 0)}):Play()
				ValueLabel.Text = tostring(Value)
				Callback(Value)
			end
			
			SliderButton.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					TweenService:Create(SliderKnob, TweenInfo.new(0.15), {Size = UDim2.new(0, 18, 0, 18)}):Play()
					UpdateSlider(Input)
				end
			end)
			
			table.insert(Connections, UserInputService.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = false
					TweenService:Create(SliderKnob, TweenInfo.new(0.15), {Size = UDim2.new(0, 14, 0, 14)}):Play()
				end
			end))
			
			table.insert(Connections, UserInputService.InputChanged:Connect(function(Input)
				if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(Input)
				end
			end))
		end
		
        function Tab:CreateInput(options)
            options = options or {}
            local InputName = options.Name or "Input"
            local Placeholder = options.Placeholder or InputName
            local Default = options.Default or ""
            local Callback = options.Callback or function() end
            local MultiLine = options.MultiLine or false
            local SideLabel = options.SideLabel
            local Value = options.Value or Default
            local Values = options.Values or {}
            
            local InputFrame = Create("Frame", {
                Name = "InputFrame",
                Parent = TabPage,
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, MultiLine and 100 or 40)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = InputFrame
            })
            
            Create("UIStroke", {
                Color = Theme.Outline,
                Transparency = 0.5,
                Thickness = 1,
                Parent = InputFrame
            })
            
            if SideLabel then
                local Label = Create("TextLabel", {
                    Parent = InputFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Font = Enum.Font.GothamMedium,
                    Text = SideLabel,
                    TextColor3 = Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local InputBoxBg = Create("Frame", {
                Parent = InputFrame,
                BackgroundColor3 = Theme.Sidebar,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = SideLabel and UDim2.new(1, -160, 0.5, 0) or UDim2.new(0, 6, 0, 6),
                Size = SideLabel and UDim2.new(0, 150, 0, 28) or UDim2.new(1, -12, 1, -12),
                AnchorPoint = SideLabel and Vector2.new(1, 0.5) or Vector2.new(0, 0)
            })
            
            if SideLabel then
                InputBoxBg.Position = UDim2.new(1, -12, 0.5, 0)
                InputBoxBg.AnchorPoint = Vector2.new(1, 0.5)
            end
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = InputBoxBg
            })
            
            local InputStroke = Create("UIStroke", {
                Color = Theme.Outline,
                Transparency = 0.7,
                Thickness = 1,
                Parent = InputBoxBg
            })
            
            local TextBox = Create("TextBox", {
                Parent = InputBoxBg,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, MultiLine and 8 or 0),
                Size = UDim2.new(1, -16, 1, MultiLine and -16 or 0),
                Font = Enum.Font.Gotham,
                PlaceholderText = Placeholder,
                Text = Value or Default,
                TextColor3 = Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = MultiLine and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                ClearTextOnFocus = true,
                MultiLine = MultiLine,
                TextWrapped = true
            })
            
            TextBox.Focused:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Theme.Accent, Transparency = 0}):Play()
            end)
            
            TextBox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Theme.Outline, Transparency = 0.7}):Play()
                Callback(TextBox.Text)
            end)
            
            local InputObject = {
                Value = Value or Default,
                Values = Values
            }
            
            function InputObject:Set(value)
                self.Value = value
                TextBox.Text = tostring(value)
                Callback(tostring(value))
            end
            
            function InputObject:Get()
                return self.Value
            end
            
            if (Value or Default) ~= "" then
                Callback(Value or Default)
            end
            
            return InputObject
        end
		
        function Tab:CreateDropdown(options)
            options = options or {}
            local DropdownName = options.Name or "Dropdown"
            local Items = options.Items or {}
            local Default = options.Default or Items[1]
            local Callback = options.Callback or function() end
            
            local DropdownFrame = Create("Frame", {
                Name = "DropdownFrame",
                Parent = TabPage,
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ClipsDescendants = true,
                ZIndex = 2
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = DropdownFrame
            })
            
            Create("UIStroke", {
                Color = Theme.Outline,
                Transparency = 0.5,
                Thickness = 1,
                Parent = DropdownFrame
            })
            
            local Label = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -40, 0, 38),
                Font = Enum.Font.GothamMedium,
                Text = DropdownName,
                TextColor3 = Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            
            local CurrentValue = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -35, 0, 38),
                Font = Enum.Font.Gotham,
                Text = Default or "Select...",
                TextColor3 = Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2
            })
            
            local Arrow = Create("ImageLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -28, 0, 9),
                Size = UDim2.new(0, 20, 0, 20),
                Image = "rbxassetid://6031091004",
                ImageColor3 = Theme.TextSecondary,
                ZIndex = 2
            })
            
            local Button = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = "",
                ZIndex = 3
            })
            
            local SearchBar = Create("TextBox", {
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 0.5,
                Position = UDim2.new(0, 6, 0, 42),
                Size = UDim2.new(1, -12, 0, 26),
                Font = Enum.Font.Gotham,
                PlaceholderText = "Search...",
                Text = "",
                TextColor3 = Theme.TextColor,
                PlaceholderColor3 = Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3,
                Visible = false
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = SearchBar
            })
            
            Create("UIPadding", {
                Parent = SearchBar,
                PaddingLeft = UDim.new(0, 8)
            })

            local DropdownContainer = Create("ScrollingFrame", {
                Parent = DropdownFrame,
                Active = true,
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 6, 0, 74),
                Size = UDim2.new(1, -12, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                ZIndex = 3
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = DropdownContainer
            })
            
            local ListLayout = Create("UIListLayout", {
                Parent = DropdownContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })
            
            Create("UIPadding", {
                Parent = DropdownContainer,
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4)
            })
            
            local Open = false
            local ItemButtons = {}
            
            local function UpdateList(filter)
                filter = filter and filter:lower() or ""
                local contentSize = 0
                for _, btn in pairs(ItemButtons) do
                    if btn.Text:lower():find(filter, 1, true) then
                        btn.Visible = true
                        contentSize = contentSize + 28
                    else
                        btn.Visible = false
                    end
                end
                DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, contentSize + 8)
            end

            local function ToggleDropdown()
                Open = not Open
                SearchBar.Visible = Open
                local TargetHeight = Open and math.min(#Items * 28 + 12, 160) or 0
                local FrameHeight = Open and (TargetHeight + 80) or 38
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, FrameHeight)}):Play()
                TweenService:Create(DropdownContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -12, 0, TargetHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = Open and 180 or 0}):Play()
                
                if Open then
                    SearchBar:CaptureFocus()
                else
                    SearchBar.Text = ""
                    UpdateList("")
                end
            end
            
            Button.MouseButton1Click:Connect(ToggleDropdown)
            
            SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
                UpdateList(SearchBar.Text)
            end)
            
            local function RefreshItems(newItems)
                Items = newItems or Items
                for _, btn in pairs(ItemButtons) do
                    btn:Destroy()
                end
                ItemButtons = {}
                
                for _, item in pairs(Items) do
                    local ItemButton = Create("TextButton", {
                        Parent = DropdownContainer,
                        BackgroundColor3 = Theme.Background,
                        BackgroundTransparency = 0.5,
                        Size = UDim2.new(1, 0, 0, 24),
                        Font = Enum.Font.Gotham,
                        Text = item,
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 13,
                        ZIndex = 3,
                        AutoButtonColor = false,
                        ClipsDescendants = true
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ItemButton
                    })
                    
                    ItemButton.MouseEnter:Connect(function()
                        TweenService:Create(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0.5, TextColor3 = Theme.TextColor}):Play()
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        TweenService:Create(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.5, TextColor3 = Theme.TextSecondary}):Play()
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        task.spawn(function()
                            local Mouse = Players.LocalPlayer:GetMouse()
                            local Ripple = Create("Frame", {
                                Parent = ItemButton,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 0.8,
                                BorderSizePixel = 0,
                                Position = UDim2.new(0, Mouse.X - ItemButton.AbsolutePosition.X, 0, Mouse.Y - ItemButton.AbsolutePosition.Y),
                                Size = UDim2.new(0, 0, 0, 0),
                                ZIndex = 4
                            })
                            
                            Create("UICorner", {
                                CornerRadius = UDim.new(1, 0),
                                Parent = Ripple
                            })

                            local Tween = TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(0, 100, 0, 100),
                                Position = UDim2.new(0, Mouse.X - ItemButton.AbsolutePosition.X - 50, 0, Mouse.Y - ItemButton.AbsolutePosition.Y - 50),
                                BackgroundTransparency = 1
                            })
                            
                            Tween:Play()
                            Tween.Completed:Wait()
                            Ripple:Destroy()
                        end)
                        
                        CurrentValue.Text = item
                        Callback(item)
                        ToggleDropdown()
                    end)
                    
                    table.insert(ItemButtons, ItemButton)
                end
            end
            
            RefreshItems(Items)
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
            end)
            

            local DropdownObject = {
                Items = Items
            }
            
            function DropdownObject:Refresh(newItems)
                items = newItems or items
                self.items = items
                
                if not table.find(items, CurrentValue.Text) then
                    CurrentValue.Text = items[1] or "none"
                end

                RefreshItems(items)
            end
            return DropdownObject
        end

		
      function Tab:CreateMultiDropdown(options)
            options = options or {}
            local DropdownName = options.Name or "Multi Dropdown"
            local Items = options.Items or options.Values or {}
            local Default = options.Default or options.Value or {}
            local Callback = options.Callback or function() end
            
            local Selected = type(Default) == "table" and Default or {}
            
            local DropdownFrame = Create("Frame", {
                Name = "MultiDropdownFrame",
                Parent = TabPage,
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ClipsDescendants = true,
                ZIndex = 2
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = DropdownFrame
            })
            
            Create("UIStroke", {
                Color = Theme.Outline,
                Transparency = 0.5,
                Thickness = 1,
                Parent = DropdownFrame
            })
            
            local Label = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -40, 0, 38),
                Font = Enum.Font.GothamMedium,
                Text = DropdownName,
                TextColor3 = Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            
            local function UpdateText()
                if #Selected == 0 then
                    return "None"
                elseif #Selected == 1 then
                    return Selected[1]
                else
                    return #Selected .. " Selected"
                end
            end
            
            local CurrentValue = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -35, 0, 38),
                Font = Enum.Font.Gotham,
                Text = UpdateText(),
                TextColor3 = Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2
            })
            
            local Arrow = Create("ImageLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -28, 0, 9),
                Size = UDim2.new(0, 20, 0, 20),
                Image = "rbxassetid://6031091004",
                ImageColor3 = Theme.TextSecondary,
                ZIndex = 2
            })
            
            local Button = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = "",
                ZIndex = 3
            })
            
            local SearchBar = Create("TextBox", {
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 0.5,
                Position = UDim2.new(0, 6, 0, 42),
                Size = UDim2.new(1, -12, 0, 26),
                Font = Enum.Font.Gotham,
                PlaceholderText = "Search...",
                Text = "",
                TextColor3 = Theme.TextColor,
                PlaceholderColor3 = Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3,
                Visible = false
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = SearchBar
            })
            
            Create("UIPadding", {
                Parent = SearchBar,
                PaddingLeft = UDim.new(0, 8)
            })

            local DropdownContainer = Create("ScrollingFrame", {
                Parent = DropdownFrame,
                Active = true,
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 6, 0, 74),
                Size = UDim2.new(1, -12, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                ZIndex = 3
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = DropdownContainer
            })
            
            local ListLayout = Create("UIListLayout", {
                Parent = DropdownContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })
            
            Create("UIPadding", {
                Parent = DropdownContainer,
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4)
            })
            
            local Open = false
            local ItemButtons = {}
            
            local function UpdateList(filter)
                filter = filter and filter:lower() or ""
                local contentSize = 0
                for _, btn in pairs(ItemButtons) do
                    if btn.Text:lower():find(filter, 1, true) then
                        btn.Visible = true
                        contentSize = contentSize + 28
                    else
                        btn.Visible = false
                    end
                end
                DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, contentSize + 8)
            end

            local function ToggleDropdown()
                Open = not Open
                SearchBar.Visible = Open
                local TargetHeight = Open and math.min(#Items * 28 + 12, 160) or 0
                local FrameHeight = Open and (TargetHeight + 80) or 38
                
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, FrameHeight)}):Play()
                TweenService:Create(DropdownContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -12, 0, TargetHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = Open and 180 or 0}):Play()
                
                if Open then
                    SearchBar:CaptureFocus()
                else
                    SearchBar.Text = ""
                    UpdateList("")
                end
            end
            
            Button.MouseButton1Click:Connect(ToggleDropdown)
            
            SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
                UpdateList(SearchBar.Text)
            end)
            
            local function RefreshItems(newItems)
                Items = newItems or Items
                for _, btn in pairs(ItemButtons) do
                    btn:Destroy()
                end
                ItemButtons = {}
                
                for _, item in pairs(Items) do
                    local IsSelected = table.find(Selected, item)
                    local ItemButton = Create("TextButton", {
                        Parent = DropdownContainer,
                        BackgroundColor3 = IsSelected and Theme.Hover or Theme.Background,
                        BackgroundTransparency = 0.5,
                        Size = UDim2.new(1, 0, 0, 24),
                        Font = Enum.Font.Gotham,
                        Text = item,
                        TextColor3 = IsSelected and Theme.Accent or Theme.TextSecondary,
                        TextSize = 13,
                        ZIndex = 3,
                        AutoButtonColor = false,
                        ClipsDescendants = true
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ItemButton
                    })
                    
                    ItemButton.MouseEnter:Connect(function()
                        if not table.find(Selected, item) then
                            TweenService:Create(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0.5, TextColor3 = Theme.TextColor}):Play()
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        if not table.find(Selected, item) then
                            TweenService:Create(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.5, TextColor3 = Theme.TextSecondary}):Play()
                        end
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        task.spawn(function()
                            local Mouse = Players.LocalPlayer:GetMouse()
                            local Ripple = Create("Frame", {
                                Parent = ItemButton,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 0.8,
                                BorderSizePixel = 0,
                                Position = UDim2.new(0, Mouse.X - ItemButton.AbsolutePosition.X, 0, Mouse.Y - ItemButton.AbsolutePosition.Y),
                                Size = UDim2.new(0, 0, 0, 0),
                                ZIndex = 4
                            })
                            
                            Create("UICorner", {
                                CornerRadius = UDim.new(1, 0),
                                Parent = Ripple
                            })

                            local Tween = TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(0, 100, 0, 100),
                                Position = UDim2.new(0, Mouse.X - ItemButton.AbsolutePosition.X - 50, 0, Mouse.Y - ItemButton.AbsolutePosition.Y - 50),
                                BackgroundTransparency = 1
                            })
                            
                            Tween:Play()
                            Tween.Completed:Wait()
                            Ripple:Destroy()
                        end)
                        
                        if table.find(Selected, item) then
                            table.remove(Selected, table.find(Selected, item))
                            TweenService:Create(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.5, TextColor3 = Theme.TextSecondary}):Play()
                        else
                            table.insert(Selected, item)
                            TweenService:Create(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0.5, TextColor3 = Theme.Accent}):Play()
                        end
                        
                        CurrentValue.Text = UpdateText()
                        Callback(Selected)
                    end)
                    
                    table.insert(ItemButtons, ItemButton)
                end
            end
            
            RefreshItems()
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
            end)
            
            local MultiDropdownObject = {
                Values = Items,
                Value = Selected
            }
            
            function MultiDropdownObject:Set(values)
                if type(values) == "table" then
                    Selected = values
                    CurrentValue.Text = UpdateText()
                    Callback(Selected)
                end
            end
            
            function MultiDropdownObject:Get()
                return Selected
            end
            
            function MultiDropdownObject:Refresh(newItems)
                RefreshItems(newItems)
            end
            
            return MultiDropdownObject
        end
		
		function Tab:CreateColorPicker(options)
			options = options or {}
			local Name = options.Name or "Color Picker"
			local Default = options.Default or Color3.fromRGB(255, 255, 255)
			local Callback = options.Callback or function() end
			
			local ColorH, ColorS, ColorV = Default:ToHSV()
			local ColorVal = Default
			local Open = false
			
			local PickerFrame = Create("Frame", {
				Name = "PickerFrame",
				Parent = TabPage,
				BackgroundColor3 = Theme.ElementBackground,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 38),
				ClipsDescendants = true
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = PickerFrame
			})
			
			Create("UIStroke", {
				Color = Theme.Outline,
				Transparency = 0.5,
				Thickness = 1,
				Parent = PickerFrame
			})
			
			local Label = Create("TextLabel", {
				Parent = PickerFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -60, 0, 38),
				Font = Enum.Font.GothamMedium,
				Text = Name,
				TextColor3 = Theme.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Preview = Create("Frame", {
				Parent = PickerFrame,
				BackgroundColor3 = Default,
				Position = UDim2.new(1, -40, 0, 9),
				Size = UDim2.new(0, 28, 0, 20)
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = Preview
			})
			
			local Button = Create("TextButton", {
				Parent = PickerFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 38),
				Text = ""
			})
			
			local PickerContainer = Create("Frame", {
				Parent = PickerFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 42),
				Size = UDim2.new(1, -24, 0, 160),
				Visible = true
			})
			
			
			local SVBox = Create("ImageButton", {
				Parent = PickerContainer,
				BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 120),
				Image = "rbxassetid://4155801252",
				AutoButtonColor = false
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = SVBox
			})
			
			local SVCursor = Create("Frame", {
				Parent = SVBox,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Position = UDim2.new(ColorS, -3, 1 - ColorV, -3),
				Size = UDim2.new(0, 6, 0, 6),
				ZIndex = 2
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = SVCursor
			})
			
			Create("UIStroke", {
				Color = Color3.new(0, 0, 0),
				Thickness = 1,
				Parent = SVCursor
			})
			
			
			local HueBar = Create("ImageButton", {
				Parent = PickerContainer,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -24),
				Size = UDim2.new(1, 0, 0, 20),
				AutoButtonColor = false
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = HueBar
			})
			
			Create("UIGradient", {
				Parent = HueBar,
				Rotation = 0,
				Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
				}
			})
			
			local HueCursor = Create("Frame", {
				Parent = HueBar,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Position = UDim2.new(ColorH, -3, 0, -2),
				Size = UDim2.new(0, 6, 1, 4),
				ZIndex = 2
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 2),
				Parent = HueCursor
			})
			
			Create("UIStroke", {
				Color = Color3.new(0, 0, 0),
				Thickness = 1,
				Parent = HueCursor
			})
			
			
			local function UpdateColor()
				ColorVal = Color3.fromHSV(ColorH, ColorS, ColorV)
				Preview.BackgroundColor3 = ColorVal
				SVBox.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
				Callback(ColorVal)
			end
			
			local DraggingSV = false
			local DraggingHue = false
			
			SVBox.MouseButton1Down:Connect(function()
				DraggingSV = true
			end)
			
			HueBar.MouseButton1Down:Connect(function()
				DraggingHue = true
			end)
			
			table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					DraggingSV = false
					DraggingHue = false
				end
			end))
			
			table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if DraggingSV then
						local rX = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
						local rY = math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
						
						ColorS = rX
						ColorV = 1 - rY
						
						SVCursor.Position = UDim2.new(ColorS, -3, 1 - ColorV, -3)
						UpdateColor()
					elseif DraggingHue then
						local rX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
						
						ColorH = rX
						HueCursor.Position = UDim2.new(ColorH, -3, 0, -2)
						UpdateColor()
					end
				end
			end))
			
			Button.MouseButton1Click:Connect(function()
				Open = not Open
				TweenService:Create(PickerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, Open and 200 or 38)}):Play()
			end)
		end

		function Tab:CreateKeybind(options)
			options = options or {}
			local KeybindName = options.Name or "Keybind"
			local Default = options.Default or Enum.KeyCode.RightControl
			local Callback = options.Callback or function() end
			
			local KeybindFrame = Create("Frame", {
				Name = "KeybindFrame",
				Parent = TabPage,
				BackgroundColor3 = Theme.ElementBackground,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 38)
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = KeybindFrame
			})
			
			Create("UIStroke", {
				Color = Theme.Outline,
				Transparency = 0.5,
				Thickness = 1,
				Parent = KeybindFrame
			})
			
			local Label = Create("TextLabel", {
				Parent = KeybindFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -60, 1, 0),
				Font = Enum.Font.GothamMedium,
				Text = KeybindName,
				TextColor3 = Theme.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local KeybindButton = Create("TextButton", {
				Parent = KeybindFrame,
				BackgroundColor3 = Theme.Background,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -95, 0.5, -12),
				Size = UDim2.new(0, 85, 0, 24),
				Font = Enum.Font.Gotham,
				Text = Default.Name,
				TextColor3 = Theme.TextSecondary,
				TextSize = 13,
				ClipsDescendants = true
			})
			
			Create("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = KeybindButton
			})
			
			Create("UIStroke", {
				Color = Theme.Outline,
				Transparency = 0.7,
				Thickness = 1,
				Parent = KeybindButton
			})
			
			local Binding = false
			
			KeybindButton.MouseButton1Click:Connect(function()
				
				task.spawn(function()
					local Mouse = Players.LocalPlayer:GetMouse()
					local Ripple = Create("Frame", {
						Parent = KeybindButton,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.8,
						BorderSizePixel = 0,
						Position = UDim2.new(0, Mouse.X - KeybindButton.AbsolutePosition.X, 0, Mouse.Y - KeybindButton.AbsolutePosition.Y),
						Size = UDim2.new(0, 0, 0, 0),
						ZIndex = 2
					})
					
					Create("UICorner", {
						CornerRadius = UDim.new(1, 0),
						Parent = Ripple
					})

					local Tween = TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 100, 0, 100),
						Position = UDim2.new(0, Mouse.X - KeybindButton.AbsolutePosition.X - 50, 0, Mouse.Y - KeybindButton.AbsolutePosition.Y - 50),
						BackgroundTransparency = 1
					})
					
					Tween:Play()
					Tween.Completed:Wait()
					Ripple:Destroy()
				end)

				Binding = true
				KeybindButton.Text = "..."
				TweenService:Create(KeybindButton, TweenInfo.new(0.2), {TextColor3 = Theme.Accent}):Play()
			end)
			
			table.insert(Connections, UserInputService.InputBegan:Connect(function(Input)
				if Binding then
					if Input.UserInputType == Enum.UserInputType.Keyboard then
						Default = Input.KeyCode
						KeybindButton.Text = Default.Name
						Binding = false
						TweenService:Create(KeybindButton, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
						Callback(Default)
					elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Binding = false
						KeybindButton.Text = Default.Name
						TweenService:Create(KeybindButton, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
					end
				else
					if Input.KeyCode == Default then
						Callback(Default)
					end
				end
			end))
		end

		return Tab
	end

	function Window:Destroy()
		ScreenGui:Destroy()
		for _, connection in pairs(Connections) do
			connection:Disconnect()
		end
		Connections = {}
	end

	return Window
end

function VoraLib:Destroy()
	for _, connection in pairs(Connections) do
		connection:Disconnect()
	end
	Connections = {}
	
	if RunService:IsStudio() then
		local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("VoraHub")
		if gui then gui:Destroy() end
	else
		local gui = CoreGui:FindFirstChild("VoraHub")
		if gui then gui:Destroy() end
	end
end


local Window = VoraLib:CreateWindow({
	Name = "Vora Hub",
	Intro = true
})

Window:Notify({
    Title = "VORA HUB Loaded",
    Content = "UI loaded successfully!",
    Duration = 3,
})

local InfoTab = Window:CreateTab({
	Name = "Info",
	Icon = "rbxassetid://7733964719"
})

local ExclusiveTab = Window:CreateTab({
	Name = "Exclusive",
	Icon = "rbxassetid://7733765398"
})

local MainTab = Window:CreateTab({
	Name = "Main",
	Icon = "rbxassetid://7733779610"
})

local AutoTab = Window:CreateTab({
	Name = "Auto",
	Icon = "rbxassetid://7733799901"
})

local PlayerTab = Window:CreateTab({
	Name = "Player",
	Icon = "rbxassetid://7743875962"
})

local ShopTab = Window:CreateTab({
	Name = "Shop",
	Icon = "rbxassetid://7733793319"
})

local TeleportTab = Window:CreateTab({
	Name = "Teleport",
	Icon = "rbxassetid://128755575520135"
})

local SettingsTab = Window:CreateTab({
	Name = "Settings",
	Icon = "rbxassetid://7733954611"
})


InfoTab:CreateSection({ Name = "Community Support" })

InfoTab:CreateButton({
	Name = "Discord",
	SubText = "click to copy link",
	Icon = "rbxassetid://7733919427", 
	Callback = function()
		setclipboard("https://discord.gg/yourserver")
		Window:Notify({
			Title = "Discord",
			Content = "Link copied to clipboard!",
			Duration = 3
		})
	end
})

InfoTab:CreateParagraph({
	Title = "Update",
	Content = "Every time there is a game update or someone reports something, I will fix it as soon as possible."
})

getgenv().host = game:GetService("Players").LocalPlayer

 function applyZoom()
    host.CameraMaxZoomDistance = math.huge
    host.CameraMinZoomDistance = 0.1
end

applyZoom()

host.CharacterAdded:Connect(function()
    task.wait(0.1)
    applyZoom()
end)

ReplicatedStorage = game:GetService("ReplicatedStorage")
 RunService = game:GetService("RunService")
 Net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
 Replion = require(ReplicatedStorage.Packages.Replion)
 FishingController = require(ReplicatedStorage.Controllers.FishingController)
 ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
 VendorUtility = require(ReplicatedStorage.Shared.VendorUtility)
 Data = Replion.Client:WaitReplion("Data")
 Items = ReplicatedStorage:WaitForChild("Items")
 Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
 NetService = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
 sellAllItems = NetService:WaitForChild("RF/SellAllItems")
 enchan = NetService:WaitForChild("RE/ActivateEnchantingAltar")
 oxygenRemote = NetService:WaitForChild("URE/UpdateOxygen")
 radar = NetService:WaitForChild("RF/UpdateFishingRadar")
 autoon = NetService:WaitForChild("RF/UpdateAutoFishingState")
 equipTool = NetService:WaitForChild("RE/EquipToolFromHotbar")
 CoreGui = game:GetService("CoreGui")
 tradeFunc = Net["RF/InitiateTrade"]
 RETextNotification = Net["RE/TextNotification"]
 ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
 TradingController = require(ReplicatedStorage.Controllers.ItemTradingController)

 RE = {
    FavoriteItem = Net:FindFirstChild("RE/FavoriteItem"),
    FavoriteStateChanged = Net:FindFirstChild("RE/FavoriteStateChanged"),
    FishingCompleted = Net:FindFirstChild("RE/FishingCompleted"),
    FishCaught = Net:FindFirstChild("RE/FishCaught"),
    EquipItem = Net:FindFirstChild("RE/EquipItem"),
    ActivateAltar = Net:FindFirstChild("RE/ActivateEnchantingAltar"),
    EquipTool = Net:FindFirstChild("RE/EquipToolFromHotbar"),
}

 equipItemRemote = RE.EquipItem or Net:FindFirstChild("RE/EquipItem")
 equipToolRemote = RE.EquipTool or Net:FindFirstChild("RE/EquipToolFromHotbar")
 activateAltarRemote = RE.ActivateAltar or Net:FindFirstChild("RE/ActivateEnchantingAltar")

 st = {
    canFish = true,
}

 blockedFunctions = {
    "OnCooldown",
}

 function patchFishingController()
     fishingModule = ReplicatedStorage.Controllers:FindFirstChild("FishingController")
    if not fishingModule then return end

     ok, FC = pcall(require, fishingModule)
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

 function instant()
    NetService:WaitForChild("RF/ChargeFishingRod"):InvokeServer(1)
    task.wait(0.2)
    NetService:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(1, 0.921, 17819.019)
    task.wait(delayfishing)
    NetService:WaitForChild("RE/FishingCompleted"):FireServer(1)
end


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

ExclusiveTab:CreateSection({ Name = "Premium" })

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

ExclusiveTab:CreateToggle({
	Name = "No Animation",
    Value = false,
    Callback = setAnim
})

-- // TOTEM DATA
local TOTEM_DATA = {
    ["Luck Totem"] = {Id = 1, Duration = 3601},
    ["Mutation Totem"] = {Id = 2, Duration = 3601},
    ["Shiny Totem"] = {Id = 3, Duration = 3601}
}
local TOTEM_NAMES = {"Luck Totem", "Mutation Totem", "Shiny Totem"}
local selectedTotemName = "Luck Totem"

-- // AUTO SINGLE TOTEM
local AUTO_TOTEM_ACTIVE = false
local AUTO_TOTEM_THREAD = nil
local currentTotemExpiry = 0

-- // AUTO 9 TOTEM
local AUTO_9_TOTEM_ACTIVE = false
local AUTO_9_TOTEM_THREAD = nil
local stateConnection = nil
local noclipThread = nil

-- // REFERENCE POSITIONS (DIBUAT LEBIH JAUH & VARIATIF)
local REF_CENTER = Vector3.new(93.932, 9.532, 2684.134)
local REF_SPOTS = {
    Vector3.new(45.0468979 + 5, 9.51625347 + 3, 2730.19067 - 6),      -- 1 (lebih jauh)
    Vector3.new(145.644608 - 6, 9.51625347 + 2.5, 2721.90747 + 7),    -- 2
    Vector3.new(84.6406631 + 4, 10.2174253 + 4, 2636.05786 - 5),      -- 3
    Vector3.new(45.0468979 - 4.5, 110.516253 + 6, 2730.19067 + 5),    -- 4
    Vector3.new(145.644608 + 7, 110.516253 - 3, 2721.90747 - 6),      -- 5
    Vector3.new(84.6406631 - 5, 111.217425 + 5, 2636.05786 + 8),      -- 6
    Vector3.new(45.0468979 + 6, -92.483747 - 4, 2730.19067 - 7),      -- 7
    Vector3.new(145.644608 - 8, -92.483747 + 5, 2721.90747 + 4),      -- 8
    Vector3.new(84.6406631 + 5.5, -93.782575 - 3.5, 2636.05786 - 8),  -- 9
}

-- // GET FLY PART
local function GetFlyPart()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

-- // ANTI-FALL STATE MANAGER
local function MaintainAntiFallState(enable)
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    if enable then
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

        if not stateConnection then
            stateConnection = RunService.Heartbeat:Connect(function()
                if hum and AUTO_9_TOTEM_ACTIVE then
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                end
            end)
        end
    else
        if stateConnection then stateConnection:Disconnect(); stateConnection = nil end
        
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end

-- // ENABLE V3 PHYSICS
local function EnableV3Physics()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local mainPart = GetFlyPart()
    
    if not mainPart or not hum then return end
    
    if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
    hum.PlatformStand = true 
    
    MaintainAntiFallState(true)
    
    local bg = mainPart:FindFirstChild("FlyGuiGyro") or Instance.new("BodyGyro", mainPart)
    bg.Name = "FlyGuiGyro"
    bg.P = 9e4 
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = mainPart.CFrame
    
    local bv = mainPart:FindFirstChild("FlyGuiVelocity") or Instance.new("BodyVelocity", mainPart)
    bv.Name = "FlyGuiVelocity"
    bv.Velocity = Vector3.new(0, 0.1, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    if noclipThread then task.cancel(noclipThread) end
    noclipThread = task.spawn(function()
        while AUTO_9_TOTEM_ACTIVE and char and char.Parent do
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            task.wait(0.1)
        end
    end)
end

-- // DISABLE V3 PHYSICS (LANDING & TOGGLE OFF AMAN TOTAL)
local function DisableV3Physics()
    AUTO_9_TOTEM_ACTIVE = false
    
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local mainPart = GetFlyPart()
    
    if mainPart then
        pcall(function()
            if mainPart:FindFirstChild("FlyGuiGyro") then mainPart.FlyGuiGyro:Destroy() end
            if mainPart:FindFirstChild("FlyGuiVelocity") then mainPart.FlyGuiVelocity:Destroy() end
        end)
        
        pcall(function()
            mainPart.Velocity = Vector3.zero
            mainPart.RotVelocity = Vector3.zero
            mainPart.AssemblyLinearVelocity = Vector3.zero 
            mainPart.AssemblyAngularVelocity = Vector3.zero
        end)
        
        local _, y, _ = mainPart.CFrame:ToEulerAnglesYXZ()
        mainPart.CFrame = CFrame.new(mainPart.Position) * CFrame.fromEulerAnglesYXZ(0, y, 0)
        
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local result = workspace:Raycast(mainPart.Position, Vector3.new(0, -10, 0), params)
        if result then
            mainPart.CFrame = mainPart.CFrame + Vector3.new(0, 6, 0)
        end
    end
    
    if hum then 
        hum.PlatformStand = false 
        task.wait(0.1)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.2)
        hum:ChangeState(Enum.HumanoidStateType.Running)
        task.wait(0.1)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    MaintainAntiFallState(false) 
    
    if char:FindFirstChild("Animate") then char.Animate.Disabled = false end
    
    task.delay(0.5, function()
        if char and char.Parent then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end)
    
    if noclipThread then task.cancel(noclipThread) noclipThread = nil end
end

-- // FLY TO TARGET
local function FlyPhysicsTo(targetPos)
    local mainPart = GetFlyPart()
    if not mainPart then return end
    
    local bv = mainPart:FindFirstChild("FlyGuiVelocity")
    local bg = mainPart:FindFirstChild("FlyGuiGyro")
    if not bv or not bg then EnableV3Physics(); task.wait(0.2); bv = mainPart.FlyGuiVelocity; bg = mainPart.FlyGuiGyro end
    local SPEED = 80 
    
    while AUTO_9_TOTEM_ACTIVE and mainPart.Parent do
        local currentPos = mainPart.Position
        local diff = targetPos - currentPos
        local dist = diff.Magnitude
        
        bg.CFrame = CFrame.lookAt(currentPos, targetPos)
        if dist < 1.5 then 
            bv.Velocity = Vector3.new(0, 0.1, 0)
            break
        else
            bv.Velocity = diff.Unit * SPEED
        end
        RunService.Heartbeat:Wait()
    end
end

-- // GET TOTEM UUID
local function GetTotemUUID(name)
    local success, r = pcall(function()
        return require(ReplicatedStorage.Packages.Replion).Client:WaitReplion("Data")
    end)
    if not success then return nil end
    local s, d = pcall(function() return r:GetExpect("Inventory") end)
    if s and d.Totems then 
        for _, i in ipairs(d.Totems) do 
            if tonumber(i.Id) == TOTEM_DATA[name].Id and (i.Count or 1) >= 1 then return i.UUID end 
        end 
    end
    return nil
end

-- // OXYGEN REMOTE
local RF_EquipOxygenTank = Net["RF/EquipOxygenTank"]
local RF_UnequipOxygenTank = Net["RF/UnequipOxygenTank"]

-- // 9 TOTEM LOOP
local function Run9TotemLoop()
    if AUTO_9_TOTEM_THREAD then task.cancel(AUTO_9_TOTEM_THREAD) end
    
    AUTO_9_TOTEM_THREAD = task.spawn(function()
        AUTO_9_TOTEM_ACTIVE = true
        
        local char = player.Character or player.CharacterAdded:Wait()
        local mainPart = GetFlyPart()
        local hum = char:FindFirstChild("Humanoid")
        if not mainPart then 
            AUTO_9_TOTEM_ACTIVE = false
            return 
        end
        
        local uuid = GetTotemUUID(selectedTotemName)
        if not uuid then 
            Window:Notify({ Title = "No Stock", Content = "Isi inventory dulu!", Duration = 4, Icon = "x" })
            AUTO_9_TOTEM_ACTIVE = false
            local t = Exclusive:GetElementByTitle("Auto Spawn 9 Totem")
            if t then t:Set(false) end
            return 
        end
        
        local myStartPos = mainPart.Position 
        Window:Notify({ Title = "Started", Content = "V3 Engine + Oxygen Protection!", Duration = 4, Icon = "zap" })
        
        if RF_EquipOxygenTank then pcall(function() RF_EquipOxygenTank:InvokeServer(105) end) end
        
        if hum then hum.Health = hum.MaxHealth end
        
        EnableV3Physics()
        
        for _, refSpot in ipairs(REF_SPOTS) do
            if not AUTO_9_TOTEM_ACTIVE then break end
            
            local relativePos = refSpot - REF_CENTER
            local targetPos = myStartPos + relativePos
            
            FlyPhysicsTo(targetPos) 
            
            task.wait(0.8)
            
            uuid = GetTotemUUID(selectedTotemName)
            if uuid then
                pcall(function() Net["RE/SpawnTotem"]:FireServer(uuid) end)
                
                task.spawn(function() 
                    for k=1,7 do
                        pcall(function() Net["RE/EquipToolFromHotbar"]:FireServer(1) end)
                        task.wait(0.09) 
                    end 
                end)
            else
                break
            end
            
            task.wait(1.7) 
        end
        
        if AUTO_9_TOTEM_ACTIVE then
            FlyPhysicsTo(myStartPos)
            task.wait(1.2)  -- Tunggu lebih lama biar landing perfect
            Window:Notify({ Title = "Selesai", Content = "Landing aman total!", Duration = 5, Icon = "check" })
        end
        
        if RF_UnequipOxygenTank then pcall(function() RF_UnequipOxygenTank:InvokeServer() end) end
        
        DisableV3Physics()
        
        local t = Exclusive:GetElementByTitle("Auto Spawn 9 Totem")
        if t then t:Set(false) end
    end)
end

-- // AUTO SINGLE TOTEM
local function RunAutoTotemLoop()
    if AUTO_TOTEM_THREAD then task.cancel(AUTO_TOTEM_THREAD) end
    AUTO_TOTEM_THREAD = task.spawn(function()
        while AUTO_TOTEM_ACTIVE do
            local timeLeft = currentTotemExpiry - os.time()
            if timeLeft <= 0 then
                local uuid = GetTotemUUID(selectedTotemName)
                if uuid then
                    pcall(function() Net["RE/SpawnTotem"]:FireServer(uuid) end)
                    currentTotemExpiry = os.time() + TOTEM_DATA[selectedTotemName].Duration
                    task.spawn(function() 
                        for i=1,4 do task.wait(0.2) pcall(function() Net["RE/EquipToolFromHotbar"]:FireServer(1) end) end 
                    end)
                end
            end
            task.wait(1)
        end
    end)
end

ExclusiveTab:CreateDropdown({
	Name = "Pilih Jenis Totem",
Items = {"Luck Totem", "Mutation Totem", "Shiny Totem"},
    Value = selectedTotemName,
 Callback = function(n) 
        selectedTotemName = n
        currentTotemExpiry = 0 
    end 
})

ExclusiveTab:CreateToggle({
	Name = "Enable Auto Totem (Single)",
	SubText = "Mode Normal",
	Default = false,
	 Callback = function(s) 
        AUTO_TOTEM_ACTIVE = s
        if s then RunAutoTotemLoop() else if AUTO_TOTEM_THREAD then task.cancel(AUTO_TOTEM_THREAD) end end 
    end 
})

ExclusiveTab:CreateToggle({
	Name = "Auto Spawn 9 Totem",
	Default = false,
 Callback = function(s)
        AUTO_9_TOTEM_ACTIVE = s
        if s then
            Run9TotemLoop()
        else
            AUTO_9_TOTEM_ACTIVE = false
            DisableV3Physics()
            if AUTO_9_TOTEM_THREAD then task.cancel(AUTO_9_TOTEM_THREAD) end
            Window:Notify({ Title = "Stopped", Content = "Dihentikan & karakter normal!", Duration = 5, Icon = "x" })
        end
    end
})

ExclusiveTab:CreateSection({ Name = "Extreme FPS Boost" })

ExclusiveTab:CreateToggle({
	Name = "Extreme FPS Boost",
	SubText = "Maksimalkan FPS dengan mengorbankan hampir semua efek visual",
	Default = false,
	 Callback = function(enabled)
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        local RunService = game:GetService("RunService")

        -- Data penyimpanan untuk restore
        local restore = {
            lighting = {},
            terrain = {},
            objects = {},        -- instance -> data
            connection = nil
        }

        local function saveLighting()
            if next(restore.lighting) == nil then
                restore.lighting = {
                    GlobalShadows = Lighting.GlobalShadows,
                    FogEnd = Lighting.FogEnd,
                    Brightness = Lighting.Brightness,
                    Ambient = Lighting.Ambient,
                    OutdoorAmbient = Lighting.OutdoorAmbient,
                    ColorShift_Top = Lighting.ColorShift_Top,
                    ColorShift_Bottom = Lighting.ColorShift_Bottom,
                    ShadowSoftness = Lighting.ShadowSoftness,
                    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
                    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
                    ClockTime = Lighting.ClockTime,
                    GeographicLatitude = Lighting.GeographicLatitude,
                }
            end
        end

        local function saveTerrain()
            if Terrain and next(restore.terrain) == nil then
                restore.terrain = {
                    WaterTransparency = Terrain.WaterTransparency,
                    WaterReflectance = Terrain.WaterReflectance,
                    WaterWaveSize = Terrain.WaterWaveSize,
                    WaterWaveSpeed = Terrain.WaterWaveSpeed,
                }
            end
        end

        local function extremeLowGraphics()
            -- Lighting super minimal
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 0
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.GeographicLatitude = 0
            Lighting.ShadowSoftness = 0
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)

            -- Hapus post-processing effects
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    if not restore.objects[effect] then
                        restore.objects[effect] = { Enabled = effect.Enabled }
                    end
                    effect.Enabled = false
                end
            end

            -- Terrain minimal
            if Terrain then
                Terrain.WaterTransparency = 1
                Terrain.WaterReflectance = 0
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
            end
        end

        local function optimizePart(part)
            if part:IsA("BasePart") and not restore.objects[part] then
                restore.objects[part] = {
                    Material = part.Material,
                    Reflectance = part.Reflectance,
                    CastShadow = part.CastShadow,
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide, -- penting untuk gameplay
                }

                part.Material = Enum.Material.SmoothPlastic
                part.Reflectance = 0
                part.CastShadow = false

                -- Hapus Decal/Texture/SurfaceAppearance (berat banget)
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
                        if not restore.objects[child] then
                            restore.objects[child] = { Parent = child.Parent }
                        end
                        child:Destroy() -- langsung hapus, lebih ringan daripada disable
                    end
                end
            end
        end

        local function disableAllEffects(instance)
            local class = instance.ClassName
            if class == "ParticleEmitter" or class == "Trail" or class == "Beam" 
                or class == "Smoke" or class == "Fire" or class == "Sparkles" 
                or class == "Light" or class == "SurfaceLight" or class == "PointLight" or class == "SpotLight" then
                
                if not restore.objects[instance] then
                    restore.objects[instance] = { Enabled = instance.Enabled }
                end
                instance.Enabled = false
            end
        end

        local function processAll()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    optimizePart(obj)
                else
                    disableAllEffects(obj)
                end
            end
        end

        local function restoreEverything()
            -- Restore Lighting
            for prop, val in pairs(restore.lighting) do
                pcall(function() Lighting[prop] = val end)
            end

            -- Restore Terrain
            if Terrain then
                for prop, val in pairs(restore.terrain) do
                    pcall(function() Terrain[prop] = val end)
                end
            end

            -- Restore objects
            for obj, data in pairs(restore.objects) do
                if obj and obj.Parent then
                    for prop, val in pairs(data) do
                        pcall(function() obj[prop] = val end)
                    end
                end
            end

            restore.objects = {}
        end

        if enabled then
            saveLighting()
            saveTerrain()
            extremeLowGraphics()
            processAll()

            -- Monitor objek baru (penting untuk map dinamis)
            restore.connection = workspace.DescendantAdded:Connect(function(desc)
                task.spawn(function()
                    if desc:IsA("BasePart") then
                        optimizePart(desc)
                    else
                        disableAllEffects(desc)
                    end
                end)
            end)

        else
            if restore.connection then
                restore.connection:Disconnect()
                restore.connection = nil
            end
            restoreEverything()
        end
    end
})

local freezeConnection
local originalCFrame

ExclusiveTab:CreateToggle({
	Name = "Freeze Character",
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

ExclusiveTab:CreateToggle({
	Name = "Disable Notification",
	Default = false,
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


ExclusiveTab:CreateToggle({
	Name = "Disable Fish Caught",
	Default = false,
  Callback = function(state)
        disableNotifs = state
        
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

        if state then
            -- 1. Hapus yang sudah ada sekarang
            local smallNotif = PlayerGui:FindFirstChild("Small Notification")
            if smallNotif then
                smallNotif:Destroy()
            end

            -- 2. Auto-hapus setiap kali game coba spawn lagi
            PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "Small Notification" or 
                   (child:FindFirstChild("Display") and child:FindFirstChildWhichIsA("Frame")) then
                    task.spawn(function()
                        task.wait() -- tunggu 1 frame biar aman
                        if child and child.Parent then
                            child:Destroy()
                        end
                    end)
                end
            end)
        end
    end
})

ExclusiveTab:CreateToggle({
	Name = "Disable Char Effect",
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

ExclusiveTab:CreateToggle({
	Name = "Disable Fishing Effect",
	Default = false,
	  Callback = function(state)
        delEffects = state

        if state then
            spawn(function()
                while delEffects do
                    local cosmetic = workspace:FindFirstChild("CosmeticFolder")
                    if cosmetic then
                        for _, child in ipairs(cosmetic:GetChildren()) do
                            -- SELAMATKAN HANYA 2 KONDISI INI:
                            -- 1. Nama EXACT "Part" (huruf kecil semua)
                            -- 2. Nama hanya angka murni tanpa huruf/simbol (contoh: 12345678)
                            local isExactPart   = child.Name == "Part"
                            local isPureNumber  = string.match(child.Name, "^%d+$")

                            if not (isExactPart or isPureNumber) then
                                child:Destroy()
                            end
                        end

                        -- Anti-respawn: langsung hancurkan yang baru muncul kalau bukan dua itu
                        cosmetic.ChildAdded:Connect(function(child)
                            if delEffects then
                                task.wait()
                                local isExactPart  = child.Name == "Part"
                                local isPureNumber = string.match(child.Name, "^%d+$")

                                if not (isExactPart or isPureNumber) then
                                    child:Destroy()
                                end
                            end
                        end)
                    end
                    task.wait(0.1) -- blitz speed, nggak ada yang lolos
                end
            end)
        end
    end
})

ExclusiveTab:CreateToggle({
	Name = "Hide Rod On Hand",
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

ExclusiveTab:CreateSection({ Name = "Blatant" })

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Config = {
    blantant = false,
    cancel = 1.55,
    complete = 0.5
}

-- === NET ===
local Net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local charge
local requestminigame
local fishingcomplete
local equiprod
local cancelinput
local ReplicateTextEffect
local BaitSpawned
local BaitDestroyed

pcall(function()
    charge               = Net:WaitForChild("RF/ChargeFishingRod")
    requestminigame       = Net:WaitForChild("RF/RequestFishingMinigameStarted")
    fishingcomplete       = Net:WaitForChild("RE/FishingCompleted")
    equiprod              = Net:WaitForChild("RE/EquipToolFromHotbar")
    cancelinput           = Net:WaitForChild("RF/CancelFishingInputs")
    ReplicateTextEffect   = Net:WaitForChild("RE/ReplicateTextEffect")
    BaitSpawned           = Net:WaitForChild("RE/BaitSpawned")
    BaitDestroyed         = Net:WaitForChild("RE/BaitDestroyed")
end)

-- === THREAD ===
local mainThread
local equipThread

-- === STATE ===
local exclaimDetected = false
local bait = 0 -- 0 = no bait, 1 = bait active

-- === LISTEN ! ===
ReplicateTextEffect.OnClientEvent:Connect(function(data)
    local char = LocalPlayer.Character
    if not char or not data.TextData or not data.TextData.AttachTo then return end

    if data.TextData.AttachTo:IsDescendantOf(char)
        and data.TextData.Text == "!" then
        exclaimDetected = true
    end
end)

-- === LISTEN BAIT SPAWN ===
if BaitSpawned then
    BaitSpawned.OnClientEvent:Connect(function(bobber, position, owner)
        if owner and owner ~= LocalPlayer then return end
        bait = 1
    end)
end

-- === LISTEN BAIT DESTROY ===
if BaitDestroyed then
    BaitDestroyed.OnClientEvent:Connect(function(bobber)
        bait = 0
    end)
end

-- === CAST ===
local function StartCast()
    -- CAST
    task.spawn(function()
        pcall(function()
            local ok = cancelinput:InvokeServer()
            if not ok then
                repeat ok = cancelinput:InvokeServer() until ok
            end

            local charged = charge:InvokeServer(math.huge)
            if not charged then
                repeat charged = charge:InvokeServer(math.huge) until charged
            end

            requestminigame:InvokeServer(1, 0.05, 1731873.1873)
        end)
    end)

    -- COMPLETE LOGIC
    task.spawn(function()
        exclaimDetected = false

        local timeout = 2
        local timer = 0

        while Config.blantant and timer < timeout do
            -- SYARAT FINAL
            if exclaimDetected and bait == 0 then
                break
            end
            task.wait(0.01)
            timer += 0.01
        end

        if not Config.blantant then return end
        if not (exclaimDetected and bait == 0) then return end

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
        bait = 0
        pcall(cancelinput.InvokeServer, cancelinput)
    end
end

ExclusiveTab:CreateToggle({
	Name = "Blatant",
	 Value = Config.blantant,
    Callback = Toggle
})

ExclusiveTab:CreateInput({
	Name = "Delay Bait",
	SideLabel = "Delay Bait",
	Placeholder = "Enter Text...",
	  Default = tostring(Config.cancel),
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            Config.cancel = n
        end
    end
})

ExclusiveTab:CreateInput({
	Name = "Delay Reel",
	SideLabel = "Delay Reel",
	Placeholder = "Enter Text...",
	 Default = tostring(Config.complete),
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            Config.complete = n
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

ExclusiveTab:CreateToggle({
	Name = "Auto Perfection",
	Default = false,
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


ExclusiveTab:CreateSection({ Name = "Webhook Fish Caught" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local httpRequest = syn and syn.request or http and http.request or http_request or (fluxus and fluxus.request) or
    request
if not httpRequest then return end

local ItemUtility, Replion, DataService
-- Perbaikan akhir untuk bagian Webhook Fish Caught (fix local registers error & deteksi lebih akurat)

-- Hapus baris ini kalau ada di atas: local ItemUtility, Replion, DataService
-- Biar tidak declare local tidak perlu

fishDB = fishDB or {}
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

-- Pindah require ke dalam pcall biar aman & tidak pakai local di scope utama
pcall(function()
    local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    local Replion = require(ReplicatedStorage.Packages.Replion)
    local DataService = Replion.Client:WaitReplion("Data")
    
    -- Simpan ke _G atau global kalau perlu dipakai di luar (webhook function)
    _G.ItemUtility = ItemUtility
    _G.DataService = DataService
end)

-- Function buildFishDatabase (sudah bagus, local di dalam loop aman karena per iteration)
function buildFishDatabase()
    table.clear(fishDB)
    local itemsContainer = ReplicatedStorage:WaitForChild("Items")
    
    for _, itemModule in ipairs(itemsContainer:GetChildren()) do
        if itemModule:IsA("ModuleScript") then
            local success, itemData = pcall(require, itemModule)
            if success and itemData and itemData.Data and itemData.Data.Type == "Fish" then
                local data = itemData.Data
                if data.Id and data.Name then
                    fishDB[data.Id] = {
                        Name = data.Name,
                        Tier = data.Tier,
                        Icon = data.Icon,
                        SellPrice = itemData.SellPrice or 0
                    }
                end
            end
        end
    end
end

-- Panggil sekali saat script load (atau saat event update kalau fish baru ditambah)
buildFishDatabase()

-- Di bagian lain webhook, pakai _G.ItemUtility & _G.DataService
-- Contoh di getInventoryFish():
function getInventoryFish()
    if not (_G.ItemUtility and _G.DataService) then return {} end
    local inventoryItems = _G.DataService:GetExpect({ "Inventory", "Items" })
    local fishes = {}
    for _, v in pairs(inventoryItems) do
        local itemData = _G.ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data.Type == "Fish" then
            table.insert(fishes, { Id = v.Id, UUID = v.UUID, Metadata = v.Metadata })
        end
    end
    return fishes
end

-- Lakukan yang sama untuk function lain yang pakai ItemUtility/DataService

-- Tambahan: Kalau game update & tambah fish baru, panggil lagi buildFishDatabase()
-- Misal di spawn loop atau button refresh

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
        Window:Notify({ Title = "Error", Content = "Webhook URL Empty" })
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

ExclusiveTab:CreateInput({
	Name = "URL Webhook",
	Placeholder = "Paste your Discord...",
	 Value = _G.WebhookURL or "",
    Callback = function(text)
        _G.WebhookURL = text
    end
})


ExclusiveTab:CreateMultiDropdown({
	Name = "Rarity Filter",
	  Values = rarityList,
    Value = _G.WebhookRarities or {},
    Callback = function(selected_options)
        _G.WebhookRarities = selected_options
    end
})
ExclusiveTab:CreateToggle({
	Name = "Send Webhook",
    Value = _G.DetectNewFishActive or false,
    Callback = function(state)
        _G.DetectNewFishActive = state
    end
})

ExclusiveTab:CreateButton({
	Name = "Test Webhook",
	Icon = "rbxassetid://7733919427", 
	Callback = function()
		Window:Notify({
			Title = "Webhook",
			Content = "Testing Webhook...",
			Duration = 2
		})
	end
})

ExclusiveTab:CreateSection({ Name = "Webhook Whatsapp Fish Caught" })

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

ExclusiveTab:CreateInput({
	Name = "Target Phone (62...)",
	Placeholder = "Nomor WhatsApp",
    Value = _G.WA_TargetPhone,
    Callback = function(t)
        _G.WA_TargetPhone = t
    end
})

ExclusiveTab:CreateMultiDropdown({
	Name = "Rarity Filter",
    Values = rarityList,
    Value = _G.WebhookRarities,
    Callback = function(opts)
        _G.WebhookRarities = opts
    end
})

ExclusiveTab:CreateToggle({
	Name = "Send WA Notification",
	  Value = _G.DetectNewFishActive,
    Callback = function(s)
        _G.DetectNewFishActive = s
    end
})

ExclusiveTab:CreateButton({
	Name = "Test Whatsapp",
	Icon = "rbxassetid://7733919427", 
 Callback = function()
        sendFonnteMessage(_G.WA_TargetPhone, "Test berhasil! Webhook WhatsApp aktif.", nil)
    end
})




MainTab:CreateSection({ Name = "Main" })

MainTab:CreateToggle({
	Name = "Auto Rod",
	Default = false,
	  Callback = function(Value) 
        _G.AutoRod = Value
        if Value then
            equipTool:FireServer(1)
        else return end
    end
})

CurrentOption = "Instant"

MainTab:CreateDropdown({
	Name = "Mode",
	Items = {"Legit", "Instant"},
	Default = "Instant",
	Callback = function(Option)
        CurrentOption = Option
    end
})

MainTab:CreateToggle({
	Name = "Auto Farm",
	Default = false,
	    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            if CurrentOption == "Instant" then
                Window:Notify({
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
                Window:Notify({
                    Title = "AutoFarm",
                    Content = "Legit Mode ON",
                    Duration = 3
                })
                task.spawn(function()
                    while _G.AutoFarm and CurrentOption == "Legit" do
                        pcall(function()
                            FishingController:RequestChargeFishingRod(Vector2.new(0, 0), true)
                             guid = FishingController.GetCurrentGUID and FishingController:GetCurrentGUID()
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
            Window:Notify({
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

MainTab:CreateInput({
	Name = "Fishing Delay",
	SideLabel = "Fishing Delay",
	Placeholder = "Contoh: 1.0",
	Default = "",
	 Callback = function(value)
        delayfishing = value
    end
})

MainTab:CreateSection({ Name = "Sell", Icon = "rbxassetid://7733793319" })

Players = game:GetService("Players")
 LocalPlayer = Players.LocalPlayer

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
            Window:Notify({
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


MainTab:CreateToggle({
	Name = "Auto Sell",
	Default = false,
	  Callback = function(v)
        if v then
            StartAutoSell()
        else
            StopAutoSell()
        end
    end
})

MainTab:CreateInput({
	Name = "Sell Delay",
	SideLabel = "Sell Delay",
	Placeholder = "Contoh: 10",
	Default = 0,
	Callback = function(txt)
        selldelay = tonumber(txt) or 0
        print("Sell delay set ke:", selldelay)
    end
})

MainTab:CreateInput({
	Name = "Sell By Count",
	SideLabel = "Sell By Count",
	Placeholder = "Contoh: 100",
	Default = "",
	 Callback = function(txt)
        countdelay = tonumber(txt) or 0
        print("Sell count set ke:", countdelay)
    end
})

MainTab:CreateSection({ Name = "Auto Favorite", Icon = "rbxassetid://7733765398" })

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
    if not rarity then return end

    local nameMatches = selectedName and table.find(selectedName, info.Data.Name)
    local rarityMatches = selectedRarity and table.find(selectedRarity, rarity)

    local isFav = favState[item.UUID] or item.Favorited or false
    local shouldFav = (nameMatches or rarityMatches) and not isFav

    if shouldFav then
        if RE.FavoriteItem then
            RE.FavoriteItem:FireServer(item.UUID, true)
            favState[item.UUID] = true
            warn("[AutoFav] Favorited:", info.Data.Name, "|", rarity)
        else
            warn("[AutoFav][ERROR] FavoriteItem RemoteEvent not found")
        end
    end
end

local function scanInventory()
    if not st.autoFavEnabled then return end
    local inv = Data:GetExpect({ "Inventory", "Items" })
    if not inv then return end

    for _, item in ipairs(inv) do
        checkAndFavorite(item)
    end
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

MainTab:CreateDropdown({
	Name = "Favorite by Name",
	Items = #fishNames > 0 and fishNames or { "No Data" },
	Placeholder = "Enter Name...",
	Default = "",
	 Callback = function(opts)
        selectedName = opts or {}
        if st.autoFavEnabled then scanInventory() end
    end
})

MainTab:CreateMultiDropdown({
	Name = "Favorite by Rarity",
	Items = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
	Default = {}, -- HARUS table
	Callback = function(opts)
		selectedRarity = opts or {}
		if st.autoFavEnabled then
			scanInventory()
		end
	end
})


MainTab:CreateToggle({
	Name = "Start Auto Favorite",
	Default = false,
    Callback = function(state)
        st.autoFavEnabled = state
        if st.autoFavEnabled then scanInventory() end
    end
})

MainTab:CreateButton({
	Name = "Unfavorite All",
	Icon = "rbxassetid://7733919427", 
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

local skipCutscene = false
local replicateConn
local stopConn
local originalPlay
local originalStop
local hooked = false


AutoTab:CreateToggle({
	Name = "Skip Cutscene",
	Default = false,
	  Callback = function(state)
        skipCutscene = state

        -- ===== Remote Events (connect sekali) =====
        if not replicateConn and RE.ReplicateCutscene then
            replicateConn = RE.ReplicateCutscene.OnClientEvent:Connect(function(...)
                if skipCutscene then
                    warn("[VoraHub] Blocked ReplicateCutscene event!")
                end
            end)
        end

        if not stopConn and RE.StopCutscene then
            stopConn = RE.StopCutscene.OnClientEvent:Connect(function()
                if skipCutscene then
                    warn("[VoraHub] Blocked StopCutscene event!")
                end
            end)
        end

        -- ===== Controller (hook sekali doang) =====
        if hooked then return end
        hooked = true

        spawn(LPH_NO_VIRTUALIZE(function()
            local ok, CutsceneController = pcall(function()
                return require(ReplicatedStorage.Controllers.CutsceneController)
            end)

            if not ok or not CutsceneController then
                warn("[VoraHub] CutsceneController not found.")
                return
            end

            originalPlay = originalPlay or CutsceneController.Play
            originalStop = originalStop or CutsceneController.Stop

            -- monitor toggle
            while true do
                if skipCutscene then
                    CutsceneController.Play = function(...)
                        warn("[VoraHub] Cutscene skipped (Play).")
                    end
                    CutsceneController.Stop = function(...)
                        warn("[VoraHub] Cutscene skipped (Stop).")
                    end
                else
                    CutsceneController.Play = originalPlay
                    CutsceneController.Stop = originalStop
                end
                task.wait(0.25)
            end
        end))
    end
})

AutoTab:CreateToggle({
	Name = "Auto Infinite Candy",
	Default = false,
	 Callback = function(state)
        if state then
            local characters = {
                "Talon", "Kenny", "OutOfOrderFoxy", "Terror", "Req",
                "Mac", "Wildes", "Jixxio", "Relukt", "Tapiobaa", "nthnth", "TheBluePurple", "Mitch"
            }
            
            for _, character in ipairs(characters) do
                local args = {
                    [1] = character,
                    [2] = "PresentChristmasDoor"
                }
                game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net:FindFirstChild("RF/SpecialDialogueEvent"):InvokeServer(unpack(args))
            end
        end
    end
})


AutoTab:CreateSection({ Name = "Auto Trade", Icon = "rbxassetid://7733955511" })

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

local tradeParagraph = AutoTab:CreateParagraph({
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

AutoTab:CreateParagraph({
	Title = "Trade Status",
	Content = "Progress : <font color='#aaaaaa'>Idle</font>"
})

local itemDropdown = AutoTab:CreateDropdown({
	Name = "Select Item",
	Items = { "None" },
	Default = "None",
	Callback = function(value)
		if not value or value == "None" then
			TradeState.selectedItem = nil
		else
			TradeState.selectedItem = value:match("^(.-) %|") or value
		end
		setStatus(nil)
	end
})

AutoTab:CreateInput({
	Name = "Amount to Trade",
	SideLabel = "Amount to Trade",
	Placeholder = "Enter Number",
	Default = "1",
	Callback = function(value)
        TradeState.tradeAmount = tonumber(value) or 1
        setStatus(nil)
    end
})

AutoTab:CreateButton({
	Name = "Refresh Fish",
	Callback = function()
		local grouped, values = getGroupedByType("Fish")
		TradeState.currentGrouped = grouped
		itemDropdown:Refresh(values)
	end
})

AutoTab:CreateButton({
	Name = "Refresh Stone",
	Callback = function()
		local grouped, values = getGroupedByType("Enchant Stones")
		TradeState.currentGrouped = grouped
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

local playerDropdown = AutoTab:CreateDropdown({
	Name = "Select Player",
	Items = playerList,
    Default = playerList[1] or "None",
	Callback = function(value)
        if value == "None" then
            TradeState.selectedPlayer = nil
        else
            TradeState.selectedPlayer = value
        end
        setStatus(nil)
    end
})


AutoTab:CreateButton({
	Name = "Refresh Player",
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

AutoTab:CreateToggle({
	Name = "Auto Trade",
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

AutoTab:CreateSection({ Name = "Auto Accept Trade", Icon = "rbxassetid://7733774602" })

AutoTab:CreateToggle({
	Name = "Auto Accept Trade",
	Default = false,
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


AutoTab:CreateSection({ Name = "Enchant Features", Icon = "rbxassetid://7733801202" })

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
      ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
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


local Paragraph = AutoTab:CreateParagraph({
	Title = "Enchanting Features",
	Content = "Rod Active = <font color='#00aaff'>Demascus Rod</font>\nEnchant Now = <font color='#ff00ff'>None</font>\nEnchant Stone Left = <font color='#ffff00'>0</font>"
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

AutoTab:CreateButton({
	Name = "Teleport to Altar",
	Icon = "rbxassetid://128755575520135",
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

AutoTab:CreateButton({
	Name = "Teleport to Second Altar",
	Icon = "rbxassetid://7733920644",
	 Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local targetCFrame = CFrame.new(1481, 128, -592)
            character:PivotTo(targetCFrame)
        end
    end
})

AutoTab:CreateDropdown({
	Name = "Target Enchant",
  Items = enchantNames,
    Value = _G.TargetEnchant or enchantNames[1],
    Callback = function(selected)
        _G.TargetEnchant = selected
    end
})

AutoTab:CreateToggle({
	Name = "Auto Enchant",
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

AutoTab:CreateButton({
	Name = "Start Double Enchant",
	Icon = "rbxassetid://7733920644",
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

PlayerTab:CreateInput({
	Name = "Walk Speed",
	SideLabel = "Contoh: 18",
	Placeholder = "Enter Speed...",
	Default = "",
	Callback = function(value)
        local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = tonumber(value) or 18
        end
    end
})

PlayerTab:CreateInput({
	Name = "Jump Power",
	SideLabel = "Contoh: 50",
	Placeholder = "Enter Power...",
	Default = "",
	Callback = function(Text)
		local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = tonumber(value) or 50
        end
    end
})

local UserInputService = game:GetService("UserInputService")

PlayerTab:CreateToggle({
	Name = "Infinite Jump",
	Default = false,
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

PlayerTab:CreateToggle({
	Name = "Noclip",
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

PlayerTab:CreateToggle({
	Name = "Radar",
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

PlayerTab:CreateToggle({
	Name = "Diving Gear",
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

PlayerTab:CreateButton({
	Name = "FlyGui V3",
	Icon = "rbxassetid://7733920644",
	 Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        Notify("Fly GUI Activated")
    end
})


ShopTab:CreateSection({ Name = "Buy Rod" })

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

ShopTab:CreateDropdown({
	Name = "Select Rod",
	  Items = rodNames,  
    Value = selectedRod,  
    Callback = function(value)  
        selectedRod = value  
    end  
})  


ShopTab:CreateButton({
	Name = "Buy Rod",
	Icon = "rbxassetid://7733920644",
	 Callback=function()  
        local key = rodKeyMap[selectedRod]  
        if key and rods[key] then  
            local success, err = pcall(function()  
                RFPurchaseFishingRod:InvokeServer(rods[key])  
            end)  
            if success then  
                Window:Notify({Title="Rod Purchase", Content="Purchased "..selectedRod, Duration=3})  
            else  
                Window:Notify({Title="Rod Purchase Error", Content=tostring(err), Duration=5})  
            end  
        end  
    end  
})

ShopTab:CreateSection({ Name = "Buy Baits" })

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

ShopTab:CreateDropdown({
	Name = "Select Bait",
	 Items = baitNames,  
    Value = selectedBait,  
    Callback = function(value)  
        selectedBait = value  
    end  
})  

ShopTab:CreateButton({
	Name = "Buy Bait",
	Icon = "rbxassetid://7733920644",
 Callback = function()  
        local key = baitKeyMap[selectedBait]  
        if key and baits[key] then  
            local success, err = pcall(function()  
                RFPurchaseBait:InvokeServer(baits[key])  
            end)  
            if success then  
                Window:Notify({Title = "Bait Purchase", Content = "Purchased " .. selectedBait, Duration = 3})  
            else  
                Window:Notify({Title = "Bait Purchase Error", Content = tostring(err), Duration = 5})  
            end  
        end  
    end  
})


ShopTab:CreateSection({ Name = "Buy Weather Event", Icon = "rbxassetid://7733955511" })

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

ShopTab:CreateMultiDropdown({
	Name = "Select Weather Events",
	Items = weatherNames,
    Default = selectedWeathers,
    Callback = function(values)
        selectedWeathers = values
        print("Selected:", table.concat(values, ", "))
    end
})


ShopTab:CreateToggle({
	Name = "Auto Buy Selected Weathers",
	SubText = "Continuously purchase all selected weather events while ON",
	Default = false,
 Callback = function(state)
        autoBuyRunning = state

        if state then
            if #selectedWeathers == 0 then
                Window:Notify({
                    Title = "⚠️ No Selection",
                    Content = "Please select at least one weather event before enabling.",
                    Duration = 3
                })
                autoBuyRunning = false
                return
            end

            Window:Notify({
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
                            Window:Notify({
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
            Window:Notify({
                Title = "🛑 Auto Buy Disabled",
                Content = "Weather auto-purchase stopped.",
                Duration = 3
            })
        end
    end
})


TeleportTab:CreateSection({ Name = "Island", Icon = "rbxassetid://7733955511" })

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
    ["Christmas island"] = Vector3.new(1138.14966, 23.5075855, 1560.2113, 0.423432112, -1.18154251e-08, -0.905927837, -3.26613829e-08, 1, -2.83083299e-08, 0.905927837, 4.1575511e-08, 0.423432112),
}

local SelectedIsland = nil

TeleportTab:CreateDropdown({
	Name = "Select Island",
	 Items = (function()
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

TeleportTab:CreateButton({
	Name = "Teleport to Island",
	Icon = "rbxassetid://7733920644",
	  Callback = function()
        if SelectedIsland and IslandLocations[SelectedIsland] and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(IslandLocations[SelectedIsland])
        end
    end
})

TeleportTab:CreateSection({ Name = "Tp To Player", Icon = "rbxassetid://7733955511" })

local SelectedPlayer = nil

local FishingDropdown = TeleportTab:CreateDropdown({
	Name = "Select Player",
	Items = (function()
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

TeleportTab:CreateButton({
	Name = "Teleport to Player",
	Icon = "rbxassetid://7733920644",
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

TeleportTab:CreateSection({ Name = "Location NPC", Icon = "rbxassetid://7733955511" })

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

TeleportTab:CreateDropdown({
	Name = "Select NPC",
	Items = (function()
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

TeleportTab:CreateButton({
	Name = "Teleport to NPC",
	Icon = "rbxassetid://7733920644",
	 Callback = function()
        if SelectedNPC and NPC_Locations[SelectedNPC] and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(NPC_Locations[SelectedNPC])
        end
    end
})

TeleportTab:CreateSection({ Name = "Event Teleporter", Icon = "rbxassetid://7733955511" })

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
	selectedEvents = type(selectedEvents) == "table" and selectedEvents or {}

	while autoEventTPEnabled do
		local sorted = {}

		for _, e in ipairs(selectedEvents) do
			local cfg = eventData[e]
			if type(cfg) == "table" then
				table.insert(sorted, cfg)
			end
		end

		table.sort(sorted, function(a, b)
			return (a.Priority or 0) < (b.Priority or 0)
		end)

		for _, config in ipairs(sorted) do
			if type(config.Locations) ~= "table" then
				continue
			end

			local foundTarget, foundPos

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
							local pos = d:IsA("BasePart") and d.Position
								or (d.PrimaryPart and d.PrimaryPart.Position)
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


TeleportTab:CreateDropdown({
	Name = "Select Fish Events",
	Items = eventNames,
	Callback = function(value)
		selectedEvents = { value } -- paksa jadi table
		print("[EventTP] Selected Event:", value)
	end
})


TeleportTab:CreateToggle({
	Name = "Auto Fish Event TP",
	Default = false,
	Callback = function(state)
		autoEventTPEnabled = state
		if state then
			task.spawn(runMultiEventTP)
		else
		end
	end
})

TeleportTab:CreateSection({ Name = "Winter Cavern (Christmas Cave Event)", Icon = "rbxassetid://7733801202" })

local autoChristmasCaveEnabled = false
local previousCFrame = nil
local wasInCave = false

local targetCaveCFrame = CFrame.new(
    457.491913, -580.58136, 8907.0459,
    0.00628850982, 2.50354376e-10, -0.999980211,
    6.77411549e-08, 1, 6.76358691e-10,
    0.999980211, -6.77440681e-08, 0.00628850982
)

local function getCaveStatus()
    local possibleTeleporters = {"CavernTeleporter", "WinterCavernTeleporter", "ChristmasCavernTeleporter", "CaveTeleporter", "WinterCaveTeleporter"}
    local teleporterGui = nil
    for _, name in ipairs(possibleTeleporters) do
        teleporterGui = workspace.Map:FindFirstChild(name)
        if teleporterGui then break end
    end
    
    if not teleporterGui then return nil end
    
    local startTeleport = teleporterGui:FindFirstChild("StartTeleport")
    if not startTeleport then return nil end
    
    local gui = startTeleport:FindFirstChild("Gui")
    if not gui then return nil end
    
    local frame = gui:FindFirstChild("Frame")
    if not frame then return nil end
    
    local possibleLabels = {"NewLabel", "Label", "TextLabel", "StatusLabel", "Title"}
    local label = nil
    for _, lname in ipairs(possibleLabels) do
        label = frame:FindFirstChild(lname)
        if label and label:IsA("TextLabel") and label.Text ~= "" then break end
    end
    
    if not label then return nil end
    
    local textLower = string.lower(label.Text)
    
    if string.find(textLower, "close") or string.find(textLower, "closed") or string.find(textLower, "coming soon") or string.find(textLower, "wait") then
        return "closed"
    elseif string.find(textLower, "open") or string.find(textLower, "enter") or string.find(textLower, "winter cavern") or string.find(textLower, "active") or string.find(textLower, "christmas cave") then
        return "open"
    end
    
    return nil
end

local function runAutoChristmasCave()
    wasInCave = false
    previousCFrame = nil
    
    while autoChristmasCaveEnabled do
        local status = getCaveStatus()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if hrp and status then
            if status == "open" then
                if not wasInCave then
                    previousCFrame = hrp.CFrame
                    hrp.CFrame = targetCaveCFrame
                    Window:Notify({
                        Title = "Winter Cavern OPEN! ❄️🎄",
                        Content = "Cave BUKA 30 menit! Auto TP masuk grind WinterFrost Shark & Icebreaker Whale!",
                        Duration = 9
                    })
                    wasInCave = true
                end
            elseif status == "closed" then
                if wasInCave and previousCFrame then
                    hrp.CFrame = previousCFrame
                    Window:Notify({
                        Title = "Winter Cavern CLOSED ⛄",
                        Content = "Cave TUTUP. Auto balik posisi lama. Next open ~1.5-2 jam!",
                        Duration = 8
                    })
                    wasInCave = false
                    previousCFrame = nil
                end
            end
        end
        
        task.wait(8)
    end
end

TeleportTab:CreateToggle({
	Name = "Auto TP Winter Cavern (Detect Open/Close)",
	Default = false,
	  Callback = function(state)
        autoChristmasCaveEnabled = state
        if state then
            task.spawn(runAutoChristmasCave)
            Window:Notify({
                Title = "Auto Detect ON ❄️",
                Content = "Monitoring Winter Cavern setiap 8 detik. Open → TP masuk, Close → balik otomatis.",
                Duration = 10
            })
        else
            Window:Notify({ Title = "Auto Detect OFF", Content = "Auto TP Winter Cavern dimatikan.", Duration = 4 })
        end
    end
})

TeleportTab:CreateButton({
	Name = "Manual TP Inside Winter Cavern",
	Icon = "rbxassetid://7733920644",
 Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            previousCFrame = hrp.CFrame
            hrp.CFrame = targetCaveCFrame
            Window:Notify({ Title = "TP Success ❄️", Content = "Berhasil masuk Winter Cavern!", Duration = 6 })
        end
    end
})

TeleportTab:CreateButton({
	Name = "Balik ke Posisi Sebelum TP",
	Icon = "rbxassetid://7733920644",
	  Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and previousCFrame then
            hrp.CFrame = previousCFrame
            Window:Notify({ Title = "Back Success", Content = "Kembali ke posisi sebelumnya!", Duration = 5 })
            previousCFrame = nil
        end
    end
})


SettingsTab:CreateSection({ Name = "General", Icon = "rbxassetid://7733954611" })

SettingsTab:CreateToggle({
	Name = "AntiAFK",
	SubText = "Prevent Roblox from kicking you when idle",
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

SettingsTab:CreateToggle({
	Name = "Auto Reconnect",
	SubText = "Automatic reconnect if disconnected",
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

SettingsTab:CreateSection({ Name = "Hide Identity Features", Icon = "rbxassetid://7743875962" })

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


SettingsTab:CreateInput({
	Name = "Hide Name",
	Placeholder = "Input Name",
	   Default = defaultHeader,
    Callback = function(value)
        customHeader = value
        if keepHidden then
            header.Text = customHeader
        end
    end
})
SettingsTab:CreateInput({
	Name = "Hide Level",
	Placeholder = "Input Level",
	   Default = defaultLevel,
    Callback = function(value)
        customLevel = value
        if keepHidden then
            levelLabel.Text = customLevel
        end
    end
})


SettingsTab:CreateToggle({
	Name = "Hide Identity (RGB Blink)",
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

player.CharacterAdded:Connect(function(newChar)
    local overhead = getOverhead(newChar)
    header = overhead.Content.Header
    levelLabel = overhead.LevelContainer.Label

    if keepHidden then
        header.Text = customHeader
        levelLabel.Text = customLevel
    end
end)

SettingsTab:CreateSection({ Name = "Server", Icon = "rbxassetid://7733955511" })

SettingsTab:CreateButton({
	Name = "Rejoin Server",
	SubText = "Reconnect to current server",
	Icon = "rbxassetid://7733920644",
 Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

SettingsTab:CreateButton({
	Name = "Server Hop",
	SubText = "Switch to another server",
	Icon = "rbxassetid://7733920644",
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
