`timescale 1 ns/1 ps
module adc_pa(
    // Системные сигналы
    input wire rst_i,
    input wire clk_120_i,

    // Axi BRAM интерфейс взаимодействия с MicroBlaze
    input wire axi_en_i,
    input wire [31:0] axi_data_i,
    input wire axi_we_i,
    input wire [31:0] axi_addr_i,
    output reg axi_vd_o,
    output reg [31:0] axi_data_o,
    output reg axi_irq_o,

    // Входные порты от модуля передатчика
    input wire tx_active_i,
    input wire [3:0] tx_mode_i,

    // Входные/выходные порты к АЦП
    output reg adc_sck_o,
    output reg adc_conv_o,
    input wire adc_sdo_i
    );


    //Внутренние регистры
    reg [31:0] control_reg = 32'h0;
    reg [31:0] rezult_reg = 32'h0;
    reg [31:0] calib_reg [0:15];
    integer i;

    //Логика сброса
    always @(posedge clk_120_i or posedge rst_i) begin
        if(rst_i) begin
            control_reg <= 32'h0;
            rezult_reg <= 32'h0;
            for ( i = 0; i < 16; i = i + 1) begin
            calib_reg [i] <= 32'h0;
            end
            axi_vd_o <= 1'h0;
            axi_data_o <= 32'h0;
            axi_irq_o <=1'h0;
            adc_sck_o <= 1'h0;
            adc_conv_o <= 1'h0;
        end
    end


always @(posedge clk_120_i) begin
    if(!rst_i && axi_en_i) begin
       if(axi_we_i) begin
         // Запись данных
         case (axi_addr_i[7:0])
             8'h0: control_reg <= axi_data_i;
             8'h4:; //Регистр только для чтения
             8'h8: calib_reg[0] <= axi_data_i;
             8'hc: calib_reg[1] <= axi_data_i;
             default: ;
         endcase
       end else begin
         // Чтение данных
         case (axi_addr_i[7:0])
             8'h0: axi_data_o <= control_reg;
             8'h4: axi_data_o <= axi_data_o; 
             8'h8: axi_data_o <= calib_reg[0];
             8'hc: axi_data_o <= calib_reg[1];
             default: axi_data_o <= 32'h0;
         endcase
         axi_vd_o <= 1'b1;
       end
    end else begin
         axi_vd_o <= 1'b0;
        
    end
end
    
// Логика деления частоты из 120 Мгц до 10 Мгц    
reg [3:0] adc_sck_counter;

always @(posedge clk_120_i or posedge rst_i) begin
    if(rst_i) begin
      adc_sck_counter <= 4'd0;
      adc_sck_o <= 1'b0;
    end else begin
      adc_sck_counter <= adc_sck_counter + 1;
      if(adc_sck_counter == 4'd5) begin
        adc_sck_counter <= 4'h0;
        adc_sck_o <= ~adc_sck_o;
      end
    end
end


// Логика задержки и запуска измерений
reg [16:0] delay_counter;      // счётчик задержки перед началом измерений
reg [5:0]  measurement_counter; // счётчик количества измерений (32 измерения)
reg [31:0] sum_u_pad;           // сумма положительных значений (не используется в логике)
reg [5:0]  sum_u_otr;           // сумма отрицательных значений (не используется в логике)

// -------------------------------------------------------------------
// Главный цикл: always-блок срабатывает по положительному фронту такта
// или по сбросу. Здесь реализован конечный автомат управления АЦП.
// -------------------------------------------------------------------
always @(posedge clk_120_i or posedge rst_i) begin
  // --------------------- Ветвление 1: сброс ------------------------
  if (rst_i) begin
    // Обнуление всех регистров при активном сбросе
    delay_counter      <= 17'd0;
    measurement_counter <= 6'd0;
    sum_u_pad          <= 32'd0;
    sum_u_otr          <= 32'd0;
    adc_conv_o         <= 1'b0;    // сигнал запуска АЦП выключен
  // --------------------- Ветвление 2: обычная работа ---------------
  end else begin
    // -------- Разветвление 2.1: активна передача? ----------
    if (tx_active_i) begin
      // Устанавливаем задержку 48000 тактов (для паузы после передачи)
      delay_counter <= 17'd48000;
    // -------- Разветвление 2.2: идёт отсчёт задержки? ----------
    end else if (delay_counter != 0) begin
      // Уменьшаем счётчик задержки на 1
      delay_counter <= delay_counter - 1;
      // Вложенное разветвление: после декремента достигли нуля?
      // (если delay_counter был равен 1, то теперь стал 0)
      if (delay_counter == 1) begin
        // Запускаем АЦП и устанавливаем счётчик измерений на 32
        adc_conv_o      <= 1'b1;
        measurement_counter <= 6'd32;
      end
    // -------- Разветвление 2.3: идёт процесс измерений? ----------
    end else if (measurement_counter != 0) begin
      // Сбрасываем сигнал запуска АЦП и уменьшаем счётчик измерений
      adc_conv_o      <= 1'b0;
      measurement_counter <= measurement_counter - 1;
    // -------- Разветвление 2.4: все остальные случаи ----------
    end else begin
      // Ничего не делаем, просто держим adc_conv_o в 0
      adc_conv_o <= 1'b0;
    end
  end
end




    
endmodule /* adc_pa */
