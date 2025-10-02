package carry_save_adder;

module carry_save_adder #(parameter int WIDTH = 8)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [WIDTH-1:0] C,
    output logic [WIDTH-1:0] Sum,
    output logic [WIDTH-1:0] Carry
);
    always_comb begin
        for (int i = 0; i < WIDTH; i++) begin
            Sum[i] = A[i] ^ B[i] ^ C[i];
            Carry[i] = (A[i]&B[i]) | (B[i]&C[i]) | (C[i]&A[i]);
        end
    end
endmodule

module multi_operand_carry_save_adder #(
    parameter int N = 4,
    parameter int WIDTH = 8
)(
    input logic [N-1:0][WIDTH-1:0] operands,
    output logic [WIDTH + $clog2(N)-1:0] sum
);
    localparam int OUTW = WIDTH + $clog2(N);
    logic [OUTW-1:0] stage [0:2*N-2];
    int stage_count;
    always_comb begin
        for (int i = 0; i < N; i++)
            stage[i] = operands[i];
        stage_count = N;
        int idx = 0;
        while (stage_count > 2) begin
            int new_count = 0;
            for (int i = 0; i < stage_count; i += 3) begin
                if (i+2 < stage_count) begin
                    logic [OUTW-1:0] S, C;
                    carry_save_adder #(.WIDTH(OUTW)) csa (
                        .A(stage[i]),
                        .B(stage[i+1]),
                        .C(stage[i+2]),
                        .Sum(S),
                        .Carry(C)
                    );
                    stage[new_count] = S;
                    stage[new_count+1] = C << 1;
                    new_count += 2;
                end else begin
                    stage[new_count] = stage[i];
                    new_count += 1;
                end
            end
            stage_count = new_count;
        end
        if (stage_count == 2)
            sum = stage[0] + stage[1];
        else
            sum = stage[0];
    end
endmodule

endpackage
