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

local ffi = require("ffi")

Support.extra.dofile('bitfuncs.lua')
Support.extra.dofile('ringbuffer.lua')

Support.extra.dofile('gx700.lua')
Support.extra.dofile('cpld.lua')
Support.extra.dofile('asic.lua')
Support.extra.dofile('jamma.lua')
Support.extra.dofile('jvs.lua')
Support.extra.dofile('rtc.lua')
Support.extra.dofile('expansion.lua')
Support.extra.dofile('security.lua')
Support.extra.dofile('watchdog.lua')

-- Global callbacks
function DrawImguiFrame()
	if (not imgui.Begin('Sys573-4-Redux', true)) then
		imgui.End()
		return
	end

	if (imgui.BeginTabBar('Tab Bar')) then
		if (imgui.BeginTabItem('GX700')) then
			Sys573:DrawImguiTab()
			Sys573.Watchdog:DrawImguiWidget()
			imgui.EndTabItem()
		end
		if (imgui.BeginTabItem('RTC')) then
			Sys573.RTC:DrawImguiTab()
			imgui.EndTabItem()
		end
		if (imgui.BeginTabItem('Security Cart')) then
			Sys573.SecurityCart:DrawImguiTab()
			imgui.EndTabItem()
		end
		if (imgui.BeginTabItem('JVS')) then
			Sys573.JVS:DrawImguiTab()
			imgui.EndTabItem()
		end
		if (imgui.BeginTabItem('JAMMA')) then
			Sys573.JAMMA:DrawImguiTab()
			imgui.EndTabItem()
		end
		if (imgui.BeginTabItem('Expansion')) then
			Sys573.Expansion:DrawImguiTab()
			imgui.EndTabItem()
		end
		imgui.EndTabBar()
	end
	imgui.End()
end

function UnknownMemoryRead(address, size)
	if (address >= 0xbf000000 and address < 0xbf8000000) then address = address - 0xA0000000 end
	if (address >= 0x1f000000 and address < 0x1f8000000 and Sys573.m_connected) then
		return Sys573.read(address, size)
	end

	return 0xff
end

function UnknownMemoryWrite(address, size, value)
	if (address >= 0xbf000000 and address < 0xbf8000000) then address = address - 0xA0000000 end
	if (address >= 0x1f000000 and address < 0x1f8000000 and Sys573.m_connected) then
		return Sys573.write(address, size, value)
	end
end

Sys573.ASIC:init()
Sys573.RTC:init()
Sys573.Expansion:init()
Sys573.Watchdog:init()

Sys573.event_lutsset = PCSX.Events.createEventListener('Memory::SetLuts', Sys573.setLUTs)
