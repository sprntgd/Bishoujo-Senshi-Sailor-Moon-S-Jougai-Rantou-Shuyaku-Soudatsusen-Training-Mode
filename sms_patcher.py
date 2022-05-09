from traceback import format_exc
from os import path, listdir
from sys import argv
from struct import pack, unpack
from hashlib import sha256

# Patch list. Each contains a list of sub-patches with the following format:
# Row 1: Name of patch
# Row 2: Binary data to replace.
#        - Integer refers to an offset in a newly added block.
#        - Binary data runs a search and replace for the given string.
#        - List containing integer and binary data patches at the given offset, using the data for verification.
# Row 3: New data to replace.
#        - "___" is a replacement string. The next character determins the purpose.
#        - "___B" : Replace with the offset of the newly added block. Starts at 0xE8 in an original SMS ROM.
#        - "___0" : Replace the byte with a passed value. Up to 9 supported.
#        - "____" : Single underscore (\x5F). Required for patches containing b'\x5F\x5F\x5F'

# MSU-1 Patch by Enigami
PATCH_MSU1 = (
    ("MSU-1(by Enigami)",
     b'\xE2\x20\xA5\x6F\x8D\x0C\x42\xE6\x6C\xC2\x30',
     b'\xE2\x20\xA5\x6F\x8D\x0C\x42\x5C\xA3\x80___B'
    ),
    ("MSU-1(by Enigami)",
     b'\x8B\x4B\xAB\xC2\x30\x29\xFF\x00\x0A\x85\x00\x0A\x18\x65\x00\xA8\x5A\xB9\xE7\xEC\x85\x00\xB9\xE9\xEC\x85\x02\x20\xD4\xEB\x20\xFB\xEB\x20\xAE\xEB\xC2\x30\x7A\xB9\xEA\xEC\xC9\xFF\xFF\xF0\x10\x85\x00\xB9\xEC\xEC\x85\x02\x20\xD4\xEB\x20\xFB\xEB\x20\xAE\xEB\xAB\x6B\x8B\x4B\xAB\xC2\x10\xE2\x20',
     b'\x5C\x00\x80\x28\xEA\xEA\x4B\xAB\x0A\x85\x00\x0A\x18\x65\x00\xA8\x5A\xB9\xE7\xEC\x85\x00\xB9\xE9\xEC\x85\x02\x20\xD4\xEB\x20\xFB\xEB\x20\xAE\xEB\xC2\x30\x7A\xB9\xEA\xEC\xC9\xFF\xFF\xF0\x10\x85\x00\xB9\xEC\xEC\x85\x02\x20\xD4\xEB\x20\xFB\xEB\x20\xAE\xEB\xAB\x6B\x5C\x69\x80___B\x4B\xAB\xEA'
    ),
    ("MSU-1(by Enigami)",
     0x8000,
     b'\xE2\x30\x48\xAD\x02\x20\xC9\x53\xD0\x52\x8A\xC9\x0A\xD0\x06\x68\x48\xC9\x02\xF0\x47\x68\x48\xC9\x1F\x10\x41\xDA\xAA\xBF\xC9\x80___B\xFA\x8D\x04\x20\x9C\x05\x20\xAD\x00\x20\x29\x40\xD0\xF9\xAD\x00\x20\x29\x08\xD0\x20\xA9\x03\x8D\x07\x20\x8B\xA9\x7E\x48\xAB\xA9\xFF\x8D\x40\xF4\xAB\x8D\x06\x20\x68\x8B\xE2\x80\xC2\x30\x29\xFF\x00\x5C\x51\xEB\x80\x9C\x07\x20\x9C\x06\x20\x68\x8B\xE2\x80\xC2\x30\x29\xFF\x00\x5C\x51\xEB\x80\x8B\xE2\x20\x48\xAD\x02\x20\xC9\x53\xD0\x28\xAD\x00\x20\x89\x10\xF0\x21\x68\xC9\xF2\xD0\x0D\x8B\xA9\x7E\x48\xAB\xA9\xFC\x8D\x40\xF4\xAB\x80\x0C\xC9\x01\xD0\x08\xA9\x01\x8D\x04\x20\x9C\x05\x20\xA9\x01\x48\x68\xC2\x10\x5C\x93\xEB\xC0\xA9\x7E\x48\xAB\xAD\x40\xF4\xC9\xFF\xF0\x13\xC9\x00\xF0\x0F\x38\xE9\x04\x8D\x40\xF4\x48\xA9\x80\x48\xAB\x68\x8D\x06\x20\xE6\x6C\xC2\x30\x5C\x07\x9A\x80\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x12'
    ),
)

# Extended palette patch (Supports 32 per character)
# See sms_patcher_asm.txt for commented asm
PATCH_PAL = (
    ("Palette map (1P)",
     b'\x0A\x18\x65\x00\x18\x65\x20\x85\x23\xA5\x22\x85\x25\xA7\x23\x85\x00\xE6\x23\xE6\x23\xA7\x23\x85\x02\xE6\x20\xE6\x20\xE6\x20\xE6\x20\xE6\x20\xE6\x20\xA9\x00\x06\x85\x04\xA9\x20\x00\x85\x06\x22\xDD\x8A\x80\xC2\x20\xA7\x20\x85\x00\xE6\x20\xE6\x20\xA7\x20\x85\x02\xE6\x20\xA9\x30\x05\x85\x04\xA9\x08\x00\x85\x06\x22\xDD\x8A\x80\xC2\x20\xA7\x20\x85\x00\xE6\x20\xE6\x20\xA7\x20\x85\x02\xE6\x20',
     b'\xA9\x0C\x00\x18\x65\x20\x85\x20\x8A\xEB\x0A\x0A\x0A\x85\x02\xA5\x00\xEB\x4A\x18\x65\x02\x18\x69\x08\x00\x85\x00\xA9___B\x00\x85\x02\xA9\x30\x05\x85\x04\xA9\x08\x00\x85\x06\x22\xDD\x8A\x80\x86\x00\xA9\x00\x06\x85\x04\xA9\x20\x00\x85\x06\x22\xDD\x8A\x80\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\x86\x00'
    ),
    ("Palette map (2P)",
     b'\x0A\x18\x65\x00\x18\x65\x20\x85\x23\xA5\x22\x85\x25\xA7\x23\x85\x00\xE6\x23\xE6\x23\xA7\x23\x85\x02\xE6\x20\xE6\x20\xE6\x20\xE6\x20\xE6\x20\xE6\x20\xA9\x20\x06\x85\x04\xA9\x20\x00\x85\x06\x22\xDD\x8A\x80\xC2\x20\xA7\x20\x85\x00\xE6\x20\xE6\x20\xA7\x20\x85\x02\xE6\x20\xA9\x38\x05\x85\x04\xA9\x08\x00\x85\x06\x22\xDD\x8A\x80\xC2\x20\xA7\x20\x85\x00\xE6\x20\xE6\x20\xA7\x20\x85\x02\xE6\x20',
     b'\xA9\x0C\x00\x18\x65\x20\x85\x20\x8A\xEB\x0A\x0A\x0A\x85\x02\xA5\x00\xEB\x4A\x18\x65\x02\x18\x69\x08\x00\x85\x00\xA9___B\x00\x85\x02\xA9\x38\x05\x85\x04\xA9\x08\x00\x85\x06\x22\xDD\x8A\x80\x86\x00\xA9\x20\x06\x85\x04\xA9\x20\x00\x85\x06\x22\xDD\x8A\x80\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\xEA\x86\x00'
    ),
    ("Palette selection + Default stage selection",
     b'\xC2\x30\xA7\xFE\x29\x80\x50\xF0\x29\xE2\x20\xA9\x03\x85\x78\x9C\x02\x1D\xC2\x30\xA9\x01\x00\x99\x02\x00\x20\x93\xA6\xEE\x10\x1B\x86\x00\xB9\x06\x00\xAA\xA9\x01\x00\x9D\x00\x00\xA6\x00\xC2\x30\x80\x2E\xC2\x20\xA7\xFE\x29\x40\x80\xF0\x25\xE2\x20\xA9\x03\x85\x78\x9C\x02\x1D\xC2\x30\xA9\x01\x00\x99\x02\x00\x20\xC4\xA6\xEE\x10\x1B\x86\x00\xB9\x06\x00\xAA\xA9\x01\x00\x9D\x00\x00\xA6\x00\xC2\x20\x60\xC2\x30\xAD\x10\x1B\xF0\x17\xAD\x14\x1B\xC9\x01\x00\xD0\x0F\xAD\x16\x1B\xD9\x00\x00\xD0\x07\xA9\x01\x00\x99\x04\x00\x60\xA9\x00\x00\x99\x04\x00\xA9\x01\x00\x8D\x14\x1B\xB9\x00\x00\x8D\x16\x1B\x60\xC2\x30\xAD\x10\x1B\xF0\x17\xAD\x14\x1B\xC9\x02\x00\xD0\x0F\xAD\x16\x1B\xD9\x00\x00\xD0\x07\xA9\x00\x00\x99\x04\x00\x60\xA9\x01\x00\x99\x04\x00\xA9\x02\x00\x8D\x14\x1B\xB9\x00\x00\x8D\x16\x1B\x60',
     b'\x22\x0A\x00___B\x60'
    ),
    ("Palette selection + Default stage selection",
     0,
     b'\x00\x02\x08\x0C\x0A\x0E\x10\x06\x04\x00\xC2\x30\xA7\xFE\x29\xC0\xC0\xD0\x03\xC2\x20\x6B\xE2\x20\xA9\x03\x85\x78\x9C\x02\x1D\xC2\x30\xA9\x01\x00\x99\x02\x00\x86\x04\x64\x00\xA7\xFE\x29\x40\xC0\xF0\x02\xE6\x00\x29\x40\x40\xF0\x02\xE6\x00\x29\x40\x00\xF0\x02\xE6\x00\xA5\xFE\x38\xE9\x04\x00\x85\xFE\xA7\xFE\x29\x20\x00\xF0\x05\xA9\x04\x00\x04\x00\xA7\xFE\x29\x10\x00\xF0\x05\xA9\x08\x00\x04\x00\xA7\xFE\x29\x00\x10\xF0\x05\xA9\x10\x00\x04\x00\xAD\x10\x1B\xF0\x16\xAD\x16\x1B\xD9\x00\x00\xD0\x0E\xAD\x14\x1B\xC5\x00\xD0\x07\xA5\x00\x49\x01\x00\x85\x00\xB9\x00\x00\xEB\x0A\x0A\x0A\x0A\x85\x02\xA5\x00\xEB\x4A\x18\x65\x02\xAA\xBF\x00\x00___B\xD0\x0C\xA9\x20\x00\x4A\xF0\x06\x14\x00\xF0\xF9\x80\xC1\xA5\x00\x99\x04\x00\x8D\x14\x1B\xB9\x00\x00\x8D\x16\x1B\xAA\xBF\x00\x00___B\xE2\x20\x85\x8E\xC2\x20\xA7\xFE\x29\x00\x0F\xD0\x13\xA5\xB1\x29\xFF\x00\xC9\x09\x00\x90\x06\x38\xE9\x09\x00\x80\xF5\x0A\x85\x8E\xEE\x10\x1B\xB9\x06\x00\xAA\xA9\x01\x00\x9D\x00\x00\xA6\x00\x6B'
    ),
)

# Enable Nakayoshi stage
PATCH_NAKAYOSHI = (
    ("Enable hidden stage",
     (0x3BADE, b'\x8D'),
     b'\x9C'
    ),
)

# Nakayoshi music (static)
# Parameter 0 is the track index
PATCH_NAKAYOSHI_BGM = (
    ("Hidden stage BGM",
     (0x200219, b'\x06'),
     b'___0'
    ),
)

# Character themes instead of stage themes
# Parameter 0 is the code start offset
# Pass 0x0A for Nakayoshi stage only
# Pass 0x15 for all stages
PATCH_THEMES = (
    ("Character themes",
     (0x85FF, b'\x4B\xEB\x80'),
     b'___0\x00___B'
    ),
    ("Character themes",
     0,
     b'\x00\x0A\x0B\x0C\x0D\x0E\x10\x11\x0F\x12\xC2\x30\xC9\x06\x00\xF0\x04\x5C\x4B\xEB\x80\xA5\xB1\x29\x01\x00\x85\x00\x0A\x18\x65\x00\xAA\xE2\x20\xBD\x00\x1D\xAA\xBF\x00\x00___B\xC2\x20\x85\xA2\x5C\x4B\xEB\x80'
    ),   
)

NAMES = ["","Moon","Mercury","Mars","Jupiter","Venus","Uranus","Neptune","Pluto","Chibimoon","Saturn"]

# Basic functions
def read_int(data, offset, length=2):
    value = 0
    for i in range(0, length):
        value += 0x100**i * data[offset + i]
    return value

def input_yesno(prompt):
    while 1:
        yn = input(prompt + " (type y/n and press enter): ")[:1].lower()
        if yn == "y":
            return True
        elif yn == "n":
            return False

def input_byte(prompt, default=None):
    while 1:
        value = input(prompt + " (enter for default, or 0-255): ")
        try:
            if value:
                value = int(value)
            else:
                value = default
        except:
            continue
        if value is None or 0 <= value <= 255:
            return value

# Search for an already applied patch
def find_patched(data, new_data):
    # Split patch string around wildcards
    new_data = new_data.split(b'___')
    i = -1
    i = data.find(new_data[0])
    while i >= 0:
        # Found the start. Check the rest.
        j = i + len(new_data[0]) + 1
        for s in new_data[1:]:
            if data[j:j+len(s)-1] != s[1:]:
                break
            j += len(s)
        else:
            # Found
            return i
        i = data.find(new_data[0], i+1)
    # Not found
    return -1

def apply_patch(data, patches, parameters=None):
    # Write to temp object in case any of the sub-patches fail
    temp_data = data[:]
    next_block = (len(data) >> 16) + 0xC0
    lastname = None
    for patch in patches:
        name = patch[0]
        old_data = patch[1]
        new_data = patch[2]
        if name != lastname:
            print("Applying patch: %s%s" % (name, " " + str(parameters) if parameters else ""))
        lastname = name

        if type(old_data) is int:
            # Integer adds data to the end of the ROM
            i = len(temp_data) + old_data
            while len(temp_data) < i + len(new_data):
                temp_data += b'\x00'*0x10000
        elif type(old_data) is bytes:
            # Search for bytes in the existing ROM
            i = data.find(old_data)
            if i < 0:
                # Not found. See if there is a match for the patched data.
                i = find_patched(temp_data, new_data)
                if i < 0:
                    print("  Error: Original data not found. Patch failed")
                    return False
                print("  Warning: Patch already applied")
                return
        elif type(old_data) in (tuple, list):
            i = old_data[0]
            s = old_data[1] if len(old_data) > 1 else b''
            if s:
                if temp_data[i:i+len(s)] != s:
                    if find_patched(temp_data[i:i+len(s)], new_data) < 0:
                        print("  Warning: Non-original data found at patch offset.")
                    else:
                        print("  Warning: Patch already applied")

        # Block offset replacement
        j = 0
        while j < len(new_data):
            if new_data[j:j+3] == b'___':
                c = new_data[j+3:j+4]
                if c == b'_':
                    # Underscore only
                    new_data = new_data[:j] + b'_' + new_data[j+4:]
                elif c == b'B':
                    # Offset of added block
                    new_data = new_data[:j] + bytes((next_block,)) + new_data[j+4:]
                elif c in b'0123456789':
                    # Parameter replacement (byte input only)
                    new_data = new_data[:j] + bytes((parameters[int(c)],)) + new_data[j+4:]
            j += 1
        temp_data[i:i+len(new_data)] = new_data

    # Finalise patch
    data[:] = temp_data[:]

# Loads a palette from a BMP file and converts to BGR555
def bmp_palette(filename):
    with open(filename, 'rb') as infile:
        bmp = infile.read()
    # Check header
    if bmp[:2] != b"BM":
        print("Invalid BMP file %s" % color_fn)
        return None
    # Load relevant parts of the header
    bmp_headsize, = unpack('<I', bmp[0x0E:0x12])
    bmp_bpp, = unpack('<H', bmp[0x1C:0x1E])
    bmp_palettecount, = unpack('<I', bmp[0x2E:0x32])
    # Make sure palette exists and has enough colors
    if bmp_bpp != 8 or bmp_palettecount < 36:
        print("Invalid palette in %s" % color_fn)
        return None
    # Read first 36 colors of the palette
    o = 0x0E + bmp_headsize
    colors = list(unpack('<36I', bmp[o:o+36*4]))
    # Convert to SNES color space
    for i in range(0, 36):
        color = colors[i]
        B = int((color & 0xFF) * 31/255 + 0.5)
        G = int(((color >> 8) & 0xFF) * 31/255 + 0.5)
        R = int(((color >> 16) & 0xFF) * 31/255 + 0.5)
        colors[i] = R + 0x20*G + 0x400*B
    return colors

# Main code
def process(filename):
    if not path.isfile(filename):
        print("File not found: %s" % filename)
        return False

    with open(filename, 'rb') as infile:
        data = bytearray(infile.read())

    # Strip header
    head = b'\x00\x00\x68\x00\xC0\x03\xA5\x06\xD6\x09\x28\x0D\xF1\x0F\x30\x13'
    i = data.find(head)
    if i >= 0:
        data = data[i:]
        if i > 0: print("Removed header")
        m = sha256()
        m.update(data[:0x280000])
        h = m.digest()
        if h == b'\xe2\x2f\x9a\x7e\x3e\xc6\xe9\xe5\x6b\x14\x31\xda\x9f\x97\x0f\xec\x12\xcc\xa0\x40\x6c\x60\xb2\xbb\xf3\x27\x91\x94\x6e\xc0\xd5\x4b':
            print("Verified original Sailor Moon S ROM.")
            # Remove any footers
            data = data[:0x280000]
        else:
            print("Warning: ROM has already been modified.")
    else:
        print("Warning: ROM is not Sailor Moon S.")
    print('')

    # Pad file to the end of the last block, making the size divisible by 0x10000
    data += b'\x00'*((len(data) + 0xFFFF) // 0x10000 * 0x10000 - len(data))
    # Crop empty blocks
    while data[-0x10000:] == b'\x00'*0x10000:
        data = data[:-0x10000]

    applied_msu1 = False

    # User input
    option_test = False
    #option_test = input_yesno("Test all color slots?")
    option_pal = input_yesno("Extend palette?")
    option_msu1 = input_yesno("MSU-1 support?")

    option_nakayoshi = input_yesno("Enable hidden stage?")
    option_nakayoshi_themes = input_yesno("Play character themes on hidden stage? No to specify a single track.")
    if option_nakayoshi_themes:
        option_nakayoshi_bgm = 6 # Force BGM to default value for detection purposes
        option_themes = input_yesno("Play character themes on all stages?")
    else:
        print("  02: Moonlight Densetsu")
        print("  03: Player Select")
        print("  05: Eyecatch (non-looping)")
        print("  06: Demo Visual A (Victory)")
        print("  07: ACS")
        print("  08: Demo Visual C (Tournament)")
        print("  09: Demo Visual B (Outer senshi)")
        print("  10: Moon Theme")
        print("  11: Mercury Theme")
        print("  12: Mars Theme")
        print("  13: Jupiter Theme")
        print("  14: Venus Theme")
        print("  15: Pluto Theme")
        print("  16: Uranus Theme")
        print("  17: Neptune Theme")
        print("  18: Chibimoon Theme")
        print("  19: Ending")
        print("  20: Opening Demo")
        print("  21: Tuxedo Mask (non-looping)")
        print("  Additional MSU-1 PCMs can be created for track 22 and above.")
        print("  Missing MSU-1 tracks will default to SPC700 Player Select.")
        while 1:
            option_nakayoshi_bgm = input_byte("Select music track for hidden stage")
            if option_nakayoshi_bgm in (0, 1, 4):
                if not input_yesno("This will crash the game. Are you sure?"):
                    continue
            break
        option_themes = False

    while 1:
        option_title = input("Patch description (11 chars max): ")
        chars = " !\"#$%&'()+,-.0123456789;=@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{}~"
        try:
            for c in option_title:
                if not c in chars:
                    raise ValueError("Invalid character")
            option_title = option_title.encode('ascii')
        except:
            print("  Error: Invalid characters")
            continue
        if len(option_title) > 11:
            print("  Error: Too long")
            continue
        option_title = option_title.ljust(11)
        break

    print("")
    # Apply patches
    if option_msu1:
        apply_patch(data, PATCH_MSU1)
        applied_msu1 = True
    else:
        # Check if the MSU-1 patch is applied
        for patch in PATCH_MSU1:
            if find_patched(data, patch[2]) < 0:
                applied_msu1 = True
                break

    if option_nakayoshi:
        apply_patch(data, PATCH_NAKAYOSHI)
    if option_nakayoshi_bgm is not None:
        apply_patch(data, PATCH_NAKAYOSHI_BGM, [option_nakayoshi_bgm])
    if option_themes:
        apply_patch(data, PATCH_THEMES, [0x15])
    elif option_nakayoshi_themes:
        apply_patch(data, PATCH_THEMES, [0x0A])

    if option_pal:
        apply_patch(data, PATCH_PAL)
        palette_offset = len(data) - 0x10000
        # Copy original palettes to new location
        pointer_offset = 0x200238
        for chara_id in range(1, 10):
            chara_name = NAMES[chara_id]
            chara_offset = read_int(data, pointer_offset + 2*chara_id) + 0x200000
            # Color 1
            src = read_int(data, chara_offset + 0x1, 3) - 0xC00000
            dest = palette_offset + 0x1000*chara_id + 0x10
            data[dest:dest+0x20] = data[src:src+0x20] # Color 1
            palette_1 = unpack("<16H", data[src:src+0x20])
            # Color 2
            src = read_int(data, chara_offset + 0x4, 3) - 0xC00000
            dest += 0x80
            data[dest:dest+0x20] = data[src:src+0x20] # Color 2
            palette_2 = unpack("<16H", data[src:src+0x20])
            # Objects
            src = read_int(data, chara_offset + 0xA, 3) - 0xC00000
            dest = palette_offset + 0x1000*chara_id + 0x30
            data[dest:dest+0x20] = data[src:src+0x20] # Color 1 objects
            dest += 0x80
            data[dest:dest+0x20] = data[src:src+0x20] # Color 2 objects
            palette_1 += unpack("<16H", data[src:src+0x20])
            palette_2 += unpack("<16H", data[src:src+0x20])
            # Icon
            src = read_int(data, chara_offset + 0x7, 3) - 0xC00000
            dest = palette_offset + 0x1000*chara_id + 0x8
            data[dest:dest+0x8] = data[src:src+0x8] # Color 1 icon
            dest += 0x80
            data[dest:dest+0x8] = data[src:src+0x8] # Color 2 icon
            palette_1 += unpack("<4H", data[src:src+0x8])
            palette_2 += unpack("<4H", data[src:src+0x8])
            
            # Mark color 1 and 2 as enabled
            dest = palette_offset + 0x1000*chara_id
            data[dest] = 1
            data[dest+0x80] = 1
            # Add markers to unused palettes
            r = 0
            g = 0
            b = 0
            for i in range(2, 32):
                dest = palette_offset + 0x1000*chara_id + 0x80*i
                if option_test:
                    if r > 31: r = 31
                    if g > 31: g = 31
                    if b > 31: b = 31
                    rgb = pack('<H', (b << 10) + (g << 5) + r)
                    if chara_id == 1:
                        s = ""
                        if i & 0x04: s += "L+"
                        if i & 0x08: s += "R+"
                        if i & 0x10: s += "Start+"
                        if i % 4 == 0: s += "A"
                        if i % 4 == 1: s += "B"
                        if i % 4 == 2: s += "Y"
                        if i % 4 == 3: s += "X"
                        print("Test color %02d: #%02X%02X%02X %s" % (i, r, g, b, s))
                    data[dest] = 1
                    data[dest+0x8:dest+0x10] = rgb*0x4   # Icon
                    data[dest+0x10:dest+0x30] = rgb*0x10 # Character
                    data[dest+0x30:dest+0x50] = rgb*0x10 # Projectile
                    r += 16
                    if r > 32:
                        r = 0
                        g += 16
                        if g > 32:
                            g = 0
                            b += 16
                            if b > 32:
                                b = 0
                else:
                    data[dest+0x8:dest+0x10] = b'\x01'*0x8   # Icon
                    data[dest+0x10:dest+0x30] = b'\x02'*0x20 # Character
                    data[dest+0x30:dest+0x50] = b'\x03'*0x20 # Projectile

        # Import from bmp files
        color_dir = path.join(path.dirname(argv[0]), "sms_colors")
        if path.exists(color_dir):
            for color_fn in sorted(listdir(color_dir)):
                name, ext = path.splitext(color_fn)
                name = name.split("_")
                try:
                    # Parse filename
                    chara_id = int(name[0])
                    palette_id = int(name[1])
                except:
                    continue
                try:
                    if ext == ".txt":
                        # Read colors from text file
                        # Format is 36 comma separated integers in BGR555 format
                        with open(path.join(color_dir, color_fn), 'rb') as infile:
                            colors = list(infile.read().decode('utf-8').split(',')[:36])
                        for i in range(0, len(colors)):
                            colors[i] = int(colors[i], 16)
                        # Pad to length 36
                        colors += [-1]*(36 - len(colors))
                        # Replace default colors.
                        # -1 = Default 1, -2 = Default 2
                        for i in range(0, 36):
                            if colors[i] == -1:
                                colors[i] = palette_1[i]
                            elif colors[i] == -2:
                                colors[i] = palette_2[i]
                    elif ext == ".bmp":
                        # Read colors from a BMP palette.
                        # Must be an 8-bit palette based image with at least 36 colors
                        colors = bmp_palette(path.join(color_dir, color_fn))
                        if colors is None:
                            continue
                    else:
                        continue
                    # Reorder and store in ROM. First 1 is flag that tells the game to use the palette.
                    colors = [1,0,0,0] + colors[32:36] + colors[0:32]
                    dest = palette_offset + 0x1000*chara_id + 0x80*palette_id
                    data[dest:dest+0x50] = pack('<40H', *colors)
                    print("Imported %s" % color_fn)
                        
                except:
                    print("  Error importing %s" % color_fn)
                    raise

    # Change title to describe patches
    data[0xFFC0:0xFFD5] = b"\xBE\xB0\xD7\xB0\xD1\xB0\xDDS " + option_title + b" "

    # Pad ROM to the next 4 megabit size
    data += b'\x00'*((len(data) + 0x7FFFF) // 0x80000 * 0x80000 - len(data))
    
    # Fix checksum
    print("Calculating checksum", end="")
    size = len(data)
    chk_size = 0x80000
    while chk_size <= size:
        chk_size <<= 1
    if chk_size == size:
        chk = sum(data)
    else:
        chk_data = data[chk_size // 2:]
        while len(chk_data) < chk_size // 2:
            chk_data += chk_data[len(chk_data) - chk_size:]
        chk = sum(data[:chk_size // 2]) + sum(chk_data)
    data[0xFFDE] = chk & 0xFF
    data[0xFFDF] = chk>>8 & 0xFF
    data[0xFFDC] = data[0xFFDE] ^ 0xFF
    data[0xFFDD] = data[0xFFDF] ^ 0xFF
    print(': ' + hex(read_int(data, 0xFFDE)))

    # Save file
    new_filename, ext = path.splitext(filename)
    new_filename += "(" + option_title.strip().decode('ascii') + ")" + ext
    print("Saving file: %s" % new_filename)
    
    with open(new_filename, 'wb') as outfile:
        outfile.write(bytes(data))

    return True

if __name__ == '__main__':
    try:
        args = argv[1:]
        if len(args) > 0:
            process(args[0])
        else:
            print("No file specified.")
    except:
        input(format_exc())
    print("")
    input("Press enter to close this window.")
