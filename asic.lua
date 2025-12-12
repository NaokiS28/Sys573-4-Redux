--[[
/*
 * GenV - Copyright (C) 2025 NaokiS, spicyjpeg
 * asic.lua - Created on 08-12-2025
 *
 * GenV is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * GenV is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * GenV. If not, see <https://www.gnu.org/licenses/>.
 */
]]

Sys573.ASIC = {
	m_output = 0xFFFF,
	m_input = { 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF }
}

Sys573.constants.ASIC = {
	IN_DIP_JVS_CART = 1,
	IN_MISC = 2,
	IN_JAMMA = 3,
	IN_JVS = 4,
	IN_EXT_1 = 5,
	IN_EXT_2 = 6,
	OUT_ADC_DI = 0,
	OUT_ADC_CS = 1,
	OUT_ADC_CLK = 2,
	OUT_COIN_COUNTER1 = 3,
	OUT_COIN_COUNTER2 = 4,
	OUT_AMP_MUTE = 5,
	OUT_CDDA_MUTE = 6,
	OUT_SPU_MUTE = 7,
	OUT_JVS_RESET = 8
}

function Sys573.ASIC:setLUTASIC()
	local readLUT = PCSX.getReadLUT()

	if (readLUT == nil or writeLUT == nil) then return end

	--for i = 1, #self.m_input do
	--		readLUT[(4 * i) + 0x1f400004] = ffi.cast('uint16_t*', self.m_input[i])
	--	end

	--ffi.copy(readLUT + 0x9f00, readLUT + 0x1f00, 4 * ffi.sizeof("void *"))
	--ffi.copy(readLUT + 0xbf00, readLUT + 0x1f00, 4 * ffi.sizeof("void *"))


	--readLUT[0x1f04] = ffi.cast('uint8_t*', self.m_detachedMemory)
	--readLUT[0x1f05] = ffi.cast('uint8_t*', self.m_detachedMemory)

	--ffi.copy(readLUT + 0x9f04, readLUT + 0x1f04, 2 * ffi.sizeof("void *"))
	--ffi.copy(readLUT + 0xbf04, readLUT + 0x1f04, 2 * ffi.sizeof("void *"))
end

function Sys573.ASIC:read(address)
	address = address / 4
	if (address ~= 0) then
		print(string.format('Read ASIC: @ 0x%02X', address))
		return self.m_input[address]
	end
end

function Sys573.ASIC:writeOutputs(address, value)
	address = address / 4
	if (address == 0) then
		self.m_output = bit.band(value, 0x1FF)
		print(string.format('Write ASIC: 0x%03X @ 0x%02X', bit.band(value, 0x1FF), address))
	end
end

function Sys573.ASIC:init()
	Sys573.CPLD:registerFunction(
		CPLD_AddressMap:new(0x1f400000, 2, 0xF,
			nil,
			function(address, width, value)
				self:writeOutputs(address, value)
			end)
	)
end
