`timescale 1ns/1ps
`include "adder_and_substractor.sv"
module tb_adder_and_substractor;
    import adder_and_substractor::*;
    localparam N = 4;
    logic [N-1:0] a, b;
    logic [N-1:0] sum_unsigned, sum_ones, sum_twos;
    logic overflow_unsigned, overflow_signed;
    logic [N-1:0] diff_unsigned, diff_ones, diff_twos;
    logic overflow_unsigned_sub, overflow_signed_sub;

    unsigned_adder #(.N(N)) uadd (
        .augend(a), .addend(b),
        .sum(sum_unsigned), .overflow(overflow_unsigned)
    );
    
    ones_complement_adder #(.N(N)) oadd (
        .augend(a), .addend(b),
        .sum(sum_ones)
    );

    twos_complement_adder #(.N(N)) tadd (
        .augend(a), .addend(b),
        .sum(sum_twos)
    );

    signed_adder_overflow_detector #(.N(N)) sad (
        .augend(a), .addend(b), .sum(sum_twos),
        .overflow(overflow_signed)
    );

    unsigned_subtractor #(.N(N)) usub (
        .minuend(a), .subtrahend(b),
        .difference(diff_unsigned), .overflow(overflow_unsigned_sub)
    );

    ones_complement_subtractor #(.N(N)) osub (
        .minuend(a), .subtrahend(b),
        .difference(diff_ones)
    );

    twos_complement_subtractor #(.N(N)) tsub (
        .minuend(a), .subtrahend(b),
        .difference(diff_twos)
    );

    signed_subtractor_overflow_detector #(.N(N)) ssub (
        .minuend(a), .subtrahend(b), .difference(diff_twos),
        .overflow(overflow_signed_sub)
    );

    initial begin
        $display("=== Adder and Subtractor Testbench ===");

        typedef struct {logic [N-1:0] a, b;} test_vec_t;
        test_vec_t test_vectors [5];

        test_vectors[0] = '{4'd3, 4'd2};
        test_vectors[1] = '{4'd7, 4'd8};
        test_vectors[2] = '{4'd15, 4'd1};
        test_vectors[3] = '{4'd0, 4'd0};
        test_vectors[4] = '{4'd9, 4'd5};

        for (int i = 0; i < test_vectors.size(); i++) begin
            a = test_vectors[i].a;
            b = test_vectors[i].b;
            #1;

            $display("\nTest %0d: a=%0d, b=%0d", i, a, b);
            $display("Unsigned Adder: sum=%0d, overflow=%0b", sum_unsigned, overflow_unsigned);
            $display("Ones Complement Adder: sum=%0d", sum_ones);
            $display("Twos Complement Adder: sum=%0d, signed overflow=%0b", sum_twos, overflow_signed);

            $display("Unsigned Subtractor: diff=%0d, overflow=%0b", diff_unsigned, overflow_unsigned_sub);
            $display("Ones Complement Subtractor: diff=%0d", diff_ones);
            $display("Twos Complement Subtractor: diff=%0d, signed overflow=%0b", diff_twos, overflow_signed_sub);
        end

        $display("\n=== Testbench Completed ===");
        $finish;
    end
endmodule
