;=============================================================================
;
; file   aa_fonts.asm
; brief  Font-data for the (futurly anti-aliased) word processor
; author JD Gascuel.
;
; copyright (c) 2010, JD Gascuel. All rights reserved.
; $Id$
;=============================================================================
; HISTORY
;  2010-11-23 : [jDG] Creation with the original 1.72 fonts repacked.
;
; BUGS:
;

; Original fonts where byte swapped in PROM memory, but the repacked don't...
; AA_BYTE_SWAP		EQU	1

;---- SMALL font description and data ----------------------------------------
aa_font28	code_pack
aa_font28_block:
			DB	' ', 0x80		; Translate space
			DB	'²', 0x81
			DB	'°', 0x82
			DB	'¤', 0x83
			DB	0xB7,0x7F		; Cursor...
			DB	0xB8,0x84		; Cursor...
			DB	0				; End of translation table
			DB	aa_font28_firstChar			; To be substracted
			DB	aa_font28_chars				; Max value
			DB	0x83-aa_font28_firstChar	; replace by ? when out.
			DB	aa_font28_height + 0x80
;
#include	"aa_font28_idx.inc"				; SHOULD FOLLOW !
#include	"aa_font28.inc"
; Make sure this is coherent...
	if aa_font28_nbbits != 3
		error SMALL fount should be encoded with anti-aliasing...
	endif

;---- MEDIUM font description and data ---------------------------------------
aa_font48	code_pack
aa_font48_block:
			DB	0x27, 0x3B					; ' char
			DB	'"', 0x3C
			DB	'm', 0x3D
			DB	' ', 0x3E
			DB	0
			DB	aa_font48_firstChar
			DB	aa_font48_chars
			DB	0x3E-aa_font48_firstChar
			DB	aa_font48_height + 0x80		; AA flag.
;
#include	"aa_font48_idx.inc"
#include	"aa_font48.inc"
; Make sure this is coherent...
	if aa_font48_nbbits != 3
		error MEDIUM fount should be encoded with 3bits anti-aliasing...
	endif

;---- LARGE font description and data ----------------------------------------
aa_font90	code_pack
aa_font90_block:
			DB	' ', 0x2F
			DB	0
			DB	aa_font90_firstChar
			DB	aa_font90_chars
			DB	0x2F-aa_font90_firstChar
			DB	aa_font90_height + 0x80		; AA flag.
;
#include	"aa_font90_idx.inc"
#include	"aa_font90.inc"

;=============================================================================
; Make sure this is coherent...
	if aa_font90_nbbits != 3
		error SMALL fount should be encoded with 3bits anti-aliasing...
	endif
