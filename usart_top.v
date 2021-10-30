module usart_top
  (
    input                               sys_clk,sys_rst            ,//使能高电平有效，低电平复位
    input                               uart_rxd                   ,
    output                              uart_txd                   ,
    output             [23:0]           D                          ,
    output             [ 1:0]           Adress                     ,
    output             [ 5:0]           Mod_SEL                    ,
    output                              TRP                         
  );
//50MHZ,115200bps
//多少个sys_clk时钟周期发送一个二进制位
parameter                               BPS_CNT = 16'd434          ;

wire                                    received_done              ;//接收完毕给信号到发送模块

  usart_rec #(.BPS_CNT(BPS_CNT))
            u_rec                                                   //主从串口握手控制, 接收模块
            (
    .sys_clk                           (sys_clk                   ),
    .sys_rst                           (sys_rst                   ),
    .uart_rxd                          (uart_rxd                  ),
    .received_done                     (received_done             ),
    .Adress                            (Adress                    ),
    .Mod_SEL                           (Mod_SEL                   ),
    .D                                 (D                         ),
    .TRP                               (TRP                       ) 
);

  usart_trans #(.BPS_CNT(BPS_CNT))
              u_trans
              (
    .sys_clk                           (sys_clk                   ),
    .sys_rst                           (sys_rst                   ),
    .uart_txd                          (uart_txd                  ),
    .received_done                     (received_done             ),
    .Adress                            (Adress                    ),
    .Mod_SEL                           (Mod_SEL                   ),
    .D                                 (D                         ) 
);

endmodule 