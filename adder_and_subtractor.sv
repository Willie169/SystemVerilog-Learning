module full_adder (
    input logic augend, addend, carry_in,
    output logic sum, carry_out
);
    assign sum = augend ^ addend ^ carry_in;
    assign carry_out = (augend & addend) | (addend & carry_in) | (augend & carry_in);
endmodule

module ripple_adder #(parameter N=4) (
    input logic [N-1:0] augend, addend,
    input logic carry_in,
    output logic [N-1:0] sum,
    output logic carry_out
);
    logic [N:0] carry;
    assign carry[0] = carry_in;
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : adder_loop
            full_adder fa (
                .augend(augend[i]),
                .addend(addend[i]),
                .carry_in(carry[i]),
                .sum(sum[i]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate
    assign carry_out = carry[N];
endmodule

module unsigned_adder #(parameter N=4) (
    input logic [N-1:0] augend, addend,
    output logic [N-1:0] sum,
    output logic overflow
);
    ripple_adder #(.N(N)) ra (
        .augend(augend),
        .addend(addend),
        .carry_in(1'b0),
        .sum(sum),
        .carry_out(overflow)
    );
endmodule

module ones_complement_adder #(parameter N=4) (
    input logic [N-1:0] augend, addend,
    output logic [N-1:0] sum
);
    logic [N-1:0] raw;
    logic carry;
    ripple_adder #(.N(N)) ra (
        .augend(augend),
        .addend(addend),
        .carry_in(1'b0),
        .sum(raw),
        .carry_out(carry)
    );
    ripple_adder #(.N(N)) end_around (
        .augend(raw),
        .addend({{N-1{1'b0}}, carry}),
        .carry_in(1'b0),
        .sum(sum),
        .carry_out()
    );
endmodule

module twos_complement_adder #(parameter N=4) (
    input logic [N-1:0] augend, addend,
    output logic [N-1:0] sum
);
    ripple_adder #(.N(N)) ra (
        .augend(augend),
        .addend(addend),
        .carry_in(1'b0),
        .sum(sum),
        .carry_out()
    );
endmodule

module signed_adder_overflow_detector #(parameter N=4) (
    input logic [N-1:0] augend, addend, sum,
    output logic overflow
);
    assign overflow = (augend[N-1] & addend[N-1] & ~sum[N-1]) | (~augend[N-1] & ~addend[N-1] & sum[N-1]);
endmodule

module full_subtractor (
    input logic minuend, subtrahend, borrow_in,
    output logic difference, borrow_out
);
    assign difference = minuend ^ subtrahend ^ borrow_in;
    assign borrow_out = (~minuend & subtrahend) | (~minuend & borrow_in) | (subtrahend & borrow_in);
endmodule

module ripple_subtractor #(parameter N=4) (
    input logic [N-1:0] minuend, subtrahend,
    input logic borrow_in,
    output logic [N-1:0] difference,
    output logic borrow_out
);
    logic [N:0] borrow;
    assign borrow[0] = borrow_in;
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : subtractor_loop
            full_subtractor fs (
                .minuend(minuend[i]),
                .subtrahend(subtrahend[i]),
                .borrow_in(borrow[i]),
                .difference(difference[i]),
                .borrow_out(borrow[i+1])
            );
        end
    endgenerate
    assign borrow_out = borrow[N];
endmodule

module unsigned_subtractor #(parameter N=4) (
    input logic [N-1:0] minuend, subtrahend,
    output logic [N-1:0] difference,
    output logic overflow
);
    ripple_subtractor #(.N(N)) rs (
        .minuend(minuend),
        .subtrahend(subtrahend),
        .borrow_in(1'b0),
        .difference(difference),
        .borrow_out(overflow)
    );
endmodule

module ones_complement_subtractor #(parameter N=4) (
    input logic [N-1:0] minuend, subtrahend,
    output logic [N-1:0] difference
);
    logic [N-1:0] complement;
    assign complement = ~subtrahend;  
    ones_complement_adder #(.N(N)) oca (
        .augend(minuend),
        .addend(complement),
        .sum(difference)
    );
endmodule

module twos_complement_subtractor #(parameter N=4) (
    input logic [N-1:0] minuend, subtrahend,
    output logic [N-1:0] difference
);
    logic [N-1:0] complement;
    assign complement = ~subtrahend + 1'b1;    
    twos_complement_adder #(.N(N)) tca (
        .augend(minuend),
        .addend(complement),
        .sum(difference)
    );
endmodule

module signed_subtractor_overflow_detector #(parameter N=4) (
    input logic [N-1:0] minuend, subtrahend, difference,
    output logic overflow
);
    assign overflow = (minuend[N-1] & ~subtrahend[N-1] & ~difference[N-1]) | (~minuend[N-1] & subtrahend[N-1] & difference[N-1]);
endmodule
