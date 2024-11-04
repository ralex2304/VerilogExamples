`timescale 1ns/1ps

module fifo_assertions #(
    parameter WIDTH = 32
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic             i_wr_vld,
    input  logic [WIDTH-1:0] i_wr_data,

    input  logic             i_rd_en,
    input  logic [WIDTH-1:0] o_rd_data,

    input  logic             o_full,
    input  logic             o_empty
);

logic rdy = 1'b0;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        rdy <= 1'b1;
end

`define ASSERT(NAME, EXPR)      \
    ERROR_``NAME``_INVLD: assert property ( \
        @(posedge clk) disable iff (!rdy || !rst_n) \
        EXPR        \
    ) else $finish

    `ASSERT(I_WR_VLD,  !$isunknown(i_wr_vld));

    `ASSERT(I_WR_DATA, i_wr_vld |-> !$isunknown(i_wr_data));

    `ASSERT(I_RD_EN,   !$isunknown(i_rd_en));

    `ASSERT(O_RD_DATA, i_rd_en |-> !$isunknown(o_rd_data));

    `ASSERT(O_FULL,    !$isunknown(o_full));

    `ASSERT(O_EMPTY,   !$isunknown(o_empty));

endmodule
