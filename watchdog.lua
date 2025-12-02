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

Sys573_Watchdog = {
	m_timer = 0,
	m_enabled = false,
	m_doReset = false
}

local captures = {}
captures.current = coroutine.running()
captures.callback = function()
    PCSX.nextTick(function()
        captures.callback:free()
        coroutine.resume(captures.current)
    end)
end
captures.callback = ffi.cast('void (*)()', captures.callback)