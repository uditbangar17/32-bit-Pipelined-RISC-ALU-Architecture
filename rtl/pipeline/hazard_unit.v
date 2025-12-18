module hazard_unit(
    input  wire [4:0] id_rs,
    input  wire [4:0] id_rt,
    input  wire       id_ex_MemRead,
    input  wire [4:0] id_ex_rt,
    output wire       stall
);
    assign stall = id_ex_MemRead && ((id_ex_rt == id_rs) || (id_ex_rt == id_rt)) && (id_ex_rt != 0);
endmodule