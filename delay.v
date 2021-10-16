module delay(
    input                               sys_clk                    ,
    output reg                          en,RST                      
  );

reg                    [31:0]           count = 0                  ;

  always @(posedge sys_clk) begin                                   //100M 10ns
    if(count == 32'd10) begin                                       //达到100ns之后不再继续count++   之前是1s
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
