`timescale 1ns/1ps


////////UDP.sv////**************************************************************************************
//
//

//////********************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 03:22:32 PM
// Design Name: 
// Module Name: UDP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UDP #(
    parameter DATA_WIDTH       = 1024,
    parameter DEPTH            = 32,
    parameter BIAS_WIDTH       = 4,
    parameter DATA_WIDTH_INT   = 32,
    parameter PARALLEL_OUT     = 32,
    parameter INT_WIDTH        = 8,
    parameter OUT_WIDTH        = 256
)(

    input wire i_clk,
    input wire i_rst,

    input logic [DATA_WIDTH-1:0]rdma_in_bias,
    input logic                 rdma_valid_bias,
    input logic                 rdma_bias_done,

    input logic [DATA_WIDTH-1:0]input_conv_core,
    input logic                 input_valid_conv_core,


    input logic [BIAS_WIDTH-1:0]     csr_bias_batch,
    input logic [DATA_WIDTH_INT-1:0] csr_b,
    input logic [DATA_WIDTH_INT-1:0] csr_c,
    input logic [PARALLEL_OUT-1:0]   csr_op_prelu,


    input logic csr_bias_en,
    input logic [1:0]csr_demux, // to choose the function between the 

    output logic [OUT_WIDTH-1:0]output_udp,
    output logic                o_fifo_push,
    input  logic                o_fifo_full,
    output logic                wdma_en

    
);

    /// bias_addition IOs
    logic enable_bias;
    logic [DATA_WIDTH-1:0]input_b;
    logic                 input_b_valid;

    logic [DATA_WIDTH-1:0]output_b;
    logic                 output_b_valid;

//    ///// BN IOs
//    logic [DATA_WIDTH-1:0]     input_bn;
//    logic                      input_bn_valid;
//    logic [DATA_WIDTH_INT-1:0] input_bn_reg[0:PARALLEL_OUT-1];


//    logic [DATA_WIDTH-1:0]    output_bn;
//    logic                     output_bn_valid;
//    logic [DATA_WIDTH_INT-1:0]output_bn_valid_reg;
//    logic [DATA_WIDTH_INT-1:0]output_bn_reg[0:PARALLEL_OUT-1];

//    assign output_bn_valid = (output_bn_valid_reg == 32'hffff_ffff) ? 1'b1 : 1'b0;



    // ///////  LUT IOs

    // logic [DATA_WIDTH-1:0]     input_lut;
    // logic                      input_lut_valid;
    // logic [DATA_WIDTH_INT-1:0] input_lut_reg[0:PARALLEL_OUT-1];

    // logic [DATA_WIDTH-1:0]     output_lut;
    // logic                      output_lut_valid;
    // logic [DATA_WIDTH_INT-1:0] output_lut_reg[0:PARALLEL_OUT-1];


    /// spl IOs
    logic [DATA_WIDTH-1:0]    input_spl;
    logic                     input_spl_valid;
    logic [DATA_WIDTH_INT-1:0]input_spl_reg[0:PARALLEL_OUT-1];

    logic [DATA_WIDTH-1:0]    output_spl;
    logic                     output_spl_valid;
    logic [DATA_WIDTH_INT-1:0]output_spl_reg[0:PARALLEL_OUT-1];
    logic [DATA_WIDTH_INT-1:0]output_spl_valid_reg;

    assign output_spl_valid = (output_spl_valid_reg == 32'hffff_ffff) ? 1'b1 : 1'b0;


    /// quantization IOs

    logic [DATA_WIDTH-1:0]    input_q;
    logic                     input_q_valid;
    logic [DATA_WIDTH_INT-1:0]input_q_reg[0:PARALLEL_OUT-1];

    logic [OUT_WIDTH-1:0]     output_q;
    logic                     output_q_valid;
    logic [INT_WIDTH-1:0]output_q_reg[0:PARALLEL_OUT-1];
    logic [DATA_WIDTH_INT-1:0]     output_q_valid_reg;

    assign output_q_valid = (output_q_valid_reg == 32'hffff_ffff) ? 1'b1 : 1'b0;

    ///RELU IOs

    logic [OUT_WIDTH-1:0]     input_relu;
    logic                     input_relu_valid;
    logic [INT_WIDTH-1:0]     input_relu_reg[0:PARALLEL_OUT-1];

    logic [OUT_WIDTH-1:0]     output_relu;
    logic                     output_relu_valid;
    logic [DATA_WIDTH_INT-1:0]output_relu_valid_reg;
    logic [INT_WIDTH-1:0]     output_relu_reg[0:PARALLEL_OUT-1];
    assign output_relu_valid  = (output_relu_valid_reg == 32'hffff_ffff) ? 1'b1 : 1'b0;




    genvar j;
        
    // generate 

    //     for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : input_bias 

    //         assign input_b_reg[j] = input_b[(j*32)+31 : (j*32)]; 
    //     end
        
    // endgenerate


    // generate 

    //     for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : output_q
            
    //         assign output_bias[(j*8)+7 : (j*8)]= output_bias_reg[j];
    //     end
        
    // endgenerate

//    generate 

//        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : bn_input

//            assign input_bn_reg[j] = input_bn[(j*32)+31 : (j*32)]; 
//        end
        
        
//    endgenerate


//    generate 

//        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : bn_output
            
//            assign output_bn[(j*32)+31 : (j*32)]= output_bn_reg[j];
//        end
        
//    endgenerate


    // generate 

    //     for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : lut_input

    //         assign input_lut_reg[j] = input_lut[(j*8)+7 : (j*8)]; 
    //     end
        
    // endgenerate



    // generate 

    //     for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : output_q
            
    //         assign output_lut[(j*8)+7 : (j*8)]= output_lut_reg[j];
    //     end
        
    // endgenerate


    generate 

        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : spl_input

            assign input_spl_reg[j] = input_spl[(j*32)+31 : (j*32)]; 
        end
        
        
    endgenerate


    generate 

        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : spl_output
            
            assign output_spl[(j*32)+31 : (j*32)]= output_spl_reg[j];
        end
        
    endgenerate

    generate 

        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : q_input

            assign input_q_reg[j] = input_q[(j*32)+31 : (j*32)]; 
        end
        
        
    endgenerate


    generate 

        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : q_output

            assign output_q[(j*8)+7 : (j*8)]= output_q_reg[j];
        end
        
    endgenerate

    generate
        for (j = 0 ; j<PARALLEL_OUT ;j=j+1 ) begin : relu_input
            assign input_relu_reg[j] = input_relu[(j*8)+7 : (j*8)];
            
        end
    endgenerate


    generate 

        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : relu_output
            
            assign output_relu[(j*8)+7 : (j*8)]= output_relu_reg[j];
        end
        
    endgenerate






    always_comb begin

        begin
            enable_bias        = 1'b0;
            input_b            =   0;
            input_b_valid      =  'd0;
            input_q            =   'd0;     
            input_q_valid      =   'd0;     
            input_relu         =   'd0;     
            input_relu_valid   =   'd0;     
            output_udp         =   'd0;     
            input_spl          =   'd0;     
            input_spl_valid    =   'd0;               
        end

        if(!i_rst)begin
            enable_bias = 1'b0;
        end
        else begin
            if(csr_bias_en)begin
                enable_bias     = 1'b1;
                input_b         = input_conv_core;
                input_b_valid   = input_valid_conv_core;

                case (csr_demux)

                    2'b00: begin
                            input_q            = output_b;
                            input_q_valid      = output_b_valid;
                            input_relu         = output_q;
                            input_relu_valid   = output_q_valid;
                            output_udp         = output_relu;
                            
                        end 

                    2'b01 : begin
                            input_spl          = output_b;
                            input_spl_valid    = output_b_valid;
                            input_q            = output_spl;
                            input_q_valid      = output_spl_valid;
                            output_udp         = output_q;
                        end

                    2'b10 : begin


        
                        
                        end

                    2'b11:begin


 

                        end

                    default: ;

                endcase
            end
            else begin
                enable_bias = 1'b0;
    
                case (csr_demux)

                    2'b00: begin
                            input_q            = input_conv_core;
                            input_q_valid      = input_valid_conv_core;
                            input_relu         = output_q;
                            input_relu_valid   = output_q_valid;
                            output_udp         = output_relu;
                        end 

                    2'b01 : begin
                            input_spl          = input_conv_core;
                            input_spl_valid    = input_valid_conv_core;
                            input_q            = output_spl;
                            input_q_valid      = output_spl_valid;
                            output_udp         = output_q;
                        end

                    2'b10 : begin


                        end

                    2'b11:begin


                        end
                        
                    default: ;
                endcase
            end 
        end
    end






    bias_controller #(
        .DATA_WIDTH                  (DATA_WIDTH),
        .DEPTH                       (DEPTH),
        .DATA_WIDTH_INT              (DATA_WIDTH_INT),
        .PARALLEL_OUT                (PARALLEL_OUT),
        .BIAS_WIDTH                  (BIAS_WIDTH)
    ) B_A (        
        .i_clk                       (i_clk),
        .i_rst                       (i_rst),
        
        .csr_bias_en                 (enable_bias),
        .csr_bias_batch              (csr_bias_batch),

        .bias_in                     (rdma_in_bias),
        .bias_valid_in               (rdma_valid_bias),
        .bias_done_in                (rdma_bias_done),

        .input_conv                  (input_b),
        .input_valid_conv            (input_b_valid),

        .output_bias                 (output_b),
        .output_bias_valid           (output_b_valid)
    );


    genvar i ;

    generate

        for(i=0 ; i<PARALLEL_OUT ; i=i+1)begin : QUAN
            qunat Q(    
                         .i_clk         (i_clk)
                        ,.i_rst         (i_rst)
                        ,.in_data       (input_q_reg[i])
                        ,.b             (csr_b)
                        ,.quant_enable  (input_q_valid)
                        ,.c             (csr_c)
                        ,.out_data      (output_q_reg[i])
                        ,.quant_done    (output_q_valid_reg[i])
                    );
        end
        
    endgenerate

    generate

        for(i=0 ; i<PARALLEL_OUT ; i=i+1)begin : RELU

            relu R( 
                     .i_clk           (i_clk)
                    ,.i_rst           (i_rst)
                    ,.inputx          (input_relu_reg[i])          
                    ,.outputy         (output_relu_reg[i])  
                    ,.input_valid     (input_relu_valid)      
                    ,.output_valid    (output_relu_valid_reg[i])      
                );
        end

    endgenerate

    // generate
    //     for (i =0 ; i<PARALLEL_OUT  ; i=i+1) begin : B_N

    //         BN  B_N(
 
    //                  .inputx       (input_bn_reg[i])                                               
    //                 ,.mean         (csr_mean)                                             
    //                 ,.sd           (csr_sd)      
    //                 ,.quotient     (output_bn_reg[i])                                              
    //                 ,.bn_done      (output_bn_valid_reg[i])                            
    //         );
            
    //     end
    // endgenerate 



    generate 
        for (i=0; i<PARALLEL_OUT ; i=i+1)begin :PRELU

            prelu P( 
                     .i_clk            (i_clk)                                    
                    ,.i_rst            (i_rst)                                          
                    ,.prelu_en         (input_spl_valid)                                            
                    ,.data_in          (input_spl_reg[i])                                             
                    ,.op_in            (csr_op_prelu)                                                 
                    ,.data_out         (output_spl_reg[i])                                              
                    ,.prelu_op_done    (output_spl_valid_reg[i])                                                
                );
        end

    endgenerate

    // generate 
    //     for(i=0 ; i<PARALLEL_OUT ; i=i+1)begin
    //         lut(
    //                  .i_clk          (i_clk)                                    
    //                 ,.i_rst          (i_rst)                                    
    //                 ,.data_in        (rdma_lut_in)                                      
    //                 ,.buf_done       ()                                       
    //                 ,.wr_en          (rdma_lut_valid)                                    
    //                 ,.IF             (input_lut_reg[i])                                 
    //                 ,.IF_valid       ()                                       
    //                 ,.data_out       (output_lut_reg[i])                                       
    //                 ,.valid_data     ()                                         
    //                 ,.step_size      ()                                        
    //                 ,.max            ()                                  
    //                 ,.min            ()                                  
    //                 ,.LUT_entry      ()                                        
    //         );
    //     end
    // endgenerate


    always_ff @(posedge i_clk)begin
        if(!i_rst)begin
            o_fifo_push <= 1'b0;

        end
        else begin
            if(output_q_valid && (!o_fifo_full))begin
                o_fifo_push <= 1'b1;
                wdma_en      <= 1'b1;
            end
            else begin
                o_fifo_push <= 1'b0;
                wdma_en     <= 1'b0;
            end
        end
    end


    
endmodule

    
/////bais_add.sv/////****************************************************************************************************

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 10:51:10 AM
// Design Name: 
// Module Name: bias_add
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bias_add #(parameter num_inputs = 2, input_width = 32) ( INPUT_DATA, OUT  );


    input signed [num_inputs*input_width-1:0] INPUT_DATA;
    
    output reg signed [input_width-1:0]OUT;
    
    
    reg [input_width-1:0]OUT0;
    reg [input_width-1:0]OUT1;
    
    reg signed [input_width-1 : 0] input_array [num_inputs-1 : 0];
    reg signed [input_width-1 : 0] temp_array  [num_inputs-1 : 0];
    reg [input_width-1 : 0] input_slice;
    
    integer num_in;
    integer i, j;

    always @(INPUT_DATA) begin

        for (i=0 ; i < num_inputs ; i=i+1) begin
            for (j=0 ; j < input_width ; j=j+1) begin
                input_slice[j] = INPUT_DATA[i*input_width+j];
            end
            input_array[i] = input_slice;
        end

        for (num_in = num_inputs; num_in >1 ; num_in = num_in - (num_in/2)) begin
            for (i=0 ; i < (num_in/2) ; i = i+1) begin
                temp_array[i*2] = input_array[i*2] ^ input_array[i*2+1]; //get partial sum

                temp_array[i*2+1] = (input_array[i*2] & input_array[i*2+1]) << 1; //get shift carry
            end

            if ((num_in % 2) > 0) begin
                for (i=0 ; i < (num_in % 2) ; i = i + 1)
                    temp_array[2 * (num_in/2) + i] = input_array[2 * (num_in/2) + i];
            end

            for (i=0 ; i < num_in ; i = i + 1)
                 input_array[i] = temp_array[i]; //update input array.
        end
    end 

    
    assign OUT0 = input_array[0];
    assign OUT1 = input_array[1];
    assign OUT  = OUT0 + OUT1;
//    assign bias_valid = 1'b1;
    
    
    
endmodule

////////////***********************************************************************************************************************

////bais_controller.sv////*********************************************************************************************************

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 10:51:28 AM
// Design Name: 
// Module Name: bias_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bias_controller#(
    parameter DATA_WIDTH      = 1024,
    parameter DEPTH           = 32,
    parameter DATA_WIDTH_INT  = 32,
    parameter PARALLEL_OUT    = 32,
    parameter BIAS_WIDTH = 5
)(

    input wire                     i_clk,
    input wire                     i_rst,
        
    input logic                    csr_bias_en,
    input logic [BIAS_WIDTH-1:0]   csr_bias_batch,


    input logic [DATA_WIDTH-1:0]   bias_in,
    input logic                    bias_valid_in,
    input logic                    bias_done_in,

    input logic [DATA_WIDTH-1:0] input_conv,
    input logic                  input_valid_conv,
    
    output logic [DATA_WIDTH-1:0] output_bias,
    output logic                  output_bias_valid

);

    logic done_bias;

    logic [DATA_WIDTH-1:0]fifo_out;

    logic b_fifo_pop;
    logic b_fifo_push;
    logic b_fifo_full;
    logic enable;



    logic [DATA_WIDTH_INT-1:0] bias_data[0:PARALLEL_OUT-1];

    logic [DATA_WIDTH_INT-1:0] input_ADD[0:PARALLEL_OUT-1];

    logic [DATA_WIDTH_INT-1:0] output_ADD[0:PARALLEL_OUT-1];



    typedef enum  { 
        IDLE,
        BA,
        BA_OPR,
        WAIT_STA
    } state;

    state next_state,current_state;


    always_ff@(posedge i_clk)begin
        if(~i_rst) begin
            current_state  <= IDLE;
        end
        else begin
            current_state  <= next_state;
        end
    end


    always_comb begin : FSM 

        next_state = current_state;

        case(current_state)
        
            IDLE: begin
                    if(csr_bias_en)begin
                        next_state = BA;
                    end
                    else begin
                        next_state = IDLE;
                    end 
                end 
          

            BA :begin
                    if(done_bias) begin
                        next_state = BA_OPR;
                    end
                    else begin
                        next_state = BA;
                    end
                end
            BA_OPR : begin
                    if(done_bias)begin
                        if(input_valid_conv)begin
                            next_state = BA_OPR;
                        end
                        else begin
                            // next_state = ;
                        end
                    end
                    else begin
                        next_state = BA;
                    end
                end
            WAIT_STA: begin
                        if(done_bias)begin
                            if(input_valid_conv)begin
                                next_state = BA_OPR;
                            end
                            else begin
                                next_state = WAIT_STA;
                            end
                            
                        end
                        else begin
                            next_state = BA;
                        end

                end
                
          default : begin
          
          end

        endcase
    end


    always_ff @(posedge i_clk)begin :OUTPUT
        case (next_state)
            IDLE: begin
                    b_fifo_push       <= 1'b0;
                    b_fifo_pop        <= 1'b0;
                    done_bias         <= 1'b1;
                    enable            <= 1'b0;
                    done_bias         <= 1'b0;
                    output_bias_valid <= 1'b0;
                end

            BA: begin
                    if(!bias_done_in && !done_bias) begin
                        if(!b_fifo_full && bias_valid_in)begin
                            b_fifo_push <= 1'b1;
                        end
                        else begin
                            b_fifo_push <= 1'b0;
                        end
                    end
                    else begin
                        done_bias <= 1'b1;
                    end 
                end
                
            BA_OPR:begin
                    if(done_bias && input_valid_conv)begin
                        b_fifo_pop         <= 1'b1;
                        output_bias_valid  <= 1'b1;
                    end
                    else begin
                        b_fifo_pop         <= 1'b0;
                        output_bias_valid  <= 1'b0;
                    end
                end


            WAIT_STA : begin
                        b_fifo_pop        <= 1'b0;
                        b_fifo_push       <= 1'b0;
                        enable            <= 1'b0;
                        output_bias_valid <= 1'b0;

                    end
            default: ;
        endcase
    end

    genvar j;
        
    generate 

        
            for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : IN
            
               assign bias_data[j] = fifo_out[(j*32)+31 : (j*32)]; 
            end
        
        
        endgenerate  

    generate 

        //genvar j;
            
                for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : IN2
                
                   assign input_ADD[j] = input_conv[(j*32)+31 : (j*32)]; 
                end
            
            
            endgenerate 
        
        
    generate 
        
        for (j = 0; j < PARALLEL_OUT ; j=j+1) begin : OUT
            
            assign output_bias[(j*32)+31 : (j*32)] = output_ADD[j];
               
        end
        
    endgenerate 



    bias_fifo #(
        .DATA_WIDTH         (DATA_WIDTH),
        .DEPTH              (DEPTH),
        .BIAS_WIDTH         (BIAS_WIDTH)
    ) B_F (
        .i_clk               (i_clk),
        .i_rst               (i_rst),
        .push                (b_fifo_push),
        .pop                 (b_fifo_pop),
        .full                (b_fifo_full),
        .inputb              (bias_in),
        .outputb             (fifo_out),
        .bias_batch          (csr_bias_batch)
    );


    genvar i;


    generate
        
    
        for(i=0 ; i < PARALLEL_OUT ; i=i+1)begin : BIAS

            bias_add  B_A(  
                             
                             .INPUT_DATA       ({input_ADD[i],bias_data[i]})
                            ,.OUT              (output_ADD[i])
                        );
            
        end
    endgenerate


endmodule

///////*************************************************************************************************************************

/////bais_fifo.sv/////************************************************************************************************************

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 10:50:54 AM
// Design Name: 
// Module Name: bias_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bias_fifo#(
    parameter DATA_WIDTH = 1024,
    parameter DEPTH      = 32,
    parameter BIAS_WIDTH = 5
)(
    input   wire                        i_clk,
    input   wire                        i_rst,

    input   logic                       push,
    input   logic                       pop,

    output  logic                       full,

    input   logic [DATA_WIDTH-1:0]      inputb,
    output  logic [DATA_WIDTH-1:0]      outputb,
    input   logic [BIAS_WIDTH-1:0]      bias_batch

);

    reg [DATA_WIDTH-1:0] MEM[DEPTH-1:0];

    localparam int unsigned FifoDepth = (DEPTH > 0) ? DEPTH : 1;

    logic [($clog2(DEPTH))-1:0]shift_reg;

    //logic [($clog2(DEPTH))-1:0]rd_ptr;
    logic [($clog2(DEPTH))-1:0]wr_ptr;

    //logic [($clog2(DEPTH))-1:0]status_ptr;
    

    assign full = (wr_ptr == DEPTH ) ? 1'b1 : 1'b0;


    always_ff @(posedge i_clk)begin
        if(!i_rst)begin
            wr_ptr <= 0;
        end
        else begin
            if(push && !pop)begin
                MEM[wr_ptr] <= inputb;
                wr_ptr      <= wr_ptr + 1;
            end
        end
    end


    // always_ff @(posedge i_clk)begin

    //         if(!push && pop && i_rst)begin
    //             outputb <= MEM[shift_reg];
    //     end
    // end

    assign outputb = (pop && !push) ? MEM[shift_reg] : 0;


    always_ff @(posedge i_clk) begin
        if(!i_rst)begin
            shift_reg <= 0;
        end
        else begin
            if(pop && !push)begin
                //outputb <= MEM[shift_reg];

                if(shift_reg == bias_batch-1)begin
                    shift_reg <= 0;
                end
                else begin
                    shift_reg <= shift_reg + 1;
                end
            end
            else begin
                shift_reg <= 0;
            end
        end
    end


    // always_comb begin
    //     if(!i_rst)begin
    //         shift_reg = 0;
    //     end
    //     else begin
    //         if(pop && !push)begin
    //             //outputb <= MEM[shift_reg];

    //             if(shift_reg == bias_batch-1)begin
    //                 shift_reg = 0;
    //             end
    //             else begin
    //                 shift_reg = shift_reg + 1;
    //             end
    //         end
    //         else begin
    //             shift_reg = FifoDepth - 1;
    //         end
    //     end
    // end




endmodule


//////***************************************************************************************************************************	

/////prelu.sv///*****************************************************************************************************************

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 10:31:19 AM
// Design Name: 
// Module Name: prelu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module prelu #(
    parameter int unsigned  DATA_WIDTH  = 32
)( 
    input logic i_clk,
    input logic i_rst,

    input  logic prelu_en,
    
    input  logic signed [DATA_WIDTH-1:0] data_in,
    input  logic signed [DATA_WIDTH-1:0] op_in,

    output logic signed [DATA_WIDTH*2-1:0] data_out,
    output logic prelu_op_done
);

    logic                        data_in_sign;
    logic                        prelu_op;
    logic signed [DATA_WIDTH-1:0]data_out_reg;

    
    assign  data_in_sign = data_in[DATA_WIDTH-1];
    
    
    always_ff @(posedge i_clk)begin
        if(!i_rst)begin

            data_out     <= 0;
        end
        else begin
            if(prelu_en)begin

                data_out    <= data_out_reg;
                if(prelu_op)begin
                    prelu_op_done <= 1'b1;
                end
                else begin
                    prelu_op_done <= 1'b0;
                end  
            end

        end
    end

    always_comb begin
        if(!i_rst)begin
            data_out_reg = 0;
            prelu_op     = 0;
        end
        else begin
            if(prelu_en)begin
                if (!data_in_sign)begin
                    data_out_reg   = data_in;
                    prelu_op       = 1'b1;
                end
                else begin  
                    data_out_reg    = ($signed(data_in) * (op_in));
                    prelu_op        = 1'b1;
                end 
            end
            else begin
                data_out_reg        = 'd0;
                prelu_op            = 'd0;
            end  
        end
    end

endmodule

//////***********************************************************************************************************************




////qunat.sv////******************************************************************************************************************


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 10:23:52 AM
// Design Name: 
// Module Name: qunat
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module qunat#(
    parameter int unsigned IN_DATA_WIDTH=32,
    parameter int unsigned OUT_DATA_WIDTH=8,
    parameter int unsigned DATA_WIDTH=32
)(  

    input  wire                                 i_clk,
    input  wire                                 i_rst,

    input  logic  signed [IN_DATA_WIDTH-1:0]    in_data,
    input  logic  signed [DATA_WIDTH-1:0]       b,
    input  logic         [DATA_WIDTH-1:0]       c,
    input  logic                                quant_enable,

    output logic  signed [OUT_DATA_WIDTH-1:0]   out_data,
    output logic                                quant_done
);


    logic signed [(DATA_WIDTH*2)-1:0] temp_product;
    logic signed [DATA_WIDTH-1:0]temp_shift;


    always_ff @(posedge i_clk)begin
        if(!i_rst)begin
            temp_product <= 'd0;
        end
        else begin
            if(quant_enable)begin
                temp_product <= $signed(in_data * b) >> c;
            end
            else begin
                temp_product <= 'd0;
            end 
            
        end
    end

    

    always_ff @(posedge i_clk) begin
        if(!i_rst)begin
            out_data   <= 'd0;
            quant_done <= 'b0;
        end
        else begin
            if(quant_enable)begin
                if (temp_product > 127) begin
                    out_data   <= 127;
                    quant_done <= 1'b1;
                end
                else if (temp_product < $signed(8'h80)) begin
                    out_data   <= 8'h80;
                    quant_done <= 1'b1;
                end
                else begin
                    out_data   <= temp_product[OUT_DATA_WIDTH-1:0];
                    quant_done <= 1'b1;
                end  
            end
            else begin
                out_data   <= 'd0;
                quant_done <= 'b0;
            end
        end
    end
 
endmodule

//////******************************************************************************************************************

/////relu.sv////********************************************************************************************************

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 10:27:26 AM
// Design Name: 
// Module Name: relu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module relu#(
    parameter DATA_WIDTH = 8
)(

    input  wire                   i_clk,
    input  wire                   i_rst,


    input  logic [DATA_WIDTH-1:0]inputx,
    output logic [DATA_WIDTH-1:0]outputy,

    input  logic input_valid,

    output logic output_valid
);

    logic sign_bit;



    assign sign_bit = inputx[DATA_WIDTH-1];

    always_ff @(posedge i_clk)begin
        if(!i_rst)begin
            output_valid <= 0;
            outputy      <= 0;
        end
        else begin
            if(input_valid && !sign_bit)begin
                outputy     <= inputx;   
                output_valid <= 1'b1;   
            end 
            else begin
                outputy      <= 'd0;
                output_valid <= 1'b0;
            end    
        end
    end
endmodule

////**************************************************************************************************

