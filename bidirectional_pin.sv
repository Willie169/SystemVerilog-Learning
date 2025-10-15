module bidir_pin(
    inout logic pin,
    input logic data_out,
    output logic data_in,
    input logic enable
);
    assign pin = enable ? data_out : 1'bz;
    assign data_in = pin;
endmodule

