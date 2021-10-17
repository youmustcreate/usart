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

localparam                              TX_NUM = 8'd5              ;//回传数据字节总数
localparam                              N = 6000                   ;//传输一个字节所需要的时间 10*(50M/115200)和波特率有关

localparam                              state0 = 4'd0              ;
localparam                              state0 = 4'd1              ;
localparam                              state1 = 4'd2              ;
localparam                              state2 = 4'd3              ;

wire                                    tx_byte_en                 ;
wire                   [ 7:0]           tx_byte                    ;
wire                                    sys_rst_n                  ;

reg                                     tx_byte_en_T               ;
reg                    [ 7:0]           tx_byte_T                  ;

reg                    [ 7:0]           TXdatacount                ;
reg                    [ 7:0]           TRP_REG                    ;
reg                    [ 7:0]           TX_REG[TX_NUM:1]           ;
reg                    [ 7:0]           data_tx[TX_NUM:1]          ;

reg                    [15:0]           count                      ;
reg                    [ 3:0]           state,flag                 ;

assign tx_byte_en  = tx_byte_en_T;
assign tx_byte     = tx_byte_T;

  uart_send  #(.BPS_CNT(BPS_CNT))
             u_uart_send(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst                   ),
    .tx_byte_en                        (tx_byte_en                ),
    .tx_byte                           (tx_byte                   ),
    .uart_txd                          (uart_txd                  ) 
             );

//检测数据接收完毕 给出的回传触发信号 trig
  always @ (posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
      TRP_REG    <= 8'd0;
    else
      TRP_REG    <= {TRP_REG[6:0],trig};                            
  end

//--------------------状态切换----------------------------------
  always @ (posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst) begin
      state   <= state0;
      flag    <=  8'd0;
    end
    
    else begin
      case(state)
        state0: begin
          //检测到上升沿触发就开始回传
          if(TRP_REG[1:0] == 2'b01) begin                                 
            state <= state1;
            flag  <= 8'd1;
          end

          else begin
            state <= state0;
            flag  <= 8'd0;
          end
        end

        state1: begin
          if(count == 4) begin
            state <= state2;
            flag  <= 8'd2;
          end
        end
        
        state2: begin
          //这里预留了2倍的接收时间
          if(count == 2*N)                                          
          begin
            if(TXdatacount < TX_NUM) begin
              state    <= state2;
              flag     <=  8'd2;
            end

            else begin
              state    <= state3;
              flag     <=  8'd0 ;
            end
          end
        end

        state3: begin
          state <= state0;
          flag <= 0;
        end
        
        default:
          ;
      endcase
    end
  end

  //----------------TRANSMIT计数器--------------
  always @ (posedge sys_clk or negedge sys_rst) begin               
    if(!sys_rst)
      count <= 0;

    else begin
      case(flag)
        0: 
          count <= 0;
        
        1: begin
          count <= count + 1;
          if(count == 4)
            count <= 0;
        end
        
        2: begin
          count <= count + 1;
          if(count == 2*N)
            count <= 0;
        end

        default:
          ;
      endcase
    end
  end

//----------------------按字节发送模块--------------------
  always @ (posedge sys_clk or negedge sys_rst)                     //串口发送
  begin
    if(!sys_rst) begin
      TXdatacount          <= 0;
      tx_byte_en_T             <= 0;
      tx_byte_T            <= 8'h00;
    end

    else begin
      case(state)
        state0: begin
          TXdatacount <= 0;
          tx_byte_en_T <= 0;
        end

        state1: begin
          TX_REG[1] <= Adress;
          TX_REG[2] <= Mod_SEL;
          TX_REG[3] <= D[23:16]; //24位数据位
          TX_REG[4] <= D[15:8];
          TX_REG[5] <= D[7:0];
        end

        state2: begin
          if(count == 1) begin
            tx_byte_en_T  <= 0;
            tx_byte_T <= TX_REG[TXdatacount + 1];
          end

          else if(count == 2) begin
            tx_byte_en_T      <= 1;
            TXdatacount   <= TXdatacount + 1;
          end

          else if(count == 4) begin
            tx_byte_en_T      <= 0;                                     //发送完成标志拉低
          end
        end

        state3: begin
          TXdatacount <= 0;
          tx_byte_en_T <= 0;
        end
        default:
          ;
      endcase
    end
  end

endmodule

