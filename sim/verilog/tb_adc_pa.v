`timescale 1ns / 1ps  

module tb_adc_pa();
    // Системные сигналы
    reg rst_i;
    reg clk_120_i;
    reg axi_en_i;
    reg [31:0] axi_data_i;
    reg axi_we_i;
    reg [31:0] axi_addr_i;
    wire axi_vd_o;
    wire [31:0] axi_data_o;
    wire axi_irq_o;
    reg tx_active_i;
    reg [3:0] tx_mode_i;
    wire adc_sck_o;
    wire adc_conv_o;
    reg adc_sdo_i;

// Инстанцирование модуля

 adc_pa uut (
    .rst_i(rst_i),
    .clk_120_i(clk_120_i),
    .axi_en_i(axi_en_i),
    .axi_data_i(axi_data_i),
    .axi_we_i(axi_we_i),
    .axi_addr_i(axi_addr_i),
    .axi_vd_o(axi_vd_o),
    .axi_data_o(axi_data_o),
    .axi_irq_o(axi_irq_o),
    .tx_active_i(tx_active_i),
    .tx_mode_i(tx_mode_i),
    .adc_sck_o(adc_sck_o),
    .adc_conv_o(adc_conv_o),
    .adc_sdo_i(adc_sdo_i)
 );

//Генерация тактового сигнала 120 мгц
initial begin
  clk_120_i = 0;
  forever #4 clk_120_i = ~clk_120_i; // Период 8 нс
end

   initial begin
    rst_i = 1;
    axi_en_i = 0;
    axi_data_i = 0;
    axi_we_i = 0;
    axi_addr_i = 0;
    tx_active_i = 0;
    tx_mode_i = 0;
    adc_sdo_i = 0;

   #100; //Сброс
    rst_i =0;

    #10
    // Запись в регистр управления
    axi_en_i = 1;
    axi_we_i = 1;
    axi_addr_i = 8'h0;
    axi_data_i = 32'h3; // Разрешение работы и прерываний
    #10
    axi_en_i = 0;

    // Чтение регистра управления
    axi_en_i = 1;
    axi_we_i = 0;
    axi_addr_i = 8'h0;
    #10
    $display("Control reg: %h" , axi_data_o);
    axi_en_i = 0;

    // Запись в  калибровочный регистр 0
    axi_en_i = 1;
    axi_we_i = 1;
    axi_addr_i = 8'h8;
    axi_data_i = 32'h12345678; // Разрешение работы и прерываний
    #10
    axi_en_i = 0;

    // Чтение калибровочного регистра 0
    axi_en_i = 1;
    axi_we_i = 0;
    axi_addr_i = 8'h8;
    #10
    $display("Calib reg 0: %h" , axi_data_o);
    axi_en_i = 0;

    

   #100; 
    $finish;
   end

endmodule
