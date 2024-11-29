 /****************************************************
 * Company: ITESO
 *****************************************************
 * Engineer: Francisco Flores
 * Date: Feb 2024
 *****************************************************
 * Description: This module describes a multiplexer
 * with N inputs of WIDTH bits.
 *****************************************************
 * Parameters:
 *  WIDTH  Amount of bits in each input
 *  N      Amount of inputs in bits 
 *****************************************************/

module mux_param #(
    parameter WIDTH = 32, 
    parameter N = 32
)
(
    input [WIDTH-1:0] X [N-1:0],
    input [$clog2(N)-1:0] SEL,
    output [WIDTH-1:0] Y
);

assign Y = X[SEL];

endmodule