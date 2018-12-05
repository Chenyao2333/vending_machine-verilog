module show(clk, D, dig_sel, dig, point);
	input clk;
	input [15:0] D;
	output point;
	output [3:0] dig_sel;
	output [6:0] dig;
	reg point;
	reg [3:0] dig_sel;
	reg [6:0] dig;
	
	reg [3:0] now;
	reg [1:0] count;
	reg [15:0] count_1;
	
	always @ (posedge clk) begin
		count_1 = count_1 + 1;
		if (count_1 == 0) begin
			count = count + 1;
		end

		case (count)
			2'b00: begin
				dig_sel <= 4'b0001;
				now = D % 10;
				point <= 0;
			end
			2'b01: begin
				dig_sel <= 4'b0010;
				now = D / 10 % 10;
				point <= 1;
			end
			2'b10: begin
				dig_sel <= 4'b0100;
				now = D / 100 % 10;
				point <= 0;
			end
			2'b11: begin
				dig_sel <= 4'b1000;
				now = D / 1000 % 10;
				point <= 0;
			end
		endcase

		case(now)
			0: dig <= 7'b1111110;
			1: dig <= 7'b0110000;
			2: dig <= 7'b1101101;
			3: dig <= 7'b1111001;
			4: dig <= 7'b0110011;
			5: dig <= 7'b1011011;
			6: dig <= 7'b1011111;
			7: dig <= 7'b1110000;
			8: dig <= 7'b1111111;
			9: dig <= 7'b1111011;
			default:	dig <= 0;
		endcase
	end
endmodule


module key_press(clk, in, out);
	input clk, in;
	output out;
	
	reg out, pressed;
	always @ (posedge clk) begin
		if (in) begin
			if (pressed) begin
				out = 0;
			end else begin
				pressed = 1;
				out = 1;
			end
		end else begin
			pressed = 0;
			out = 0;
		end
	end
endmodule

module vending_machine(clk, coin_5, coin_10, coin_50, item_15, item_25, cash_back, dig_sel, dig, point, debug1, debug2);
	input clk;
	input coin_5, coin_10, coin_50, item_15, item_25, cash_back;
	
	output point, debug1, debug2;
	output [3:0] dig_sel;
	output [6:0] dig;
	
	reg [15:0] cash;
	
	wire c5, c10, c50, i15, i25, cb;
	key_press k5(clk, coin_5, c5);
	key_press k10(clk, coin_10, c10);
	key_press k50(clk, coin_50, c50);
	key_press ki15(clk, item_15, i15);
	key_press ki25(clk, item_25, i25);
	key_press kcb(clk, cash_back, cb);
	
	reg debug1, debug2;
	always @ (posedge clk) begin
		if (c5) begin
			cash = cash + 5;
			debug1 = 0;
			debug2 = 0;
		end
		if (c10) begin
			cash = cash + 10;
			debug1 = 0;
			debug2 = 0;
		end
		if (c50) begin
			cash = cash + 50;
			debug1 = 0;
			debug2 = 0;
		end
		if (i15) begin
			if (cash >= 15) begin
				cash = cash - 15;
				debug1 = 0;
			end else begin
				debug1 = 1;
			end
			debug2 = 0;
		end
		if (i25) begin
			if (cash >= 25) begin
				cash = cash - 25;
				debug1 = 0;
			end else begin
				debug1 = 1;
			end
			debug2 = 0;
		end
		if (cb) begin
			cash = 0;
			debug1 = 0;
			debug2 = 1;
		end
	end

	show s(clk, cash, dig_sel, dig, point);
endmodule