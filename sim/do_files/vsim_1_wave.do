# ============================================================
# Файл: vsim_1_wave.do
# Настройки окна волн для симуляции тестбенча tb_adc_pa
# ============================================================

onerror {resume}
quietly WaveActivateNextPane {} 0

# -------------------- Сигналы верхнего уровня тестбенча --------------------
add wave -noupdate /tb_adc_pa/rst_i
add wave -noupdate /tb_adc_pa/clk_120_i
add wave -noupdate /tb_adc_pa/axi_en_i
add wave -noupdate /tb_adc_pa/axi_data_i
add wave -noupdate /tb_adc_pa/axi_we_i
add wave -noupdate /tb_adc_pa/axi_addr_i
add wave -noupdate /tb_adc_pa/axi_vd_o
add wave -noupdate /tb_adc_pa/axi_data_o
add wave -noupdate /tb_adc_pa/axi_irq_o
add wave -noupdate /tb_adc_pa/tx_active_i
add wave -noupdate /tb_adc_pa/tx_mode_i
add wave -noupdate /tb_adc_pa/adc_sck_o
add wave -noupdate /tb_adc_pa/adc_conv_o
add wave -noupdate /tb_adc_pa/adc_sdo_i

# -------------------- Внутренние сигналы тестируемого модуля (uut) --------------------
add wave -noupdate -divider {UUT Signals}
add wave -noupdate /tb_adc_pa/uut/rst_i
add wave -noupdate /tb_adc_pa/uut/clk_120_i
add wave -noupdate /tb_adc_pa/uut/axi_en_i
add wave -noupdate /tb_adc_pa/uut/axi_data_i
add wave -noupdate /tb_adc_pa/uut/axi_we_i
add wave -noupdate /tb_adc_pa/uut/axi_addr_i
add wave -noupdate /tb_adc_pa/uut/axi_vd_o
add wave -noupdate /tb_adc_pa/uut/axi_data_o
add wave -noupdate /tb_adc_pa/uut/axi_irq_o
add wave -noupdate /tb_adc_pa/uut/tx_active_i
add wave -noupdate /tb_adc_pa/uut/tx_mode_i
add wave -noupdate /tb_adc_pa/uut/adc_sck_o
add wave -noupdate /tb_adc_pa/uut/adc_conv_o
add wave -noupdate /tb_adc_pa/uut/adc_sdo_i

# -------------------- Регистры и вспомогательные сигналы --------------------
add wave -noupdate -divider {Registers}
add wave -noupdate /tb_adc_pa/uut/control_reg
add wave -noupdate /tb_adc_pa/uut/rezult_reg
add wave -noupdate /tb_adc_pa/uut/i

# -------------------- Настройки отображения --------------------
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0} {{Cursor 2} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {10 us}
