module dispatch_staller (
    input clk,
    input rst,
    /*FSM inputs*/
    input branch,
    input jalr,
    input branch_solved,
    input jalr_solved,
    input ifq_empty,
    output reg branch_add_reg_en,
    output reg nstall
);

typedef enum logic [1:0] {NORMAL_OP, STALLINNG_FOR_BRANCH, STALLING_FOR_JALR/*, STALLING_FOR_IFQ_NOT_EMPTY*/} fsm_state;

fsm_state state;

always_comb begin : stall_logic
    if(ifq_empty)
        nstall = 1'b0;
    else if (state == NORMAL_OP)
        nstall = 1'b1;
    else
        nstall = 1'b0;
end

always_comb begin : branch_reg_en
    if (state == STALLINNG_FOR_BRANCH)
        branch_add_reg_en = 1'b0;
    else
        branch_add_reg_en = 1'b1;
end


always_ff @( posedge clk, posedge rst ) begin : sequential
    if(rst)  begin
        /*
        if(ifq_empty)
            state <= STALLING_FOR_IFQ_NOT_EMPTY;
        else
        */
            state <= NORMAL_OP;
    end else begin
        case (state)
            NORMAL_OP: 
                if(branch)
                    state <= STALLINNG_FOR_BRANCH;
                else if(jalr)
                    state <= STALLING_FOR_JALR;
/*                
                else if(ifq_empty)
                    state <= STALLING_FOR_IFQ_NOT_EMPTY;
*/
                else
                    state <= NORMAL_OP;
            STALLINNG_FOR_BRANCH:
                if(branch_solved)
                    state <= NORMAL_OP;
                else
                    state <= STALLINNG_FOR_BRANCH;
            STALLING_FOR_JALR:
                if(jalr_solved)
                    state <= NORMAL_OP;
                else
                    state <= STALLING_FOR_JALR;
/*
            STALLING_FOR_IFQ_NOT_EMPTY:
                if(ifq_empty)
                    state <= STALLING_FOR_IFQ_NOT_EMPTY;
                else
                    state <= NORMAL_OP;
*/
            default: state <= NORMAL_OP;
        endcase
    end   
end

endmodule