-- Mozbugbox's lua utilities for mpv 
-- Copyright (c) 2015-2018 mozbugbox@yahoo.com.au
-- Licensed under GPL version 3 or later

-- Show clock and duration on video
-- Usage: c script_message show-clock-and-duration [true|yes]
local mp = require("mp")
local msg = require("mp.msg")
local utils = require("mp.utils") -- utils.to_string()
local assdraw = require('mp.assdraw')

local shown = false

local update_timeout = 1 -- in seconds

-- Class creation function
function class_new(klass)
    -- Simple Object Oriented Class constructor
    local klass = klass or {}
    function klass:new(o)
        local o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
    end
    return klass
end

-- print content of a lua table
function print_table(tbl)
    msg.info(utils.to_string(tbl))
end

-- Show OSD Clock And Duration
local OSDClockAndTitleAndDuration = class_new()
function OSDClockAndTitleAndDuration:_show_clock_and_title_and_duration()
    local osd_w, osd_h, aspect = mp.get_osd_size()

    local fontsize = 13

    -- For showing Duration on upper left corner
    local duration = mp.get_property_osd("playback-time") .. " / " .. mp.get_property_osd("duration")
    local ass = assdraw:ass_new()
    ass:new_event()
    ass:an(7)
    ass:append(string.format("{\\fs%d}", fontsize))
    ass:append(duration)
    ass:an(0)
    mp.set_osd_ass(osd_w, osd_h, ass.text)

    local duration = mp.get_property_osd("media-title")
    ass:new_event()
    ass:an(8)
    ass:append(string.format("{\\fs%d}", fontsize))
    ass:append(duration)
    ass:an(0)
    mp.set_osd_ass(osd_w, osd_h, ass.text)

    -- For showing Clock on upper right corner
    local now = os.date("%I:%M %p")
    ass:new_event()
    ass:an(9)
    ass:append(string.format("{\\fs%d}", fontsize))
    ass:append(now)
    ass:an(0)
    mp.set_osd_ass(osd_w, osd_h, ass.text)
end

function clear_osd()
    local osd_w, osd_h, aspect = mp.get_osd_size()
    mp.set_osd_ass(osd_w, osd_h, "")
end

function OSDClockAndTitleAndDuration:toggle_show_clock_and_title_and_duration(val)
    if shown == true then
        self.tobj:kill()
        self.tobj = nil
        clear_osd()
        shown = false
    elseif shown == false then
        local trues = {["true"]=true, ["yes"] = true}
        if self.tobj then
            if trues[val] ~= true then
                self.tobj:kill()
                self.tobj = nil
                clear_osd()
                shown = false
            end
        elseif val == nil or trues[val] == true then
            self:_show_clock_and_title_and_duration()
            local tobj = mp.add_periodic_timer(update_timeout,
                function() self:_show_clock_and_title_and_duration() end)
            self.tobj = tobj
            shown = true
        end
    end
end

local osd_clock_and_duration = OSDClockAndTitleAndDuration:new()
function toggle_show_clock_and_title_and_duration(v)
    osd_clock_and_duration:toggle_show_clock_and_title_and_duration(v)
end

mp.commandv("script-message", toggle_show_clock_and_title_and_duration())
mp.register_script_message("show-clock-and-title-and-duration", toggle_show_clock_and_title_and_duration)




