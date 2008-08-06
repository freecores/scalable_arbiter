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

`timescale 1ns / 1ps

`define CLOCK_MHZ 40
`define DEBOUNCE_HIGH_COUNT 3
`define DEBOUNCE_LOW_COUNT 2
`define STRETCH_HIGH_COUNT 10
`define STRETCH_LOW_COUNT 5

module demo_filters (
	input in,
	output out,
	output valid_in,
	output valid_out,
	
	input clock,
	input reset
);

wire usec_tick, msec_tick, interconnect;

pulser #(
	.count(`CLOCK_MHZ)
) usec_pulser (
	.enable(1'b1),
	.out(usec_tick),
	
	.clock(clock),
	.reset(reset)
);

pulser #(
	.count(1000)
) msec_pulser (
	.enable(usec_tick),
	.out(msec_tick),
	
	.clock(clock),
	.reset(reset)
);

debouncer #(
	.high_count(`DEBOUNCE_HIGH_COUNT),
	.low_count(`DEBOUNCE_LOW_COUNT)
) debouncer (
	.enable(msec_tick),
	.in(in),
	.out(interconnect),
	.valid(valid_in),
	
	.clock(clock),
	.reset(reset)
);

stretcher #(
	.high_count(`STRETCH_HIGH_COUNT),
	.low_count(`STRETCH_LOW_COUNT)
) stretcher (
	.enable(msec_tick),
	.in(interconnect),
	.out(out),
	.valid(valid_out),
	
	.clock(clock),
	.reset(reset)
);

endmodule
