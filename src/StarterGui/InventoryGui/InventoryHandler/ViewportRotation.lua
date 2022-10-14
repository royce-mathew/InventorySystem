local UserInputService = game:GetService("UserInputService")
local LastMousePos = nil  -- Used to calculate how far mouse has moved
local mouse = game.Players.LocalPlayer:GetMouse()

local viewportRotation = {}

function viewportRotation:Enable(viewportFrame)
	
	local viewportModel = viewportFrame:FindFirstChildWhichIsA("Model")
	if not viewportModel then return end

	local viewport = setmetatable(viewportRotation, 
		{
			__index = {
				inputChanged = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
					if gameProcessedEvent or not viewportModel.PrimaryPart then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement then -- runs every time mouse is moved
						if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then -- makes sure player is holding down right click

							local CurrentMousePos = Vector2.new(mouse.X,mouse.Y)
							local change = (CurrentMousePos - LastMousePos)/2 -- calculates distance mouse traveled (/5 to lower sensitivity)

							-- The angles part is weird here because of how the cube happens to be oriented. The angles may differ for other sections
							viewportModel:SetPrimaryPartCFrame(
								viewportModel:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(change.Y), math.rad(change.X), 0)
							)

							LastMousePos = CurrentMousePos
							
							-- This line is needed because it makes the rotaiton relative to the original position
							viewportModel.PrimaryPart.Orientation = Vector3.new(0, 0, 0)
						end
					end
				end),

				inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
					if gameProcessedEvent then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then -- player starts dragging
						LastMousePos = Vector2.new(mouse.X, mouse.Y)
					end
				end),

				inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
					if gameProcessedEvent then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then -- player stops dragging
						LastMousePos = nil
					end
				end)
			}
		}
	)
	return viewport
end

function viewportRotation:Disable(viewportFrame)
	local sucess, response = pcall(function()
		self.inputChanged:Disconnect()
		self.inputBegan:Disconnect()
		self.inputEnded:Disconnect()
	end)

	self.inputChanged = nil
	self.inputBegan = nil
	self.inputEnded = nil
end

return viewportRotation
