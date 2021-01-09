-- ModFreakz
-- For support, previews and showcases, head to https://discord.gg/ukgQa5K
Config = {
Use3DText = false
}
MF_ObjectSpawner = {}
local MFO = MF_ObjectSpawner

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj; end)

MFO.Version = '1.0.10'

Citizen.CreateThread(function(...)
  while not ESX do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj; end) Citizen.Wait(0); end
end)

MFO.Controls = {
  ["UP"]              = 96,   -- NUMPAD +
  ["DOWN"]            = 97,   -- NUMPAD -
  ["RIGHT"]           = 108,  -- NUMPAD 4
  ["LEFT"]            = 107,  -- NUMPAD 6
  ["BACK"]            = 111,  -- NUMPAD 8
  ["FORWARD"]         = 110,  -- NUMPAD 5

  ["ROTY+"]           = 189,  -- ARROW LEFT
  ["ROTY-"]           = 190,  -- ARROW RIGHT
  ["ROTX+"]           = 188,  -- ARROW UP
  ["ROTX-"]           = 187,  -- ARROW DOWN
  ["ROTZ+"]           = 117,  -- NUMPAD 7
  ["ROTZ-"]           = 118,  -- NUMPAD 9

  ["INCREASE_SPEED"]  = 209,  -- LEFT SHIFT
  ["DECREASE_SPEED"]  = 20,   -- Z

  ["INCREASE_RANGE"]  = 15,   -- SCROLL UP
  ["DECREASE_RANGE"]  = 14,   -- SCROLL DOWN

  ["GRAB_OBJECT"]     = 47,   -- G
  ["SAVE_OBJECT"]     = 74,   -- H
  ["DROP_OBJECT"]     = 29,   -- B
  ["DELETE_OBJECT"]     = 178,   -- Del
}

MFO.MoveSpeed       = 0.1 -- base obj move speed
MFO.RotSpeed        = 0.5 -- base rot speed

MFO.SpeedIncreaser  = 5.0 -- when pressing INCREASE_SPEED
MFO.SpeedDecreaser  = 0.1 -- when pressing DECREASE_SPEED

MFO.Range           = 3.0
MFO.RangeAdder      = 0.5

MFO.DespawnDist     = 200.0
MFO.SpawnDist       = 100.0

Strings = {
 ['Furnishing'] = 'Kaydet ~INPUT_REPLAY_HIDEHUD~\n Hız ~INPUT_MULTIPLAYER_INFO~ ~INPUT_VEH_SUB_ASCEND~  \nRange  ~INPUT_VEH_CINEMATIC_DOWN_ONLY~ ~INPUT_VEH_CINEMATIC_UP_ONLY~ \nÇevir ~INPUT_VEH_FLY_SELECT_TARGET_RIGHT~ ~INPUT_VEH_FLY_SELECT_TARGET_LEFT~ ~INPUT_CELLPHONE_LEFT~ ~INPUT_CELLPHONE_RIGHT~ ~INPUT_CELLPHONE_DOWN~ ~INPUT_CELLPHONE_UP~ \nHareket Ettir ~INPUT_VEH_SUB_PITCH_DOWN_ONLY~ ~INPUT_VEH_FLY_PITCH_UP_ONLY~ ~INPUT_VEH_FLY_ROLL_LEFT_ONLY~ ~INPUT_VEH_FLY_ROLL_RIGHT_ONLY~ \nYükseklik ~INPUT_REPLAY_FOVINCREASE~ ~INPUT_REPLAY_FOVDECREASE~'
}
