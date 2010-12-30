; OSTC - diving computer code
; Copyright (C) 2009 HeinrichsWeikamp GbR

;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.


; hardware routines for S6E6D6 Samsung OLED Driver IC
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 090801
; last updated: 090830
; known bugs:
; ToDo: Optimise PLED_box calls

WIN_FONT 	macro	win_font_input
			movlw	win_font_input
			movff	WREG,win_font
			endm
			
WIN_TOP 	macro 	win_top_input
			movlw	win_top_input
			movff	WREG,win_top
			endm
			
WIN_LEFT 	macro 	win_left_input
			movlw	win_left_input
			movff	WREG,win_leftx2
			endm
			
WIN_INVERT	macro 	win_invert_input
			movlw	win_invert_input
			movff	WREG,win_invert
			endm

WIN_COLOR	macro 	win_color_input
			movlw	win_color_input
			call	PLED_set_color
			endm
	
word_processor:						; word_processor:
	clrf	POSTINC2				; Required, to mark end of string.
	call	aa_wordprocessor
	movlb	b'00000001'				; Back to Rambank1
	return

; -----------------------------
; PLED_SetColumnPixel:
; -----------------------------
PLED_SetColumnPixel:
	movwf	win_leftx2		    ; d'0' ... d'159'
	mullw   2                   ; Copy to POD, times 2.

	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	bra     PLED_DataWrite_PROD

; -----------------------------
; PLED_SetRow:
; Backup WREG --> win_top, for the next write pixel.
; Setup OLED pixel horizontal address.
; -----------------------------
PLED_SetRow:		
	movff  	WREG,win_top                ; d'0' ... d'239'
	mullw   1                           ; Copy row to PRODH:L
	movlw	0x20			; Horizontal Address START:END
	rcall	PLED_CmdWrite
	bra     PLED_DataWrite_PROD		

; -----------------------------
; PLED Write Two Pixel
; -----------------------------

PLED_PxlWrite:
    rcall   PLED_PxlWrite_Single        ; Write first pixel.

; Write 2nd Pixel on same row but one column to the right
    movwf   win_leftx2,W                ; Increment column address.
    mullw   2
    incf    PRODL
    clrf    WREG                        ; Does not reset CARRY...
    addwfc  PRODH
	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	rcall   PLED_DataWrite_PROD
    ; Continue with PLED_PxlWrite_Single...

; -----------------------------
; PLED Write One Pixel
; -----------------------------
PLED_PxlWrite_Single:
	movlw	0x22					; Start Writing Data to GRAM
	rcall	PLED_CmdWrite
	bsf		oled_rs					; Data!
	movff	win_color1, PORTD
	bcf		oled_rw
	bsf		oled_rw					; Upper
	movff	win_color2, PORTD
	bcf		oled_rw
	bsf		oled_rw					; Lower
	return

; -----------------------------
; PLED Display Off
; -----------------------------
PLED_DisplayOff:
	clrf	PORTD
	bcf		oled_hv
	bcf		oled_vdd
	bcf		oled_cs
	bcf		oled_e_nwr	
	bcf		oled_rw
	bcf		oled_nreset
	return

;=============================================================================
; PLED_frame : draw a frame around current box with current color.
; Inputs:  win_top, win_leftx2, win_height, win_width, win_color1, win_color2
; Outputs: (none)
; Trashed: WREG, PROD, aa_start:2, aa_end:2, win_leftx2, win_width:1

PLED_frame: 
    movff   win_top,aa_start+0              ; Backup everything.
    movff   win_height,aa_start+1
    movff   win_leftx2,aa_end+0
    movff   win_width,aa_end+1

    ;---- TOP line -----------------------------------------------------------
    movlw   1                               ; row ~ height=1
    movff   WREG,win_height
    rcall   PLED_box

    ;---- BOTTOM line --------------------------------------------------------
    movff   aa_start+0,PRODL                ; Get back top,
    movff   aa_start+1,WREG                 ; and height
    addwf   PRODL,W                         ; top+height
    decf    WREG                            ; top+height-1
    movff   WREG,win_top                    ; top+height-1 --> top
    rcall   PLED_box                        

    ;---- LEFT column --------------------------------------------------------
    movff   aa_start+0,win_top              ; Restore top/height.
    movff   aa_start+1,win_height
    movlw   1                               ; column ~ width=1
    movff   WREG,win_width
    rcall   PLED_box

    ;---- RIGHT column -------------------------------------------------------
    movff   aa_end+0,WREG
    movff   aa_end+1,PRODL
    addwf   PRODL,W
    decf    WREG
    movff   WREG,win_leftx2
    bra     PLED_box

;=============================================================================
; PLED_box : fills current box with current color.
; Inputs:  win_top, win_leftx2, win_height, win_width, win_color1, win_color2
; Outputs: (none)
; Trashed: WREG, PROD

PLED_box:
    ;---- Define Window ------------------------------------------------------
	movlw	0x35				; VerticalStartAddress HIGH:LOW
	rcall	PLED_CmdWrite
	movff	win_leftx2,WREG
	mullw   2
	rcall	PLED_DataWrite_PROD

	movlw	0x36				; VerticalEndAddress HIGH:LOW
	rcall	PLED_CmdWrite
	movff   win_width,PRODL     ; Bank-safe addressing
	movff	win_leftx2,WREG
	addwf   PRODL,W             ; left+width
	decf    WREG                ; left+width-1
	mullw   2                   ; times 2 --> rightx2
	rcall	PLED_DataWrite_PROD

	movlw	0x37				; HorizontalAddress START:END
	rcall	PLED_CmdWrite
	movff	win_top,PRODH       ; Start row.
	movff   win_height,PRODL    ; height
    movf    PRODH,W
    addwf   PRODL,F             ; top + height
    decf    PRODL,F             ; top + height - 1 --> bottom.
	rcall	PLED_DataWrite_PROD

    ;---- Start pointer ------------------------------------------------------
	movlw	0x20				; Start Address Horizontal (.0 - .239)
	rcall	PLED_CmdWrite
	movff	win_top,WREG
	mullw   1
	rcall	PLED_DataWrite_PROD

	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	movff	win_leftx2,WREG
	mullw   2
	rcall	PLED_DataWrite_PROD

    ;---- Fill Window --------------------------------------------------------
	movlw	0x22					; Start Writing Data to GRAM
	rcall	PLED_CmdWrite

	movff	win_height,PRODH
	bsf		oled_rs					; Data!

PLED_box2:                          ; Loop height times
	movff	win_width,PRODL
PLED_box3:                          ; loop width times
	movff	win_color1,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Upper
	movff	win_color2,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Lower

	movff	win_color1,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Upper
	movff	win_color2,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Lower

	decfsz	PRODL,F
	bra		PLED_box3
	decfsz	PRODH,F
	bra		PLED_box2

	movlw	0x00					; NOP, to stop Address Update Counter
	bra     PLED_CmdWrite

;=============================================================================
; PLED_ClearScreen: An optimized version of PLEX_box, for ful screen black.
; Trashed: WREG, PROD

PLED_ClearScreen:
	movlw	0x35				; VerticalStartAddress HIGH:LOW
	rcall	PLED_CmdWrite
	mullw   0
	rcall	PLED_DataWrite_PROD

	movlw	0x36				; VerticalEndAddress HIGH:LOW
	rcall	PLED_CmdWrite
	movlw	0x01
	rcall	PLED_DataWrite		
	movlw	0x3F
	rcall	PLED_DataWrite		

	movlw	0x37				; HorizontalAddress START:END
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DataWrite		
	movlw	0xEF
	rcall	PLED_DataWrite		

	movlw	0x20				; Start Address Horizontal (.0 - .239)
	rcall	PLED_CmdWrite
	rcall	PLED_DataWrite_PROD

	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	rcall	PLED_DataWrite_PROD

	movlw	0x22					; Start Writing Data to GRAM
	rcall	PLED_CmdWrite

	; See Page 101 of OLED Driver IC Datasheet how to handle rs/rw clocks
	bsf		oled_rs					; Data!

	movlw	.160
	movwf	PRODH
PLED_ClearScreen2:
	movlw	.240
	movwf	PRODL
PLED_ClearScreen3:

	clrf	PORTD					; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw					; Upper

    clrf	PORTD					; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw					; Lower

	clrf	PORTD					; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw					; Upper

    clrf	PORTD					; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw					; Lower

	decfsz	PRODL,F
	bra		PLED_ClearScreen3
	decfsz	PRODH,F
	bra		PLED_ClearScreen2

	movlw	0x00					; NOP, to stop Address Update Counter
	bra     PLED_CmdWrite

; -----------------------------
; PLED Write Cmd via W
; -----------------------------
PLED_CmdWrite:
	bcf		oled_rs					; Command!
	movwf	PORTD					; Move Data to PORTD
	bcf		oled_rw
	bsf		oled_rw
	return

; -----------------------------
; PLED Write Display Data via W
; -----------------------------
PLED_DataWrite:
	bsf		oled_rs					; Data!
	movwf	PORTD					; Move Data to PORTD
	bcf		oled_rw
	bsf		oled_rw
	return

; -----------------------------
; PLED Data Cmd via W
; -----------------------------
PLED_DataWrite_PROD:
	bsf		oled_rs					; Data!
	movff	PRODH,PORTD				; Move high byte to PORTD (OLED is bigendian)
	bcf		oled_rw
	bsf		oled_rw
	movff	PRODL,PORTD				; Move low byte to PORTD
	bcf		oled_rw
	bsf		oled_rw
	return

; -----------------------------
; PLED boot
; -----------------------------
PLED_boot:
	bcf		oled_hv
	WAITMS	d'32'
	bsf		oled_vdd
	nop
	bcf		oled_cs
	nop
	bsf		oled_nreset
;	WAITMS	d'10'			; Quick wake-up
	WAITMS	d'250'			; Standard wake-up
	bsf		oled_e_nwr	
	nop
	bcf		oled_nreset
	WAIT10US	d'2'
	bsf		oled_nreset
	WAITMS	d'10'

	movlw	0x24				; 80-System 8-Bit Mode
	rcall	PLED_CmdWrite

	movlw	0x02				; RGB Interface Control (S6E63D6 Datasheet page 42)
	rcall	PLED_CmdWrite
	movlw	0x00				; X X X X X X X RM
	rcall	PLED_DataWrite
	movlw	0x00				; DM X RIM1 RIM0 VSPL HSPL EPL DPL
	rcall	PLED_DataWrite		; System Interface: RIM is ignored, Internal Clock

	movlw	0x03				; Entry Mode (S6E63D6 Datasheet page 46)
	rcall	PLED_CmdWrite
	movlw	0x00				; =b'00000000' 	CLS MDT1 MDT0 	BGR 	X  	X  	X  	SS  65k Color
	rcall	PLED_DataWrite
	movlw	b'00110000'			; =b'00110000'	X  	X 	 I/D1 	I/D0 	X  	X  	X 	AM
	rcall	PLED_DataWrite

	movlw	0x18
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x28
	rcall	PLED_DataWrite

	movlw	0xF8
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x0F
	rcall	PLED_DataWrite

	movlw	0xF9
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x0F
	rcall	PLED_DataWrite

	movlw	0x10
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x00
	rcall	PLED_DataWrite

; Now Gamma settings...
	rcall	PLED_brightness_full
	;rcall	PLED_brightness_low
; End Gamma Settings

	rcall	PLED_ClearScreen

	bsf		oled_hv
	WAITMS	d'32'

	movlw	0x05
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x01
	rcall	PLED_DataWrite			; Display ON
	return


PLED_brightness_full:
	movlw	0x70
	rcall	PLED_CmdWrite
	movlw	0x1F
	rcall	PLED_DataWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x71
	rcall	PLED_CmdWrite
	movlw	0x23
	rcall	PLED_DataWrite
	movlw	0x80
	rcall	PLED_DataWrite
	movlw	0x72
	rcall	PLED_CmdWrite
	movlw	0x2A
	rcall	PLED_DataWrite
	movlw	0x80
	rcall	PLED_DataWrite

	movlw	0x73
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DataWrite
	movlw	0x11
	rcall	PLED_DataWrite
	movlw	0x74
	rcall	PLED_CmdWrite
	movlw	0x1C
	rcall	PLED_DataWrite
	movlw	0x11
	rcall	PLED_DataWrite

	movlw	0x75
	rcall	PLED_CmdWrite
	movlw	0x1B
	rcall	PLED_DataWrite
	movlw	0x15
	rcall	PLED_DataWrite
	movlw	0x76
	rcall	PLED_CmdWrite
	movlw	0x1A
	rcall	PLED_DataWrite
	movlw	0x15
	rcall	PLED_DataWrite

	movlw	0x77
	rcall	PLED_CmdWrite
	movlw	0x1C
	rcall	PLED_DataWrite
	movlw	0x18
	rcall	PLED_DataWrite
	movlw	0x78
	rcall	PLED_CmdWrite
	movlw	0x21
	rcall	PLED_DataWrite
	movlw	0x15
	rcall	PLED_DataWrite
	
	return

PLED_brightness_low:
	movlw	0x70
	rcall	PLED_CmdWrite
	movlw	0x14
	rcall	PLED_DataWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x71
	rcall	PLED_CmdWrite
	movlw	0x17
	rcall	PLED_DataWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x72
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DataWrite
	movlw	0x80
	rcall	PLED_DataWrite

	movlw	0x73
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DataWrite
	movlw	0x11
	rcall	PLED_DataWrite
	movlw	0x74
	rcall	PLED_CmdWrite
	movlw	0x14
	rcall	PLED_DataWrite
	movlw	0x0B
	rcall	PLED_DataWrite

	movlw	0x75
	rcall	PLED_CmdWrite
	movlw	0x1B
	rcall	PLED_DataWrite
	movlw	0x15
	rcall	PLED_DataWrite
	movlw	0x76
	rcall	PLED_CmdWrite
	movlw	0x13
	rcall	PLED_DataWrite
	movlw	0x0E
	rcall	PLED_DataWrite

	movlw	0x77
	rcall	PLED_CmdWrite
	movlw	0x1C
	rcall	PLED_DataWrite
	movlw	0x18
	rcall	PLED_DataWrite
	movlw	0x78
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DataWrite
	movlw	0x0E
	rcall	PLED_DataWrite
	
	return

PLED_set_color:;Converts 8Bit RGB b'RRRGGGBB' into 16Bit RGB b'RRRRRGGGGGGBBBBB'
	movwf	oled1_temp				; Get 8Bit RGB b'RRRGGGBB'
	movff	oled1_temp,	oled2_temp	; Copy

	; Mask Bit 7,6,5,4,3,2
	movlw	b'00000011'
	andwf	oled2_temp,F

	movlw	b'00000000'
	dcfsnz	oled2_temp,F
	movlw	b'01010000'
	dcfsnz	oled2_temp,F
	movlw	b'10100000'
	dcfsnz	oled2_temp,F
	movlw	b'11111000'
	movwf	oled3_temp				; Blue done.

	movff	oled1_temp,	oled2_temp	; Copy
	; Mask Bit 7,6,5,1,0
	movlw	b'00011100'
	andwf	oled2_temp,F
	rrncf	oled2_temp,F
	rrncf	oled2_temp,F

	movlw	b'00000000'
	dcfsnz	oled2_temp,F
	movlw	b'00000100'
	dcfsnz	oled2_temp,F
	movlw	b'00001000'
	dcfsnz	oled2_temp,F
	movlw	b'00001100'
	dcfsnz	oled2_temp,F
	movlw	b'00010000'
	dcfsnz	oled2_temp,F
	movlw	b'00010100'
	dcfsnz	oled2_temp,F
	movlw	b'00100000'
	dcfsnz	oled2_temp,F
	movlw	b'00111111'
	movwf	oled4_temp			

	rrcf	oled4_temp,F
	rrcf	oled3_temp,F

	rrcf	oled4_temp,F
	rrcf	oled3_temp,F

	rrcf	oled4_temp,F
	rrcf	oled3_temp,F		; oled3_temp (b'GGGBBBBB') done.

	movff	oled1_temp,	oled2_temp	; Copy
	clrf	oled1_temp

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F		; Green done.

	; Mask Bit 4,3,2,1,0
	movlw	b'11100000'
	andwf	oled2_temp,F

	rrncf	oled2_temp,F
	rrncf	oled2_temp,F
	rrncf	oled2_temp,F
	rrncf	oled2_temp,F
	rrncf	oled2_temp,F

	movlw	b'00000000'
	dcfsnz	oled2_temp,F
	movlw	b'00000100'
	dcfsnz	oled2_temp,F
	movlw	b'00001000'
	dcfsnz	oled2_temp,F
	movlw	b'00001100'
	dcfsnz	oled2_temp,F
	movlw	b'00010000'
	dcfsnz	oled2_temp,F
	movlw	b'00010100'
	dcfsnz	oled2_temp,F
	movlw	b'00100000'
	dcfsnz	oled2_temp,F
	movlw	b'00111111'
	movwf	oled4_temp			

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F	

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F

	rrcf	oled4_temp,F
	rrcf	oled1_temp,F		; Red done.

	movff	oled1_temp,win_color1
	movff	oled3_temp,win_color2	; Set Bank0 Color registers...
	return

