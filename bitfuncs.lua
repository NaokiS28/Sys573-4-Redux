--[[
/*
 * GenV - Copyright (C) 2025 NaokiS, spicyjpeg
 * bitfuncs.lua - Created on 08-12-2025
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

function BitRead(val, n)
	local mask = (bit.lshift(1, n))
	return bit.band(val, mask) > 0
end

function BitSet(val, n)
	local mask = (bit.lshift(1, n))
	return bit.bxor(bit.band(val, -mask - 1), mask)
end

function BitClear(val, n)
	local mask = -(bit.lshift(1, n)) - 1
	return bit.band(bit.band(val, mask), mask)
end

function BitWrite(val, n, state)
	if (state) then
		return BitSet(val, n)
	else
		return BitClear(val, n)
	end
end

function Bool_to_number(value)
	return value and 1 or 0
end

function Number_to_bool(value)
	return value > 0
end
