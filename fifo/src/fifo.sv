`timescale 1ns/1ps

module fifo #(
    parameter WIDTH = 32,
    parameter DEPTH = 64
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic             i_wr_vld,
    input  logic [WIDTH-1:0] i_wr_data,

    input  logic             i_rd_en,
    output logic [WIDTH-1:0] o_rd_data,

    output logic             o_full,
    output logic             o_empty
);

logic [WIDTH-1:0] data[DEPTH-1:0];

logic [$clog2(DEPTH)-1:0] head, next_head;
logic [$clog2(DEPTH)-1:0] tail, next_tail;

logic rd_fire, wr_fire;

assign rd_fire = i_rd_en && !o_empty;
assign wr_fire = i_wr_vld && (!o_full || (i_rd_en && !o_empty));

assign next_head = $clog2(DEPTH)'((head + 1'b1) % ($clog2(DEPTH) + 1)'(DEPTH));
assign next_tail = $clog2(DEPTH)'((tail + 1'b1) % ($clog2(DEPTH) + 1)'(DEPTH));

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        head       <= 'b0;
    end else if (wr_fire) begin
        data[head] <= i_wr_data;
        head       <= next_head;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        tail <= 'b0;
    end else if (rd_fire) begin
        tail <= next_tail;
    end
end

assign o_rd_data = data[tail];

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        o_full  <= 1'b0;
        o_empty <= 1'b1;
    end else if (rd_fire && wr_fire) begin
        o_full  <= o_full;
        o_empty <= 1'b0;
    end else if (rd_fire) begin
        o_full  <= 1'b0;
        o_empty <= (next_tail == head);
    end else if (wr_fire) begin
        o_full  <= (next_head == tail);
        o_empty <= 1'b0;
    end
end

endmodule
