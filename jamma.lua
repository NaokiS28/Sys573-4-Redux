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

require("bit")

Sys573.JAMMA = {
	m_extOut = 0xFF,
	m_analogIn = { 0, 0, 0, 0 },
}

CabinetControls = {
	"Test", "Service"
}

Sys573.constants.JAMMA = {
	Player = {
		{
			Up = { " UP ", 3, 2 },
			Down = { "DOWN", 3, 3 },
			Left = { "LEFT", 3, 0 },
			Right = { "RIGHT", 3, 1 },
			Button1 = { " B1 ", 3, 4 },
			Button2 = { " B2 ", 3, 5 },
			Button3 = { " B3 ", 3, 6 },
			Button4 = { " B4 ", 5, 8 },
			Button5 = { " B5 ", 5, 9 },
			Button6 = { " B6 ", 5, 11 },
			Start = { "START", 3, 7 }
		},
		{
			Up = { " UP ", 3, 10 },
			Down = { "DOWN", 3, 11 },
			Left = { "LEFT", 3, 8 },
			Right = { "RIGHT", 3, 9 },
			Button1 = { " B1 ", 3, 12 },
			Button2 = { " B2 ", 3, 13 },
			Button3 = { " B3 ", 3, 14 },
			Button4 = { " B4 ", 6, 8 },
			Button5 = { " B5 ", 6, 9 },
			Button6 = { " B6 ", 6, 11 },
			Start = { "START", 3, 15 }
		}
	},

	Test = { "TEST", 5, 10 },
	Service = { "SERVICE", 2, 12 },
	Coin = {
		{ "COIN 1", 2, 8 },
		{ "COIN 2", 2, 9 } },

	DIP = {
		{ "DIP 1", 1, 0 },
		{ "DIP 2", 1, 1 },
		{ "DIP 3", 1, 2 },
		{ "DIP 4", 1, 3 } },
	OutputStates = { "Inactive", "Active" },
}

CabinetDIPs = {
	Sys573.constants.JAMMA.DIP[1],
	Sys573.constants.JAMMA.DIP[2],
	Sys573.constants.JAMMA.DIP[3],
	Sys573.constants.JAMMA.DIP[4]
}
CabinetControls = {
	Sys573.constants.JAMMA.Test,
	Sys573.constants.JAMMA.Service,
	Sys573.constants.JAMMA.Coin[1],
	Sys573.constants.JAMMA.Coin[2] }

PlayerControls = {
	{ nil,    "Up",   nil,     "Start", nil,       "Button2", "Button3" },
	{ "Left", nil,    "Right", nil,     "Button1", "Button5", "Button6" },
	{ nil,    "Down", nil,     nil,     "Button4", nil,       nil }
}

function Sys573.JAMMA:DrawCabinetLayout()
	local asic = Sys573.ASIC
	local changed

	--Service inputs
	for c = 1, #CabinetControls do
		local cbox = CabinetControls[c]
		if (cbox ~= nil) then
			local reg = cbox[2] -- ASIC input register (3, 5 or 6)
			local bitpos = cbox[3]

			local state = BitRead(asic.m_input[reg], bitpos)
			changed, state = imgui.Checkbox(cbox[1], not state) -- Invert the displayed X
			state = not state
			if (changed) then
				asic.m_input[reg] = BitWrite(asic.m_input[reg], bitpos, state)
			end
		end
	end

	-- DIP inputs
	for d = 1, #CabinetDIPs do
		local cbox = CabinetDIPs[d]
		local reg = cbox[2] -- ASIC input register (3, 5 or 6)
		local bitpos = cbox[3]

		local state = not BitRead(asic.m_input[reg], bitpos)
		changed, state = imgui.SliderInt(cbox[1], Bool_to_number(state), 0, 1) -- Invert the displayed X
		if (changed) then
			state = state == 0
			asic.m_input[reg] = BitWrite(asic.m_input[reg], bitpos, state)
		end
	end

	imgui.TextUnformatted(string.format("DIP: 0x%04X", asic.m_input[1]))
	imgui.TextUnformatted(string.format("Misc.: 0x%04X", asic.m_input[2]))
	imgui.TextUnformatted(string.format("Extra 1: 0x%04X", asic.m_input[5]))
end

function Sys573.JAMMA:DrawJAMMALayout(Player)
	local asic = Sys573.ASIC
	local changed
	if (imgui.BeginTable("JAMMA", 7)) then
		for r = 1, #PlayerControls do
			imgui.TableNextRow()
			for b = 1, 7 do
				imgui.TableSetColumnIndex(b - 1)
				local input_name = PlayerControls[r][b]
				if (input_name ~= nil) then
					local cbox = Sys573.constants.JAMMA.Player[Player][input_name]
					local state = BitRead(asic.m_input[cbox[2]], cbox[3])
					changed, state = imgui.Checkbox(cbox[1], not state) -- Invert the displayed X
					state = not state
					if (changed) then
						asic.m_input[cbox[2]] = BitWrite(asic.m_input[cbox[2]], cbox[3], state)
					end
				end
			end
		end
		imgui.EndTable()
	end
	imgui.TextUnformatted(string.format("JAMMA: 0x%04X", asic.m_input[3]))
	imgui.TextUnformatted(string.format("Extra %d: 0x%04X", Player, asic.m_input[4 + Player]))
end

function Sys573.JAMMA:DrawImguiTab()
	local changed = false
	imgui.SeparatorText("Digital In")
	if imgui.CollapsingHeader(
			"Cabinet"
		) then
		self:DrawCabinetLayout()
	end
	for i = 1, 2 do
		if imgui.CollapsingHeader(
				string.format("Player %d", i)
			) then
			imgui.PushID("Player" .. i)
			self:DrawJAMMALayout(i)
			imgui.PopID()
		end
	end
	imgui.SeparatorText("Analog In")
	for a = 1, #self.m_analogIn do
		changed, self.m_analogIn[a] = imgui.SliderInt(string.format("Channel %d", a),
			self.m_analogIn[a],
			-128, 128)
	end
	imgui.SeparatorText("Outputs")
	self:DrawOutputs()
end

function Sys573.JAMMA:DrawOutputs()
	for i = 1, 8 do
		imgui.TableNextColumn()
		imgui.TextUnformatted(string.format('Output %d: %s', i,
			Sys573.constants.JAMMA.OutputStates[
			Bool_to_number(
				not BitRead(Sys573.JAMMA.m_extOut, i - 1)
			) + 1
			]))
	end
end

function Sys573.JAMMA:SetOutputs(val)
	self.m_extOut = bit.band(val, 0xFF)
end
