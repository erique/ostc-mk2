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
; 2011/08/12 : Sergei V. Rozinov: Complete translation patch
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
; Define's section
;   Definition			     translation                 ; English original
#IFNDEF	TXT_DEFINED                                                           
#DEFINE	TXT_DEFINED                                                           
                                                                              
#DEFINE	TXT_GAS_C		     'G'                         ; 'G'                    
#DEFINE	TXT_GAS1			 "G"                         ; "G"
#DEFINE	TXT_METER_C		     'm'                         ; 'm'                    
#DEFINE	TXT_METER5		     "m    "                     ; "m    "                
#DEFINE	TXT_METER3		     "m  "                       ; "m  "                  
#DEFINE	TXT_METER2		     "m "                        ; "m "                   
#DEFINE	TXT_METER1		     "m"                         ; "m"                    
#DEFINE	TXT_MBAR7		     " mbar  "                   ; " mbar  "              
#DEFINE	TXT_MBAR5		     "mbar "                     ; "mbar "                
#DEFINE	TXT_BAR4		     "bar "                      ; "bar "                 
#DEFINE	TXT_BAR3			 "bar"                       ; "bar"
#DEFINE	TXT_ALT5		     "Alt: "                     ; "Alt: "                
#DEFINE	TXT_KGL4		     "kg/l"                      ; "kg/l"                 
#DEFINE	TXT_VOLT2			 "V "                        ; "V "
#DEFINE	TXT_VOLT1		     "V"                         ; "V"                    
#DEFINE	TXT_STEP5		     "Step:"                     ; "Step:"                
#DEFINE	TXT_CF2			     "CF"                        ; "CF"                   
#DEFINE	TXT_O2_4		     "O2: "                      ; "O2: "                 
#DEFINE	TXT_O2_3		     "O2 "                       ; "O2 "                  
#DEFINE	TXT_AIR4		     "AIR "                      ; "AIR "                 
#DEFINE	TXT_ERR4		     "ERR "                      ; "ERR "                 
#DEFINE	TXT_HE4			     "He: "                      ; "He: "                 
#DEFINE	TXT_NX3			     "NX "                       ; "NX "                  
#DEFINE	TXT_TX3			     "TX "                       ; "TX "                  
#DEFINE	TXT_AT4			     " at "                      ; " at "
#DEFINE	TXT_G1_3		     "G1:"                       ; "G1:"                  
#DEFINE	TXT_G2_3		     "G2:"                       ; "G2:"                  
#DEFINE	TXT_G3_3		     "G3:"                       ; "G3:"                  
#DEFINE	TXT_G4_3		     "G4:"                       ; "G4:"                  
#DEFINE	TXT_G5_3		     "G5:"                       ; "G5:"                  
#DEFINE	TXT_G6_3		     "G6:"                       ; "G6:"                  
#DEFINE	TXT_1ST4		     "1st:"                      ; "1st:"                 
#DEFINE	TXT_CNS4		     "CNS:"                      ; "CNS:"                 
#DEFINE	TXT_CNSGR10		     "CNS > 250%"                ; "CNS > 250%"           
#DEFINE	TXT_AVR4		     "Avr:"                      ; "Avr:"                 
#DEFINE	TXT_GF3			     "GF:"                       ; "GF:"                  
#DEFINE	TXT_SAT4		     "Sat:"                      ; "Sat:"                 
#DEFINE	TXT_0MIN5			 "0min "                     ; "0min "
#DEFINE	TXT_MIN4			 "min "                      ; "min "  
#DEFINE	TXT_BSAT5			 "BSat:"                     ; "BSat:" 
#DEFINE	TXT_BDES5			 "BDes:"                     ; "BDes:" 
#DEFINE	TXT_LAST5			 "Last:"                     ; "Last:" 
#DEFINE	TXT_GFLO6			 "GF_lo:"                    ; "GF_lo:"
#DEFINE	TXT_GFHI6			 "GF_hi:"                    ; "GF_hi:"
#DEFINE	TXT_PPO2_5			 "ppO2:"                     ; "ppO2:" 
#DEFINE	TXT_OC_O1			 "O"                         ; "O"     
#DEFINE	TXT_OC_C1			 "C"                         ; "C"     
#DEFINE	TXT_CC_C1_1			 "C"                         ; "C"     
#DEFINE	TXT_CC_C2_1			 "C"                         ; "C"     
#DEFINE	TXT_GF_G1			 "G"                         ; "G"     
#DEFINE	TXT_GF_F1			 "F"                         ; "F"     
#DEFINE	TXT_SP2				 "SP"                        ; "SP"    
#DEFINE	TXT_DIL4			 "Dil:"                      ; "Dil:"  
#DEFINE	TXT_N2_2			 "N2"                        ; "N2"    
#DEFINE	TXT_HE2				 "He"                        ; "He"    
#DEFINE	TXT_PSCR_P1			 "p"                         ; "P"
#DEFINE	TXT_PSCR_S1			 "S"                         ; "S"
#ENDIF                                                                   
;=============================================================================
;   macro     X     Y        "Italiano   "               ; English original
    TCODE    .0,   .0,       "Building MD2 Hash"         ;001 Building MD2 Hash
    TCODE    .0,   .25,      "Attendi..."                ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .65,  .2,       "Menu?"                     ;004 Menu?
    TCODE    .65,  .2,       "Menu:"                     ;005 Menu:
    TCODE    .20,  .35,      "Logbook"                   ;006 Logbook
    TCODE    .20,  .65,      "Imposta Gas"               ;007 Gas Setup
    TCODE    .20,  .35,      "Imposta Ora"               ;008 Set Time
    TCODE    .20,  .95,      "Reset Menu"                ;009 Reset Menu
    TCODE    .20,  .125,     "Impostazioni"              ;010 Setup
    TCODE    .20,  .185,     "Esci"                      ;011 Exit
    TCODE    .111, .2,       "Attendi..."                ;012 Wait...
    TCODE    .0,   .24,      "MD2 Hash:"                 ;013 MD2 Hash:
    TCODE    .0,   .0,       "Desat"                     ;014 Desat         (Desaturation count-down)
    TCODE    .50,  .2,       "Connessione"               ;015 Interface		(Connected to USB)
    TCODE    .10,  .30,      "Inizio"                    ;016 Start
    TCODE    .10,  .55,      "Data"                      ;017 Data
    TCODE    .10,  .80,      "Testata"                   ;018 Header
    TCODE    .10,  .105,     "Profilo"                   ;019 Profile
    TCODE    .10,  .130,     "Fatto."                    ;020 Done.
    TCODE    .20,  .35,      "Annulla Reset"             ;021 Cancel Reset
    TCODE    .32,  .65,      "Ora :"                     ;022 Time:
    TCODE    .32,  .95,      "Data:"                     ;023 Date:
    TCODE    .0,   .215,     "Imposta Ore"               ;024 Set Hours
    TCODE    .6,   .0,       "Azzera..."                 ;025 Reset...
    TCODE    .55,  .2,       "Logbook"                   ;026 Logbook
    TCODE    .14,  .2,       "Funzioni Custom I"         ;027 Custom Functions I
    TCODE    .40,  .2,       "Reset Menu"                ;028 Reset Menu
    TCODE    .50,  .2,       "Imposta orario:"           ;029 Set Time:
    TCODE    .100, .50,      "SetMarker"                 ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "PianoDeco"                 ;031 Decoplan
    TCODE    .100, .0,       "ListaGas"                  ;032 Gaslist
    TCODE    .100, .50,      "AzzeraAvr"                 ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "Esci"                      ;034 Exit		        (Exit current menu)
    TCODE    .0,   .0,       "NonVolo"                   ;035 NoFly		        (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "Inizio immersione[m]"      ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "Fine immersione  [m]"      ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "End Delay [sec]"           ;038 End Delay [sec]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "Spegnimento [min]"         ;039 Power Off [min]
    TCODE    .40,  .35,      "Pre-menu  [min]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "velocità [m/min]"          ;041 velocity[m/min]
    TCODE    .40,  .35,      "Accensione [mbar]"         ;042 Wake-up  [mbar]
    TCODE    .40,  .35,      "max.Surf.[mbar]"           ;043 max.Surf.[mbar]
    TCODE    .40,  .35,      "Visualizza GF [%]"         ;044 GF display  [%]
    TCODE    .40,  .35,      "min. O2 Vis.[%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "Dive menus[min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "Saturazione x[%]"          ;047 Saturate x  [%]
    TCODE    .40,  .35,      "Desaturazione x[%]"        ;048 Desaturate x[%]
    TCODE    .40,  .35,      "Ratio NonVolo [%]"         ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "Allarme GF 1  [%]"         ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "CNSshow surf[%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "Deco Offset [m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 Bassa[bar]"           ;053 ppO2 low  [bar]
    TCODE    .40,  .35,      "ppO2 Alta [bar]"           ;054 ppO2 high [bar]
    TCODE    .40,  .35,      "ppO2 vedi [bar]"           ;055 ppO2 show [bar]
    TCODE    .40,  .35,      "freq campionamento"        ;056 sampling rate  
    TCODE    .40,  .35,      "Divisor Temp   "          ;057 Divisor Temp   
    TCODE    .40,  .35,      "Divisor Decodat"           ;058 Divisor Decodat
    TCODE    .40,  .35,      "Divisor GF     "           ;059 Divisor GF
    TCODE    .40,  .35,      "Divisor ppO2   "           ;060 Divisor ppO2 
    TCODE    .40,  .35,      "Divisor Debug  "           ;061 Divisor Debug  
    TCODE    .40,  .35,      "Divisor CNS    "           ;062 Divisor CNS
    TCODE    .40,  .35,      "CNSshow dive[%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "Logbook offset "           ;064 Logbook offset 
    TCODE    .40,  .35,      "Ultima Deco a[m]"          ;065 Last Deco at[m]
    TCODE    .40,  .35,      "Fine Apnea  [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "Mostra Volts.Batt"         ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "Questo programma è"        ;068 This program is
    TCODE    .0,   .65,      "distribuito nella"         ;069 distributed in the
    TCODE    .0,   .95,      "speranza che vi sarà"      ;070 hope that it will be
    TCODE    .0,   .125,     "utile, ma SENZA"           ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "NESSUNA GARANZIA"          ;072 ANY WARRANTY
    TCODE    .0,   .185,     "anche l'implicita"         ;073 even the implied
    TCODE    .0,   .215,     "garanzia di"               ;074 warranty of
    TCODE    .0,   .35,      "MERCHANTABILITY or"        ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "FITNESS FOR A"             ;076 FITNESS FOR A
    TCODE    .0,   .95,      "PARTICULAR PURPOSE."       ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "Vedi anche GNU General"    ;078 See the GNU General
    TCODE    .0,   .155,     "Public License per"        ;079 Public License for
    TCODE    .0,   .185,     "maggiori dettagli:"        ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .102,  .54,     "TappaDeco"                  ;082 Decostop
    TCODE    .0,    .0,      "m/min"                     ;083 m/min
    TCODE    .108,  .113,    "No Stop"                   ;084 No Stop
    TCODE    .135,  .113,    "TTS"                       ;085 TTS
    TCODE    .100,  .0,      "Divetime"                  ;086 Divetime
    TCODE    .0,    .0,      "Profondità"                ;087 Depth
    TCODE    .0,    .0,      "Primo Gas?"                ;088 First Gas?
    TCODE    .0,    .0,      "Default:"                  ;089 Default:
    TCODE    .0,    .0,      "Minuti"                    ;090 Minutes
    TCODE    .0,    .0,      "Mese  "                    ;091 Month  
    TCODE    .0,    .0,      "Giorno "                   ;092 Day    
    TCODE    .0,    .0,      "Anno   "                   ;093 Year   
    TCODE    .0,    .0,      "Imposta"                   ;094 Set 
    TCODE    .0,    .0,      "Gas# "                     ;095 Gas# 
    TCODE    .0,    .0,      "SI"                        ;096 Yes
    TCODE    .0,    .0,      "Corrente:"                 ;097 Current:
    TCODE    .40,   .2,      "Menu Impostazioni:"        ;098 Setup Menu:
    TCODE    .20,   .35,     "Funzioni custom I"         ;099 Custom FunctionsI
    TCODE    .20,   .125,    "TipoDeco:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Profondimetro"             ;102 Gauge    
    TCODE    .85,   .125,    "Profondimetro"             ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "Gas Attivo? "              ;105 Active Gas?
    TCODE    .10,   .2,      "Imposta Gas - listaGas"	 ;106 Gas Setup - Gaslist
    TCODE    .20,   .95,     "Profondità +/-:"           ;107 Depth +/-:
    TCODE    .20,   .125,    "Cambia:" 		         ;108 Change:
    TCODE    .20,   .155,    "Default:"			 ;109 Default:
    TCODE    .20,   .65,     "CCR SetPoint Menu"         ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "CCR SetPoint Menu"         ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "SP#"                       ;112 SP#
    TCODE    .20,   .95,     "Info Batteria"             ;113 Battery Info
    TCODE    .10,   .2,      "Informazioni Batteria"     ;114 Battery Information
    TCODE    .0,    .9,      "Cicli:"                    ;115 Cycles:
    TCODE    .85,   .125,    "Apnea"                     ;116 Apnoe
    TCODE    .0,    .18,     "Ultimo Completo:"          ;117 Last Complete:
    TCODE    .0,    .27,     "Minimo Vbatt:"             ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "Minimo al:"                ;119 Lowest at:
    TCODE    .0,    .45,     "Tmin:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tmax:"                     ;121 Tmax:
    TCODE    .100,  .124,    "Altri"                   	 ;122 More (Gaslist)
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "Esci"                      ;127 Exit
    TCODE    .100,  .25,     "Cancella"                  ;128 Delete
    TCODE    .20,   .65,     "Debug:"                    ;129 Debug:
    TCODE    .65,   .65,     "ON "                       ;130 ON 
    TCODE    .65,   .65,     "OFF"                       ;131 OFF
    TCODE    .100,  .50,     "Canc. tutto"               ;132 Del. all
    TCODE    .10,   .0,      "Rest Inaspettato dal"      ;133 Unexpected reset from
    TCODE    .10,   .25,     "Divemode! Aiutaci "        ;134 Divemode! Please help
    TCODE    .10,   .50,     "e comunicaci le "     	 ;135 and report the Debug 
    TCODE    .10,   .75,     "Informazioni qui sotto!"   ;136 Information below!
    TCODE    .100,  .0,	     "Bailout"                   ;137 Bailout
    TCODE    .85,   .125,    "Apnea    "                 ;138 Apnoe    
    TCODE    .105,  .120,    "Discesa"                   ;139 Descent
    TCODE    .105,  .60,     "Superficie"                ;140 Surface
    TCODE    .65,   .2,      "Esci?"                     ;141 Quit?
    TCODE    .20,   .155,    "Aggiungi"                  ;142 More
    TCODE    .42,   .72,     "Conferma:"                 ;143 Confirm:
    TCODE    .60,   .2,      "Menu 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "Cancella"                  ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "Aggiungi"                  ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "ppO2"                      ;149 ppO2
    TCODE    .2,    .39,     "bar "                      ;150 bar 
    TCODE    .108,  .216,    "Marker?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "Funzioni Custom II"        ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Basso    [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF Alto     [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "Colore#Batteria"           ;156 Color# Battery 
    TCODE    .40,   .35,     "Colore#Standard"           ;157 Color# Standard
    TCODE    .40,   .35,     "Colore#Divemask"           ;158 Color# Divemask
    TCODE    .40,   .35,     "Colore# Allarmi"           ;159 Color# Warnings
    TCODE    .40,   .35,     "Sec.in Divemode"           ;160 Divemode secs. 
    TCODE    .40,   .35,     "Adjust fixed SP"           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "Allarme Ceiling"           ;162 Warn Ceiling
    TCODE    .40,   .35,     "Mix type icons "           ;163 Mix type icons
    TCODE    .40,   .35,     "Lamp MigliorGas"           ;164 Blink BetterGas	(Remainder in divemode to switch to a better decompression gas).
    TCODE    .40,   .35,     "AlarmProf[mbar]"           ;165 DepthWarn[mbar]
    TCODE    .40,   .35,     "Allarme CNS [%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "Allarme GF  [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "Alarm ppO2[bar]"           ;168 ppO2 warn [bar]
    TCODE    .40,   .35,     "AlarmVel[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "Time offset/day"           ;170 Time offset/day
    TCODE    .40,   .35,     "Vedi altimetro "           ;171 Show altimeter
    TCODE    .40,   .35,     "vedi Log-Marker"           ;172 Show Log-Marker
    TCODE    .40,   .35,     "Vedi Stopwatch "           ;173 Show Stopwatch
    TCODE    .40,   .35,     "VediGrafTessuti"           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "Vedi Tess.Prim."           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "Gira piano Deco"           ;176 Shallow stop 1st  (Reverse order of deco plans)
    TCODE    .40,   .35,     "Cambia Gas[min]"           ;177 Gas switch[min]   (Additional delay in decoplan for gas switches).
    TCODE    .40,   .35,     "Gas Fondo[/min]"           ;178 BottomGas[/min]   (Bottom gas usage, for volume estimation).
    TCODE    .40,   .35,     "Gas Risal[/min]"           ;179 AscentGas[/min]   (Ascent+Deco gas usage)
    TCODE    .40,   .35,     "TTS Futuro[min]"           ;180 Future TTS[min]   (Compute TTS for extra time at current depth)
    TCODE    .40,   .35,     "Allarme Cave[l]"           ;181 Cave Warning[l]   (Consomation warning for cave divers)
    TCODE    .40,   .35,     "GraficoVelocità"           ;182 Graph. Velocity	(Show a graphical representation of the ascend speed)
    TCODE    .40,   .35,     "Vedi pSCR ppO2 "           ;183 Show pSCR ppO2	(Show the ppO2 for pSCR divers)
    TCODE    .40,   .35,     "pSCR O2 Drop[%]"           ;184 pSCR O2 Drop[%]	(pSCR O2 drop in percent)
    TCODE    .40,   .35,     "pSCR lung ratio"           ;185 pSCR lung ratio	(pSCR counterlung ratio)
; End of function descriptor II
;
    TCODE    .13,   .2,      "Funzioni Custom II"        ;186 Custom Functions II
    TCODE    .20,   .95,     "Vedi Licenza"              ;187 Show License
    TCODE    .0,    .2,      "Risultati simul:"          ;188 Sim. Results:
    TCODE    .90,   .25,     "Superficie"                ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "Dil."                      ;192 Dil.			       (Rebreather diluent)

; 32 custom function descriptors III (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "Color# inattivo"           ;193 Color# inactive
    TCODE    .40,   .35,     "Usa tappa sicur"           ;194 Use safety stop
    TCODE    .40,   .35,     "unused         "           ;195 unused
    TCODE    .40,   .35,     "unused         "           ;196 unused
    TCODE    .40,   .35,     "unused         "           ;197 unused
    TCODE    .40,   .35,     "unused         "           ;198 unused
    TCODE    .40,   .35,     "unused         "           ;199 unused
    TCODE    .40,   .35,     "unused         "           ;200 unused
    TCODE    .40,   .35,     "unused         "           ;201 unused
    TCODE    .40,   .35,     "unused         "           ;202 unused
    TCODE    .40,   .35,     "unused         "           ;203 unused
    TCODE    .40,   .35,     "unused         "           ;204 unused
    TCODE    .40,   .35,     "unused         "           ;205 unused
    TCODE    .40,   .35,     "unused         "           ;206 unused
    TCODE    .40,   .35,     "unused         "           ;207 unused
    TCODE    .40,   .35,     "unused         "           ;208 unused
    TCODE    .40,   .35,     "unused         "           ;209 unused
    TCODE    .40,   .35,     "unused         "           ;210 unused
    TCODE    .40,   .35,     "unused         "           ;211 unused
    TCODE    .40,   .35,     "unused         "           ;212 unused
    TCODE    .40,   .35,     "unused         "           ;213 unused
    TCODE    .40,   .35,     "unused         "           ;214 unused
    TCODE    .40,   .35,     "unused         "           ;215 unused
    TCODE    .40,   .35,     "unused         "           ;216 unused
    TCODE    .40,   .35,     "unused         "           ;217 unused
    TCODE    .40,   .35,     "unused         "           ;218 unused
    TCODE    .40,   .35,     "unused         "           ;219 unused
    TCODE    .40,   .35,     "unused         "           ;220 unused
    TCODE    .40,   .35,     "unused         "           ;221 unused
    TCODE    .40,   .35,     "unused         "           ;222 unused
    TCODE    .40,   .35,     "unused         "           ;223 unused
    TCODE    .40,   .35,     "unused         "           ;224 unused
;
    TCODE    .7,    .2,      "Funcioni Custom III"       ;225 Custom Functions III
    TCODE    .85,   .125,    "pSCR-GF  "                 ;226 pSCR-GF
    TCODE    .90,   .54,     "SafetyStop"                ;227 SafetyStop
    TCODE    .0,    .0,      ""     	                 ;228 unused
    TCODE    .0,    .0,      ""		                 ;229 unused
    TCODE    .0,    .0,      ""		                 ;230 unused
    TCODE    .0,    .0,      ""     	                 ;231 unused
    TCODE    .0,    .0,      ""		                 ;232 unused
    TCODE    .0,    .0,      ""		                 ;233 unused
    TCODE    .0,    .0,      ""     	                 ;234 unused

    TCODE    .10,   .2,      "Deco Cambiato!"    	 ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "Non trovato"               ;237 Not found
    TCODE    .100,  .0,      "SetPoint"                  ;238 SetPoint
    TCODE    .100,  .0,      "No Deco"                   ;239 No Deco
    TCODE    .90,   .50,     "Intervallo:"               ;240 Interval:
    TCODE    .100,  .75,     "Display"                   ;241 Display
    TCODE    .100,  .0,      "No deco"                   ;242 No deco
    TCODE    .132,  .0,      "beta"                      ;243 beta
    TCODE    .100,  .100,    "unuse"                     ;244 unuse
    TCODE    .20,   .65,     "Resetta CF,Gas & Deco"     ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "Batt bassa!"               ;246 LowBatt!
    TCODE    .20,   .125,    "Simulatore"                ;247 Simulator
    TCODE    .30,   .2,      "OSTC Simulator"            ;248 OSTC Simulator
    TCODE    .20,   .65,     "Inizio immersione"         ;249 Start Dive
    TCODE    .100,  .25,     "+ 1m"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1m"                      ;251 - 1m
    TCODE    .100,  .75,     "+10m"                      ;252 +10m
    TCODE    .100,  .100,    "-10m"                      ;253 -10m
    TCODE    .100,  .0,      "Chiudi"                    ;254 Close
    TCODE    .131,  .170,    "Tempo"                     ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "Formato data:"             ;257 Date format:
    TCODE    .40,   .2,      "Setup Menu 2:"             ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMDDYY"                    ;259 MMDDYY
    TCODE    .105,  .35,     "DDMMYY"                    ;260 DDMMYY
    TCODE    .105,  .35,     "YYMMDD"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC 
    TCODE    .65,   .168,    "Bail "                     ;263 Bail 
    TCODE    .7,    .48,     "Aria "                     ;264 Air
    TCODE    .120,  .135,    "Aria "                     ;265 Air

    TCODE    .0,    .0,      "Info pSCR"             	 ;266 pSCR Info (Must be 9Chars!)
    TCODE    .0,    .216,    "Max."                      ;267 Max.
    TCODE    .0,    .0,      ""     	                 ;268 unused
    TCODE    .0,    .0,      ""		                 ;269 unused
    TCODE    .0,    .0,      ""		                 ;270 unused

; New CFs Warning
    TCODE    .24,   .2,      "Nuova CF aggiunta!"        ;271 New CF added!
    TCODE    .0,    .35,     "Nuove Funz. custom"        ;272 New CustomFunctions
    TCODE    .0,    .65,     "Aggiunte! Controlla"       ;273 were added! Check
    TCODE    .0,    .95,     "i menu CF I CF II"         ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "per i Dettagli!"           ;275 for Details!
    TCODE    .20,   .125,    "Salinità: "                ;276 Salinity:
;
    TCODE    .20,   .95,     "Tempo di fondo:"           ;277 Bottom Time:
    TCODE    .20,   .125,    "Profondità Max:"           ;278 Max. Depth:
    TCODE    .20,   .155,    "Calcola Deco"              ;279 Calculate Deco
    TCODE    .20,   .155,    "Luminosità:"          	 ;280 Brightness:
;
    TCODE    .93,   .170,    "Prof.media"                ;281 Avr.Depth
    TCODE    .90,   .170,    "Lead Tiss."                ;282 Lead Tiss.
    TCODE    .93,   .170,    "Cronometro"                ;283 Stopwatch
    TCODE    .20,   .95,     "Azzera Logbook"            ;284 Reset Logbook
    TCODE    .20,   .125,    "Riavvia OSTC"              ;285 Reboot OSTC
    TCODE    .20,   .155,    "Azzera Decodata"           ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "Altimetro"                 ;287 Altimeter
    TCODE    .38,   .1,      "imposta Altimetro"         ;288 Set Altimeter
    TCODE    .20,   .35,     "Rif Mare: "                ;289 Sea ref: 
    TCODE    .0,    .0,      "Abilitato: "               ;290 Enabled:
    TCODE    .20,   .95,     "Default: 1013 mbar"        ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Alt: "                     ;294 Alt: 
;
    TCODE    .20,   .95,     "Funzioni CustomIII"        ;295 Custom FunctionsIII
    TCODE    .50,    .2,     "Raw Data:"                 ;296 Raw Data:
; Gas-setup addons:
    TCODE    .0,    .0,      "MOD:"                      ;297 MOD:                  (max operating depth of a gas).
    TCODE    .0,    .0,      "END:"                      ;298 END:                  (equivalent nitrogen depth of a gas).
    TCODE    .0,    .0,      "EAD:"                      ;299 EAD:                  (equivalent air depth of a gas).
    TCODE    .100,  .125,    "More"			 ;300 More                  (Enable/Disable Gas underwater)
    TCODE    .0,    .2,      "OCR Gas Usage:"            ;301 OCR Gas Usage:        (Planned gas consumtion by tank).
; 115k Bootloader support:
    TCODE    .45,   .100,    "Bootloader"		 ;302 Bootloader
    TCODE    .40,   .130,    "Perfavore aspetta!"	 ;303 Please wait!
    TCODE    .50,   .130,    "Aborted!"		         ;304 Aborted
; @5 variant
    TCODE    .0,    .0,      "TTS Futuro"                ;305 Future TTS            (=10 chars. Title for @5 customview).
;
    TCODE    .100,  .125,    "Esci Sim"                  ;306 Quit Sim              (=8char max. Quit Simulator mode)
; Dive interval
    TCODE    .20,   .35,     "Intervallo:"               ;307 Interval:
    TCODE    .0,    .0,      "Adesso "                   ;308 Now                   (7 chars min)
    TCODE    .108,  .112,    "Medio"	 		 ;309 Average
;
    TCODE    .94,    .54,    "Cronometro" 		 ;310 Stopwatch             (BIG Stopwatch in Gauge mode)
; Cave consomation
    TCODE    .0,    .0,      "Cave Bail."                ;311 Cave Bail.            (=10 chars.)
; OLED Brightness settings
    TCODE    .103,  .155,    "Eco "	    	         ;312 Eco 					(Same length as #313!)
    TCODE    .103,  .155,    "High" 	                 ;313 High					(Same length as #312!)

; ZH-L16 mode description
    TCODE    .0,    .35,     "TipoDeco: ZH-L16 OC"       ;314 Decotype: ZH-L16 OC
    TCODE    .0,    .65,     "Per Sub in Circuito" 	 ;315 For Open Circuit
    TCODE    .0,    .95,     "Aperto. Supporta 5"    	 ;316 Divers. Supports 5
    TCODE    .0,    .125,    "Miscele Trimix."       	 ;317 Trimix Gases.
    TCODE    .0,    .155,    "Configura il tuo gas"      ;318 Configure your gas
    TCODE    .0,    .185,    "nel menu ImpostaGas."      ;319 in Gassetup menu.
    TCODE    .0,    .215,    "Controlla CF11 & CF12 !"   ;320 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "Tipodeco: Profondimetro"   ;321 Decotype: Gauge    
    TCODE    .0,    .65,     "Il tempo di immersione"    ;322 Divetime will be in
    TCODE    .0,    .95,     "sarà Minuti:Secondi."      ;323 Minutes:Seconds.   
    TCODE    .0,    .125,    "OSTC2 non calcolerà"       ;324 OSTC2 will not     
    TCODE    .0,    .155,    "mai Deco, tempo di "       ;325 compute Deco, NoFly
    TCODE    .0,    .185,    "Non volo e tempo di "      ;326 time and Desat.
    TCODE    .0,    .215,    "desaturazione!"      	 ;327 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "Tipodeco: ZH-L16 CC"       ;328 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "Per Rebreather "       	 ;329 For closed
    TCODE    .0,    .95,     "a circuito chiuso"         ;330 circuit rebreathers
    TCODE    .0,    .125,    "Configura i 3"      	 ;331 Configure the 3
    TCODE    .0,    .155,    "SetPoints nel menu"      	 ;332 SetPoints in CCR -
    TCODE    .0,    .185,    "imposta-CCR. 5 bail-"      ;333 Setup menu. 5 bail-
    TCODE    .0,    .215,    "outs sono disponibili."    ;334 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "Tipodeco: Apnea"      	 ;335 Decotype: Apnoe
    TCODE    .0,    .65,     "OSTC2 mostrerà"	         ;336 OSTC2 will display
    TCODE    .0,    .95,     "ogni discesa separ-"       ;337 each descent separ-
    TCODE    .0,    .125,    "atamente in Min:Sec."      ;338 ately in Min:Sec.
    TCODE    .0,    .155,    "Temporaneamente il"        ;339 Will temporally set
    TCODE    .0,    .185,    "samplerate sarà 1 sec"     ;340 samplerate to 1 sec
    TCODE    .0,    .215,    "Senza calcolo Deco "       ;341 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "TpoDeco: L16-GF OC"        ;342 Decotype: L16-GF OC
    TCODE    .0,    .65,     "Calcolo decompres-"        ;343 Decompression cal-
    TCODE    .0,    .95,     "sione con il "             ;344 culations with the
    TCODE    .0,    .125,    "Metodo GF (GF_lo/GF"       ;345 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). Controlla CF32 &"    ;346 _hi). Check CF32 &
    TCODE    .0,    .185,    "CF33! Circuito Aperto"     ;347 CF33! Open Circuit
    TCODE    .0,    .215,    "con Deep Stops."	  	 ;348 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "TipoDeco: L16-GF CC"       ;349 Decotype: L16-GF CC
    TCODE    .0,    .65,     "Calcolo decompres-"      	 ;350 Decompression cal-
    TCODE    .0,    .95,     "sione con il "      	 ;351 culations with the
    TCODE    .0,    .125,    "Metodo GF (GF_lo/GF"       ;352 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). Controlla CF32 &"    ;353 _hi). Check CF32 &
    TCODE    .0,    .185,    "CF33!Circuito chiuso"      ;354 CF33!Closed Circuit
    TCODE    .0,    .215,    "con Deep Stops."       	 ;355 with Deep Stops.
; pSCR-GF mode description
    TCODE    .0,    .35,     "TipoDeco: pSCR-GF"     	 ;356 Decotype: pSCR-GF
    TCODE    .0,    .65,     "Per passive semi-"     	 ;357 For passive semi-
    TCODE    .0,    .95,     "closed rebreather."    	 ;358 closed rebreather.
    TCODE    .0,    .125,    "Controlla CF32 & CF33"     ;359 Check CF32 & CF33
    TCODE    .0,    .155,    "per i gradient factors"    ;360 for gradient factors
    TCODE    .0,    .185,    "and CF61-CF63 per"     	 ;361 and CF61-CF63 for
    TCODE    .0,    .215,    "modalità pSCR."    	 ;362 pSCR features.
;

;=============================================================================
