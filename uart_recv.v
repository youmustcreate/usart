module uart_recv
  #(parameter BPS_CNT = 16'd434)
   (
    input                               sys_clk                    ,//系统时钟50Mhz
    input                               sys_rst_n                  ,//系统复位，低电平有效
    input                               uart_rxd                   ,//UART接收端口
    output reg                          rx_byte_done               ,//接收一个字节完成标志信号
    output reg         [ 7:0]           rx_data                     //接收的一个字节数据
   );

reg                                     uart_rxd_d0                ;
reg                                     uart_rxd_d1                ;
reg                    [15:0]           clk_cnt                    ;//系统时钟计数器
reg                    [ 3:0]           rx_cnt                     ;//接收数据计数器
reg                                     rx_flag                    ;//接收过程标志信号
reg                    [ 7:0]           rx_data_t                  ;//接收数据寄存器

  //wire define
wire                                    start_flag                 ;

  //捕获接收端口下降沿(起始位)，得到一个时钟周期的脉冲信号
  assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);

  //对UART接收端口的数据延迟两个时钟周期
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      uart_rxd_d0 <= 1'b0;
      uart_rxd_d1 <= 1'b0;
    end
    
    else begin
      uart_rxd_d0  <= uart_rxd;         //rxd==0时
      uart_rxd_d1  <= uart_rxd_d0;
    end
  end

//----------------------------------------------------------------------------------------------

  //当脉冲信号start_flag到达时，进入接收过程
  always @(posedge sys_clk or negedge sys_rst_n) begin     
    if (!sys_rst_n)
      rx_flag <= 1'b0;
    
    else begin
      if(start_flag)                                                //检测到起始位
        rx_flag <= 1'b1;                                            //进入接收过程，标志位rx_flag拉高
      
      else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2 - 2))         //clk_cnt==217
        rx_flag <= 1'b0;                                            //计数到停止位中间时，停止接收过程
      else
        rx_flag <= rx_flag;
    end
  end

  //进入接收过程后，启动系统时钟计数器与接收数据计数器
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      clk_cnt <= 16'd0;
      rx_cnt  <= 4'd0;
    end

    else if ( rx_flag ) begin                                       //处于接收过程
      //clk_cnt 计数到 433
      if (clk_cnt < BPS_CNT - 1) begin
        clk_cnt <= clk_cnt + 1'b1;
        rx_cnt  <= rx_cnt;
      end
      
      else begin
        clk_cnt <= 16'd0;                                           //对系统时钟计数达一个波特率周期后清零
        //rx_cnt 接收完一个二进制位 加一
        rx_cnt  <= rx_cnt + 1'b1;       
      end
    end

    else begin                                                      //接收过程结束，计数器清零
      clk_cnt <= 16'd0;
      rx_cnt  <= 4'd0;
    end
  end

  //根据接收数据计数器来寄存uart接收端口数据
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if ( !sys_rst_n)
      rx_data_t <= 8'd0;

    else if(rx_flag)                                                //系统处于接收过程
      if (clk_cnt == BPS_CNT/2) begin                               //判断系统时钟计数器计数到数据位中间
        case ( rx_cnt )
          4'd1 :
            rx_data_t[0] <= uart_rxd_d1;                               //寄存数据位最低位
          4'd2 :
            rx_data_t[1] <= uart_rxd_d1;
          4'd3 :
            rx_data_t[2] <= uart_rxd_d1;
          4'd4 :
            rx_data_t[3] <= uart_rxd_d1;
          4'd5 :
            rx_data_t[4] <= uart_rxd_d1;
          4'd6 :
            rx_data_t[5] <= uart_rxd_d1;
          4'd7 :
            rx_data_t[6] <= uart_rxd_d1;
          4'd8 :
            rx_data_t[7] <= uart_rxd_d1;                               //寄存数据位最高位
          default:
            ;
        endcase
      end
      else
        rx_data_t <= rx_data_t;
    else
      rx_data_t <= 8'd0;
  end

  //数据接收完毕后给出标志信号并寄存输出接收到的数据
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      rx_data      <= 8'd0;
      rx_byte_done <= 0;
    end

    else if(rx_cnt == 4'd9) begin                                   //接收数据计数器计数到停止位时
      rx_data      <= rx_data_t;                                    //寄存输出接收到的数据
      rx_byte_done <= 1;                                            //并将接收完成标志位拉高
    end
    
    else begin
      rx_data      <= 8'd0;
      rx_byte_done <= 0;
    end
  end

endmodule
