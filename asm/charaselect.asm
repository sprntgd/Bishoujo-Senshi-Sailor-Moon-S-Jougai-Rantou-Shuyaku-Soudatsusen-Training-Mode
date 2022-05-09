.MEMORYMAP
  SLOTSIZE $10000
  DEFAULTSLOT 0
  SLOT 0 $0000
.ENDME

.ROMBANKMAP
  BANKSTOTAL $40
  BANKSIZE $10000
  BANKS $40
.ENDRO

.BANK $00
.ORGA $A630
JSL $E8000A
RTS

.BANK $28
.ORGA $0000
; E80000
.DB $00, $02, $08, $0C, $0A, $0E, $10, $06, $04, $00
; E8000A
REP #$30
LDA [$FE]
AND #$C0C0  ;Bitmask for A+B+X+Y
BNE +       ;Skip next 2 lines if pressed
REP #$20
RTL
+
;Unmodified code. Nothing interesting.
SEP #$20
LDA #$03
STA $78
STZ $1D02
REP #$30
LDA #$0001
STA $0002,y
;Process palette number for A B X Y press
STX $04
STZ $00
LDA [$FE]
AND #$C040  ;B or X or Y
BEQ +
INC $00
+
AND #$4040  ;X or Y
BEQ +
INC $00
+
AND #$0040  ;X
BEQ +
INC $00
+
;Process held L R Start
LDA $FE
SEC
SBC #$0004
STA $FE     ;Change pointer to reference held buttons
LDA [$FE]
AND #$0020  ;L
BEQ +       ;Skip next 2 lines if not holding L
LDA #$0004
TSB $00     ;Add 0x04 to Palette
+
LDA [$FE]
AND #$0010  ;R
BEQ +       ;Skip next 2 lines if not holding R
LDA #$0008
TSB $00     ;Add 0x08 to Palette
+
LDA [$FE]
AND #$1000
BEQ +       ;Skip next 2 lines if not holding Start
LDA #$0010  ;Add 0x10 to Palette
TSB $00
+
--
;Check if color is allowed
LDA $1B10
BEQ +       ;Branch if other player hasn't selected
LDA $1B16
CMP $0000,y
BNE +       ;Branch if other player selected a different character
LDA $1B14
CMP $00
BNE +       ;Branch if other player selected a different color
LDA $00
EOR #$0001  ;1P+2P clash, so select adjacent color (A=B, X=Y)
STA $00
+
;Make sure color exists by checking if the first byte is nonzero
LDA $0000,y
XBA
ASL
ASL
ASL
ASL
STA $02     ;CharacterID * 0x1000
LDA $00
XBA
LSR         ;PaletteID * 0x80
CLC
ADC $02     ;Add the above
TAX
LDA $E80000,x ;Note: Use replacement string instead of E8 in patcher
BNE +       ; Branch if non-zero
;Unset highest bit palette until valid (1F -> 0F -> 07 -> 03 -> 01 -> 00)
LDA #$0020
-
LSR
BRA +       ; Break if we reach color 0
TRB $00
BEQ -       ; Back to LSR if palette was unchanged
BRA --
+
LDA $00
STA $0004,y
STA $1B14   ;Store selected color
LDA $0000,y
STA $1B16   ;Store selected character
TAX
;Select character's stage by default
LDA $E80000,x  ;Note: Use replacement string instead of E8 in patcher
SEP #$20
STA $8E     ; Character stage
REP #$20    
LDA [$FE]
AND #$0F00  ; Bitmask for any d-pad direction
BNE ++
;Override with random select if not holding a direction
LDA $B1
AND #$00FF
-
CMP #$0009
BCC +
SEC
SBC #$0009  ;Subtract 9 until stage is less than 9
BRA -
+
ASL
STA $8E     ;Random stage
++
;Keep track of stuff
INC $1B10   ;Track number of players who have selected their character
LDA $0006,y
TAX
LDA #$0001
STA $0000h,x 
LDX $04     ;Restore value of X to what it was before this function
RTL
NOP         ;Repeat to fill the space held by the original code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Original code. Completely replaced by the above
/*
REP #$30
LDA [$FE]
AND #$5080
BEQ +        ;Not pressed A or Y or Start
;Pressed A or Y or Start
SEP #$20
LDA #$03
STA $78
STZ $1D02
REP #$30
LDA #$0001
STA $0002,y
JSR color1   ;Check and select default color
INC $1B10
STX $00
LDA $0006,y
TAX
LDA #$0001
STA $0000,x
LDX $00
REP #$30
BRA ++
;Not pressed A or Y or Start
+
REP #$20
LDA [$FE]
AND #$8040
BEQ ++      ;Not pressed B or X
;Pressed B or X
SEP #$20
LDA #$03
STA $78
STZ $1D02
REP #$30
LDA #$0001
STA $0002,y
JSR color2   ;Check and select alt color
INC $1B10
STX $00
LDA $0006,y
TAX
LDA #$0001
STA $0000,x
LDX $00
;No input
++
REP #$20
RTS
;Check if default color is allowed
color1:
REP #$30
LDA $1B10
BEQ +       ;Other player has not selected a character
LDA $1B14
CMP #$0001
BNE +       ;Other player did not select default color
LDA $1B16
CMP $0000,y
BNE +       ;Other player selected a different character
;Select default color
LDA #$0001
STA $0004,y
RTS
+
LDA #$0000
STA $0004,y ;Alt color
LDA #$0001
STA $1B14   ;Store palette
LDA $0000,y
STA $1B16   ;Store CharacterID
RTS

;Check if alt color is allowed
color2:
REP #$30
LDA $1B10
BEQ +       ;Other player has not selected a character
LDA $1B14
CMP #$0002
BNE +       ;Other player did not select alt color
LDA $1B16
CMP $0000,y
BNE +       ;Other player selected a different character
LDA #$0000
STA $0004,y ;Select default color
RTS
+
;Select alt color
LDA #$0001
STA $0004,y
LDA #$0002
STA $1B14   ;Store Palette
LDA $0000,y
STA $1B16   ;Store CharacterID
RTS
*/