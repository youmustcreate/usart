module usart_trans
  #(parameter BPS_CNT = 16'd434)
   (
    input                               sys_clk,sys_rst            ,//使能高电平有效，低电平复位
    output                              uart_txd                   ,
    input                               received_done              ,
    input              [23:0]           D                          ,
    input              [ 1:0]           Adress                     ,
    input              [ 5:0]           Mod_SEL                     
   );

localparam                              TX_NUM = 8'd5              ;//回传数据字节总数
localparam                              N = 10*BPS_CNT             ;//传输一个字节所需要的时间 10*(50M/115200)和波特率有关

localparam                              state0 = 4'd0              ;
localparam                              state1 = 4'd1              ;
localparam                              state2 = 4'd2              ;

wire                                    tx_byte_en                 ;
wire                   [ 7:0]           tx_byte                    ;
wire                                    sys_rst_n                  ;
wire                   [ 7:0]           TX_REG[TX_NUM:1]           ;

reg                                     tx_byte_en_T               ;
reg                    [ 7:0]           tx_byte_T                  ;

reg                    [ 7:0]           TXdatacount                ;
reg                    [ 7:0]           TRP_REG                    ;


reg                    [15:0]           count                      ;
reg                    [ 3:0]           state                      ;
reg                    [ 7:0]           count_flag                 ;//计数方式标志位

assign tx_byte_en    =  tx_byte_en_T;
assign tx_byte[7:0]  =  tx_byte_T[7:0];

assign TX_REG[1]     =  {6'b0,Adress};
assign TX_REG[2]     =  {2'b0,Mod_SEL};
assign TX_REG[3]     =  D[23:16];
assign TX_REG[4]     =  D[15:8];
assign TX_REG[5]     =  D[7:0];

//检测数据接收完毕 给出的回传触发信号 trig
  always @ (posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
      TRP_REG    <= 8'd0;
    else
      TRP_REG    <= {TRP_REG[6:0],received_done};                            
  end

//--------------------状态切换----------------------------------
  always @ (posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst) begin
      state       <= state0;
      count_flag  <=  8'd0;
    end
    
    else begin
      case(state)
        state0: begin
          //检测到上升沿触发就开始回传
          if(TRP_REG[1:0] == 2'b01) begin                                 
            state       <= state1;
            count_flag  <= 8'd1;
          end
        end
        
        state1: begin
          //这里只留了一倍的发送时间
          if(count == N)                                          
          begin
            if(TXdatacount < TX_NUM) begin
              state       <= state1;
              count_flag  <= 8'd1;
            end

            else begin
              state       <= state2;
              count_flag  <= 8'd0 ;
            end
          end
        end

        state2: begin
          state      <= state0;
          count_flag <= 0;
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
      case(count_flag)
        0: 
          count <= 0;
        
        1: begin
          count <= count + 1;
          //这里只留了一倍的发送时间
          if(count == N)
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
      tx_byte_en_T         <= 0;
      tx_byte_T            <= 8'h00;
    end

    else begin
      case(state)
        state0: begin
          TXdatacount  <= 0;
          tx_byte_en_T <= 0;
        end

        // state1: begin
        // end

        state1: begin
          if(count == 1) begin
            tx_byte_T     <= TX_REG[TXdatacount + 1];
            tx_byte_en_T  <= 1;
            TXdatacount   <= TXdatacount + 1;
          end

          else if(count == 3) begin 
            tx_byte_en_T  <= 0;                                     //发送完成标志拉低
          end
        end

        state2: begin
          TXdatacount   <= 0;
          tx_byte_en_T  <= 0;
        end
        default:
          ;
      endcase
    end
  end

uart_send #(.BPS_CNT(BPS_CNT))
          u_uart_send(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst                   ),
    .tx_byte_en                        (tx_byte_en                ),
    .tx_byte                           (tx_byte                   ),
    .uart_txd                          (uart_txd                  ) 
);

endmodule 