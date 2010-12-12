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


; Customviews for divemode
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 101212
; last updated: 101212
; known bugs:
; ToDo:

customview_menu_entry3:		; Show the customview-dependent entry for the divemode menu
	bcf		menu3_active	;=1: menu entry three in divemode menu is active
	movff	menupos3,temp1		; copy
	dcfsnz	temp1,F
	bra		customview_menu3_stopwatch		; Show the stopwatch option in divemode menu
	dcfsnz	temp1,F
	bra		customview_menu3_marker			; Show the marker option in divemode menu
	dcfsnz	temp1,F
	bra		customview_menu3_clock			; Show the clock option in divemode menu
	dcfsnz	temp1,F
	bra		customview_menu3_lead_tiss		; Show the leading tissue option in divemode menu
	; Menupos3=0, do nothing
	return

customview_menu3_stopwatch:
	bsf		menu3_active			; Set Flag
	DISPLAYTEXT	.33					; ResetAvr
	return

customview_menu3_marker:
	bsf		menu3_active			; Set Flag
	DISPLAYTEXT	.30					; Set Marker
	return

customview_menu3_clock:				; No menu entry
customview_menu3_lead_tiss			; No menu entry
	return

customview_second:		; Do every-second tasks for the custom view area
	movff	menupos3,temp1		; copy
	dcfsnz	temp1,F
	bra		customview_1sec_stopwatch		; Update the Stopwatch
	dcfsnz	temp1,F
	bra		customview_1sec_marker			; Update the Marker
	dcfsnz	temp1,F
	bra		customview_1sec_clock			; Update the Clock
	dcfsnz	temp1,F
	bra		customview_1sec_lead_tiss		; Update the leading tissue
	; Menupos3=0, do nothing
	return
	
customview_1sec_stopwatch:
	call	PLED_stopwatch_show2	; Update figures only
	return

customview_1sec_marker:				; Do nothing extra
	return

customview_1sec_lead_tiss:			; Do nothing extra
	return

customview_1sec_clock:
;	call	PLED_diveclock2
	return


customview_minute:		; Do every-minute tasks for the custom view area
	movff	menupos3,temp1		; copy
	dcfsnz	temp1,F
	bra		customview_minute_stopwatch		; Update the Stopwatch
	dcfsnz	temp1,F
	bra		customview_minute_marker		; Update the Marker
	dcfsnz	temp1,F
	bra		customview_minute_clock			; Update the Clock
	dcfsnz	temp1,F
	bra		customview_minute_lead_tiss		; Update the leading tissue
	; Menupos3=0, do nothing
	return

customview_minute_clock:
	call	PLED_diveclock2			; Update the clock
	return

customview_minute_lead_tiss:
	call	PLED_show_leading_tissue_2 ; Update the leading tissue
	return

customview_minute_marker:			; Do nothing extra
customview_minute_stopwatch:		; Do nothing extra
	return


customview_toggle:		; Yes, show next customview (and delete this flag)
	incf	menupos3,F			; Number of customview to show
	movlw	d'5'				; Max number+1
	cpfseq	menupos3			; Max reached?
	bra		customview_mask		; No, show
	clrf	menupos3			; Reset to zero (Zero=no custom view)
customview_mask:	
	call	PLED_clear_customview_divemode
	movff	menupos3,temp1		; Menupos3 holds number of customview function
	dcfsnz	temp1,F
	bra		customview_init_stopwatch		; Show the Stopwatch
	dcfsnz	temp1,F
	bra		customview_init_marker			; Show the Marker-Menu
	dcfsnz	temp1,F
	bra		customview_init_clock			; Show the clock
	dcfsnz	temp1,F
	bra		customview_init_lead_tissue		; Show the leading tissue
;	bra		customview_init_nocustomview	; menupos3=0 -> No Customview
customview_init_nocustomview:
	bra		customview_toggle_exit	

customview_init_stopwatch:
; Init Stopwatch
	call	PLED_stopwatch_show
	bra		customview_toggle_exit	

customview_init_marker:
; Init Marker 
	DISPLAYTEXT		d'151'					; Set Marker?
	bra		customview_toggle_exit	

customview_init_clock:
; Init Clock
	call	PLED_diveclock
	bra		customview_toggle_exit	

customview_init_lead_tissue:
; Show leading tissue
	call	PLED_show_leading_tissue
	bra		customview_toggle_exit	

customview_toggle_exit:
	bcf		toggle_customview	; Clear flag
	return