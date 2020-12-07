module picorv32_wrapper#(
  parameter MEM_SIZE = 128*1024/4
  )(
  input clk,
  input resetn,
  output reg [48:0] print_out,
  input val_in,
  output ready_upward,
  input [31:0] din,
  output val_out,
  input ready_downward,
  output [31:0] dout,
  output trap
);
  wire mem_valid;
  wire mem_instr;
  wire mem_ready;
  wire [31:0] mem_addr;
  wire [31:0] mem_wdata;
  wire [3:0] mem_wstrb;
  wire [31:0] mem_rdata;
  wire [31:0] irq;



    
	picorv32 #(
	) uut (
	.clk         (clk        ),
	.resetn      (resetn     ),
	.trap        (trap       ),
	.mem_valid   (mem_valid  ),
	.mem_instr   (mem_instr  ),
	.mem_ready   (mem_ready  ),
	.mem_addr    (mem_addr   ),
	.mem_wdata   (mem_wdata  ),
	.mem_wstrb   (mem_wstrb  ),
	.mem_rdata   (mem_rdata  ),
	.irq         (irq        )
	);
	
	picorv_mem#(
        .MEM_SIZE(MEM_SIZE)
	) picorv_mem_inst (
        .clk         (clk),
        .resetn      (resetn     ),
        .mem_valid   (mem_valid  ),
        .mem_instr   (mem_instr  ),
        .mem_ready   (mem_ready  ),
        .mem_addr    (mem_addr   ),
        .mem_wdata   (mem_wdata  ),
        .mem_wstrb   (mem_wstrb  ),
        .mem_rdata   (mem_rdata  ),
        .val_out     (val_out     ),
        .ready_downward(ready_downward),
        .dout        (dout        ),
        .val_in      (val_in    ),
        .ready_upward(ready_upward),
        .din         (din       ),
        .irq         (irq        )
	); 

	
    always@(posedge clk) begin
        if(!resetn) begin
          print_out <= 0;
        end else begin
          if(mem_addr == 32'h1000_0000 && mem_ready==1)
            print_out <= {1'b1, 40'h0000000000, mem_wdata[7:0]};
          else
            print_out <= {1'b0, 48'h0000_0000_0000};
        end          
    end
    

   /* 
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
     */   
        

endmodule
