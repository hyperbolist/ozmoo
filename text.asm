; message handing and decoding
;
; DragonTroll: PRINT_PADDR S030 ("The Dragon and the Troll"): 8d 03 1b

convert_paddr
    ; convert a/x to paddr in .addr
    stx .addr + 2 ; 1b
    sta .addr + 1 ; 03
    lda #$0
    sta .addr

    asl .addr+2
    rol .addr+1
    rol .addr
    asl .addr+2
    rol .addr+1
    rol .addr
    ; $031b -> $00, $0c, $6c
    rts

read_text_byte
    lda .addr
    ldx .addr + 1
    ldy .addr + 2
    jsr read_byte_at_z_address
    inc .addr + 2
    bne +
    inc .addr + 1
    bne +
    inc .addr
+   rts

print_paddr
-   jsr read_text_byte
    sta .packedtext
    jsr read_text_byte
    sta .packedtext + 1

    ; extract 3 zchars (5 bits each)
    ldx #0
--  lda .packedtext + 1
    and #$1f
    sta .zchars,x

    ldy #5
--- lsr .packedtext
    ror .packedtext+1
    dey
    bne ---
    inx
    cpx #3
    bne --

    ; print the three chars
    ldx #2
--  lda .zchars,x
    cmp #6
    bcc .l1
    ; print zchar
    sec
    sbc #6
    clc
    adc .alphabet_offset
    tay
    lda .alphabet,y
    jsr kernel_printchar
    ; change back to A0
    lda #0
    sta .alphabet_offset
    jmp .next_zchar
.l1 cmp #0
    bne .l2
    ; space
    lda #$20
    jsr kernel_printchar
    jmp .next_zchar
.l2 cmp #4
    bne .l3
    ; change to A1
    lda #26
    sta .alphabet_offset
    jmp .next_zchar
.l3 cmp #5
    bne .l4
    ; change to A2
    lda #52
    sta .alphabet_offset
.l4
.next_zchar
    dex
    bpl --

    lda .packedtext + 1
    beq -
    rts

testtext
    lda #0
    sta .alphabet_offset
    lda #$03
    ldx #$1b
    jsr convert_paddr
    ; $0c6c: 13 2d 28 04 26 e6
    ; $132d: 0 00100 11001 01101 = 4 25 13: (A1) Th
    ; $2804: 0 01010 00000 00100 =
    jsr print_paddr
    rts

.addr !byte 0,0,0
.zchars !byte 0,0,0
.packedtext !byte 0,0
.alphabet_offset !byte 0
.alphabet
    !pet "abcdefghijklmnopqrstuvwxyz"
    !pet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    !pet " ",13,"0123456789.,!?_#'",34, "/\-:()"