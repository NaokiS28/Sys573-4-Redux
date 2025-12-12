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

ExpansionOptions = {
	{ 1, "None" },
	{ 2, "Analog I/O" },
	--{ 3, "Digital I/O" },
	--{ 4, "Fishing Reel I/O" }
}

Sys573.Expansion = {
	m_type = 1
}

function Sys573.Expansion:init()
	Sys573.CPLD:registerFunction(
		CPLD_AddressMap:new(0x1f640000, 4, 0xFF,
			function(address, width)
				return Sys573.Expansion:read(address, width)
			end,
			function(address, width, value)
				Sys573.Expansion:write(address, width, value)
			end)
	)
end

function Sys573.Expansion:write(address, width, value)
	if (self.m_type == 2) then return self.AnalogIO:write(address, width, value) end
	return false
end

function Sys573.Expansion:read(address, width)
	return 0xFFFFFFFF
end

function Sys573.Expansion:DrawImguiTab()
	local changed
	if (imgui.BeginCombo("Installed Expansion", ExpansionOptions[Sys573.Expansion.m_type][2])) then
		for i = 1, #ExpansionOptions do
			local selected = (i == Sys573.Expansion.m_Type)
			if (imgui.Selectable(ExpansionOptions[i][2], selected)) then
				Sys573.Expansion.m_type = i
			end
			if (selected) then
				imgui.SetItemDefaultFocus()
			end
		end
		imgui.EndCombo()
	end
end

-- ANALOG IO

Sys573.Expansion.AnalogIO = {
	m_output = { 0xFF, 0xFF, 0xFF, 0x0F }
}

function Sys573.Expansion.AnalogIO:write(address, width, value)
	if address == 0x0 then
		self.m_output[1] = bit.band(value, 0xFF)
		return true
	elseif address == 0x8 then
		self.m_output[2] = bit.band(value, 0xFF)
		return true
	elseif address == 0x10 then
		self.m_output[3] = bit.band(value, 0xFF)
		return true
	elseif address == 0x18 then
		self.m_output[4] = bit.band(value, 0x0F)
		return true
	end
	return false
end

function Sys573.Expansion.AnalogIO:read(address, width)
	return 0xFFFF
end
