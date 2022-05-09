.MEMORYMAP
  SLOTSIZE $10000
  DEFAULTSLOT 0
  SLOT 0 $0000
.ENDME

.ROMBANKMAP
  BANKSTOTAL 1
  BANKSIZE $10000
  BANKS 1
.ENDRO

.BANK 0
.ORGA $879B
; 00879B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unmodified
SEP #$30      ; 1 byte accumulator, 1 byte index
LDA #$E0      
STA $22       ; ReadBank
LDA $1D00     ; CharaID
STA $1000     ; $1000 = CharaID
ASL A         
TAX           ; X = CharaID * 2  
LDA $1D01     
STA $1076     ; ???
LDA #$01      
STA $1003     ; ??? = 1
STZ $1016     ; ???
STZ $1009     ; FlipX
LDA $8F       
STA $1008     ; ??? = 0x8F
LDA #$22      
STA $1001     ; ActionID = 0x22 
STA $1004     
STZ $1002     ; ActionStarted
STZ $1046     ; HurtState
STZ $1007     ; ActionFrame
STZ $1006     ; ActionTick
LDA $1D08     
STA $1070     ; BuffAttack
LDA $1D09     
STA $1071     ; BuffDefense
LDA $1D0A     
STA $1072     ; BuffHP
LDA $1D0B     
STA $1073     ; BuffSpecial
LDA $1D0C     
STA $1074     ; BuffSecret
LDA $1D0D     
STA $1075     ; BuffOchame
LDA $1072     
ASL A         
ASL A         
ASL A         
CLC           
ADC #$60      
STA $1049     ; HP += BuffHP * 8
STA $104A     ; MaxHP
REP #$20      ; 2 byte accumulator
LDA #$0080    
STA $1021     ; PosX = 0x20 
LDA #$00C0    
STA $1025     ; PosY = 0xC0 
STZ $100A     ; ???
LDA #$0001     
STA $1012     ; ??? 
STZ $1030     ; VelX
STZ $1032     ; VelY
STZ $1034     ; Gravity
STZ $1036     ; ???
STZ $1038     ; ???
STZ $103A     ; ???
STZ $1079     ; ???
LDA $E00238,x ; PaletteOffset = $E00238 + CharaID * 2
STA $20       ; ReadPos
SEP #$20      ; 1 byte accumulator
LDA [$20] 
INC $20    
STA $1048     ; FirstHitDefense = Byte1
REP #$20      ; 2 byte accumulator
LDA $1D02 
AND #$00FF 
STA $00       ; PaletteID 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Replaced (see below)
/*
ASL A
CLC
ADC $00       ; PaletteID*3
CLC
ADC $20       ; Read Pos
STA $23       ; ReadPos + PaletteID*3
LDA $22
STA $25       ; $25 = ReadBank (0xE0)
LDA [$23]
STA $00       ; CopySource = [ReadPos] (Color1 or Color2 pointer)
INC $23
INC $23
LDA [$23]
STA $02       ; CopyBank = PaletteBank
INC $20
INC $20
INC $20
INC $20
INC $20
INC $20       ; ReadPos += 6
LDA #$0600
STA $04       ; CopyDest = $0600
LDA #$0020
STA $06       ; CopySize = 0x20
JSL $808ADD   ; BlockCopy()
REP #$20      ; 2 byte accumulator
LDA [$20]     ;
STA $00       ; CopySource = [ReadPos] (Win icon pointer)
INC $20       ;
INC $20       ; ReadPos += 2
LDA [$20]     ; CopyBank = [ReadPos]
STA $02       ;
INC $20       ; ReadPos ++
LDA #$0530    ;
STA $04       ; CopyDest = $0530
LDA #$0008    ;
STA $06       ; CopySize = 8
JSL $808ADD   ; BlockCopy()
REP #$20      ;
LDA [$20]     ;
STA $00       ; CopySource = [ReadPos] (Object palette pointer)
INC $20       ;
INC $20       ; ReadPos += 2
LDA [$20]     ;
STA $02       ; CopyBank = [ReadPos]
INC $20       ; ReadPos ++
LDA #$0640    ;
STA $04       ; CopyDest = $0640 
LDA #$0020    ;
STA $06       ; CopySize = 0x20
JSL $808ADD   ; BlockCopy()
*/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modified
;Increment loading pointer to skip internal palette data
LDA #$000C    ;4 palette pointers, 3 bytes each
CLC
ADC $20
STA $20

;Get palette offset
TXA           ;X already contains CharaID * 2
XBA
ASL A
ASL A
ASL A
STA $02       ;CharaID * 0x1000
LDA $00       ;PaletteID was stored in $00 before this block of code
XBA
LSR A         ;PaletteID * 0x80
CLC
ADC $02       ;Add both of the above
CLC

;Copy 1P win icon
ADC #$0008
STA $00       ;CopySource = CharaID * 0x1000 + PaletteID * 0x80
LDA #$00E8    ;Note: Use replacement string instead of E8 in patcher
STA $02       ;CopyBank = 0xE8
LDA #$0530
STA $04       ;CopyDest = $0530
LDA #$0008
STA $06       ;CopySize = 0x08
JSL $808ADD   ;BlockCopy()

;Copy 1P palette
STX $00       ;CopySource = X (The X register contains the next byte after the copied block)
LDA #$0600
STA $04       ;CopyDest = $0600
LDA #$0020
STA $06       ;CopySize = 0x20
JSL $808ADD   ;BlockCopy()

;Fill space occupied by original
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP           
STX $00       ;CopySource = X

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unmodified
LDA #$0640
STA $04       ;CopyDest = $0640
LDA #$0020
STA $06       ;CopySize = 0x20
JSL $808ADD   ;BlockCopy()
REP #$20
LDA [$20]
STA $00       ;CopySource = [ReadPos]
INC $20
INC $20       ;ReadPos += 2
LDA [$20]
STA $02       ;CopyBank = [ReadPos] 
INC $20       ;ReadPos ++
LDA #$6A00
STA $03       ;CopyDest = $6A00
LDA #$6A01
STA $05
JSR $916B
SEP #$30
LDA $1D00
CLC
ADC #$1E
JSL $80EB4B