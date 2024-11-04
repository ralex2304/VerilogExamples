`timescale 1ns/1ps

module fifo_tb;

logic             clk;
logic             rst_n = 1'b1;
logic             rdy   = 1'b0;

initial $dumpfile("dump.svc");

always begin
    $dumpvars;
    #5
    $dumpvars;
    clk <= ~clk;
end

initial begin
    #5
    rst_n = 1'b0;
    #5
    rst_n = 1'b1;
    rdy   = 1'b1;
end

localparam WIDTH = 32;
localparam DEPTH = 64;

logic             i_wr_vld;
logic [WIDTH-1:0] i_wr_data;

logic             i_rd_en;
logic [WIDTH-1:0] o_rd_data;

logic             o_empty;
logic             o_full;

fifo #(
    .WIDTH      (WIDTH),
    .DEPTH      (DEPTH)
) fifo_inst (
    .clk        (clk),
    .rst_n      (rst_n),

    .i_wr_vld   (i_wr_vld),
    .i_wr_data  (i_wr_data),

    .i_rd_en    (i_rd_en),
    .o_rd_data  (o_rd_data),

    .o_full     (o_full),
    .o_empty    (o_empty)
);

logic rd_rand;
logic wr_rand;

logic [WIDTH-1:0] wr_data;

always @(posedge clk) begin
    rd_rand <= 1'($urandom_range(0, 1));
    wr_rand <= 1'($urandom_range(0, 1));
    for (integer i = 0; i < WIDTH; i++)
        wr_data[i] <= 1'($urandom_range(0, 1));
end

logic [WIDTH-1:0] queue[$];

assign i_wr_vld  = wr_rand;
assign i_wr_data = wr_data;

assign i_rd_en   = rd_rand;

always @(posedge clk) begin
    if (rdy && i_wr_vld && (!o_full || (i_rd_en && !o_empty))) begin
        queue.push_front(wr_data);
    end
end

always @(posedge clk) begin
    if (rdy && i_rd_en && !o_empty) begin
        if (queue[$] !== o_rd_data) begin
            $error("[FAIL] o_rd_data=%h, expected %h", o_rd_data, queue[$]);
        end
        queue.pop_back();
    end
end

always @(posedge clk) begin
    if (rdy) begin
        if ((queue.size() == 0) !== o_empty) begin
            $error("[FAIL] queue.size()=%d, o_empty=%b", queue.size(), o_empty);
        end

        if ((queue.size() == DEPTH) !== o_full) begin
            $error("[FAIL] queue.size()=%d, o_full=%b", queue.size(), o_full);
        end
    end
end

initial begin
    #1000000
    $display("[PASS]");
    $finish;
end

endmodule
