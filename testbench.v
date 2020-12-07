module testbench;
    parameter MEM_SIZE=128*1024/4;
	reg clk = 1;
	reg resetn = 0;
	wire trap;
    wire [48:0] print_out;

    wire [31:0] din;
    wire val_in;
    wire ready_upward;
    wire [31:0] dout;
    wire val_out;
    wire ready_downward;
    
    
    picorv32_wrapper#(
    .MEM_SIZE(MEM_SIZE)
    )i1(
    .clk(clk),
    .resetn(resetn),
    .print_out(print_out),
    .val_in(val_out),
    .ready_upward(ready_downward),
    .din(dout),
    .val_out(val_in),
    .ready_downward(ready_upward),
    .dout(din),
    .trap(trap)
    );
	

      fifo_stream fifo_stream_inst(
          .clk(clk),
          .reset(!resetn),
          .din(din),
          .val_in(val_in),
          .ready_upward(ready_upward),
          .dout(dout),
          .val_out(val_out),
          .ready_downward(ready_downward)
          );
	
	
	always #5 clk = ~clk;

    always@(posedge clk) begin
        if (trap) $finish;
    end

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("testbench.vcd");
            $dumpvars(0, testbench);
        end
        repeat (100) @(posedge clk);
        resetn <= 1;
        repeat (1000000) @(posedge clk);
        $finish;
    end
    

    wire display_en;
    wire [7:0] display_char;
    assign display_en = (i1.mem_addr == 32'h1000_0000) ? 1:0;
    assign display_char = i1.mem_wdata[7:0];
    
    always@(posedge clk) begin
        if(print_out[48])
            $write("%c", print_out[7:0]);
    end
    
    
	
endmodule
