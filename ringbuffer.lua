--[[
/*
 * GenV - Copyright (C) 2025 NaokiS, spicyjpeg
 * ringbuffer.lua - Created on 06-12-2025
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

RingBuffer = {}
RingBuffer.__index = RingBuffer

function RingBuffer:new(capacity)
	local obj = {
		buf = {},
		head = 1,
		tail = 1,
		size = 0,
		capacity = capacity
	}
	return setmetatable(obj, RingBuffer)
end

function RingBuffer:push(value)
	if self.size == self.capacity then
		assert("Ring buffer full!")
		return false -- buffer full
	end

	self.buf[self.tail] = value
	self.tail = (self.tail % self.capacity) + 1
	self.size = self.size + 1
	return true
end

function RingBuffer:pop()
	if self.size == 0 then
		return nil
	end

	local value = self.buf[self.head]
	self.buf[self.head] = nil
	self.head = (self.head % self.capacity) + 1
	self.size = self.size + -1
	return value
end

function RingBuffer:count()
	return self.size
end
