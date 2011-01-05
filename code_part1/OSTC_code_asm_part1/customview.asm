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
; history:
;   2010-12-12: [MH] last updated
;   2011-01-04: [jDG] Saturation graphs in customview divemode
; known bugs:
; ToDo:

;=============================================================================
; Show the customview-dependent entry for the divemode menu
;
customview_menu_entry3:		
	bcf		menu3_active	;=1: menu entry three in divemode menu is active

	movff	menupos3,WREG	            ; copy
	dcfsnz	WREG,F
	bra		customview_menu3_stopwatch  ; Show the stopwatch option in divemode menu
	dcfsnz	WREG,F
	bra		customview_menu3_marker     ; Show the marker option in divemode menu
	dcfsnz	WREG,F
	bra		customview_menu3_clock      ; Show the clock option in divemode menu
	dcfsnz	WREG,F
	bra		customview_menu3_lead_tiss  ; Show the leading tissue option in divemode menu
	; Menupos3=0, do nothing
	return

customview_menu3_stopwatch:
	bsf		menu3_active                ; Set Flag
	DISPLAYTEXT	.33                     ; ResetAvr
	return

customview_menu3_marker:
	bsf		menu3_active                ; Set Flag
	DISPLAYTEXT	.30                     ; Set Marker
	return

customview_menu3_clock:                 ; No menu entry
customview_menu3_lead_tiss              ; No menu entry
	return

;=============================================================================
; Do every-second tasks for the custom view area

customview_second:                      
	movff	menupos3,WREG               ; copy
	dcfsnz	WREG,F
	bra		customview_1sec_stopwatch   ; Update the Stopwatch
	dcfsnz	WREG,F
	bra		customview_1sec_marker      ; Update the Marker
	dcfsnz	WREG,F
	bra		customview_1sec_clock       ; Update the Clock
	dcfsnz	WREG,F
	bra		customview_1sec_lead_tiss   ; Update the leading tissue
	dcfsnz	WREG,F
	bra		customview_1sec_average     ; Update the Average depth
	dcfsnz	WREG,F
	bra		customview_1sec_graphs      ; Update the leading tissue
	; Menupos3=0, do nothing
	return

customview_1sec_average:
	call	PLED_total_average_show2	; Update the figures only
	return
	
customview_1sec_stopwatch:
	call	PLED_stopwatch_show2        ; Update figures only
	return

customview_1sec_marker:                 ; Do nothing extra
customview_1sec_clock:                  ; Do nothing extra
customview_1sec_lead_tiss:              ; Do nothing extra
	return

customview_1sec_graphs:                 ; Do nothing extra
	return

;=============================================================================
; Do every-minute tasks for the custom view area

customview_minute:
	movff	menupos3,WREG               ; copy
	dcfsnz	WREG,F
	bra		customview_minute_stopwatch ; Update the Stopwatch
	dcfsnz	WREG,F
	bra		customview_minute_marker    ; Update the Marker
	dcfsnz	WREG,F
	bra		customview_minute_clock     ; Update the Clock
	dcfsnz	WREG,F
	bra		customview_minute_lead_tiss ; Update the leading tissue
	dcfsnz	WREG,F
	bra		customview_minute_average		; Update the Average depth
	dcfsnz	WREG,F
	bra		customview_minute_graphs	; Update the graphs
	; Menupos3=0, do nothing
	return

customview_minute_clock:
	call	PLED_diveclock2             ; Update the clock
	return

customview_minute_lead_tiss:
	call	PLED_show_leading_tissue_2  ; Update the leading tissue
	return

customview_minute_graphs:
	call	deco_calc_desaturation_time	; calculate desaturation time
	movlb	b'00000001'						; select ram bank 1
	call	PLED_tissue_saturation_graph
	return

customview_minute_marker:               ; Do nothing extra
customview_minute_stopwatch:            ; Do nothing extra
customview_minute_average:			; Do nothing extra
	return

;=============================================================================
; Yes, show next customview (and delete this flag)

customview_toggle:		
	ostc_debug	'X'		; Sends debug-information to screen if debugmode active
	incf	menupos3,F			            ; Number of customview to show
	movlw	d'6'				; Max number
	cpfsgt	menupos3			            ; Max reached?
	bra		customview_mask		            ; No, show
	clrf	menupos3			            ; Reset to zero (Zero=no custom view)
customview_mask:	
	call	PLED_clear_customview_divemode
	movff	menupos3,WREG                   ; Menupos3 holds number of customview function
	dcfsnz	WREG,F
	bra		customview_init_stopwatch		; Show the Stopwatch
	dcfsnz	WREG,F
	bra		customview_init_marker			; Show the Marker-Menu
	dcfsnz	WREG,F
	bra		customview_init_clock			; Show the clock
	dcfsnz	WREG,F
	bra		customview_init_lead_tissue		; Show the leading tissue
	dcfsnz	WREG,F
	bra		customview_init_average			; Show Total average depth
	dcfsnz	WREG,F
	bra		customview_init_graphs		    ; Show the graphs

customview_init_nocustomview:
	bra		customview_toggle_exit	

customview_init_average:
	call	PLED_total_average_show		; Show Average with mask
	bra		customview_toggle_exit	

customview_init_stopwatch:
	GETCUSTOM8	d'51'					; Show Stopwatch? (=1 in WREG)
	decfsz		WREG,F					; WREG=1?	
	bra			customview_toggle		; No, use next Customview

	call	PLED_stopwatch_show			; Init Stopwatch display
	bra		customview_toggle_exit	

customview_init_marker:					; Init Marker
	GETCUSTOM8	d'50'					; Show Marker? (=1 in WREG)
	decfsz		WREG,F					; WREG=1?	
	bra			customview_toggle		; No, use next Customview

    call    PLED_standard_color
	DISPLAYTEXT		d'151'				; Set Marker?
	bra		customview_toggle_exit	

customview_init_clock:					; Init Clock
	call	PLED_diveclock
	bra		customview_toggle_exit	

customview_init_lead_tissue:			; Show leading tissue
	GETCUSTOM8	d'53'					; Show Lead Tissue? (=1 in WREG)
	decfsz		WREG,F					; WREG=1?	
	bra			customview_toggle		; No, use next Customview

	call	PLED_show_leading_tissue
	bra		customview_toggle_exit	

customview_init_graphs:					; Show tissue graph
 	GETCUSTOM8	d'52'					; Show Tissue Graph? (=1 in WREG)
	decfsz		WREG,F					; WREG=1?	
	bra			customview_toggle		; No, use next Customview

	call	deco_calc_desaturation_time	; calculate desaturation time
	movlb	b'00000001'						; select ram bank 1
	call    PLED_tissue_saturation_graph
	bra     customview_toggle_exit	
customview_toggle_exit:
	bcf		toggle_customview			; Clear flag
	ostc_debug	'Y'		                ; Sends debug-information to screen in debugmode
	return

;=============================================================================
; Yes, show next customview (and delete this flag)

surfcustomview_toggle:
	incf	menupos3,F			; Number of customview to show
	movlw	d'4'				; Max number
	cpfsgt	menupos3			; Max reached?
	bra		surfcustomview_mask	; No, show
	clrf	menupos3			; Reset to zero (Zero=no custom view)
surfcustomview_mask:	
	call	PLED_clear_customview_surfmode
	movff	menupos3,WREG       ; Menupos3 holds number of customview function
	dcfsnz	WREG,F
	bra		surfcustomview_init_graphs			; Show the tissue graphs
	dcfsnz	WREG,F
	bra		surfcustomview_init_gaslist			; Show pre-dive gaslist/setpoint list
	dcfsnz	WREG,F
	bra		surfcustomview_init_interval; Show the interval counter
	dcfsnz	WREG,F
	bra		surfcustomview_init_cfview			; Show the interval counter

surfcustomview_init_nocustomview:
	bra		surfcustomview_toggle_exit	

surfcustomview_init_graphs:
	call	PLED_tissue_saturation_graph; Draw the graphs
	bra		surfcustomview_toggle_exit	

surfcustomview_init_gaslist:
	call	PLED_pre_dive_screen				; Show the Gaslist/Setpoint list
	bra		surfcustomview_toggle_exit	

surfcustomview_init_interval:
	call    PLED_standard_color
	DISPLAYTEXT	d'189'							; Surface
	DISPLAYTEXT	d'240'							; Interval:
	call	PLED_interval						; Display the interval
	bra		surfcustomview_toggle_exit	

surfcustomview_init_cfview:
	read_int_eeprom		d'34'					; Get Decomode
	incf	EEDATA,W							; +1 -> WREG
	movwf	temp10
	dcfsnz	temp10,F
	call	PLED_show_cf11_cf12_cf29			; =0 (ZH-L16 OC)
	dcfsnz	temp10,F
	bra		surfcustomview_toggle_exit			; =1 (Gauge)
	dcfsnz	temp10,F
	call	PLED_show_cf11_cf12_cf29			; =2 (ZH-L16 CC)
	dcfsnz	temp10,F
	bra		surfcustomview_toggle_exit			; =3 (Apnoe)
	dcfsnz	temp10,F
	call	PLED_show_cf32_cf33_cf29			; =4 (L16-GF OC)
	dcfsnz	temp10,F
	call	PLED_show_cf32_cf33_cf29			; =5 (L16-GF CC)
	bra		surfcustomview_toggle_exit	

surfcustomview_toggle_exit:
	bcf		toggle_customview			; Clear flag
	clrf	timeout_counter2			; Clear timeout
	return

;=============================================================================
; Do every-second tasks for the custom view area

surfcustomview_second:
;	movff	menupos3,WREG               ; copy
;	dcfsnz	WREG,F
;	bra		surfcustomview_1sec_graphs		; Update the Graphs
;	dcfsnz	WREG,F
;	bra		surfcustomview_1sec_gaslist		; Update the Gaslist/SetPoint List
;	dcfsnz	WREG,F
;	bra		surfcustomview_1sec_interval	; Update the Interval display
;	dcfsnz	WREG,F
;	bra		surfcustomview_1sec_cfview		; Update the critical cf view
;	; Menupos3=0, do nothing
;	return
;surfcustomview_1sec_cfview:				; Do nothing extra
;surfcustomview_1sec_graphs:				; Do nothing extra
;surfcustomview_1sec_gaslist:			; Do nothing extra
;surfcustomview_1sec_interval:			; Do nothing extra
	return

;=============================================================================

surfcustomview_minute:		; Do every-minute tasks for the custom view area
	movff	menupos3,WREG               ; copy
	dcfsnz	WREG,F
	bra		surfcustomview_minute_graphs		; Update the Graphs
	dcfsnz	WREG,F
	bra		surfcustomview_minute_gaslist		; Update the Gaslist/SetPoint List
	dcfsnz	WREG,F
	bra		surfcustomview_minute_interval		; Update the Interval display
	dcfsnz	WREG,F
	bra		surfcustomview_minute_cfview			; Update the critical cf view
	; Menupos3=0, do nothing
	return

surfcustomview_minute_graphs:
	call	PLED_tissue_saturation_graph		; Draw/Update the graphs
	return

surfcustomview_minute_interval:
	DISPLAYTEXT	d'189'							; Surface
	DISPLAYTEXT	d'240'							; Interval:
	call	PLED_interval						; Display the interval	
	return

surfcustomview_minute_gaslist:					; Do nothing extra
surfcustomview_minute_cfview:					; Do nothing extra
	return