/*
 * Copyright (c) 2008, Kendall Correll
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

`define PORT_WIDTH 8
`define ARB_WIDTH 256
`define SELECT_WIDTH 8

/*

These results give a rough idea of how the timing and size scale
with the arbiter width. It is useful to look at the trends, but
the individual values should be taken with a grain of salt.

Preliminary results using XC3S1600E-4FG320:

                  arbiter                        arbiter_x2
        /----------------------------\ /----------------------------\
 width    MHz    slices LUTs registers   MHz    slices LUTs registers
    8   214.961     22    34    35     287.439     34    42    53
   16   191.571     47    75    68     284.252     69    87   103
   32   148.943     99   163   133     211.730    122   169   188
   64   124.285    200   346   262     202.840    245   349   370
  128   102.807    434   717   519     165.044    490   739   699
  256   100.796    923  1555  1032     163.666    986  1504  1389
  512    87.176   1867  3120  2057     148.854   1973  2914  2686
 1024    81.974   3628  5976  4106     140.213   3947  5883  5360
 2048    69.214   7089 11444  8203     116.050   7966 12164 10513
 4096    49.332* 14853 24501 16396     113.404* 15592 23858 21011

* at 4096, arbiter and arbiter_x2 exceed device capacity

Preliminary results using EP3C25F324C8:

                  arbiter                        arbiter_x2
        /----------------------------\ /----------------------------\
 width    MHz    slices LUTs registers   MHz    slices LUTs registers
    8   384.17      37    33    35     453.31      55    29    53
   16   289.60      80    73    68     452.90     108    68   103
   32   259.74     165   160   133     357.53     206   152   188
   64   187.51     337   320   262     299.94     415   319   370
  128   132.12     675   630   519     226.50     853   685   699
  256   122.37    1362  1279  1032     217.96    1694  1353  1389
  512    99.91    2738  2627  2057     132.29    3303  2642  2686
 1024    85.54    5434  5121  4106     130.28    6622  5312  5360
 2048    71.77   10861 10128  8203     123.47   13236 10582 10513
 4096    61.10   21777 20313 16396     140.86   23208 21177 21011

*/

module demo_arbiter (
	input enable_in,
	input enable_out,
	input load,
	input [`PORT_WIDTH-1:0] port_in,
	output [`PORT_WIDTH-1:0] port_out,
	output [`SELECT_WIDTH-1:0] select,
	output valid,
	
	input clock,
	input reset
);

wire [`ARB_WIDTH-1:0] req, grant;

shifter #(
	.count(`ARB_WIDTH/`PORT_WIDTH),
	.width(`PORT_WIDTH)
) in_shifter (
	.enable(enable_in),
	.load(1'b0),
	
	.parallel_in({`ARB_WIDTH{1'bx}}),
	.serial_in(port_in),
	.parallel_out(req),
	.serial_out(),
	
	.clock(clock)
);

arbiter #(
	.width(`ARB_WIDTH),
	.select_width(`SELECT_WIDTH)
) arbiter (
	.enable(1'b1),
	.req(req),
	.grant(grant),
	.select(select),
	.valid(valid),
	
	.clock(clock),
	.reset(reset)
);

shifter #(
	.count(`ARB_WIDTH/`PORT_WIDTH),
	.width(`PORT_WIDTH)
) out_shifter (
	.enable(enable_out),
	.load(load),
	
	.parallel_in(grant),
	.serial_in({`PORT_WIDTH{1'bx}}),
	.parallel_out(),
	.serial_out(port_out),
	
	.clock(clock)
);

endmodule
