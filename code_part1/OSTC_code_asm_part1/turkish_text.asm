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
; * Ascii chars: we can support a few specific chars. Oäüß for German.
;   éèêC for French. áíóúñ¡¿ for Spanish.
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
#DEFINE	TXT_IN4			     " in "                      ; " in "                 
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
#DEFINE	TXT_0MIN5			 "0 dk "                     ; "0min "
#DEFINE	TXT_MIN4			 "dk  "                      ; "min "
#DEFINE	TXT_BSAT5			 "BSat:"                     ; "BSat:" 
#DEFINE	TXT_BDES5			 "BDes:"                     ; "BDes:" 
#DEFINE	TXT_LAST5			 "Son: "                     ; "Last:"
#DEFINE	TXT_GFLO6			 "GFmin:"                    ; "GF_lo:"
#DEFINE	TXT_GFHI6			 "GFmax:"                    ; "GF_hi:"
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
                                                                         
#ENDIF                                                                   
;=============================================================================
;   macro     X     Y        "translation"               ; English original
    TCODE    .0,   .0,       "Firmware Kontrol "         ;001 Building MD2 Hash
    TCODE    .0,   .25,      "Lütfen Bekle..."           ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .65,  .2,       "Menü?"                     ;004 Menu?
    TCODE    .65,  .2,       "Menü:"                     ;005 Menu:
    TCODE    .20,  .35,      "LogBook"                   ;006 Logbook
    TCODE    .20,  .65,      "Gaz Karisimi     "         ;007 Gas Setup
    TCODE    .20,  .35,      "Tarih Ayari       "        ;008 Set Time
    TCODE    .20,  .95,      "Fabrika Ayarlari  "        ;009 Reset Menu
    TCODE    .20,  .125,     "Kurulum      "             ;010 Setup
    TCODE    .20,  .185,     "<-- "                      ;011 Exit
    TCODE    .97, .2,        "Bekle... "                 ;012 Wait...
    TCODE    .0,   .24,      "MD2 Hash:"                 ;013 MD2 Hash:
    TCODE    .0,   .0,       "Desat"                     ;014 Desat         (Desaturation count-down)
    TCODE    .50,  .2,       "Inteface "                 ;015 Interface		(Connected to USB)
    TCODE    .10,  .30,      "Basla"                     ;016 Start
    TCODE    .10,  .55,      "Veri "                     ;017 Data
    TCODE    .10,  .80,      "Baslik   "                 ;018 Header
    TCODE    .10,  .105,     "Profil"                    ;019 Profile
    TCODE    .10,  .130,     "Bitti  "                   ;020 Done.
    TCODE    .20,  .35,      "Sifirlama Iptal   "        ;021 Cancel Reset
    TCODE    .32,  .65,      "Saat:   "                  ;022 Time:
    TCODE    .32,  .95,      "Tarih:"                    ;023 Date:
    TCODE    .0,   .215,     "Saati Ayarla "             ;024 Set Hours
    TCODE    .6,   .0,       "Sifirla...     "           ;025 Reset...
    TCODE    .55,  .2,       "LogBook"                   ;026 Logbook
    TCODE    .14,  .2,       "Ozel Fonksiyonlar I"       ;027 Custom Functions I
    TCODE    .14,  .2,       "Menü Sifirla      "        ;028 Reset Menu
    TCODE    .14,  .2,       "Saati Ayarla:      "       ;029 Set Time:
    TCODE    .100, .50,      "Isaret "                   ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "Dekoplan"                  ;031 Decoplan
    TCODE    .100, .0,       "GazListe"                  ;032 Gaslist
    TCODE    .100, .50,      "Sifirla "                  ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "<-- "                      ;034 Exit		        (Exit current menu)
    TCODE    .0,   .0,       "Ucus "                     ;035 NoFly		        (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "Dalis Basla [m]"           ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "Dalis Bitir [m]"           ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "Bekleme    [sn]"           ;038 End Delay [sec]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "Güc Kapama [dk]"           ;039 Power Off [min]
    TCODE    .40,  .35,      "Alt Menü   [dk]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "Hiz      [m/dk]"           ;041 velocity[m/min]
    TCODE    .40,  .35,      "Uyan     [mbar]"           ;042 Wake-up  [mbar]
    TCODE    .40,  .35,      "Max Yüzey[mbar]"           ;043 max.Surf.[mbar]
    TCODE    .40,  .35,      "GF Goster   [%]"           ;044 GF display  [%]
    TCODE    .40,  .35,      "min. O2 Dis.[%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "Dalis Menü[min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "Saturasyon x[%]"           ;047 Saturate x  [%]
    TCODE    .40,  .35,      "Desaturas. x[%]"           ;048 Desaturate x[%]
    TCODE    .40,  .35,      "Ucus Yüzde  [%]"           ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "GF Alarm 1  [%]"           ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "CNS goster  [%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "Deko Ofset  [m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 min. [bar]"           ;053 ppO2 low  [bar]
    TCODE    .40,  .35,      "ppO2 max. [bar]"           ;054 ppO2 high [bar]
    TCODE    .40,  .35,      "ppO2 Gost.[bar]"           ;055 ppO2 show [bar]
    TCODE    .40,  .35,      "Ornekeleme     "           ;056 sampling rate
    TCODE    .40,  .35,      "Sicaklik Orani "           ;057 Divisor Temp
    TCODE    .40,  .35,      "Deko Orani     "           ;058 Divisor Decodat
    TCODE    .40,  .35,      "GF Orani       "           ;059 Divisor GF
    TCODE    .40,  .35,      "ppO2 Orani     "           ;060 Divisor ppO2
    TCODE    .40,  .35,      "Debug Orani    "           ;061 Divisor Debug
    TCODE    .40,  .35,      "CNS Orani      "           ;062 Divisor CNS
    TCODE    .40,  .35,      "CNS-Bilgisi [%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "LogBook Ofset  "           ;064 Logbook offset
    TCODE    .40,  .35,      "Son Deko    [m]"           ;065 Last Deco at[m]
    TCODE    .40,  .35,      "Apnea Bitir [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "Batarya Gücü[v]"           ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "Bu cihaz ve yazilim fay"   ;068 This program is
    TCODE    .0,   .65,      "dali olacagi düsünüle- "   ;069 distributed in the
    TCODE    .0,   .95,      "rek üretilmistir!.     "   ;070 hope that it will be
    TCODE    .0,   .125,     "Ancak herhangi bir ga- "   ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "ranti verilmemektedir. "   ;072 ANY WARRANTY
    TCODE    .0,   .185,     "Bu cihazi ve icindeki  "   ;073 even the implied
    TCODE    .0,   .215,     "yazilimi kullanmak sa- "   ;074 warranty of
    TCODE    .0,   .35,      "dece sizin sorumlulugu-"   ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "nuzdadir.Hicbir sekilde"   ;076 FITNESS FOR A
    TCODE    .0,   .95,      "üretici firma dogacak  "   ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "sorunlardan sorumlu tu-"   ;078 See the GNU General
    TCODE    .0,   .155,     "tulamaz. Daha fazla de-"   ;079 Public License for
    TCODE    .0,   .185,     "yat icin:              "   ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .85,  .54,      "Deko Durak"                ;082 Decostop
    TCODE    .0,    .0,      "m/dk "                     ;083 m/min
    TCODE    .100,  .113,    "Dekosuz "                  ;084 No Stop
    TCODE    .135,  .113,    "TTS"                       ;085 TTS
;   TCODE    .71,  .113,    "Yüzey Varis"                ;085 TTS
    TCODE    .85,  .0,       "Dalis Süre"                ;086 Divetime
    TCODE    .0,    .0,      "Derinlik"                  ;087 Depth
    TCODE    .0,    .0,      "Ilk Gaz ?  "               ;088 First Gas?
    TCODE    .0,    .0,      "Standart:"                 ;089 Default:
    TCODE    .0,    .0,      "Dakika "                   ;090 Minutes
    TCODE    .0,    .0,      "Ay     "                   ;091 Month
    TCODE    .0,    .0,      "Gün    "                   ;092 Day
    TCODE    .0,    .0,      "Yil    "                   ;093 Year
    TCODE    .0,    .0,      "Giris "                    ;094 Set
    TCODE    .0,    .0,      "Gaz# "                     ;095 Gas#
    TCODE    .0,    .0,      "Ok"                        ;096 Yes
    TCODE    .0,    .0,      "Aktif:   "                 ;097 Current:
    TCODE    .14,   .2,      "Ayarlar:          "        ;098 Setup Menu:
    TCODE    .20,   .35,     "Ozel Fonksiyonlar I"       ;099 Custom FunctionsI
    TCODE    .20,   .125,    "Deko Mod:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Derinlik "                 ;102 Gauge
    TCODE    .85,   .125,    "Derinlik "                 ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "Aktif Gaz?   "             ;105 Active Gas?
    TCODE    .10,   .2,      "Gaz Ayarlari : Liste "     ;106 Gas Setup - Gaslist
    TCODE    .20,   .95,     "Derin +/-:"		 ;107 Depth +/-:
    TCODE    .20,   .125,    "Degisti:"			 ;108 Change:
    TCODE    .20,   .155,    "Standart:"                 ;109 Default:
    TCODE    .20,   .65,     "CCR Kismi Basinc "         ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "CCR Kismi Basinc "         ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "SP#"                       ;112 SP#
    TCODE    .20,   .95,     "Batarya Bilgi"             ;113 Battery Info
    TCODE    .10,   .2,      "Batarya Bilgisi     "      ;114 Battery Information
    TCODE    .0,    .9,      "Döngü :"                   ;115 Cycles:
    TCODE    .85,   .125,    "Apnea"                     ;116 Apnoe
    TCODE    .0,    .18,     "En Son Biten:"             ;117 Last Complete:
    TCODE    .0,    .27,     "En Düsük (V): "            ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "En Düsük  :"               ;119 Lowest at:
    TCODE    .0,    .45,     "Tmin:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tmax:"                     ;121 Tmax:
    TCODE    .100,  .125,    "Daha"                    	 ;122 More (Gaslist)
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "Cik "                      ;127 Exit
    TCODE    .100,  .25,     "Sil    "                   ;128 Delete
    TCODE    .20,   .65,     "Debug:"                    ;129 Debug:
    TCODE    .65,   .65,     "ON "                       ;130 ON
    TCODE    .65,   .65,     "OFF"                       ;131 OFF
    TCODE    .100,  .50,     "Hepsini Sil "              ;132 Del. all
    TCODE    .10,   .0,      "Beklenmeyen Reset     "    ;133 Unexpected reset from
    TCODE    .10,   .25,     "Dalis Modu! Lütfen asa"    ;134 Divemode! Please help
    TCODE    .10,   .50,     "gidaki hata kodunu ra"     ;135 and report the Debug
    TCODE    .10,   .75,     "porlayin.     "            ;136 Information below!
    TCODE    .100,  .75,     "Bailout"                   ;137 Bailout
    TCODE    .85,   .125,    "Apnea    "                 ;138 Apnoe
    TCODE    .105,  .120,    "Yüksel "                   ;139 Descent
    TCODE    .105,  .60,     "Yüzey  "                   ;140 Surface
    TCODE    .65,   .2,      "Cikis ? "                  ;141 Quit?
    TCODE    .20,   .155,    "Daha"                      ;142 More
    TCODE    .42,   .72,     "Onayla?"                   ;143 Confirm:
    TCODE    .60,   .2,      "Menü 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "Iptal "                    ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "Daha"                      ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "ppO2"                      ;149 ppO2
    TCODE    .2,    .39,     "bar "                      ;150 bar 
    TCODE    .108,  .216,    "Isaret?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "Ozel Fonksiyonlar II"      ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Düsük    [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF Yüksek   [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "Renk# Batarya  "           ;156 Color# Battery
    TCODE    .40,   .35,     "Renk# Standart "           ;157 Color# Standard
    TCODE    .40,   .35,     "Renk# Dalis    "           ;158 Color# Divemask
    TCODE    .40,   .35,     "Renk# Uyarilar "           ;159 Color# Warnings
    TCODE    .40,   .35,     "Dalis Modu Sn. "           ;160 Divemode secs.
    TCODE    .40,   .35,     "Sabit SP Ayari "           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "Satih Uyarisi  "           ;162 Warn Ceiling
    TCODE    .40,   .35,     "Gaz Mix Ikonlar"           ;163 Mix type icons
    TCODE    .40,   .35,     "En iyi Gaz     "           ;164 Blink BetterGas	(Remainder in divemode to switch to a better decompression gas).
    TCODE    .40,   .35,     "Derinlik [mbar]"           ;165 DepthWarn[mbar]
    TCODE    .40,   .35,     "CNS Uyarisi [%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "GF Uyarisi  [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "ppO2 Uyar.[bar]"           ;168 ppO2 warn [bar]
    TCODE    .40,   .35,     "Hiz Uyar[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "Zaman Ofset/Gün"           ;170 Time offset/day
    TCODE    .40,   .35,     "Yükseklik      "           ;171 Show altimeter
    TCODE    .40,   .35,     "Log Isaret     "           ;172 Show Log-Marker
    TCODE    .40,   .35,     "Kronometre     "           ;173 Show Stopwatch
    TCODE    .40,   .35,     "Doku Grafik    "           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "Oncü Doku      "           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "Ilk Bekleme    "           ;176 Shallow stop 1st  (Reverse order of deco plans)
    TCODE    .40,   .35,     "Gaz Degist[min]"           ;177 Gas switch[min]   (Additional delay in decoplan for gas switches).
    TCODE    .40,   .35,     "Dip Gazi [/min]"           ;178 BottomGas[/min]   (Bottom gas usage, for volume estimation).
    TCODE    .40,   .35,     "Inis Gazi[/min]"           ;179 AscentGas[/min]   (Ascent+Deco gas usage)
    TCODE    .40,   .35,     "TTS @+Min [min]"           ;180 Future TTS[min]   (@5 variant: compute TTS for extra time at current depth)
    TCODE    .40,   .35,     "Hiz Goster     "           ;182 Graph. Velocity	(Show a graphical representation of the ascend speed)
    TCODE    .40,   .35,     "Kullanim Disi  "           ;182 not used
    TCODE    .40,   .35,     "Kullanim Disi  "           ;183 not used
    TCODE    .40,   .35,     "Kullanim Disi  "           ;184 not used
    TCODE    .40,   .35,     "Kullanim Disi  "           ;185 not used
; End of function descriptor II
;
    TCODE    .13,   .2,      "Ozel Fonksiyonlar II"      ;186 Custom Functions II
    TCODE    .20,   .95,     "Lisansi Goster  "          ;187 Show License
    TCODE    .0,    .2,      "Simulasyon:"               ;188 Sim. Results:
    TCODE    .90,   .25,     "Yüzey  "                   ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "Dil."                      ;192 Dil.			       (Rebreather diluent)
; ZH-L16 mode description
    TCODE    .0,    .35,     "Deko Modeli: ZH-L16 OC "   ;193 Decotype: ZH-L16 OC
    TCODE    .0,    .65,     "Standart dalis modeli. "   ;194 For Open Circuit
    TCODE    .0,    .95,     "Cihaz,5 adet Trimix ga-"   ;195 Divers. Supports 5
    TCODE    .0,    .125,    "zini desteklemektedir. "   ;196 Trimix Gases.
    TCODE    .0,    .155,    "Lütfen ozel fonksiyon- "   ;197 Configure your gas
    TCODE    .0,    .185,    "lardan CF11 & CF12 yi  "   ;198 in Gassetup menu.
    TCODE    .0,    .215,    "kontrol ediniz!        "   ;199 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "Deko Modeli:Derinlik   "   ;200 Decotype: Gauge
    TCODE    .0,    .65,     "Dalis zamani dakika ve "   ;201 Divetime will be in
    TCODE    .0,    .95,     "saniye cinsinden göste-"   ;202 Minutes:Seconds.
    TCODE    .0,    .125,    "rilecektir. Bilgisayar "   ;203 OSTC2 will not
    TCODE    .0,    .155,    "hicbir sekilde Deko bil"   ;204 compute Deco, NoFly
    TCODE    .0,    .185,    "gisi hesaplanmayacaktir"   ;205 time and Desat.
    TCODE    .0,    .215,    "                       "   ;206 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "Deko Modeli: ZH-L16 CC "   ;207 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "Tam/(Yari) Kapali Devre"   ;208 For (Semi-)Closed
    TCODE    .0,    .95,     "Geri Solutucu icin üc  "   ;209 Circuit rebreathers
    TCODE    .0,    .125,    "farkli kismi basinc gi-"   ;210 Configure the 3
    TCODE    .0,    .155,    "risi yapabilirsiniz.   "   ;211 SetPoints in CCR -
    TCODE    .0,    .185,    "Ayrica 5 adet Bailout  "   ;212 Setup menu. 5 bail-
    TCODE    .0,    .215,    "sistemde bulunmaktadir."   ;213 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "Deko Modeli: Apnea     "   ;214 Decotype: Apnoe
    TCODE    .0,    .65,     "OSTC2 sadece yükselis  "   ;215 OSTC2 will display
    TCODE    .0,    .95,     "bilgisini dakika ve    "   ;216 each descent separ-
    TCODE    .0,    .125,    "saniye cinsinden goste-"   ;217 ately in Min:Sec.
    TCODE    .0,    .155,    "recektir. Deko hesapla "   ;218 Will temporally set
    TCODE    .0,    .185,    "masi yapilmayacaktir!  "   ;219 samplerate to 1 sec
    TCODE    .0,    .215,    "                       "   ;220 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "Deko Modeli: L16-GF OC "   ;221 Decotype: L16-GF OC
    TCODE    .0,    .65,     "Deko hesaplamalari GF- "   ;222 Decompression cal-
    TCODE    .0,    .95,     "Gradient Factor'e göre "   ;223 culations with the
    TCODE    .0,    .125,    "yapilmaktadir. Lütfen  "   ;224 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "CF32 & CF33 nolu fonksi"   ;225 _hi). Check CF32 &
    TCODE    .0,    .185,    "yonlari kontrol ediniz."   ;226 CF33! Open Circuit
    TCODE    .0,    .215,    "Derin Durak mevcuttur. "   ;227 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "Deko Modeli: L16-GF CC "   ;228 Decotype: L16-GF CC
    TCODE    .0,    .65,     "Deko hesaplamalari GF- "   ;229 Decompression cal-
    TCODE    .0,    .95,     "Gradient Factor'e göre "   ;230 culations with the
    TCODE    .0,    .125,    "yapilmaktadir. Lütfen  "   ;231 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "CF32 & CF33 nolu fonksi"   ;232 _hi). Check CF32 &
    TCODE    .0,    .185,    "yonlari kontrol ediniz."   ;233 CF33!Closed Circuit
    TCODE    .0,    .215,    "Kapali(Yari) Kapali Dev"  ;234 with Deep Stops.
;
    TCODE    .10,   .2,      "Deko Modeli Degisti!"      ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "Bulunamadi!   "            ;237 Not found
    TCODE    .100,  .0,      "Kismi Basinc"              ;238 SetPoint
    TCODE    .100,  .0,      "Dekosuz"                   ;239 No Deco
    TCODE    .90,   .50,     "Zamani:   "                ;240 Interval:
    TCODE    .100,  .75,     "Goster "                   ;241 Display
    TCODE    .100,  .0,      "Kalan Deko"                ;242 No deco
    TCODE    .132,  .0,      "beta"                      ;243 beta
    TCODE    .100,  .100,    "iptal"                     ;244 unuse
    TCODE    .20,   .65,     "Gaz & Deko Sifirla  "      ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "Düsük Batarya!  "          ;246 LowBatt!
    TCODE    .20,   .125,    "Simulator"                 ;247 Simulator
    TCODE    .30,   .2,      "OSTC Simulator"            ;248 OSTC Simulator
    TCODE    .20,   .65,     "Dalisa Basla"              ;249 Start Dive
    TCODE    .100,  .25,     "+ 1m"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1m"                      ;251 - 1m
    TCODE    .100,  .75,     "+10m"                      ;252 +10m
    TCODE    .100,  .100,    "-10m"                      ;253 -10m
    TCODE    .100,  .0,      "<-- "                      ;254 Close
    TCODE    .128,  .170,    "Zam."                      ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "Tarih :"                   ;257 Date format:
    TCODE    .10,   .2,      "Ekstra Ayarlar:     "      ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMDDYY"                    ;259 MMDDYY
    TCODE    .105,  .35,     "DDMMYY"                    ;260 DDMMYY
    TCODE    .105,  .35,     "YYMMDD"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC 
    TCODE    .65,   .168,    "Bail "                     ;263 Bail 
    TCODE    .7,    .48,     "Hava  "                    ;264 Air
    TCODE    .120,  .135,    "Hava  "                    ;265 Air

    TCODE    .0,    .0,      ""             			 ;266 unused
    TCODE    .0,    .216,    "Max"                       ;267 Max.
    TCODE    .0,    .0,      ""     	                 ;268 unused
    TCODE    .0,    .0,      ""		                   	 ;269 unused
    TCODE    .0,    .0,      ""		                     ;270 unused

; New CFs Warning
    TCODE    .10,   .2,      "Yeni Fonksiyonlar   "      ;271 New CF added!
    TCODE    .0,    .35,     "Yeni Fonksiyonlar     "    ;272 New CustomFunctions
    TCODE    .0,    .65,     "Eklendi,Lütfen     "       ;273 were added! Check
    TCODE    .0,    .95,     "Ozel Fonksiyonlari "       ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "Kontrol Ediniz!  "         ;275 for Details!
    TCODE    .20,   .95,     "Tuzluluk: "                ;276 Salinity:
;
    TCODE    .20,   .95,     "Dip Zaman:"                ;277 Bottom Time:
    TCODE    .20,   .125,    "Derinlik :"                ;278 Max. Depth:
    TCODE    .20,   .155,    "Deko Hesapla     "         ;279 Calculate Deco
   	TCODE    .20,   .155,    "Parlaklik:"            	 ;280 Brightness:
;
    TCODE    .107,   .170,   "Ort.Der"                   ;281 Avr.Depth
    TCODE    .90,   .170,    "Kompartman"                ;282 Lead Tiss.
    TCODE    .100,   .170,   "Kronomet"                  ;283 Stopwatch
    TCODE    .20,   .95,     "LogBook Sifirla "          ;284 Reset Logbook
    TCODE    .20,   .125,    "OSTC Baslat!    "          ;285 Reboot OSTC
    TCODE    .20,   .155,    "Deko Bilgisi Sil  "        ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "Altimetre  "               ;287 Altimeter
    TCODE    .18,   .1,      "Altimetre Ayarla  "        ;288 Set Altimeter
    TCODE    .20,   .35,     "Deniz:   "                 ;289 Sea ref:
    TCODE    .0,    .0,      "Aktif:   "                 ;290 Enabled:
    TCODE    .20,   .95,     "Normal:  1013 mbar"        ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Alt: "                     ;294 Alt:
;
    TCODE    .20,   .125,    "Degiskenler...   "         ;295 Show raw data
    TCODE    .50,    .2,     "Degiskenler"               ;296 Raw Data:
; Gas-setup addons:
    TCODE    .0,    .0,      "MOD:"                      ;297 MOD:                  (max operating depth of a gas).
    TCODE    .0,    .0,      "END:"                      ;298 END:                  (equivalent nitrogen depth of a gas).
    TCODE    .0,    .0,      "EAD:"                      ;299 EAD:                  (equivalent air depth of a gas).
    TCODE    .100,  .125,	 "Aktif?"			 		 ;300 Active?               (Enable/Disable Gas underwater)
    TCODE    .0,    .2,      "OCR Gaz kullanim:"         ;301 OCR Gas Usage:        (Planned gas consumtion by tank).
; 115k Bootloader support:
	TCODE	 .45,	.100,	 "Yükleniyor"				 ;302 Bootloader
	TCODE	 .35,	.130,	 "Lütfen Bekle!"			 ;303 Please wait!
	TCODE	 .40,	.130,	 "Iptal Edildi"				 ;304 Aborted
;@5 variant
    TCODE    .0,    .0,      "TTS @+Min."                ;305 Future TTS            (=10 chars. Title for @5 customview).
;
    TCODE    .100,  .125,    "Menü    "                  ;306 Quit Sim (=8char max. Quit Simulator mode)
;Dive interval
    TCODE    .20,   .35,     "Zaman :  "                 ;307 Interval:
    TCODE    .0,    .0,      "simdi  "                   ;308 Now (7 chars min)
    TCODE   .10,   .113,     "Ortalama" 	 		 	 ;309 Average
    TCODE   .109,  .54,	     "Krono. "		 		 	 ;310 Stopwatch (BIG Stopwatch in Gauge mode)
; Cave consomation
    TCODE    .0,    .0,      "Cave Bail."                ;311 Cave Bail.            (=10 chars.)
; OLED Brightness settings
    TCODE    .103,  .155,    "Dusuk "    	             ;312 Eco 					(Same length as #313!)
    TCODE    .103,  .155,    "Parlak" 	                 ;313 High					(Same length as #312!)

;=============================================================================
