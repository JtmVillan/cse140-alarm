// CSE140L
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module top_level_lab2_part1(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
		Alarmon,
		Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp,
               H1disp, H0disp,
  output logic Buzz);	           // alarm sounds
  logic[6:0] TSec, TMin, THrs,     // clock/time
             AMin, AHrs;		   // alarm setting
  logic[6:0] Min, Hrs;
  logic Szero, Mzero, Hzero, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, AMen, AHen;
  logic Buzz1;	                   // intermediate Buzz signal

// be sure to set parameters on ct_mod_N modules
// seconds counter runs continuously, but stalls when Timeset is on

//if the enable is 0 and reset is 0, (time set is on), keep the same output
  ct_mod_N #(.N(60)) Sct(
    .clk(Pulse), .rst(Reset), .en(!Timeset), .ct_out(TSec), .z(Szero)
    );




//if setting minutes, minutes will act as a seconds counter
//if not setting minutes, minutes will act as a seconds counter ONLY when seconds at 59, meaning z is 1
//if the reset and enable are both 0, then the ct_mod will HOLD


always_comb begin
    if (Szero == 1 || (Timeset==1 && Minadv==1)) begin
        TMen = 1;
    end
    else begin
        TMen = 0;
    end
end
/*
always_comb begin
    if (Timeset==1) begin
        TMen = Minadv;
    end
    else begin
        TMen = Szero;
    end
end*/

// minutes counter -- runs at either 1/sec or 1/60sec
  ct_mod_N #(.N(60)) Mct(
    .clk(Pulse), .rst(Reset), .en(TMen), .ct_out(TMin), .z(Mzero)
    );
//when "enabled", timeset is 1, minutes adv at 1/sec to set minutes
//how to "run" this in a condition
//do i stick this ct_mod_N in an always statement?


always_comb begin
    if ((Mzero == 1 && Szero == 1) || (Timeset==1 && Hrsadv==1)) begin
        THen = 1;
    end
    else begin
        THen = 0;
    end
end
/*
always_comb begin
    if (Timeset==1) begin
        THen = Hrsadv;
    end
    else begin
        THen = Mzero && Szero;
    end
end*/

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N #(.N(24)) Hct(
	.clk(Pulse), .rst(Reset), .en(THen), .ct_out(THrs), .z(Hzero)
    );



always_comb begin
    if (Alarmset == 1 && Minadv == 1) begin
        AMen = 1;
    end
    else begin
        AMen = 0;
    end
end

// alarm set registers -- either hold or advance 1/sec
  ct_mod_N #(.N(60)) Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .ct_out(AMin), .z()
    );


always_comb begin
    if (Alarmset == 1 && Hrsadv == 1) begin
        AHen = 1;
    end
    else begin
        AHen = 0;
    end
end

  ct_mod_N #(.N(24)) Hreg(
    .clk(Pulse), .rst(Reset), .en(AHen), .ct_out(AHrs), .z()
    );


// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(
    .bin_in (TSec)  ,
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

    always_comb begin
        //condition on if timeset or alarmset is on
        if (Alarmset == 1) begin
            Min = AMin;
        end
        else begin
            Min = TMin;
        end
    end

  lcd_int Mdisp(
    .bin_in (Min) ,
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

    always_comb begin
        if (Alarmset == 1) begin
            Hrs = AHrs;
        end
        else begin
            Hrs = THrs;
        end
    end

  lcd_int Hdisp(
    .bin_in (Hrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);

//condition based on Alarm On
    always_comb begin
        if (Alarmon == 1 && Buzz1 == 1) begin
            Buzz = 1;
        end
        else begin
            Buzz = 0;
        end
    end
// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .buzz(Buzz1)
	);

endmodule
