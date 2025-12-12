--[[
Original by:
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

Sys573 = {
	m_Connected = true,
	m_switchOn = true,
	m_cartData = ffi.new("uint8_t[512 * 1024]")
}

function Sys573.setLUTs()
	local readLUT = PCSX.getReadLUT()
	local writeLUT = PCSX.getWriteLUT()

	if (readLUT == nil or writeLUT == nil) then return end

	if (Sys573.m_connected) then
		Sys573.CPLD:setLUTs()
	else
		ffi.fill(readLUT + 0x1f00, 6 * ffi.sizeof("void *"), 0)
	end

	ffi.fill(writeLUT + 0x1f00, 6 * ffi.sizeof("void *"), 0)
	ffi.fill(writeLUT + 0x9f00, 6 * ffi.sizeof("void *"), 0)
	ffi.fill(writeLUT + 0xbf00, 6 * ffi.sizeof("void *"), 0)
end

function Sys573.read8(address)
	return Sys573.PAL:read8(address)
end

function Sys573.read16(address)
	local byte2 = bit.lshift(Sys573.read8(address + 1), 8)
	local byte1 = Sys573.read8(address)
	return bit.bor(byte2, byte1)
end

function Sys573.read32(address)
	local byte4 = bit.lshift(Sys573.read8(address), 24)
	local byte3 = bit.lshift(Sys573.read8(address + 1), 16)
	local byte2 = bit.lshift(Sys573.read8(address + 2), 8)
	local byte1 = Sys573.read8(address + 3)
	return bit.bor(byte4, byte3, byte2, byte1)
end

function Sys573.write8(address, value)
	--print('Sys573.write8 ' .. string.format("%x", address) .. ' = ' .. string.format("%x", value))
	--Sys573.PAL:write8(address, value)
	assert(false, string.format("8-bit write to 573 port: 0x%02X -> 0x%04X", value, address))
end

function Sys573.write16(address, value)
	Sys573.PAL:write16(address, value)
end

function Sys573.write32(address, value)
	Sys573.PAL:write32(address, value)
end
