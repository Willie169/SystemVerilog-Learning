// tb_carry_save_adder.sv
`timescale 1ns/1ps
`include "carry_save_adder.sv"

module tb_carry_save_adder;
    parameter int N = 5;
    parameter int WIDTH = 8;
    parameter int NUM_TESTS = 100;

    logic [N-1:0][WIDTH-1:0] operands;
    logic [WIDTH + $clog2(N)-1:0] sum;
    logic [WIDTH + $clog2(N)-1:0] expected_sum;

    carry_save_adder #(
        .N(N),
        .WIDTH(WIDTH)
    ) dut (
        .operands(operands),
        .sum(sum)
    );

    task automatic check_results();
        expected_sum = 0;
        for (int i = 0; i < N; i++)
            expected_sum += operands[i];
        assert(sum == expected_sum) else begin
            $fatal(1, "Mismatch! operands=%p sum=%0d expected_sum=%0d", operands, sum, expected_sum);
        end
    endtask

    initial begin
        $display("=== Randomized Testbench for Multi-Operand CSA ===");
        for (int t = 0; t < NUM_TESTS; t++) begin
            for (int i = 0; i < N; i++)
                operands[i] = $urandom_range(0, 2**WIDTH-1);            
            #1;
            check_results();
            $display("Test %0d/%0d passed: operands=%p sum=%0d", t+1, NUM_TESTS, operands, sum);
        end
        $display("=== All %0d Random Tests Passed ===", NUM_TESTS);
        $finish;
    end

endmodule
