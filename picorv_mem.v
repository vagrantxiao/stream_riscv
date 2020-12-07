module picorv_mem#(
  parameter MEM_SIZE=128*1024/4,
  parameter RAM_TYPE = "block"
  )(
  input clk,
  input resetn,
  input mem_valid,
  input mem_instr,
  output reg mem_ready,
  input [31:0] mem_addr,
  input [31:0] mem_wdata,
  input [3:0] mem_wstrb,
  output [31:0] mem_rdata,
  output val_out,
  output [31:0] dout,
  input ready_downward,
  input [31:0] din,
  input val_in,
  output reg ready_upward,
  output reg [31:0] irq
  ); 
  


	(* ram_style = RAM_TYPE *) reg [31:0] memory [0:MEM_SIZE-1];
	wire val_out_tmp;
	wire stream2riscv_vld;
	
	initial begin
      //$readmemh("/home/ylxiao/ws_182/F200929_riscv/src/firmware.hex", memory);
      $readmemh("/home/ylxiao/ws_riscv/picorv32/firmware/firmware.hex", memory);
    end
    
    reg [15:0] count_cycle;
    always @(posedge clk) count_cycle <= resetn ? count_cycle + 1 : 0;

    always @* begin
        irq = 0;
        irq[4] = &count_cycle[12:0];
        irq[5] = &count_cycle[15:0];
    end	

    
    assign val_out = (mem_addr == 32'h10000008) ? val_out_tmp : 1'b0;
    assign stream2riscv_vld =  (mem_addr == 32'h10000004) ? 1'b1 : 1'b0;
    

    reg [7:0] ready_upward_cnt;
    wire see_read_addr_cnt_en;
    reg [7:0]  see_read_addr_cnt;
        
    always@(posedge clk) begin
        if(!resetn) begin
            ready_upward <= 0;
        end else if((ready_upward_cnt != see_read_addr_cnt) && val_in) begin
            ready_upward <= 1;
        end else begin
            ready_upward <= 0;
        end
    end    
    
    
    always@(posedge clk) begin
        if(!resetn) begin
            ready_upward_cnt <= 0;
        end else if((ready_upward_cnt != see_read_addr_cnt) && val_in) begin
            ready_upward_cnt <= ready_upward_cnt + 1;
        end else begin
            ready_upward_cnt <= ready_upward_cnt;
        end
    end    
    
    
    always@(posedge clk) begin
        if(!resetn) begin
            see_read_addr_cnt <= 0;
        end else if(see_read_addr_cnt_en) begin
            see_read_addr_cnt <= see_read_addr_cnt + 1;
        end
    end        
    
                
    rise_detect #(
        .data_width(1)
    )i1(
        .data_out(val_out_tmp),
        .data_in(mem_valid),
        .clk(clk),
        .reset(!resetn)
    );
        
    rise_detect #(
        .data_width(1)
    )i2(
        .data_out(see_read_addr_cnt_en),
        .data_in(stream2riscv_vld),
        .clk(clk),
        .reset(!resetn)
    );        
    
    reg mem_rdata_sel;
    wire [14:0] true_addr;
    assign true_addr = mem_addr[16:2];
    assign dout = mem_wdata;
	always @(posedge clk) begin
		mem_ready <= 0;
		if (mem_valid && !mem_ready) begin
				if(mem_addr == 32'h10000008) begin
				    mem_ready <= ready_downward;
				end else if(mem_addr == 32'h10000004) begin
				    mem_ready <= val_in;
				end else begin
				    mem_ready <= 1'b1;
				end
				
				if(mem_addr == 32'h10000004) begin
				    mem_rdata_sel <= 1;
				end else begin
				    mem_rdata_sel <= 0;
				end
				
				if (mem_wstrb[0]) memory[true_addr][ 7: 0] <= mem_wdata[ 7: 0];
				if (mem_wstrb[1]) memory[true_addr][15: 8] <= mem_wdata[15: 8];
				if (mem_wstrb[2]) memory[true_addr][23:16] <= mem_wdata[23:16];
				if (mem_wstrb[3]) memory[true_addr][31:24] <= mem_wdata[31:24];
        end
	end


wire [31:0] do;
assign mem_rdata = mem_rdata_sel ? din : do;

ram0#(
    .DWIDTH(8),
    .AWIDTH(15),
    .RAM_TYPE("block"),
    .INIT_VALUE("/home/ylxiao/ws_riscv/picorv32/firmware/firmware0.hex")
    )ram_inst_0(                                                          
    // Write port                                                     
    .clk(clk),                                                      
    .di(mem_wdata[ 7: 0]),                                                  
    .wren((mem_valid && !mem_ready)&&(mem_wstrb[0])),                                                       
    .wraddr(true_addr),                                               
    // Read port                                                                                                           
    .rden(mem_valid && !mem_ready),                                                       
    .rdaddr(true_addr),                                               
    .do(do[7:0])
    );   

ram0#(
    .DWIDTH(8),
    .AWIDTH(15),
    .RAM_TYPE("block"),
    .INIT_VALUE("/home/ylxiao/ws_riscv/picorv32/firmware/firmware1.hex")
    )ram_inst_1(                                                          
    // Write port                                                     
    .clk(clk),                                                      
    .di(mem_wdata[ 15: 8]),                                                  
    .wren((mem_valid && !mem_ready)&&(mem_wstrb[1])),                                                       
    .wraddr(true_addr),                                               
    // Read port                                                                                                           
    .rden(mem_valid && !mem_ready),                                                       
    .rdaddr(true_addr),                                               
    .do(do[15:8])
    ); 

ram0#(
    .DWIDTH(8),
    .AWIDTH(15),
    .RAM_TYPE("block"),
    .INIT_VALUE("/home/ylxiao/ws_riscv/picorv32/firmware/firmware2.hex")
    )ram_inst_2(                                                          
    // Write port                                                     
    .clk(clk),                                                      
    .di(mem_wdata[ 23: 16]),                                                  
    .wren((mem_valid && !mem_ready)&&(mem_wstrb[2])),                                                       
    .wraddr(true_addr),                                               
    // Read port                                                                                                           
    .rden(mem_valid && !mem_ready),                                                       
    .rdaddr(true_addr),                                               
    .do(do[23:16])
    ); 
    
ram0#(
    .DWIDTH(8),
    .AWIDTH(15),
    .RAM_TYPE("block"),
    .INIT_VALUE("/home/ylxiao/ws_riscv/picorv32/firmware/firmware3.hex")
    )ram_inst_3(                                                          
    // Write port                                                     
    .clk(clk),                                                      
    .di(mem_wdata[ 31: 24]),                                                  
    .wren((mem_valid && !mem_ready)&&(mem_wstrb[3])),                                                       
    .wraddr(true_addr),                                               
    // Read port                                                                                                           
    .rden(mem_valid && !mem_ready),                                                       
    .rdaddr(true_addr),                                               
    .do(do[31:24])
    );   
endmodule

