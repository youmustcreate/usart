module TOP(
    input                               CLK_50M                    ,//50MHZ
    input                               uart_rxd                   ,
    output                              uart_txd                   ,
    output                              led                        ,
    output             [23:0]           D                          ,
    output             [ 1:0]           Adress                     ,
    output             [ 5:0]           Mod_SEL                    ,
    output                              TRP                         
  );

wire                                    sys_clk                    ;
wire                                    sys_rst                    ;
wire                                    sys_rst_n                  ;
wire                                    clk_200M                   ;

  PLL uPLL(
    .inclk0                            (CLK_50M                   ),//50MHZ
    .c0                                (sys_clk                   ),//100MHZ
    .c1                                (clk_200M                  ) //200MHZ
      );

  delay u_delay(
    .sys_clk                           (CLK_50M                   ),
    .en                                (sys_rst                   ),//高电平使能
    .RST                               (sys_rst_n                 ) //低电平使能
        );

  led u_led(
    .sys_clk                           (CLK_50M                   ),
    .sys_rst                           (sys_rst                   ),//高电平使能
    .led0                              (led                       ) 
      );

  usart_top u_usart_top(
    .sys_clk                           (CLK_50M                   ),//50MHZ
    .sys_rst                           (sys_rst                   ),
    .uart_rxd                          (uart_rxd                  ),
    .uart_txd                          (uart_txd                  ),

    .Adress                            (Adress                    ),
    .Mod_SEL                           (Mod_SEL                   ),
    .D                                 (D                         ),
    .TRP                               (TRP                       ) 
            );



endmodule
