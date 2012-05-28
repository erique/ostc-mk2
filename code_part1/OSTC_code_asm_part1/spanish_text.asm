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
; * Ascii chars: we can support a few specific chars. ���� for German.
;   ���� for French. ����� for Spanish.
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
;   macro     X     Y        "translation"               ; English original
    TCODE    .0,   .0,       "Creando Resumen MD2"       ;001 Building MD2 Hash
    TCODE    .0,   .25,      "Espere por favor..."       ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .58,  .2,       "�Men�?"                    ;004 Menu?
    TCODE    .65,  .2,       "Men�:"                     ;005 Menu:
    TCODE    .20,  .35,      "Diario"                    ;006 Logbook
    TCODE    .20,  .65,      "Config. Gas"               ;007 Gas Setup
    TCODE    .20,  .35,      "Fijar Hora"                ;008 Set Time
    TCODE    .20,  .95,      "Men� Reinicio"             ;009 Reset Menu
    TCODE    .20,  .125,     "Configuraci�n"             ;010 Setup
    TCODE    .20,  .185,     "Salir"                     ;011 Exit
    TCODE    .100, .2,       "Espere..."                 ;012 Wait..
    TCODE    .0,   .24,      "Resumen MD2:"              ;013 MD2 Hash:
    TCODE    .0,   .0,       "Desat"                     ;014 Desat         (Desaturation count-down)
    TCODE    .57,  .2,       "Interfaz"                  ;015 Interface
    TCODE    .10,  .30,      "Inicio"                    ;016 Start
    TCODE    .10,  .55,      "Datos"                     ;017 Data
    TCODE    .10,  .80,      "Cabecera"                  ;018 Header
    TCODE    .10,  .105,     "Perfil"                    ;019 Profile
    TCODE    .10,  .130,     "Hecho."                    ;020 Done.
    TCODE    .20,  .35,      "Cancelar Reinicio"         ;021 Cancel Reset
    TCODE    .32,  .65,      "Hora :"                    ;022 Time:
    TCODE    .32,  .95,      "Fecha:"                    ;023 Date:
    TCODE    .0,   .215,     "Fijar Horas"               ;024 Set Hours
    TCODE    .6,   .0,       "Reinicio..."               ;025 Reset...
    TCODE    .55,  .2,       "Diario"                    ;026 Logbook
    TCODE    .14,  .2,       "Func. Personaliz. I"       ;027 Custom Functions I
    TCODE    .20,  .2,       "Men� Reinicio"             ;028 Reset Menu
    TCODE    .35,  .2,       "Fijar Hora:"               ;029 Set Time:
    TCODE    .100, .50,      "Marcar  "                  ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "Plandeco"                  ;031 Decoplan
    TCODE    .100, .0,       "Listagas"                  ;032 Gaslist
    TCODE    .100, .50,      "ReiniMed"                  ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "Salir"                     ;034 Exit		        (Exit current menu)
    TCODE    .0,   .0,       "NoVue"                     ;035 NoFly		        (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "Buceo Inic. [m]"           ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "Buceo Fin.  [m]"           ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "Retras Fin[sec]"           ;038 End Delay [sec]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "Apagado   [min]"           ;039 Power Off [min]
    TCODE    .40,  .35,      "Pre-men�  [min]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "Vel.    [m/min]"           ;041 velocity[m/min]
    TCODE    .40,  .35,      "Activac. [mbar]"           ;042 Wake-up  [mbar]
    TCODE    .40,  .35,      "M�x. Sup.[mbar]"           ;043 max.Surf.[mbar]
    TCODE    .40,  .35,      "Muestra GF  [%]"           ;044 GF display  [%]
    TCODE    .40,  .35,      "Mues.m�n. O2[%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "Men�s buc.[min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "Saturac. x  [%]"           ;047 Saturate x  [%]
    TCODE    .40,  .35,      "Desaturac. x[%]"           ;048 Desaturate x[%]
    TCODE    .40,  .35,      "Ratio NoVue [%]"           ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "Alarma GF 1 [%]"           ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "Mues.CNSsup.[%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "Dist. Deco  [m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 bajo [bar]"           ;053 ppO2 low  [bar]
    TCODE    .40,  .35,      "ppO2 alto [bar]"           ;054 ppO2 high [bar]
    TCODE    .40,  .35,      "ppO2 mues.[bar]"           ;055 ppO2 show [bar]
    TCODE    .40,  .35,      "frec. muestreo "           ;056 sampling rate  
    TCODE    .40,  .35,      "Divisor Temp   "           ;057 Divisor Temp   
    TCODE    .40,  .35,      "Divisor Datdeco"           ;058 Divisor Decodat
    TCODE    .40,  .35,      "Divisor GF     "           ;059 Divisor GF
    TCODE    .40,  .35,      "Divisor ppO2   "           ;060 Divisor ppO2 
    TCODE    .40,  .35,      "Divisor Depurac"           ;061 Divisor Debug  
    TCODE    .40,  .35,      "Divisor CNS    "           ;062 Divisor CNS
    TCODE    .40,  .35,      "Mues.CNSbuc.[%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "Despl. diario  "           ;064 Logbook offset 
    TCODE    .40,  .35,      "Ult. Deco a [m]"           ;065 Last Deco at[m]
    TCODE    .40,  .35,      "Fin Apnea   [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "Mues. volt. Bat"           ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "Este programa se"          ;068 This program is
    TCODE    .0,   .65,      "distribuye con el deseo"   ;069 distributed in the
    TCODE    .0,   .95,      "de que le resulte �til,"   ;070 hope that it will be
    TCODE    .0,   .125,     "pero SIN GARANTIAS"        ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "DE NINGUN TIPO;"           ;072 ANY WARRANTY
    TCODE    .0,   .185,     "ni siquiera con las"       ;073 even the implied
    TCODE    .0,   .215,     "garant�as impl�citas"      ;074 warranty of
    TCODE    .0,   .35,      "de COMERCIABILIDAD"        ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "o APTITUD PARA UN"         ;076 FITNESS FOR A
    TCODE    .0,   .95,      "PROPOSITO DETERMINADO."    ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "Para m�s informaci�n,"     ;078 See the GNU General
    TCODE    .0,   .155,     "consulte la Licencia"      ;079 Public License for
    TCODE    .0,   .185,     "P�blica General de GNU:"   ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .102,  .54,     "Paradeco"                  ;082 Decostop
    TCODE    .0,    .0,      "m/min"                     ;083 m/min
    TCODE    .108,  .113,    "No Para"                   ;084 No Stop
    TCODE    .135,  .113,    "TTS"                       ;085 TTS
    TCODE    .100,  .0,      "Tiem.buc"                  ;086 Divetime
    TCODE    .0,    .0,      "Prof."                     ;087 Depth
    TCODE    .0,    .0,      "�Primer Gas?"              ;088 First Gas?
    TCODE    .0,    .0,      "Defecto:"                  ;089 Default:
    TCODE    .0,    .0,      "Minutos"                   ;090 Minutes
    TCODE    .0,    .0,      "Mes    "                   ;091 Month  
    TCODE    .0,    .0,      "D�a    "                   ;092 Day    
    TCODE    .0,    .0,      "A�o    "                   ;093 Year   
    TCODE    .0,    .0,      "Fija"                      ;094 Set 
    TCODE    .0,    .0,      "#Gas "                     ;095 Gas# 
    TCODE    .0,    .0,      "S� "                       ;096 Yes
    TCODE    .0,    .0,      "Actual: "                  ;097 Current:
    TCODE    .40,   .2,      "Men� Conf.:"               ;098 Setup Menu:
    TCODE    .20,   .35,     "Func.Personaliz.I"         ;099 Custom FunctionsI
    TCODE    .20,   .125,    "Tipodeco:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Indicador"                 ;102 Gauge    
    TCODE    .85,   .125,    "Indi."                     ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "�Gas Activo? "             ;105 Active Gas?
    TCODE    .10,   .2,      "Conf.Gas - Listagas"       ;106 Gas Setup - Gaslist
    TCODE    .20,   .95,     "Prof. +/-:"                ;107 Depth +/-:
    TCODE    .20,   .125,    "Cambiar:"                  ;108 Change:
    TCODE    .20,   .155,    "Defecto:"                  ;109 Default:
    TCODE    .20,   .65,     "Men� SetPoint CCR"         ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "Men� SetPoint CCR"         ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "#SP"                       ;112 SP#
    TCODE    .20,   .95,     "Info.Bater�a"              ;113 Battery Info
    TCODE    .10,   .2,      "Informaci�n Bater�a"       ;114 Battery Information
    TCODE    .0,    .9,      "Ciclos:"                   ;115 Cycles:
    TCODE    .85,   .125,    "Apnea"                     ;116 Apnoe
    TCODE    .0,    .18,     "Ult. Completo:"            ;117 Last Complete:
    TCODE    .0,    .27,     "Vbatt M�nimo:"             ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "M�nimo el:"                ;119 Lowest at:
    TCODE    .0,    .45,     "Tm�n:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tm�x:"                     ;121 Tmax:
    TCODE    .100,  .124,    "M�s"                    	 ;122 More (Gaslist)
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "Sal."                      ;127 Exit
    TCODE    .100,  .25,     "Borrar"                    ;128 Delete
    TCODE    .20,   .65,     "Depur:"                    ;129 Debug:
    TCODE    .65,   .65,     "ACT"                       ;130 ON 
    TCODE    .65,   .65,     "DES"                       ;131 OFF
    TCODE    .100,  .50,     "Borrtodo"                  ;132 Del. all
    TCODE    .0,    .0,      "�Reinicio inesperado"      ;133 Unexpected reset from
    TCODE    .0,    .25,     "del Modo Buceo. Ayudar"    ;134 Divemode! Please help
    TCODE    .0,    .50,     "reportando Informaci�n"    ;135 and report the Debug 
    TCODE    .0,    .75,     "de Depuraci�n debajo!"     ;136 Information below!
    TCODE    .100,  .0,      "Bailout"                   ;137 Bailout
    TCODE    .85,   .125,    "Apnea    "                 ;138 Apnoe    
    TCODE    .105,  .120,    "Descen."                   ;139 Descent
    TCODE    .105,  .60,     "Superf."                   ;140 Surface
    TCODE    .50,   .2,      "�Salir?"                   ;141 Quit?
    TCODE    .20,   .155,    "M�s"                       ;142 More
    TCODE    .42,   .72,     "Confirm:"                  ;143 Confirm:
    TCODE    .60,   .2,      "Men� 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "Cancel"                    ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "M�s"                       ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "ppO2"                      ;149 ppO2
    TCODE    .2,    .39,     "bar "                      ;150 bar 
    TCODE    .108,  .216,    "�Marca?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "Func.Personaliz.II"        ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Bajo     [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF Alto     [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "#Color Bater�a "           ;156 Color# Battery 
    TCODE    .40,   .35,     "#Color Est�ndar"           ;157 Color# Standard
    TCODE    .40,   .35,     "#Color MascBuc."           ;158 Color# Divemask
    TCODE    .40,   .35,     "#Color Avisos  "           ;159 Color# Warnings
    TCODE    .40,   .35,     "SegundosModoBuc"           ;160 Divemode secs. 
    TCODE    .40,   .35,     "Ajusta SP fijo "           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "Tope Aviso     "           ;162 Warn Ceiling
    TCODE    .40,   .35,     "Iconos TipoMezl"           ;163 Mix type icons
    TCODE    .40,   .35,     "Parp. Mejor Gas"           ;164 Blink BetterGas	(Remainder in divemode to switch to a better decompression gas).
    TCODE    .40,   .35,     "AvisoProf[mbar]"           ;165 DepthWarn[mbar]
    TCODE    .40,   .35,     "Aviso CNS   [%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "Aviso GF    [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "Aviso ppO2[bar]"           ;168 ppO2 warn [bar]
    TCODE    .40,   .35,     "AvisoVel[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "Despl. Temp/day"           ;170 Time offset/day
    TCODE    .40,   .35,     "Mostr.Alt�metro"           ;171 Show altimeter
    TCODE    .40,   .35,     "Mostr.Marca Log"           ;172 Show Log-Marker
    TCODE    .40,   .35,     "Mostrar Cronom."           ;173 Show Stopwatch
    TCODE    .40,   .35,     "Mostr. Gr�f.Tej"           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "Mostr. TejContr"           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "PriParadaSuperf"           ;176 Shallow stop 1st  (Reverse order of deco plans)
    TCODE    .40,   .35,     "Conmu. gas[min]"           ;177 Gas switch[min]   (Additional delay in decoplan for gas switches).
    TCODE    .40,   .35,     "Gas Fondo[/min]"           ;178 BottomGas[/min]   (Bottom gas usage, for volume estimation).
    TCODE    .40,   .35,     "GasAscens[/min]"           ;179 AscentGas[/min]   (Ascent+Deco gas usage)
    TCODE    .40,   .35,     "Futuro TTS[min]"           ;180 Future TTS[min]   (Compute TTS for extra time at current depth)
    TCODE    .40,   .35,     "Cave Warning[l]"           ;181 Cave Warning[l]   (Consomation warning for cave divers)
    TCODE    .40,   .35,     "Graph. Velocity"           ;182 Graph. Velocity	(Show a graphical representation of the ascend speed)
    TCODE    .40,   .35,     "Show pSCR ppO2 "           ;183 Show pSCR ppO2	(Show the ppO2 for pSCR divers)
    TCODE    .40,   .35,     "pSCR O2 Drop[%]"           ;184 pSCR O2 Drop[%]	(pSCR O2 drop in percent)
    TCODE    .40,   .35,     "pSCR lung ratio"           ;185 pSCR lung ratio	(pSCR counterlung ratio)
; End of function descriptor II
;
    TCODE    .13,   .2,      "Func.Personaliz. II"       ;186 Custom Functions II
    TCODE    .20,   .95,     "Ver Licencia"              ;187 Show License
    TCODE    .0,    .2,      "Result. Sim.:"             ;188 Sim. Results:
    TCODE    .90,   .25,     "Superf."                   ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "Dil."                      ;192 Dil.			       (Rebreather diluent)

; 32 custom function descriptors III (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "Color# inactive"           ;193 Color# inactive
    TCODE    .40,   .35,     "unused         "           ;194 unused
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
	TCODE    .7,    .2,      "Func.Personaliz. III"      ;225 Custom Functions III
    TCODE    .85,   .125,    "pSCR-GF  "                 ;226 pSCR-GF
    TCODE    .0,    .0,      ""		                     ;227 unused
    TCODE    .0,    .0,      ""     	                 ;228 unused
    TCODE    .0,    .0,      ""		                   	 ;229 unused
    TCODE    .0,    .0,      ""		                     ;230 unused
    TCODE    .0,    .0,      ""     	                 ;231 unused
    TCODE    .0,    .0,      ""		                   	 ;232 unused
    TCODE    .0,    .0,      ""		                     ;233 unused
    TCODE    .0,    .0,      ""     	                 ;234 unused

    TCODE    .10,   .2,      "�ModoDeco cambiado!"       ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "No encont"                 ;237 Not found
    TCODE    .100,  .0,      "SetPoint"                  ;238 SetPoint
    TCODE    .100,  .0,      "No Deco"                   ;239 No Deco
    TCODE    .90,   .50,     "Interval:"                 ;240 Interval:
    TCODE    .100,  .75,     "Pantall"                   ;241 Display
    TCODE    .100,  .0,      "No deco"                   ;242 No deco
    TCODE    .132,  .0,      "beta"                      ;243 beta
    TCODE    .100,  .100,    "nouso"                     ;244 unuse
    TCODE    .20,   .65,     "Rein. CF,Gas y Deco"       ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "BatBaja!"                  ;246 LowBatt!
    TCODE    .20,   .125,    "Simulador"                 ;247 Simulator
    TCODE    .30,   .2,      "Simulador OSTC"            ;248 OSTC Simulator
    TCODE    .20,   .65,     "Inicio Buc."               ;249 Start Dive
    TCODE    .100,  .25,     "+ 1m"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1m"                      ;251 - 1m
    TCODE    .100,  .75,     "+10m"                      ;252 +10m
    TCODE    .100,  .100,    "-10m"                      ;253 -10m
    TCODE    .100,  .0,      "Atras"                     ;254 Close
    TCODE    .131,  .170,    "Tiem"                      ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "Fto. fecha: "              ;257 Date format:
    TCODE    .40,   .2,      "Men� Conf. 2:"             ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMDDAA"                    ;259 MMDDYY
    TCODE    .105,  .35,     "DDMMAA"                    ;260 DDMMYY
    TCODE    .105,  .35,     "AAMMDD"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC 
    TCODE    .65,   .168,    "Bail "                     ;263 Bail 
    TCODE    .7,    .48,     "Aire  "                    ;264 Air
    TCODE    .120,  .135,    "Aire  "                    ;265 Air

    TCODE    .0,    .0,      "pSCR Info"             	 ;266 pSCR Info (Must be 9Chars!)
    TCODE    .0,    .216,    "Max."                      ;267 Max.
    TCODE    .0,    .0,      ""     	                 ;268 unused
    TCODE    .0,    .0,      ""		                   	 ;269 unused
    TCODE    .0,    .0,      ""		                     ;270 unused

; New CFs Warning
    TCODE    .0,    .2,      "�Nuevo CF a�adido!"        ;271 New CF added!
    TCODE    .0,    .35,     "�A�adidas nuevas Func."    ;272 New CustomFunctions
    TCODE    .0,    .65,     "Pers.! �Comprobar men�"    ;273 were added! Check
    TCODE    .0,    .95,     "CF I y CF II para"         ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "m�s Detalles!"             ;275 for Details!
    TCODE    .20,   .125,    "Salinidad:"                ;276 Salinity:
;
    TCODE    .20,   .95,     "Tiempo Fondo:"             ;277 Bottom Time:
    TCODE    .20,   .125,    "Prof. Max.:"               ;278 Max. Depth:
    TCODE    .20,   .155,    "Calcular Deco"             ;279 Calculate Deco
    TCODE    .20,   .155,    "Brightness:"          	 ;280 Brightness:
;
    TCODE    .93,   .170,    "ProfMedia"                 ;281 Avr.Depth
    TCODE    .90,   .170,    "TejControl"                ;282 Lead Tiss.
    TCODE    .93,   .170,    "Crono."                    ;283 Stopwatch
    TCODE    .20,   .95,     "Reinic Diario"             ;284 Reset Logbook
    TCODE    .20,   .125,    "Reinic OSTC"               ;285 Reboot OSTC
    TCODE    .20,   .155,    "Rein Datosdeco"            ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "Alt�metro"                 ;287 Altimeter
    TCODE    .38,   .1,      "Fij Alt�metro"             ;288 Set Altimeter
    TCODE    .20,   .35,     "Ref. mar:"                 ;289 Sea ref: 
    TCODE    .0,    .0,      "Activo:  "                 ;290 Enabled:
    TCODE    .20,   .95,     "Defecto: 1013 mbar"        ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Alt: "                     ;294 Alt: 
;
	TCODE    .20,   .95,     "Func.Personaliz.III"       ;295 Custom FunctionsIII
	TCODE    .50,    .2,     "DatosRaw:"                 ;296 Raw Data:
; Gas-setup addons:
    TCODE    .0,    .0,      "MOD:"                      ;297 MOD:                  (max operating depth of a gas).
    TCODE    .0,    .0,      "END:"                      ;298 END:                  (equivalent nitrogen depth of a gas).
    TCODE    .0,    .0,      "EAD:"                      ;299 EAD:                  (equivalent air depth of a gas).
	TCODE    .100,  .125,	 "M�s"						 ;300 More               	(Enable/Disable Gas underwater)
	TCODE    .0,    .2,      "Uso Gas OCR:"              ;301 OCR Gas Usage:        (Planned gas consumtion by tank).
; 115k Bootloader support:
	TCODE	 .45,	.100,	 "CargadorArr"				 ;302 Bootloader
	TCODE	 .40,	.130,	 "�EsperePorf!"				 ;303 Please wait!
	TCODE	 .50,	.130,	 "�Aborta!"					 ;304 Aborted
;@5 variant
    TCODE    .0,    .0,      "Futuro TTS"                ;305 Future TTS            (=10 chars. Title for @5 customview).
;
    TCODE    .100,  .125,    "SalirSim"                  ;306 Quit Sim              (=8char max. Quit Simulator mode)
;Dive interval
    TCODE    .20,   .35,     "Interval:"                 ;307 Interval:
    TCODE    .0,    .0,      "Now    "                   ;308 Now                   (7 chars min)
	TCODE	 .100,	.113,	 "Promedio"			 		 ;309 Average
	TCODE	 .116,	.54,	 "Crono."		 		 	 ;310 Stopwatch             (BIG Stopwatch in Gauge mode)
; Cave consomation
    TCODE    .0,    .0,      "Cave Bail."                ;311 Cave Bail.           (=10 chars.)
; OLED Brightness settings
    TCODE    .103,  .155,    "Eco "	    	             ;312 Eco 					(Same length as #313!)
    TCODE    .103,  .155,    "High" 	                 ;313 High					(Same length as #312!)

; ZH-L16 mode description
    TCODE    .0,    .35,     "Tipodeco: ZH-L16 OC"       ;314 Decotype: ZH-L16 OC
    TCODE    .0,    .65,     "Para Buceo Circuito"       ;315 For Open Circuit
    TCODE    .0,    .95,     "Abierto. Soporta 5 "       ;316 Divers. Supports 5
    TCODE    .0,    .125,    "Gases Trimix.      "       ;317 Trimix Gases.
    TCODE    .0,    .155,    "Configure su gas en"       ;318 Configure your gas
    TCODE    .0,    .185,    "el men� Config. Gas"       ;319 in Gassetup menu.
    TCODE    .0,    .215,    "�Mirar CF11 & CF12!"       ;320 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "Tipodeco: Indicador"       ;321 Decotype: Gauge    
    TCODE    .0,    .65,     "TiempoBuceo ser� en"       ;322 Divetime will be in
    TCODE    .0,    .95,     "Minutos:Segundos.  "       ;323 Minutes:Seconds.   
    TCODE    .0,    .125,    "OSTC2 no calcular� "       ;324 OSTC2 will not     
    TCODE    .0,    .155,    "Deco, tiempo NoVue "       ;325 compute Deco, NoFly
    TCODE    .0,    .185,    "y Desat.           "       ;326 time and Desat.
    TCODE    .0,    .215,    "�Tan s�lo tiempo!  "       ;327 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "Tipodeco: ZH-L16 CC"       ;328 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "Para rebreathers   "       ;329 For Closed
    TCODE    .0,    .95,     "Cerrados"       			 ;330 Circuit rebreathers
    TCODE    .0,    .125,    "Configure los 3    "       ;331 Configure the 3
    TCODE    .0,    .155,    "SetPoints en men�  "       ;332 SetPoints in CCR -
    TCODE    .0,    .185,    "Conf. CCR. Hay 5   "       ;333 Setup menu. 5 bail-
    TCODE    .0,    .215,    "bailouts disponible"       ;334 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "Tipodeco: Apnea    "       ;335 Decotype: Apnoe
    TCODE    .0,    .65,     "OSTC2 mostrar� cada"       ;336 OSTC2 will display
    TCODE    .0,    .95,     "descenso por sepa- "       ;337 each descent separ-
    TCODE    .0,    .125,    "rado en Min:Seg.   "       ;338 ately in Min:Sec.
    TCODE    .0,    .155,    "Temporal.fija frec."       ;339 Will temporally set
    TCODE    .0,    .185,    "muestras a 1 seg.  "       ;340 samplerate to 1 sec
    TCODE    .0,    .215,    "No se calcula Deco "       ;341 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "Tipodeco: L16-GF OC"       ;342 Decotype: L16-GF OC
    TCODE    .0,    .65,     "C�lculos descompr. "       ;343 Decompression cal-
    TCODE    .0,    .95,     "con el m�todo-GF   "       ;344 culations with the
    TCODE    .0,    .125,    "(GF_bajo/GF_alto). "       ;345 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "�Mirar CF32 y CF33!"       ;346 _hi). Check CF32 &
    TCODE    .0,    .185,    "CircuitoAbierto con"       ;347 CF33! Open Circuit
    TCODE    .0,    .215,    "Paradas Profundas. "       ;348 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "Tipodeco: L16-GF CC"       ;349 Decotype: L16-GF CC
    TCODE    .0,    .65,     "C�lculos descompr. "       ;350 Decompression cal-
    TCODE    .0,    .95,     "con el m�todo-GF   "       ;351 culations with the
    TCODE    .0,    .125,    "(GF_bajo/GF_alto). "       ;352 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "�Mirar CF32 & CF33!"       ;353 _hi). Check CF32 &
    TCODE    .0,    .185,    "CircuitoCerrado con"       ;354 CF33!Closed Circuit
    TCODE    .0,    .215,    "Paradas Profundas. "       ;355 with Deep Stops.
; pSCR-GF mode description
    TCODE    .0,    .35,     "Decotype: pSCR-GF"     	;356 Decotype: pSCR-GF
    TCODE    .0,    .65,     "For passive semi-"     	;357 For passive semi-
    TCODE    .0,    .95,     "closed rebreather."    	;358 closed rebreather.
    TCODE    .0,    .125,    "Check CF32 & CF33"     	;359 Check CF32 & CF33
    TCODE    .0,    .155,    "for gradient factors"    	;360 for gradient factors
    TCODE    .0,    .185,    "and CF61-CF63 for"     	;361 and CF61-CF63 for
    TCODE    .0,    .215,    "pSCR features."    		;362 pSCR features.

;

;=============================================================================
