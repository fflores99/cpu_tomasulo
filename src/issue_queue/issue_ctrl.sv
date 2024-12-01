module issue_ctrl #(parameter DEPTH = 4) (
    /*Status of registers*/
    /*Reg inputs*/
    input [5:0] op1_tag[DEPTH], /*op1 tag from each register*/
    input op1_data_valid[DEPTH], /*op1 data valid from each register*/
    input [5:0] op2_tag[DEPTH], /*op2 tag from each register*/
    input op2_data_valid[DEPTH], /*op2 data valid from each register*/
    input valid[DEPTH], /*RD valid from each register used to track if instruction in register is a valid instruction*/
    input ready[DEPTH],
    input entry_valid[DEPTH],
    /*interface inputs*/
    input queue_en, /*queue enebale from dispatch*/
    input ex_done, /*Excecute done from Excecution Unit*/
    /*CDB inputs*/
    input [5:0] cdb_tag, /*Published CDB tag*/
    input cdb_data_valid, /*Published CDB data valid*/
    /*Update muxes control*/
    output reg op1_updt_en[DEPTH],
    output reg op1_updt_from_cdb[DEPTH],
    output reg op2_updt_en[DEPTH],
    output reg op2_updt_from_cdb[DEPTH],
    output reg updt_cmn[DEPTH],
    /*Register control*/
    output reg reg_we[DEPTH], /*Enable for registers*/
    output reg flush[DEPTH],
    /*Output control*/
    output reg [1:0] output_selector, /*Selector for output mux, also used to track which register is being output*/
    /*Back pressure*/
    output reg queue_full, /*Queue full indicator*/
    /*Issue controller*/
    output reg issue_valid /*Issue valid bit to indicate excecution unit that data output is valid*/
);

/*Used to track the state of each register*/
typedef enum reg[1:0] {REG_EMPTY, REG_WAITING, REG_READY} rstatus;
rstatus REG_STATUS[DEPTH];

/*Used to track register operations*/
reg reg_shift[DEPTH], reg_updt_op1[DEPTH], reg_updt_op2[DEPTH];

/*Checks the status of each register*/
always_comb begin : status_decoder
    integer i;
    for (i = 0; i < DEPTH; i++) begin
        if(entry_valid[i]) begin
            /*Register is not empty*/
            if(ready[i]) begin
                /*Register is ready to be issued*/
                REG_STATUS[i] = REG_READY;
            end else begin
                /*Register is waiting for a cdb entry*/
                REG_STATUS[i] = REG_WAITING;
            end
        end else begin
            /*Register is empty*/
            REG_STATUS[i] = REG_EMPTY;
        end
    end
end

/*Checks if fifo is full*/
always_comb begin : full_control
    if((REG_STATUS[0] != REG_EMPTY) && (REG_STATUS[1] != REG_EMPTY) && (REG_STATUS[2] != REG_EMPTY) && (REG_STATUS[3] != REG_EMPTY))
        queue_full = 1'b1;
    else
        queue_full = 1'b0;
end

/*Output control*/
always_comb begin : output_controller
    /*Decides which register to issue with priority to the oldest*/
    if(REG_STATUS[3] == REG_READY) begin
        issue_valid = 1'b1;
        output_selector = 2'b11;
    end else if(REG_STATUS[2] == REG_READY) begin
        issue_valid = 1'b1;
        output_selector = 2'b10;
    end else if(REG_STATUS[1] == REG_READY) begin
        issue_valid = 1'b1;
        output_selector = 2'b01; 
    end else if(REG_STATUS[0] == REG_READY) begin
        issue_valid = 1'b1;
        output_selector = 2'b00;
    end else begin
        issue_valid = 1'b0;
        output_selector = 2'b00;
    end
end

/* In this context, shift means request the data from upper register (in case of reg 0 is from dispatch unit)*/
always_comb begin : shift_ctrl
    /*Every register will be shifted if lower register is empty, is being output, or is being shifted as well*/
    /*If a register is empty it will shift, even if upper data is also an empty value*/
    /*Register 3 will be updated if it is being output and excecution unit has finished process its data or if it is empty*/
    if(((output_selector == 2'b11) && (issue_valid == 1'b1) && (ex_done == 1'b1))  || (REG_STATUS[3] == REG_EMPTY))
        reg_shift[3] = 1'b1;
    else 
        reg_shift[3] = 1'b0;
    /*Registers 2, 1 and 0 will be updated if it is being output and excecution unit has finished process its data or if it is empty or if next register is being shifted*/
    if(((output_selector == 2'b10) && (issue_valid == 1'b1) && (ex_done == 1'b1)) || (reg_shift[3] == 1'b1) || (REG_STATUS[2] == REG_EMPTY))
        reg_shift[2] = 1'b1;
    else 
        reg_shift[2] = 1'b0;

    if(((output_selector == 2'b01) && (issue_valid == 1'b1) && (ex_done == 1'b1)) || (reg_shift[2] == 1'b1) || (REG_STATUS[1] == REG_EMPTY) )
        reg_shift[1] = 1'b1;
    else 
        reg_shift[1] = 1'b0;

    if(((output_selector == 2'b00) && (issue_valid == 1'b1) && (ex_done == 1'b1)) || (reg_shift[1] == 1'b1) || (REG_STATUS[0] == REG_EMPTY))
        reg_shift[0] = 1'b1;
    else 
        reg_shift[0] = 1'b0;
end

/*Shift and update control*/
always_comb begin : updt_ctrl
    /*A register is updated if CDB publishes its dependency*/
    integer i;
    for (i = 0; i < DEPTH; i += 1) begin
        if(cdb_data_valid == 1'b1 && cdb_tag == op1_tag[i] && op1_data_valid[i] == 1'b0 && entry_valid[i] == 1'b1)
            reg_updt_op1[i] = 1'b1;
        else
            reg_updt_op1[i] = 1'b0;
        
        if(cdb_data_valid == 1'b1 && cdb_tag == op2_tag[i] && op2_data_valid[i] == 1'b0 && entry_valid[i] == 1'b1)
            reg_updt_op2[i] = 1'b1;
        else
            reg_updt_op2[i] = 1'b0;
    end
end

always_comb begin : update_selector
    integer i;
    for (i = 0; i < DEPTH; i += 1) begin
        if(reg_shift[i] == 1'b1) begin
            if(i == 0) begin
                if(queue_en == 1'b0)  begin
                    /*Register 0 is sending is requesting new data, but queeue is not eneabled*/
                    reg_we[i] = 1'b0;
                    updt_cmn[i] = 1'b0;
                    op1_updt_en[i] = 1'b0;
                    op2_updt_en[i] = 1'b0;
                    op1_updt_from_cdb[i] = 1'b0;
                    op2_updt_from_cdb[i] = 1'b0; 
                    flush[i] = 1'b1;
                end else begin
                    flush[i] = 1'b0;
                    reg_we[i] = 1'b1;
                    updt_cmn[i] = 1'b1;
                    op1_updt_en[i] = 1'b1;
                    op2_updt_en[i] = 1'b1;
                    op1_updt_from_cdb[i] = 1'b0;
                    op2_updt_from_cdb[i] = 1'b0; 
                end
            end else begin
                /*Registers other than 0*/
                if ((output_selector == (i[1:0] - 1)) && (issue_valid == 1'b1) && (ex_done == 1'b1)) begin
                    /*Previous register is being published*/
                    reg_we[i] = 1'b0;
                    updt_cmn[i] = 1'b0;
                    op1_updt_en[i] = 1'b0;
                    op2_updt_en[i] = 1'b0;
                    op1_updt_from_cdb[i] = 1'b0;
                    op2_updt_from_cdb[i] = 1'b0; 
                    flush[i] = 1'b1;
                end else begin
                    op1_updt_en[i] = 1'b1;
                    op2_updt_en[i] = 1'b1;
                    reg_we[i] = 1'b1;
                    updt_cmn[i] = 1'b1;
                    flush[i] = 1'b0;
                    /*Compares with prev register operation*/
                    if(reg_updt_op1[i-1] == 1'b1)
                    /*Update op1 with CDB*/
                        op1_updt_from_cdb[i] = 1'b1;
                    else
                    /*Update from previous*/
                        op1_updt_from_cdb[i] = 1'b0;

                    if(reg_updt_op2[i-1] == 1'b1)
                    /*Update op2 with CDB*/
                        op2_updt_from_cdb[i] = 1'b1;
                    else
                    /*Update from previous*/
                        op2_updt_from_cdb[i] = 1'b0;
                end
            end
        end
    end
end

endmodule