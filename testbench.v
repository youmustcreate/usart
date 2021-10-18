`timescale 1 ns/ 1 ps
module testbench();

  parameter SYS_CLK = 50;				       //系统时钟频率，单位Mhz
  parameter SYS_PRE = 1000/(SYS_CLK*2);	       //时钟周期，单位ns
  parameter UART_BPS = 115200;				   //串口波特率
  parameter BPS_CNT = 1_000_000_000/UART_BPS;  //用于串口仿真的时延

  reg sys_clk;

  // TOP Inputs
  reg   uart_rxd;

  // TOP Outputs
  wire  uart_txd;
  wire  led;
  wire  [23:0]  D;
  wire  [ 1:0]  Adress;
  wire  [ 5:0]  Mod_SEL;
  wire  TRP;


  TOP  u_TOP (
         .CLK_50M                 ( sys_clk    ),
         .uart_rxd                ( uart_rxd   ),
         .uart_txd                ( uart_txd   ),
         .led                     ( led        ),
         .D                       ( D          ),
         .Adress                  ( Adress     ),
         .Mod_SEL                 ( Mod_SEL    ),
         .TRP                     ( TRP        )
       );



  initial begin
    #0;
    sys_clk = 0;
    uart_rxd = 1;

    #2000;

    //串口起始信号：高电平到低电平（下降沿）
    #BPS_CNT;
    uart_rxd = 1;  //时间延持BPS_CNTns，自我检查`timescale 1 ns/ 1 ps
    #BPS_CNT;
    uart_rxd = 0;
    //串口数据信号：***从位0到位7***，依次发送
    //测试数据为 11111111 00000000  00111111 00000000 00001111 10100000 10001101 00001010 10101010 
    //FF 00 3F 00 0F A0 8D  0A AA
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;



    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
//////////////////////////////////////

    #BPS_CNT;
    uart_rxd = 0;


    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;


    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
////////////////////////////////////////////
    #BPS_CNT;
    uart_rxd = 0;

    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;


    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
///////////////////////////////////////
    #BPS_CNT;
    uart_rxd = 0;



    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;


    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
/////////////////////////////////////////

    #BPS_CNT;
    uart_rxd = 0;



    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;

    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;

    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
/////////////////////////////////////////////

    #BPS_CNT;
    uart_rxd = 0;



    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;

    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;


    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
/////////////////////////////////////////////
    #BPS_CNT;
    uart_rxd = 0;



    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;

    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 1;
    
    #BPS_CNT;
    uart_rxd = 0;

    #BPS_CNT;
    uart_rxd = 1;


    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
/////////////////////////////////////////////
    
    #BPS_CNT;
    uart_rxd = 0;


    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 0;

    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;



    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
/////////////////////////////////////////////
    #BPS_CNT;
    uart_rxd = 0;

    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;
    #BPS_CNT;
    uart_rxd = 1;
    #BPS_CNT;
    uart_rxd = 0;

    //串口结束信号
    #BPS_CNT;
    uart_rxd = 1;
/////////////////////////////////////////
    #7000000;
    $stop;

    $display("Running testbench");
  end


  always  #SYS_PRE sys_clk = ~sys_clk;  //产生时钟
endmodule
