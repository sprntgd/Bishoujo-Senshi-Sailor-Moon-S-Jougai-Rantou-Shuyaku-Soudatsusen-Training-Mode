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
.ORGA $898E
; 00898E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Direct copy of the modified code in Load1P.asm with different offsets. Changed lines are marked
REP #$20
LDA $1D05     ; $1D02 -> $1D05
AND #$00FF
STA $00
LDA #$000C
CLC
ADC $20
STA $20
TXA
XBA
ASL A
ASL A
ASL A
STA $02
LDA $00
XBA
LSR A
CLC
ADC $02
CLC
ADC #$0008
STA $00
LDA #$00E8
STA $02
LDA #$0538    ; $0530 -> $0538
STA $04
LDA #$0008
STA $06
JSL $808ADD
STX $00
LDA #$0620    ; $0600 -> $0620
STA $04
LDA #$0020
STA $06
JSL $808ADD
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
STX $00
LDA #$0660    ; $0640 -> $0660
STA $04
LDA #$0020
STA $06
JSL $808ADD