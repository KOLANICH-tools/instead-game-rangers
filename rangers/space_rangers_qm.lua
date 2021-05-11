-- This is a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild
--
-- This file is compatible with Lua 5.3

local class = require("class")
require("kaitaistruct")
local enum = require("enum")
local utils = require("utils")
local str_decode = require("string_decode")

-- 
-- You can download quests from:
--   * the sites mentioned on https://ifwiki.ru/TGE
--   * http://www.rilarhiv.ru/tge2.htm
-- See also: Source (http://www.abaduaber.narod.ru/lastqm.txt)
-- See also: Source (https://github.com/roginvs/space-rangers-quest/blob/master/src/lib/qmreader.ts)
-- See also: https://github.com/ObKo/OpenSR/blob/rework/include/OpenSR/QM/QM.h (https://github.com/ObKo/OpenSR/blob/rework/QM/QM.cpp)
-- See also: Source (https://github.com/VirRus77/Space-Rangers-Quests/blob/master/SpaceRangersQuests.Model/FileQuest.cs)
SpaceRangersQm = class.class(KaitaiStruct)

SpaceRangersQm.SuccessCondition = enum.Enum {
  arrival = 0,
  immediately = 1,
}

function SpaceRangersQm:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm:_read()
  self.signature = self._io:read_bytes(3)
  if not(self.signature == "\211\053\058") then
    error("not equal, expected " ..  "\211\053\058" .. ", but got " .. self.signature)
  end
  self.format_version_num = self._io:read_u1()
  self.version = SpaceRangersQm.Version(self._io, self, self._root)
  if self.format_version >= 7 then
    self.changelog = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  self.giver_race = SpaceRangersQm.Race(self._io, self, self._root)
  self.success_condition = SpaceRangersQm.SuccessCondition(self._io:read_u1())
  self.planet_races = SpaceRangersQm.Race(self._io, self, self._root)
  if self.format_version < 6 then
    self.unkn_sometimes0 = self._io:read_u4le()
  end
  self.player_status = SpaceRangersQm.PlayerStatus(self._io, self, self._root)
  if self.format_version < 6 then
    self.unkn_sometimes1 = self._io:read_u4le()
  end
  self.player_race = SpaceRangersQm.Race(self._io, self, self._root)
  if self.format_version < 6 then
    self.unkn_sometimes2 = self._io:read_u4le()
  end
  self.player_reputation = self._io:read_u4le()
  self.screen_size = SpaceRangersQm.Vec2U1(self._io, self, self._root)
  self.grid_granularity = SpaceRangersQm.Vec2U1(self._io, self, self._root)
  self.transition_limit = self._io:read_u4le()
  self.difficulty = self._io:read_u4le()
  if self.format_version > 6 then
    self.parameter_count_num = self._io:read_u4le()
  end
  self.parameters = {}
  for i = 0, self.parameter_count - 1 do
    self.parameters[i + 1] = SpaceRangersQm.Parameter(i, self._io, self, self._root)
  end
  self.to_star = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.parsec = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.artefact = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.to_planet = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.date = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.money = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.from_planet = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.from_star = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.ranger = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.loc_count = self._io:read_u4le()
  self.transition_count = self._io:read_u4le()
  self.congrat_message = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.description = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.unkn3 = self._io:read_u4le()
  self.unkn4 = self._io:read_u4le()
  self.locations = {}
  for i = 0, self.loc_count - 1 do
    self.locations[i + 1] = SpaceRangersQm.Location(self._io, self, self._root)
  end
  self.transitions = {}
  for i = 0, self.transition_count - 1 do
    self.transitions[i + 1] = SpaceRangersQm.Transition(self._io, self, self._root)
  end
end

SpaceRangersQm.property.parameter_count_comp_1 = {}
function SpaceRangersQm.property.parameter_count_comp_1:get()
  if self._m_parameter_count_comp_1 ~= nil then
    return self._m_parameter_count_comp_1
  end

  self._m_parameter_count_comp_1 = utils.box_unwrap((self.parameter_count_comp < 48) and utils.box_wrap(48) or (self.parameter_count_comp))
  return self._m_parameter_count_comp_1
end

SpaceRangersQm.property.parameter_count_comp = {}
function SpaceRangersQm.property.parameter_count_comp:get()
  if self._m_parameter_count_comp ~= nil then
    return self._m_parameter_count_comp
  end

  self._m_parameter_count_comp = (6 << self.format_version)
  return self._m_parameter_count_comp
end

SpaceRangersQm.property.description_count = {}
function SpaceRangersQm.property.description_count:get()
  if self._m_description_count ~= nil then
    return self._m_description_count
  end

  self._m_description_count = 10
  return self._m_description_count
end

SpaceRangersQm.property.parameter_count = {}
function SpaceRangersQm.property.parameter_count:get()
  if self._m_parameter_count ~= nil then
    return self._m_parameter_count
  end

  self._m_parameter_count = utils.box_unwrap((self.format_version < 6) and utils.box_wrap(self.parameter_count_comp_1) or (self.parameter_count_num))
  return self._m_parameter_count
end

SpaceRangersQm.property.format_version = {}
function SpaceRangersQm.property.format_version:get()
  if self._m_format_version ~= nil then
    return self._m_format_version
  end

  self._m_format_version = (self.format_version_num & 15)
  return self._m_format_version
end

-- 
-- pixels.
-- 
-- 0 is unlimited.
-- 
-- Сложность квеста в процентах.

SpaceRangersQm.Vec2U1 = class.class(KaitaiStruct)

function SpaceRangersQm.Vec2U1:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Vec2U1:_read()
  self.vec = {}
  for i = 0, 2 - 1 do
    self.vec[i + 1] = self._io:read_u1()
  end
end


SpaceRangersQm.Parameter = class.class(KaitaiStruct)

SpaceRangersQm.Parameter.Type = enum.Enum {
  normal = 0,
  fail = 1,
  success = 2,
  death = 3,
}

SpaceRangersQm.Parameter.CriticalBoundary = enum.Enum {
  max = 0,
  min = 1,
}

function SpaceRangersQm.Parameter:_init(idx, io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self.idx = idx
  self:_read()
end

function SpaceRangersQm.Parameter:_read()
  self.range = SpaceRangersQm.RangeU4(self._io, self, self._root)
  if self._root.format_version < 6 then
    self.ave = self._io:read_u4le()
  end
  self.type = SpaceRangersQm.Parameter.Type(self._io:read_u1())
  self.unkn1 = self._io:read_u1()
  self.unkn2 = self._io:read_u1()
  self.unkn3 = self._io:read_u1()
  if self._root.format_version < 6 then
    self.unkn4 = self._io:read_u1()
  end
  self.show_at_zero_u1 = self._io:read_u1()
  if  ((self.idx == 0) and (self._root.format_version <= 2))  then
    self.unkn16 = self._io:read_bytes(16)
  end
  self.critical_boundary = SpaceRangersQm.Parameter.CriticalBoundary(self._io:read_u1())
  self.is_active_u1 = self._io:read_u1()
  self.grades_count = self._io:read_u4le()
  self.is_player_money_u1 = self._io:read_u1()
  self.name = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.grades = {}
  for i = 0, self.grades_count - 1 do
    self.grades[i + 1] = SpaceRangersQm.Parameter.Grade(self._io, self, self._root)
  end
  self.critical_message = SpaceRangersQm.SrStr(self._io, self, self._root)
  if self._root.format_version >= 6 then
    self.picture = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  if self._root.format_version >= 6 then
    self.sound = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  if self._root.format_version >= 6 then
    self.track = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  self.start_value = SpaceRangersQm.SrStr(self._io, self, self._root)
end

SpaceRangersQm.Parameter.property.show_at_zero = {}
function SpaceRangersQm.Parameter.property.show_at_zero:get()
  if self._m_show_at_zero ~= nil then
    return self._m_show_at_zero
  end

  self._m_show_at_zero = self.show_at_zero_u1 ~= 0
  return self._m_show_at_zero
end

SpaceRangersQm.Parameter.property.is_active = {}
function SpaceRangersQm.Parameter.property.is_active:get()
  if self._m_is_active ~= nil then
    return self._m_is_active
  end

  self._m_is_active = self.is_active_u1 ~= 0
  return self._m_is_active
end

SpaceRangersQm.Parameter.property.is_player_money = {}
function SpaceRangersQm.Parameter.property.is_player_money:get()
  if self._m_is_player_money ~= nil then
    return self._m_is_player_money
  end

  self._m_is_player_money = self.is_player_money_u1 ~= 0
  return self._m_is_player_money
end


SpaceRangersQm.Parameter.Grade = class.class(KaitaiStruct)

function SpaceRangersQm.Parameter.Grade:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Parameter.Grade:_read()
  self.range = SpaceRangersQm.RangeU4(self._io, self, self._root)
  self.label = SpaceRangersQm.SrStr(self._io, self, self._root)
end


SpaceRangersQm.Vec2U4 = class.class(KaitaiStruct)

function SpaceRangersQm.Vec2U4:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Vec2U4:_read()
  self.vec = {}
  for i = 0, 2 - 1 do
    self.vec[i + 1] = self._io:read_u4le()
  end
end


SpaceRangersQm.Location = class.class(KaitaiStruct)

SpaceRangersQm.Location.Show = enum.Enum {
  no_change = 0,
  show = 1,
  hide = 2,
}

SpaceRangersQm.Location.TextSelectionMethod = enum.Enum {
  order = 0,
  formula = 1,
}

function SpaceRangersQm.Location:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Location:_read()
  self.passes_days = self._io:read_u4le()
  self.coord = SpaceRangersQm.Vec2U4(self._io, self, self._root)
  self.id = self._io:read_u4le()
  if self._root.format_version >= 6 then
    self.visit_limit = self._io:read_u4le()
  end
  self.type = SpaceRangersQm.Location.Type(self._io, self, self._root)
  self.actions = {}
  for i = 0, self._root.parameter_count - 1 do
    self.actions[i + 1] = SpaceRangersQm.ParameterAction(i, self._io, self, self._root)
  end
  if self._root.format_version >= 6 then
    self.description_count_num = self._io:read_u4le()
  end
  self.descriptions = {}
  for i = 0, self._root.description_count - 1 do
    self.descriptions[i + 1] = SpaceRangersQm.Location.Description(self._io, self, self._root)
  end
  self.text_selection_method = SpaceRangersQm.Location.TextSelectionMethod(self._io:read_u1())
  self.unkn1 = self._io:read_u4le()
  self.name = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.unkn3 = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.text_selection_formula = SpaceRangersQm.SrStr(self._io, self, self._root)
end

SpaceRangersQm.Location.property.description_count = {}
function SpaceRangersQm.Location.property.description_count:get()
  if self._m_description_count ~= nil then
    return self._m_description_count
  end

  self._m_description_count = utils.box_unwrap((self._root.format_version >= 6) and utils.box_wrap(self.description_count_num) or (self._root.description_count))
  return self._m_description_count
end

-- 
-- location coordinate.
-- 
-- Длина еще одного текста (он повторяет первое описание локации, при изменении - ничего), назначение которого мне не ясно.

SpaceRangersQm.Location.Type = class.class(KaitaiStruct)

SpaceRangersQm.Location.Type.Type = enum.Enum {
  none = 0,
  initial = 1,
  empty = 2,
  success = 3,
  fail = 4,
  death = 5,
}

function SpaceRangersQm.Location.Type:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Location.Type:_read()
  if self._root.format_version < 6 then
    self.is_initial_ = self._io:read_u1()
  end
  if self._root.format_version < 6 then
    self.is_success_ = self._io:read_u1()
  end
  if self._root.format_version < 6 then
    self.is_fail_ = self._io:read_u1()
  end
  if self._root.format_version < 6 then
    self.is_death_ = self._io:read_u1()
  end
  if self._root.format_version < 6 then
    self.is_empty_ = self._io:read_u1()
  end
  if self._root.format_version >= 6 then
    self.type_ = SpaceRangersQm.Location.Type.Type(self._io:read_u1())
  end
end

SpaceRangersQm.Location.Type.property.is_death = {}
function SpaceRangersQm.Location.Type.property.is_death:get()
  if self._m_is_death ~= nil then
    return self._m_is_death
  end

  self._m_is_death = utils.box_unwrap((self._root.format_version < 6) and utils.box_wrap(self.is_death_ ~= 0) or (self.type_ == SpaceRangersQm.Location.Type.Type.death))
  return self._m_is_death
end

SpaceRangersQm.Location.Type.property.is_success = {}
function SpaceRangersQm.Location.Type.property.is_success:get()
  if self._m_is_success ~= nil then
    return self._m_is_success
  end

  self._m_is_success = utils.box_unwrap((self._root.format_version < 6) and utils.box_wrap(self.is_success_ ~= 0) or (self.type_ == SpaceRangersQm.Location.Type.Type.success))
  return self._m_is_success
end

SpaceRangersQm.Location.Type.property.is_initial = {}
function SpaceRangersQm.Location.Type.property.is_initial:get()
  if self._m_is_initial ~= nil then
    return self._m_is_initial
  end

  self._m_is_initial = utils.box_unwrap((self._root.format_version < 6) and utils.box_wrap(self.is_initial_ ~= 0) or (self.type_ == SpaceRangersQm.Location.Type.Type.initial))
  return self._m_is_initial
end

SpaceRangersQm.Location.Type.property.is_fail = {}
function SpaceRangersQm.Location.Type.property.is_fail:get()
  if self._m_is_fail ~= nil then
    return self._m_is_fail
  end

  self._m_is_fail =  ((utils.box_unwrap((self._root.format_version < 6) and utils.box_wrap(self.is_fail_ ~= 0) or (self.type_ == SpaceRangersQm.Location.Type.Type.fail))) or (self.is_death)) 
  return self._m_is_fail
end

SpaceRangersQm.Location.Type.property.is_empty = {}
function SpaceRangersQm.Location.Type.property.is_empty:get()
  if self._m_is_empty ~= nil then
    return self._m_is_empty
  end

  self._m_is_empty = utils.box_unwrap((self._root.format_version < 6) and utils.box_wrap(self.is_empty_ ~= 0) or (self.type_ == SpaceRangersQm.Location.Type.Type.empty))
  return self._m_is_empty
end


SpaceRangersQm.Location.Description = class.class(KaitaiStruct)

function SpaceRangersQm.Location.Description:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Location.Description:_read()
  self.msg = SpaceRangersQm.SrStr(self._io, self, self._root)
  if self._root.format_version >= 6 then
    self.picture = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  if self._root.format_version >= 6 then
    self.sound = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  if self._root.format_version >= 6 then
    self.track = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
end


SpaceRangersQm.PasStr = class.class(KaitaiStruct)

function SpaceRangersQm.PasStr:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.PasStr:_read()
  self.size = self._io:read_u4le()
  self.value = str_decode.decode(self._io:read_bytes((self.size * 2)), "utf-16le")
end


SpaceRangersQm.Version = class.class(KaitaiStruct)

function SpaceRangersQm.Version:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Version:_read()
  self.major = self._io:read_u2le()
  self.minor = self._io:read_u2le()
end


SpaceRangersQm.ParameterAction = class.class(KaitaiStruct)

SpaceRangersQm.ParameterAction.ShowMode = enum.Enum {
  no_change = 0,
  show = 1,
  hide = 2,
}

SpaceRangersQm.ParameterAction.Unit = enum.Enum {
  value = 0,
  summ = 1,
  percentage = 2,
  expr = 3,
  unkn1000000 = 16777216,
}

function SpaceRangersQm.ParameterAction:_init(idx, io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self.idx = idx
  self:_read()
end

function SpaceRangersQm.ParameterAction:_read()
  self.unkn = self._io:read_u4le()
  self.range = SpaceRangersQm.RangeU4(self._io, self, self._root)
  self.delta = self._io:read_s4le()
  self.show_ = SpaceRangersQm.ParameterAction.ShowMode(self._io:read_u1())
  self.unit = SpaceRangersQm.ParameterAction.Unit(self._io:read_s4le())
  self.percent_present_u1 = self._io:read_u1()
  self.delta_present_u1 = self._io:read_u1()
  self.expr_present_u1 = self._io:read_u1()
  self.expr = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.includes = SpaceRangersQm.ParameterAction.Includes(self._io, self, self._root)
  self.mods = SpaceRangersQm.ParameterAction.Mods(self._io, self, self._root)
  self.threshold_message = SpaceRangersQm.SrStr(self._io, self, self._root)
  if self._root.format_version >= 6 then
    self.picture = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  if self._root.format_version >= 6 then
    self.sound = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
  if self._root.format_version >= 6 then
    self.track = SpaceRangersQm.SrStr(self._io, self, self._root)
  end
end

SpaceRangersQm.ParameterAction.property.percent_present = {}
function SpaceRangersQm.ParameterAction.property.percent_present:get()
  if self._m_percent_present ~= nil then
    return self._m_percent_present
  end

  self._m_percent_present = self.percent_present_u1 ~= 0
  return self._m_percent_present
end

SpaceRangersQm.ParameterAction.property.expr_present = {}
function SpaceRangersQm.ParameterAction.property.expr_present:get()
  if self._m_expr_present ~= nil then
    return self._m_expr_present
  end

  self._m_expr_present = self.delta_present_u1 ~= 0
  return self._m_expr_present
end

SpaceRangersQm.ParameterAction.property.delta_present = {}
function SpaceRangersQm.ParameterAction.property.delta_present:get()
  if self._m_delta_present ~= nil then
    return self._m_delta_present
  end

  self._m_delta_present = self.delta_present_u1 ~= 0
  return self._m_delta_present
end

SpaceRangersQm.ParameterAction.property.param = {}
function SpaceRangersQm.ParameterAction.property.param:get()
  if self._m_param ~= nil then
    return self._m_param
  end

  self._m_param = self._root.parameters[self.idx + 1]
  return self._m_param
end


SpaceRangersQm.ParameterAction.Includes = class.class(KaitaiStruct)

function SpaceRangersQm.ParameterAction.Includes:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.ParameterAction.Includes:_read()
  self.count = self._io:read_u4le()
  self.accept = self._io:read_u1()
  self.values = {}
  for i = 0, self.count - 1 do
    self.values[i + 1] = self._io:read_u4le()
  end
end


SpaceRangersQm.ParameterAction.Mods = class.class(KaitaiStruct)

function SpaceRangersQm.ParameterAction.Mods:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.ParameterAction.Mods:_read()
  self.count = self._io:read_u4le()
  self.type = self._io:read_u1()
  self.values = {}
  for i = 0, self.count - 1 do
    self.values[i + 1] = self._io:read_u4le()
  end
end


SpaceRangersQm.Race = class.class(KaitaiStruct)

function SpaceRangersQm.Race:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Race:_read()
  self.reserved0 = self._io:read_bits_int_be(1)
  self.unhabited = self._io:read_bits_int_be(1)
  self.reserved1 = self._io:read_bits_int_be(1)
  self.gaal = self._io:read_bits_int_be(1)
  self.faeyan = self._io:read_bits_int_be(1)
  self.human = self._io:read_bits_int_be(1)
  self.peleng = self._io:read_bits_int_be(1)
  self.malloq = self._io:read_bits_int_be(1)
end


SpaceRangersQm.Transition = class.class(KaitaiStruct)

function SpaceRangersQm.Transition:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.Transition:_read()
  self.priority = self._io:read_f8le()
  self.passes_days = self._io:read_u4le()
  self.id = self._io:read_u4le()
  self.source_id = self._io:read_u4le()
  self.destination_id = self._io:read_u4le()
  if self._root.format_version < 6 then
    self.color = self._io:read_u1()
  end
  self.always_show_u1 = self._io:read_u1()
  self.limit = self._io:read_u4le()
  self.show_order = self._io:read_u4le()
  self.actions = {}
  for i = 0, self._root.parameter_count - 1 do
    self.actions[i + 1] = SpaceRangersQm.ParameterAction(i, self._io, self, self._root)
  end
  self.condition_expr = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.title = SpaceRangersQm.SrStr(self._io, self, self._root)
  self.description = SpaceRangersQm.SrStr(self._io, self, self._root)
end

SpaceRangersQm.Transition.property.always_show = {}
function SpaceRangersQm.Transition.property.always_show:get()
  if self._m_always_show ~= nil then
    return self._m_always_show
  end

  self._m_always_show = self.always_show_u1 ~= 0
  return self._m_always_show
end


SpaceRangersQm.PlayerStatus = class.class(KaitaiStruct)

function SpaceRangersQm.PlayerStatus:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.PlayerStatus:_read()
  self.reserved = self._io:read_bits_int_be(5)
  self.warrior = self._io:read_bits_int_be(1)
  self.pirate = self._io:read_bits_int_be(1)
  self.merchant = self._io:read_bits_int_be(1)
end


SpaceRangersQm.SrStr = class.class(KaitaiStruct)

function SpaceRangersQm.SrStr:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.SrStr:_read()
  self.present = self._io:read_u4le()
  if self.present ~= 0 then
    self.str = SpaceRangersQm.PasStr(self._io, self, self._root)
  end
end


SpaceRangersQm.RangeU4 = class.class(KaitaiStruct)

function SpaceRangersQm.RangeU4:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function SpaceRangersQm.RangeU4:_read()
  self.vec2 = SpaceRangersQm.Vec2U4(self._io, self, self._root)
end

SpaceRangersQm.RangeU4.property.start = {}
function SpaceRangersQm.RangeU4.property.start:get()
  if self._m_start ~= nil then
    return self._m_start
  end

  self._m_start = self.vec2.vec[0 + 1]
  return self._m_start
end

SpaceRangersQm.RangeU4.property.stop = {}
function SpaceRangersQm.RangeU4.property.stop:get()
  if self._m_stop ~= nil then
    return self._m_stop
  end

  self._m_stop = self.vec2.vec[1 + 1]
  return self._m_stop
end


return SpaceRangersQm
