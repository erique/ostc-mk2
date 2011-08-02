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
; 2011/07/25 : Sergei V. Rozinov: Russian translation.
; 2011/07/28 : Sergei V. Rozinov: Corrected.
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
;   macro     X     Y        "translation"               ; English original
    TCODE    .0,   .0,       "������ MD2 ����"           ;001 Building MD2 Hash
    TCODE    .0,   .25,      "���������� �����..."       ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .65,  .2,       "����?"                     ;004 Menu?
    TCODE    .65,  .2,       "����:"                     ;005 Menu:
    TCODE    .20,  .35,      "������"                    ;006 Logbook
    TCODE    .20,  .65,      "��������� �����"           ;007 Gas Setup
    TCODE    .20,  .35,      "��������� �����"           ;008 Set Time
    TCODE    .20,  .95,      "���� ������"               ;009 Reset Menu
    TCODE    .20,  .125,     "���������"                 ;010 Setup
    TCODE    .20,  .185,     "�����"                     ;011 Exit
    TCODE    .104, .2,       "�����..."                  ;012 Wait...
    TCODE    .0,   .24,      "MD2 ���:"                  ;013 MD2 Hash:
    TCODE    .0,   .0,       "�����"                     ;014 Desat         (Desaturation count-down)
    TCODE    .50,  .2,       "���������"                 ;015 Interface		(Connected to USB)
    TCODE    .10,  .30,      "�����"                     ;016 Start
    TCODE    .10,  .55,      "������"                    ;017 Data
    TCODE    .10,  .80,      "���������"                 ;018 Header
    TCODE    .10,  .105,     "�������"                   ;019 Profile
    TCODE    .10,  .130,     "������."                   ;020 Done.
    TCODE    .20,  .35,      "�������� �����"            ;021 Cancel Reset
    TCODE    .32,  .65,      "�����:"                    ;022 Time:
    TCODE    .32,  .95,      "���� :"                    ;023 Date:
    TCODE    .0,   .215,     "���������� ���"            ;024 Set Hours
    TCODE    .6,   .0,       "�����..."                  ;025 Reset...
    TCODE    .55,  .2,       "������"                    ;026 Logbook
    TCODE    .20,  .2,       "���. ��������� I"          ;027 Custom Functions I
    TCODE    .40,  .2,       "���� ������"               ;028 Reset Menu
    TCODE    .15,  .2,       "��������� �������:"        ;029 Set Time:
    TCODE    .100, .50,      "������"                    ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "��������"                  ;031 Decoplan
    TCODE    .100, .0,       "��� ����"                  ;032 Gaslist
    TCODE    .100, .50,      "���.����"                  ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "�����"                     ;034 Exit		        (Exit current menu)
    TCODE    .0,   .0,       "����"                     ;035 NoFly		        (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "������ ����.[m]"           ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "����� ����. [m]"           ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "��� ����� [min]"           ;038 End Delay [min]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "����������[min]"           ;039 Power Off [min]
    TCODE    .40,  .35,      "����-���� [min]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "��������[m/min]"           ;041 velocity[m/min]
    TCODE    .40,  .35,      "���������[mbar]"           ;042 Wake-up  [mbar]
    TCODE    .40,  .35,      "max. ����[mbar]"           ;043 max.Surf.[mbar]
    TCODE    .40,  .35,      "�������� GF [%]"           ;044 GF display  [%]
    TCODE    .40,  .35,      "min.O2 �����[%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "���� ����.[min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "��������� x [%]"           ;047 Saturate x  [%]
    TCODE    .40,  .35,      "���������� x[%]"           ;048 Desaturate x[%]
    TCODE    .40,  .35,      "���� ������[%]"           ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "GF ������� 1[%]"           ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "CNS ������� [%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "���� ����   [m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 ���� [bar]"           ;053 ppO2 low  [bar]
    TCODE    .40,  .35,      "ppO2 �����[bar]"           ;054 ppO2 high [bar]
    TCODE    .40,  .35,      "ppO2 �����[bar]"           ;055 ppO2 show [bar]
    TCODE    .40,  .35,      "�������� ������"           ;056 sampling rate
    TCODE    .40,  .35,      "�������� ������"           ;057 Divisor Temp
    TCODE    .40,  .35,      "�������� ����  "           ;058 Divisor Decodat
    TCODE    .40,  .35,      "�������� �����1"           ;059 Divisor NotUse1
    TCODE    .40,  .35,      "�������� ppO2  "           ;060 Divisor ppO2
    TCODE    .40,  .35,      "�������� ����� "           ;061 Divisor Debug
    TCODE    .40,  .35,      "�������� �����2"           ;062 Divisor NotUse2
    TCODE    .40,  .35,      "CNS ��������[%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "����� � �������"           ;064 Logbook offset
    TCODE    .40,  .35,      "������� ����[m]"           ;065 Last Deco at[m]
    TCODE    .40,  .35,      "����� Apnoe [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "����� ����.���."           ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "��� ��������� ��������"    ;068 This program is
    TCODE    .0,   .65,      "���������������� �"        ;069 distributed in the
    TCODE    .0,   .95,      "�������, ��� ��� �����"    ;070 hope that it will be
    TCODE    .0,   .125,     "��������, �� ����"         ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "������ ��������; �����"    ;072 ANY WARRANTY
    TCODE    .0,   .185,     "��� ���������������"       ;073 even the implied
    TCODE    .0,   .215,     "�������� ������������"     ;074 warranty of
    TCODE    .0,   .35,      "�������� ���"              ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "����������� ���"           ;076 FITNESS FOR A
    TCODE    .0,   .95,      "���������� ����."          ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "������ GNU General"        ;078 See the GNU General
    TCODE    .0,   .155,     "Public License ���"        ;079 Public License for
    TCODE    .0,   .185,     "������ ����������:"        ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .102,  .54,     "��������"                  ;082 Decostop
    TCODE    .0,    .0,      "�/���"                     ;083 m/min
    TCODE    .102,  .113,    "��� ����"                  ;084 No Stop
    TCODE    .135,  .113,    "TTS"                       ;085 TTS
    TCODE    .121,  .0,      "®���"                     ;086 Divetime
    TCODE    .0,    .0,      "�������"                   ;087 Depth
    TCODE    .0,    .0,      "������ ���?"               ;088 First Gas?
    TCODE    .0,    .0,      "���������:"                ;089 Default:
    TCODE    .0,    .0,      "������"                    ;090 Minutes
    TCODE    .0,    .0,      "����� "                    ;091 Month
    TCODE    .0,    .0,      "����  "                    ;092 Day
    TCODE    .0,    .0,      "���   "                    ;093 Year
    TCODE    .0,    .0,      "���������� "               ;094 Set
    TCODE    .0,    .0,      "���# "                     ;095 Gas#
    TCODE    .0,    .0,      "��"                        ;096 Yes
    TCODE    .0,    .0,      "���������:"                ;097 Current:
    TCODE    .23,   .2,      "���� ���������:"           ;098 Setup Menu:
    TCODE    .20,   .35,     "���. ��������� I"          ;099 Custom FunctionsI
    TCODE    .20,   .125,    "��������:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Gauge    "                 ;102 Gauge
    TCODE    .85,   .125,    "Gauge"                     ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "�������� ���? "            ;105 Active Gas?
    TCODE    .10,   .2,      "��������� �����"	         ;106 Gas Setup - Gaslist
    TCODE    .20,   .95,     "����. +/-:"                ;107 Depth +/-:
    TCODE    .20,   .125,    "��������:" 	             ;108 Change:
	TCODE	 .20,	.155,	 "���������:"			  	 ;109 Default:
    TCODE    .20,   .65,     "��������� CCR"             ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "���� ���������� CCR"       ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "SP#"                       ;112 SP#
    TCODE    .20,   .95,     "��������� �������"         ;113 Battery Info
    TCODE    .17,   .2,      "���������� �������"        ;114 Battery Information
    TCODE    .0,    .9,      "������:"                   ;115 Cycles:
    TCODE    .85,   .125,    "Apnoe"                     ;116 Apnoe
    TCODE    .0,    .18,     "����. �������:"            ;117 Last Complete:
    TCODE    .0,    .27,     "������� V���:"             ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "������� ����:"             ;119 Lowest at:
    TCODE    .0,    .45,     "Tmin:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tmax:"                     ;121 Tmax:
    TCODE    .100,  .125,    "�����"		          	 ;122 More (Gaslist)
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "�����"                     ;127 Exit
    TCODE    .100,  .25,     "�������"                   ;128 Delete
    TCODE    .20,   .65,     "�����:"                    ;129 Debug:
    TCODE    .65,   .65,     "��� "                      ;130 ON
    TCODE    .65,   .65,     "����"                      ;131 OFF
    TCODE    .100,  .50,     "����. ���"                 ;132 Del. all
    TCODE    .10,   .0,      "����������� ����� �� "     ;133 Unexpected reset from
    TCODE    .10,   .25,     "������ ����������!   "     ;134 Divemode! Please help
    TCODE    .10,   .50,     "�������� �� ������,  "     ;135 and report the Debug
    TCODE    .10,   .75,     "��������� ����� ����!"     ;136 Information below!
    TCODE    .100,  .75,     "�������"                   ;137 Bailout
    TCODE    .85,   .125,    "Apnoe    "                 ;138 Apnoe
    TCODE    .112,  .120,    "� ����"                    ;139 Descent
    TCODE    .105,  .60,     "�������"                   ;140 Surface
    TCODE    .65,   .2,      "����?"                     ;141 Quit?
    TCODE    .20,   .155,    "�����"                     ;142 More
    TCODE    .42,   .72,     "�������?"                  ;143 Confirm:
    TCODE    .60,   .2,      "���� 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "������"                    ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "�����"            	     ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "ppO2"                      ;149 ppO2
    TCODE    .2,    .39,     "bar "                      ;150 bar
    TCODE    .108,  .216,    "������?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "���. ��������� II"	     ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Low      [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF High     [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "����#   �������"           ;156 Color# Battery
    TCODE    .40,   .35,     "����#  ��������"           ;157 Color# Standard
    TCODE    .40,   .35,     "����# ��� �����"           ;158 Color# Divemask
    TCODE    .40,   .35,     "����# ���������"           ;159 Color# Warnings
    TCODE    .40,   .35,     "����� ����.���."           ;160 Divemode secs.
    TCODE    .40,   .35,     "������. ����.SP"           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "���������. ����"           ;162 Warn Ceiling
    TCODE    .40,   .35,     "�������� ����� "           ;163 Mix type icons
    TCODE    .40,   .35,     "�����. ����.���"           ;164 Blink BetterGas	(Remainder in divemode to switch to a better decompression gas).
	TCODE    .40,   .35,     "����.����[mbar]"           ;165 DepthWarn[mbar]
    TCODE    .40,   .35,     "CNS �������.[%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "GF �������. [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "ppO2 ����.[bar]"           ;168 ppO2 warn [bar]
    TCODE    .40,   .35,     "����.��.[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "��������� �����"           ;170 Time offset/day
    TCODE    .40,   .35,     "����� ���������"           ;171 Show altimeter
    TCODE    .40,   .35,     "�������� ������"           ;172 Show Log-Marker
    TCODE    .40,   .35,     "�������� ������"           ;173 Show Stopwatch
    TCODE    .40,   .35,     "����� ����. ���"           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "����� ����. ���"           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "����.���.������"           ;176 Shallow stop 1st  (Reverse order of deco plans)
    TCODE    .40,   .35,     "������.���[min]"           ;177 Gas switch[min]   (Additional delay in decoplan for gas switches).
    TCODE    .40,   .35,     "����.����[/min]"           ;178 BottomGas[/min]   (Bottom gas usage, for volume estimation).
    TCODE    .40,   .35,     "����.����[/min]"           ;179 AscentGas[/min]   (Ascent+Deco gas usage)
    TCODE    .40,   .35,     "�����. TTS[min]"           ;180 Future TTS[min]   (@5 variant: compute TTS for extra time at current depth)
    TCODE    .40,   .35,     "�� ������������"           ;181 not used
    TCODE    .40,   .35,     "�� ������������"           ;182 not used
    TCODE    .40,   .35,     "�� ������������"           ;183 not used
    TCODE    .40,   .35,     "�� ������������"           ;184 not used
    TCODE    .40,   .35,     "�� ������������"           ;185 not used
; End of function descriptor II
;
    TCODE    .20,   .2,      "���. ��������� II"         ;186 Custom Functions II
    TCODE    .20,   .95,     "�������� ��������"         ;187 Show License
    TCODE    .0,    .2,      "����������:"               ;188 Sim. Results:
    TCODE    .90,   .25,     "�������."                  ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "���."                      ;192 Dil.			       (Rebreather diluent)
; ZH-L16 mode description
    TCODE    .0,    .35,     "��������: ZH-L16 OC"       ;193 Decotype: ZH-L16 OC
    TCODE    .0,    .65,     "��� �������� ����� "       ;194 For Open Circuit
    TCODE    .0,    .95,     "�������. ��������  "       ;195 Divers. Supports 5
    TCODE    .0,    .125,    "�� 5 �������-������"       ;196 Trimix Gases.
    TCODE    .0,    .155,    "������� ���� ����  "       ;197 Configure your gas
    TCODE    .0,    .185,    "� ���� ���������.  "       ;198 in Gassetup menu.
    TCODE    .0,    .215,    "�����. ��11 & ��12!"       ;199 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "��������: Gauge    "       ;200 Decotype: Gauge
    TCODE    .0,    .65,     "����� ��� ����� �  "       ;201 Divetime will be in
    TCODE    .0,    .95,     "���� ������:�������"       ;202 Minutes:Seconds.
    TCODE    .0,    .125,    "OSTC2 �� ��������� "       ;203 OSTC2 will not
    TCODE    .0,    .155,    "������������,      "       ;204 compute Deco, NoFly
    TCODE    .0,    .185,    "������� ����� �   "       ;205 time and Desat.
    TCODE    .0,    .215,    "����� ����������!  "       ;206 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "��������: ZH-L16 CC"       ;207 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "��� (����-)��������"       ;208 For (Semi-)Closed
    TCODE    .0,    .95,     "����� �������.     "       ;209 Circuit rebreathers
    TCODE    .0,    .125,    "������� 3 ���������"       ;210 Configure the 3
    TCODE    .0,    .155,    "� ���� ���������   "       ;211 SetPoints in CCR -
    TCODE    .0,    .185,    "CCR. �������� �� 5 "       ;212 Setup menu. 5 bail-
    TCODE    .0,    .215,    "�������-������.    "       ;213 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "��������: Apnoe    "       ;214 Decotype: Apnoe
    TCODE    .0,    .65,     "OSTC2 ����������   "       ;215 OSTC2 will display
    TCODE    .0,    .95,     "������ ����������  "       ;216 each descent separ-
    TCODE    .0,    .125,    "�������� � ���:���."       ;217 ately in Min:Sec.
    TCODE    .0,    .155,    "�������� ����������"       ;218 Will temporally set
    TCODE    .0,    .185,    "������ ������ 1 ���"       ;219 samplerate to 1 sec
    TCODE    .0,    .215,    "�� ��������� ����! "       ;220 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "��������: L16-GF OC"       ;221 Decotype: L16-GF OC
    TCODE    .0,    .65,     "������ ������������"       ;222 Decompression cal-
    TCODE    .0,    .95,     "� ������� ��������-"       ;223 culations with the
    TCODE    .0,    .125,    "������� (GF_lo/GF  "       ;224 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). �����. ��32 &"       ;225 _hi). Check CF32 &
    TCODE    .0,    .185,    "��33!�������� ����,"       ;226 CF33! Open Circuit
    TCODE    .0,    .215,    "�������� ���������."       ;227 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "��������: L16-GF CC"       ;228 Decotype: L16-GF CC
    TCODE    .0,    .65,     "������ ������������"       ;229 Decompression cal-
    TCODE    .0,    .95,     "� ������� ��������-"       ;230 culations with the
    TCODE    .0,    .125,    "������� (GF_lo/GF  "       ;231 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). �����. ��32 &"       ;232 _hi). Check CF32 &
    TCODE    .0,    .185,    "��33!�������� ����,"       ;233 CF33!Closed Circuit
    TCODE    .0,    .215,    "�������� ���������."       ;234 with Deep Stops.
;
    TCODE    .10,   .2,      "�������� �������!  "       ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "�� ������"                 ;237 Not found
    TCODE    .100,  .0,      "��������"                  ;238 SetPoint
    TCODE    .100,  .0,      "��� ����"                  ;239 No Deco
    TCODE    .90,   .50,     "��������:"                 ;240 Interval:
    TCODE    .100,  .75,     "�������"                   ;241 Display
    TCODE    .100,  .0,      "��� ����"                  ;242 No deco
    TCODE    .132,  .0,      "beta"                      ;243 beta
    TCODE    .100,  .100,    "unuse"                     ;244 unuse
    TCODE    .20,   .65,     "����� ��,��� � ����"       ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "�������!"                  ;246 LowBatt!
    TCODE    .20,   .125,    "�����������"               ;247 Simulator
    TCODE    .30,   .2,      "OSTC �����������"          ;248 OSTC Simulator
    TCODE    .20,   .35,     "������ ��������"           ;249 Start Dive
    TCODE    .100,  .25,     "+ 1�"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1�"                      ;251 - 1m
    TCODE    .100,  .75,     "+10�"                      ;252 +10m
    TCODE    .100,  .100,    "-10�"                      ;253 -10m
    TCODE    .100,  .0,      "�������"                   ;254 Close
    TCODE    .131,  .170,    "����"                      ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "������ ����:"              ;257 Date format:
    TCODE    .23,   .2,      "���� ��������� 2:"         ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMDDYY"                    ;259 MMDDYY
    TCODE    .105,  .35,     "DDMMYY"                    ;260 DDMMYY
    TCODE    .105,  .35,     "YYMMDD"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC
    TCODE    .65,   .168,    "Bail "                     ;263 Bail
    TCODE    .7,    .48,     "Air   "                    ;264 Air
    TCODE    .120,  .135,    "Air   "                    ;265 Air
    TCODE    .2,    .39,     "����������"                ;266 Calibrate
    TCODE    .0,    .216,    "����."                     ;267 Max.
    TCODE    .10,   .8,      "��"                        ;268 not
    TCODE    .10,   .16,     "������!"                   ;269 found!
    TCODE    .0,    .0,      "mV:"                       ;270 mV:
; New CFs Warning
    TCODE    .24,   .2,      "��������� ��!"             ;271 New CF added!
    TCODE    .0,    .35,     "����� ���. ���������"      ;272 New CustomFunctions
    TCODE    .0,    .65,     "���������! ���������"      ;273 were added! Check
    TCODE    .0,    .95,     "���� �� I and �� II"       ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "��� ����������!"           ;275 for Details!
    TCODE    .20,   .95,     "���������: "               ;276 Salinity:
;
    TCODE    .20,   .65,     "����� �� ��� :"            ;277 Bottom Time:
    TCODE    .20,   .95,     "����. �������:"            ;278 Max. Depth:
    TCODE    .20,   .125,    "��������� ����"            ;279 Calculate Deco
    TCODE    .20,   .155,    "�������� ����"             ;280 Show Decoplan
;
    TCODE    .107,  .170,    "Ѯ�����"                   ;281 Avr.Depth
    TCODE    .90,   .170,    "���� �����"                ;282 Lead Tiss.
    TCODE    .114,  .170,    "�����"                    ;283 Stopwatch
    TCODE    .20,   .95,     "����� �������"             ;284 Reset Logbook
    TCODE    .20,   .125,    "������������ OSTC"         ;285 Reboot OSTC
    TCODE    .20,   .155,    "����� ������ ����"         ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "���������"                 ;287 Altimeter
    TCODE    .10,   .1,      "��������� ����������"      ;288 Set Altimeter
    TCODE    .20,   .35,     "����.����: "               ;289 Sea ref:
    TCODE    .0,    .0,      "�������? : "               ;290 Enabled:
    TCODE    .20,   .95,     "���������: 1013 mbar"      ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Alt: "                     ;294 Alt:
;
	TCODE    .20,   .125,    "�������� ����"             ;295 Show raw data
	TCODE    .50,    .2,     "����:"                     ;296 Raw Data:
; Gas-setup addons:
    TCODE    .0,    .0,      "MOD:"                      ;297 MOD:                  (max operating depth of a gas).
    TCODE    .0,    .0,      "END:"                      ;298 END:                  (equivalent nitrogen depth of a gas).
    TCODE    .0,    .0,      "EAD:"                      ;299 EAD:                  (equivalent air depth of a gas).
	TCODE	 .100,	.125,	 "�������?"   				 ;300 Active?               (Enable/Disable Gas underwater)
	TCODE    .0,    .2,      "������ OCR �����:"         ;301 OCR Gas Usage:        (Planned gas consumtion by tank).
; 115k Bootloader support:
	TCODE	 .45,	.100,	 "���������"				 ;302 Bootloader
	TCODE	 .40,	.130,	 "���������� �����!"    	 ;303 Please wait!
	TCODE	 .50,	.130,	 "��������!"				 ;304 Aborted
;@5 variant
    TCODE    .0,    .0,      "�����. TTS"                ;305 Future TTS            (=10 chars. Title for @5 customview).
    TCODE    .100,  .125,    "Quit Sim"                  ;306 Quit Sim (=8char max. Quit Simulator mode)
;Dive interval
    TCODE    .20,   .35,     "Interval:"                 ;307 Interval:
    TCODE    .0,    .0,      "Now    "                   ;308 Now (7 chars min)
	TCODE	 .108,	.112,	 "Average"			 		 ;309 Average
	TCODE	 .94,	.54,	 "Stopwatch"		 		 ;310 Stopwatch (BIG Stopwatch in Gauge mode)
;=============================================================================