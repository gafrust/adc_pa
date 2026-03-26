# ============================================================
# Файл: v_sim.do
# Описание: Скрипт для компиляции и запуска симуляции в ModelSim/QuestaSim
# ============================================================

# -------------------- Компиляция глобального модуля Xilinx --------------------
# Для корректной симуляции проектов Xilinx (Vivado/ISE) требуется модуль glbl,
# который содержит глобальные сигналы (GSR, GTS и др.). Версия glbl.v выбирается
# в зависимости от установленного инструмента.

# Для ISE 14.7 (закомментировано)
#vlog -reportprogress 300 -work work /usr/local/Xilinx/14.7/ISE_DS/ISE/verilog/src/glbl.v
# Для Vivado 2020.1 (закомментировано)
#vlog -reportprogress 300 -work work C:/Xilinx/Vivado/2020.1/data/verilog/src/glbl.v
# Для Vivado 2024.2 (актуальная версия)
#vlog -reportprogress 300 -work work /opt/Xilinx/Vivado/2024.2/data/verilog/src/glbl.v
vlog -reportprogress 300 -work work /opt/Xilinx__/Vivado/2023.1/data/verilog/src/glbl.v

# -------------------- Создание и настройка библиотеки work --------------------
# Создаём физическую библиотеку work (каталог work в текущей директории)
vlib work
# Привязываем логическое имя библиотеки work к физическому каталогу work
vmap work work

# -------------------- Определение путей к исходным файлам --------------------
# Путь к RTL-файлам (на два уровня выше относительно текущей папки скрипта)
set path_icnl   ../../rtl
# Путь к верилоговским файлам (на один уровень выше)
set path_icnl2   ../verilog
# ВНИМАНИЕ: возможно, опечатка в именах переменных (icnl вместо inc).
# Но это не влияет на работу, если пути используются только в +incdir+.

# -------------------- Компиляция исходных файлов --------------------
# Компилируем тестбенч tb_adc_pa.v (SystemVerilog)
vlog  +incdir+$path_icnl  -reportprogress 300 -work work ../verilog/tb_adc_pa.v

# Компилируем файл конфигурации ukl_nano_def_cfg.v (обычно параметры, дефайны)
#vlog  +incdir+$path_icnl  -reportprogress 300 -work work ../verilog/ukl_nano_def_cfg.v

# Компилируем основной RTL-модуль adc_pa.v
# +define+__XILINX_SIMULATOR__ – определяет макрос, часто используемый в коде Xilinx
# +incdir+$path_icnl2 +incdir+$path_icnl – добавляем два каталога для поиска include-файлов
vlog  +define+__XILINX_SIMULATOR__ +incdir+$path_icnl2 +incdir+$path_icnl  -reportprogress 300 -work work ../../rtl/adc_pa.v

# При необходимости компиляция VHDL-модели IP (закомментировано)
#vcom -work work ../../ip/ukl_nano_rx_dF_dsp/ipmanager/ukl_nano_rx_dF_dsp/sim/ukl_nano_rx_dF_dsp.vhd

# -------------------- Запуск симуляции --------------------
# -voptargs=+acc=lprn – оптимизация дизайна с доступом ко всем сигналам для отладки
# -L unisims_ver – подключаем библиотеку примитивов Xilinx (unisims_ver)
# -t 100pS – устанавливаем временное разрешение 100 пикосекунд
# work.test – симулируемый тестбенч (модуль test в библиотеке work)
# glbl – глобальный модуль Xilinx, необходимый для инициализации
vsim -voptargs=+acc=lprn -t 100pS work.tb_adc_pa glbl
#vsim -voptargs=+acc=lprn -L unisims_ver -t 100pS work.tb_adc_pa glbl

# -------------------- Открытие окон отладки --------------------
# Открываем окно волн (Wave)
view wave
# Открываем окно иерархии (Structure)
view structure
# Открываем окно сигналов (Signals)
view signals

# -------------------- Загрузка настроек волн --------------------
# Выполняем файл команд vsim_1_wave.do, который обычно содержит
# команды для добавления сигналов в окно волн и настройки отображения
do vsim_1_wave.do

# -------------------- Запуск симуляции --------------------
# Запускаем симуляцию на 3500 микросекунд модельного времени
run 3500 us

