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

.BANK 0
.ORGA $85FE
; 8085FE
JSL $E9000A

.BANK $29
.ORGA $0000
; E90000
.DB $00, $0A, $0B, $0C, $0D, $0E, $10, $11, $0F, $12
; E9000A
REP #$30
CMP #$0006
BEQ +        ; Branch if Nakayoshi music
JMP $80EB4B
+
LDA $B1
AND #$0001   ; Random 0 or 1
STA $00
ASL A
CLC
ADC $00      ; Multiply by 3
TAX
SEP #$20
LDA $1D00,x  ; Character ID  01 0A : 02 0B : 03 0C : 04 0D : 05 0E : 06 10 : 07 11 : 08 0F : 09 12
TAX
LDA $E90000,x
REP #$20
STA $A2
JMP $80EB4B