;=============================================================================
; OSTC - diving computer code
; Copyright (C) 2008 HeinrichsWeikamp GbR
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
; Hold texts and screen position to display the texts.
; History:
; 2007/10/13 : Initial version by Matthias Heinrichs, info@heinrichsweikamp.com
; 2008/05/24 : MW.
; 2011/02/02 : Jean-Do Gascuel : split into different files for multi-lingual support
;
; known bugs:
; ToDo: 
;=============================================================================
;
; Instructions for translating:
;
; * Strings are accessed according to the order in the file.
;   So don't change ordering !
;
; * Keep the english original version on the right column. So translations
;   can be reviewed and maintened.
;
; * One of the main constraint is to keep texts short, to avoid clobering
;   the OSTC screen. Of course, the technical, precise terms should be used.
;   Generally, there is no hard constraint: you can be one or two chars 
;   shorter or longer.
; 
; * Beware that some strings do have a fixed length. You should then use 
;   exactly the same size.
;
; * Beware that some strings have ponctuation, or trailling space(s). In that
;   case, you should keep EXACTLY the same ponctuation AND TRAILING SPACES.
;
; * Ascii chars: we can support a few specific chars. öäüß for German.
;   éèêç for French. áíóúñ¡¿ for Spanish.
;   If you really, absolutly, need more: ask...
;
; * Do not translate comments (everithing after the ;), because they are
;   used for maintenance.
;
; * The X column is position on screen. Some texts are centered, left
;   padded or right padded. In that case, if you changed the text size,
;   you will have to adjust position. A char is 7 pixels wide.
;
;=============================================================================
;   macro     X     Y        "translation"               ; English original
    TCODE    .0,   .0,       "Building MD2 Hash"         ;001 Building MD2 Hash
    TCODE    .0,   .25,      "Please Wait..."            ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .65,  .2,       "Menu?"                     ;004 Menu?
    TCODE    .65,  .2,       "Menu:"                     ;005 Menu:
    TCODE    .20,  .35,      "Logbook"                   ;006 Logbook
    TCODE    .20,  .65,      "Gas Setup"                 ;007 Gas Setup
    TCODE    .20,  .35,      "Set Time"                  ;008 Set Time
    TCODE    .20,  .95,      "Reset Menu"                ;009 Reset Menu
    TCODE    .20,  .125,     "Setup"                     ;010 Setup
    TCODE    .20,  .185,     "Exit"                      ;011 Exit
    TCODE    .111, .2,       "Wait..."                   ;012 Wait...
    TCODE    .0,   .24,      "MD2 Hash:"                 ;013 MD2 Hash:
    TCODE    .0,   .0,       "Desat"                     ;014 Desat         (Desaturation count-down)
    TCODE    .50,  .2,       "Interface"                 ;015 Interface		(Connected to USB)
    TCODE    .10,  .30,      "Start"                     ;016 Start
    TCODE    .10,  .55,      "Data"                      ;017 Data
    TCODE    .10,  .80,      "Header"                    ;018 Header
    TCODE    .10,  .105,     "Profile"                   ;019 Profile
    TCODE    .10,  .130,     "Done."                     ;020 Done.
    TCODE    .20,  .35,      "Cancel Reset"              ;021 Cancel Reset
    TCODE    .32,  .65,      "Time:"                     ;022 Time:
    TCODE    .32,  .95,      "Date:"                     ;023 Date:
    TCODE    .32,  .155,     "Set Hours"                 ;024 Set Hours
    TCODE    .6,   .0,       "Reset..."                  ;025 Reset...
    TCODE    .55,  .2,       "Logbook"                   ;026 Logbook
    TCODE    .14,  .2,       "Custom Functions I"        ;027 Custom Functions I
    TCODE    .40,  .2,       "Reset Menu"                ;028 Reset Menu
    TCODE    .50,  .2,       "Set Time:"                 ;029 Set Time:
    TCODE    .100, .50,      "SetMarker"                 ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "Decoplan"                  ;031 Decoplan
    TCODE    .100, .0,       "Gaslist"                   ;032 Gaslist
    TCODE    .100, .50,      "ResetAvr"                  ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "Exit"                      ;034 Exit		        (Exit current menu)
    TCODE    .0,   .0,       "NoFly"                     ;035 NoFly		        (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "Start Dive  [m]"           ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "End Dive    [m]"           ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "End Delay [min]"           ;038 End Delay [min]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "Power Off [min]"           ;039 Power Off [min]
    TCODE    .40,  .35,      "Pre-menu  [min]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "velocity[m/min]"           ;041 velocity[m/min]
    TCODE    .40,  .35,      "Wake-up  [mBar]"           ;042 Wake-up  [mBar]
    TCODE    .40,  .35,      "max.Surf.[mBar]"           ;043 max.Surf.[mBar]
    TCODE    .40,  .35,      "GF display  [%]"           ;044 GF display  [%]
    TCODE    .40,  .35,      "min. O2 Dis.[%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "Dive menus[min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "Saturate x  [%]"           ;047 Saturate x  [%]
    TCODE    .40,  .35,      "Desaturate x[%]"           ;048 Desaturate x[%]
    TCODE    .40,  .35,      "NoFly Ratio [%]"           ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "GF alarm 1  [%]"           ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "CNSshow surf[%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "Deco Offset [m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 low  [Bar]"           ;053 ppO2 low  [Bar]
    TCODE    .40,  .35,      "ppO2 high [Bar]"           ;054 ppO2 high [Bar]
    TCODE    .40,  .35,      "ppO2 show [Bar]"           ;055 ppO2 show [Bar]
    TCODE    .40,  .35,      "sampling rate  "           ;056 sampling rate  
    TCODE    .40,  .35,      "Divisor Temp   "           ;057 Divisor Temp   
    TCODE    .40,  .35,      "Divisor Decodat"           ;058 Divisor Decodat
    TCODE    .40,  .35,      "Divisor NotUse1"           ;059 Divisor NotUse1
    TCODE    .40,  .35,      "Divisor ppO2   "           ;060 Divisor ppO2 
    TCODE    .40,  .35,      "Divisor Debug  "           ;061 Divisor Debug  
    TCODE    .40,  .35,      "Divisor NotUse2"           ;062 Divisor NotUse2
    TCODE    .40,  .35,      "CNSshow dive[%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "Logbook offset "           ;064 Logbook offset 
    TCODE    .40,  .35,      "Last Deco at[m]"           ;065 Last Deco at[m]
    TCODE    .40,  .35,      "End Apnoe   [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "Show Batt.Volts"           ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "This program is"           ;068 This program is
    TCODE    .0,   .65,      "distributed in the"        ;069 distributed in the
    TCODE    .0,   .95,      "hope that it will be"      ;070 hope that it will be
    TCODE    .0,   .125,     "useful, but WITHOUT"       ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "ANY WARRANTY; without"     ;072 ANY WARRANTY
    TCODE    .0,   .185,     "even the implied"          ;073 even the implied
    TCODE    .0,   .215,     "warranty of"               ;074 warranty of
    TCODE    .0,   .35,      "MERCHANTABILITY or"        ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "FITNESS FOR A"             ;076 FITNESS FOR A
    TCODE    .0,   .95,      "PARTICULAR PURPOSE."       ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "See the GNU General"       ;078 See the GNU General
    TCODE    .0,   .155,     "Public License for"        ;079 Public License for
    TCODE    .0,   .185,     "more details:"             ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .102,  .54,     "Decostop"                  ;082 Decostop
    TCODE    .0,    .0,      "m/min"                     ;083 m/min
    TCODE    .108,  .113,    "No Stop"                   ;084 No Stop
    TCODE    .135,  .113,    "TTS"                       ;085 TTS
    TCODE    .100,  .0,      "Divetime"                  ;086 Divetime
    TCODE    .0,    .0,      "Depth"                     ;087 Depth
    TCODE    .0,    .0,      "First Gas?"                ;088 First Gas?
    TCODE    .0,    .0,      "Default:"                  ;089 Default:
    TCODE    .0,    .0,      "Minutes"                   ;090 Minutes
    TCODE    .0,    .0,      "Month  "                   ;091 Month  
    TCODE    .0,    .0,      "Day    "                   ;092 Day    
    TCODE    .0,    .0,      "Year   "                   ;093 Year   
    TCODE    .0,    .0,      "Set "                      ;094 Set 
    TCODE    .0,    .0,      "Gas# "                     ;095 Gas# 
    TCODE    .0,    .0,      "Yes"                       ;096 Yes
    TCODE    .0,    .0,      "Current:"                  ;097 Current:
    TCODE    .40,   .2,      "Setup Menu:"               ;098 Setup Menu:
    TCODE    .20,   .35,     "Custom FunctionsI"         ;099 Custom FunctionsI
    TCODE    .20,   .125,    "Decotype:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Gauge    "                 ;102 Gauge    
    TCODE    .85,   .125,    "Gauge"                     ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "Active Gas? "              ;105 Active Gas?
    TCODE    .10,   .2,      "Gas Setup - Gaslist"	 ;106 Gas Setup - Gaslist
    TCODE    .0,    .0,      "Depth +"                   ;107 Depth +
    TCODE    .0,    .0,      "Depth -"                   ;108 Depth -
    TCODE    .20,   .35,     "Back"                      ;109 Back
    TCODE    .20,   .65,     "CCR SetPoint Menu"         ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "CCR SetPoint Menu"         ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "SP#"                       ;112 SP#
    TCODE    .20,   .95,     "Battery Info"              ;113 Battery Info
    TCODE    .10,   .2,      "Battery Information"       ;114 Battery Information
    TCODE    .0,    .9,      "Cycles:"                   ;115 Cycles:
    TCODE    .85,   .125,    "Apnoe"                     ;116 Apnoe
    TCODE    .0,    .18,     "Last Complete:"            ;117 Last Complete:
    TCODE    .0,    .27,     "Lowest Vbatt:"             ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "Lowest at:"                ;119 Lowest at:
    TCODE    .0,    .45,     "Tmin:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tmax:"                     ;121 Tmax:
    TCODE    .100,  .125,    "Gas 6.."                   ;122 Gas 6..
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "Exit"                      ;127 Exit
    TCODE    .100,  .25,     "Delete"                    ;128 Delete
    TCODE    .20,   .65,     "Debug:"                    ;129 Debug:
    TCODE    .65,   .65,     "ON "                       ;130 ON 
    TCODE    .65,   .65,     "OFF"                       ;131 OFF
    TCODE    .100,  .50,     "Del. all"                  ;132 Del. all
    TCODE    .10,   .0,      "Unexpected reset from"     ;133 Unexpected reset from
    TCODE    .10,   .25,     "Divemode! Please help"     ;134 Divemode! Please help
    TCODE    .10,   .50,     "and report the Debug "     ;135 and report the Debug 
    TCODE    .10,   .75,     "Information below!"        ;136 Information below!
    TCODE    .100,  .75,     "Bailout"                   ;137 Bailout
    TCODE    .85,   .125,    "Apnoe    "                 ;138 Apnoe    
    TCODE    .105,  .120,    "Descent"                   ;139 Descent
    TCODE    .105,  .60,     "Surface"                   ;140 Surface
    TCODE    .65,   .2,      "Quit?"                     ;141 Quit?
    TCODE    .20,   .155,    "More"                      ;142 More
    TCODE    .42,   .72,     "Confirm:"                  ;143 Confirm:
    TCODE    .60,   .2,      "Menu 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "Cancel"                    ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "More"                      ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "(ppO2:"                    ;149 (ppO2:
    TCODE    .2,    .39,     "Bar) "                     ;150 Bar) 
    TCODE    .108,  .216,    "Marker?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "Custom FunctionsII"        ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Low      [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF High     [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "Color# Battery "           ;156 Color# Battery 
    TCODE    .40,   .35,     "Color# Standard"           ;157 Color# Standard
    TCODE    .40,   .35,     "Color# Divemask"           ;158 Color# Divemask
    TCODE    .40,   .35,     "Color# Warnings"           ;159 Color# Warnings
    TCODE    .40,   .35,     "Divemode secs. "           ;160 Divemode secs. 
    TCODE    .40,   .35,     "Adjust fixed SP"           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "Warn Ceiling   "           ;162 Warn Ceiling
    TCODE    .40,   .35,     "Mix type icons "           ;163 Mix type icons
    TCODE    .40,   .35,     "Blink BetterGas"           ;164 Blink BetterGas	(Remainder in divemode to switch to a better decompression gas).
	TCODE    .40,   .35,     "DepthWarn[mBar]"           ;165 DepthWarn[mBar]
    TCODE    .40,   .35,     "CNS warning [%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "GF warning  [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "ppO2 warn [Bar]"           ;168 ppO2 warn [Bar]
    TCODE    .40,   .35,     "Vel.warn[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "Time offset/day"           ;170 Time offset/day
    TCODE    .40,   .35,     "Show altimeter "           ;171 Show altimeter
    TCODE    .40,   .35,     "Show Log-Marker"           ;172 Show Log-Marker
    TCODE    .40,   .35,     "Show Stopwatch "           ;173 Show Stopwatch
    TCODE    .40,   .35,     "ShowTissueGraph"           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "Show Lead.Tiss."           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "ShallowStop 1st"           ;176 Shallow stop 1st  (Reverse order of deco plans)
    TCODE    .40,   .35,     "Gas switch[min]"           ;177 Gas switch[min]   (Additional delay in decoplan for gas switches).
    TCODE    .40,   .35,     "not used       "           ;178 not used
    TCODE    .40,   .35,     "not used       "           ;179 not used
    TCODE    .40,   .35,     "not used       "           ;180 not used
    TCODE    .40,   .35,     "not used       "           ;181 not used
    TCODE    .40,   .35,     "not used       "           ;182 not used
    TCODE    .40,   .35,     "not used       "           ;183 not used
    TCODE    .40,   .35,     "not used       "           ;184 not used
    TCODE    .40,   .35,     "not used       "           ;185 not used
; End of function descriptor I
;
    TCODE    .13,   .2,      "Custom Functions II"       ;186 Custom Functions II
    TCODE    .20,   .95,     "Show License"              ;187 Show License
    TCODE    .0,    .2,      "Sim. Results:"             ;188 Sim. Results:
    TCODE    .90,   .25,     "Surface"                   ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "Dil."                      ;192 Dil.			       (Rebreather diluent)
; ZH-L16 mode description
    TCODE    .0,    .35,     "Decotype: ZH-L16 OC"       ;193 Decotype: ZH-L16 OC
    TCODE    .0,    .65,     "For Open Circuit   "       ;194 For Open Circuit
    TCODE    .0,    .95,     "Divers. Supports 5 "       ;195 Divers. Supports 5
    TCODE    .0,    .125,    "Trimix Gases.      "       ;196 Trimix Gases.
    TCODE    .0,    .155,    "Configure your gas "       ;197 Configure your gas
    TCODE    .0,    .185,    "in Gassetup menu.  "       ;198 in Gassetup menu.
    TCODE    .0,    .215,    "Check CF11 & CF12 !"       ;199 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "Decotype: Gauge    "       ;200 Decotype: Gauge    
    TCODE    .0,    .65,     "Divetime will be in"       ;201 Divetime will be in
    TCODE    .0,    .95,     "Minutes:Seconds.   "       ;202 Minutes:Seconds.   
    TCODE    .0,    .125,    "OSTC2 will not     "       ;203 OSTC2 will not     
    TCODE    .0,    .155,    "compute Deco, NoFly"       ;204 compute Deco, NoFly
    TCODE    .0,    .185,    "time and Desat.    "       ;205 time and Desat.
    TCODE    .0,    .215,    "time at all!       "       ;206 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "Decotype: ZH-L16 CC"       ;207 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "For (Semi-)Closed  "       ;208 For (Semi-)Closed
    TCODE    .0,    .95,     "Circuit rebreathers"       ;209 Circuit rebreathers
    TCODE    .0,    .125,    "Configure the 3    "       ;210 Configure the 3
    TCODE    .0,    .155,    "SetPoints in CCR - "       ;211 SetPoints in CCR -
    TCODE    .0,    .185,    "Setup menu. 5 bail-"       ;212 Setup menu. 5 bail-
    TCODE    .0,    .215,    "outs are available."       ;213 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "Decotype: Apnoe    "       ;214 Decotype: Apnoe
    TCODE    .0,    .65,     "OSTC2 will display "       ;215 OSTC2 will display
    TCODE    .0,    .95,     "each descent separ-"       ;216 each descent separ-
    TCODE    .0,    .125,    "ately in Min:Sec.  "       ;217 ately in Min:Sec.
    TCODE    .0,    .155,    "Will temporally set"       ;218 Will temporally set
    TCODE    .0,    .185,    "samplerate to 1 sec"       ;219 samplerate to 1 sec
    TCODE    .0,    .215,    "No Deco calculation"       ;220 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "Decotype: L16-GF OC"       ;221 Decotype: L16-GF OC
    TCODE    .0,    .65,     "Decompression cal- "       ;222 Decompression cal-
    TCODE    .0,    .95,     "culations with the "       ;223 culations with the
    TCODE    .0,    .125,    "GF-Method (GF_lo/GF"       ;224 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). Check CF32 & "       ;225 _hi). Check CF32 &
    TCODE    .0,    .185,    "CF33! Open Circuit "       ;226 CF33! Open Circuit
    TCODE    .0,    .215,    "with Deep Stops.   "       ;227 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "Decotype: L16-GF CC"       ;228 Decotype: L16-GF CC
    TCODE    .0,    .65,     "Decompression cal- "       ;229 Decompression cal-
    TCODE    .0,    .95,     "culations with the "       ;230 culations with the
    TCODE    .0,    .125,    "GF-Method (GF_lo/GF"       ;231 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). Check CF32 & "       ;232 _hi). Check CF32 &
    TCODE    .0,    .185,    "CF33!Closed Circuit"       ;233 CF33!Closed Circuit
    TCODE    .0,    .215,    "with Deep Stops.   "       ;234 with Deep Stops.
;
    TCODE    .10,   .2,      "Decomode changed!  "       ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "Not found"                 ;237 Not found
    TCODE    .100,  .0,      "SetPoint"                  ;238 SetPoint
    TCODE    .100,  .0,      "No Deco"                   ;239 No Deco
    TCODE    .90,   .50,     "Interval:"                 ;240 Interval:
    TCODE    .100,  .75,     "Display"                   ;241 Display
    TCODE    .100,  .0,      "No deco"                   ;242 No deco
    TCODE    .132,  .0,      "beta"                      ;243 beta
    TCODE    .100,  .100,    "unuse"                     ;244 unuse
    TCODE    .20,   .65,     "Reset CF,Gas & Deco"       ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "LowBatt!"                  ;246 LowBatt!
    TCODE    .20,   .125,    "Simulator"                 ;247 Simulator
    TCODE    .30,   .2,      "OSTC Simulator"            ;248 OSTC Simulator
    TCODE    .20,   .35,     "Start Dive"                ;249 Start Dive
    TCODE    .100,  .25,     "+ 1m"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1m"                      ;251 - 1m
    TCODE    .100,  .75,     "+10m"                      ;252 +10m
    TCODE    .100,  .100,    "-10m"                      ;253 -10m
    TCODE    .100,  .0,      "Close"                     ;254 Close
    TCODE    .131,  .170,    "Time"                      ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "Date format:"              ;257 Date format:
    TCODE    .40,   .2,      "Setup Menu 2:"             ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMDDYY"                    ;259 MMDDYY
    TCODE    .105,  .35,     "DDMMYY"                    ;260 DDMMYY
    TCODE    .105,  .35,     "YYMMDD"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC 
    TCODE    .65,   .168,    "Bail"                      ;263 Bail
    TCODE    .7,    .48,     "Air   "                    ;264 Air
    TCODE    .120,  .135,    "Air   "                    ;265 Air
    TCODE    .2,    .39,     "Calibrate"                 ;266 Calibrate
    TCODE    .0,    .216,    "Max."                      ;267 Max.
    TCODE    .10,   .8,      "not"                       ;268 not
    TCODE    .10,   .16,     "found!"                    ;269 found!
    TCODE    .0,    .0,      "mV:"                       ;270 mV:
; New CFs Warning
    TCODE    .24,   .2,      "New CF added!"             ;271 New CF added!
    TCODE    .0,    .35,     "New CustomFunctions"       ;272 New CustomFunctions
    TCODE    .0,    .65,     "were added! Check"         ;273 were added! Check
    TCODE    .0,    .95,     "CF I and CF II Menu"       ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "for Details!"              ;275 for Details!
    TCODE    .20,   .95,     "Salinity: "                ;276 Salinity:
;
    TCODE    .20,   .65,     "Bottom Time:"              ;277 Bottom Time:
    TCODE    .20,   .95,     "Max. Depth:"               ;278 Max. Depth:
    TCODE    .20,   .125,    "Calculate Deco"            ;279 Calculate Deco
    TCODE    .20,   .155,    "Show Decoplan"             ;280 Show Decoplan
;
    TCODE    .93,   .170,    "Avr.Depth"                 ;281 Avr.Depth
    TCODE    .90,   .170,    "Lead Tiss."                ;282 Lead Tiss.
    TCODE    .93,   .170,    "Stopwatch"                 ;283 Stopwatch
    TCODE    .20,   .95,     "Reset Logbook"             ;284 Reset Logbook
    TCODE    .20,   .125,    "Reboot OSTC"               ;285 Reboot OSTC
    TCODE    .20,   .155,    "Reset Decodata"            ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "Altimeter"                 ;287 Altimeter
    TCODE    .38,   .1,      "Set Altimeter"             ;288 Set Altimeter
    TCODE    .20,   .35,     "Sea ref: "                 ;289 Sea ref: 
    TCODE    .0,    .0,      "Enabled: "                 ;290 Enabled:
    TCODE    .20,   .95,     "Default: 1013 mbar"        ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Alt: "                     ;294 Alt: 
;
	TCODE    .20,   .125,    "Show raw data"             ;295 Show raw data
	TCODE    .50,    .2,     "Raw Data:"                 ;296 Raw Data:
; Gas-setup addons:
    TCODE    .0,    .0,      "MOD:"                      ; 297 MOD:                 (max operating depth of a gas).
    TCODE    .0,    .0,      "END:"                      ; 298 END:                 (equivalent nitrogen depth of a gas).
    TCODE    .0,    .0,      "EAD:"                      ; 299 EAD:                 (equivalent air depth of a gas).
;=============================================================================
