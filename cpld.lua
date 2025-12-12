--[[
/***************************************************************************
 *   Copyright (C) 2024 PCSX-Redux authors                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.           *
 ***************************************************************************/
 ]]

local ffi = require("ffi")

CPLD_AddressMap = {}
CPLD_AddressMap.__index = CPLD_AddressMap

function CPLD_AddressMap:new(address, width, length, read, write)
	--assert(math.fmod(address + length, width) > 0, "Address is not aligned!")
	local obj = {
		m_startAddr = address,
		m_endAddr = address + length - 1,
		m_width = width,
		f_read = read,
		f_write = write
	}
	return setmetatable(obj, CPLD_AddressMap)
end

Sys573.CPLD = {
	m_map = {}
}

function Sys573.CPLD:between(val, low, high)
	if (low > high) then return false end
	return (val >= low and val <= high)
end

function Sys573.CPLD:init()

end

function Sys573.CPLD:reset()

end

function Sys573.CPLD:registerFunction(map)
	local addr = map.m_startAddr
	self.m_map[addr] = map
end

function Sys573.CPLD:setLUTs()
	local readLUT = PCSX.getReadLUT()
	local writeLUT = PCSX.getWriteLUT()

	--for i = 0, 3, 1 do
	--	readLUT[i + 0x1f00] = ffi.cast('uint8_t*', PIOCart.m_cartData + bit.lshift(i, 16))
	--end

	--ffi.copy(readLUT + 0x9f00, readLUT + 0x1f00, 4 * ffi.sizeof("void *"))
	--ffi.copy(readLUT + 0xbf00, readLUT + 0x1f00, 4 * ffi.sizeof("void *"))

	--Sys573.CPLD:setLUTFlashBank()
end

function Sys573.CPLD:setLUTFlashBank()
	local readLUT = PCSX.getReadLUT()
	local writeLUT = PCSX.getWriteLUT()

	if (readLUT == nil or writeLUT == nil) then return end

	if (self.m_chip == 0) then
		--self.FlashMemory:setLUTs()

		if (self.m_bank == 0) then
			ffi.copy(readLUT + 0x1f04, readLUT + 0x1f00, 2 * ffi.sizeof("void *"))
		else --if(bank == 1) then
			ffi.copy(readLUT + 0x1f04, readLUT + 0x1f02, 2 * ffi.sizeof("void *"))
		end
	else
		--readLUT[0x1f04] = ffi.cast('uint8_t*', self.m_detachedMemory)
		--readLUT[0x1f05] = ffi.cast('uint8_t*', self.m_detachedMemory)
	end

	ffi.copy(readLUT + 0x9f04, readLUT + 0x1f04, 2 * ffi.sizeof("void *"))
	ffi.copy(readLUT + 0xbf04, readLUT + 0x1f04, 2 * ffi.sizeof("void *"))
end

function Sys573.CPLD:write(address, width, value)
	print(string.format('Write: 0x%08X @ 0x%08X', value, address))
	local map = self.m_map[address]
	if (map ~= nil and map.f_write ~= nil) then
		map.f_write(address - map.m_startAddr, width, value)
		return true
	else
		for i in pairs(self.m_map) do
			local imap = self.m_map[i]
			if (self:between(address, imap.m_startAddr, imap.m_endAddr) and imap.f_write ~= nil) then
				imap.f_write(address - imap.m_startAddr, width, value)
				return true
			end
		end
	end
	print('Write nil')
	return false
end

function Sys573.CPLD:read(address, width)
	print(string.format('Read: 0x%08X', address))
	local map = self.m_map[address]
	if (map ~= nil and map.f_write ~= nil) then
		return map.f_read(address - map.m_startAddr, width), true
	else
		for i in pairs(self.m_map) do
			local imap = self.m_map[i]
			if (self:between(address, imap.m_startAddr, imap.m_endAddr) and imap.f_read ~= nil) then
				return imap.f_read(address - imap.m_startAddr, width), true
			end
		end
	end
	print('Read nil')
	return 0xFFFFFFFF, false
end
