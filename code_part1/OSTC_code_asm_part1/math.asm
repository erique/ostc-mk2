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


; Math routines
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/30/05
; last updated: 06/21/07
; known bugs:
; ToDo: clean up!

convert_time:							; converts hi:lo in minutes to hours (hi) and minutes (lo)
	movff	lo,xA+0						; divide by 60...
	movff	hi,xA+1						; 
	movlw	d'60'						; 
	movwf	xB+0						; 
	clrf	xB+1						; 
	rcall	div16x16					; xA/xB=xC with xA as remainder
	movff	xC+0,hi						; Hours
	movff	xA+0,lo						; =remaining minutes (0.....59)
	return

div16:
; divA=divA/2^divB (divB: 8Bit only!)
	bcf		STATUS,C
	rrcf	divA+1
	rrcf	divA
	decfsz	divB
	bra		div16
	return

div32:
; xC=xC(32Bit)/2^divB (divB: 8Bit only!)
	bcf		STATUS,C
	rrcf	xC+3
	rrcf	xC+2
	rrcf	xC+1	
	rrcf	xC+0
	decfsz	divB
	bra		div32
	return

invert_xC:
	movf   xC+1, w 				; inverses xC+0:xC+1
	sublw  0xFF
	movwf  xC+1
	movf   xC+0, w 
	bcf		STATUS,C
	sublw  0xFF
	movwf  xC+0
	return	


sub16:
;  sub_c = sub_a - sub_b
	bcf		neg_flag
	movf   sub_b+0, w             	;  Get Value to be subtracted
	subwf  sub_a+0, w             	;  Do the High Byte
	movwf  sub_c+0
	movf   sub_b+1, w               ;  Get the Value to be Subbed
	subwfb sub_a+1, w
	movwf  sub_c+1
	btfss	STATUS,N
	return							; result positve
;  sub_c = sub_a - sub_b
	bsf		neg_flag				; result negative
	movff	sub_c+0,sub_b+0
	movff	sub_c+1,sub_b+1
	setf	sub_a
	setf	sub_a+1
	movf   sub_b+0, w             	;  Get Value to be subtracted
	subwf  sub_a+0, w             	;  Do the High Byte
	movwf  sub_c+0
	movf   sub_b+1, w               ;  Get the Value to be Subbed
	subwfb  sub_a+1, w
	movwf  	sub_c+1
    return        


mult16x16:
;xA*xB=xC
	clrf    xC+2        	  ;  Clear the High-Order Bits
	clrf    xC+3
	movf    xA, w               ;  Do the "L" Multiplication first
	mulwf   xB
	movf    PRODL, w            ;  Save result
	movwf   xC
	movf    PRODH, w
	movwf   xC+1
	movf    xA, w               ;  Do the "I" Multiplication
	mulwf   xB+1
	movf    PRODL, w            ;  Save the Most Significant Byte First
	addwf   xC+1, f
	movf    PRODH, w
	addwfc  xC+2, f    	 		 ;  Add to the Last Result
	movf    xA+1, w               ;  Do the "O" Multiplication
	mulwf   xB
	movf    PRODL, w            ;  Add the Lower Byte Next
	addwf   xC+1, f
	movf    PRODH, w            ;  Add the High Byte First
	addwfc  xC+2, f
	btfsc   STATUS, C           ;  Add the Carry
	incf    xC+3, f
	movf    xA+1, w               ;  Do the "F" Multiplication
	mulwf   xB+1
	movf    PRODL, w
	addwf   xC+2, f
	movf    PRODH, w
	addwfc  xC+3, f
	return


div16x16:						;xA/xB=xC with xA as remainder 	
								;uses divB as temp variable
		clrf	xC+0
		clrf	xC+1
        MOVF    xB+0,W       	; Check for zero
        IORWF   xB+1,W     		; 
        BTFSC   STATUS,Z        ; Check for zero
        RETLW   H'FF'           ; return 0xFF if illegal
        MOVLW   1               ; Start count at 1
        MOVWF   divB	       ; Clear Count
div16x16_1
    	BTFSC   xB+1,7     		; High bit set ?
        bra	    div16x16_2      ; Yes then continue
        INCF    divB,F     		; Increment count

		bcf		STATUS,C
		rlcf	xB+0,F
		rlcf	xB+1,F
        bra	    div16x16_1
div16x16_2:
								; Shift result left
		bcf		STATUS,C
		rlcf	xC+0,F
		rlcf	xC+1,F

 			; Reduce Divisor		

        MOVF    xB,W         ; Get low byte of subtrahend
        SUBWF   xA,F         ; Subtract DST(low) - SRC(low)
        MOVF    xB+1,W       ; Now get high byte of subtrahend
        BTFSS   STATUS,C     ; If there was a borrow, rather than
        INCF    xB+1,W       ; decrement high byte of dst we inc src
        SUBWF   xA+1,F       ; Subtract the high byte and we're done


        BTFSC   STATUS, C       ; Did it reduce?        
        bra	    div16x16_3      ; No, so it was less than

		movf	xB+0,W			; Reverse subtraction
		addwf	xA+0,F
		movf	xB+1,W
		addwfc	xA+1,F

        bra	    div16x16_4      ; Continue the process
div16x16_3:
	     BSF     xC+0,0        	; Yes it did, this gets a 1 bit
div16x16_4:
	     DECF    divB,F 		    ; Decrement N_COUNT
        BTFSC   STATUS,Z        ; If its not zero then continue
        return

		bcf		STATUS,C
		rrcf	xB+1,F
		rrcf	xB+0,F

        bra    div16x16_2              ; Next bit.

div32x16:  ; xC:4 / xB:2 = xC+3:xC+2 with xC+1:xC+0 as remainder
	; Setup
	movlw		.32		; setup shift counter
	movwf		divB
	movf		xC+3,W	; move ACCb to ACCf
	movwf		xA+1
	movf		xC+2,W
	movwf		xA+0
	movf		xC+1,W	; move ACCc to ACCe
	movwf		sub_a+1
	movf		xC+0,W
	movwf		sub_a+0
	clrf		xC+3
	clrf		xC+2
	clrf		xC+1
	clrf		xC+0
	clrf		sub_b+1
	clrf		sub_b+0
div32x16_2
	bcf			STATUS,C
	rlcf		sub_a+0,F
	rlcf		sub_a+1,F
	rlcf		xA+0,F
	rlcf		xA+1,F
	rlcf		sub_b+0,F
	rlcf		sub_b+1,F
	movf		xB+1,W
	subwf		sub_b+1,W	; check if a>d
	btfss		STATUS,Z
	goto		div32x16_3
	movf		xB+0,W
	subwf		sub_b+0,W	; if msb equal then check lsb
div32x16_3
	btfss		STATUS,C	; carry set if d>a
	goto		div32x16_4
	movf		xB+0,W	; d-a into d
	subwf		sub_b+0,F
	btfss		STATUS,C
	decf		sub_b+1,F
	movf		xB+1,W
	subwf		sub_b+1,F
	bsf			STATUS,C	; shift a 1 into b (result)
div32x16_4
	rlcf		xC+0,F
	rlcf		xC+1,F
	rlcf		xC+2,F
	rlcf		xC+3,F
	decfsz		divB,F	; loop until all bits checked
	goto		div32x16_2
	return

  
isr_div16:
; divA=divA/2^divB (divB: 8Bit only!)
	bcf		STATUS,C
	rrcf	isr_divA+1
	rrcf	isr_divA
	decfsz	isr_divB
	bra		isr_div16
	return

isr_div32:
; xC=xC(32Bit)/2^divB (divB: 8Bit only!)
	bcf		STATUS,C
	rrcf	isr_xC+3
	rrcf	isr_xC+2
	rrcf	isr_xC+1	
	rrcf	isr_xC+0
	decfsz	isr_divB
	bra		isr_div32
	return

isr_invert_xC:
	movf   isr_xC+1, w 				; inverses xC+0:xC+1
	sublw  0xFF
	movwf  isr_xC+1
	movf   isr_xC+0, w 
	bcf		STATUS,C
	sublw  0xFF
	movwf  isr_xC+0
	return	


isr_sub16:
;  sub_c = sub_a - sub_b
	bcf		neg_flag_isr
	movf   isr_sub_b+0, w             	;  Get Value to be subtracted
	subwf  isr_sub_a+0, w             	;  Do the High Byte
	movwf  isr_sub_c+0
	movf   isr_sub_b+1, w               ;  Get the Value to be Subbed
	subwfb isr_sub_a+1, w
	movwf  isr_sub_c+1
	btfss	STATUS,N
	return							; result positve
;  sub_c = sub_a - sub_b
	bsf		neg_flag_isr				; result negative
	movff	isr_sub_c+0,isr_sub_b+0
	movff	isr_sub_c+1,isr_sub_b+1
	setf	isr_sub_a
	setf	isr_sub_a+1
	movf   isr_sub_b+0, w             	;  Get Value to be subtracted
	subwf  isr_sub_a+0, w             	;  Do the High Byte
	movwf  isr_sub_c+0
	movf   isr_sub_b+1, w               ;  Get the Value to be Subbed
	subwfb  isr_sub_a+1, w
	movwf  	isr_sub_c+1
    return        


isr_mult16x16:
;xA*xB=xC
	clrf    isr_xC+2        	  ;  Clear the High-Order Bits
	clrf    isr_xC+3
	movf    isr_xA, w               ;  Do the "L" Multiplication first
	mulwf   isr_xB
	movf    PRODL, w            ;  Save result
	movwf   isr_xC
	movf    PRODH, w
	movwf   isr_xC+1
	movf    isr_xA, w               ;  Do the "I" Multiplication
	mulwf   isr_xB+1
	movf    PRODL, w            ;  Save the Most Significant Byte First
	addwf   isr_xC+1, f
	movf    PRODH, w
	addwfc  isr_xC+2, f    	 		 ;  Add to the Last Result
	movf    isr_xA+1, w               ;  Do the "O" Multiplication
	mulwf   isr_xB
	movf    PRODL, w            ;  Add the Lower Byte Next
	addwf   isr_xC+1, f
	movf    PRODH, w            ;  Add the High Byte First
	addwfc  isr_xC+2, f
	btfsc   STATUS, C           ;  Add the Carry
	incf    isr_xC+3, f
	movf    isr_xA+1, w               ;  Do the "F" Multiplication
	mulwf   isr_xB+1
	movf    PRODL, w
	addwf   isr_xC+2, f
	movf    PRODH, w
	addwfc  isr_xC+3, f
	return
       