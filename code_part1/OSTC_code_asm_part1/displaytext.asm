; OSTC - diving computer code
; Copyright (C) 2008 HeinrichsWeikamp GbR

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


; Displays from text_table_vx.asm
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/30/05
; last updated: 100730
; known bugs:
; ToDo:


; These macros output to POSTINC only
OUTPUTTEXT	macro	textnumber 		; For Texts 1-254
	movlw	textnumber
	call	displaytext0
	endm

OUTPUTTEXTH	macro	textnumber		; For Texts 255-511
	movlw	LOW	textnumber			; Use only Lower 8 Bit
	call	displaytext0_h
	endm

displaytext0_h:
	bsf		displaytext_high		; Highbit set
	rcall	displaytext0
	return
	
displaytext0:
	bsf		output_to_postinc_only
	rcall	displaytext1
	bcf		output_to_postinc_only
	return

; These macros output to POSTINC and call the wordprocessor
DISPLAYTEXT	macro	textnumber
	movlw	textnumber
	call	displaytext1
	endm

DISPLAYTEXTH	macro	textnumber
	movlw	LOW	textnumber			; Use only Lower 8 Bit
	call	displaytext1h
	endm

displaytext1h:
	bsf		displaytext_high		; Highbit set
	rcall	displaytext1
	return

displaytext1:
	movwf	textnumber
	movlw	b'10000000'
	movwf	EECON1

	clrf	TBLPTRU
	movlw	textpos_pointer_high
	movwf	TBLPTRH
	movlw	textpos_pointer_low			; base address -4 for position table
	movwf	TBLPTRL

	movff	textnumber,xA+0
	movlw	d'0'
	btfsc	displaytext_high		; Highbit set?
	movlw	d'1'					; Yes!
	movwf	xA+1					; Set High Bit

	bcf		STATUS,C
	rlcf	xA+0,F
	rlcf	xA+1,F					; times 2 for adress

	movlw	d'2'
	addwf	xA+0,F
	movlw	d'0'
	addwfc	xA+1,F					; + 2

	movf	xA+0,W
	addwf	TBLPTRL,F				; set adress, data can be read
	movf	xA+1,W
	addwfc	TBLPTRH,F				; High byte, if required

	TBLRD*+
	btfss	output_to_postinc_only		; output to postinc only?
	movff	TABLAT,win_leftx2			; No, write coordinates

	TBLRD*+
	btfss	output_to_postinc_only	; output to postinc only?
	movff	TABLAT,win_top			; No, write coordinates

	movlw	d'0'
	movff	WREG,win_font			; Bank0 Variable...

	clrf	textaddress+0
	clrf	textaddress+1
	clrf	TBLPTRH					; Set Pointer for textlength table
	clrf	TBLPTRU
	movlw	textlength_pointer_low
	movwf	TBLPTRL
	bra		displaytext1b

displaytext1a:	
	bcf		displaytext_high		; Clear flag
									; Get textadress from textlength table
displaytext1b:	
	TBLRD*+
	movf	TABLAT,W
	addwf	textaddress+0,F
	movlw	d'0'
	addwfc	textaddress+1,F
	decfsz	textnumber,F
	bra		displaytext1b
	
	btfsc	displaytext_high		; Highbit set?
	bra		displaytext1a			; Yes, add 256 loops

displaytext2:						; copies text to wordprocessor
	clrf	TBLPTRU
	movlw	text_pointer_low
	addwf	textaddress+0,W
	movwf	TBLPTRL
	movlw	text_pointer_high		; Base address Texts
	addwfc	textaddress+1,W
	movwf	TBLPTRH

	btfss	output_to_postinc_only		; output to postinc2 only?
	lfsr	FSR2,letter					; no!

displaytext2a:
	TBLRD*+
	movlw	'}'						; Text finished?
	cpfseq	TABLAT
	bra		displaytext3
	bra		display_text_exit

displaytext3:
	movff	TABLAT,POSTINC2

	TBLRD*+
	movlw	'}'						; Text finished?
	cpfseq	TABLAT
	bra		displaytext4
	bra		display_text_exit
displaytext4:
	movff	TABLAT,POSTINC2
	bra		displaytext2a

display_text_exit:
	btfss	output_to_postinc_only		; output to postinc only?
	call	word_processor
	return
