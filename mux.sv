module mux #(parameter N = 2)(
    input logic [2**N-1:0] D,
    input logic [N-1:0] S,
    output logic Y
);
    always_comb begin
        Y = D[S];
    end
endmodule

