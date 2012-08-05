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
; History:
; 2009-08-30: [MH] last updated.
; 2011-01-07: [jDG] Added flip_screen option
; known bugs: pixel-write (loogbok curves) not done yet...
; ToDo:

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

;=============================================================================

word_processor:						; word_processor:
    clrf	POSTINC2				; Required, to mark end of string.
    call	aa_wordprocessor
    movlb	b'00000001'				; Back to Rambank1
    return

;=============================================================================
; Macro to provides our own interface code.
;
PIXEL_WRITE macro   colRegister, rowRegister
        movff   colRegister,win_leftx2
        movff   rowRegister,win_top
        call    pixel_write
        endm

INIT_PIXEL_WROTE macro colRegister
        movff   colRegister,win_leftx2
        call    init_pixel_write
        endm

HALF_PIXEL_WRITE macro rowRegister
        movff   rowRegister,win_top
        call    half_pixel_write
        endm

;-----------------------------------------------------------------------------
; Init for half_pixel_write
; Set column register on OLED device, and current color.
; Inputs: win_leftx2
; Outputs: win_color:2
; Trashed: WREG, PROD
init_pixel_write:
        movff   win_leftx2,WREG
        mullw   2
        rcall   pixel_write_col320      ; Start Address Vertical (.0 - .319)
        goto    PLED_standard_color
    
;-----------------------------------------------------------------------------
; Writes two half-pixels at position (win_top,win_leftx2)
; Inputs: win_leftx2, win_top, win_color:2
; Trashed: WREG, PROD
pixel_write:
        movff   win_leftx2,WREG
        mullw   2
        rcall   pixel_write_col320      ; Start Address Vertical (.0 - .319)
        rcall   half_pixel_write        ; Write this half-one.

        movff   win_leftx2,WREG         ; Address of next one
        mullw   2
        infsnz  PRODL                   ; +1
        incf    PRODH
    	rcall   pixel_write_col320
    	bra     half_pixel_write        ; Note: Cmd 0x20 is mandatory, because
    	                                ; of the autoincrement going vertical

        ;---- Do the 16bit 319-X-->X, if needed, and send to OLED ------------
pixel_write_col320:
        movff   win_flags,WREG          ; BEWARE: bank0 bit-test
        btfss   WREG,0                  ; 180° rotation ?
        bra     pixel_write_noflip_H

        movf    PRODL,W                 ; 16bits 319 - PROD --> PROD
        sublw   LOW(.319)               ; 319-W --> W
        movwf   PRODL
        movf    PRODH,W
        btfss   STATUS,C                ; Borrow = /CARRY
        incf    WREG
        sublw   HIGH(.319)
        movwf   PRODH

pixel_write_noflip_H:
    	movlw	0x21				    ; Start Address Vertical (.0 - .319)
    	rcall	PLED_CmdWrite
    	bra     PLED_DataWrite_PROD   

;-----------------------------------------------------------------------------
; Writes a vertical line of half-pixel at position (win_top,win_leftx2,win_height).
; Inputs: win_leftx2, win_top, win_height, win_color:2
; Trashed: WREG, PROD, TABLAT, TBLPTRL
half_vertical_line:
        clrf    TABLAT                  ; Loop index.

half_vertical_line_loop:
        movff   win_leftx2,WREG         ; Init X position.
        mullw   2
        movf    TABLAT,W                ; Get loop index
        andlw   1                       ; Just low bit
        xorwf   PRODL,F                 ; And use it to jitter current X position
        rcall   pixel_write_col320      ; Start Address Vertical (.0 - .319)

        movff   win_height,WREG         ; Index reached height (Bank0 read) ?
        xorwf   TABLAT,W
        btfsc   STATUS,Z                ; Equals ?
        return                          ; Yes: done.
        movff   win_top,WREG            ; Y = top + index (Bank0 read)
        addwf   TABLAT,W
        rcall   half_pixel_write_1
        incf    TABLAT,F                ; index++
        bra     half_vertical_line_loop

;-----------------------------------------------------------------------------
; Writes one half-pixel at position (win_top,win_leftx2).
; Inputs: win_leftx2, win_top, win_color:2
; Trashed: WREG, PROD
half_pixel_write:
    	movff  	win_top,WREG            ; d'0' ... d'239'

; Variant with Y position in WREG.
half_pixel_write_1:
        movff   win_flags,PRODL         ; BEWARE: bank0 bit-test
    	btfsc   PRODL,0                 ; 180° rotation ?
    	sublw   .239                    ; 239-Y --> Y

    	mullw   1                       ; Copy row to PRODH:L
    	movlw	0x20			        ; Horizontal Address START:END
    	rcall	PLED_CmdWrite
    	rcall   PLED_DataWrite_PROD
    
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
; Fast macros to write to OLED display.
; Adding a call/return adds 3 words and a pipeline flush, hence make it
; nearly twice slower...
;
; Input	 : commande as macro parameter.
; Output : NONE
; Trash  : WREG
;
AA_CMD_WRITE macro cmd
		movlw	cmd
;		rcall   PLED_CmdWrite			; slow but saves a lot of bytes in flash
	; /* Fast writing
		bcf		oled_rs				    ; Cmd mode
		movwf	PORTD,A
		bcf		oled_rw				    ; Tick the clock
		bsf		oled_rw
	; Fast writing */
		endm
;
; Input	 : data as macro parameter.
; Output : NONE
; Trash  : WREG
;
AA_DATA_WRITE macro data
        movlw   data
        rcall   PLED_DataWrite
        endm
;
; Input	 : PRODH:L as 16bits data.
; Output : NONE
; Trash  : NONE
;
AA_DATA_WRITE_PROD	macro
;       rcall   PLED_DataWrite_PROD	; slow but saves a lot of bytes in flash
	; /* Fast writing
		bsf		oled_rs				    ; Data mode
		movff	PRODH,PORTD			    ; NOTE: OLED is BIGENDIAN!
		bcf		oled_rw				    ; Tick the clock
		bsf		oled_rw
		movff	PRODL,PORTD
		bcf		oled_rw				    ; Tick the clock
		bsf		oled_rw
	; Fast writing */
		endm

;=============================================================================
; Output OLED Window Address commands.
; Inputs : win_top, win_leftx2, win_height, aa_width.
; Output : PortD commands.
; Trashed: PROD
;
PLED_box_write:
		movff	win_leftx2,WREG         ; Compute left = 2*leftx2 --> PROD
		mullw	2

        movff   win_flags,WREG          ; BEWARE: bank0 bit-test
    	btfsc   WREG,0                  ; 180° rotation ?
    	bra     PLED_box_flip_H         ; YES: 

        ;---- Normal horizontal window ---------------------------------------
        ; Output 0x35 left,
        ;        0x36 right ==  left + width - 1.
		AA_CMD_WRITE	0x35		    ; this is the left border
		AA_DATA_WRITE_PROD              ; Output left
		AA_CMD_WRITE	0x21            ; Also the horizontal first pix coord.
		AA_DATA_WRITE_PROD
		
		movf	aa_width+0,W,ACCESS	    ; right = left + width - 1
		addwf	PRODL,F
		movf	aa_width+1,W,ACCESS
		addwfc	PRODH,F
		decf	PRODL,F,A			    ; decrement result
		btfss   STATUS,C
		decf	PRODH,F,A

		AA_CMD_WRITE	0x36		    ; Write and the right border
		AA_DATA_WRITE_PROD

		bra     PLED_box_noflip_H

        ;---- Flipped horizontal window --------------------------------------
PLED_box_flip_H:
        ; Output 0x36 flipped(left)  = 319-left
        ;        0x35 flipped(right) = 319-right = 320 - left - width
        movf    PRODL,W                 ; 16bits 319 - PROD --> PROD
        sublw   LOW(.319)               ; 319-W --> W
        movwf   PRODL
        movf    PRODH,W
        btfss   STATUS,C                ; Borrow = /CARRY
        incf    WREG
        sublw   HIGH(.319)
        movwf   PRODH
		AA_CMD_WRITE	0x36		    ; this is the left border
		AA_DATA_WRITE_PROD              ; Output left
		AA_CMD_WRITE	0x21
		AA_DATA_WRITE_PROD

        movf    aa_width+0,W            ; 16bits PROD - width --> PROD
        subwf   PRODL,F                 ; PRODL - WREG --> PRODL
        movf    aa_width+1,W
        subwfb  PRODH,F
        infsnz  PRODL                   ; PROD+1 --> PROD
        incf    PRODH
		AA_CMD_WRITE	0x35		    ; this is the left border
		AA_DATA_WRITE_PROD              ; Output left

PLED_box_noflip_H:
        movff   win_flags,WREG          ; BEWARE: bank0 bit-test
    	btfsc   WREG,0                  ; 180° rotation ?
    	bra     PLED_box_flip_V

        ;---- Normal vertical window -----------------------------------------
        ; Output 0x37 (top) (bottom)
		movff	win_top,PRODH           ; top --> PRODH (first byte)
		movff   win_height,WREG
		addwf   PRODH,W
		decf	WREG
		movwf	PRODL                   ; top+height-1 --> PRODL (second byte)

		AA_CMD_WRITE	0x37
		AA_DATA_WRITE_PROD

        movff   PRODH,PRODL
        clrf    PRODH                   ; Start pixel V coord == top.
		AA_CMD_WRITE	0x20
		AA_DATA_WRITE_PROD

		return

        ;---- Flipped vertical window ----------------------------------------
        ; Output 0x37 flipped(bottom) = 239-bottom = 240 - top - height
        ;             flipped(top)    = 239-top
PLED_box_flip_V:
		movff   win_top,PRODL
		movff   win_height,WREG
		addwf   PRODL,W
		sublw   .240                    ; 240 - top - height
		movwf   PRODH                   ; First byte

		movf	PRODL,W
		sublw   .239                    ; 249-top
		movwf   PRODL                   ; --> second byte.

		AA_CMD_WRITE	0x37
		AA_DATA_WRITE_PROD

        clrf    PRODH                   ; Start pixel V coord.
		AA_CMD_WRITE	0x20
		AA_DATA_WRITE_PROD

		return

;=============================================================================
; PLED_frame : draw a frame around current box with current color.
; Inputs:  win_top, win_leftx2, win_height, win_width, win_color1, win_color2
; Outputs: (none)
; Trashed: WREG, PROD, aa_start:2, aa_end:2, win_leftx2, win_width:1
    global  PLED_frame
PLED_frame:
    movff   win_top,aa_start+0          ; Backup everything.
    movff   win_height,aa_start+1
    movff   win_leftx2,aa_end+0
    movff   win_width,aa_end+1

    ;---- TOP line -----------------------------------------------------------
    movlw   1                           ; row ~ height=1
    movff   WREG,win_height
    rcall   PLED_box

    ;---- BOTTOM line --------------------------------------------------------
    movff   aa_start+0,PRODL             ; Get back top,
    movff   aa_start+1,WREG              ; and height
    addwf   PRODL,W                      ; top+height
    decf    WREG                         ; top+height-1
    movff   WREG,win_top                 ; top+height-1 --> top
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

    global  PLED_box
PLED_box:
    ;---- Define Window ------------------------------------------------------
	movff	win_width,WREG
	bcf     STATUS,C
	rlcf    WREG
	movwf   aa_width+0
	movlw   0
	rlcf    WREG
	movwf   aa_width+1
	rcall   PLED_box_write

    ;---- Fill Window --------------------------------------------------------
	movlw	0x22                        ; Start Writing Data to GRAM
	rcall	PLED_CmdWrite

	clrf	PRODH                       ; Column counter.
	bsf		oled_rs                     ; Data!

PLED_box2:                              ; Loop height times
	movff	win_height,PRODL
    
PLED_box3:                              ; loop width times
	movff	win_color1,PORTD
	bcf		oled_rw
	bsf		oled_rw                     ; Upper
	movff	win_color2,PORTD
	bcf		oled_rw
	bsf		oled_rw                     ; Lower

	movff	win_color1,PORTD
	bcf		oled_rw
	bsf		oled_rw                     ; Upper
	movff	win_color2,PORTD
	bcf		oled_rw
	bsf		oled_rw                     ; Lower

	decfsz	PRODL,F                     ; row loop finished ?
	bra		PLED_box3                   ; No: continue.

    incf    PRODH,F                     ; column count ++

    movff   win_bargraph,WREG           ; current column == bargraph ?
    cpfseq  PRODH
    bra     PLED_box4                   ; No: just loop.

    clrf    WREG                        ; Yes: switch to black
    movff   WREG,win_color1
    movff   WREG,win_color2
PLED_box4:
    movff   win_width,WREG
    cpfseq  PRODH
    bra     PLED_box2

	movlw	0x00                        ; NOP, to stop window mode
	rcall   PLED_CmdWrite
	
	setf    WREG                        ; Reset bargraph mode...
	movff   WREG,win_bargraph
	return

;=============================================================================
; PLED_ClearScreen: An optimized version of PLEX_box, for full screen black.
; Trashed: WREG, PROD

    global  PLED_ClearScreen
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

	movlw	0x22                ; Start Writing Data to GRAM
	rcall	PLED_CmdWrite

	; See Page 101 of OLED Driver IC Datasheet how to handle rs/rw clocks
	bsf		oled_rs             ; Data!

	movlw	.160
	movwf	PRODH
PLED_ClearScreen2:
	movlw	.240
	movwf	PRODL
PLED_ClearScreen3:

	clrf	PORTD               ; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw             ; Upper

    clrf	PORTD               ; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw             ; Lower

	clrf	PORTD               ; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw             ; Upper

    clrf	PORTD               ; Need to generate trace here too.
	bcf		oled_rw
	bsf		oled_rw             ; Lower

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
; PLED Read data into WREG
; -----------------------------
; NOTE: you should "setf TRISD" before calling this function,
;       to make PortD an input port...
PLED_DataRead:
	bsf		oled_rs					; Data register.
	bcf		oled_e_nwr              ; Read enable.
	nop
	nop
	nop
	nop
	movf	PORTD,W				    ; Read byte.
	bsf		oled_e_nwr              ; release bus.
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
	movlw	0x00				; CLS MDT1 MDT0 	BGR 	X  	X  	X  	SS  65k Color
	rcall	PLED_DataWrite

	; Change direction for block-writes of pixels
    lfsr    FSR0,win_flags
	btfss   INDF0,0             ; BANK-SAFE bit test.
	movlw	b'00110000'			; [normal]  X  	X 	 I/D1 	I/D0 	X  	X  	X 	AM
	btfsc   INDF0,0
    movlw   b'00000000'         ; [flipped] X  	X 	 I/D1 	I/D0 	X  	X  	X 	AM
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
	bsf		oled_hv
	WAITMS	d'32'
	bsf		oled_hv

	movlw	0x05
	rcall	PLED_CmdWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x01
	rcall	PLED_DataWrite			; Display ON
	return


PLED_brightness_full: ; Choose between Eco and High...
	btfsc	oled_brightness_high		; OLED brightness (=0: Eco, =1: High)
	bra		PLED_brightness_full_high
; Mid
	movlw	0x70
	rcall	PLED_CmdWrite
	movlw	0x1B
	rcall	PLED_DataWrite
	movlw	0x80
	rcall	PLED_DataWrite
	movlw	0x71
	rcall	PLED_CmdWrite
	movlw	0x1F
	rcall	PLED_DataWrite
	movlw	0x00
	rcall	PLED_DataWrite
	movlw	0x72
	rcall	PLED_CmdWrite
	movlw	0x22
	rcall	PLED_DataWrite
	movlw	0x00
	rcall	PLED_DataWrite

	movlw	0x73
	rcall	PLED_CmdWrite
	movlw	0x17
	rcall	PLED_DataWrite
	movlw	0x11
	rcall	PLED_DataWrite
	movlw	0x74
	rcall	PLED_CmdWrite
	movlw	0x1A
	rcall	PLED_DataWrite
	movlw	0x0E
	rcall	PLED_DataWrite

	movlw	0x75
	rcall	PLED_CmdWrite
	movlw	0x1D
	rcall	PLED_DataWrite
	movlw	0x15
	rcall	PLED_DataWrite
	movlw	0x76
	rcall	PLED_CmdWrite
	movlw	0x18
	rcall	PLED_DataWrite
	movlw	0x11
	rcall	PLED_DataWrite

	movlw	0x77
	rcall	PLED_CmdWrite
	movlw	0x1E
	rcall	PLED_DataWrite
	movlw	0x18
	rcall	PLED_DataWrite
	movlw	0x78
	rcall	PLED_CmdWrite
	movlw	0x1D
	rcall	PLED_DataWrite
	movlw	0x11
	rcall	PLED_DataWrite
	return

PLED_brightness_full_high:
; Full
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
;Low
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

PLED_set_color:;Converts 8Bit RGB b'RRRGGGBB' into 16Bit RGB b'RRRRRGGG GGGBBBBB'
	movwf	oled1_temp				; Get 8Bit RGB b'RRRGGGBB'
	movwf	oled2_temp				; Copy

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

	