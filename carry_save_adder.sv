// carry_save_adder.sv

module carry_save_adder #(
    parameter int N = 4,
    parameter int WIDTH = 8
)(
    input logic [N-1:0][WIDTH-1:0] operands,
    output logic [WIDTH + $clog2(N)-1:0] sum
);
    localparam int OUTW = WIDTH + $clog2(N);
    logic [OUTW-1:0] intermediate [0:N-1];
    int remaining;
    int new_remaining;
    always_comb begin
        for (int i = 0; i < N; i++)
            intermediate[i] = {{(OUTW-WIDTH){1'b0}}, operands[i]};
        remaining = N;
        for (int step = 0; step < N; step++) begin
            if (remaining > 2) break;
            new_remaining = 0;
            for (int i = 0; i < remaining; i += 3) begin
                if (i+2 < remaining) begin
                    logic [OUTW-1:0] s, c;
                    for (int j = 0; j < OUTW; j++) begin
                        s[j] = intermediate[i][j] ^ intermediate[i+1][j] ^ intermediate[i+2][j];
                        c[j] = (intermediate[i][j]&intermediate[i+1][j]) | (intermediate[i+1][j]&intermediate[i+2][j]) | (intermediate[i+2][j]&intermediate[i][j]);
                    end
                    intermediate[new_remaining] = s;
                    intermediate[new_remaining+1] = c << 1;
                    new_remaining += 2;
                end else begin
                    intermediate[new_remaining] = intermediate[i];
                    new_remaining += 1;
                end
            end
            remaining = new_remaining;
        end
        if (remaining == 2)
            sum = intermediate[0] + intermediate[1];
        else
            sum = intermediate[0];
    end
endmodule
