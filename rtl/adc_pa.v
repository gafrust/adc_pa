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
    
    
    
endmodule /* adc_pa */
