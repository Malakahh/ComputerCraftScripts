-- Note: All coordinates and directions are local to the turtle, and does not reflect cardinal directions
-- Turtles always move one layer above where they are building

-- Blueprint here


local fuelSlot = 16
local lowFuelThreshold = 100
local facingDirection = "East"

local patternMaterials = {}
local pos = {
	["x"] = 0,
	["y"] = 0,
	["z"] = 0
}

local function ValidatePatterns()
	local numPatterns = #blueprint

	local patternIdx
	for patternIdx = 1, numPatterns, 1 do
		local pattern = blueprint[patternIdx]["pattern"]
		local maxZ = #pattern

		local z
		for z = 1, maxZ, 1 do
			local maxX = #pattern[z]

			local x
			for x = 1, maxX, 1 do
				local inventoryIdx = pattern[z][x]

				if inventoryIdx ~= 0 then
					local data = turtle.getItemDetail(inventoryIdx)

					if data == nil then
						return false
					end

					if patternMaterials[inventoryIdx] == nil then
						patternMaterials[inventoryIdx] = data.name
					elseif patternMaterials[inventoryIdx] ~= data.name then
						return false
					end
				end
			end
		end 
	end

	return true
end

local function doRefuel()
	local currentLevel = turtle.getFuelLevel()

	if currentLevel <= lowFuelThreshold then
		print("Refuelling")
		turtle.select(fuelSlot)
		turtle.refuel()
	end
end

local function forward()
	doRefuel()
	turtle.forward()
	if facingDirection == "East" then
		pos.x = pos.x + 1
	elseif facingDirection == "West" then
		pos.x = pos.x - 1
	elseif facingDirection == "South" then
		pos.y = pos.y + 1
	elseif facingDirection == "North" then
		pos.y = pos.y - 1
	end
end

local function back()
	turtle.back()
	if facingDirection == "East" then
		pos.x = pos.x - 1
	elseif facingDirection == "West" then
		pos.x = pos.x + 1
	elseif facingDirection == "South" then
		pos.y = pos.y - 1
	elseif facingDirection == "North" then
		pos.y = pos.y + 1
	end
end

local function up()
	turtle.up()
	pos.z = pos.z + 1
end

local function down()
	turtle.down()
	pos.z = pos.z - 1
end

local function turnRight()
	turtle.turnRight()
	if facingDirection == "East" then
		facingDirection = "South"
	elseif facingDirection == "South" then
		facingDirection = "West"
	elseif facingDirection == "West" then
		facingDirection = "North"
	elseif facingDirection == "North" then
		facingDirection = "East"
	end
end

local function turnLeft()
	turtle.turnLeft()
	if facingDirection == "East" then
		facingDirection = "North"
	elseif facingDirection == "North" then
		facingDirection = "West"
	elseif facingDirection == "West" then
		facingDirection = "South"
	elseif facingDirection == "South" then
		facingDirection = "East"
	end
end

local function FaceTowards(direction)
	while facingDirection ~= direction do
		turnRight()
	end
end

local function MoveToCoord(x, y, z)
	if x ~= nil and pos.x ~= x then
		if pos.x > x then
			FaceTowards("West")
		elseif pos.x < x then
			FaceTowards("East")
		end

		while pos.x ~= x do
			forward()
		end
	end

	if y ~= nil and pos.y ~= y then
		if pos.y > y then
			FaceTowards("North")
		elseif pos.y < y then
			FaceTowards("South")
		end

		while pos.y ~= y do
			forward()
		end
	end

	if z ~= nil and pos.z ~= z then
		while pos.z ~= z do
			if pos.z > z then
				down()
			elseif pos.z < z then
				up()
			end			
		end
	end
end

local function BuildOne(idxToPlace)
	local blockAhead = turtle.inspect()
	if blockAhead then
		turtle.dig()
	end

	forward()

	local blockBelow = turtle.inspectDown()
	if blockBelow then
		turtle.digDown()
	end

	if idxToPlace ~= nil and idxToPlace ~= 0 then
		turtle.select(idxToPlace)
		turtle.placeDown()
	end
end

local function ValidateInventory()
	local i
	for i = 1, 16, 1 do
		local data = turtle.getItemDetail(i)
		if data ~= nil then
			if patternMaterials[i] ~= nil and patternMaterials[i] ~= data.name then
				print("Found: " .. tostring(data.name) .. " in slot " .. tostring(i) .. " Expected: " .. tostring(patternMaterials[i]))
				print("Inventory not valid")
				return false
			end
		end
	end

	return true
end

local function ConstructPattern(pattern)
	MoveToCoord(0, 0)

	local maxZ = #pattern
	local z
	for z = 1, maxZ, 1 do
		local startX, endX, increment

		if z % 2 == 1 then
			startX = 1
			endX = #pattern[z]
			increment = 1

			FaceTowards("East")
		else
			startX = #pattern[z]
			endX = 1
			increment = -1

			FaceTowards("West")
		end

		print("startX: " .. startX .. " endX: " .. endX .. " increment: " .. increment)

		local x
		for x = startX, endX, increment do
			print("x: " .. x)
			local idxToPlace = pattern[z][x]

			if not ValidateInventory() then
				return false
			end

			BuildOne(idxToPlace)
		end

		if z + 1 ~= maxZ then
			FaceTowards("South")

			local idxToPlace = pattern[z + 1][x]

			if not ValidateInventory() then
				return false
			end

			BuildOne(idxToPlace)
		end
	end

	return true
end

local function BuildBlueprint(layers)
	if ValidatePatterns() then
		print("Pattern is valid")
		print("Building " .. layers .. " layers")

		local i
		while true do
			local patternIdx
			for patternIdx = 1, #blueprint, 1 do
				local successiveIdx
				for successiveIdx = 1, blueprint[patternIdx]["successive"], 1 do
					local success = ConstructPattern(blueprint[patternIdx]["pattern"])

					print("Constructed pattern: " .. success)

					if not success then
						return
					end

					i = i + 1

					if i == layers then
						return
					end
				end
			end
		end
	else
		print("Pattern validation failed")
	end
end

local userInput = io.read()
BuildBlueprint(tonumber(userInput))

