module uart_send
  #(parameter BPS_CNT = 16'd434)
   (
    input                               sys_clk                    ,//系统时钟
    input                               sys_rst_n                  ,//系统复位，低电平有效
    input                               tx_byte_en                 ,//发送使能信号
    input              [ 7:0]           tx_byte                    ,//待发送数据
    output reg                          uart_txd                    //UART发送端口
   );

reg                                     uart_en_d0                 ;
reg                                     uart_en_d1                 ;
reg                    [15:0]           clk_cnt                    ;//系统时钟计数器
reg                    [ 3:0]           tx_cnt                     ;//发送数据计数器
reg                                     tx_flag                    ;//发送过程标志信号
reg                    [ 7:0]           tx_byte_T                    ;//寄存发送数据

wire                                    en_flag                    ;

  //捕获uart_en上升沿，得到一个时钟周期的脉冲信号
  assign en_flag = (~tx_byte_en1) & tx_byte_en0;

  //对发送使能信号uart_en延迟两个时钟周期
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      tx_byte_en0 <= 1'b0;
      tx_byte_en1 <= 1'b0;
    end
    else begin
      tx_byte_en0 <= tx_byte_en;
      tx_byte_en1 <= tx_byte_en0;
    end
  end

  //当脉冲信号en_flag到达时,寄存待发送的数据，并进入发送过程
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      tx_flag <= 1'b0;
      tx_byte_T <= 8'd0;
    end

    else if (en_flag) begin                                         //检测到发送使能上升沿
      tx_flag <= 1'b1;                                              //进入发送过程，标志位tx_flag拉高
      tx_byte_T <= tx_byte;                                          //寄存待发送的数据
    end
    
    else if ((tx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2)) begin        //计数到停止位中间时，停止发送过程
      tx_flag <= 1'b0;                                              //发送过程结束，标志位tx_flag拉低
      tx_byte_T <= 8'd0;
    end
    
    else begin
      tx_flag <= tx_flag;
      tx_byte_T <= tx_byte_T;
    end
  end

  //进入发送过程后，启动系统时钟计数器与发送数据计数器
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      clk_cnt <= 16'd0;
      tx_cnt  <= 4'd0;
    end

    else if (tx_flag) begin                                         //处于发送过程
      if (clk_cnt < BPS_CNT - 1) begin
        clk_cnt <= clk_cnt + 1'b1;
        tx_cnt  <= tx_cnt;
      end
      
      else begin
        clk_cnt <= 16'd0;                                           //对系统时钟计数达一个波特率周期后清零
        tx_cnt  <= tx_cnt + 1'b1;                                   //此时发送数据计数器加1
      end
    end
    
    else begin                                                      //发送过程结束
      clk_cnt <= 16'd0;
      tx_cnt  <= 4'd0;
    end
  end

  //根据发送数据计数器来给uart发送端口赋值
  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
      uart_txd <= 1;
    
    else if (tx_flag)
    case(tx_cnt)
      4'd0:
        uart_txd <= 1'b0;                                           //起始位
      4'd1:
        uart_txd <= tx_byte_T[0];                                     //数据位最低位
      4'd2:
        uart_txd <= tx_byte_T[1];
      4'd3:
        uart_txd <= tx_byte_T[2];
      4'd4:
        uart_txd <= tx_byte_T[3];
      4'd5:
        uart_txd <= tx_byte_T[4];
      4'd6:
        uart_txd <= tx_byte_T[5];
      4'd7:
        uart_txd <= tx_byte_T[6];
      4'd8:
        uart_txd <= tx_byte_T[7];                                     //数据位最高位
      4'd9:
        uart_txd <= 1'b1;                                           //停止位
      default:
        ;
    endcase
    
    else
      uart_txd <= 1;                                             //空闲时发送端口为高电平
  end

endmodule
