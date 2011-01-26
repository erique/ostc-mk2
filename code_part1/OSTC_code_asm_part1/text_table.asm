
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


; hold texts and parameters for the texts
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/13/07
; last updated: 05/24/08
; known bugs:
; ToDo: 

; Textlengths
; The length table helps to find the texts much faster

texts	code	0x00070

textlength_pointer:
	DB	.0,.18,.16,.24,.6,.6		; nu,  t1,  t2,  t3,  t4,  t5
	DB	.8,.10,.10,.12,.6,.6		; t6,  t7,  t8,  t9,  t10, t11
	DB	.8,.10,.6,.10,.6,.6			; t12, t13, t14, t15, t16, t17
	DB	.8,.8,.6,.14,.6,.6			; t18, t19, t20, t21, t22, t23
	DB	.10,.10,.8,.20,.12,.10		; t24, t25, t26, t27, t28, t29
	DB	.10,.10,.8,.10,.6,.6		; t30, t31, t32, t33, t34, t35
; 32 Custom funtion descriptors with length 16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
; Licence
	DB	.16,.20,.22,.20			; t68, t69, t70, t71
	DB	.22,.18,.12,.20			; t72, t73, t74, t75
	DB	.14,.20,.20,.20			; t76, t77, t78, t79
	DB	.14,.24					; t80, t81
; end of licence

	DB	.10,.6,.8,.4,.10,.6		; t82, t83, t84, t85, t86, t87
	DB	.12,.10,.8,.8,.8,.8		; t88, t89, t90, t91, t92, t93
	DB	.6,.6,.4,.10,.12,.18	; t94, t95, t96, t97, t98, t99
	DB	.10,.10,.10,.6,.10,.14	;t100,t101,t102,t103,t104,t105
	DB	.20,.8,.8,.6,.18,.18	;t106,t107,t108,t109,t110,t111
	DB	.4,.14,.20,.8,.6,.16	;t112,t113,t114,t115,t116,117
	DB	.14,.12,.6,.6,.8,.6		;t118,t119,t120,t121,t122,123
	DB	.6,.6,.6,.6,.8,.8		;t124,t125,t126,t127,t128,129
	DB	.4,.4,.10,.22,.22,.22	;t130,t131,t132,t133,134,135
	DB	.20,.8,.10,.8,.8,.6		;t136;t137;t138;t139;t140;t141
	DB	.6,.10,.8,.8,.4,.6		;t142;t143;t144;t145;t146;t147
	DB	.12,.8,.6,.8,.10,.20	;t148;t149;t150;t151;t152;t153
; 32 Custom funtion descriptors with length 16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
	DB	.16,.16,.16,.16
; 32 Custom funtion descriptors with length 16
	DB	.20,.14,.14,.8,.8,.8	;t186;t187;t188;t189;t190;t191
	DB	.6,.20,.20,.20,.20,.20	;t192;t193;t194;t195;t196;t197
	DB	.20,.20,.20,.20,.20,.20 ;t198......t203		
	DB	.20,.20,.20,.20,.20,.20 ;t204......t209
	DB	.20,.20,.20,.20,.20,.20 ;t210......t215
	DB	.20,.20,.20,.20,.20,.20 ;t216......t221
	DB	.20,.20,.20,.20,.20,.20 ;t222......t227
	DB	.20,.20,.20,.20,.20,.20 ;t228......t233
	DB	.20,.20,.10,.10,.10,.8	;t234;t235;t236;t237;t238;t239
	DB	.10,.8,.8,.6,.6,.20		;t240;t241;t242;t243;t244;t245
	DB	.10,.10,.16,.12,.6,.6	;t246;t247;t248;t249;t250;t251
	DB	.6,.6,.6,.6				;t252;t253;t254;t255

; Text Bank2 (Texts 256-511):
	DB	.2,.14,.14,.8,.8,.8		;t256;t257;t258;t259;t260;t261
	DB	.6,.6,.6,.6,.10,.6		;t262;t263;t264;t265;t266;t267
	DB	.4,.8,.4,.14,.20,.18	;t268;t269;t270;t271;t272;t273
	DB	.20,.14,.10,.14,.12,.16	;t274;t275;t276;t277;t278;t279
	DB	.14,.10,.12,.10,.14,.12	;t280;t281;t282;t283;t284;t285
	DB	.16						;t286
	DB  .10                     ;t287 Altimeter

; Textpositions
; Example: DB	.4,.2	; COLUMN=4,ROW=2

; Textpositions pointer
textpos_pointer:
	DB	.0,.0			;1 
	DB	.0,.25			;2 
	DB	.0,.2			;3
	DB	.65,.2			;4
	DB	.65,.2			;5
	DB	.20,.35			;6
	DB	.20,.65			;7
	DB	.20,.35			;8
	DB	.20,.95			;9
	DB	.20,.125		;10
	DB	.20,.185		;11
	DB	.115,.2			;12
	DB	.0,.24			;13 
	DB	.0,.0			;14 	
	DB	.50,.2			;15
	DB	.10,.30			;16
	DB	.10,.55			;17
	DB	.10,.80			;18
	DB	.10,.105		;19
	DB	.10,.130		;20
	DB	.20,.35			;21
	DB	.32,.65			;22
	DB	.32,.95			;23
	DB	.32,.155		;24
	DB	.6,.0			;25
	DB	.55,.2			;26
	DB	.14,.2			;27
	DB	.40,.2			;28
	DB	.50,.2			;29
	DB	.100,.50		;30	; SetMarker
	DB	.100,.25		;31	; Decoplan
	DB	.100,.0			;32	; Gaslist
	DB	.100,.50		;33	; ResetAvr
	DB	.100,.100		;34
	DB	.0,.0			;35

; 32 Custom funtion descriptors wi.12th Column=5, row=8, Y-scale=1, greyvalue=15
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
;licence:
	DB	.0,.35		;68
	DB	.0,.65		;69
	DB	.0,.95		;70
	DB	.0,.125		;71
	DB	.0,.155		;72
	DB	.0,.185		;73
	DB	.0,.215		;74
	DB	.0,.35		;75
	DB	.0,.65		;76
	DB	.0,.95		;77
	DB	.0,.125		;78
	DB	.0,.155		;79
	DB	.0,.185		;80
	DB	.0,.215		;81
; end of licence

	DB	.102,.54	;82 Decostop
	DB	.0,.0		;83
	DB	.108,.113	;84	No Stop
	DB	.135,.113	;85 TTS
	DB	.100,.0		;86 Divetime
	DB	.0,.0		;87 Depth
	DB	.0,.0		;88
	DB	.0,.0		;89
	DB	.0,.0		;90
	DB	.0,.0		;91
	DB	.0,.0		;92
	DB	.0,.0		;93
	DB	.0,.0		;94
	DB	.0,.0		;95
	DB	.0,.0		;96	
	DB	.0,.0		;97	
	DB	.40,.2		;98
	DB	.20,.35		;99
	DB	.20,.125	;100
	DB	.85,.125	;101
	DB	.85,.125	;102
	DB	.85,.125	;103
	DB	.85,.125	;104
	DB	.0,.0		;105
	DB	.10,.2		;106
	DB	.0,.0		;107
	DB	.0,.0		;108
	DB	.20,.35		;109
	DB	.20,.65		;110
	DB	.20,.2		;111
	DB	.0,.0		;112
	DB	.20,.95		;113
	DB	.10,.2		;114
	DB	.0,.9		;115
	DB	.85,.125	;116
	DB	.0,.18		;117
	DB	.0,.27		;118
	DB	.0,.36		;119
	DB	.0,.45		;120
	DB	.0,.54		;121
	DB	.100,.125	;122		Gas 6.. (Divemode menu)
	DB	.100,.25	;123
	DB	.100,.50	;124
	DB	.100,.75	;125
	DB	.100,.100	;126
	DB	.100,.0		;127
	DB	.100,.25	;128
	DB	.20,.65		;129
	DB	.65,.65		;130
	DB	.65,.65		;131
	DB	.100,.50	;132
	DB	.10,.0		;133		Debug intro
	DB	.10,.25		;134
	DB	.10,.50		;135
	DB	.10,.75		;136		/Debug Intro
	DB	.100,.75	;137		Bailout
	DB	.85,.125	;138
	DB	.105,.120	;139		Descent
	DB	.105,.60	;140		Surface
	DB	.65,.2		;141
	DB	.20,.155	;142
	DB	.42,.72		;143		Confirm:
	DB	.60,.2		;144
	DB	.52,.96		;145		Cancel
	DB	.52,.120	;146		OK!
	DB	.20,.35		;147		More (Gas Setup)
	DB	.160,.125	;148		[12 Spaces...]
	DB	.0,.8		;149
	DB	.2,.39		;150
	DB	.108,.216	;151		Marker?
	DB	.85,.125	;152
	DB	.20,.65		;153
; 32 Custom funtion descriptors with Column=5, row=8, Y-scale=1, greyvalue=15
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			
	DB	.40,.35			;185
; 32 Custom funtion descriptors with Column=5, row=8, Y-scale=1, greyvalue=15
	DB	.13,.2			;186
	DB	.20,.95			;187
	DB	.0,.2			;188
	DB	.90,.25			;189	Surface (Interval)
	DB	.0,.0			;190
	DB	.0,.0			;191
	DB	.0,.0			;192
; Mode descriptions (6x)
	DB	.0,.35	
	DB	.0,.65	
	DB	.0,.95	
	DB	.0,.125	
	DB	.0,.155	
	DB	.0,.185	
	DB	.0,.215	
	
	DB	.0,.35	
	DB	.0,.65	
	DB	.0,.95	
	DB	.0,.125	
	DB	.0,.155	
	DB	.0,.185	
	DB	.0,.215	
	
	DB	.0,.35	
	DB	.0,.65	
	DB	.0,.95	
	DB	.0,.125	
	DB	.0,.155	
	DB	.0,.185	
	DB	.0,.215	
	
	DB	.0,.35	
	DB	.0,.65	
	DB	.0,.95	
	DB	.0,.125	
	DB	.0,.155	
	DB	.0,.185	
	DB	.0,.215	
	
	DB	.0,.35	
	DB	.0,.65	
	DB	.0,.95	
	DB	.0,.125	
	DB	.0,.155	
	DB	.0,.185	
	DB	.0,.215	
	
	DB	.0,.35	
	DB	.0,.65	
	DB	.0,.95	
	DB	.0,.125	
	DB	.0,.155	
	DB	.0,.185	
	DB	.0,.215				;234

	DB	.10,.2				;235
	DB	.85,.125			;236
	DB	.2,.12				;237
	DB	.100,.0				;238   	SetPoint
	DB	.100,.0				;239 	No Deco (non-GF)
	DB	.90,.50				;240	(Surface) Interval:
	DB	.100,.75			;241	Display (Divemode Menu)
	DB	.100,.0				;242	No Deco (GF)
	DB	.160-4*7,.0         ;243	beta, right binded to screen width.
	DB	.100,.100			;244	Exit
	DB	.20,.65				;245
	DB	.50,.145			;246	LowBatt!
	DB	.20,.125			;247	Simulator
	DB	.30,.2				;248
	DB	.20,.35				;249
	DB	.100,.25			;250	Divemode_Simulator_Menu
	DB	.100,.50			;251
	DB	.100,.75			;252
	DB	.100,.100			;253
	DB	.100,.0				;254    Divemode_Simulator_Menu
	DB	.131,.170			;255	Time
	
; Text Bank2 (Texts 256-511):
	DB	.0,.0 				;256	
	DB	.20,.35				;257
	DB	.40,.2				;258
	DB	.105,.35			;259
	DB	.105,.35			;260
	DB	.105,.35			;261
	DB	.1,.1				;262
	DB	.65,.168			;263 	Bail
	DB	.7,.48				;264
	DB	.120,.135			;265
	DB	.2,.39				;266
	DB	.0,.216				;267
	DB	.10,.8				;268
	DB	.10,.16				;269
	DB	.0,.0				;270

	DB	.24,.2				;271
	DB	.0,.35				;272
	DB	.0,.65				;273
	DB	.0,.95				;274
	DB	.0,.125				;275
	DB	.20,.95				;276

	DB	.20,.65				;277
	DB	.20,.95				;278
	DB	.20,.125			;279
	DB	.20,.155			;280
	
	DB	.93,.170			;281	Avr.Depth
	DB	.90,.170			;282	Lead Tiss.
	DB	.93,.170			;283	Stopwatch
	DB	.20,.95				;284
	DB	.20,.125			;285

	DB	.20,.155			;286
    DB  .20,.155            ;287    Altimeter

; stores texts, texts must have even length and must end with "}"	
text_pointer:
	DA	"Building MD2 Hash}"	;1 
	DA	"Please Wait...}}"		;2 
	DA	"HeinrichsWeikamp OSTC2}}";3
	DA	"Menu?}"				;4		l=6
	DA	"Menu:}"				;5
	DA	"Logbook}"				;6
	DA	"Gas Setup}"			;7
	DA	"Set Time}}"			;8
	DA	"Reset Menu}}"			;9		l=12
	DA	"Setup}"				;10		l=6
	DA	"Exit}}"				;11
	DA	"Wait..}}"				;12
	DA	"MD2 Hash:}"			;13 
	DA	"Desat}"				;14 	l=6
	DA	"Interface}"			;15
	DA	"Start}"				;16
	DA	"Data}}"				;17
	DA	"Header}}"				;18
	DA	"Profile}"				;19
	DA	"Done.}"				;20
	DA	"Cancel Reset}}"		;21		l=14
	DA	"Time:}"				;22
	DA	"Date:}"				;23
	DA	"Set Hours}"			;24
	DA	"Reset...}}"			;25
	DA	"Logbook}"				;26
	DA	"Custom Functions I}}"	;27		l=20
	DA	"Reset Menu}}"			;28		l=12
	DA	"Set Time:}"			;29
	DA	"SetMarker}"			;30		l=10
	DA	"Decoplan}}"			;31
	DA	"Gaslist}"				;32 	l=8
	DA	"ResetAvr}}"			;33		l=10
	DA	"Exit}}"				;34
	DA	"NoFly}"				;35		l=6
; 32 custom function descriptors with length=16!
	DA	"Start Dive  [m]}"		;36		l=16
	DA	"End Dive    [m]}"		;37
	DA	"End Delay [min]}"		;38
	DA	"Power Off [min]}"		;39
	DA	"Pre-menu  [min]}"		;40
	DA	"velocity[m/min]}"		;41
	DA	"Wake-up  [mBar]}"		;42
	DA	"max.Surf.[mBar]}"		;43
	DA	"GF display  [%]}"		;44
	DA	"min. O2 Dis.[%]}"		;45
	DA	"Dive menus[min]}"		;46
	DA	"Saturate x  [%]}"		;47
	DA	"Desaturate x[%]}"		;48
	DA	"NoFly Ratio [%]}"		;49
	DA	"GF alarm 1  [%]}"		;50
	DA	"CNSshow surf[%]}"		;51
	DA	"Deco Offset [m]}"		;52
	DA	"ppO2 low  [Bar]}"		;53
	DA	"ppO2 high [Bar]}"		;54
	DA	"ppO2 show [Bar]}"		;55
	DA	"sampling rate  }"		;56
	DA	"Divisor Temp   }"		;57
	DA	"Divisor Decodat}"		;58
	DA	"Divisor NotUse1}"		;59
	DA	"Divisor ppO2	}"		;60
	DA	"Divisor Debug  }"		;61
	DA	"Divisor NotUse2}"		;62
	DA	"CNSshow dive[%]}"		;63
	DA	"Logbook offset }"		;64
	DA	"Last Deco at[m]}"		;65
	DA	"End Apnoe   [h]}"		;66
	DA	"Show Batt.Volts}"		;67
;licence
	DA	"This program is}"		;68		l=16
	DA	"distributed in the}}"	;69		l=20
	DA	"hope that it will be}}";70		l=22
	DA	"useful, but WITHOUT}"	;71		l=20
	DA	"ANY WARRANTY; without}";72		l=22
	DA	"even the implied}}" 	;73		l=18
	DA	"warranty of}"			;74		l=12
	DA	"MERCHANTABILITY or}}"	;75		l=20
	DA	"FITNESS FOR A}"		;76		l=14
	DA	"PARTICULAR PURPOSE.}"	;77		l=20
	DA	"See the GNU General}"	;78		l=20
	DA	"Public License for}}"	;79		l=20
	DA	"more details:}"		;80		l=14
	DA	"www.heinrichsweikamp.de}";81	l=24
; end of licence
	DA	"Decostop}}"			;82		l=10
	DA	"m/min}"				;83		l=6
	DA	"No Stop}"				;84		l=8
	DA	"TTS}"					;85		l=4
	DA	"Divetime}}"			;86		l=10
	DA	"Depth}"				;87		l=6
	DA	"First Gas?}}"			;88		l=12
	DA	"Default:}}"			;89		l=10
	DA	"Minutes}"				;90		l=8
	DA	"Month  }"				;91		l=8
	DA	"Day    }"				;92		l=8
	DA	"Year   }"				;93		l=8
	DA	"Set }}"				;94		l=6
	DA	"Gas# }"				;95		l=6
	DA	"Yes}"					;96		l=4
	DA	"Current:}}"			;97 	l=10
	DA	"Setup Menu:}"			;98		l=12
	DA	"Custom FunctionsI}"	;99		l=18
	DA	"Decotype:}"			;100	l=10
	DA	"ZH-L16 OC}"			;101	l=10
	DA	"Gauge    }"			;102	l=10
	DA	"Gauge}"				;103	l=6
	DA	"ZH-L16 CC}"			;104	l=10
	DA	"Active Gas? }}"		;105	l=14
	DA	"Gas Setup - Gaslist}"	;106	l=20
	DA	"Depth +}"				;107	l=8
	DA	"Depth -}"				;108	l=8
	DA	"Back}}"				;109	l=6
	DA	"CCR SetPoint Menu}"	;110	l=18
	DA	"CCR SetPoint Menu}"	;111	l=18
	DA	"SP#}"					;112	l=4
	DA	"Battery Info}}"		;113	l=14
	DA	"Battery Information}"	;114	l=20
	DA	"Cycles:}"				;115	l=8
	DA	"Apnoe}"				;116	l=6
	DA	"Last Complete:}}"		;117	l=16
	DA	"Lowest Vbatt:}"		;118	l=14
	DA	"Lowest at:}}"			;119	l=12
	DA	"Tmin:}"				;120	l=6
	DA	"Tmax:}"				;121	l=6
	DA	"Gas 6..}"				;122	l=8
	DA	"O2 +}}"				;123	l=6
	DA	"O2 -}}"				;124	l=6
	DA	"He +}}"				;125	l=6
	DA	"He -}}"				;126	l=6
	DA	"Exit}}"				;127	l=6
	DA	"Delete}}"				;128	l=8
	DA	"Debug:}}"				;129	l=8
	DA	"ON }"					;130	l=4
	DA	"OFF}"					;131	l=4
	DA	"Del. all}}"			;132	l=10
	DA	"Unexpected reset from}";133	l=22
	DA	"Divemode! Please help}";134	l=22
	DA	"and report the Debug }";135	l=22
	DA	"Information below!}}"	;136	l=20
	DA	"Bailout}"				;137	l=8
	DA	"Apnoe    }"			;138	l=10
	DA	"Descent}"				;139	l=8
	DA	"Surface}"				;140	l=8
	DA	"Quit?}"				;141	l=6
	DA	"More}}"				;142	l=6
	DA	"Confirm:}}"			;143	l=10
	DA	"Menu 2:}"				;144	l=8
	DA	"Cancel}}"				;145	l=8
	DA	"OK!}"					;146	l=4
	DA	"More}}"				;147	l=6
	DA	":.........:}"			;148	l=12
	DA	"(ppO2:}}"				;149	l=8
	DA	"Bar) }"				;150	l=6
	DA	"Marker?}"				;151	l=8
	DA	"L16-GF OC}"			;152	l=10
	DA	"Custom FunctionsII}}"	;153	l=20


; 32 custom function descriptors with length=16!
	DA	"GF Low      [%]}"		;154
	DA	"GF High     [%]}"		;155
	DA	"Color# Battery }"		;156
	DA	"Color# Standard}"		;157
	DA	"Color# Divemask}"		;158
	DA	"Color# Warnings}"		;159
	DA	"Divemode secs. }"		;160
	DA	"Adjust fixed SP}"		;161
	DA	"Warn Ceiling   }"		;162
	DA	"Mix type icons }"		;163
	DA	"Blink BetterGas}"		;164
	DA	"DepthWarn[mBar]}"		;165
	DA	"CNS warning [%]}"		;166
	DA	"GF warning  [%]}"		;167
	DA	"ppO2 warn [Bar]}"		;168
	DA	"Vel.warn[m/min]}"		;169
	DA	"Time offset/day}"		;170
	DA	"Show altimeter }"		;171
	DA	"Show Log-Marker}"		;172
	DA	"Show Stopwatch }"		;173
	DA	"ShowTissueGraph}"		;174
	DA	"Show Lead.Tiss.}"		;175
	DA	"Shalow stop 1st}"		;176
	DA	"not used       }"		;177
	DA	"not used       }"		;178
	DA	"not used       }"		;179
	DA	"not used       }"		;180
	DA	"not used       }"		;181
	DA	"not used       }"		;182
	DA	"not used       }"		;183
	DA	"not used       }"		;184
	DA	"not used       }"		;185
; 32 custom function descriptors with length=16!


	DA	"Custom Functions II}"	;186		l=20
	DA	"Show License}}"		;187		l=14
	DA	"Sim. Results:}"		;188		l=14
	DA	"Surface}"				;189		l=8
	DA	"ppO2 +}}"				;190		l=8
	DA	"ppO2 -}}"				;191		l=8
	DA	"Dil.}}"				;192		l=6
; ZH-L16 mode description
	DA	"Decotype: ZH-L16 OC}"	;193		l=20
	DA	"For Open Circuit   }"	;194		l=20
	DA	"Divers. Supports 5 }"	;195		l=20
	DA	"Trimix Gases.      }"	;196		l=20
	DA	"Configure your gas }"	;197		l=20	
	DA	"in Gassetup menu.  }"	;198		l=20		
	DA	"Check CF11 & CF12 !}"	;199		l=20
; Gaugemode description
	DA	"Decotype: Gauge    }"	;200		l=20
	DA	"Divetime will be in}"	;201		l=20
	DA	"Minutes:Seconds.   }"	;202		l=20
	DA	"OSTC2 will not     }"	;203		l=20
	DA	"compute Deco, NoFly}"	;204		l=20	
	DA	"time and Desat.-   }"	;205		l=20		
	DA	"time at all!       }"	;206		l=20	
; Const.ppO2 description
	DA	"Decotype: ZH-L16 CC}"	;207		l=20
	DA	"For (Semi-)Closed  }"	;208		l=20
	DA	"Circuit rebreathers}"	;209		l=20
	DA	"Configure the 3    }"	;210		l=20
	DA	"SetPoints in CCR - }"	;211		l=20	
	DA	"Setup menu. 5 bail-}"	;212		l=20		
	DA	"outs are available.}"	;213		l=20	
; Apnoemode description
	DA	"Decotype: Apnoe    }"	;214		l=20
	DA	"OSTC2 will display }"	;215		l=20
	DA	"each descent separ-}"	;216		l=20
	DA	"ately in Min:Sec.  }"	;217		l=20
	DA	"Will temporally set}"	;218		l=20	
	DA	"samplerate to 1 sec}"	;219		l=20		
	DA	"No Deco calculation}"	;220		l=20		
; Multi GF OC mode description
	DA	"Decotype: L16-GF OC}"	;221		l=20
	DA	"Decompression cal- }"	;222		l=20
	DA	"culations with the }"	;223		l=20
	DA	"GF-Method (GF_lo/GF}"	;224		l=20
	DA	"_hi). Check CF32 & }"	;225		l=20	
	DA	"CF33! Open Circuit }"	;226		l=20		
	DA	"with Deep Stops.   }"	;227		l=20		
; Multi GF CC mode description
	DA	"Decotype: L16-GF CC}"	;228		l=20
	DA	"Decompression cal- }"	;229		l=20
	DA	"culations with the }"	;230		l=20
	DA	"GF-Method (GF_lo/GF}"	;231		l=20
	DA	"_hi). Check CF32 & }"	;232		l=20	
	DA	"CF33!Closed Circuit}"	;233		l=20		
	DA	"with Deep Stops.   }"	;234		l=20	
	
	DA	"Decomode changed!  }"	;235		l=20
	DA	"L16-GF CC}"			;236		l=10
	DA	"Not found}"			;237		l=10
	DA	"SetPoint}}"			;238	 	l=10
	DA	"No Deco}"				;239		l=8
	DA	"Interval:}"			;240		l=10
	DA	"Display}"				;241		l=8
	DA	"No deco}"				;242		l=8
	DA	"beta}}"				;243		l=6
	DA	"unuse}"				;244		l=6
	DA	"Reset CF,Gas & Deco}"	;245		l=20
	DA	"LowBatt!}}"			;246		l=10
	DA	"Simulator}"			;247		l=10
	DA	"OSTC Simulator}}"		;248		l=16
	DA	"Start Dive}}"			;249		l=12
	DA	"+ 1m}}"				;250		l=6
	DA	"- 1m}}"				;251		l=6
	DA	"+10m}}"				;252		l=6
	DA	"-10m}}"				;253		l=6
	DA	"Close}"				;254		l=6
	DA	"Time}}"				;255		l=6
	
; Text Bank2 (Texts 256-511):
	DA	"x}"					;256		l=2	
	DA	"Date format:}}"		;257		l=14
	DA	"Setup Menu 2:}"		;258		l=14
	DA	"MMDDYY}}"				;259		l=8
	DA	"DDMMYY}}"				;260		l=8
	DA	"YYMMDD}}"				;261		l=8
	DA	"OSTC }"				;262		l=6
	DA	"Bail}}"				;263		l=6 
	DA	"Air  }"				;264		l=6
	DA	"Air  }"				;265		l=6
	DA	"Calibrate}"			;266		l=10
	DA	"Max.}}"				;267		l=6
	DA	"not}"					;268		l=4
	DA	"found!}}"				;269		l=8
	DA	"mV:}"					;270		l=4
; New CFs Warning
	DA	"New CF added!}"		;271		l=14
	DA	"New CustomFunctions}"	;272		l=20
	DA	"were added! Check}"	;273		l=18
	DA	"CF I and CF II Menu}"	;274		l=20	
	DA	"for Details!}}"		;275		l=14
	DA  "Salinity:}"			;276		l=10
	DA	"Bottom Time:}}"		;277		l=14
	DA	"Max. Depth:}"			;278		l=12
	DA	"Calculate Deco}}"		;279		l=16
	DA	"Show Decoplan}"		;280		l=14
	DA	"Avr.Depth}"			;281		l=10
	DA	"Lead Tiss.}}"			;282		l=12
	DA	"Stopwatch}"			;283		l=10
	DA	"Reset Logbook}"		;284		l=14
	DA	"Reboot OSTC}"			;285		l=12
	DA	"Reset Decodata}}"		;286		l=16
    DA	"Altimeter}"    		;287		l=10