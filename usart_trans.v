module usart_trans
  #(parameter BPS_CNT = 16'd434)
   (
    input                               sys_clk,sys_rst            ,//使能高电平有效，低电平复位
    output                              uart_txd                   ,
    input                               trig                       ,
    input              [23:0]           D                          ,
    input              [ 1:0]           Adress                     ,
    input              [ 5:0]           Mod_SEL                     
   );


localparam                              TX_NUM = 8'd7              ;
localparam                              N = 6000                   ;//传输一个字节所需要的时间 10*(50M/115200)和波特率有关

localparam                              state0 = 4'd0              ;
localparam                              state1 = 4'd1              ;
localparam                              state2 = 4'd2              ;
localparam                              state3 = 4'd3              ;
localparam                              state4 = 4'd4              ;
localparam                              state5 = 4'd5              ;
localparam                              state6 = 4'd6              ;
localparam                              state7 = 4'd7              ;



wire                                    TX_INT                     ;
wire                   [ 7:0]           tx_data                    ;
wire                                    sys_rst_n                  ;

reg                                     TX_INT_T                   ;
reg                    [ 7:0]           tx_data_T                  ;

reg                    [ 7:0]           TXdatacount                ;
reg                    [ 7:0]           TRP_REG                    ;
reg                    [ 7:0]           TX_REG[TX_NUM:1]           ;
reg                    [ 7:0]           data_tx[TX_NUM:1]          ;

reg                    [15:0]           count                      ;
reg                    [ 3:0]           state,next_state,flag      ;

assign TX_INT  = TX_INT_T;
assign tx_data = tx_data_T;


  uart_send  #(.BPS_CNT(BPS_CNT))
             u_uart_send(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst                   ),
    .uart_en                           (TX_INT                    ),
    .uart_din                          (tx_data                   ),
    .uart_txd                          (uart_txd                  ) 
             );



  always @ (posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
      TRP_REG <= 8'd0;
    else
      TRP_REG    <= {TRP_REG[6:0],trig};                            //检测到触发信号
  end




  //----------------TRANSMIT--------------
  always @ (posedge sys_clk or negedge sys_rst) begin               //计数器
    if(!sys_rst)
      count <= 0;
    else begin
      case(flag)
        0: begin
          count <= 0;
        end
        1: begin
          count <= count + 1;
          if(count == 4)        begin
            count <= 0;
          end
        end
        2: begin
          count <= count + 1;
          if(count == 2*N)      begin
            count <= 0;
          end
        end
        3: begin
          count <= count + 1;
          if(count == 2*N)      begin
            count <= 0;
          end
        end
        4: begin
          count <= count + 1;
          if(count == 10_000)   begin
            count <= 0;
          end                                                       //50ns
        end
        default:
          ;
      endcase
    end
  end



  always @ (posedge sys_clk or negedge sys_rst) begin               //状态切换
    if(!sys_rst) begin
      state   <= state0;
      flag    <=  8'd0;
    end
    else begin
      case(state)
        state0: begin
          state <= state1;
          flag <= 8'd0;
        end
        state1: begin
          if(TRP_REG[1:0] == 2'b01)                                 //必须数上变频模式下的触发才回传
          begin
            state <= state2;
            flag <= 8'd1;
          end
          else begin
            state <= state1;
            flag <= 8'd0;
          end
        end
        state2: begin
          if(count == 4) begin
            state <= state3;
            flag <= 8'd2;
          end
        end
        state3: begin
          if(count == 2*N)                                          //这里预留了2倍的接收时间
          begin
            if(TXdatacount < TX_NUM) begin
              state    <= state3;
              flag     <=  8'd2;
            end
            else begin
              state    <= state4;
              flag     <=  8'd0 ;
            end
          end
        end
        state4: begin
          //if(count == 100000)
          //	begin state <= state1;flag <= 0;end
          state <= state1;
          flag <= 0;
        end
        default:
          ;
      endcase
    end
  end




  always @ (posedge sys_clk or negedge sys_rst)                     //串口发送
  begin
    if(!sys_rst) begin
      TXdatacount        <= 0;
      TX_INT_T             <= 0;
      tx_data_T             <= 8'h00;
    end
    else begin
      case(state)
        state0: begin
          TXdatacount <= 0;
          TX_INT_T <= 0;
        end
        state1: begin
          TXdatacount <= 0;
          TX_INT_T <= 0;
        end

        state2: begin
          TX_REG[1] <= 8'hFF;
          TX_REG[2] <= Adress;
          TX_REG[3] <= Mod_SEL;
          TX_REG[4] <= D[23:16];
          TX_REG[5] <= D[15:8];
          TX_REG[6] <= D[7:0];
          TX_REG[7] <= 8'hAA;
        end

        state3: begin
          if(count == 1) begin
            TX_INT_T  <= 0;
            tx_data_T <= TX_REG[TXdatacount + 1];
          end

          else if(count == 2) begin
            TX_INT_T      <= 1;
            TXdatacount   <= TXdatacount + 1;
          end

          else if(count == 4) begin
            TX_INT_T      <= 0;                                     //发送完成标志拉低
          end
        end

        state4: begin
          TXdatacount <= 0;
          TX_INT_T <= 0;
        end
        default:
          ;
      endcase
    end
  end

endmodule

