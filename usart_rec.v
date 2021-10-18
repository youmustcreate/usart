module usart_rec
  #(parameter BPS_CNT = 16'd434)
   (
     input                               sys_clk,sys_rst            ,//使能高电平有效，低电平复位
     input                               uart_rxd                   ,
     output                              trig                       ,
     output reg         [23:0]           D                          ,
     output reg         [ 1:0]           Adress                     ,
     output reg         [ 5:0]           Mod_SEL                    ,
     output                              TRP
   );

wire                                    rx_byte_done               ;
wire                   [ 7:0]           rx_data                    ;//一个字节的数据
wire                                    sys_rst_n                  ;//串口模块内部低电平有效
reg                    [ 7:0]           RXdatacount                ;
reg                    [ 7:0]           RX_REG[RX_NUM:1]           ;
reg                    [ 7:0]           RX_REGT[RX_NUM:1]          ;

reg                    [ 3:0]           rx_byte_done_t             ;
reg                    [ 7:0]           LET                        ;
reg                                     LE                         ;
reg                                     R                          ;
reg                    [19:0]           count1                     ;//这里的位宽决定能计数到多少

    parameter                           RX_NUM = 8'd9              ;
//传输一个字节所需要的时间 10*(50M/115200)和波特率有关。等于10*BPS_CNT
localparam                              N = 6000                   ;

  //------------------------------------------------------------------------
uart_recv   #(.BPS_CNT(BPS_CNT))
            u_uart_recv(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst                   ),
    .uart_rxd                          (uart_rxd                  ),
    .rx_byte_done                      (rx_byte_done              ),
    .rx_data                           (rx_data                   ) //一个字节
            );

//------------------------------------------------------------------------
always @ (posedge sys_clk or negedge sys_rst) begin
  if(!sys_rst) begin
    rx_byte_done_t <= 4'd0;
    LET            <= 8'd0;
  end
  else begin
    rx_byte_done_t   <= {rx_byte_done_t[2:0],rx_byte_done};
    LET              <= {LET[6:0],LE};                                    //控制指令检测
  end
end

assign trig = LET[2];                                               //延迟一个更新脉冲输出
assign TRP  = LET[6];                                               //数据更新后50ns产生外触发信号，200ns保持时间


//------------------------RECEIVE----------------------------------------------
always @ (posedge sys_clk or negedge sys_rst) begin
  if(!sys_rst) begin
    RXdatacount <= 0;
    count1 <= 0;
    LE  <= 0;
    R <= 0;
  end

  else begin
    if(rx_byte_done_t [1:0] == 2'b01)               //posedge
    begin
      RX_REGT[RXdatacount + 1] <= rx_data;
      RXdatacount <= RXdatacount + 1;
    end

    else if(RX_REGT[1] == 8'hFF && RX_REGT[9] == 8'hAA && R == 1) begin        //控制指令
      count1 <= count1 + 1;
      if(count1 == 1) begin
        RX_REG[1]   <= RX_REGT[1];
        RX_REG[2]   <= RX_REGT[2];
        RX_REG[3]   <= RX_REGT[3];
        RX_REG[4]   <= RX_REGT[4];
        RX_REG[5]   <= RX_REGT[5];
        RX_REG[6]   <= RX_REGT[6];
        RX_REG[7]   <= RX_REGT[7];
        RX_REG[8]   <= RX_REGT[8];
        RX_REG[9]   <= RX_REGT[9];
      end

      else if(count1 == 3)
        LE <= 1;

      else if(count1 == 13)       begin                                      //10*20ns=200ns
        RX_REGT[1]     <= 8'h00;
        RX_REGT[9]     <= 8'h00;
        RXdatacount    <= 0;
        R              <= 0;
        LE             <= 0;
        count1         <= 0;
      end
    end

    else begin
      if(RXdatacount > 0) begin
        if(RX_REGT[1] != 8'hFF) begin
          RX_REGT[1]     <=8'h00;
          R              <= 0;
          LE             <= 0;
          RXdatacount    <= 0;
          count1         <= 0;
        end

        else begin
          count1 <= count1 + 1;
          if(count1 == N*9) begin   //9个字节 计数到54000
            count1   <= 0;
            if( (RXdatacount == RX_NUM ) && (RX_REGT[9] == 8'hAA) )            //控制指令
              R      <= 1;
            else begin
              R           <= 0;
              RXdatacount <= 0;
              RX_REGT[1]  <=8'h00;
            end
          end
        end
      end
    end
  end
end


//----------------------配置信号输出----------------------//
always @ (posedge sys_clk or negedge sys_rst) begin
  if(!sys_rst) begin                                                //上电默认状态
    Adress     <=  2'd0;
    Mod_SEL    <=  6'd1;
    D          <= 24'd0;
  end

  else begin
    if(LET[2:1] == 2'b01)                                           //一定要用上升沿来配置
    begin
      if(RX_REG[2][1:0] == 2'b00)                                   //频率控制
      begin
        Adress     <=  RX_REG[2][1:0];
        Mod_SEL  <=  RX_REG[3][5:0];
        D            <= {RX_REG[4],RX_REG[5],RX_REG[6]};
      end
      else if(RX_REG[2][1:0] == 2'b01)                              //上变频控制
      begin
        Adress     <=  RX_REG[2][1:0];
        Mod_SEL  <=  RX_REG[3][5:0];
        D            <= {16'd0,RX_REG[7]};
      end
      else if(RX_REG[2][1:0] == 2'b10)                              //上变频控制
      begin
        Adress     <=  RX_REG[2][1:0];
        Mod_SEL  <=  RX_REG[3][5:0];
        D            <= {16'd0,RX_REG[8]};
      end
    end
  end
end
//--------------------外触发信号---------------//
reg                    [15:0]           up_date                    ;
always @ (posedge sys_clk or negedge sys_rst)                       //备用
begin
  if(!sys_rst) begin
    up_date <= 0;
  end
  else begin
    up_date <= {up_date[14:0],trig};
  end
end

endmodule

// ! 红色的高亮注释
// ? 蓝色的高亮注释
// * 绿色的高亮注释
// todo 橙色的高亮注释
// // 灰色带删除线的注释
// 普通的注释