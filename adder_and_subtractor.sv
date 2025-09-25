module full_adder (
    input logic a, b, cin,
    output logic sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module ripple_adder #(parameter N=4) (
    input logic [N-1:0] a, b,
    input logic cin,
    output logic [N-1:0] sum,
    output logic cout
);
    logic [N:0] carry;
    assign carry[0] = cin;
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : adder_loop
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    assign cout = carry[N];
endmodule

module unsigned_adder #(parameter N=4) (
    input logic [N-1:0] a, b,
    output logic [N-1:0] sum,
    output logic overflow
);
    ripple_adder #(.N(N)) ra (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(sum),
        .cout(overflow)
    );
endmodule

module ones_complement_adder #(parameter N=4) (
    input logic [N-1:0] a, b,
    output logic [N-1:0] sum
);
    logic [N-1:0] raw;
    logic carry;
    ripple_adder #(.N(N)) ra (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(raw),
        .cout(carry)
    );
    ripple_adder #(.N(N)) end_around (
        .a(raw),
        .b({{N-1{1'b0}}, carry}),
        .cin(1'b0),
        .sum(sum),
        .cout()
    );
endmodule

module twos_complement_adder #(parameter N=4) (
    input logic [N-1:0] a, b,
    output logic [N-1:0] sum
);
    ripple_adder #(.N(N)) ra (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(sum),
        .cout()
    );
endmodule

module full_subtractor (
    input logic a, b, bin,
    output logic diff, bout
);
    assign diff = a ^ b ^ bin;
    assign bout = (~a & b) | (~a & bin) | (b & bin);
endmodule

module ripple_subtractor #(parameter N=4) (
    input logic [N-1:0] a, b,
    input logic bin,
    output logic [N-1:0] diff,
    output logic bout
);
    logic [N:0] borrow;
    assign borrow[0] = bin;
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : subtractor_loop
            full_subtractor fs (
                .a(a[i]),
                .b(b[i]),
                .bin(borrow[i]),
                .diff(diff[i]),
                .bout(borrow[i+1])
            );
        end
    endgenerate
    assign bout = borrow[N];
endmodule

module unsigned_subtractor #(parameter N=4) (
    input logic [N-1:0] a, b,
    output logic [N-1:0] diff,
    output logic overflow
);
    ripple_subtractor #(.N(N)) rs (
        .a(a),
        .b(b),
        .bin(1'b0),
        .diff(diff),
        .bout(overflow)
    );
endmodule

module ones_complement_subtractor #(parameter N=4) (
    input logic [N-1:0] a, b,
    output logic [N-1:0] diff
);
    logic [N-1:0] b_comp;
    assign b_comp = ~b;  
    ones_complement_adder #(.N(N)) oca (
        .a(a),
        .b(b_comp),
        .sum(diff)
    );
endmodule

module ones_complement_adder_overflow #(parameter N=4) (
    input logic [N-1:0] a, b, sum,
    output logic overflow
);
    assign overflow = (a[N-1] & b[N-1] & ~sum[N-1]) | (~a[N-1] & ~b[N-1] & sum[N-1]);
endmodule

module ones_complementd_subtractor_overflow #(parameter N=4) (
    input logic [N-1:0] a, b, diff,
    output logic overflow
);
    assign overflow = (a[N-1] & ~b[N-1] & ~diff[N-1]) | (~a[N-1] & b[N-1] & diff[N-1]);
endmodule

module twos_complement_subtractor #(parameter N=4) (
    input logic [N-1:0] a, b,
    output logic [N-1:0] diff
);
    logic [N-1:0] b_comp;
    assign b_comp = ~b + 1'b1;    
    twos_complement_adder #(.N(N)) tca (
        .a(a),
        .b(b_comp),
        .sum(diff)
    );
endmodule

module twos_complement_adder_overflow #(parameter N=4) (
    input logic [N-1:0] a, b, sum,
    output logic overflow
);
    assign overflow = (a[N-1] & b[N-1] & ~sum[N-1]) | (~a[N-1] & ~b[N-1] & sum[N-1]);
endmodule

module twos_complementd_subtractor_overflow #(parameter N=4) (
    input logic [N-1:0] a, b, diff,
    output logic overflow
);
    assign overflow = (a[N-1] & ~b[N-1] & ~diff[N-1]) | (~a[N-1] & b[N-1] & diff[N-1]);
end module
