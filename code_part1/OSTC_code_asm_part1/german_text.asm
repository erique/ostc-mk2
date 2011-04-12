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
; 2011/03/29 : Oliver J. Albrecht: German translation.
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
    TCODE    .0,   .0,       "Erstelle MD2 Hash"         ;001 Building MD2 Hash
    TCODE    .0,   .25,      "Bitte warten..."           ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .65,  .2,       "Menü?"                     ;004 Menu?
    TCODE    .65,  .2,       "Menü:"                     ;005 Menu:
    TCODE    .20,  .35,      "Logbuch"                   ;006 Logbook
    TCODE    .20,  .65,      "Gas-Einstellungen"         ;007 Gas Setup
    TCODE    .20,  .35,      "Uhrzeit einstellen"        ;008 Set Time
    TCODE    .20,  .95,      "Daten Zurücksetzen"        ;009 Reset Menu
    TCODE    .20,  .125,     "Einstellungen"             ;010 Setup
    TCODE    .20,  .185,     "Ende"                      ;011 Exit
    TCODE    .97, .2,        "Warten..."                 ;012 Wait...
    TCODE    .0,   .24,      "MD2 Hash:"                 ;013 MD2 Hash:
    TCODE    .0,   .0,       "Entsä"                     ;014 Desat         (Desaturation count-down)
    TCODE    .50,  .2,       "Interface"                 ;015 Interface		(Connected to USB)
    TCODE    .10,  .30,      "Start"                     ;016 Start
    TCODE    .10,  .55,      "Daten"                     ;017 Data
    TCODE    .10,  .80,      "Kopfzeile"                 ;018 Header
    TCODE    .10,  .105,     "Profil"                    ;019 Profile
    TCODE    .10,  .130,     "Fertig."                   ;020 Done.
    TCODE    .20,  .35,      "Zurücksetzen abbr."        ;021 Cancel Reset
    TCODE    .32,  .65,      "Uhrzeit:"                  ;022 Time:
    TCODE    .32,  .95,      "Datum:"                    ;023 Date:
    TCODE    .0,   .215,     "Einst.Stunden"             ;024 Set Hours
    TCODE    .6,   .0,       "Zurücksetzen..."           ;025 Reset...
    TCODE    .55,  .2,       "Logbuch"                   ;026 Logbook
    TCODE    .14,  .2,       "Custom Funktionen I"       ;027 Custom Functions I
    TCODE    .14,  .2,       "Daten Zurücksetzen"        ;028 Reset Menu
    TCODE    .14,  .2,       "Uhrzeit einstellen:"       ;029 Set Time:
    TCODE    .100, .50,      "Markern"                   ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "Dekoplan"                  ;031 Decoplan
    TCODE    .100, .0,       "Gasliste"                  ;032 Gaslist
    TCODE    .100, .50,      "DTiefeLö"                  ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "Ende"                      ;034 Exit		        (Exit current menu)
    TCODE    .0,   .0,       "Flugv"                     ;035 NoFly		        (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "TG Start    [m]"           ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "TG Ende     [m]"           ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "TGNachlauf[min]"           ;038 End Delay [min]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "Standby   [min]"           ;039 Power Off [min]
    TCODE    .40,  .35,      "Pre-Menü  [min]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "Geschw. [m/min]"           ;041 velocity[m/min]
    TCODE    .40,  .35,      "Aufwachen[mBar]"           ;042 Wake-up  [mBar]
    TCODE    .40,  .35,      "max.Ober.[mBar]"           ;043 max.Surf.[mBar]
    TCODE    .40,  .35,      "GF Anzeige  [%]"           ;044 GF display  [%]
    TCODE    .40,  .35,      "min. O2 Dis.[%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "TG Menüs  [min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "Sättigung x [%]"           ;047 Saturate x  [%]
    TCODE    .40,  .35,      "Entsätt. x  [%]"           ;048 Desaturate x[%]
    TCODE    .40,  .35,      "Flugv.Ratio [%]"           ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "GF Alarm 1  [%]"           ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "CNSAnzOberf.[%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "Deko Versatz[m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 min. [Bar]"           ;053 ppO2 low  [Bar]
    TCODE    .40,  .35,      "ppO2 max. [Bar]"           ;054 ppO2 high [Bar]
    TCODE    .40,  .35,      "ppO2 anz. [Bar]"           ;055 ppO2 show [Bar]
    TCODE    .40,  .35,      "Abtastrate     "           ;056 sampling rate  
    TCODE    .40,  .35,      "Divisor Temp   "           ;057 Divisor Temp   
    TCODE    .40,  .35,      "Divisor Dekodat"           ;058 Divisor Decodat
    TCODE    .40,  .35,      "Divisor frei1  "           ;059 Divisor NotUse1
    TCODE    .40,  .35,      "Divisor ppO2   "           ;060 Divisor ppO2 
    TCODE    .40,  .35,      "Divisor Debug  "           ;061 Divisor Debug  
    TCODE    .40,  .35,      "Divisor frei2  "           ;062 Divisor NotUse2
    TCODE    .40,  .35,      "CNS-Anz. TG [%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "Logbuch Versatz"           ;064 Logbook offset 
    TCODE    .40,  .35,      "Letzte Deko [m]"           ;065 Last Deco at[m]
    TCODE    .40,  .35,      "Apnoe Ende  [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "Zeige Batt.Volt"           ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "Dieses Programm wird in"   ;068 This program is
    TCODE    .0,   .65,      "der Hoffnung bereit-"      ;069 distributed in the
	TCODE    .0,   .95,      "gestellt, dass es nütz-"   ;070 hope that it will be
    TCODE    .0,   .125,     "lich ist, aber OHNE"       ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "JEDE GEWAEHRLEISTUNG,"     ;072 ANY WARRANTY
    TCODE    .0,   .185,     "auch keine implizierte"    ;073 even the implied
    TCODE    .0,   .215,     "Gebrauchstauglichkeit"     ;074 warranty of
    TCODE    .0,   .35,      "oder Eignung für einen"    ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "bestimmten Zweck."         ;076 FITNESS FOR A
    TCODE    .0,   .95,      "Weitere Informationen"     ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "finden Sie in der GNU"     ;078 See the GNU General
    TCODE    .0,   .155,     "General Public License "   ;079 Public License for
    TCODE    .0,   .185,     "unter:"                    ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .93,  .54,      "Dekostopp"                 ;082 Decostop
    TCODE    .0,    .0,      "m/min"                     ;083 m/min
    TCODE    .100,  .113,    "Nullzeit"                  ;084 No Stop
    TCODE    .135,  .113,    "TTS"                       ;085 TTS
    TCODE    .93,  .0,       "Tauchzeit"                 ;086 Divetime
    TCODE    .0,    .0,      "Tiefe"                     ;087 Depth
    TCODE    .0,    .0,      "Erstes Gas?"               ;088 First Gas?
    TCODE    .0,    .0,      "Standard:"                 ;089 Default:
    TCODE    .0,    .0,      "Minuten"                   ;090 Minutes
    TCODE    .0,    .0,      "Monat  "                   ;091 Month  
    TCODE    .0,    .0,      "Tag    "                   ;092 Day    
    TCODE    .0,    .0,      "Jahr   "                   ;093 Year   
    TCODE    .0,    .0,      "Einst."                    ;094 Set 
    TCODE    .0,    .0,      "Gas# "                     ;095 Gas# 
    TCODE    .0,    .0,      "Ja"                        ;096 Yes
    TCODE    .0,    .0,      "Aktuell: "                 ;097 Current:
    TCODE    .14,   .2,      "Einstellungs-Menü:"        ;098 Setup Menu:
    TCODE    .20,   .35,     "Custom FunktionenI"        ;099 Custom FunctionsI
    TCODE    .20,   .125,    "Dekomod.:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Tiefenme."                 ;102 Gauge    
    TCODE    .85,   .125,    "Tiefenme."                 ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "Aktives Gas? "             ;105 Active Gas?
    TCODE    .10,   .2,      "Gas-Einst. - Gasliste"     ;106 Gas Setup - Gaslist
    TCODE    .0,    .0,      "Tiefe +"		         ;107 Depth +
    TCODE    .0,    .0,      "Tiefe -"			 ;108 Depth -
    TCODE    .20,   .35,     "Zurü."                     ;109 Back
    TCODE    .20,   .65,     "CCR SetPoint Menü"         ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "CCR SetPoint Menü"         ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "SP#"                       ;112 SP#
    TCODE    .20,   .95,     "Batterie Info"             ;113 Battery Info
    TCODE    .10,   .2,      "Batterie Information"      ;114 Battery Information
    TCODE    .0,    .9,      "Zyklen:"                   ;115 Cycles:
    TCODE    .85,   .125,    "Apnoe"                     ;116 Apnoe
    TCODE    .0,    .18,     "Zuletzt voll:"             ;117 Last Complete:
    TCODE    .0,    .27,     "Tiefste Vbatt:"            ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "Datum tief:"               ;119 Lowest at:
    TCODE    .0,    .45,     "Tmin:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tmax:"                     ;121 Tmax:
    TCODE    .100,  .125,    "Mehr"                    	 ;122 More (Gaslist)
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "Ende"                      ;127 Exit
    TCODE    .100,  .25,     "Löschen"                   ;128 Delete
    TCODE    .20,   .65,     "Debug:"                    ;129 Debug:
    TCODE    .65,   .65,     "AN "                       ;130 ON 
    TCODE    .65,   .65,     "AUS"                       ;131 OFF
    TCODE    .100,  .50,     "alle löschen"              ;132 Del. all
    TCODE    .10,   .0,      "Unerwarteter Reset des"    ;133 Unexpected reset from
    TCODE    .10,   .25,     "TG-Modus! Bitte melden"    ;134 Divemode! Please help
    TCODE    .10,   .50,     "Sie die u.a. Debug "       ;135 and report the Debug 
    TCODE    .10,   .75,     "Informationen!"            ;136 Information below!
    TCODE    .100,  .75,     "Bailout"                   ;137 Bailout
    TCODE    .85,   .125,    "Apnoe    "                 ;138 Apnoe    
    TCODE    .105,  .120,    "Abstieg"                   ;139 Descent
    TCODE    .105,  .60,     "Oberfl."                   ;140 Surface
    TCODE    .65,   .2,      "Beenden?"                  ;141 Quit?
    TCODE    .20,   .155,    "Mehr"                      ;142 More
    TCODE    .42,   .72,     "Sicher?"                   ;143 Confirm:
 	TCODE    .60,   .2,      "Menü 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "Zurück"                    ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "Mehr"                      ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "(ppO2:"                    ;149 (ppO2:
    TCODE    .2,    .39,     "Bar) "                     ;150 Bar) 
    TCODE    .108,  .216,    "Marker?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "Custom FunktionenII"       ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Low      [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF High     [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "Farbe# Batterie"           ;156 Color# Battery 
    TCODE    .40,   .35,     "Farbe# Standard"           ;157 Color# Standard
    TCODE    .40,   .35,     "Farbe# Maske   "           ;158 Color# Divemask
    TCODE    .40,   .35,     "Farbe# Warnung "           ;159 Color# Warnings
    TCODE    .40,   .35,     "Tauchmodus Sek."           ;160 Divemode secs. 
    TCODE    .40,   .35,     "Festen SP ände."           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "Warnung Ceiling"           ;162 Warn Ceiling
    TCODE    .40,   .35,     "Gas Mix Symbole"           ;163 Mix type icons
    TCODE    .40,   .35,     "BesseresGasAnz "           ;164 Blink BetterGas	(Remainder in divemode to switch to a better decompression gas).
    TCODE    .40,   .35,     "TiefeWarn[mBar]"           ;165 DepthWarn[mBar]
    TCODE    .40,   .35,     "CNS Warnung [%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "GF Warnung  [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "ppO2 Warn [Bar]"           ;168 ppO2 warn [Bar]
    TCODE    .40,   .35,     "GescWarn[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "ZeitVersatz/Tag"           ;170 Time offset/day
    TCODE    .40,   .35,     "Höhenmesser anz"           ;171 Show altimeter
    TCODE    .40,   .35,     "Log-Marker anz."           ;172 Show Log-Marker
    TCODE    .40,   .35,     "Stoppuhr anz.  "           ;173 Show Stopwatch
    TCODE    .40,   .35,     "Gewebegraph anz"           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "Leitgewebe anz "           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "Flach.StoppOben"           ;176 Shallow stop 1st  (Reverse order of deco plans)
    TCODE    .40,   .35,     "Gaswechsel[min]"           ;177 Gas switch[min]   (Additional delay in decoplan for gas switches).
    TCODE    .40,   .35,     "BottomGas[l/mn]"           ;178 BottomGas[l/mn]   (Bottom gas usage, for volume estimation).
    TCODE    .40,   .35,     "Sonst.Gas[l/mn]"           ;179 AscentGas[l/mn]   (Ascent+Deco gas usage)
    TCODE    .40,   .35,     "nicht verwendet"           ;180 not used
    TCODE    .40,   .35,     "nicht verwendet"           ;181 not used
    TCODE    .40,   .35,     "nicht verwendet"           ;182 not used
    TCODE    .40,   .35,     "nicht verwendet"           ;183 not used
    TCODE    .40,   .35,     "nicht verwendet"           ;184 not used
    TCODE    .40,   .35,     "nicht verwendet"           ;185 not used
; End of function descriptor I
;
    TCODE    .13,   .2,      "Custom Funktionen II"      ;186 Custom Functions II
    TCODE    .20,   .95,     "Lizenz anzeigen "          ;187 Show License
    TCODE    .0,    .2,      "Sim. Daten:"               ;188 Sim. Results:
    TCODE    .90,   .25,     "Oberfl."                   ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "Dil."                      ;192 Dil.			       (Rebreather diluent)
; ZH-L16 mode description
    TCODE    .0,    .35,     "Dekomodell: ZH-L16 OC"     ;193 Decotype: ZH-L16 OC
    TCODE    .0,    .65,     "Für das Tauchen mit"       ;194 For Open Circuit
    TCODE    .0,    .95,     "offenen Systemen. "        ;195 Divers. Supports 5
    TCODE    .0,    .125,    "Bis zu 5 Trimix Gase."     ;196 Trimix Gases.
    TCODE    .0,    .155,    "Hierzu das Menü Gas-"      ;197 Configure your gas
    TCODE    .0,    .185,    "einstellung verwenden."    ;198 in Gassetup menu.
    TCODE    .0,    .215,    "CF11 & CF12 prüfen!"       ;199 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "Dekomodell:Tiefenmesser"   ;200 Decotype: Gauge    
    TCODE    .0,    .65,     "Die Tauchzeit wird in"     ;201 Divetime will be in
    TCODE    .0,    .95,     "Minuten:Sekunden ange-"    ;202 Minutes:Seconds.   
    TCODE    .0,    .125,    "zeigt. Der OSTC2 be-"      ;203 OSTC2 will not     
    TCODE    .0,    .155,    "rechnet keine Daten für"   ;204 compute Deco, NoFly
    TCODE    .0,    .185,    "Deko, Flugverbots- oder"   ;205 time and Desat.
    TCODE    .0,    .215,    "Entsättigungszeiten!"      ;206 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "Dekomodell: ZH-L16 CC"     ;207 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "Für (halb-)geschlossene "  ;208 For (Semi-)Closed
    TCODE    .0,    .95,     "Kreislaufsysteme."         ;209 Circuit rebreathers
    TCODE    .0,    .125,    "Stelle die 3 Setpoints"    ;210 Configure the 3
    TCODE    .0,    .155,    "im CCR Setpoint Menü"      ;211 SetPoints in CCR -
    TCODE    .0,    .185,    "ein. Bis zu 5 Bailout"     ;212 Setup menu. 5 bail-
    TCODE    .0,    .215,    "Gase sind verfügbar."      ;213 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "Dekomodell: Apnoe    "     ;214 Decotype: Apnoe
    TCODE    .0,    .65,     "Der OSTC2 zeigt jeden"     ;215 OSTC2 will display
    TCODE    .0,    .95,     "Abstieg getrennt in"       ;216 each descent separ-
    TCODE    .0,    .125,    "Min:Sek an. Die Abtast-"   ;217 ately in Min:Sec.
    TCODE    .0,    .155,    "rate wird temporär auf"    ;218 Will temporally set
    TCODE    .0,    .185,    "1 Sekunde eingestellt."    ;219 samplerate to 1 sec
    TCODE    .0,    .215,    "Keine Deko Berechnung"     ;220 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "Dekomodell: L16-GF OC"     ;221 Decotype: L16-GF OC
    TCODE    .0,    .65,     "Berechnung der Deko"       ;222 Decompression cal-
    TCODE    .0,    .95,     "mittels der GF-Methode"    ;223 culations with the
    TCODE    .0,    .125,    "(GF_lo/GF_hi). "           ;224 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "Prüfe die CF32 & CF33"     ;225 _hi). Check CF32 &
    TCODE    .0,    .185,    "Werte! Für offene Sys-"    ;226 CF33! Open Circuit
    TCODE    .0,    .215,    "teme mit Tiefenstopps."    ;227 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "Dekomodell: L16-GF CC"     ;228 Decotype: L16-GF CC
    TCODE    .0,    .65,     "Berechnung der Deko"       ;229 Decompression cal-
    TCODE    .0,    .95,     "mittels der GF-Methode"    ;230 culations with the
    TCODE    .0,    .125,    "(GF_lo/GF_hi). Prüfe"      ;231 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "die CF32 & CF33 Werte!"    ;232 _hi). Check CF32 &
    TCODE    .0,    .185,    "Für geschlossene Sys-"     ;233 CF33!Closed Circuit
    TCODE    .0,    .215,    "teme mit Tiefenstopps."    ;234 with Deep Stops.
;
    TCODE    .10,   .2,      "Dekomodell verändert!"     ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "Nicht gefunden"            ;237 Not found
    TCODE    .100,  .0,      "SetPoint"                  ;238 SetPoint
    TCODE    .100,  .0,      "k. Deko"                   ;239 No Deco
    TCODE    .90,   .50,     "Intervall:"                ;240 Interval:
    TCODE    .100,  .75,     "Anzeige"                   ;241 Display
    TCODE    .100,  .0,      "Keine Deko"                ;242 No deco
    TCODE    .132,  .0,      "beta"                      ;243 beta
    TCODE    .100,  .100,    "frei"                      ;244 unuse
    TCODE    .20,   .65,     "CF,Gas&Deko zurücks."      ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "Battery schwach!"          ;246 LowBatt!
    TCODE    .20,   .125,    "Simulator"                 ;247 Simulator
    TCODE    .30,   .2,      "OSTC Simulator"            ;248 OSTC Simulator
    TCODE    .20,   .35,     "TG beginnen"               ;249 Start Dive
    TCODE    .100,  .25,     "+ 1m"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1m"                      ;251 - 1m
    TCODE    .100,  .75,     "+10m"                      ;252 +10m
    TCODE    .100,  .100,    "-10m"                      ;253 -10m
    TCODE    .100,  .0,      "Ende"                      ;254 Close
    TCODE    .128,  .170,    "Zeit"                      ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "Datumsform.:"              ;257 Date format:
    TCODE    .10,   .2,      "Einstellungs-Menü 2:"      ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMDDYY"                    ;259 MMDDYY
    TCODE    .105,  .35,     "DDMMYY"                    ;260 DDMMYY
    TCODE    .105,  .35,     "YYMMDD"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC 
    TCODE    .65,   .168,    "Bail"                      ;263 Bail
    TCODE    .7,    .48,     "Luft  "                    ;264 Air
    TCODE    .120,  .135,    "Luft  "                    ;265 Air
    TCODE    .2,    .39,     "Kalibrieren"               ;266 Calibrate
    TCODE    .0,    .216,    "Max."                      ;267 Max.
    TCODE    .10,   .8,      "nicht"                     ;268 not
    TCODE    .10,   .16,     "gefunden!"                 ;269 found!
    TCODE    .0,    .0,      "mV:"                       ;270 mV:
; New CFs Warning
    TCODE    .10,   .2,      "Neue CF hinzugefügt!"      ;271 New CF added!
    TCODE    .0,    .35,     "Neue Custom Funktionen"    ;272 New CustomFunctions
    TCODE    .0,    .65,     "wurden hinzugefügt!"       ;273 were added! Check
    TCODE    .0,    .95,     "Prüfe CFI und CF II"       ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "Menü für Details!"         ;275 for Details!
    TCODE    .20,   .95,     "Salzgeh.: "                ;276 Salinity:
;
    TCODE    .20,   .65,     "Grundzeit:"                ;277 Bottom Time:
    TCODE    .20,   .95,     "Max. Tiefe:"               ;278 Max. Depth:
    TCODE    .20,   .125,    "Dekoplan berechn."         ;279 Calculate Deco
    TCODE    .20,   .155,    "Dekoplan anzeigen."        ;280 Show Decoplan
;
    TCODE    .107,   .170,   "D-Tiefe"                   ;281 Avr.Depth
    TCODE    .90,   .170,    "Leitgewebe"                ;282 Lead Tiss.
    TCODE    .100,   .170,   "Stoppuhr"                  ;283 Stopwatch
    TCODE    .20,   .95,     "Logbuch zurücks."          ;284 Reset Logbook
    TCODE    .20,   .125,    "OSTC neu starten"          ;285 Reboot OSTC
    TCODE    .20,   .155,    "Dekodaten zurücks."        ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "Höhenmesser"               ;287 Altimeter
    TCODE    .18,   .1,      "Höhenmesser einst."        ;288 Set Altimeter
    TCODE    .20,   .35,     "Höhe NN: "                 ;289 Sea ref: 
    TCODE    .0,    .0,      "Aktiv:   "                 ;290 Enabled:
    TCODE    .20,   .95,     "Normal:  1013 mbar"        ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Höhe "                     ;294 Alt: 
;
    TCODE    .20,   .125,    "Rohdaten anzeigen"         ;295 Show raw data
    TCODE    .50,    .2,     "Rohdaten:"                 ;296 Raw Data:
; Gas-setup addons:
    TCODE    .0,    .0,      "MOD:"                      ;297 MOD:                  (max operating depth of a gas).
    TCODE    .0,    .0,      "END:"                      ;298 END:                  (equivalent nitrogen depth of a gas).
    TCODE    .0,    .0,      "EAD:"                      ;299 EAD:                  (equivalent air depth of a gas).
    TCODE  .100,  .125,	     "Aktiv?"			 ;300 Active?               (Enable/Disable Gas underwater)
    TCODE    .0,    .2,      "OCR Gasverbrauch:"         ;301 OCR Gas Usage:        (Planned gas consumtion by tank).
;=============================================================================
