`timescale 1ns / 1ps

module round_and_clip #(
        parameter WIDTH=31,
        parameter FINAL=16,    
        parameter SCALE=5   
    )
    (
        input logic [WIDTH-1:0]rac_in,
        output logic [FINAL-1:0]rac_out,
        output logic sat
    );
    
	logic rco;
	logic neg_half;
	logic discard_ones;
	logic discard_zeros;
	logic body_ones;
	logic body_zeros;
	logic [5:0] rac_check;
	logic [FINAL-1:0] max_neg = {1'b1,{(FINAL-1){1'b0}}};
	logic [FINAL-1:0] max_pos = {1'b0,{(FINAL-1){1'b1}}};
	logic [FINAL:0] round_res_tmp;
	logic [FINAL-1:0]round_res;
	
	generate
			if(SCALE == 1) begin
				always_comb begin		
					if(FINAL + SCALE == WIDTH)begin
						//discard
						if(rac_in[WIDTH-1] == 1)begin
							discard_ones = 1;
							discard_zeros = 0;
						end else begin
							discard_ones = 0;
							discard_zeros =1;
						end	
					end else begin
						//discard
						if(&rac_in[WIDTH-1:FINAL+SCALE] == 1)begin
							discard_ones = 1;
							discard_zeros = 0;		
						end else begin
							if(|rac_in[WIDTH-1:FINAL+SCALE] == 0)begin
								discard_ones = 0;
								discard_zeros = 1;
							end else begin 
								discard_ones = 0;
								discard_zeros = 0;
							end
						end
					end
						//body
						if(&rac_in[FINAL+SCALE-2:SCALE] == 1)begin
							body_ones = 1;
							body_zeros = 0;
						end else begin
							if(|rac_in[FINAL+SCALE-2:SCALE] == 0)begin
								body_ones = 0;
								body_zeros = 1;
							end else begin
								body_ones = 0;
								body_zeros = 0;
							end
						end	
						//neg_half
						if(rac_in[WIDTH-1] == 1)
							neg_half = 1;
						else
							neg_half = 0;
						//rco
						rco = rac_in[SCALE-1];
				
						rac_check = {rco, neg_half, discard_ones, discard_zeros, body_ones, body_zeros};
						round_res_tmp = (rac_in[FINAL+SCALE-1:SCALE-1] + 1);
						round_res = round_res_tmp[FINAL:1];
					
				end
			end
		else if(SCALE == 0)begin
			always_comb begin
				//discard
				if(&rac_in[WIDTH-1:FINAL] == 1)begin
					discard_ones = 1;
					discard_zeros = 0;
				end else begin
					if(|rac_in[WIDTH-1:FINAL] == 0)begin
						discard_ones = 0;
						discard_zeros = 1;
					end else begin 
						discard_ones = 0;
					discard_zeros = 0;
					end
				end
				//body
				if(&rac_in[FINAL-2:0] == 1)begin
					body_ones = 1;
					body_zeros = 0;
				end else begin
					if(|rac_in[FINAL-2:0] == 0)begin
						body_ones = 0;
						body_zeros = 1;
					end else begin
						body_ones = 0;
						body_zeros = 0;
					end
				end
				//neg_half
				neg_half = 0;

				//rco
				rco = 0;
				rac_check = {rco, neg_half, discard_ones, discard_zeros, body_ones, body_zeros};
				round_res_tmp = (rac_in[FINAL-1:0] + 1);
				round_res = round_res_tmp[FINAL:1];
			end 
		end
		else begin
			always_comb begin
				if(FINAL + SCALE == WIDTH)begin
						//discard
						if(rac_in[WIDTH-1] == 1)begin
							discard_ones = 1;
							discard_zeros = 0;
						end else begin
							discard_ones = 0;
							discard_zeros =1;
						end
				end else begin
					if(&rac_in[WIDTH-1:FINAL+SCALE] == 1)begin
						discard_ones = 1;
						discard_zeros = 0;
					end else begin
						if(|rac_in[WIDTH-1:FINAL+SCALE] == 0)begin
							discard_ones = 0;
							discard_zeros = 1;
						end else begin 
							discard_ones = 0;
							discard_zeros = 0;
						end
					end
				end
					//body
					if(&rac_in[FINAL+SCALE-2:SCALE] == 1)begin
						body_ones = 1;
						body_zeros = 0;
					end else begin
						if(|rac_in[FINAL+SCALE-2:SCALE] == 0)begin
							body_ones = 0;
							body_zeros = 1;
						end else begin
							body_ones = 0;
							body_zeros = 0;
						end
					end
				
				//neg_half
					if(rco == 1 && (|rac_in[SCALE-2:0] == 0) && rac_in[WIDTH-1])
						neg_half = 1'b1;
					else
						neg_half = 1'b0;
		
				//rco
				rco = rac_in[SCALE-1];
				rac_check = {rco, neg_half, discard_ones, discard_zeros, body_ones, body_zeros};
				round_res_tmp = (rac_in[FINAL+SCALE-1:SCALE-1] + 1);
				round_res = round_res_tmp[FINAL:1];
			end
		end
	endgenerate	
	
    always_comb begin
		unique casez(rac_check)
			//a
			6'b0?01??: begin
				sat = 0;
				rac_out = rac_in[FINAL+SCALE-1:SCALE];
			end
			//b
			6'b0?1001:begin
				sat = 1;
				rac_out = max_neg;
			end
			//c
			6'b0?10?0:begin
				sat = 0;
				rac_out = rac_in[FINAL+SCALE-1:SCALE];
			end
			//d
			6'b100110:begin
				sat = 1;
				rac_out = max_pos;
			end
			//e
			6'b10010?:begin
				sat = 0;
				rac_out = round_res;
			end
			//f
			6'b101010:begin
				sat = 0;
				rac_out = 0;
			end
			//g
			6'b10100?:begin
				sat = 0;
				rac_out = round_res;
			end
			//i
			6'b111001:begin
				sat = 1;
				rac_out = max_neg;
			end
			//j
			6'b1110?0:begin
				sat = 0;
				rac_out = rac_in[FINAL+SCALE-1:SCALE];
			end
			default:begin
				sat = 1;
				rac_out = (rac_in[WIDTH-1] == 1) ? max_neg:max_pos;
			end
		endcase
	end

endmodule
