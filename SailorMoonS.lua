-- Detect snes9x.
if client == nil then
  snes9x = true
else
  snes9x = false
end
--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------
-- 判定/Hitboxes        攻撃/Hit  頭/Head   身/Body   本体/Collision
box_colors = {0xFFFFFF, 0xFF0000, 0xC0FF00, 0x00FF00, 0x0000FF}
box_alpha  = 0x40
box_border = 0x80

-- HPゲージとか/HP bars
hp_color_background = 0xF80000
hp_color = 0xF8C800
low_hp_color = 0xF8A040
high_hp_color = 0x20D001
advantage_color = 0x80FF80 --有利の色
disadvantage_color = 0xFF8080 --不利の色

-- コンボ練習設定 / Combo mode settings
idle_timeout = 120 -- オートモード発動 / Frames to wait before guard AI takes over
guard_timeout = 60 -- 攻撃後のオートガード / Frames to guard after recovering from stun

-- ユーザー色 / User palettes
chara_names = {"Moon","Mercury","Mars","Jupiter","Venus","Uranus","Neptune","Pluto","Chibimoon","Saturn"}

-- Colors are 15-bit BGR. Magenta:
--             B     G     R
--   ->    0 11111 00000 11111
--   ->    0111 1100 0001 1111
--    0  x  7    C    1    F
--
-- -1 = Default 1P color
-- -2 = Default 2P color


--------------------------------------------------------------------------------
-- You probably don't need to touch anything below here
--------------------------------------------------------------------------------
-- Memory offsets     1P        2P        Projectiles
--                     S       SuperS
palette_offsets = {0xE00238, 0xE0ABC4}
         --                    Hit     Hurt  Collision
hitbox_offsets = {{0x8A0000, 0xC1F1, 0xC229, 0xC23D}, --S
                  {0xAF0000, 0xB000, 0xB046, 0xB05C}} --SuperS
                  
input_offsets = {0x808373, 0x808347}

-- Game state tracking
game_version = 0
transition = 0
boxes = {}
players = {}
players_lastframe = {}
invincible = {false, false}
attack_frame = {0,0}
active_time = {-1,-1} -- Frames since leaving neutral state
neutral_time = {0,0} -- Frames since entering neutral state
last_action_id = {-1,-1}

-- Script state tracking
combo_damage = {0,0}
on_right = {false, false}
autoguard_time = {0,0}
player_side = {0,0}
backdash_disable = {0,0}
buttonlist = {B=0x8000, Y=0x4000, select=0x2000, start=0x1000, up=0x800, down=0x400, left=0x200, right=0x100, A=0x80, X=0x40, L=0x20, R=0x10}
camera = {x=0, y=0}
inputs = {{},{}}
input_log = {{},{}}
held_inputs = {{},{}}
recording_slot = {0,0}
playback_slot = {0,0}
playback_index = {0,0}
playback_loop = {false, false}
recorded_inputs = {{},{},{},{}}
input_idle_time = {0,0} -- Frames since last human input
mash_time = {0,0} -- AI is mashing buttons
player_swap = false

-- Reset position
left_offset = 0x00
left_distance = 0x2F
right_offset = 0x00
right_distance = 0x2F
center_offset = 0x00
center_distance = 0x80

-- Table of cancellable recovery animations (light attacks)
neutral_state = {{[0x42]=true,[0x48]=true,[0x54]=true,[0x58]=true},--Moon
                 {[0x41]=true,[0x46]=true,[0x53]=true,[0x57]=true},--Mercury
                 {[0x42]=true,[0x49]=true,[0x55]=true,[0x59]=true},--Mars
                 {[0x42]=true,[0x47]=true,[0x53]=true,[0x57]=true},--Jupiter
                 {[0x41]=true,[0x45]=true,[0x51]=true,[0x55]=true},--Venus
                 {[0x42]=true,[0x48]=true,[0x54]=true,[0x58]=true},--Uranus
                 {[0x41]=true,[0x45]=true,[0x56]=true,[0x5A]=true},--Neptune
                 {[0x41]=true,[0x49]=true,[0x55]=true,[0x59]=true},--Pluto
                 {[0x41]=true,[0x47]=true,[0x53]=true,[0x57]=true},--Chibi
                 {[0x41]=true,[0x43]=true,[0x49]=true,[0x4B]=true,[0x59]=true,[0x5B]=true,[0x61]=true,[0x63]=true}}--Saturn
                  
for chara_id = 1,10 do
  for i = 0,9 do
    neutral_state[chara_id][i] = true
  end
  neutral_state[chara_id][0x0C] = true
  neutral_state[chara_id][0x0D] = true
  neutral_state[chara_id][0x21] = true
end

palette_data = {}
selected_color = 1
palette_temp = {nil,nil}
palette_temp[0] = 0
                     
-- Interface settings
gui_selected = 1
gui_info = 1
gui_damage = 1
gui_hp = 0
gui_hitbox = 3
gui_subframe = -1
gui_dummy = 1
gui_dummy_guard = 2
gui_dummy_recover = 1
gui_dummy_recover_slot = 0
gui_input = 0
gui_swap = 0

--------------------------------------------------------------------------------
-- Function wrappers to account for different functionality across emulators
--------------------------------------------------------------------------------
local addalpha
if snes9x then
  addalpha = function(color, alpha)
    if color == nil then return nil end
    if alpha == nil then return color*0x100 + 0xFF end
    return color*0x100 + alpha
  end
else
  addalpha = function(color, alpha)
    if color == nil then return nil end
    if alpha == nil then return color + 0xFF000000 end
    return color + alpha*0x1000000
  end
end

local drawbox
if snes9x then
  drawbox = function(x, y, x2, y2, background, backgroundalpha, line, linealpha)
    background = addalpha(background, backgroundalpha)
    if line == nil then
      line = background
    else
      line = addalpha(line, linealpha)
    end
    gui.box(x, y, x2, y2, background, line)
  end
else
  drawbox = function(x, y, x2, y2, background, backgroundalpha, line, linealpha)
    background = addalpha(background, backgroundalpha)
    line = addalpha(line, linealpha)
    if line == nil then line = background end
    gui.drawBox(x, y, x2, y2, line, background)
  end
end

local drawline
if snes9x then
  drawline = function(x, y, x2, y2, color, alpha)
    color = addalpha(color, alpha)
    gui.line(x, y, x2, y2, color)
  end
else
  drawline = function(x, y, x2, y2, color, alpha)
    color = addalpha(color, alpha)
    gui.drawLine(x, y, x2, y2, color)
  end
end

local drawtext
if snes9x then
  drawtext = function(x, y, message, color, background, alpha, backgroundalpha)
    if color == nil then
      color = 0xFFFFFFFF
    else
      color = addalpha(color, alpha)
    end
    if background ~= nil then
      if backgroundalpha == nil then backgroundalpha = 128 end
      background = addalpha(background, backgroundalpha)
      gui.box(x - 1, y - 1, x+string.len(message)*4 + 1, y+7, background, 0)
    end
    gui.text(x + 1, y, message, color, 0)
  end
else
  drawtext = function(x, y, message, color, background, alpha, backgroundalpha)
    if color == nil then
      color = 0xFFFFFFFF
    else
      color = addalpha(color, alpha)
    end
    if background == nil then
      background = 0
    else
      if backgroundalpha == nil then backgroundalpha = 128 end
      background = addalpha(background, backgroundalpha)
    end
    gui.pixelText(x, y, message, color, background)
  end
end

local getregister_pc
if snes9x then
  getregister_pc = function()
    return memory.getregister("pbpc")
  end
else
  getregister_pc = function()
    return emu.getregister("PC")
  end
end

local readbyte, readbytesigned, writebyte, writebytesigned
local readword, readwordsigned, writeword, writewordsigned
local readdword, readdwordsigned, writedword, writedwordsigned
if snes9x then
  readbyte = memory.readbyte
  readbytesigned = memory.readbytesigned
  writebyte = memory.writebyte
  writebytesigned = memory.writebytesigned
  readword = memory.readword
  readwordsigned = memory.readwordsigned
  writeword = memory.writeword
  writewordsigned = memory.writewordsigned
  readdword = memory.readdword
  readdwordsigned = memory.readdwordsigned
  writedword = memory.writedword
  writedwordsigned = memory.writedwordsigned
else
  readbyte = memory.read_u8
  readbytesigned = memory.read_s8
  writebyte = memory.write_u8
  writebytesigned = memory.write_s8
  readword = memory.read_u16_le
  readwordsigned = memory.read_s16_le
  writeword = memory.write_u16_le
  writewordsigned = memory.write_s16_le
  readdword = memory.read_u32_le
  readdwordsigned = memory.read_s32_le
  writedword = memory.write_u32_le
  writedwordsigned = memory.write_s32_le
end

local readbyterange
if snes9x then
  readbyterange = function (addr, length)
    local t = memory.readbyterange(addr + 1, length - 1)
    t[0] = readbyte(addr)
    return t
  end
else
  readbyterange = function (addr, length)
    local t = memory.readbyterange(addr, length)
    t[0] = readbyte(addr)
    return t
  end
end
--------------------------------------------------------------------------------
-- Data type conversion
--------------------------------------------------------------------------------
local function byte_to_signed(byte1)
  if byte1 > 0x80 then return byte1 - 0x100 end
  return byte1
end

local function bytes_to_word(byte1, byte2)
  return byte1 + byte2*0x100
end

local function bytes_to_word_signed(byte1, byte2)
  byte1 = byte1 + byte2*0x100
  if byte1 >= 0x8000 then return byte1 - 0x10000 end
  return byte1
end

local function bytes_to_dword(byte1, byte2, byte3, byte4)
  return byte1 + byte2*0x100 + byte3*0x10000 + byte4*0x1000000
end

local function bytes_to_dword_signed(byte1, byte2, byte3, byte4)
  byte1 = byte1 + byte2*0x100 + byte3*0x10000 + byte4*0x1000000
  if byte1 >= 0x80000000 then return byte1 - 0x100000000 end
  return byte1
end

--local function word_to_bytes(n)
--  local t = {}
--  local i = 1
--  while n > 0 do
--    t[i] = n % 0x100
--    n = math.floor(n/0x100)
--    i = i + 1
--  end
--  return t
--end

--------------------------------------------------------------------------------
-- Memory access. Read by passing no variables.
--------------------------------------------------------------------------------
local function mem_camera_pos(x, y)
  if x == nil and y == nil then
    return {x=readwordsigned(0x7E0A00), y=readwordsigned(0x7E0A02)}
  end
  if x ~= nil then writeword(0x7E0A00, x) end
  if y ~= nil then writeword(0x7E0A02, y) end
end

-- Set game time to the first frame of the given second
local function mem_timer(seconds)
  if seconds == nil then
    return readdword(0x7E0802)
  end
  seconds = seconds + 1
  writedword(0x7E0802, math.floor(seconds / 10)*0x10000 + (seconds % 10)*0x100 + 1)
end

-- Game mode. 0 = VS, 1 = Story, 4 = Training
local function mem_game_mode(n)
  if n == nil then
    return readbyte(0x7E008D)
  end
  writebyte(0x7E008D, n)
end

-- General player modification
local function mem_player(player_no, variable, n)
  if variable == nil then variable = 0 end
  local offset = 0x7E0F80 + player_no*0x80 + variable
  if n == nil then
    return readbyte(offset)
  end
  writebyte(offset, n)
end

-- Player position including subpixels
local function mem_player_pos(player_no, x, y)
  local offset = 0x7E0F80 + player_no*0x80
  if x == nil and y == nil then
    return {x=readdword(offset + 0x20), y=readdword(offset + 0x24)}
  end
  if x ~= nil then writedword(offset + 0x20, x) end
  if y ~= nil then writedword(offset + 0x24, y) end
end

-- Player velocity in subpixels per frame
local function mem_player_vel(player_no, x, y)
  local offset = 0x7E0F80 + player_no*0x80
  if x == nil and y == nil then
    return {x=readwordsigned(offset + 0x30), y=readwordsigned(offset + 0x32)}
  end
  if x ~= nil then writeword(offset + 0x30, x) end
  if y ~= nil then writeword(offset + 0x32, y) end
end

-- Player HP
local function restore_player_hp(player_no, amount)
  if amount == nil then amount = 96 end
  local max_hp = readbyte(0x7E0FCA + player_no*0x80)
  writebyte(0x7E0FC9 + player_no*0x80, max_hp - 96 + amount)
end

-- Make a character do something
local function mem_player_action(player_no, action_id)
  local offset = 0x7E0F80 + player_no*0x80
  if action_id == nil then
    return readbyte(offset + 0x01)
  end
  writebyte(offset + 0x01, action_id)
  writeword(offset + 0x02, 0x0001)
  writebyte(offset + 0x04, action_id)
  writeword(offset + 0x06, 0x0000)
  -- action_id list:
  -- 00 Neutral -- 01 Walk forward -- 02 Walk backward
  -- 03 Crouch -- 04 Half crouch
  -- 05 Jump startup -- 06 Jump up -- 07 Jump forward -- 08 Jump back -- 09 Landing
  -- 0C Stand block -- 0D Crouch block
  -- 0E Stand blockstun -- 0F Crouch blockstun
  -- 10 Head hitstun (light) -- 11 head hitstun (heavy)
  -- 12 Body hitstun (light) -- 13 Body hitstun (heavy)
  -- 14 Duck hitstun (light) -- 15 Duck hitstun (heavy)
  -- 16 Air hitstun
  -- 17 Flame -- 18 Electric -- 19 Knockdown -- 1A Heavy knockdown
  -- 1B Thrown (face up) -- 1C Held -- 1D Thrown (feet up)
  -- 1E Down -- 1F Knockout -- 20 Stand up
  -- 21 Neutral(25% HP)
  -- 22 Intro
  -- 23 Throw tech
  -- 24 Victory
  -- 25 Freeze
  -- 26 Backdash
  -- 27 Slip -- 28 Down -- 29 Stand up -- 2A Embarassed
  -- Chibi 63-64 Misfire
end

local function reset_player_state(player_no)
  mem_player_action(player_no, 0)
  mem_player(player_no, 0x46, 0)
  restore_player_hp(player_no)
end
------------------------------------------------------------------------
-- Interface
------------------------------------------------------------------------
-- Convert internal hitbox data into a table of coordinates
local function create_box(player_no, offset, box_type)
  local player = players_lastframe[player_no]
  -- Reads positional data from after the player has moved instead of before.
  if gui_subframe == -1 then
    if player_no == 1 and box_type ~= 2 then player = players[player_no] end
  elseif gui_subframe >= player_no then
    player = players[player_no]
  end
  
  if player == nil then return nil end
  -- Attacks are not processed on the first frame of an action
  if box_type == 2 then
    if player[0x02] == 0 then return nil end
  end
  
  --local camera = mem_camera_pos()
  local flip_x = player[0x09]
  local pos_x = bytes_to_dword_signed(player[0x20], player[0x21], player[0x22], player[0x23])
  local pos_y = bytes_to_dword_signed(player[0x24], player[0x25], player[0x26], player[0x27])
  if pos_y >= 0x800000 then pos_y = pos_y - 0x1000000 end
  pos_x = math.floor(pos_x/0x100)
  pos_y = math.floor(pos_y/0x100)
  if player_no <= 2 then
    pos_x = math.max(math.min(pos_x, 360), 24)
    pos_y = math.min(pos_y, 192)
  end
  
  pos_x = pos_x - camera.x
  pos_y = pos_y - camera.y
  
  -- Default position is center dot
  local box_x = pos_x
  local box_y = pos_y
  local box_width = 1
  local box_height = 1
  local flags = 0
  if offset >= 0 then
    box_height = readbyte(offset + 5)
    if box_height == 0 then return nil end
    box_width = readbyte(offset + 1 + flip_x*2)
    if box_width == 0 then return nil end
    box_x = readbytesigned(offset + flip_x*2) + pos_x
    box_y = readbytesigned(offset + 4) + pos_y
    box_flags = readbyte(offset + 6)
    --local unknown = readbytesigned(offset + 7) --This appears to do nothing
  end
  if box_type == 2 or box_type == 5 then -- Collision / Attack
    -- Hit detection bug that gives 2P side a 1-pixel range advantage.
    box_x = box_x - 1
    box_y = box_y - 1
  else
    -- Account for conversion to x1,x2 format
    box_width = box_width - 1
    box_height = box_height - 1
  end
  if box_y + box_height < 0 then return nil end
  return {box_x, box_y, box_x + box_width, box_y + box_height, box_flags, box_type}
end

--------------------------------------------------------------------------------
-- PALETTE STUFF
--------------------------------------------------------------------------------
local function snes_rgb(color)
  local r = color % 32
  local g = math.floor(color / 32) % 32
  local b = math.floor(color / 1024) % 32
  return {R=r, G=g, B=b}
end

local function rgb_snes(color)
  return color.R + color.G*32 + color.B*1024
end

local function snes_rgb24(color)
  color = snes_rgb(color)
  color.R = math.floor(color.R * 255 / 31 + 0.5)
  color.G = math.floor(color.G * 255 / 31 + 0.5)
  color.B = math.floor(color.B * 255 / 31 + 0.5)
  return color
end

local function rgb24_snes(color)
  local r = math.floor(color.R * 31 / 255 + 0.5)
  local g = math.floor(color.G * 31 / 255 + 0.5)
  local b = math.floor(color.B * 31 / 255 + 0.5)
  return r + g*32 + b*1024
end

local function mem_color(player_no, index, color)
  local offset = 0x0005DE + player_no*0x20 + index*2
  if index > 32 then
    offset = offset - 0x110
    if player_no == 2 then
      offset = offset - 0x18
    end
  elseif index > 16 then
    offset = offset + 0x20
  end
  if color == nil then
    return readword(offset)
  end
  writeword(offset, color)
end

local function colorpath()
  local dirname = ""
  if snes9x then
    dirname = debug.getinfo(1).source:match("@?(.*[/\\])")
  end
  if game_version == 1 then
    dirname = dirname .. "sms_colors"
  elseif game_version == 2 then
    dirname = dirname .. "smss_colors"
  end
  return dirname
end

local function import_palettes()
  -- Default palettes
  for chara_id = 1, 8 + game_version do
    local chara_name = chara_names[chara_id]
    palette_data[chara_id] = {}
    for palette_no = 0,1 do
      -- Lots of data indirection
      local palette_addr = readdword(0xE00001 + readword(palette_offsets[game_version] + chara_id*2) + palette_no*3) % 0x1000000
      palette_data[chara_id][palette_no] = {}
      for i = 0,15 do
        palette_data[chara_id][palette_no][i + 1] = readword(palette_addr + 2*i)
      end
      palette_addr = readdword(0xE0000A + readword(palette_offsets[game_version] + chara_id*2)) % 0x1000000
      for i = 0,15 do
        palette_data[chara_id][palette_no][i + 17] = readword(palette_addr + 2*i)
      end
      palette_addr = readdword(0xE00007 + readword(palette_offsets[game_version] + chara_id*2)) % 0x1000000
      for i = 0,3 do
        palette_data[chara_id][palette_no][i + 33] = readword(palette_addr + 2*i)
      end
    end
    local dirname = colorpath()
    for palette_no = 0,31 do
      -- Text
      local filename = string.format("%02d_%02d_%s.txt", chara_id, palette_no, chara_name)
      local filepath = dirname .. "/" .. filename
      local file = io.open(filename, "rb")
      if file ~= nil then
        local data = file:read("*a")
        file:close()
        palette_data[chara_id][palette_no] = {}
        local i = 1
        for c in string.gmatch(s, "([^,]+)") do
          local n = tonumber(c)
          if n >= 0x80000000 then n = n - 0x100000000 end
          palette_data[chara_id][palette_no][i] = n
          i = i + 1
        end
        print(filename .. " : Loaded")
      end
      -- Bitmap
      local filename = string.format("%02d_%02d_%s.bmp", chara_id, palette_no, chara_name)
      local filepath = dirname .. "/" .. filename
      local file = io.open(filepath, "rb")
      if file ~= nil then
        local data = file:read("*a")
        file:close()
         -- Test for "BM" identifier
        if string.byte(data, 1) ~= 66 or string.byte(data, 2) ~= 77 then
          print(filename .. " : Invalid bitmap")
        else
          -- Load relevant parts of the header
          bmp_headsize = bytes_to_dword(string.byte(data, 15), string.byte(data, 16), string.byte(data, 17), string.byte(data, 18))
          bmp_bpp = bytes_to_word(string.byte(data, 29), string.byte(data, 30))
          bmp_palettecount = bytes_to_dword(string.byte(data, 47), string.byte(data, 48), string.byte(data, 49), string.byte(data, 50))
          -- Make sure palette has enough colors
          if bmp_bpp ~= 8 or bmp_palettecount < 36 then
            print(filename .. ": Invalid palette")
          else
            palette_data[chara_id][palette_no] = {}
            -- Read BMP Palette
            local offset = 14 + bmp_headsize
            for i = 1,36 do
              local color = {}
              color.B = string.byte(data, offset + i*4 - 3)
              color.G = string.byte(data, offset + i*4 - 2)
              color.R = string.byte(data, offset + i*4 - 1)
              palette_data[chara_id][palette_no][i] = rgb24_snes(color)
            end
            print( filename .. " : Loaded")
          end
        end
      end
    end
  end
end

-- Change the character palette
-- Passing only the player number resets them to their default palette
local function load_palette(player_no, chara_id, palette_no)
  if chara_id == nil then chara_id = readbyte(0x7E1CFD + player_no*3) end
  if palette_no == nil then palette_no = readbyte(0x7E1CFF + player_no*3) end
  -- Lots of data indirection
  local palette = palette_data[chara_id][palette_no]
  if palette == nil then
    palette = palette_data[chara_id][0]
  end
  for i = 1,32 do
    local color = palette[i]
    if color == nil or color == -1 then
      color = palette_data[chara_id][0][i]
    elseif color == -2 then
      color = palette_data[chara_id][1][i]
    end
    mem_color(player_no, i, color)
  end
end

-- Only works correctly if called from within maininput
local joypad_set = function(player_no, buttons)
  local input = readword(0x7E005A + player_no * 2)
  for k, v in pairs(buttons) do
    local i = buttonlist[k]
    if input % (i*2) >= i then
      if v == false then
        input = input - i
      end
    elseif v == true then
      input = input + i
    end
  end
  writeword(0x7E005A + player_no * 2, input)
end
-- Faster than passing false to every button
local joypad_disable = function(player_no)
  writeword(0x7E005A + player_no * 2, 0)
end

local drawmenu = function(id, name, values, index)
  local gui_x = 180
  local gui_y = 64
  local gui_r = gui_x + 72
  if gui_selected == id then
    color = 0xFFFFFF
  else
    color = 0xC0C0C0
  end
  drawbox(gui_x, gui_y + id*6, gui_r, gui_y + id*6 + 6, 0x000000, 0x80)
  drawtext(gui_x, gui_y + id*6, name, color, 0, 0xFF, 0)
  if values ~= nil then
    local s = values
    if index ~= nil then
      s = values[index]
    end
    drawtext(gui_r - string.len(s)*4, gui_y + id*6, s, color, 0, 0xFF, 0)
  end
end
--------------------------------------------------------------------------------
-- User input and manipulation of game input
-- Hooks the game code immediately after it reads the gamepads
--------------------------------------------------------------------------------
local function maininput()
  -- Detect and adjust game version
  local game_code = readbyte(0xFFB3)
  --S
  if game_code == 81 then
    if game_version ~= 1 then
      game_version = 1
      import_palettes()
    end
  --SuperS
  elseif game_code == 74 then 
    if game_version ~= 2 then
      game_version = 2
      import_palettes()
    end
  else
    return
  end
  -- Check we're at the right hook for this game.
  if getregister_pc() ~= input_offsets[game_version] then return end
  
  local game_mode = mem_game_mode() -- 0x04 = Training mode.
  local in_game = readbyte(0x7E0070) > 0
  local game_paused = readbyte(0x7E01FA) > 0x80
  -- Detect game exit via select button to prevent freeze in SuperS
  if in_game then
    if readbyte(0x7E00A4) % 0x40 >= 0x20 then
      if readbyte(0x7E00AC) % 0x40 < 0x20 then
        in_game = false
      end
    end
  end
  
  
  if in_game then
    -- Change game mode variable to enable training mode damage
    if game_mode == 4 then
      if transition == 0 then
        -- Delay change by 1 frame to avoid menu bugs
        transition = 1
      else
        mem_game_mode(5)
      end
    end
  else
    -- Revert changes to avoid menu bugs
    transition = 0
    if game_mode == 5 then mem_game_mode(4) end
    boxes = {}
    players = {}
  end
  
  -- Input history
  if in_game and not game_paused then
    if gui_input > 0 then
      for player_no = 1,2 do
        if gui_input == 3 or gui_input == player_no then
          local i = readword(0x7E00A1 + player_no * 2)
          local input = {}
          local lastinput = input_log[player_no][1]
          if lastinput == nil then lastinput = {} end
          local addinput = false
          -- Compare current input to previous input and add a new entry if different
          for k, v in pairs(buttonlist) do
            if k ~= "L" and k ~= "R" and k ~= "select" and k ~= "start" then
              input[k] = i % (v*2) >= v
              if input[k] ~= lastinput[k] then addinput = true end
            end
          end
          if addinput then
            table.insert(input_log[player_no], 1, input)
            input_log[player_no][1]["time"] = 1
          else
            -- If input is the same, increment its frame counter instead
            input_log[player_no][1]["time"] = input_log[player_no][1]["time"] + 1
          end
          input_log[player_no][25] = nil -- Limit to 24 rows
          -- Display on screen
          local gui_y = 64
          for k, v in pairs(input_log[player_no]) do
            local s = ""
            if v["left"] then
              s = s .. "<"
            end
            if v["up"] then
              s = s .. "^"
            end
            if v["down"] then
              s = s .. "v"
            end
            if v["right"] then
              s = s .. ">"
            end
            if v["Y"] then s = s .. "Y" end
            if v["X"] then s = s .. "X" end
            if v["B"] then s = s .. "B" end
            if v["A"] then s = s .. "A" end
            if player_no == 1 then
              s = string.format("%2d ", math.min(v["time"], 99)) .. s
              drawtext(0, gui_y, s, 0xFFFFFF, 0x000000, 0xFF, 0x80)
            else
              s = s .. string.format(" %2d", math.min(v["time"], 99))
              drawtext(255 - string.len(s)*4, gui_y, s, 0xFFFFFF, 0x000000, 0xFF, 0x80)
            end
            gui_y = gui_y + 6
          end
        end
      end
    end
  else
    input_log = {{},{}}
  end
   
  for player_no = 1,2 do
    -- Restore player colors to normal after being highlighted in palette edit mode
    if palette_temp[player_no] ~= nil then
      mem_color(player_no, selected_color, palette_temp[player_no])
      palette_temp[player_no] = nil
    end
    -- Get player input from the game instead of relying on emulators to be consistent.
    local i = readword(0x7E005A + player_no * 2)
    local input = inputs[player_no]
    local held_input = held_inputs[player_no]
    local idle = input_idle_time[player_no] + 1
    for k, v in pairs(buttonlist) do
      input[k] = i % (v*2) >= v
      if input[k] then
        if (held_input[k] or 0) <= 0 then
          held_input[k] = 1
        else
          held_input[k] = held_input[k] + 1
        end
        idle = 0
      elseif (held_input[k] or 0) >= 0 then
        held_input[k] = -1
      else
        held_input[k] = held_input[k] - 1
      end
    end
    if recording_slot[player_no] > 0 or playback_slot[player_no] > 0 then idle = 0 end
    input_idle_time[player_no] = idle
  end
  
  -- Swap controller inputs if either player is holding the R button
  if gui_swap == 0 then
    for player_no = 1,2 do
      if held_inputs[player_no]["R"] == 1 then
        player_swap = not player_swap
      end
    end
  elseif inputs[1]["R"] or inputs[2]["R"] then
    player_swap = true
  else
    player_swap = false
  end
    
  if player_swap then
    joypad_set(1, inputs[2])
    joypad_set(2, inputs[1])
    if gui_info > 0 then
      drawtext(223, 212, "PAD SWAP", 0xFFFFFF, 0x000000, 0xFF, 0x00)
    end
  end
  
  -- Replace input with recorded inputs when in playback mode
  for player_no = 1,2 do
    local slot = playback_slot[player_no]
    local index = playback_index[player_no]
    if in_game and not game_paused and slot > 0 and index > 0 then
      if recorded_inputs[slot][index] == nil then
        -- Loop the recording
        if playback_loop[player_no] then
          index = 1
        else
          index = 0
          -- Force dummy to reactivate
          input_idle_time[player_no] = idle_timeout
        end
      end
      if index == 0 or recorded_inputs[slot][index] == nil then
        -- Nothing is recorded
        playback_slot[player_no] = 0
        playback_index[player_no] = 0
      else
        -- Display status if input display is on
        if gui_input == 3 or gui_input == player_no then
          drawtext(-43 + player_no*92, 48, string.format("Playback %d", slot), 0xFFFFFF, 0x000000, 0xFF, 0x80)
          drawtext(-43 + player_no*92, 54, string.format("%df", index), 0xFFFFFF, 0x000000, 0xFF, 0x80)
        end
        -- Write inputs to game memory
        local input = recorded_inputs[slot][index]
        joypad_set(player_no, input)
        -- Swap left/right if on the right
        if on_right[player_no] then
          joypad_set(player_no, {left=input["right"], right=input["left"]})
        end
        playback_index[player_no] = index + 1
      end
    end
  end
  
  -- Main input processing
  for player_no = 1,2 do
    local input = inputs[player_no]
    local held_input = held_inputs[player_no]
    
    -- This variable indicates the player being controlled as opposed to controller number
    local player_control = player_no
    if player_swap then player_control = 3 - player_no end
    
    local player = players[player_control]
    if player == nil or game_paused or not in_game then
      -- Stuff to do when not in active gameplay
      if not in_game then
        -- Reset playback state upon returning to character select
        playback_slot[player_control] = 0
        recording_slot[player_control] = 0
      end
    else
      -- Disable select button quit unless held for 1 second.
      if held_input["select"] < 60 then
        joypad_set(player_no, {select=false})
      elseif player_no ~= 1 then
        -- Allow player 2 to exit the game
        joypad_set(1, {select=true})
      end
      
      if playback_slot[player_control] > 0 and playback_index[player_control] == 0 then
        -- Playback slot selected. Prompt player to begin playback.
        drawtext(-43 + player_control*92, 48, "Select:Play", 0xFFFFFF, 0x000000, 0xFF, 0x80)
        drawtext(-43 + player_control*92, 54, "Start:Cancel", 0xFFFFFF, 0x000000, 0xFF, 0x80)
        joypad_set(player_control, {start=false})
        if held_input["start"] == -1 then
          playback_slot[player_control] = 0
          joypad_disable(player_control)
        elseif held_input["select"] == 1 then
          -- Begin playback
          playback_index[player_control] = 1
          playback_loop[player_control] = true
        end
      end
      if playback_slot[player_control] == -1 then
        -- Playback mode. Prompt player to select a slot.
        drawtext(-43 + player_control*92, 48, "Playback slot", 0xFFFFFF, 0x000000, 0xFF, 0x80)
        drawtext(-43 + player_control*92, 54, "Y/X/B/A", 0xFFFFFF, 0x000000, 0xFF, 0x80)
        if held_input["Y"] == -1 then
          playback_slot[player_control] = 1
        elseif held_input["X"] == -1 then
          playback_slot[player_control] = 2
        elseif held_input["B"] == -1 then
          playback_slot[player_control] = 3
        elseif held_input["A"] == -1 then
          playback_slot[player_control] = 4
        elseif held_input["L"] == -1 then
          playback_slot[player_control] = 0
        elseif held_input["select"] == 1 then
          -- Pressing select a second time switches to recording mode.
          playback_slot[player_control] = 0
          recording_slot[player_control] = -1
        end
        if held_input["select"] < 60 then
          -- Disable all in-game input except for holding select to exit
          joypad_disable(player_control)
        end
      elseif recording_slot[player_control] == -1 then
        -- Recording mode. Prompt player to select a slot.
        drawtext(-43 + player_control*92, 48, "Recording slot", 0xFFFFFF, 0x000000, 0xFF, 0x80)
        drawtext(-43 + player_control*92, 54, "Y/X/B/A", 0xFFFFFF, 0x000000, 0xFF, 0x80)
        if held_input["Y"] == -1 then
          recording_slot[player_control] = 1
        elseif held_input["X"] == -1 then
          recording_slot[player_control] = 2
        elseif held_input["B"] == -1 then
          recording_slot[player_control] = 3
        elseif held_input["A"] == -1 then
          recording_slot[player_control] = 4
        elseif held_input["select"] == 1 then
          -- Cancel if select is pressed a third time.
          recording_slot[player_control] = 0
        end
        if recording_slot[player_control] > 0 then
          -- Slot selected. Wipe previously recorded data.
          recorded_inputs[recording_slot[player_control]] = {}
        end
        if held_input["select"] < 60 then
          -- Disable all in-game input except for holding select to exit
          joypad_disable(player_control)
        end
      elseif recording_slot[player_control] > 0 then
        -- Record inputs to selected slot
        drawtext(-43 + player_control*92, 48, string.format("Recording slot %d", recording_slot[player_control]), 0xFFFFFF, 0x000000, 0xFF, 0x80)
        drawtext(-43 + player_control*92, 54, string.format("%df", #recorded_inputs[recording_slot[player_control]]), 0xFFFFFF, 0x000000, 0xFF, 0x80)
        -- Remove non-recordable buttons from the input
        joypad_set(player_control, {L=false, R=false, start=false, select=false})
        if held_input["select"] == 1 then
          -- Press select to finish recording
          recording_slot[player_control] = 0
        elseif recorded_inputs[recording_slot[player_control]][1] ~= nil or input["A"] or input["B"] or input["X"] or input["Y"] or input["up"] or input["down"] or input["left"] or input["right"] then
          -- Wait until the first non-empty input to start recording.
          if on_right[player_control] then
            -- Swap saved left/right values when character is on the right
            table.insert(recorded_inputs[recording_slot[player_control]], {A=input["A"], B=input["B"], X=input["X"], Y=input["Y"], up=input["up"], down=input["down"], left=input["right"], right=input["left"]})
          else
            table.insert(recorded_inputs[recording_slot[player_control]], {A=input["A"], B=input["B"], X=input["X"], Y=input["Y"], up=input["up"], down=input["down"], left=input["left"], right=input["right"]})
          end
        end
      elseif selected_color > 1 then
        if input["L"] then
          -- Hold L to control characters in palette edit mode
        else
          joypad_disable(player_control)
          -- Color edit mode.
          if held_input["select"] >= 60 then
            -- deactivate color edit mode
            held_input["select"] = 2
            selected_color = 1
          end
          -- Left/Right: Change selected color index
          if held_input["right"]  == 1 then
            selected_color = selected_color + 1
            if selected_color > 36 then selected_color = 2 end
          end
          if held_input["left"] == 1 then
            selected_color = selected_color - 1
            if selected_color <= 1 then selected_color = 36 end
          end
          -- Select + Start: Save palette file
          if input["select"] then
            if held_input["start"] == 1 then
              local dirname = colorpath()
              local chara_id = mem_player(player_control, 0)
              local chara_name = chara_names[chara_id]
              local filename = string.format("%02d_##_%s.bmp", chara_id, chara_name)
              local filepath = dirname .. "/" .. filename
              local file = io.open(filepath, "rb")
              local data = ""
              if file ~= nil then
                -- Transfer current palette to base file
                data = file:read("*a")
                file:close()
                print(string.len(data))
                bmp_headsize = bytes_to_dword(string.byte(data, 15), string.byte(data, 16), string.byte(data, 17), string.byte(data, 18))
                local offset = 14 + bmp_headsize
                local pdata = ""
                for i = 1,36 do
                  local color = snes_rgb24(mem_color(player_control, i))
                  pdata = pdata .. string.char(color.B) .. string.char(color.G) .. string.char(color.R) .. "\000"
                end
                data = string.sub(data, 1, offset) .. pdata .. string.sub(data, offset + string.len(pdata) + 1)
              else
                -- No base file. Create image containing only the palette
                data = "BM\246\000\000\000\000\000\000\000\198\000\000\000\040\000"
                data = data .. "\000\000\016\000\000\000\003\000\000\000\001\000\008\000\000\000"
                data = data .. "\000\000\048\000\000\000\000\000\000\000\000\000\000\000\036\000"
                data = data .. "\000\000\000\000\000\000"
                for i = 1,36 do
                  local color = snes_rgb24(mem_color(player_control, i))
                  data = data .. string.char(color.B) .. string.char(color.G) .. string.char(color.R) .. "\000"
                end
                for i = 33,36 do
                  local color = snes_rgb24(mem_color(player_control, i))
                  data = data .. string.char(i - 1)
                end
                for i = 37,48 do
                  data = data .. "\000"
                end
                for i = 17,32 do
                  local color = snes_rgb24(mem_color(player_control, i))
                  data = data .. string.char(i - 1)
                end
                for i = 1,16 do
                  local color = snes_rgb24(mem_color(player_control, i))
                  data = data .. string.char(i - 1)
                end
              end
              -- Save created file
              local ok, err, code = os.rename(dirname,dirname)
              if not ok and code ~= 13 then os.execute("mkdir " .. dirname) end
              -- Scan for next available palette slot
              local i = 2
              while true do
                filename = string.format("%02d_%02d_%s.bmp", chara_id, i, chara_name)
                filepath = dirname .. "/" .. filename
                file = io.open(filepath, "rb")
                if file == nil then break end
                io.close(file)
                i = i + 1
              end
              file = io.open(filepath, "wb")
              file:write(data)
              file:close()
              print("Saved: " .. filename)
              import_palettes()
            end
          else
            -- Start: Restore selected color to default
            if held_input["start"] == 1 then
              local palette_chara = readbyte(0x7E1CFD + player_control*3)
              local palette_no = readbyte(0x7E1CFF + player_control*3)
              local color = palette_data[palette_chara][palette_no][selected_color]
              mem_color(player_control, selected_color, color)
            end
          end
          -- Up/Down: Change palette
          if held_input["up"] == 1 then
            local color = mem_color(player_control, selected_color)
            color = snes_rgb(color)
            for k, selected_field in pairs({"R","G","B"}) do
              local doit = false
              if selected_field == "R" and (input["Y"] or input["X"]) then doit = true end
              if selected_field == "G" and (input["B"] or input["X"]) then doit = true end
              if selected_field == "B" and (input["A"] or input["X"]) then doit = true end
              if doit then
                color[selected_field] = color[selected_field] + 1
                if color[selected_field] >= 0x20 then color[selected_field] = 0 end
                mem_color(player_control, selected_color, rgb_snes(color))
              end
            end
          end
          if held_input["down"] == 1 then
            local color = mem_color(player_control, selected_color)
            color = snes_rgb(color)
            for k, selected_field in pairs({"R","G","B"}) do
              local doit = false
              if selected_field == "R" and (input["Y"] or input["X"]) then doit = true end
              if selected_field == "G" and (input["B"] or input["X"]) then doit = true end
              if selected_field == "B" and (input["A"] or input["X"]) then doit = true end
              if doit then
                color[selected_field] = color[selected_field] - 1
                if color[selected_field] < 0 then color[selected_field] = 0x1F end
                mem_color(player_control, selected_color, rgb_snes(color))
              end
            end
          end
        end
      elseif input["L"] then
        -- L button is used as a modifier to reset player position
        -- L button held. Not in color edit mode.
        local p1x, p2x = nil, nil
        local doreset = false
        -- L+Y / L+X: Fine adjust distance between players upon reset.
        if held_input["Y"] == 1 or held_input["Y"] > 30 then
          if input["left"] then
            left_distance = left_distance - 1
          elseif input["right"] then
            right_distance = right_distance + 1
          else
            center_distance = center_distance - 1
          end
          doreset = true
        end
        if held_input["X"] == 1 or held_input["X"] > 30 then
          if input["left"] then
            left_distance = left_distance + 1
          elseif input["right"] then
            right_distance = right_distance - 1
          else
            center_distance = center_distance + 1
          end
          doreset = true
        end
        -- L+B / L+A: Fine adjust reset position.
        if held_input["B"] == 1 or held_input["B"] > 30 then
          if input["left"] then
            left_offset = left_offset - 1
          elseif  input["right"] then
            right_offset = right_offset + 1
          else
            center_offset = center_offset - 1
          end
          doreset = true
        end
        if held_input["A"] == 1 or held_input["A"] > 30 then
          if input["left"] then
            left_offset = left_offset + 1
          elseif input["right"] then
            right_offset = right_offset - 1
          else
            center_offset = center_offset + 1
          end
          doreset = true
        end
        -- L+Start: Resets the above position changes to default
        if held_input["start"] == 1 then
          if input["left"] then
            left_offset = 0x00
            left_distance = 0x2F
          elseif input["right"] then
            right_offset = 0x00
            right_distance = 0x2F
          else
            center_offset = 0x00
            center_distance = 0x80
          end
          doreset = true
        end
        -- If you press R while holding L, force reset to swap player positions.
        if held_input["R"] == 1 then doreset = true end
        
        -- L+left = Teleport to left corner
        if held_input["left"] == 1 or (input["left"] and doreset) then
          p1x = 0x1800 + left_offset*0x100
          p2x = 0x1800 + (left_offset + left_distance)*0x100
        -- L+right = Teleport to right corner.
        elseif held_input["right"] == 1 or (input["right"] and doreset) then
          p1x = 0x16800 - (right_offset + right_distance)*0x100
          p2x = 0x16800 - right_offset*0x100
        -- L+down = Change character.
        elseif held_input["down"] == 1 then
          local chara_id = player[0x00] + 1
          if chara_id > 8 + game_version then chara_id = 1 end
          local offset = 0x7E0F80 + player_control*0x80
          writebyte(offset, chara_id)
          mem_player_action(player_control, 0x00)
          writebyte(offset + 0x05, 0x0A) -- Load zap sprite to prevent graphic errors
          writebyte(0x7E1CFD + player_control*3, chara_id)
          writebyte(0x7E1CFF + player_control*3, 0)
          load_palette(player_control, chara_id, 0)
        -- L+up = Change palette.
        elseif held_input["up"] == 1 then
          local palette_chara = readbyte(0x7E1CFD + player_control*3)
          local palette_no = readbyte(0x7E1CFF + player_control*3)
          palette_no = palette_no + 1
          if palette_data[palette_chara][palette_no] == nil then
            palette_no = 0
            palette_chara = palette_chara + 1
            if palette_chara > 8 + game_version then palette_chara = 1 end
            writebyte(0x7E1CFD + player_control*3, palette_chara)
          end
          writebyte(0x7E1CFF + player_control*3, palette_no)
          load_palette(player_control, palette_chara, palette_no)
        -- L = Teleport to center
        elseif doreset or held_input["L"] == 1 then
          p1x = 0xC000 + center_offset*0x100 - center_distance*0x80
          p2x = 0xC000 + center_offset*0x100 + center_distance*0x80
        end
        -- Write new positions to memory
        if p1x ~= nil and p2x ~= nil then
          -- Restart recording playback
          if playback_index[1] > 1 and playback_loop[1] then playback_index[1] = 1 end
          if playback_index[2] > 1 and playback_loop[2] then playback_index[2] = 1 end
          -- Move camera to the correct place
          mem_camera_pos(math.max(math.min(math.floor((p1x + p2x) / 0x200) - 0x80, 0x80), 0))
          -- Move players. 0xC000 is ground height.
          mem_player_pos(player_control, p1x, 0xC000)
          mem_player_vel(player_control, 0, 0)
          mem_player_pos(3 - player_control, p2x, 0xC000)
          mem_player_vel(3 - player_control, 0, 0)
          -- Cancel player actions and restore health
          reset_player_state(1)
          reset_player_state(2)
        end
        -- Disable character controls while L is held
        joypad_disable(player_control)
      else
        -- L is not held.
        if held_input["select"] == 1 then
          if playback_slot[player_control] == 0 and recording_slot[player_control] == 0 then
            -- Select button activates input playback mode.
            playback_slot[player_control] = -1
            joypad_disable(player_control)
          elseif playback_index[player_control] > 1 then
            -- If something is already playing, pressing select stops it.
            playback_index[player_control] = 0
            joypad_disable(player_control)
          end
        end
        -- (A+B+X+Y) = Activate special animations
        if input["A"] and input["B"] and input["X"] and input["Y"] then
          if held_input["A"] == 1 or held_input["B"] == 1 or held_input["X"] == 1 or held_input["Y"] == 1 then
            local chara_id = readbyte(0x7E0F80 + player_control*0x80)
            local action = mem_player_action(player_control)
            if action == 0 then
              -- 5+ABXY : Embarassed
              mem_player_action(player_control, 0x2A)
            elseif action <= 2 then
              -- 4/6+ABXY : Fall
              mem_player_action(player_control, 0x27)
            elseif action <= 4 then -- Crouching
              -- 2+ABXY : Chibimoon misfire
              if chara_id == 9 then
                mem_player_action(player_control, 0x63) 
              else
                mem_player_action(player_control, 0x2A)
              end
            elseif action <= 8 or action == 0x26 then
              -- J.ABXY : Fall
              mem_player_action(player_control, 0x27)
            elseif chara_id == 9 and action >= 0x5C and action <= 0x5E then
              -- Chibimoon J.J.ABXY
              mem_player_action(player_control, 0x27) -- Slip
            end
          end
        end
      end
    end
  end
  
  if in_game and game_paused then
    -- Restore HP upon pausing in training mode
    if game_mode >= 4 then
      restore_player_hp(1)
      restore_player_hp(2)
    end
    -- Consolidate button presses from both controllers
    local input = {}
    for k, v in pairs(buttonlist) do
      if held_inputs[1][k] == 1 then
        input[k] = true
      elseif held_inputs[2][k] == 1 then
        input[k] = true
      else
        input[k] = false
      end
    end
    if input["start"] then
      joypad_set(1, {start=true})
      joypad_set(2, {start=true})
    end
    if input["select"] then
      joypad_set(1, {start=true})
      joypad_set(2, {start=true})
      selected_color = 2
    end
    -- Add settings menu to pause screen
    -- Item modification
    if gui_selected == 1 then
      if input["right"] then
        gui_input = gui_input + 1
        if gui_input % 4 == 0 then gui_input = gui_input - 4 end
      end
      if input["left"] then
        if gui_input % 4 == 0 then gui_input = gui_input + 4 end
        gui_input = gui_input - 1
      end
    elseif gui_selected == 2 then
      if input["right"] or input["left"] then
        gui_damage = 1 - gui_damage
      end
    elseif gui_selected == 3 then
      if input["right"] or input["left"] then
        gui_info = 1 - gui_info
      end
    elseif gui_selected == 4 then
      if input["right"] then
        gui_hitbox = gui_hitbox + 1
        if gui_hitbox > 3 then gui_hitbox = 0 end
      end
      if input["left"] then
        gui_hitbox = gui_hitbox - 1
        if gui_hitbox < 0 then gui_hitbox = 3 end
      end
    elseif gui_selected == 5 then
      if input["right"] then
        gui_subframe = gui_subframe + 1
        if gui_subframe > 4 then gui_subframe = -1 end
        if gui_subframe == 3 then gui_subframe = 4 end
      end
      if input["left"] then
        gui_subframe = gui_subframe - 1
        if gui_subframe < -1 then gui_subframe = 4 end
        if gui_subframe == 3 then gui_subframe = 2 end
      end
    elseif gui_selected == 6 then
      if input["right"] then
        gui_dummy = gui_dummy + 1
        if gui_dummy > 4 then gui_dummy = 0 end
      end
      if input["left"] then
        gui_dummy = gui_dummy - 1
        if gui_dummy < 0 then gui_dummy = 4 end
      end
    elseif gui_selected == 7 then
      if input["right"] then
        gui_dummy_guard = gui_dummy_guard + 1
        if gui_dummy_guard > 3 then gui_dummy_guard = 0 end
      end
      if input["left"] then
        gui_dummy_guard = gui_dummy_guard - 1
        if gui_dummy_guard < 0 then gui_dummy_guard = 3 end
      end
    elseif gui_selected == 8 then
      if input["right"] then
        gui_dummy_recover = gui_dummy_recover + 1
        if gui_dummy_recover > 6 then gui_dummy_recover = 0 end
      end
      if input["left"] then
        gui_dummy_recover = gui_dummy_recover - 1
        if gui_dummy_recover < 0 then gui_dummy_recover = 6 end
      end
    elseif gui_selected == 9 then
      if input["right"] then
        gui_dummy_recover_slot = gui_dummy_recover_slot + 1
        if gui_dummy_recover_slot > 4 then gui_dummy_recover_slot = 0 end
      end
      if input["left"] then
        gui_dummy_recover_slot = gui_dummy_recover_slot - 1
        if gui_dummy_recover_slot < 0 then gui_dummy_recover_slot = 4 end
      end
    elseif gui_selected == 10 then
      if input["right"] or input["left"] then
        gui_swap = 1 - gui_swap
      end
    end
    -- Item selection
    if input["down"] then
      gui_selected = gui_selected + 1
      if gui_selected > 10 then gui_selected = 1 end
    end
    if input["up"] then
      gui_selected = gui_selected - 1
      if gui_selected < 1 then gui_selected = 10 end
    end
    -- Display items
    drawmenu(-1, "TRAINING OPTIONS")
    drawmenu(0, "")
    drawmenu(1, "SHOW INPUT", {"OFF", "1P", "2P", "ON"}, gui_input % 4 + 1)
    drawmenu(2, "SHOW DAMAGE", {"OFF", "ON"}, gui_damage + 1)
    drawmenu(3, "SHOW STATUS", {"OFF", "ON"}, gui_info + 1)
    drawmenu(4, "HITBOXES", {"OFF", "1P", "2P", "ON"}, gui_hitbox + 1)
    if gui_hitbox > 0 then
      drawmenu(5, " SUBFRAME", {"HIT", "-1F", "1P MOVE", "2P MOVE", "3P MOVE", "OFF"}, gui_subframe + 2)
    else
      drawmenu(5, " -")
    end
    drawmenu(6, "DUMMY", {"OFF", "AUTO", "STAND", "DUCK", "JUMP"}, gui_dummy + 1)
    if gui_dummy > 0 then
      drawmenu(7, " GUARD", {"OFF", "HIT", "THROW", "ALL"}, gui_dummy_guard + 1)
      drawmenu(8, " RECOVERY", {"OFF", "AUTO", "STAND", "DUCK", "BACK+S", "BACK+D", "BACK++"}, gui_dummy_recover + 1)
      drawmenu(9, "  PLAY SLOT", {"OFF", "Y", "X", "B", "A"}, gui_dummy_recover_slot + 1)
    else
      drawmenu(7, " -")
      drawmenu(8, " -")
      drawmenu(9, " -")
    end
    drawmenu(10, "PAD SWAP(R)", {"TOGGLE", "HOLD"}, gui_swap + 1)
  end
  
  -- Draw color edit text on screen
  if selected_color > 1 then
    local guix = 77
    local s = "PALETTE"
    if selected_color > 16 then s = " OBJECT" end
    if selected_color > 32 then s = "   ICON" end
    drawtext(guix, 205, string.format("%s %02d: ", s, selected_color), 0xFFFFFF, 0x000000, 0xFF, 0x80)
    local color = snes_rgb(mem_color(1, selected_color))
    local bgcolor = 0x000000
    if color.R + color.G*2 < 60 then bgcolor = 0xFFFFFF end
    drawtext(guix+12*4, 205, string.format("%02x%02x%02x", color.R, color.G, color.B), color.R*0x080000 + color.G*0x000800 + color.B*0x000008, bgcolor, 0xFF, 0xFF)

    local color = snes_rgb(mem_color(2, selected_color))
    local bgcolor = 0x000000
    if color.R + color.G*2 < 60 then bgcolor = 0xFFFFFF end
    drawtext(guix+19*4, 205, string.format("%02x%02x%02x", color.R, color.G, color.B), color.R*0x080000 + color.G*0x000800 + color.B*0x000008, bgcolor, 0xFF, 0xFF)
    
    -- Highlight the selected color by flashing it black and white
    if inputs[1]["select"] or inputs[2]["select"] then
      palette_temp[0] = palette_temp[0] + 1
      if palette_temp[0] > 4 then
        palette_temp[0] = 0
      end
      for player_no = 1,2 do
        palette_temp[player_no] = mem_color(player_no, selected_color)
        if palette_temp[0] < 2 then
          mem_color(player_no, selected_color, 0x7FFF)
        else
          mem_color(player_no, selected_color, 0x0000)
        end
      end
    end
  end
  
  -- Dummy actions
  for player_no = 1,2 do
    local player = players[player_no]
    if player ~= nil then
      local chara_id = player[0x00]
      local action_id = player[0x01]
      -- Detect neutral/non-neutral state and track duration
      if neutral_state[chara_id][action_id] ~= nil then
        active_time[player_no] = 0
        neutral_time[player_no] = neutral_time[player_no] + 1
      else
        neutral_time[player_no] = 0
        local n = active_time[player_no]
        if n == 0 then
          attack_frame[player_no] = 0
        end
        active_time[player_no] = n + 1
      end
      
      -- Automatically activate when the controller has not been touched for a while
      local player_control = player_no
      if player_swap then player_control = 3 - player_no end
      if input_idle_time[player_control] >= idle_timeout then
        local backdash = gui_dummy_recover >= 4 and backdash_disable[player_no] == 0
        local joydown = false
        local guard_dir = 0
        if action_id == 0x26 then
          -- 0x26 = Backdash action.
          -- When detected, stop inputting backdash unless we want to spam it.
          if gui_dummy_recover ~= 6 then
            backdash_disable[player_no] = 2
          end
        end
        -- Detect throw state for auto-break
        if player[0x46] >= 0x80 then
          mash_time[player_no] = mash_time[player_no] + 1
        else
          mash_time[player_no] = 0
        end

        if autoguard_time[player_no] > 0 then
          -- Triggers when guard or damage state is detected in the mainloop function
          if gui_dummy_recover_slot > 0 and autoguard_time[player_no] == guard_timeout then
            playback_slot[player_no] = gui_dummy_recover_slot
            playback_index[player_no] = 1
            playback_loop[player_no] = false
            autoguard_time[player_no] = 0
          else
            autoguard_time[player_no] = autoguard_time[player_no] - 1
            if gui_dummy_recover == 0 then
              autoguard_time[player_no] = 0
            else
              if on_right[player_no] then
                guard_dir = 1
              else
                guard_dir = -1
              end
            end
            -- Restore HP on the final guard frame
            if game_mode >= 4 and autoguard_time[player_no] == 0 then
              restore_player_hp(player_no)
            end
          end
        end
        if autoguard_time[player_no] == 0 then
          -- Not guarding or taking damage
          backdash = false
          if gui_dummy == 4 then -- JUMP
            joypad_set(player_no, {up=true})
          elseif gui_dummy == 3 then -- DUCK
            joypad_set(player_no, {down=true})
            joydown = true
          elseif gui_dummy == 1 then
            if players[3 - player_no][0x54] % 8 >= 4 then
              joypad_set(player_no, {down=true})
              joydown = true
            end
          end
          -- Guard if opponent attack is detected
          if gui_dummy_guard % 2 >= 1 then
            if joydown or players[3 - player_no][0x18] % 2 >= 1 or players[5 - player_no] ~= nil then
              if on_right[player_no] then
                guard_dir = 1
              else
                guard_dir = -1
              end
            end
          end
        end
        -- AI state after getting hit
        if guard_dir ~= 0 then
          -- Force backdash command state so we can hold back to backdash.
          if backdash then writebyte(0x7E0FDC + player_no*0x80, 3) end
          -- Set AI input
          if gui_dummy_recover == 3 or gui_dummy_recover == 5 then
            joydown = true
          elseif gui_dummy_recover == 1 then
            if players[3 - player_no][0x54] % 8 >= 4 then
              joydown = true
            end
          end
          joypad_set(player_no, {down=joydown and not backdash, -- Disable ducking when backdashing
                                 right=guard_dir > 0,
                                 left=guard_dir < 0,
                                 A=(gui_dummy_guard % 4 >= 2 and mash_time[player_no] < 14 and mash_time[player_no] % 2 == 1) -- Mash the A button to tech throws
                                 })
        end
      end
      if backdash_disable[player_no] == 2 then
        if action_id ~= 0x26 then
          -- Previous backdash ended.
          backdash_disable[player_no] = 1
        end
      elseif backdash_disable[player_no] == 1 then
        if autoguard_time[player_no] == 0 or player[0x46] % 40 >= 0x20 then
          -- Don't backdash until we get hit again.
          backdash_disable[player_no] = 0
        end
      end
    end
  end
end

--------------------------------------------------------------------------------
-- Hooks to the start of player processing loop. Fills the interface with stuff.
--------------------------------------------------------------------------------
local function mainloop()
  -- Skip everything if not in game
  local in_game = readbyte(0x7E0070) > 0
  if not in_game then return end
  if game_version == 0 then return end 
  
  local game_mode = mem_game_mode()
  camera = mem_camera_pos()
  -- Scan player data. Players 3-4 are projectiles.
  for player_no = 1,4 do
    local player = players[player_no]
    -- Take some data from the previous frame to account for graphic lag.
    -- e.g. Taking HP from current frame causes the lua interface to display damage before the game does.
    local player_lastframe = players_lastframe[player_no]
    if player ~= nil then
      local gui_x = ((player_no - 1) % 2)*195
      if player_no >= 3 then
        gui_x = gui_x - 65*(player_no*2 - 7)
      end
      -- Player variables. Uncomment as needed.
      --local chara_id = player[0x00]
      local action_id = player[0x01]
      --local action_started = player[0x02]
      --local action_id = player[0x04]
      --local action_sprite = player[0x05]
      --local action_tick = player[0x06]
      --local action_frame = player[0x07]
      local flip_x = player[0x09]
      --local action_flags = player[0x18] -- 1=Attack
      local pos_x = bytes_to_dword_signed(player[0x20], player[0x21], player[0x22], player[0x23])
      local pos_y = bytes_to_dword_signed(player[0x24], player[0x25], player[0x26], player[0x27])
      if pos_y >= 0x800000 then pos_y = pos_y - 0x1000000 end
      local vel_x = bytes_to_word_signed(player[0x30], player[0x31])
      local vel_y = bytes_to_word_signed(player[0x32], player[0x33])
      --local gravity = bytes_to_word_signed(player[0x34], player[0x35])
      --local hitbox_id = player[0x40]
      --local hurtbox_id = player[0x41]
      --local collision_id = player[0x42]
      --local attack_type = player[0x44]
      --local attack_damage = player[0x45]
      --local first_hit_defense = player[0x48]
      
      local hurt_state = 0
      local hp = 0
      if player_lastframe ~= nil then
        hurt_state = player_lastframe[0x46]
        hp = player_lastframe[0x49]
        if game_mode >= 4 then
          local max_hp = player_lastframe[0x4A]
          if max_hp < 143 then
            --hack max hp to prevent KO in training mode when damage is enabled
            mem_player(player_no, 0x49, 143)
            mem_player(player_no, 0x4A, 143)
          end
          hp = hp + 96 - max_hp
        end
      end
      -- local hitstop = player[0x4D]
      -- local buttons = player[0x50] -- 1=left, 2=right, 4=down, 8=up, 0x10=LP, 0x20=LK, 0x40=HP, 0x80=HK
      -- local buttons = player[0x52] -- 1=left, 2=right, 4=down, 8=up, 0x10=LP, 0x20=LK, 0x40=HP, 0x80=HK
      -- local normal_action = player[0x54] -- 1=back, 2=forward, 4=duck, 8=jump, 0x10=LP, 0x20=LK, 0x40=HP, 0x80=HK
      -- local special_action = player[0x54]
      -- local backdash_timer = player[0x5B]
      -- local backdash_state = player[0x5C]
      -- local command1_timer = player[0x5D]
      -- local command1_state = player[0x5E]
      -- local command2_timer = player[0x5F]
      -- local command2_state = player[0x60]
      -- local command3_timer = player[0x61]
      -- local command3_state = player[0x62]
      -- local command4_timer = player[0x63] -- Uranus grab right
      -- local command4_state = player[0x64] -- Uranus grab left
      -- local command5_timer = player[0x65] -- Uranus grab down  -- Jupiter grab right
      -- local command5_state = player[0x66] -- Uranus grab up    -- Jupiter grab left
      -- local command6_timer = player[0x67]                      -- Jupiter grab down
      -- local command6_state = player[0x68]                      -- Jupiter grab up
      
      -- local buff_attack    = player[0x70]
      -- local buff_defense   = player[0x71]
      -- local buff_health    = player[0x72]
      -- local buff_special   = player[0x73]
      -- local buff_secret    = player[0x74]
      -- local buff_ochame    = player[0x75]
      
      -- local action_strength = player[0x77] - 7=LP, 8=LK, 9=HP, 10=HK
      
      -- Display technical move data
      -- X/Y coordinates
      if gui_info > 0 then
        if pos_x < 0 then
          drawtext(gui_x + 11, 1, string.format(".%03d", -pos_x % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        else
          drawtext(gui_x + 11, 1, string.format(".%03d", pos_x % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        end
        if pos_y < 0 then
          drawtext(gui_x + 43, 1, string.format(".%03d", -pos_y % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        else
          drawtext(gui_x + 43, 1, string.format(".%03d", pos_y % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        end
        drawtext(gui_x, 1, string.format("%03d    ,%03d    ", pos_x/0x100, pos_y/0x100), 0xFFFFFF, 0x000000, 0xFF, 0x000000)
        if vel_x < 0 then
          drawtext(gui_x + 11, 218, string.format(".%03d", -vel_x % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        else
          drawtext(gui_x + 11, 218, string.format(".%03d", vel_x % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        end
        if vel_y < 0 then
          drawtext(gui_x + 43, 218, string.format(".%03d", -vel_y % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        else
          drawtext(gui_x + 43, 218, string.format(".%03d", vel_y % 0x100), 0xC0C0C0, 0x000000, 0xFF, 0x000000)
        end
        drawtext(gui_x, 218, string.format("%+03d    ,%+03d    ", vel_x/0x100, vel_y/0x100), 0xFFFFFF, 0x000000, 0xFF, 0x000000)
      end
      
      local player_control = player_no
      if player_swap then player_control = 3 - player_no end
        
      -- Hitstun state
      local s = ""
      if hurt_state >= 0x80 then s = "INV." end
      if hurt_state % 0x40 >= 0x20 then
        s = s .. "STUN"
        -- Idle characters should guard after being hit.
        if gui_dummy > 0 and action_id ~= 0x26 and input_idle_time[player_control] >= idle_timeout then
          autoguard_time[player_no] = guard_timeout
        end
      end
      if gui_info > 0 then
        drawtext(gui_x, 7, s, 0xFFFFFF, 0x000000, 0xFF, 0xFF)
      end
            
      -- Stuff that doesn't apply to projectiles
      if player_no <= 2 then
        if hp < 96 then
          combo_damage[player_no] = 96 - hp
          -- Restore HP in training mode if dummy is off.
          if game_mode >= 4 and hurt_state % 0x40 < 0x20 then
            if gui_dummy == 0 or input_idle_time[player_control] < idle_timeout then
              restore_player_hp(player_no)
            end
          end
        end
        
        -- Training mode life bars
        if gui_damage > 0 then
          local color = hp_color
          if hp <= 24 then color = low_hp_color end
          if player_no == 1 then
            drawbox(15, 28, 112, 37, hp_color_background, 0xFF, 0x000000, 0xFF)
            if hp > 0 then
              drawbox(112-math.min(hp, 96), 29, 16+95, 36, color, 0xFF)
            end
            if hp > 96 then
              drawbox(112-math.min(hp-96, 96), 29, 16+95, 36, high_hp_color, 0xFF)
            end
          else
            drawbox(143, 28, 240, 37, hp_color_background, 0xFF, 0x000000, 0xFF)
            if hp > 0 then
              drawbox(144, 29, 143+math.min(hp, 96), 36, color, 0xFF)
            end
            if hp > 96 then
              drawbox(144, 29, 143+math.min(hp-96, 96), 36, high_hp_color, 0xFF)
            end
          end
          -- HP digits
          if hp > 96 then color = high_hp_color end
          drawtext(33 + player_no*55, 22, string.format("%3d HP", hp), color, 0x000000, 0xFF, 0x80)
          -- Damage of last attack or combo
          local color = 0xFFFFFF - 0x000202*combo_damage[player_no]
          drawtext(-186 + player_no*201, 22, string.format("%2d DMG", combo_damage[player_no]), color, 0x000000, 0xFF, 0x80)
          -- Frame advantage
          local advantage = neutral_time[player_no] - neutral_time[3 - player_no]
          if math.abs(advantage) < 100 then
            local color = nil
            if advantage > 0 then
              color = advantage_color
            elseif advantage < 0 then
              color = disadvantage_color
            end
            drawtext(-72 + player_no*127, 22, string.format("%+3dF", advantage), color, 0x000000, 0xFF, 0x80)
          end
        end
        
        -- Player side
        local other_player = players[3-player_no]
        -- Add velocity to compensate for input lag
        local pos_x1 = math.floor((pos_x + vel_x*(3 - player_no)) / 0x100) - camera.x
        local pos_x2 = bytes_to_dword_signed(other_player[0x20], other_player[0x21], other_player[0x22], other_player[0x23])
        local vel_x2 = bytes_to_word_signed(other_player[0x30], other_player[0x31])
        pos_x2 = math.floor((pos_x2 + vel_x2*player_no) / 0x100) - camera.x
        -- Limit calculated position to screen bounds
        if pos_x1 < 0x18 then pos_x1 = 0x18
        elseif pos_x1 >= 0xE8 then pos_x1 = 0xE8 end
        if pos_x2 < 0x18 then pos_x2 = 0x18
        elseif pos_x2 >= 0xE8 then pos_x2 = 0xE8 end
        if pos_x1 == pos_x2 then
          -- If on neither side, use sprite direction.
          on_right[player_no] = flip_x ~= 0
        else
          on_right[player_no] = pos_x1 > pos_x2
        end
      end
    end
  end
  
  -- Process hitbox display
  for box_no = 1,7 do
    for player_no = 1,4 do
      player = players_lastframe[player_no]
      if player ~= nil then
        -- Set horizontal GUI position
        local gui_x = ((player_no - 1) % 2)*195
        if player_no >= 3 then
          gui_x = gui_x - 65*(player_no*2 - 7)
        end
        
        -- Use previous frame data for projectiles to compensate for lag
        local player_box = player_no
        if player_no > 2 then player_box = player_box + 2 end
        
        if boxes[player_box] ~= nil then
          box = boxes[player_box][box_no]
          if box ~= nil then
            box_type = box[6] % 0x10
            
            -- Center point
            if box_type == 1 then
              if selected_color <= 1 then
                if gui_hitbox == 3 or gui_hitbox == 2 - player_no % 2 then
                  local color = box_colors[box_type]
                  drawline(box[1] - 1, box[2], box[3] + 1, box[4], color, box_border)
                  drawline(box[1], box[2] - 1, box[3], box[4] + 1, color, box_border)
                end
              end
            -- Attack box
            elseif box_type == 2 then
              if selected_color <= 1 then
                if gui_hitbox == 3 or gui_hitbox == 2 - player_no % 2 then
                  local color = box_colors[box_type]
                  drawbox(box[1], box[2], box[3], box[4], color, box_alpha, color, box_border)
                end
              end
              -- Process flags in the hitbox data
              if gui_info > 0 then
                -- Display technical attack data.
                local attack_type = player[0x44]
                local attack_damage = player[0x45]
                local box_flags = box[5]
                local s = ""
                if box_flags % 8 >= 4 then s = s .. "J" end
                if box_flags % 2 >= 1 then s = s .. "H" end
                if box_flags % 4 >= 2 then s = s .. "L" end
                drawtext(gui_x + 44, 7, string.format("%4s", s), 0xFFFFFF, 0x000000, 0xFF, 0x00)
                if player_no <= 2 then
                  if attack_frame[player_no] == 0 then
                    attack_frame[player_no] = active_time[player_no]
                  end
                  drawtext(gui_x, 7, "ATTACK:", 0xFFC0C0, 0x000000, 0xFF, 0x00)
                  s = string.format(" %df", attack_frame[player_no])
                else
                  if attack_frame[player_no - 2] == 0 then
                    attack_frame[player_no - 2] = active_time[player_no - 2]
                  end
                  drawtext(gui_x, 7, "PRJCTL:", 0xFFC0C0, 0x000000, 0xFF, 0x00)
                  s = string.format("%df", attack_frame[player_no - 2])
                end
                drawtext(gui_x + 32, 7, s, 0xFFFFFF, 0x000000, 0xFF, 0x00)
                s = ""
                if attack_type >= 0x12 then
                  s =  "SUPER"
                elseif attack_type >= 0xC then
                  s =  "SPECIAL+"
                elseif attack_type >= 0xA then
                  s =  "HEAVY+"
                elseif attack_type >= 0x8 then
                  s =  "SPECIAL"
                elseif attack_type >= 0x4 then
                  s =  "HEAVY"
                else
                  s =  "LIGHT"
                end
                drawtext(gui_x, 13, s, 0xFFFFFF, 0x000000, 0xFF, 0x00)
                drawtext(gui_x + 32, 13, string.format("%3d DMG", attack_damage), 0xFFFFFF, 0x000000, 0xFF, 0x00)
              end
            else
              if selected_color <= 1 then
                if gui_hitbox == 3 or gui_hitbox == 2 - player_no % 2 % 2 then
                    -- Collision / hurtbox.
                  local hurt_state = player[0x46]
                  -- Hide hurtbox when invincible.
                  if box_type == 5 or hurt_state < 0x80 then
                    local color = box_colors[box_type]
                    drawbox(box[1], box[2], box[3], box[4], color, box_alpha, color, box_border)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  
  if gui_dummy > 0 then
    -- Freeze timer at 7 seconds to enable super moves
    mem_timer(7)
  end
  
  -- Distance between players
  if gui_info > 0 then
    local p1 = players_lastframe[1]
    if p1 ~= nil then
      local p2 = players_lastframe[2]
      if p2 ~= nil then
        local distance = bytes_to_word(p2[0x21], p2[0x22]) - bytes_to_word(p1[0x21], p1[0x22])
        drawtext(101, 212, string.format("DISTANCE:%4d", distance), 0xFFFFFF, 0x000000, 0xFF, 0x00)
      end
    end
  end
  
  -- Store projectile hitboxes for an extra frame to compensate for lag.
  boxes[5] = boxes[3]
  boxes[6] = boxes[4]
end

local function update_hitbox()
  for player_no = 1,4 do
    local player = players_lastframe[player_no]
    if player_no >= 3 then
      player = players[player_no]
    end
    if player ~= nil then
      local chara_id = player[0x00]
      -- Process hitboxes
      local offsets = hitbox_offsets[game_version]
      local bank = offsets[1]
      local hitbox_id = bank + readword(bank + offsets[2] + chara_id*2) + player[0x40]*8
      local hurtbox_id = bank + readword(bank + offsets[3] + chara_id*2) + player[0x41]*0x10
      local collision_id = bank + readword(bank + offsets[4] + chara_id*2) + player[0x42]*8
      if player_no <= 2 then
        -- Sort by draw depth
        boxes[player_no] = {create_box(player_no, collision_id, 5),
                            create_box(player_no, hurtbox_id, 4),
                            create_box(player_no, hurtbox_id + 8, 3),
                            create_box(player_no, hitbox_id, 2),
                            create_box(player_no, -1, 1)}
      else
        boxes[player_no] = {nil,nil,nil,
                            create_box(player_no, hitbox_id, 2),
                            create_box(player_no, -1, 1)}
      end
    else
      -- Player doesn't exist so nuke the data.
      boxes[player_no] = nil
    end
  end
end

-- Triggers after projectiles have moved
local function data()
  if game_version == 0 then return end
  for player_no = 1,4 do
    players_lastframe[player_no] = players[player_no]
    local player = readbyterange(0x7E0F80 + player_no*0x80, 0x80)
    local chara_id = player[0x00]
    if chara_id == 0 or chara_id >= 0x80 then player = nil end
    players[player_no] = player
  end
  update_hitbox()
  mainloop()
end

-- Make sure things won't break after closing the script.
local function cleanup()
  local game_mode = mem_game_mode()
  if game_mode == 5 then
    mem_game_mode(4)
  end
end
         
if snes9x then
  -- Note: Maininput hook done dumb to allow switching game on the fly without reloading the script
  memory.registerexec(input_offsets[1], maininput) --S
  memory.registerexec(input_offsets[2], maininput) --SuperS
  memory.registerexec(0xC10000, data)
  emu.registerexit(cleanup)
else
  events = {}
  table.insert(events, event.onmemoryexecute(maininput, input_offsets[1])) --S
  table.insert(events, event.onmemoryexecute(maininput, input_offsets[2])) --SuperS
  table.insert(events, event.onmemoryexecute(data, 0xC10000))
  table.insert(events, event.onexit(cleanup))
  while true do
    emu.frameadvance()
  end
end