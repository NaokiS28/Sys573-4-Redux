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

Sys573.constants.Watchdog = {
	TIMEOUT_VALUE = (60 * 1.5)
}

Sys573.Watchdog = {
	m_timer = 0,
	m_enabled = false,
	m_handler = nil
}

function Sys573.Watchdog:tick()
	if (self.m_enabled) then
		if (not self.m_resetDone and self.m_timer == 0) then
			self:reset()
		elseif (self.m_timer > 0) then
			self.m_timer = self.m_timer - 1
		end
	end
end

function Sys573.Watchdog:init()
	self.m_handler = PCSX.Events.createEventListener('GPU::Vsync', function()
		Sys573.Watchdog:tick()
	end)
	Sys573.CPLD:registerFunction(
		CPLD_AddressMap:new(0x1f5c0000, 1, 1, nil, function(address, width, value)
			Sys573.Watchdog:kick()
		end)
	)
end

function Sys573.Watchdog:kick()
	self.m_timer = Sys573.constants.Watchdog.TIMEOUT_VALUE
end

function Sys573.Watchdog:reset()
	self.m_timer = Sys573.constants.Watchdog.TIMEOUT_VALUE
	PCSX.log("System 573 - Watchdog Reset")
	PCSX.softResetEmulator()
end

function Sys573.Watchdog:DrawImguiWidget()
	imgui.SeparatorText("Watchdog")
	local changed
	changed, self.m_enabled = imgui.Checkbox('Enable', self.m_enabled)
	if (changed and self.m_enabled) then
		self.m_timer = Sys573.constants.Watchdog.TIMEOUT_VALUE
	end

	imgui.SameLine()
	if (imgui.Button("Reset System")) then
		self:reset()
	end
end
