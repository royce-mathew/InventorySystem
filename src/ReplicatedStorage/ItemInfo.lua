local rep = game:GetService("ReplicatedStorage")
local im = rep:WaitForChild("ItemModels")

local itemsInfo = {
	["Apple"] = {
		name = "Apple",
		desc = "A bright red apple",
		_type = "Main",
		stackable = true,
		max_stack = 3,
		image = "rbxassetid://421999019",
		model = im.Apple,
	},
	
	["Lighter"] = {
		name = "Lighter",
		desc = "Provides a source of light. Unlimited duration. May also be used to light candles",
		_type = "Main",
		stackable = false,
		max_stack = 1,
		image = "rbxassetid://1543254463",
		model = im.Lighter,
	},
	["Pear"] = {
		name = "Pear",
		desc = "A bright green pear",
		_type = "Stackable",
		stackable = false,
		max_stack = 0,
		image = "rbxassetid://324736610",
		model = im.Pear
	}
}

return itemsInfo
