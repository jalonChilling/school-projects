-- variables
local strChunkStorageX = 0b0000_0000_1111_1111
local strChunkStorageY = 0b1111_1111_0000_0000

local hexReplacements = {
	"a", -- 1
	"b", -- 2
	"c", -- 3
	"d", -- 4
	"e", -- 5
	"f", -- 6
	"g", -- 7
	"h", -- 8
	"i", -- 9
	"j", -- a
	"k", -- b
	"l", -- c
	"m", -- d
	"n", -- e
	"o", -- f
}
-- functions
local function intToHex(number: number): string
	return string.format("%04x", number)
end

local function hexToInt(hexStr: string): number
	return tonumber(hexStr, 16)
end

local function encode(strValue: string, byteOffset: number): string
	byteOffset = math.clamp(byteOffset, 0, 16) or 0
	local result = ""
	local currentPackedStr = 0

	for _, value in string.split(strValue, "") do -- packs the two ascii string into hex chunk
		local valueByte = string.byte(value)

		if valueByte > 127 then continue end -- checks if valueByte don't exceed 127
		if not currentPackedStr then
			currentPackedStr = (bit32.band(valueByte, strChunkStorageX)) -- packs first ascii string
		else
			currentPackedStr += (bit32.band(bit32.lshift(valueByte, 8), strChunkStorageY)) -- packs second ascii string

			result ..= intToHex(currentPackedStr - (byteOffset * 2)) -- adds the hex chunk into result
			currentPackedStr = nil -- resets packed string
		end
	end

	if currentPackedStr then -- adds the left out packed string
		result ..= intToHex(currentPackedStr - (byteOffset * 2))
	end
	return result
end

local function decode(encodedStr: string, byteOffset: number): string
	byteOffset = math.clamp(byteOffset, 0, 16) or 0
	local result = ""

	string.gsub(encodedStr, "....", function(value) -- iterates to the hex chunks
		local packedStr = hexToInt(value) + (byteOffset * 2) -- converts hex to integer

		result ..= string.char(
			bit32.extract(packedStr, 0, 8),
			bit32.extract(packedStr, 8, 8)
		) -- unpacks the chunk into ascii string
	end)
	return result
end
-- main
local test = encode("Hello World!", 16)
print(test)
print(decode(test, 16))