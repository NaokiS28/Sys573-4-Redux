--[[
/*
 * GenV - Copyright (C) 2025 NaokiS, spicyjpeg
 * rtc.lua - Created on 02-12-2025
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

Sys573.constants.RTC = {
	RTC_TIME_HOURS = 0x1FFB,
	RTC_TIME_MINS = 0x1FFA,
	RTC_TIME_SECS_STOP = 0x1FF9,
	RTC_DATE_YEAR = 0x1FFF,
	RTC_DATE_MONTH = 0x1FFE,
	RTC_DATE_DAY_FT_CENT = 0x1FFC,
	RTC_DATE_DATE_BATTERY = 0x1FFD,
	RTC_CALIBRATION_CONTROL = 0x1FF8,
	RTC_MASK_MONTH = 0x1F,
	RTC_MASK_DAY = 0x07,
	RTC_MASK_DATE = 0x3F,
	RTC_MASK_HOURS = 0x3F,
	RTC_MASK_MINS = 0x7F,
	RTC_MASK_SECONDS = 0x7F,
	RTC_MASK_BATTERY = 0xC0,
	RTC_MASK_FT_CENT = 0x70,
	RTC_MASK_STATUS = 0xE0,
	RTC_MASK_STOP = 0x80,
	RTC_MASK_SIGN = 0x20,
	RTC_MASK_READ = 0x40,
	RTC_MASK_WRITE = 0x80,
	RTC_DAY_STRING = {
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday",
		"Sunday"
	}
}

Sys573.RTC = {
	m_bbram = ffi.new("uint8_t[1024 * 8]"),
	m_batteryState = true,
	m_lastTime = 0,
	m_date = 0,
	m_day = 0,
	m_month = 0,
	m_year = 0,
	m_hours = 0,
	m_minutes = 0,
	m_seconds = 0,
}

function BCD2DEC(bcd)
	bcd = bit.band(bcd, 0xFF)
	local tens = bit.rshift(bit.band(bcd, 0xF0), 4)
	local ones = bit.band(bcd, 0xF0)
	return tens + ones
end

function DEC2BCD(decimal)
	local ones = math.fmod(decimal, 10)
	local tens = decimal / 10
	return bit.bor(bit.lshift(tens, 4), ones)
end

function Sys573.RTC:tick()
	self.m_lastTime = self.m_lastTime + 16.6
	while self.m_lastTime >= 1000.0 do
		self.m_lastTime = self.m_lastTime - 1000.0
		self.m_seconds = self.m_seconds + 1
		if self.m_seconds >= 60 then
			self.m_minutes = self.m_minutes + 1
			self.m_seconds = 0
			if self.m_minutes >= 60 then
				self.m_minutes = 0
				self.m_hours = self.m_hours + 1
				if self.m_hours >= 24 then
					self.m_hours = 0
					self.m_day = self.m_day + 1
					self.m_date = self.m_day + 1
					if self.m_day >= 8 then
						self.m_day = 1
					end
					-- I could continue on but lets be real, are you *really* going to leave PCSX-Redux running for a month?
				end
			end
		end
		self:setTime()
		self:setDate()
	end
	--end
end

-- Returns true if the WRITE, READ or STOP bits are set to tell tick() to stop updating the clock.
function Sys573.RTC:halt()
	local constants = Sys573.constants.RTC
	return bit.band(self.m_bbram[constants.RTC_CALIBRATION_CONTROL],
			constants.RTC_MASK_WRITE + constants.RTC_MASK_READ) > 0
		or bit.band(self.m_bbram[constants.RTC_TIME_SECS_STOP], constants.RTC_MASK_STOP) > 0
end

function Sys573.RTC:init()
	self.m_handler = PCSX.Events.createEventListener('GPU::Vsync', function()
		Sys573.RTC:tick()
	end)
	ffi.fill(self.m_bbram, 8184, 0xFF)
	ffi.fill(self.m_bbram, 8, 0x00)
end

function Sys573.RTC:setTime()
	local constants = Sys573.constants.RTC
	local stop = bit.band(self.m_bbram[constants.RTC_TIME_HOURS], constants.RTC_MASK_STOP)
	self.m_bbram[constants.RTC_TIME_SECS_STOP] = bit.bor(stop,
		bit.band(DEC2BCD(self.m_seconds), constants.RTC_MASK_SECONDS))
	self.m_bbram[constants.RTC_TIME_MINS] = bit.band(DEC2BCD(self.m_minutes), constants.RTC_MASK_MINS)
	self.m_bbram[constants.RTC_TIME_HOURS] = bit.band(DEC2BCD(self.m_hours), constants.RTC_MASK_HOURS)
end

function Sys573.RTC:setDate()
	local constants = Sys573.constants.RTC
	local day_settings = bit.band(self.m_bbram[constants.RTC_DATE_DAY_FT_CENT], constants.RTC_MASK_FT_CENT)
	local date_battery = bit.band(self.m_bbram[constants.RTC_DATE_DATE_BATTERY], constants.RTC_MASK_BATTERY)

	self.m_bbram[constants.RTC_DATE_DAY_FT_CENT] = bit.bor(day_settings,
		bit.band(DEC2BCD(self.m_day), constants.RTC_MASK_DAY))
	self.m_bbram[constants.RTC_DATE_DATE_BATTERY] = bit.bor(date_battery,
		bit.band(DEC2BCD(self.m_date), constants.RTC_MASK_DATE))
	self.m_bbram[constants.RTC_DATE_MONTH] = bit.band(DEC2BCD(self.m_month), constants.RTC_MASK_MONTH)
	self.m_bbram[constants.RTC_DATE_YEAR] = DEC2BCD(self.m_year)
end

function Sys573.RTC:setBattery()
	local constants = Sys573.constants.RTC
	local date_battery = bit.band(self.m_bbram[constants.RTC_DATE_DATE_BATTERY], constants.RTC_MASK_DATE)
	self.m_bbram[constants.RTC_DATE_DATE_BATTERY] = bit.bor(date_battery,
		bit.lshift(Bool_to_number(self.m_batteryState), 6))
end

function Sys573.RTC:DrawImguiTab()
	local changed
	imgui.SeparatorText("Calendar")
	changed, self.m_year = imgui.InputInt("Year", self.m_year)
	if changed then self.m_year = math.fmod(math.max(self.m_year, 0), 100) end

	changed, self.m_month = imgui.InputInt("Month", self.m_month)
	if changed then self.m_month = math.fmod(math.max(self.m_month, 0), 12) + 1 end

	changed, self.m_date = imgui.InputInt("Date", self.m_date)
	if changed then self.m_date = math.fmod(math.max(self.m_date, 0), 31) + 1 end

	imgui.SeparatorText("Clock")
	changed, self.m_hours = imgui.InputInt("Hour", self.m_hours)
	if changed then self.m_hours = math.fmod(math.max(self.m_hours, 0), 24) end

	changed, self.m_minutes = imgui.InputInt("Min", self.m_minutes)
	if changed then self.m_minutes = math.fmod(math.max(self.m_minutes, 0), 60) end

	changed, self.m_seconds = imgui.InputInt("Sec", self.m_seconds)
	if changed then self.m_seconds = math.fmod(math.max(self.m_seconds, 0), 60) end

	changed, self.m_batteryState = imgui.Checkbox("Battery OK", self.m_batteryState)
	if changed then self:setBattery() end
end
