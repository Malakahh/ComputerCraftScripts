-- Title:		Updater
-- Version:		1.1
-- Author:		Malakahh
-- All Rights Reserved

local files = {
	Updater = "https://raw.githubusercontent.com/Malakahh/ComputerCraftScripts/master/Updater.lua",
	BlueprintBot = "https://raw.githubusercontent.com/Malakahh/ComputerCraftScripts/master/BlueprintBot.lua",
}

local function WriteToFile(name, content)
	local file = fs.open(name, "w")
	file.write(content)
	file.close()
end

local function UpdateFile(file)
	local url = files[tostring(file)]
	http.request(url)

	local requesting = true
	while requesting do
		local event, _, handler = os.pullEvent()

		if event == "http_success" then
			local text = sourceText.readAll()

			print("File successfully gotten. Writing to file: " .. file)

			WriteToFile(file, text)
			requesting = false;
			return true
		elseif event == "http_failure" then
			print("Unable to connect to " .. url)
			requesting = false;
			return false
		end
	end
end

--- Start ---
print("*** Updater ***")
print("Please enter command:")
local userInput = io.read()
if userInput == "help" then
	print("- \"help\":\tShows this message")
	print("- \"list\":\tLists all available files")
	print("- <file>:\tThe file to update")
elseif userInput == "list" then
	print("Found the following files:")
	for k,_ in pairs(files) do
		print(k)
	end
elseif UpdateFile(userInput) == false then -- attempts to update a single file. 
	print("Error: wrong command or file doesn't exist. Use the \"help\"-command to see all available commands.")
end