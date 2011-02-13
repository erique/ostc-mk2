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
; 2011/02/02 : Jean-Do Gascuel: split into different files for multi-lingual support
; 2011/02/09 : Pierre Vidalot: French translation.
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
    TCODE    .0,   .0,       "Calcul du hash MD2"        ;001 Building MD2 Hash
    TCODE    .0,   .25,      "Attendez SVP..."           ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .65,  .2,       "Menu?"                     ;004 Menu?
    TCODE    .65,  .2,       "Menu:"                     ;005 Menu:
    TCODE    .20,  .35,      "Carnet de plong�es"        ;006 Logbook
    TCODE    .20,  .65,      "R�glage des Gaz"           ;007 Gas Setup
    TCODE    .20,  .35,      "R�glage Heure"             ;008 Set Time
    TCODE    .20,  .95,      "Remises a z�ro"            ;009 Reset Menu
    TCODE    .20,  .125,     "Menu R�glages"             ;010 Setup
    TCODE    .20,  .185,     "Sortir"                    ;011 Exit
    TCODE    .83,  .2,       "Attendre..."               ;012 Wait..
    TCODE    .0,   .24,      "Hash MD2:"                 ;013 MD2 Hash:
    TCODE    .0,   .0,       "D�sat"                     ;014 Desat         (Desaturation count-down)
    TCODE    .50,  .2,       "Interface"                 ;015 Interface		(Connected to USB)
    TCODE    .10,  .30,      "D�marrer"                  ;016 Start
    TCODE    .10,  .55,      "Donn�es"                   ;017 Data
    TCODE    .10,  .80,      "En-t�te"                   ;018 Header
    TCODE    .10,  .105,     "Profil"                    ;019 Profile
    TCODE    .10,  .130,     "Fait."                     ;020 Done.
    TCODE    .20,  .35,      "Annuler RaZ"               ;021 Cancel Reset
    TCODE    .32,  .65,      "Heure:"                    ;022 Time:
    TCODE    .32,  .95,      "Date :"                    ;023 Date:
    TCODE    .32,  .155,     "R�g. Heures"               ;024 Set Hours
    TCODE    .6,   .0,       "Initialisation..."         ;025 Reset...
    TCODE    .17,  .2,       "Carnet de plong�es"        ;026 Logbook
    TCODE    .14,  .2,       "Config Fonctions I"        ;027 Custom Functions I
    TCODE    .31,  .2,       "Remises a z�ro:"           ;028 Reset Menu
    TCODE    .50,  .2,       "Reg.Heure:"                ;029 Set Time:
    TCODE    .100, .50,      "Rep�re"                    ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "Paliers"                   ;031 Decoplan
    TCODE    .100, .0,       "ListeGaz"                  ;032 Gaslist
    TCODE    .100, .50,      "RazMoyn."                  ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "Sortir"                    ;034 Exit              (Exit current menu)
    TCODE    .0,   .0,       "SansAvion"                 ;035 NoFly             (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "D�but Plong.[m]"           ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "Fin Plong�e [m]"           ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "D�lai Fin [min]"           ;038 End Delay [min]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "Eteindre  [min]"           ;039 Power Off [min]
    TCODE    .40,  .35,      "Pr�-menu  [min]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "Vitesse [m/min]"           ;041 velocity[m/min]
    TCODE    .40,  .35,      "Allumer  [mBar]"           ;042 Wake-up  [mBar]
    TCODE    .40,  .35,      "Max.Surf.[mBar]"           ;043 max.Surf.[mBar]
    TCODE    .40,  .35,      "Affichage GF[%]"           ;044 GF display  [%]
    TCODE    .40,  .35,      "Aff. O2 min [%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "MenusPlong[min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "Saturat. x  [%]"           ;047 Saturate x  [%]
    TCODE    .40,  .35,      "Desaturat. x[%]"           ;048 Desaturate x[%]
    TCODE    .40,  .35,      "NoFly Ratio [%]"           ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "Alarme GF   [%]"           ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "Aff.CNS Surf[%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "D�cal. D�co [m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 mini [Bar]"           ;053 ppO2 low  [Bar]
    TCODE    .40,  .35,      "ppO2 maxi [Bar]"           ;054 ppO2 high [Bar]
    TCODE    .40,  .35,      "Aff. ppO2 [Bar]"           ;055 ppO2 show [Bar]
    TCODE    .40,  .35,      "Freq. Mesures  "           ;056 sampling rate  
    TCODE    .40,  .35,      "Diviseur Temp. "           ;057 Divisor Temp   
    TCODE    .40,  .35,      "Divis.Donn.D�co"           ;058 Divisor Decodat
    TCODE    .40,  .35,      "Diviseur NotUse"           ;059 Divisor NotUse1
    TCODE    .40,  .35,      "Diviseur ppO2  "           ;060 Divisor ppO2 
    TCODE    .40,  .35,      "Diviseur Debug "           ;061 Divisor Debug  
    TCODE    .40,  .35,      "Diviseur NotUse"           ;062 Divisor NotUse2
    TCODE    .40,  .35,      "Aff.CNSPlong[%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "D�calage Carnet"           ;064 Logbook offset 
    TCODE    .40,  .35,      "Dern. Palier[m]"           ;065 Last Deco at[m]
    TCODE    .40,  .35,      "Fin Apn�e   [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "Aff.TensionBatt"           ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "Ce    programme    est"    ;068 This program is
    TCODE    .0,   .65,      "distribu�  dans le but"    ;069 distributed in the
    TCODE    .0,   .95,      "d'�tre   utile,   mais"    ;070 hope that it will be
    TCODE    .0,   .125,     "SANS AUCUNE  GARANTIE;"    ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "sans m�me  la garantie"    ;072 ANY WARRANTY
    TCODE    .0,   .185,     "tacite    de   QUALITE"    ;073 even the implied
    TCODE    .0,   .215,     "MARCHANDE           ou"    ;074 warranty of
    TCODE    .0,   .35,      "D'ADEQUATION    A   UN"    ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "USAGE PARTICULIER."        ;076 FITNESS FOR A
    TCODE    .0,   .95,      "R�f�rez-vous    a   la"    ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "Licence       Publique"    ;078 See the GNU General
    TCODE    .0,   .155,     "G�n�rale GNU pour plus"    ;079 Public License for
    TCODE    .0,   .185,     "de d�tails sur:"           ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .118,  .54,     "Palier"                    ;082 Decostop
    TCODE    .0,    .0,      "m/min"                     ;083 m/min
    TCODE    .87,   .113,    "SansPalier"                ;084 No Stop
    TCODE    .135,  .113,    "DTR"                       ;085 TTS
    TCODE    .121,  .0,      "Dur�e"                     ;086 Divetime
    TCODE    .0,    .0,      "Profondeur"                ;087 Depth
    TCODE    .0,    .0,      "Premier Gaz?"              ;088 First Gas?
    TCODE    .0,    .0,      "D�faut:"                   ;089 Default:
    TCODE    .0,    .0,      "Minutes"                   ;090 Minutes
    TCODE    .0,    .0,      "Mois   "                   ;091 Month  
    TCODE    .0,    .0,      "Jour   "                   ;092 Day    
    TCODE    .0,    .0,      "Ann�e  "                   ;093 Year   
    TCODE    .0,    .0,      "R�g."                      ;094 Set 
    TCODE    .0,    .0,      "#Gaz "                     ;095 Gas# 
    TCODE    .0,    .0,      "Oui"                       ;096 Yes
    TCODE    .0,    .0,      "Valeur:"                   ;097 Current:
    TCODE    .31,   .2,      "Menu R�glages:"            ;098 Setup Menu:
    TCODE    .20,   .35,     "Config Fonctions I"        ;099 Custom FunctionsI
    TCODE    .20,   .125,    "ModeD�co:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Profondi."                 ;102 Gauge    
    TCODE    .85,   .125,    "Profondi."                 ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "Gaz Actif ? "              ;105 Active Gas?
    TCODE    .31,   .2,      "Liste des Gaz:"            ;106 Gas Setup - Gaslist
    TCODE    .0,    .0,      "Prof. +"  		         ;107 Depth +
    TCODE    .0,    .0,      "Prof. -"	                 ;108 Depth -
    TCODE    .20,   .35,     "Pr�c."                     ;109 Back
    TCODE    .20,   .65,     "Menu SetPoint CCR"         ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "Menu SetPoint CCR"         ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "#SP"                       ;112 SP#
    TCODE    .20,   .95,     "Info Batterie"             ;113 Battery Info
    TCODE    .6,   .2,       "Informations Batterie"     ;114 Battery Information
    TCODE    .0,    .9,      "Cycles:"                   ;115 Cycles:
    TCODE    .85,   .125,    "Apn�e"                     ;116 Apnoe
    TCODE    .0,    .18,     "Dern.Compl�te:"            ;117 Last Complete:
    TCODE    .0,    .27,     "PlusBas Vbat:"             ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "PlusBas le :"              ;119 Lowest at:
    TCODE    .0,    .45,     "Tmin:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tmax:"                     ;121 Tmax:
    TCODE    .100,  .125,    "Gaz 6.."                   ;122 Gas 6..
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "Sortie"                    ;127 Exit
    TCODE    .100,  .25,     "Suppr."                    ;128 Delete
    TCODE    .20,   .65,     "D�bug:"                    ;129 Debug:
    TCODE    .65,   .65,     "ON "                       ;130 ON 
    TCODE    .65,   .65,     "OFF"                       ;131 OFF
    TCODE    .100,  .50,     "Suppr.tout"                ;132 Del. all
    TCODE    .10,   .0,      "R�initialisation"          ;133 Unexpected reset from
    TCODE    .10,   .25,     "inattendue! Merci de"      ;134 Divemode! Please help
    TCODE    .10,   .50,     "reporter les donn�es"      ;135 and report the Debug 
    TCODE    .10,   .75,     "d'analyse ci-dessous:"     ;136 Information below!
    TCODE    .100,  .75,     "Bailout"                   ;137 Bailout
    TCODE    .85,   .125,    "Apn�e    "                 ;138 Apnoe    
    TCODE    .105,  .120,    "D�scente"                  ;139 Descent
    TCODE    .105,  .60,     "Surface"                   ;140 Surface
    TCODE    .65,   .2,      "Quit?"                     ;141 Quit?
    TCODE    .20,   .155,    "Suite..."                  ;142 More
    TCODE    .42,   .72,     "Confirm:"                  ;143 Confirm:
    TCODE    .55,   .2,      "Menu 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "Annul."                    ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "Suite..."                  ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "(ppO2:"                    ;149 (ppO2:
    TCODE    .2,    .39,     "Bar) "                     ;150 Bar) 
    TCODE    .108,  .216,    "Rep�re?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "Config Fonctions II"       ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Bas      [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF Haut     [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "CouleurBatterie"           ;156 Color# Battery 
    TCODE    .40,   .35,     "CouleurStandard"           ;157 Color# Standard
    TCODE    .40,   .35,     "Couleur Legende"           ;158 Color# Divemask
    TCODE    .40,   .35,     "Couleur Alarmes"           ;159 Color# Warnings
    TCODE    .40,   .35,     "Secs.TempsPlong"           ;160 Divemode secs. 
    TCODE    .40,   .35,     "Ajuster SP fixe"           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "Alarme Plafond "           ;162 Warn Ceiling
    TCODE    .40,   .35,     "Icone Type M�l."           ;163 Mix type icons
    TCODE    .40,   .35,     "Aff.MeilleurGaz"           ;164 Blink BetterGas	(Remainder in divemode to switch to a beter decompression gas).
    TCODE    .40,   .35,     "AlarmProf[mBar]"           ;165 DepthWarn[mBar]
    TCODE    .40,   .35,     "Alarme CNS  [%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "Alarme GF   [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "Al. ppO2  [Bar]"           ;168 ppO2 warn [Bar]
    TCODE    .40,   .35,     "Al.Vites[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "D�cal Heur/Jour"           ;170 Time offset/day
    TCODE    .40,   .35,     "Aff. Altim�tre "           ;171 Show altimeter
    TCODE    .40,   .35,     "Aff. Rep�re    "           ;172 Show Log-Marker
    TCODE    .40,   .35,     "Aff. Chrono.   "           ;173 Show Stopwatch
    TCODE    .40,   .35,     "Aff.GraphTissus"           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "Aff.Tiss.Direct"           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "Prof.DernPalier"           ;176 Shalow stop 1st
    TCODE    .40,   .35,     "non utilis�    "           ;177 not used
    TCODE    .40,   .35,     "non utilis�    "           ;178 not used
    TCODE    .40,   .35,     "non utilis�    "           ;179 not used
    TCODE    .40,   .35,     "non utilis�    "           ;180 not used
    TCODE    .40,   .35,     "non utilis�    "           ;181 not used
    TCODE    .40,   .35,     "non utilis�    "           ;182 not used
    TCODE    .40,   .35,     "non utilis�    "           ;183 not used
    TCODE    .40,   .35,     "non utilis�    "           ;184 not used
    TCODE    .40,   .35,     "non utilis�    "           ;185 not used
; End of function descriptor I
;
    TCODE    .13,   .2,      "Config Fonctions II"       ;186 Custom Functions II
    TCODE    .20,   .95,     "Voir la licence"           ;187 Show License
    TCODE    .0,    .2,      "R�sultat Sim:"             ;188 Sim. Results:
    TCODE    .90,   .25,     "Surface"                   ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "Dil."                      ;192 Dil.			       (Rebreather diluant)
; ZH-L16 mode description
    TCODE    .0,    .35,     "TypeD�co: ZH-L16 OC   "    ;193 Decotype: ZH-L16 OC	(22 chars maximum)
    TCODE    .0,    .65,     "Pour les plongeurs  en"    ;194 For Open Circuit
    TCODE    .0,    .95,     "Circuit Ouvert.       "    ;195 Divers. Supports 5
    TCODE    .0,    .125,    "Supporte 5 Gaz Trimix."    ;196 Trimix Gases.
    TCODE    .0,    .155,    "Config des gaz dans le"    ;197 Configure your gas
    TCODE    .0,    .185,    "menu R�glage des Gaz. "    ;198 in Gassetup menu.
    TCODE    .0,    .215,    "V�rifiez CF11 & CF12 !"    ;199 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "TypeD�co:Profondim�tre"    ;200 Decotype: Gauge    
    TCODE    .0,    .65,     "La dur�e  est affich�e"    ;201 Divetime will be in
    TCODE    .0,    .95,     "en Minutes:Secondes.  "    ;202 Minutes:Seconds.   
    TCODE    .0,    .125,    "L'OSTC2  ne  calculera"    ;203 OSTC2 will not     
    TCODE    .0,    .155,    "pas de D�co,  de dur�e"    ;204 compute Deco, NoFly
    TCODE    .0,    .185,    "sans avion ni de temps"    ;205 time and Desat.
    TCODE    .0,    .215,    "de d�saturation !     "    ;206 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "TypeD�co: ZH-L16 CC   "    ;207 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "Pour les  recycleurs a"    ;208 For (Semi-)Closed
    TCODE    .0,    .95,     "circuit (semi-)ferm�. "    ;209 Circuit rebreathers
    TCODE    .0,    .125,    "Configurez    les    3"    ;210 Configure the 3
    TCODE    .0,    .155,    "SetPoints   dans    le"    ;211 SetPoints in CCR -
    TCODE    .0,    .185,    "Menu SetPoint CCR.    "    ;212 Setup menu. 5 bail-
    TCODE    .0,    .215,    "5 bailouts disponibles"    ;213 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "TypeD�co: Apn�e       "    ;214 Decotype: Apnoe
    TCODE    .0,    .65,     "L'OSTC2 affichera  les"    ;215 OSTC2 will display
    TCODE    .0,    .95,     "descentes   s�par�ment"    ;216 each descent separ-
    TCODE    .0,    .125,    "en    Minutes:Secondes"    ;217 ately in Min:Sec.
    TCODE    .0,    .155,    "sans calculer de D�co."    ;218 Will temporally set
    TCODE    .0,    .185,    "Les  mesures  se  font"    ;219 samplerate to 1 sec
    TCODE    .0,    .215,    "toutes les secondes.  "    ;220 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "TypeD�co: L16-GF OC   "    ;221 Decotype: L16-GF OC
    TCODE    .0,    .65,     "Calcul  de  D�co  avec"    ;222 Decompression cal-
    TCODE    .0,    .95,     "Facteurs  de  Gradient"    ;223 culations with the
    TCODE    .0,    .125,    "(GF_bas/GF_haut).     "    ;224 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "V�rifiez CF32 & CF33 !"    ;225 _hi). Check CF32 &
    TCODE    .0,    .185,    "Pour  Circuit   Ouvert"    ;226 CF33! Open Circuit
    TCODE    .0,    .215,    "avec paliers profonds."    ;227 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "TypeD�co: L16-GF CC   "    ;228 Decotype: L16-GF CC
    TCODE    .0,    .65,     "Calcul  de  D�co  avec"    ;229 Decompression cal-
    TCODE    .0,    .95,     "Facteurs  de  Gradient"    ;230 culations with the
    TCODE    .0,    .125,    "(GF_bas/GF_haut).     "    ;231 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "V�rifiez CF32 & CF33 !"    ;232 _hi). Check CF32 &
    TCODE    .0,    .185,    "Pour   Circuit   Ferm�"    ;233 CF33!Closed Circuit
    TCODE    .0,    .215,    "avec paliers profonds."    ;234 with Deep Stops.
;
    TCODE    .10,   .2,      "Mode de D�co chang�!"      ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "Non trouv�"                ;237 Not found
    TCODE    .100,  .0,      "SetPoint"                  ;238 SetPoint
    TCODE    .100,  .0,      "PasD�co"                   ;239 No Deco
    TCODE    .90,   .50,     "Interval:"                 ;240 Interval:
    TCODE    .100,  .75,     "Contrast"                  ;241 Display
    TCODE    .100,  .0,      "PasD�co"                   ;242 No deco
    TCODE    .132,  .0,      "b�ta"                      ;243 beta
    TCODE    .100,  .100,    "unuse"                     ;244 unuse
    TCODE    .20,   .65,     "RaZ CF,Gaz & D�co"         ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "BattFaible!"               ;246 LowBatt!
    TCODE    .20,   .125,    "Simulateur"                ;247 Simulator
    TCODE    .27,   .2,      "Simulateur OSTC"           ;248 OSTC Simulator
    TCODE    .20,   .35,     "Mode Simulation..."        ;249 Start Dive
    TCODE    .100,  .25,     "+ 1m"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1m"                      ;251 - 1m
    TCODE    .100,  .75,     "+10m"                      ;252 +10m
    TCODE    .100,  .100,    "-10m"                      ;253 -10m
    TCODE    .100,  .0,      "Fermer"                    ;254 Close
    TCODE    .125,  .170,    "Heure"                     ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "Format Date:"              ;257 Date format:
    TCODE    .24,   .2,      "Menu R�glages 2:"          ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMJJAA"                    ;259 MMDDYY
    TCODE    .105,  .35,     "JJMMAA"                    ;260 DDMMYY
    TCODE    .105,  .35,     "AAMMJJ"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC 
    TCODE    .65,   .168,    "Bail"                      ;263 Bail
    TCODE    .7,    .48,     "Air   "                    ;264 Air
    TCODE    .120,  .135,    "Air   "                    ;265 Air
    TCODE    .2,    .39,     "Calibrer"                  ;266 Calibrate
    TCODE    .0,    .216,    "Max."                      ;267 Max.
    TCODE    .10,   .8,      "non"                       ;268 not
    TCODE    .10,   .16,     "trouv�!"                   ;269 found!
    TCODE    .0,    .0,      "mV:"                       ;270 mV:
; New CFs Warning
    TCODE    .3,    .2,      "Nouvelles CF ajout�es!"    ;271 New CF added!
    TCODE    .0,    .35,     "Nouv. Config Fonctions"    ;272 New CustomFunctions
    TCODE    .0,    .65,     "ajout�es! Regardez les"    ;273 were added! Check
    TCODE    .0,    .95,     "Menus  CF I  et  CF II"    ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "pour plus de d�tails!"     ;275 for Details!
    TCODE    .20,   .95,     "Salinit�: "                ;276 Salinity:
;
    TCODE    .20,   .65,     "Temps fond:"               ;277 Bottom Time:
    TCODE    .20,   .95,     "Prof. Max.:"               ;278 Max. Depth:
    TCODE    .20,   .125,    "Calculer la D�co"          ;279 Calculate Deco
    TCODE    .20,   .155,    "Voir Plan de D�co"         ;280 Show Decoplan
;
    TCODE    .93,   .170,    "Prof.Moyn"                 ;281 Avr.Depth
    TCODE    .90,   .170,    "TissuDirec"                ;282 Lead Tiss.
    TCODE    .118,   .170,   "Chrono"                    ;283 Stopwatch
    TCODE    .20,   .95,     "RaZ Carnet Plong�es"       ;284 Reset Logbook
    TCODE    .20,   .125,    "Red�marrer l'OSTC"         ;285 Reboot OSTC
    TCODE    .20,   .155,    "RaZ Saturation"            ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "Altim�tre"                 ;287 Altimeter
    TCODE    .24,   .1,      "R�glage Altim�tre"         ;288 Set Altimeter
    TCODE    .20,   .35,     "R�f�rence: "               ;289 Sea ref: 
    TCODE    .0,    .0,      "Marche: "                  ;290 Enabled:
    TCODE    .20,   .95,     "D�faut: 1013 mbar"         ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Alt: "                     ;294 Alt: 
;
	TCODE    .20,   .125,    "Aff. donn. brutes"         ;295 Show raw data
	TCODE    .50,    .2,     "Donn�es brutes:"           ;296 Raw Data:
;=============================================================================
