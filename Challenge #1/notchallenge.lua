local signature, seperator = "­", "\127"

local charIndexes = {}
local indexChars = {}

local function addCharLetter(charIndex, charValue)
	charIndexes[tostring(charIndex)] = charValue
	indexChars[charValue] = tostring(charIndex)
end

do
	local currentRealIndex = 0
	for index = 1, 26 do
		local charValue = string.char(index + 64)
		local charValue2 = string.char(index + 96)
		local charIndex = (index + currentRealIndex)

		addCharLetter(charIndex, charValue)
		addCharLetter(charIndex + 1, charValue2)
		currentRealIndex = currentRealIndex + 1
	end

	for index = 1, 10 do
		local charValue = string.char(index + 47)
		local charIndex = (index + (currentRealIndex * 2))

		addCharLetter(charIndex, charValue)
	end

	addCharLetter(0, "")
	addCharLetter(63, " ")
end

--[[for index = 1, 255 do
	print(index, string.char(index))
end--]]

local str_split = string.split or function(str, seperator)
	local output = {}
	local currentSep = ""

	for index = 1, #str do
		local currentStr = string.sub(str, index, index)

		if (not seperator) or (seperator == "") then
			output[#output + 1] = currentStr
		else
			if (currentStr == seperator) then
				output[#output + 1] = currentSep
				currentSep = ""
			else
				currentSep = currentSep .. currentStr
			end
		end
	end
	if currentSep ~= output[#output] then --and currentSep ~= "" then
		output[#output + 1] = currentSep
	end
	return output
end

local function encode(str)
	local output = ""
	local strList = str_split(str, "")

	for index = 1, #strList do
		local letter = indexChars[strList[index]] or strList[index]

		output = output .. letter .. seperator
	end
	output = string.sub(output, 1, #output - 1)
	output = signature .. output
	return output
end

local function decode(str)
	if string.sub(str, 1, #signature) == signature then
		str = string.sub(str, 3, #str)
	local output = ""
		local strChars = str_split(str, seperator)

		for index = 1, #strChars do
			local currentStr = strChars[index]
			currentStr = charIndexes[currentStr] or currentStr
			output = output .. currentStr
		end
		return output
	else
		return error("Signature verification failed!", 0)
	end
end

local sTime = os.clock()
local input = encode("lorem ipsum dolor amet")
print(input)
print(decode(input))
print("Time elapsed:", os.clock() - sTime)
--input below needs to be remapped to the new encode
--print(decode("9/2/9/7/9/14 13/15 1/14/7 9/25/15/14/7 11/1/16/23/1 7/1/25/1 14/7 9/25/15/14/7 19/1/18/9/12/9"))