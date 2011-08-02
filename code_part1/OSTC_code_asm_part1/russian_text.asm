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
; * Ascii chars: we can support a few specific chars. цдьЯ for German.
;   йикз for French. бнуъсЎї for Spanish.
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
    TCODE    .0,   .0,       "Расчет MD2 хэша"           ;001 Building MD2 Hash
    TCODE    .0,   .25,      "Пожалуйста ждите..."       ;002 Please Wait...
    TCODE    .0,   .2,       "HeinrichsWeikamp OSTC2"    ;003 HeinrichsWeikamp OSTC2
    TCODE    .65,  .2,       "Меню?"                     ;004 Menu?
    TCODE    .65,  .2,       "Меню:"                     ;005 Menu:
    TCODE    .20,  .35,      "Журнал"                    ;006 Logbook
    TCODE    .20,  .65,      "Настройка газов"           ;007 Gas Setup
    TCODE    .20,  .35,      "Установка часов"           ;008 Set Time
    TCODE    .20,  .95,      "Меню сброса"               ;009 Reset Menu
    TCODE    .20,  .125,     "Настройка"                 ;010 Setup
    TCODE    .20,  .185,     "Выход"                     ;011 Exit
    TCODE    .104, .2,       "Ждите..."                  ;012 Wait...
    TCODE    .0,   .24,      "MD2 хэш:"                  ;013 MD2 Hash:
    TCODE    .0,   .0,       "Десат"                     ;014 Desat         (Desaturation count-down)
    TCODE    .50,  .2,       "Интерфейс"                 ;015 Interface		(Connected to USB)
    TCODE    .10,  .30,      "Старт"                     ;016 Start
    TCODE    .10,  .55,      "Данные"                    ;017 Data
    TCODE    .10,  .80,      "Заголовок"                 ;018 Header
    TCODE    .10,  .105,     "Профиль"                   ;019 Profile
    TCODE    .10,  .130,     "Готово."                   ;020 Done.
    TCODE    .20,  .35,      "Отменить сброс"            ;021 Cancel Reset
    TCODE    .32,  .65,      "Время:"                    ;022 Time:
    TCODE    .32,  .95,      "Дата :"                    ;023 Date:
    TCODE    .0,   .215,     "Установить Час"            ;024 Set Hours
    TCODE    .6,   .0,       "Сброс..."                  ;025 Reset...
    TCODE    .55,  .2,       "Журнал"                    ;026 Logbook
    TCODE    .20,  .2,       "Доп. Параметры I"          ;027 Custom Functions I
    TCODE    .40,  .2,       "Меню сброса"               ;028 Reset Menu
    TCODE    .15,  .2,       "Установка времени:"        ;029 Set Time:
    TCODE    .100, .50,      "Маркер"                    ;030 SetMarker         (Add a mark in logbook profile)
    TCODE    .100, .25,      "Декоплан"                  ;031 Decoplan
    TCODE    .100, .0,       "Мои Газы"                  ;032 Gaslist
    TCODE    .100, .50,      "Сбр.Сред"                  ;033 ResetAvr          (Reset average depth)
    TCODE    .100, .100,     "Выход"                     ;034 Exit		        (Exit current menu)
    TCODE    .0,   .0,       "Нелєт"                     ;035 NoFly		        (No-flight count-down)
;
; 32 custom function descriptors I (FIXED LENGTH = 15 chars).
    TCODE    .40,  .35,      "Начало погр.[m]"           ;036 Start Dive  [m]	(depth to switch to dive mode)
    TCODE    .40,  .35,      "Конец погр. [m]"           ;037 End Dive    [m]	(depth to switch back to surface mode)
    TCODE    .40,  .35,      "Жду после [min]"           ;038 End Delay [min]  	(duration dive screen stays after end of dive)
    TCODE    .40,  .35,      "Отключение[min]"           ;039 Power Off [min]
    TCODE    .40,  .35,      "Пред-меню [min]"           ;040 Pre-menu  [min]	(Delais to keep surface-mode menus displayed)
    TCODE    .40,  .35,      "Скорость[m/min]"           ;041 velocity[m/min]
    TCODE    .40,  .35,      "Автовключ[mbar]"           ;042 Wake-up  [mbar]
    TCODE    .40,  .35,      "max. Верх[mbar]"           ;043 max.Surf.[mbar]
    TCODE    .40,  .35,      "Показать GF [%]"           ;044 GF display  [%]
    TCODE    .40,  .35,      "min.O2 показ[%]"           ;045 min. O2 Dis.[%]
    TCODE    .40,  .35,      "Меню погр.[min]"           ;046 Dive menus[min]
    TCODE    .40,  .35,      "Насыщение x [%]"           ;047 Saturate x  [%]
    TCODE    .40,  .35,      "Рассыщение x[%]"           ;048 Desaturate x[%]
    TCODE    .40,  .35,      "Нелєт фактор[%]"           ;049 NoFly Ratio [%]	(Grandient factor tolerance for no-flight countdown).
    TCODE    .40,  .35,      "GF тревога 1[%]"           ;050 GF alarm 1  [%]
    TCODE    .40,  .35,      "CNS наверху [%]"           ;051 CNSshow surf[%]
    TCODE    .40,  .35,      "Деко ниже   [m]"           ;052 Deco Offset [m]
    TCODE    .40,  .35,      "ppO2 низк [bar]"           ;053 ppO2 low  [bar]
    TCODE    .40,  .35,      "ppO2 высок[bar]"           ;054 ppO2 high [bar]
    TCODE    .40,  .35,      "ppO2 показ[bar]"           ;055 ppO2 show [bar]
    TCODE    .40,  .35,      "Интервал данных"           ;056 sampling rate
    TCODE    .40,  .35,      "Делитель темпер"           ;057 Divisor Temp
    TCODE    .40,  .35,      "Делитель деко  "           ;058 Divisor Decodat
    TCODE    .40,  .35,      "Делитель неисп1"           ;059 Divisor NotUse1
    TCODE    .40,  .35,      "Делитель ppO2  "           ;060 Divisor ppO2
    TCODE    .40,  .35,      "Делитель дебаг "           ;061 Divisor Debug
    TCODE    .40,  .35,      "Делитель неисп2"           ;062 Divisor NotUse2
    TCODE    .40,  .35,      "CNS показать[%]"           ;063 CNSshow dive[%]
    TCODE    .40,  .35,      "Номер в журнале"           ;064 Logbook offset
    TCODE    .40,  .35,      "Крайняя деко[m]"           ;065 Last Deco at[m]
    TCODE    .40,  .35,      "Конец Apnoe [h]"           ;066 End Apnoe   [h]
    TCODE    .40,  .35,      "Показ напр.бат."           ;067 Show Batt.Volts
; End of function descriptor I
;
;licence:
    TCODE    .0,   .35,      "Эта программа свободно"    ;068 This program is
    TCODE    .0,   .65,      "распространяется в"        ;069 distributed in the
    TCODE    .0,   .95,      "надежде, что она будет"    ;070 hope that it will be
    TCODE    .0,   .125,     "полезной, но БЕЗО"         ;071 useful, but WITHOUT
    TCODE    .0,   .155,     "ВСЯКИХ ГАРАНТИЙ; также"    ;072 ANY WARRANTY
    TCODE    .0,   .185,     "без подразумеваемых"       ;073 even the implied
    TCODE    .0,   .215,     "гарантий КОММЕРЧЕСКОЙ"     ;074 warranty of
    TCODE    .0,   .35,      "ЦЕННОСТИ или"              ;075 MERCHANTABILITY or
    TCODE    .0,   .65,      "ПРИГОДНОСТИ ДЛЯ"           ;076 FITNESS FOR A
    TCODE    .0,   .95,      "КОНКРЕТНОЙ ЦЕЛИ."          ;077 PARTICULAR PURPOSE.
    TCODE    .0,   .125,     "Смотри GNU General"        ;078 See the GNU General
    TCODE    .0,   .155,     "Public License для"        ;079 Public License for
    TCODE    .0,   .185,     "полной информации:"        ;080 more details:
    TCODE    .0,   .215,     "www.heinrichsweikamp.de"   ;081 www.heinrichsweikamp.de
; end of licence
;
    TCODE    .102,  .54,     "Декостоп"                  ;082 Decostop
    TCODE    .0,    .0,      "м/мин"                     ;083 m/min
    TCODE    .102,  .113,    "Без деко"                  ;084 No Stop
    TCODE    .135,  .113,    "TTS"                       ;085 TTS
    TCODE    .121,  .0,      "В®емя"                     ;086 Divetime
    TCODE    .0,    .0,      "Глубина"                   ;087 Depth
    TCODE    .0,    .0,      "Первый Газ?"               ;088 First Gas?
    TCODE    .0,    .0,      "Умолчание:"                ;089 Default:
    TCODE    .0,    .0,      "Минуты"                    ;090 Minutes
    TCODE    .0,    .0,      "Месяц "                    ;091 Month
    TCODE    .0,    .0,      "День  "                    ;092 Day
    TCODE    .0,    .0,      "Год   "                    ;093 Year
    TCODE    .0,    .0,      "Установить "               ;094 Set
    TCODE    .0,    .0,      "Газ# "                     ;095 Gas#
    TCODE    .0,    .0,      "Да"                        ;096 Yes
    TCODE    .0,    .0,      "Действует:"                ;097 Current:
    TCODE    .23,   .2,      "Меню настройки:"           ;098 Setup Menu:
    TCODE    .20,   .35,     "Доп. Параметры I"          ;099 Custom FunctionsI
    TCODE    .20,   .125,    "Алгоритм:"                 ;100 Decotype:
    TCODE    .85,   .125,    "ZH-L16 OC"                 ;101 ZH-L16 OC
    TCODE    .85,   .125,    "Gauge    "                 ;102 Gauge
    TCODE    .85,   .125,    "Gauge"                     ;103 Gauge
    TCODE    .85,   .125,    "ZH-L16 CC"                 ;104 ZH-L16 CC
    TCODE    .0,    .0,      "Активный Газ? "            ;105 Active Gas?
    TCODE    .10,   .2,      "Настройка газов"	         ;106 Gas Setup - Gaslist
    TCODE    .20,   .95,     "Глуб. +/-:"                ;107 Depth +/-:
    TCODE    .20,   .125,    "Изменить:" 	             ;108 Change:
	TCODE	 .20,	.155,	 "Умолчание:"			  	 ;109 Default:
    TCODE    .20,   .65,     "Сетпоинты CCR"             ;110 CCR SetPoint Menu
    TCODE    .20,   .2,      "Меню сетпоинтов CCR"       ;111 CCR SetPoint Menu
    TCODE    .0,    .0,      "SP#"                       ;112 SP#
    TCODE    .20,   .95,     "Состояние батареи"         ;113 Battery Info
    TCODE    .17,   .2,      "Информация батареи"        ;114 Battery Information
    TCODE    .0,    .9,      "Циклов:"                   ;115 Cycles:
    TCODE    .85,   .125,    "Apnoe"                     ;116 Apnoe
    TCODE    .0,    .18,     "Посл. зарядка:"            ;117 Last Complete:
    TCODE    .0,    .27,     "Минимум Vбат:"             ;118 Lowest Vbatt:
    TCODE    .0,    .36,     "Минимум дата:"             ;119 Lowest at:
    TCODE    .0,    .45,     "Tmin:"                     ;120 Tmin:
    TCODE    .0,    .54,     "Tmax:"                     ;121 Tmax:
    TCODE    .100,  .125,    "Далее"		          	 ;122 More (Gaslist)
    TCODE    .100,  .25,     "O2 +"                      ;123 O2 +
    TCODE    .100,  .50,     "O2 -"                      ;124 O2 -
    TCODE    .100,  .75,     "He +"                      ;125 He +
    TCODE    .100,  .100,    "He -"                      ;126 He -
    TCODE    .100,  .0,      "Выход"                     ;127 Exit
    TCODE    .100,  .25,     "Удалить"                   ;128 Delete
    TCODE    .20,   .65,     "Дебаг:"                    ;129 Debug:
    TCODE    .65,   .65,     "Вкл "                      ;130 ON
    TCODE    .65,   .65,     "Выкл"                      ;131 OFF
    TCODE    .100,  .50,     "Удал. все"                 ;132 Del. all
    TCODE    .10,   .0,      "Неожиданный сброс из "     ;133 Unexpected reset from
    TCODE    .10,   .25,     "режима погружения!   "     ;134 Divemode! Please help
    TCODE    .10,   .50,     "Сообщите об ошибке,  "     ;135 and report the Debug
    TCODE    .10,   .75,     "отправьте отчет ниже!"     ;136 Information below!
    TCODE    .100,  .75,     "Бэйлаут"                   ;137 Bailout
    TCODE    .85,   .125,    "Apnoe    "                 ;138 Apnoe
    TCODE    .112,  .120,    "В воде"                    ;139 Descent
    TCODE    .105,  .60,     "Наверху"                   ;140 Surface
    TCODE    .65,   .2,      "Откл?"                     ;141 Quit?
    TCODE    .20,   .155,    "Далее"                     ;142 More
    TCODE    .42,   .72,     "Уверены?"                  ;143 Confirm:
    TCODE    .60,   .2,      "Меню 2:"                   ;144 Menu 2:
    TCODE    .52,   .96,     "Отмена"                    ;145 Cancel
    TCODE    .52,   .120,    "OK!"                       ;146 OK!
    TCODE    .20,   .35,     "Далее"            	     ;147 More
    TCODE    .0,    .0,      ":.........:"               ;148 :.........:
    TCODE    .0,    .8,      "ppO2"                      ;149 ppO2
    TCODE    .2,    .39,     "bar "                      ;150 bar
    TCODE    .108,  .216,    "Маркер?"                   ;151 Marker?
    TCODE    .85,   .125,    "L16-GF OC"                 ;152 L16-GF OC
    TCODE    .20,   .65,     "Доп. Параметры II"	     ;153 Custom FunctionsII
;
; 32 custom function descriptors II (FIXED LENGTH = 15 chars).
    TCODE    .40,   .35,     "GF Low      [%]"           ;154 GF Low      [%]
    TCODE    .40,   .35,     "GF High     [%]"           ;155 GF High     [%]
    TCODE    .40,   .35,     "Цвет#   батареи"           ;156 Color# Battery
    TCODE    .40,   .35,     "Цвет#  стардарт"           ;157 Color# Standard
    TCODE    .40,   .35,     "Цвет# под водой"           ;158 Color# Divemask
    TCODE    .40,   .35,     "Цвет# предупреж"           ;159 Color# Warnings
    TCODE    .40,   .35,     "Время погр.сек."           ;160 Divemode secs.
    TCODE    .40,   .35,     "Поправ. фикс.SP"           ;161 Adjust fixed SP
    TCODE    .40,   .35,     "Предупреж. стоп"           ;162 Warn Ceiling
    TCODE    .40,   .35,     "Картинки газов "           ;163 Mix type icons
    TCODE    .40,   .35,     "Напом. лучш.газ"           ;164 Blink BetterGas	(Remainder in divemode to switch to a better decompression gas).
	TCODE    .40,   .35,     "Трев.глуб[mbar]"           ;165 DepthWarn[mbar]
    TCODE    .40,   .35,     "CNS предупр.[%]"           ;166 CNS warning [%]
    TCODE    .40,   .35,     "GF предупр. [%]"           ;167 GF warning  [%]
    TCODE    .40,   .35,     "ppO2 пред.[bar]"           ;168 ppO2 warn [bar]
    TCODE    .40,   .35,     "Скор.пр.[m/min]"           ;169 Vel.warn[m/min]
    TCODE    .40,   .35,     "Коррекция часов"           ;170 Time offset/day
    TCODE    .40,   .35,     "Показ альтиметр"           ;171 Show altimeter
    TCODE    .40,   .35,     "Показать маркер"           ;172 Show Log-Marker
    TCODE    .40,   .35,     "Показать таймер"           ;173 Show Stopwatch
    TCODE    .40,   .35,     "Показ граф. ткн"           ;174 ShowTissueGraph
    TCODE    .40,   .35,     "Показ глав. ткн"           ;175 Show Lead.Tiss.
    TCODE    .40,   .35,     "Мелк.ост.вверху"           ;176 Shallow stop 1st  (Reverse order of deco plans)
    TCODE    .40,   .35,     "Перекл.газ[min]"           ;177 Gas switch[min]   (Additional delay in decoplan for gas switches).
    TCODE    .40,   .35,     "Донн.расх[/min]"           ;178 BottomGas[/min]   (Bottom gas usage, for volume estimation).
    TCODE    .40,   .35,     "Подъ.расх[/min]"           ;179 AscentGas[/min]   (Ascent+Deco gas usage)
    TCODE    .40,   .35,     "Будущ. TTS[min]"           ;180 Future TTS[min]   (@5 variant: compute TTS for extra time at current depth)
    TCODE    .40,   .35,     "Не используется"           ;181 not used
    TCODE    .40,   .35,     "Не используется"           ;182 not used
    TCODE    .40,   .35,     "Не используется"           ;183 not used
    TCODE    .40,   .35,     "Не используется"           ;184 not used
    TCODE    .40,   .35,     "Не используется"           ;185 not used
; End of function descriptor II
;
    TCODE    .20,   .2,      "Доп. Параметры II"         ;186 Custom Functions II
    TCODE    .20,   .95,     "Показать лицензию"         ;187 Show License
    TCODE    .0,    .2,      "Результаты:"               ;188 Sim. Results:
    TCODE    .90,   .25,     "Поверхн."                  ;189 Surface
    TCODE    .0,    .0,      "ppO2 +"                    ;190 ppO2 +
    TCODE    .0,    .0,      "ppO2 -"                    ;191 ppO2 -
    TCODE    .0,    .0,      "Дил."                      ;192 Dil.			       (Rebreather diluent)
; ZH-L16 mode description
    TCODE    .0,    .35,     "Алгоритм: ZH-L16 OC"       ;193 Decotype: ZH-L16 OC
    TCODE    .0,    .65,     "Для открытой схемы "       ;194 For Open Circuit
    TCODE    .0,    .95,     "дыхания. Доступно  "       ;195 Divers. Supports 5
    TCODE    .0,    .125,    "до 5 Тримикс-смесей"       ;196 Trimix Gases.
    TCODE    .0,    .155,    "Задайте свои газы  "       ;197 Configure your gas
    TCODE    .0,    .185,    "в меню настройки.  "       ;198 in Gassetup menu.
    TCODE    .0,    .215,    "Уточн. ДП11 & ДП12!"       ;199 Check CF11 & CF12 !
; Gaugemode description
    TCODE    .0,    .35,     "Алгоритм: Gauge    "       ;200 Decotype: Gauge
    TCODE    .0,    .65,     "Время под водой в  "       ;201 Divetime will be in
    TCODE    .0,    .95,     "виде Минуты:Секунды"       ;202 Minutes:Seconds.
    TCODE    .0,    .125,    "OSTC2 не вычисляет "       ;203 OSTC2 will not
    TCODE    .0,    .155,    "декомпрессию,      "       ;204 compute Deco, NoFly
    TCODE    .0,    .185,    "нелєтное время и   "       ;205 time and Desat.
    TCODE    .0,    .215,    "время рассыщения!  "       ;206 time at all!
; Const.ppO2 description
    TCODE    .0,    .35,     "Алгоритм: ZH-L16 CC"       ;207 Decotype: ZH-L16 CC
    TCODE    .0,    .65,     "Для (полу-)закрытой"       ;208 For (Semi-)Closed
    TCODE    .0,    .95,     "схемы дыхания.     "       ;209 Circuit rebreathers
    TCODE    .0,    .125,    "Задайте 3 Сетпоинта"       ;210 Configure the 3
    TCODE    .0,    .155,    "в меню настройки   "       ;211 SetPoints in CCR -
    TCODE    .0,    .185,    "CCR. Доступно до 5 "       ;212 Setup menu. 5 bail-
    TCODE    .0,    .215,    "Бэйлаут-смесей.    "       ;213 outs are available.
; Apnoemode description
    TCODE    .0,    .35,     "Алгоритм: Apnoe    "       ;214 Decotype: Apnoe
    TCODE    .0,    .65,     "OSTC2 показывает   "       ;215 OSTC2 will display
    TCODE    .0,    .95,     "каждое погружение  "       ;216 each descent separ-
    TCODE    .0,    .125,    "отдельно в Мин:Сек."       ;217 ately in Min:Sec.
    TCODE    .0,    .155,    "Временно выставляет"       ;218 Will temporally set
    TCODE    .0,    .185,    "период данных 1 сек"       ;219 samplerate to 1 sec
    TCODE    .0,    .215,    "Не вычисляет деко! "       ;220 No Deco calculation
; Multi GF OC mode description
    TCODE    .0,    .35,     "Алгоритм: L16-GF OC"       ;221 Decotype: L16-GF OC
    TCODE    .0,    .65,     "Расчет декомпрессии"       ;222 Decompression cal-
    TCODE    .0,    .95,     "с методом градиент-"       ;223 culations with the
    TCODE    .0,    .125,    "фактора (GF_lo/GF  "       ;224 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). Уточн. ДП32 &"       ;225 _hi). Check CF32 &
    TCODE    .0,    .185,    "ДП33!Открытый цикл,"       ;226 CF33! Open Circuit
    TCODE    .0,    .215,    "глубокие остановки."       ;227 with Deep Stops.
; Multi GF CC mode description
    TCODE    .0,    .35,     "Алгоритм: L16-GF CC"       ;228 Decotype: L16-GF CC
    TCODE    .0,    .65,     "Расчет декомпрессии"       ;229 Decompression cal-
    TCODE    .0,    .95,     "с методом градиент-"       ;230 culations with the
    TCODE    .0,    .125,    "фактора (GF_lo/GF  "       ;231 GF-Method (GF_lo/GF
    TCODE    .0,    .155,    "_hi). Уточн. ДП32 &"       ;232 _hi). Check CF32 &
    TCODE    .0,    .185,    "ДП33!Закрытый цикл,"       ;233 CF33!Closed Circuit
    TCODE    .0,    .215,    "глубокие остановки."       ;234 with Deep Stops.
;
    TCODE    .10,   .2,      "Алгоритм изменен!  "       ;235 Decomode changed!
    TCODE    .85,   .125,    "L16-GF CC"                 ;236 L16-GF CC
    TCODE    .2,    .12,     "Не найден"                 ;237 Not found
    TCODE    .100,  .0,      "Сетпоинт"                  ;238 SetPoint
    TCODE    .100,  .0,      "Нет деко"                  ;239 No Deco
    TCODE    .90,   .50,     "Интервал:"                 ;240 Interval:
    TCODE    .100,  .75,     "Яркость"                   ;241 Display
    TCODE    .100,  .0,      "Нет деко"                  ;242 No deco
    TCODE    .132,  .0,      "beta"                      ;243 beta
    TCODE    .100,  .100,    "unuse"                     ;244 unuse
    TCODE    .20,   .65,     "Сброс ДП,газ и деко"       ;245 Reset CF,Gas & Deco
    TCODE    .50,   .145,    "Батарея!"                  ;246 LowBatt!
    TCODE    .20,   .125,    "Планировщик"               ;247 Simulator
    TCODE    .30,   .2,      "OSTC Планировщик"          ;248 OSTC Simulator
    TCODE    .20,   .35,     "Начать имитацию"           ;249 Start Dive
    TCODE    .100,  .25,     "+ 1м"                      ;250 + 1m
    TCODE    .100,  .50,     "- 1м"                      ;251 - 1m
    TCODE    .100,  .75,     "+10м"                      ;252 +10m
    TCODE    .100,  .100,    "-10м"                      ;253 -10m
    TCODE    .100,  .0,      "Закрыть"                   ;254 Close
    TCODE    .131,  .170,    "Часы"                      ;255 Time
;
; Text Bank2 (Texts 256-511)
;
    TCODE    .0,    .0,      "x"                         ;256 x
    TCODE    .20,   .35,     "Формат даты:"              ;257 Date format:
    TCODE    .23,   .2,      "Меню настройки 2:"         ;258 Setup Menu 2:
    TCODE    .105,  .35,     "MMDDYY"                    ;259 MMDDYY
    TCODE    .105,  .35,     "DDMMYY"                    ;260 DDMMYY
    TCODE    .105,  .35,     "YYMMDD"                    ;261 YYMMDD
    TCODE    .1,    .1,      "OSTC "                     ;262 OSTC
    TCODE    .65,   .168,    "Bail "                     ;263 Bail
    TCODE    .7,    .48,     "Air   "                    ;264 Air
    TCODE    .120,  .135,    "Air   "                    ;265 Air
    TCODE    .2,    .39,     "Калибровка"                ;266 Calibrate
    TCODE    .0,    .216,    "Макс."                     ;267 Max.
    TCODE    .10,   .8,      "не"                        ;268 not
    TCODE    .10,   .16,     "найден!"                   ;269 found!
    TCODE    .0,    .0,      "mV:"                       ;270 mV:
; New CFs Warning
    TCODE    .24,   .2,      "Добавлены ДП!"             ;271 New CF added!
    TCODE    .0,    .35,     "Новые Доп. Параметры"      ;272 New CustomFunctions
    TCODE    .0,    .65,     "добавлены! Проверьте"      ;273 were added! Check
    TCODE    .0,    .95,     "Меню ДП I and ДП II"       ;274 CF I and CF II Menu
    TCODE    .0,    .125,    "для информации!"           ;275 for Details!
    TCODE    .20,   .95,     "Соленость: "               ;276 Salinity:
;
    TCODE    .20,   .65,     "Время на дне :"            ;277 Bottom Time:
    TCODE    .20,   .95,     "Макс. глубина:"            ;278 Max. Depth:
    TCODE    .20,   .125,    "Вычислить деко"            ;279 Calculate Deco
    TCODE    .20,   .155,    "Показать план"             ;280 Show Decoplan
;
    TCODE    .107,  .170,    "С®едняя"                   ;281 Avr.Depth
    TCODE    .90,   .170,    "Глав ткань"                ;282 Lead Tiss.
    TCODE    .114,  .170,    "Тайме®"                    ;283 Stopwatch
    TCODE    .20,   .95,     "Сброс журнала"             ;284 Reset Logbook
    TCODE    .20,   .125,    "Перезагрузка OSTC"         ;285 Reboot OSTC
    TCODE    .20,   .155,    "Сброс данных деко"         ;286 Reset Decodata
; Altimeter extension
    TCODE    .20,   .155,    "Альтиметр"                 ;287 Altimeter
    TCODE    .10,   .1,      "Настройка альтиметра"      ;288 Set Altimeter
    TCODE    .20,   .35,     "Уров.моря: "               ;289 Sea ref:
    TCODE    .0,    .0,      "Включен? : "               ;290 Enabled:
    TCODE    .20,   .95,     "Умолчание: 1013 mbar"      ;291 Default: 1013 mbar
    TCODE    .20,   .125,    "+1 mbar"                   ;292 +1 mbar
    TCODE    .20,   .155,    "-1 mbar"                   ;293 -1 mbar
    TCODE    .85,   .185,    "Alt: "                     ;294 Alt:
;
	TCODE    .20,   .125,    "Показать дамп"             ;295 Show raw data
	TCODE    .50,    .2,     "Дамп:"                     ;296 Raw Data:
; Gas-setup addons:
    TCODE    .0,    .0,      "MOD:"                      ;297 MOD:                  (max operating depth of a gas).
    TCODE    .0,    .0,      "END:"                      ;298 END:                  (equivalent nitrogen depth of a gas).
    TCODE    .0,    .0,      "EAD:"                      ;299 EAD:                  (equivalent air depth of a gas).
	TCODE	 .100,	.125,	 "Включен?"   				 ;300 Active?               (Enable/Disable Gas underwater)
	TCODE    .0,    .2,      "Расход OCR газов:"         ;301 OCR Gas Usage:        (Planned gas consumtion by tank).
; 115k Bootloader support:
	TCODE	 .45,	.100,	 "Загрузчик"				 ;302 Bootloader
	TCODE	 .40,	.130,	 "Пожалуйста ждите!"    	 ;303 Please wait!
	TCODE	 .50,	.130,	 "Прервано!"				 ;304 Aborted
;@5 variant
    TCODE    .0,    .0,      "Будущ. TTS"                ;305 Future TTS            (=10 chars. Title for @5 customview).
    TCODE    .100,  .125,    "Quit Sim"                  ;306 Quit Sim (=8char max. Quit Simulator mode)
;Dive interval
    TCODE    .20,   .35,     "Interval:"                 ;307 Interval:
    TCODE    .0,    .0,      "Now    "                   ;308 Now (7 chars min)
	TCODE	 .108,	.112,	 "Average"			 		 ;309 Average
	TCODE	 .94,	.54,	 "Stopwatch"		 		 ;310 Stopwatch (BIG Stopwatch in Gauge mode)
;=============================================================================