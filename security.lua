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

CartridgeOptions = {
	{ 1, "Xicor X76F041" },
	{ 2, "ZS01" },
}

XicorText = {
	"Read Password",
	"Write Password",
	"Config Password"
}

Sys573.SecurityCart = {
	m_Connected = false,
	m_KeychipType = 1,
	m_Password = { "", "", "" },
	m_has_ds2401 = false,
	m_ds2401_id = "",
}

function Sys573.SecurityCart:DrawDS2401()
	local changed
	changed, self.m_has_ds2401 = imgui.Checkbox("Has DS2401", self.m_has_ds2401)
	if (self.m_has_ds2401) then
		changed, self.m_ds2401_id = imgui.extra.InputText("DS2401 ID", self.m_ds2401_id,
			imgui.constant.InputTextFlags.CharsHexadecimal + imgui.constant.InputTextFlags.CharsUppercase)
		if (imgui.BeginItemTooltip()) then
			imgui.TextUnformatted("48-Bit password in hexadecimal format")
			imgui.EndTooltip()
		end
	end
end

function Sys573.SecurityCart:DrawXicorCart()
	for i = 1, #XicorText do
		local changed
		changed, self.m_Password[i] = imgui.extra.InputText(XicorText[i],
			self.m_Password[i],
			imgui.constant.InputTextFlags.CharsHexadecimal + imgui.constant.InputTextFlags.CharsUppercase)
		if (imgui.BeginItemTooltip()) then
			imgui.TextUnformatted("64-Bit password in hexadecimal format")
			imgui.EndTooltip()
		end
	end
	self:DrawDS2401()
end

function Sys573.SecurityCart:DrawZSCart()
	local changed
	changed, self.m_Password[1] = imgui.extra.InputText("Keychip Password",
		self.m_Password[1],
		imgui.constant.InputTextFlags.CharsHexadecimal + imgui.constant.InputTextFlags.CharsUppercase)
	if (imgui.BeginItemTooltip()) then
		imgui.TextUnformatted("64-Bit password in hexadecimal format")
		imgui.EndTooltip()
	end

	self:DrawDS2401()
end

function Sys573.SecurityCart:DrawImguiTab()
	local changed
	changed, self.m_Connected = imgui.Checkbox("Present", self.m_Connected)
	if (changed and not self.m_Connected) then
		self.m_Connected = false
		self.m_KeychipType = 1
		self.m_Password = { "", "", "" }
		self.m_has_ds2401 = false
		self.m_ds2401_id = ""
	end

	if (self.m_Connected) then
		if (imgui.BeginCombo("Cartridge Type", CartridgeOptions[self.m_KeychipType][2])) then
			for i = 1, #CartridgeOptions do
				local selected = (i == self.m_KeychipType)
				if (imgui.Selectable(CartridgeOptions[i][2], selected)) then
					self.m_KeychipType = i
				end
				if (selected) then
					imgui.SetItemDefaultFocus()
				end
			end
			imgui.EndCombo()
		end

		if (self.m_KeychipType == 1) then
			self:DrawXicorCart()
		elseif (self.m_KeychipType == 2) then
			self:DrawZSCart()
		end
	end
end
