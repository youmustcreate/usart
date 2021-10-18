module delay(
    input                               sys_clk                    ,
    output reg                          en,RST                      
  );

reg                    [31:0]           count = 0                  ;

  always @(posedge sys_clk) begin                                   //20ns
    if(count == 32'd50) begin                                 //达到1s    50000000 之后不再继续count++
      en <= 1;
      RST<=0;
    end
    else begin
      en <= 0;
      RST<=1;
      count <= count + 1'b1;
    end
  end

endmodule
