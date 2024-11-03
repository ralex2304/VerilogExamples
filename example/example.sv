`timescale 1ns/1ps

module example;

bit clk;

initial $dumpfile("dump.svc");

always begin
    $dumpvars;
    #5
    $dumpvars;
    clk <= ~clk;
end

logic a = 1'b0;

integer cnt = 0;

always @(posedge clk)
    cnt <= cnt + 1;

always @(posedge clk) begin
    if (cnt >= 100)
        $finish;
end

initial begin
    #5
    a = 1'b1;
    #5
    a = 1'b0;

    $display("Hello World %b", a);
end

endmodule
