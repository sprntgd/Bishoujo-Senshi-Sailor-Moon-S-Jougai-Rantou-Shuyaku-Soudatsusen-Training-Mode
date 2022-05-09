Contact me with bug reports and questions.
  Twitter: @SprntGd
  e-Mail:  sprintgod@hotmail.com

================================================================================
 HOW TO USE
--------------------------------------------------------------------------------
Drag a Sailor Moon S ROM onto sms_patcher.exe to create a patched ROM.
Super S is not currently supported.

Current features:

Extended palette (32 colors per character)
  The colors are imported from BMP files in the sms_colors folder.
  See below for details on how to create colors.

Random stage select
  Stage selection defaults to a random stage.
  Holding a direction while selecting the 2nd character defaults to home stage.
  Note: This is included as part of the extended palette patch.

MSU-1 patch (original code by Enigami)

Options to modify the hidden stage.
  Enable by default.
  Play character themes instead of the stage theme.
  Alternatively define a specific track to play instead of the default.

================================================================================
 CREATING PALETTES
--------------------------------------------------------------------------------
Additional colors are stored in the sms_colors folder.
Files with "##" as the PaletteID are base files used for saving bitmaps.
Do not edit them.

To manually create a new color, copy a base file and change the PaletteID.

Example: 01_02_Moon.bmp
"01"   : CharaID
"02"   : PaletteID (00, 01 = Default. Max=31)
"Moon" : Color description (Can be anything)

The bitmaps can be edited in any software. Edit only the palette, not the image.
The patcher will detect all correctly named files and insert them into the game.

To select a color in-game, press the following on the character select screen.
Color 0    : A (default)
Color 1    : B (default)
Color 2    : Y
Color 3    : X
Color 4-7  : L+Above
Color 8-15 : R+Above
Color 16-31: Start+Above

SailorMoonS.lua has a color edit mode that can export compatible files.
See the Color Edit section of the lua readme for details.

================================================================================
 SOURCE CODE
--------------------------------------------------------------------------------
The source code (Python / SNES Assembly) can be found in the "src" folder.

If you have Python 3 installed you can delete sms_patcher.exe and move
sms_patcher.py out to replace it.

Building a standalone executable file requires PyInstaller.


The assembly code can be compiled with wla-dx (wla-65816.exe)

The output will not work on its own. It is intended for use with a diff tool,
which can be used to extract the modified binary data for use with the patcher.
