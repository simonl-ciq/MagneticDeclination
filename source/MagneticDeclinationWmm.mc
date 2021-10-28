import Toybox.Lang;
using Toybox.Math;
using Toybox.Time as Time;
using Toybox.Position as Position;
using Toybox.Time.Gregorian;

using Toybox.System as Sys;

class WMM {
	const A_CONST = 6378.137d;
	const A2_CONST = (A_CONST * A_CONST);
	const B_CONST = 6356.7523142d;
	const B2_CONST = (B_CONST * B_CONST);
	const RE_CONST = 6371.2d;
	const A4_CONST = (A2_CONST * A2_CONST);
	const B4_CONST = (B2_CONST * B2_CONST);
	const C2_CONST = (A2_CONST - B2_CONST);
	const C4_CONST = (A4_CONST - B4_CONST);
	const COEFFICIENTS_COUNT = 90;

	hidden var c = new [13];
	hidden var cd = new [13];
	hidden var k = new [13];
	hidden var snorm as Array<Double> = new Array<Double>[169];

	function leapyear(year)  {
		return (((year % 400) == 0) || (((year % 4) == 0) && ((year % 100) != 0))) ? true : false;
	}

	function wmm_get_cof_date(date) as Double {
//							31, 28, 31,  30,  31,  30,  31,  31,  30,  31,  30,  31
		var days   = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
		var days_in_year = 365.0d;
		var leap_adjust = -1.0d;
		var today = Gregorian.utcInfo(date, Time.FORMAT_SHORT);
		if (leapyear(today.year)) {
			days_in_year = 366.0d;
			if (today.month > 2) {leap_adjust = 0.0d;}
		}
		var days_now = leap_adjust + today.day + days[today.month];
		return today.year + (days_now / days_in_year) - WMM_EPOCH;
	}

	function initialize() {
		var j, m, n, D2, gnm, hnm, dgnm, dhnm, flnmj;

		for( var i = 0; i < 13; i += 1 ) {
			c[i] = new [13];
			cd[i] = new [13];
			k[i] = new [13];
		}
		
	// get coefficients

		c[0][0] = 0.0d;
		cd[0][0] = 0.0d;

		j = 0;
		for (n = 1; n <= 12; n++) {
			for (m = 0; m <= n; m++) {
				gnm = wmm_cof_entries[j];
				hnm = wmm_cof_entries[j+1];
				dgnm = wmm_cof_entries[j+2];
				dhnm = wmm_cof_entries[j+3];
				j += 4;

				if (m <= n)	{
					c[m][n] = gnm;
					cd[m][n] = dgnm;
					if (m != 0)	{
						c[n][m - 1] = hnm;
						cd[n][m - 1] = dhnm;
					}
				}
			}
		}

	// CONVERT SCHMIDT NORMALIZED GAUSS COEFFICIENTS TO UNNORMALIZED
		snorm[0] = 1.0d;
		for (n = 1; n <= 12; n++) {
			snorm[n] = snorm[n - 1] * (2 * n - 1).toFloat() / n.toFloat();
			j = 2;
			m = 0;
			for (D2 = n - m + 1; D2 > 0; D2--)	{
				k[m][n] = (((n - 1) * (n - 1)) - (m * m)).toFloat() / ((2 * n - 1) * (2 * n - 3).toFloat());
				if (m > 0) {
					flnmj = ((n - m + 1) * j).toFloat() / (n + m).toFloat();
					snorm[n + m * 13] = snorm[n + (m - 1) * 13] * Math.sqrt(flnmj);
					j = 1;
					c[n][m - 1] = snorm[n + m * 13] * c[n][m - 1];
					cd[n][m - 1] = snorm[n + m * 13] * cd[n][m - 1];
				}
				c[m][n] = snorm[n + m * 13] * c[m][n];
				cd[m][n] = snorm[n + m * 13] * cd[m][n];
				m += 1;
		    }
		}
		k[1][1] = 0.0d;
	}

	function E0000(position as Location, date as Moment) as Float {
		var loc = position.toRadians();
		var dt = wmm_get_cof_date(date);
		var tc = new [13];
		for( var i = 0; i < 13; i += 1 ) {
			tc[i] = new [13];
		}
		var sp = new [13];
		var cp = new [13];
		var dp = new [13];
		for( var i = 0; i < 13; i += 1 ) {
			dp[i] = new [13];
		}

		var pp = new [13];
		var srlon = Math.sin(loc[1]);
		var srlat = Math.sin(loc[0]);
		var crlon = Math.cos(loc[1]);
		var crlat = Math.cos(loc[0]);
		var srlat2 = srlat * srlat;
		var crlat2 = crlat * crlat;

		sp[0] = 0.0d;
		sp[1] = srlon;
		cp[0] = 1.0d;
		cp[1] = crlon;
		dp[0][0] = 0.0d;
		pp[0] = 1.0d;

	// CONVERT FROM GEODETIC COORDS. TO SPHERICAL COORDS
		var q = Math.sqrt(A2_CONST - C2_CONST * srlat2);
		var q2 = (A2_CONST / (B2_CONST)) * (A2_CONST / B2_CONST);
		var ct = srlat / Math.sqrt(q2 * crlat2 + srlat2);
		var st = Math.sqrt(1.0f - (ct * ct));
		var r2 = (A4_CONST - C4_CONST * srlat2) / (q * q);
		var r = Math.sqrt(r2);
		var d = Math.sqrt(A2_CONST * crlat2 + B2_CONST * srlat2);
		var ca = d / r;
		var sa = C2_CONST * crlat * srlat / (r * d);
		for (var m = 2; m <= 12; m++) {
			sp[m] = sp[1] * cp[m - 1] + cp[1] * sp[m - 1];
			cp[m] = cp[1] * cp[m - 1] - sp[1] * sp[m - 1];
		}
		var aor = RE_CONST / r;
		var ar = aor * aor;
		var br = 0.0d;
		var bt = 0.0d;
		var bp = 0.0d;
		var bpp = 0.0d;

		for (var n = 1; n <= 12; n++) {
			ar = ar * aor;
			var m = 0;
			for (var D4 = n + 1; D4 > 0; D4--) {
			// COMPUTE UNNORMALIZED ASSOCIATED LEGENDRE POLYNOMIALS AND DERIVATIVES VIA RECURSION RELATIONS
				if (n == m)	{
					snorm[n + m * 13] = st * snorm[n - 1 + (m - 1) * 13];
					dp[m][n] = st * dp[m - 1][n - 1] + ct * snorm[n - 1 + (m - 1) * 13];
				} else if (n == 1 && m == 0) {
					snorm[n + m * 13] = ct * snorm[n - 1 + m * 13];
					dp[m][n] = ct * dp[m][n - 1] - st * snorm[n - 1 + m * 13];
				} else if (n > 1 && n != m) {
					if (m > n - 2) {
						snorm[n - 2 + m * 13] = 0.0d;
					}
					if (m > n - 2) {
						dp[m][n - 2] = 0.0d;
					}
					snorm[n + m * 13] = ct * snorm[n - 1 + m * 13] - k[m][n] * snorm[n - 2 + m * 13];
					dp[m][n] = ct * dp[m][n - 1] - st * snorm[n - 1 + m * 13] - k[m][n] * dp[m][n - 2];
				}

			// TIME ADJUST THE GAUSS COEFFICIENTS
				tc[m][n] = c[m][n] + dt * cd[m][n];
				if (m != 0) {
					tc[n][m - 1] = c[n][m - 1] + dt * cd[n][m - 1];
				}

			// ACCUMULATE TERMS OF THE SPHERICAL HARMONIC EXPANSIONS
				var par = ar * snorm[n + m * 13];
				var temp1;
				var temp2;

				if (m == 0)	{
					temp1 = tc[m][n] * cp[m];
					temp2 = tc[m][n] * sp[m];
				} else {
					temp1 = tc[m][n] * cp[m] + tc[n][m - 1] * sp[m];
					temp2 = tc[m][n] * sp[m] - tc[n][m - 1] * cp[m];
				}

				bt = bt - ar * temp1 * dp[m][n];
				bp += (m * temp2 * par);
				br += ((n+1) * temp1 * par);

			// SPECIAL CASE: NORTH/SOUTH GEOGRAPHIC POLES
				if (st == 0.0f && m == 1) {
					if (n == 1)	{
						pp[n] = pp[n - 1];
					} else {
						pp[n] = ct * pp[n - 1] - k[m][n] * pp[n - 2];
					}
					bpp += (m * temp2 * ar * pp[n]);
				}
				m += 1;
        	}
    	}
		if (st == 0.0f)	{
			bp = bpp;
		} else	{
			bp /= st;
		}

		// ROTATE MAGNETIC VECTOR COMPONENTS FROM SPHERICAL TO GEODETIC COORDINATES
		// COMPUTE DECLINATION
		return Math.toDegrees(Math.atan2(bp, (-bt * ca - br * sa)));
	}

}
