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

	for patternIdx = 1, numPatterns, 1 do
		local pattern = blueprint[patternIdx]["pattern"]
		local maxZ = #pattern

		for z = 1, maxZ, 1 do
			local maxX = #pattern[z]

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
		turtle.refuel(1)
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
		pos.z = pos.z + 1
	elseif facingDirection == "North" then
		pos.z = pos.z - 1
	end
end

local function back()
	doRefuel()
	turtle.back()
	if facingDirection == "East" then
		pos.x = pos.x - 1
	elseif facingDirection == "West" then
		pos.x = pos.x + 1
	elseif facingDirection == "South" then
		pos.z = pos.z - 1
	elseif facingDirection == "North" then
		pos.z = pos.z + 1
	end
end

local function up()
	doRefuel()
	turtle.up()
	pos.y = pos.y + 1
end

local function down()
	doRefuel()
	turtle.down()
	pos.y = pos.y - 1
end

local function turnRight()
	doRefuel()
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
	doRefuel()
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
	if z ~= nil and pos.z ~= z then
		if pos.z > z then
			FaceTowards("North")
		elseif pos.z < z then
			FaceTowards("South")
		end

		while pos.z ~= z do
			forward()
		end
	end

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
		while pos.y ~= y do
			if pos.y > y then
				down()
			elseif pos.y < y then
				up()
			end			
		end
	end

	print("finished moving to (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")")
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

	if idxToPlace ~= nil then
		if idxToPlace ~= 0 then
			turtle.select(idxToPlace)
			turtle.placeDown()
		end
	else
		print("Attempted to place index: " .. tostring(idxToPlace))
	end
end

local function ValidateInventory()
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
	BuildOne(pattern[1][1])

	local maxZ = #pattern
	for z = 1, maxZ, 1 do
		local startX, endX, increment

		if z % 2 == 1 then
			startX = 2
			endX = #pattern[z]
			increment = 1

			FaceTowards("East")
		else
			startX = #pattern[z] - 1
			endX = 1
			increment = -1

			FaceTowards("West")
		end

		for x = startX, endX, increment do

			local idxToPlace = pattern[z][x]

			if not ValidateInventory() then
				return false
			end

			BuildOne(idxToPlace)
		end

		if z + 1 <= maxZ then
			FaceTowards("South")
			local idxToPlace = pattern[z + 1][endX]

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

		local i = 0
		while true do
			for patternIdx = 1, #blueprint, 1 do
				for successiveIdx = 1, blueprint[patternIdx]["successive"], 1 do
					if i == layers then
						MoveToCoord(0,0,0)
						return
					end

					MoveToCoord(0, i, 0)
					FaceTowards("East")

					i = i + 1

					turtle.digUp()
					up()

					local success = ConstructPattern(blueprint[patternIdx]["pattern"])

					if not success then
						print("Failed to construct pattern")
						return
					end
					
				end
			end
		end
	else
		print("Pattern validation failed")
	end
end

print("Please input number of layers to build:")
local userInput = io.read()
BuildBlueprint(tonumber(userInput))

