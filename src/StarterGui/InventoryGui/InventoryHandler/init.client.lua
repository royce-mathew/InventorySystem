-- [[ Services ]] --
local rep = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local plrs = game:GetService("Players")

local lp = plrs.LocalPlayer
local modulePath = lp.PlayerScripts:WaitForChild("PlayerModule")["BackpackModule"]
local backpackModule = require(modulePath)
local inventoryIcon = backpackModule.InventoryIcon
local mouse = lp:GetMouse()

local itemModelsFolder = rep:WaitForChild("ItemModels")

-- [[ Events ]] -- 
local ev = rep:WaitForChild("ClientEvents")
local invEvent = ev.InventoryEvent
local refreshInv = ev.RefreshInventory

-- [[ Objects ]] -- 
local holderFrame = script.Parent:WaitForChild("MainFrame")
local mainFrame = holderFrame.InventoryFrame
local objectiveFrame = holderFrame["Objective List"]
local subObjectiveFrame = objectiveFrame.InfoFrame["Objectives List"]
local infoFrame = mainFrame.InfoFrame
local lblTitle = infoFrame.Title
local lblDesc = infoFrame.Desc

local objectiveCopy = script.Objective

local rightClickFrame = holderFrame.RightClick
local equipButton = rightClickFrame.EquipBtn
local removeButton = rightClickFrame.DeleteBtn

local viewport = holderFrame.vpf

-- A dict list set by image_box : image
local mainInvList = {}
local objectiveList = {} -- A list full of objectives, setup{id : "objective"}

local itemInfo = require(rep:WaitForChild("ItemInfo"))

local vpRotationModule = require(script.ViewportRotation)

-- For TAB
local isOpen = false
local onCooldown = false
-- For Objective
local isObjectiveCooldown = false

-- Current values | Used to check which values are equipped / being used by user
local currentImageButton = nil; -- Checks which mousebutton its on | Also used to check if the mouse is actually on a button
local currentlyEquipped = nil; -- The one selected by the user when left clicked
local isMouseOnButton = nil; -- Tells the program if mouse is on a button - used to hide the rightclick menu

-- [[ Functions Needed for tweens ]] -- 
local function getBlur() -- Checks if a blur exists, if one doesn't, it creates a new one with 0 size
	local blur = lighting:FindFirstChild("Blur")
	if not blur then
		blur = Instance.new("BlurEffect", lighting)
		blur.Size = 0
	end
	return blur
end

-- Variable for blur
local blur = getBlur()

-- [[ Tween Info ]] -- 
-- [[ Tweening Styles ]] -- 
local tweenStyle1 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenStyle2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
-- [[ Tween List ]] -- 
local tweenSet = {
	["0A"] = {
		ts:Create(viewport, tweenStyle2, {ImageTransparency = 1}),
		ts:Create(lblTitle, tweenStyle2, {TextTransparency = 1, TextStrokeTransparency = 1}),
		ts:Create(lblDesc, tweenStyle2, {TextTransparency = 1, TextStrokeTransparency = 1})
	},
	["0B"] = {
		ts:Create(viewport, tweenStyle2, {ImageTransparency = 0}),
		ts:Create(lblTitle, tweenStyle2, {TextTransparency = 0, TextStrokeTransparency = 0.8}),
		ts:Create(lblDesc, tweenStyle2, {TextTransparency = 0.32, TextStrokeTransparency = 0.8})
	},
	["1A"] = {
		ts:Create(holderFrame, tweenStyle1, {BackgroundTransparency = 0.75}),
		ts:Create(mainFrame, tweenStyle1, {Position = UDim2.new(1, 0, 1, 0)}),
		ts:Create(blur, tweenStyle1, {Size = 20}),
		ts:Create(viewport, tweenStyle1, {ImageTransparency = 0})
	},
	["1B"] = {
		ts:Create(holderFrame, tweenStyle1, {BackgroundTransparency = 1}),
		ts:Create(mainFrame, tweenStyle1, {Position = UDim2.new(1.5, 0, 1, 0)}),
		ts:Create(blur, tweenStyle1, {Size = 0}),
		ts:Create(viewport, tweenStyle1, {ImageTransparency = 1})
	},
	["objectiveFrameA"] = {
		ts:Create(objectiveFrame.InfoFrame.Frame1, tweenStyle1, {BackgroundTransparency = 1}),
		ts:Create(objectiveFrame.InfoFrame, tweenStyle1, {BackgroundTransparency = 1}),
		ts:Create(objectiveFrame.InfoFrame.Frame2, tweenStyle1, {BackgroundTransparency = 1}),
		ts:Create(objectiveFrame.InfoFrame.Title, tweenStyle1, {TextTransparency = 1, TextStrokeTransparency = 1}),
	},
	["objectiveFrameB"] = {
		ts:Create(objectiveFrame.InfoFrame.Frame1, tweenStyle1, {BackgroundTransparency = 0.5}),
		ts:Create(objectiveFrame.InfoFrame, tweenStyle1, {BackgroundTransparency = 0}),
		ts:Create(objectiveFrame.InfoFrame.Frame2, tweenStyle1, {BackgroundTransparency = 0.5}),
		ts:Create(objectiveFrame.InfoFrame.Title, tweenStyle1, {TextTransparency = 0, TextStrokeTransparency = 0.81}),
	}
}


--[[ Functions ]] -- 
--[[
	These are local functions for the events later on.
	Description is above the function declaration
]] -- 
-- PlayTweenSet Function: Plays the tween set as a group
local function playTweenSet(id)
	for _,v in next, tweenSet[id] do -- Loop through the playTweenSet list and play every tween
		v:Play()
	end
	return tweenSet[id][1]
end
-- PlayObjectiveFrameTweenSet: Plays the Tween in / out for the objective frame
local function playObjectiveFrameTweenSet(show)
	local tween;
	if show then
		tween = playTweenSet("objectiveFrameB")
		for _,v in next, subObjectiveFrame:GetChildren() do
			if v:IsA("Frame") then
				ts:Create(v.Frame, tweenStyle1, {BackgroundTransparency = 0}):Play()
				ts:Create(v["Desc"], tweenStyle1, {TextTransparency = 0, TextStrokeTransparency = 0.81}):Play()
			end
		end
	else
		tween = playTweenSet("objectiveFrameA")
		for _,v in next, subObjectiveFrame:GetChildren() do
			if v:IsA("Frame") then
				ts:Create(v.Frame, tweenStyle1, {BackgroundTransparency = 1}):Play()
				ts:Create(v["Desc"], tweenStyle1, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			end
		end
	end
	return tween;
end
-- PlayObjectiveAdded Function: Plays the objective added tween
local function playObjectiveAdded()
	objectiveFrame["InfoFrame"]["Title"].Text = "New Objective Added"
	playObjectiveFrameTweenSet(true).Completed:Wait()
	task.wait(5)
	if not isOpen then
		playObjectiveFrameTweenSet(false).Completed:Wait()
	end
	objectiveFrame["InfoFrame"]["Title"].Text = "Objectives"
	isObjectiveCooldown = false
end
-- GetViewportCamera Function: Gets the camera inside the viewport, or makes a new camera
local function getViewportCamera() 
	local cam = viewport:FindFirstChildOfClass("Camera")
	if not cam then
		cam = Instance.new("Camera", viewport)
		viewport.CurrentCamera = cam
	end
	
	return cam
end
-- GetCurrentItemModel Function: Checks if there is a itemmodel inside the viewport
local function getCurrentItemModel() 
	return viewport:FindFirstChildOfClass("Model")
end
-- DeleteItemModel Function: Deletes the itemmodel if it exists
local function deleteItemModel() 
	local item = getCurrentItemModel()
	if item then item:Destroy() end
end
-- EmptyImageButton Function: sets the imagebutton value is a empty list
local function emptyImageButton(imageButton)
	mainInvList[imageButton] = {}
end
-- SetBackgroundToDefault Function: Sets the image backgrounds as white
local function setBackgroundToDefault()
	for _, v in next, mainFrame:GetChildren() do
		if v:IsA("ImageButton") then
			v.BackgroundColor3 = Color3.fromRGB(255,255,255)
		end
	end
end
-- UpdateGui Method, Updates the objectiveFrame Gui
local function updateObjectiveGui()
	-- Clear all children
	for _,v in next, subObjectiveFrame:GetChildren()  do
		if v:isA("Frame") then
			v:Destroy()
		end
	end

	for _, v in next, objectiveList do
		local objectiveLocalCopy = objectiveCopy:Clone()
		objectiveLocalCopy.Desc.Text = v
		objectiveLocalCopy.Parent = subObjectiveFrame
	end
end

-- Show / Hide the Inventory
local function openCloseInventory()
	if not isOpen and not onCooldown then -- Put it inside the view
		onCooldown = true
		isOpen = true
		inventoryIcon:lock() -- Disable user input for inventory icon
		
		task.defer(function()
			lp:GetMouse().Icon = "http://www.roblox.com/asset/?id=68308747"
		end)


		playTweenSet("1A") -- Play Tween Set 1A
		playObjectiveFrameTweenSet(true).Completed:Wait() -- Wait until tween finishes
		
		inventoryIcon:unlock() -- Enable user input for inventory icon
		onCooldown = false

	elseif isOpen and not onCooldown then -- Put it back outside the view
		onCooldown = true
		isOpen = false
		inventoryIcon:lock()
		
		mouse.Icon = "http://www.roblox.com/asset/?id=7916316651" 
		playTweenSet("1B")
		playObjectiveFrameTweenSet(false).Completed:Wait()
		
		inventoryIcon:unlock()
		onCooldown = false
	end
end

-- Add Objective Function: Adds an objective to the list and shows the gui
_G.AddObjective = function(objectiveText, id)
	if isObjectiveCooldown == false and objectiveList[id] == nil then
		objectiveList[id] = objectiveText
		updateObjectiveGui()
		if not isOpen then 
			isObjectiveCooldown = true
			task.spawn(playObjectiveAdded)
		end
	end
end
-- Clear Objective Function: Removes the objective from the list and shows gui update
_G.ClearObjective = function(id)
	objectiveList[id] = nil
	updateObjectiveGui()
end


inventoryIcon.selected:Connect(function()
	openCloseInventory()
end)
inventoryIcon.deselected:Connect(function()
	openCloseInventory()
end)

-- InputBegan Event: Listens for input
uis.InputBegan:Connect(function(input, gameProcessed)
	--if not gameProcessed then return end -- Don't process input while user is not in game
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local keyPressed = input.KeyCode

		if keyPressed == Enum.KeyCode.Tab then -- Check if keypressed is Tab
			
		end
	end
end)

-- [[ Main Loop ]] -- 
--[[
	Main loop for mouse events and etc, 
	
	Doesn't need to be called in a function because it constantly checks an list updated in another thread
]] -- 
for _,v in next, mainFrame:GetChildren() do
	if v:IsA("ImageButton") then
		-- Set the defaultList
		emptyImageButton(v)

		v.MouseButton1Click:Connect(function()
			-- Check if slot is already occupied
			
			local subList = mainInvList[v]
			if not subList["itemName"] or onCooldown then return end
			
			-- Tween frames going transparent
			playTweenSet("0A")
			
			-- Check if the item is actually there, and that we dont equip the currently equipped item again
			if subList["itemName"] ~= "" and currentlyEquipped ~= subList["itemName"] then
				-- Check if the item is valid\
				onCooldown = true
				setBackgroundToDefault()
				v.BackgroundColor3 = Color3.fromRGB(0,0,0) -- Set background color to black to signify that the item is selected
				tweenSet["0A"][1].Completed:Wait() -- wait until the tweens are completed

				deleteItemModel()
				
				lblTitle.Text = subList["itemName"]
				lblDesc.Text = subList["itemDesc"]
				
				-- Clone item and set inside viewport
				local modelClone = subList["itemModel"]:Clone()
				modelClone.Parent = viewport
				modelClone:SetPrimaryPartCFrame(CFrame.new())
				
				
				-- Tween frames going transluscent
				playTweenSet("0B")
				
				
				-- Set camera to item position
				local cam = getViewportCamera()
				cam.CFrame = CFrame.new(modelClone.PrimaryPart.Position + Vector3.new(0,0,4), modelClone.PrimaryPart.Position) -- - Vector3.new(0,0,-0.1)
				
				vpRotationModule:Enable(viewport)
				
				-- Wait until tween is completed to set debounce
				tweenSet["0B"][3].Completed:Wait()
				onCooldown = false
				currentlyEquipped = subList["itemName"]	
				
			else
				onCooldown = true
				v.BackgroundColor3 = Color3.fromRGB(255,255,255) -- Set color back to white
				
				tweenSet["0A"][3].Completed:Wait()
				deleteItemModel()

				vpRotationModule:Disable(viewport)
				onCooldown = false
				currentlyEquipped = nil
				
			end

		end)
		
		-- RightClick Event : Event fired when user rightclicks on one of the buttons
		v.MouseButton2Click:Connect(function()
			currentImageButton = v
			
			local subList = mainInvList[v]
			if subList["itemName"] and subList["itemName"] ~= "" then
				if subList["itemEquipped"] then
					equipButton.Text = " Unequip"
				else
					equipButton.Text = " Equip"
				end
				-- Make the rightclick frame visible
				rightClickFrame.Visible = true
				rightClickFrame.Position = UDim2.new(mouse.X / mouse.ViewSizeX, 0, mouse.Y / mouse.ViewSizeY, 0)
			else -- Frame does not contain anything
				rightClickFrame.Visible = false
			end
		end)
		
		-- These events help tell when the rightclick frame should actually appear
		v.MouseLeave:Connect(function()
			isMouseOnButton = nil
		end)
		v.MouseEnter:Connect(function()
			isMouseOnButton = true
		end)
		
	end
end

refreshInv.OnClientEvent:Connect(function(playerData)
	-- Keeping a list of index because 
	local index = 0;
	for i, v in next, playerData do
		index += 1
		
		local imageButton = mainFrame["t"..index]
		local amount = imageButton.amount
		imageButton.Image = itemInfo[i].image
		
		if v.amount <= 1 then
			amount.Text = ""
		else
			amount.Text = v.amount
		end

		mainInvList[imageButton] = {
			["itemName"] = itemInfo[i].name,
			["itemDesc"] = itemInfo[i].desc,
			["itemImage"] = itemInfo[i].image,
			["itemType"] = itemInfo[i]._type,
			["itemModel"] = itemInfo[i].model,
			["itemAmount"] = v.amount,
			["itemEquipped"] = v.equipped,
		}
	end
end)

-- Check if the rightclick is pressed
mouse.Button2Down:Connect(function()
	if not isMouseOnButton then
		rightClickFrame.Visible = false
	end
end)

-- EquipButton Event: Fired when the equip button is clicked while hovering over a button
equipButton.MouseButton1Click:Connect(function()
	local currItem =  mainInvList[currentImageButton] -- Index the current item
	rightClickFrame.Visible = false -- Make the rightclick frame invisible
	
	-- Check itemtype
	if currItem["itemType"] == "Main" then
		if currItem["itemEquipped"] then
			equipButton.Text = " Equip"
			invEvent:FireServer(1, currItem["itemName"]) -- Fire item equip / unequip event
			print("Unequipped: ", currItem["itemName"])
		else
			equipButton.Text = " Unequip"
			invEvent:FireServer(0, currItem["itemName"])
			print("Equipped: ", currItem["itemName"])
		end
	end
end)

-- RemoveButton Event: Currently has no code
removeButton.MouseButton1Click:Connect(function()
	rightClickFrame.Visible = false -- No use for remove button currently
end)
