`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2020 10:35:25 AM
// Design Name: 
// Module Name: interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

interface AXIS #(parameter DATA_WIDTH = 16);
	logic tlast;
	logic [DATA_WIDTH-1:0] tdata;
	logic tvalid;
	logic tready;
	
	modport slave(input tlast, input tdata, input tvalid, output tready);
	modport master(output tlast, output tdata, output tvalid, input tready);
	
endinterface : AXIS