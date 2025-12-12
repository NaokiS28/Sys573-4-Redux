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

Sys573.JVS = {
	m_connected = false,
	m_ioCount = 1,
	m_ioBoards = {},
	m_rxBuffer = "" --RingBuffer:new(32),
}

JVSPlayer = {}

JVS_IO = {}
JVS_IO.__index = JVS_IO

function JVS_IO:new(id)
	local obj = {
		m_groupOpened = false,
		m_name = "PCSX-Redux JVS;PCSX-Redux;V1.00",
		m_id = id or 0,
		m_players = 0,
		m_rxBuffer = "" --RingBuffer:new(8),
	}
	return setmetatable(obj, JVS_IO)
end

function JVS_IO:DrawIOBoard()
	local changed
	changed, self.m_name = imgui.extra.InputText("IO Board Name", self.m_name)
	changed, self.m_players = imgui.SliderInt("Player Count", self.m_players, 1, 4)
end

function JVS_IO:update()
end

function Sys573.JVS:DrawImguiTab()
	local changed
	changed, self.m_connected = imgui.Checkbox("IO Connected", self.m_connected)
	if (changed and not self.m_connected) then
		-- Remove all boards
		for i = 1, #self.m_ioBoards do
			self.m_ioBoards[i] = nil
		end
	end
	if not self.m_connected then
		return
	end

	changed, self.m_ioCount =
		imgui.SliderInt("IO Count", self.m_ioCount, 1, 8)

	-- If ioCount changed, (re)build the board list
	if (changed or (#self.m_ioBoards ~= m_ioCount)) then
		-- Create boards up to the count
		for i = 1, self.m_ioCount do
			if not self.m_ioBoards[i] then
				self.m_ioBoards[i] = JVS_IO:new(i)
			end
		end

		-- Remove extras
		for i = self.m_ioCount + 1, #self.m_ioBoards do
			self.m_ioBoards[i] = nil
		end
	end

	-- Draw each IO board section
	for i = 1, self.m_ioCount do
		local board = self.m_ioBoards[i]
		if not board then
			goto continue
		end

		if imgui.CollapsingHeader(
				string.format("IO Board ID: %d", i),
				board.m_groupOpened
			) then
			imgui.PushID("IO" .. i)
			board:DrawIOBoard()
			imgui.PopID()
		end

		::continue::
	end
end

function Sys573.JVS:Transmit(id, data)
	if (id > self.m_ioCount or self.m_ioBoards[id] == nil) then
		return nil
	end
end

function Sys573.JVS:Receive(data)
	--if (m_rxBuffer:count()) then
	--	return m_rxBuffer:pop()
	--end
end
