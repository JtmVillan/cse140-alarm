// CSE140 lab 2
// How does this work? How long does the alarm stay on?
// (buzz is the alarm itself)
module alarm(
  input[6:0]   tmin,
               amin,
			   thrs,
			   ahrs,
  output logic buzz
);

/* fill in the guts
  combinational logic (no clock, use =, not <=)
  buzz = 1 iff tmin=amin and thrs=ahrs
*/

always_comb begin
    if (tmin == amin && thrs == ahrs) begin
        buzz = 1;
    end

    else begin
        buzz = 0;
    end
end


endmodule
