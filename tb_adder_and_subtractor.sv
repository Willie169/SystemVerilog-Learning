// tb_adder_and_subtractor.sv

`timescale 1ns/1ps
`include "adder_and_subtractor.sv"

module tb_adder_and_subtractor;
    localparam N = 4;
    localparam NUM_TESTS = 100;

    logic [N-1:0] a, b;
    logic [N-1:0] sum_unsigned, sum_ones, sum_twos;
    logic overflow_unsigned_add, overflow_signed_add;
    logic [N-1:0] diff_unsigned, diff_ones, diff_twos;
    logic overflow_unsigned_sub, overflow_signed_sub;

    unsigned_adder #(.N(N)) uadd (.augend(a), .addend(b), .sum(sum_unsigned), .overflow(overflow_unsigned_add));
    ones_complement_adder #(.N(N)) oadd (.augend(a), .addend(b), .sum(sum_ones));
    twos_complement_adder #(.N(N)) tadd (.augend(a), .addend(b), .sum(sum_twos));
    signed_adder_overflow_detector #(.N(N)) sad (.augend(a), .addend(b), .sum(sum_twos), .overflow(overflow_signed_add));
    unsigned_subtractor #(.N(N)) usub (.minuend(a), .subtrahend(b), .difference(diff_unsigned), .overflow(overflow_unsigned_sub));
    ones_complement_subtractor #(.N(N)) osub (.minuend(a), .subtrahend(b), .difference(diff_ones));
    twos_complement_subtractor #(.N(N)) tsub (.minuend(a), .subtrahend(b), .difference(diff_twos));
    signed_subtractor_overflow_detector #(.N(N)) ssub (.minuend(a), .subtrahend(b), .difference(diff_twos), .overflow(overflow_signed_sub));

    task automatic check_results(logic [N-1:0] a, b);
        logic [N:0] expected_unsigned_sum;
        logic [N-1:0] expected_ones_sum;
        logic signed [N-1:0] a_signed, b_signed;
        logic signed [N-1:0] expected_twos_sum;
        logic expected_signed_overflow;
        logic [N:0] expected_unsigned_diff;
        logic [N-1:0] expected_ones_diff;
        logic signed [N-1:0] expected_twos_diff;
        logic expected_signed_sub_overflow;

        begin
            expected_unsigned_sum = a + b;
            expected_ones_sum  = expected_unsigned_sum[N-1:0] + expected_unsigned_sum[N];
            a_signed = a;
            b_signed = b;
            expected_twos_sum = a_signed + b_signed;
            expected_signed_overflow = ((a_signed[N-1] & b_signed[N-1] & ~expected_twos_sum[N-1]) |
                                        (~a_signed[N-1] & ~b_signed[N-1] & expected_twos_sum[N-1]));
            expected_unsigned_diff = a - b;
            expected_ones_diff = expected_unsigned_diff[N-1:0] - expected_unsigned_diff[N];
            expected_twos_diff = a_signed - b_signed;
            expected_signed_sub_overflow = ((a_signed[N-1] & ~b_signed[N-1] & ~expected_twos_diff[N-1]) |
                                            (~a_signed[N-1] & b_signed[N-1] & expected_twos_diff[N-1]));

            assert (sum_unsigned == expected_unsigned_sum[N-1:0]) else $fatal(1,"Unsigned adder failed: a=%0d b=%0d", a, b);
            assert (sum_ones == expected_ones_sum) else $fatal(1,"Ones complement adder failed: a=%0d b=%0d", a, b);
            assert (sum_twos == expected_twos_sum) else $fatal(1,"Twos complement adder failed: a=%0d b=%0d", a, b);
            assert (overflow_signed_add == expected_signed_overflow) else $fatal(1,"Signed adder overflow incorrect: a=%0d b=%0d", a, b);
            assert (diff_unsigned == expected_unsigned_diff[N-1:0]) else $fatal(1,"Unsigned subtractor failed: a=%0d b=%0d", a, b);
            assert (diff_ones == expected_ones_diff) else $fatal(1,"Ones complement subtractor failed: a=%0d b=%0d", a, b);
            assert (diff_twos == expected_twos_diff) else $fatal(1,"Twos complement subtractor failed: a=%0d b=%0d", a, b);
            assert (overflow_signed_sub == expected_signed_sub_overflow) else $fatal(1,"Signed subtractor overflow incorrect: a=%0d b=%0d", a, b);
        end
    endtask

    initial begin
        $display("=== Randomized Self-Checking Testbench ===");
        for (int i = 0; i < NUM_TESTS; i++) begin
            a = $urandom_range(0, 2**N-1);
            b = $urandom_range(0, 2**N-1);
            #1;
            check_results(a, b);
        end
        $display("=== All %0d Random Tests Passed ===", NUM_TESTS);
        $finish;
    end

endmodule
