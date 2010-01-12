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
	clrf	POSTINC2				; Required!
	movff	win_color2,win_color2_temp
	movff	win_color1,win_color1_temp
	call	main_wordprocessor		; C-Code
	movlb	b'00000001'				; Back to Rambank1
	movff	win_color2_temp,win_color2
	movff	win_color1_temp,win_color1
	return

; -----------------------------
; PLED_SetColumnPixel:
; -----------------------------
PLED_SetColumnPixel:
	movwf	LastSetColumn		; d'0' ... d'159'
	movff	LastSetColumn,win_leftx2
	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	bcf		STATUS,C
	rlcf	LastSetColumn,W		; x2 -> WREG
	movlw	d'0'
	btfsc	STATUS,C			; Result >255?
	movlw	d'1'				; Yes: Upper=1!
	rcall	PLED_DatWrite		; Upper
	bcf		STATUS,C
	rlcf	LastSetColumn,W		; x2 -> WREG
	rcall	PLED_DatWrite		; Lower
	return

; -----------------------------
; PLED_SetRow:
; -----------------------------
PLED_SetRow:		
	movwf	LastSetRow		; d'0' ... d'239'
	movff	LastSetRow,win_top
	movlw	0x20			; Horizontal Address START:END
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite		
	movf	LastSetRow,W
	rcall	PLED_DatWrite		
	return

; -----------------------------
; PLED Write Two Pixel
; -----------------------------
PLED_PxlWrite:
	movlw	0x22					; Start Writing Data to GRAM
	rcall	PLED_CmdWrite
	bsf		oled_rs					; Data!
	movff	win_color1,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Upper
	movff	win_color2,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Lower

; Reset Column+1
	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	bcf		STATUS,C
	rlcf	LastSetColumn,W		; x2
	movlw	d'0'
	btfsc	STATUS,C			; Result >256?
	movlw	d'1'				; Yes!
	rcall	PLED_DatWrite		; Upper
	bcf		STATUS,C
	rlcf	LastSetColumn,F
	incf	LastSetColumn,W		; x2
	rcall	PLED_DatWrite		; Lower

; Reset Row
	movlw	0x20			; Horizontal Address START:END
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite		
	movf	LastSetRow,W
	rcall	PLED_DatWrite		

; Write 2nd Pixel on same row but one column to the right
	movlw	0x22					; Start Writing Data to GRAM
	rcall	PLED_CmdWrite
	bsf		oled_rs					; Data!
	movff	win_color1,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Upper
	movff	win_color2,PORTD
	bcf		oled_rw
	bsf		oled_rw					; Lower
	return

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

; -----------------------------
; PLED FRAME (win_color1 and win_color2)
; -----------------------------
PLED_frame: 
	movf	box_temp+0,W
	call	PLED_set_color
	; draw right line from row top (box_temp+1) to row bottom (box_temp+2)
	movff	box_temp+1,draw_box_temp1		; Store start row
PLED_frame2:
	movf	draw_box_temp1,W				; d'0' ... d'239'
	rcall	PLED_SetRow						; Set Row
	movf	box_temp+3,W					; d'0' ... d'159'
	call	PLED_SetColumnPixel				; Set left column
	rcall	PLED_PxlWrite_Single			; Write Pixel
	incf	draw_box_temp1,F
	movf	draw_box_temp1,W				; Copy to W
	cpfseq	box_temp+2						; Done?
	bra		PLED_frame2						; Not yet...

	movf	draw_box_temp1,W				; d'0' ... d'239'
	rcall	PLED_SetRow						; Set Row
	movf	box_temp+3,W					; d'0' ... d'159'
	call	PLED_SetColumnPixel				; Set left column
	rcall	PLED_PxlWrite_Single			; Write Pixel

	; draw left line from row top (box_temp+1) to row bottom (box_temp+2)
	movff	box_temp+1,draw_box_temp1		; Store start row
PLED_frame3:
	movf	draw_box_temp1,W				; d'0' ... d'239'
	rcall	PLED_SetRow						; Set Row
	movf	box_temp+4,W					; d'0' ... d'159'
	call	PLED_SetColumnPixel				; Set left column
	rcall	PLED_PxlWrite_Single			; Write Pixel
	incf	draw_box_temp1,F
	movf	draw_box_temp1,W				; Copy to W
	cpfseq	box_temp+2						; Done?
	bra		PLED_frame3						; Not yet...

	movf	draw_box_temp1,W				; d'0' ... d'239'
	rcall	PLED_SetRow						; Set Row
	movf	box_temp+4,W					; d'0' ... d'159'
	call	PLED_SetColumnPixel				; Set left column
	rcall	PLED_PxlWrite_Single			; Write Pixel

	; draw top line from box_temp+3 (0-159) to box_temp+4 (0-159)
	movff	box_temp+3,draw_box_temp1		; Store start column
PLED_frame4:
	movf	draw_box_temp1,W				; d'0' ... d'159'
	rcall	PLED_SetColumnPixel				; Set Column
	movf	box_temp+1,W					; d'0' ... d'239'
	rcall	PLED_SetRow						; Set Row
	rcall	PLED_PxlWrite					; Write 2 Pixels
	incf	draw_box_temp1,F
	movf	draw_box_temp1,W
	cpfseq	box_temp+4
	bra		PLED_frame4

	; draw bottom line from box_temp+3 (0-159) to box_temp+4 (0-159)
	movff	box_temp+3,draw_box_temp1		; Store start column
PLED_frame5:
	movf	draw_box_temp1,W				; d'0' ... d'159'
	rcall	PLED_SetColumnPixel				; Set Column
	movf	box_temp+2,W					; d'0' ... d'239'
	rcall	PLED_SetRow						; Set Row
	rcall	PLED_PxlWrite					; Write 2 Pixels
	incf	draw_box_temp1,F
	movf	draw_box_temp1,W
	cpfseq	box_temp+4
	bra		PLED_frame5

	movlw	color_white
	call	PLED_set_color

	return

; -----------------------------
; PLED Box (win_color1 and win_color2)
; -----------------------------
PLED_box:
	movf	box_temp+0,W
	call	PLED_set_color
; /Define Window
	movlw	0x35				; VerticalStartAddress HIGH:LOW
	rcall	PLED_CmdWrite
	movff	box_temp+3,draw_box_temp1
	bcf		STATUS,C
	rlcf	draw_box_temp1,W		; x2
	movlw	d'0'
	btfsc	STATUS,C			; Result >255?
	movlw	d'1'				; Yes: Upper=1!
	rcall	PLED_DatWrite		; Upper
	bcf		STATUS,C
	rlcf	draw_box_temp1,W		; x2 -> WREG
	rcall	PLED_DatWrite		; Lower

	movlw	0x36				; VerticalEndAddress HIGH:LOW
	rcall	PLED_CmdWrite
	movff	box_temp+4,draw_box_temp1
	bcf		STATUS,C
	rlcf	draw_box_temp1,W		; x2
	movlw	d'0'
	btfsc	STATUS,C			; Result >255?
	movlw	d'1'				; Yes: Upper=1!
	rcall	PLED_DatWrite		; Upper
	bcf		STATUS,C
	rlcf	draw_box_temp1,W		; x2 -> WREG
	rcall	PLED_DatWrite		; Lower

	movlw	0x37				; HorizontalAddress START:END
	rcall	PLED_CmdWrite
	movff	box_temp+1,draw_box_temp1
	movf	draw_box_temp1,W
	rcall	PLED_DatWrite		
	movff	box_temp+2,draw_box_temp1
	movf	draw_box_temp1,W
	rcall	PLED_DatWrite		

	movlw	0x20				; Start Address Horizontal (.0 - .239)
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite		
	movff	box_temp+1,draw_box_temp1
	movf	draw_box_temp1,W
	rcall	PLED_DatWrite		

	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	movff	box_temp+3,draw_box_temp1
	bcf		STATUS,C
	rlcf	draw_box_temp1,W		; x2
	movlw	d'0'
	btfsc	STATUS,C			; Result >255?
	movlw	d'1'				; Yes: Upper=1!
	rcall	PLED_DatWrite		; Upper
	bcf		STATUS,C
	rlcf	draw_box_temp1,W		; x2 -> WREG
	rcall	PLED_DatWrite		; Lower
; /Define Window

; Fill Window
	movlw	0x22					; Start Writing Data to GRAM
	rcall	PLED_CmdWrite

	movff	box_temp+1,draw_box_temp1
	movff	box_temp+2,draw_box_temp2
	movf	draw_box_temp1,W
	subwf	draw_box_temp2,F			; X length
	incf	draw_box_temp2,F

	movff	box_temp+3,draw_box_temp1
	movff	box_temp+4,draw_box_temp3
	movf	draw_box_temp1,W
	subwf	draw_box_temp3,F			; Y length/2

	incf	draw_box_temp3,F			; Last pixel...

	bsf		oled_rs					; Data!

PLED_box2:
	movff	draw_box_temp3,draw_box_temp1
PLED_box3:
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

	decfsz	draw_box_temp1,F
	bra		PLED_box3
	decfsz	draw_box_temp2,F
	bra		PLED_box2

	movlw	0x00					; NOP, to stop Address Update Counter
	rcall	PLED_CmdWrite

	movlw	color_white
	call	PLED_set_color
	return


; -----------------------------
; PLED_ClearScreen:
; -----------------------------
PLED_ClearScreen:
	movlw	0x35				; VerticalStartAddress HIGH:LOW
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite		
	movlw	0x00
	rcall	PLED_DatWrite		

	movlw	0x36				; VerticalEndAddress HIGH:LOW
	rcall	PLED_CmdWrite
	movlw	0x01
	rcall	PLED_DatWrite		
	movlw	0x3F
	rcall	PLED_DatWrite		

	movlw	0x37				; HorizontalAddress START:END
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite		
	movlw	0xEF
	rcall	PLED_DatWrite		

	movlw	0x20				; Start Address Horizontal (.0 - .239)
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite		
	movlw	0x00
	rcall	PLED_DatWrite		

	movlw	0x21				; Start Address Vertical (.0 - .319)
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite		
	movlw	0x00
	rcall	PLED_DatWrite		

	movlw	0x22					; Start Writing Data to GRAM
	rcall	PLED_CmdWrite

	bsf		oled_rs					; Data!

	clrf	PORTD					; See Page 101 of OLED Driver IC Datasheet
	
	movlw	d'10'
	movwf	draw_box_temp3
PLED_ClearScreen2:
	movlw	d'30'
	movwf	draw_box_temp2
PLED_ClearScreen3:
	clrf	draw_box_temp1				; 30*10*256=76800 Pixels -> Clear complete 240*320
PLED_ClearScreen4:

	bcf		oled_rw
	bsf		oled_rw					; Upper
	bcf		oled_rw
	bsf		oled_rw					; Lower

	decfsz	draw_box_temp1,F
	bra		PLED_ClearScreen4
	decfsz	draw_box_temp2,F
	bra		PLED_ClearScreen3
	decfsz	draw_box_temp3,F
	bra		PLED_ClearScreen2

	movlw	0x00					; NOP, to stop Address Update Counter
	rcall	PLED_CmdWrite

	return


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

; -----------------------------
; PLED Data Cmd via W
; -----------------------------
PLED_DatWrite:
	bsf		oled_rs					; Data!
	movwf	PORTD					; Move Data to PORTD
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
	WAITMS	d'10'			; Quick wake-up
;	WAITMS	d'250'
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
	rcall	PLED_DatWrite
	movlw	0x00				; DM X RIM1 RIM0 VSPL HSPL EPL DPL
	rcall	PLED_DatWrite		; System Interface: RIM is ignored, Internal Clock

	movlw	0x03				; Entry Mode (S6E63D6 Datasheet page 46)
	rcall	PLED_CmdWrite
	movlw	0x00				; =b'00000000' 	CLS MDT1 MDT0 	BGR 	X  	X  	X  	SS  65k Color
	rcall	PLED_DatWrite
	movlw	b'00110000'			; =b'00110000'	X  	X 	 I/D1 	I/D0 	X  	X  	X 	AM
	rcall	PLED_DatWrite

	movlw	0x18
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x28
	rcall	PLED_DatWrite

	movlw	0xF8
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x0F
	rcall	PLED_DatWrite

	movlw	0xF9
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x0F
	rcall	PLED_DatWrite

	movlw	0x10
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x00
	rcall	PLED_DatWrite

; Now Gamma settings...
	rcall	PLED_brightness_full
; End Gamma Settings

	rcall	PLED_ClearScreen

	bsf		oled_hv
	WAITMS	d'32'

	movlw	0x05
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x01
	rcall	PLED_DatWrite			; Display ON
	return


PLED_brightness_full:
	movlw	0x70
	rcall	PLED_CmdWrite
	movlw	0x1F
	rcall	PLED_DatWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x71
	rcall	PLED_CmdWrite
	movlw	0x23
	rcall	PLED_DatWrite
	movlw	0x80
	rcall	PLED_DatWrite
	movlw	0x72
	rcall	PLED_CmdWrite
	movlw	0x2A
	rcall	PLED_DatWrite
	movlw	0x80
	rcall	PLED_DatWrite

	movlw	0x73
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DatWrite
	movlw	0x11
	rcall	PLED_DatWrite
	movlw	0x74
	rcall	PLED_CmdWrite
	movlw	0x1C
	rcall	PLED_DatWrite
	movlw	0x11
	rcall	PLED_DatWrite

	movlw	0x75
	rcall	PLED_CmdWrite
	movlw	0x1B
	rcall	PLED_DatWrite
	movlw	0x15
	rcall	PLED_DatWrite
	movlw	0x76
	rcall	PLED_CmdWrite
	movlw	0x1A
	rcall	PLED_DatWrite
	movlw	0x15
	rcall	PLED_DatWrite

	movlw	0x77
	rcall	PLED_CmdWrite
	movlw	0x1C
	rcall	PLED_DatWrite
	movlw	0x18
	rcall	PLED_DatWrite
	movlw	0x78
	rcall	PLED_CmdWrite
	movlw	0x21
	rcall	PLED_DatWrite
	movlw	0x15
	rcall	PLED_DatWrite
	
	return

PLED_brightness_low:
	movlw	0x70
	rcall	PLED_CmdWrite
	movlw	0x14
	rcall	PLED_DatWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x71
	rcall	PLED_CmdWrite
	movlw	0x17
	rcall	PLED_DatWrite
	movlw	0x00
	rcall	PLED_DatWrite
	movlw	0x72
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DatWrite
	movlw	0x80
	rcall	PLED_DatWrite

	movlw	0x73
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DatWrite
	movlw	0x11
	rcall	PLED_DatWrite
	movlw	0x74
	rcall	PLED_CmdWrite
	movlw	0x14
	rcall	PLED_DatWrite
	movlw	0x0B
	rcall	PLED_DatWrite

	movlw	0x75
	rcall	PLED_CmdWrite
	movlw	0x1B
	rcall	PLED_DatWrite
	movlw	0x15
	rcall	PLED_DatWrite
	movlw	0x76
	rcall	PLED_CmdWrite
	movlw	0x13
	rcall	PLED_DatWrite
	movlw	0x0E
	rcall	PLED_DatWrite

	movlw	0x77
	rcall	PLED_CmdWrite
	movlw	0x1C
	rcall	PLED_DatWrite
	movlw	0x18
	rcall	PLED_DatWrite
	movlw	0x78
	rcall	PLED_CmdWrite
	movlw	0x15
	rcall	PLED_DatWrite
	movlw	0x0E
	rcall	PLED_DatWrite
	
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

