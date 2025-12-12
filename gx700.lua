--[[
/*
 * GenV - Copyright (C) 2025 NaokiS, spicyjpeg
 * main.lua - Created on 02-12-2025
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

Sys573 = {
	m_connected = true,
	m_ramLayout = 0,
	constants = {}
}

function Sys573:DrawImguiTab()
	imgui.SeparatorText("System")

	local changed = false
	changed, Sys573.m_connected = imgui.Checkbox('Connect System 573', Sys573.m_connected)
	if (imgui.RadioButton("Revision A-C", Sys573.m_ramLayout == 0, Sys573.m_ramLayout, 0)) then
		Sys573.m_ramLayout = 0
		changed = true
	end
	if (imgui.RadioButton("Revision D", Sys573.m_ramLayout > 0, Sys573.m_ramLayout, 1)) then
		Sys573.m_ramLayout = 1
		changed = true
	end
	if (changed) then
		Sys573.ASIC.m_input[Sys573.constants.ASIC.IN_EXT_2] = BitWrite(
			Sys573.ASIC.m_input[Sys573.constants.ASIC.IN_EXT_2], 10,
			Sys573.m_ramLayout == 0)
	end
end

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

function Sys573.write(address, width, value)
	if (not Sys573.CPLD:write(address, width, value)) then
		print('Unknown write: ' .. string.format("%x", address) .. ' = ' .. string.format("%x", value))
		return false
	end
	return true
end

function Sys573.read(address, value)
	local r_val, result = Sys573.CPLD:read(address, value)
	if (not result) then
		print('Unknown read: ' .. string.format("%x", address) .. ' = ' .. string.format("%x", value))
	end
	return r_val
end
