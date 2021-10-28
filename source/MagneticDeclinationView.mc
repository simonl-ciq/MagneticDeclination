import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Application.Storage;

import Toybox.System;

class MagneticDeclinationView extends WatchUi.View {

	hidden var myInfo = null;
	hidden var needGPS = true;
	hidden var mWMM;
	hidden var mCoords;
	hidden var mDec;
	
    function initialize() {
        mWMM = new WMM();
        View.initialize();
    }

    /* ======================== Position handling ========================== */
    function onPosition(info) {
    	myInfo = info;
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        mCoords = myLayout(dc);
		myInfo = Position.getInfo();
		var loc = myInfo.position.toDegrees();

        if (myInfo == null || myInfo.accuracy < Position.QUALITY_POOR) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
		}
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

(:vivohr)
    function myLayout(dc) {
		var lf = Graphics.FONT_MEDIUM;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 74;

        return [lf, vy, vf];
    }

(:d2etc)
    function myLayout(dc) {
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 94;

        return [lf, vy, vf];
    }

(:vivo3S60)
    function myLayout(dc) {
// ApproachS60  vivo3
		var lf = Graphics.FONT_XTINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 75;

        return [lf, vy, vf];
    }

(:fr735xt)
    function myLayout(dc) {
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 60;

        return [lf, vy, vf];
    }

(:round208)
    function myLayout(dc) {
		var lf = Graphics.FONT_XTINY;
       	var vf = Graphics.FONT_NUMBER_MEDIUM;
       	var vy = 60;

        return [lf, vy, vf];
    }

(:round218)
    function myLayout(dc) {
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 68;

        return [lf, vy, vf];
    }

(:round240)
    function myLayout(dc) {
//mk2s fenix6s fr245 fr745 fr945 marq
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 75;

        return [lf, vy, vf];
    }

(:round260plus)
    function myLayout(dc) {
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 80;

        return [lf, vy, vf];
    }

(:round280)
    function myLayout(dc) {
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 88;

        return [lf, vy, vf];
    }

(:round390)
    function myLayout(dc) {
		var lf = Graphics.FONT_XTINY;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 130;

        return [lf, vy, vf];
    }

(:gpsmap)
    function myLayout(dc) {
		var lf = Graphics.FONT_MEDIUM;
       	var vf = Graphics.FONT_NUMBER_HOT;
       	var vy = 125;

        return [lf, vy, vf];
    }

(:rect240)
    function myLayout(dc) {
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_THAI_HOT;
       	var vy = 85;

        return [lf, vy, vf];
    }

(:rect200x265)
    function myLayout(dc) {
		var lf = Graphics.FONT_SMALL;
       	var vf = Graphics.FONT_NUMBER_THAI_HOT;
       	var vy = 95;

        return [lf, vy, vf];
    }

(:rect240x400)
    function myLayout(dc) {
		var lf = Graphics.FONT_MEDIUM;
       	var vf = Graphics.FONT_NUMBER_THAI_HOT;
       	var vy = 120;

        return [lf, vy, vf];
    }

(:rect246x322)
    function myLayout(dc) {
		var lf = Graphics.FONT_SMALL;
       	var vf = Graphics.FONT_NUMBER_THAI_HOT;
       	var vy = 110;

        return [lf, vy, vf];
    }

(:rect282x470)
    function myLayout(dc) {
		var lf = Graphics.FONT_TINY;
       	var vf = Graphics.FONT_NUMBER_THAI_HOT;
       	var vy = 120;
        return [lf, vy, vf];
    }

(:rect480x800)
    function myLayout(dc) {
		var lf = Graphics.FONT_MEDIUM;
       	var vf = Graphics.FONT_NUMBER_THAI_HOT;
       	var vy = 220;

        return [lf, vy, vf];
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
		var px = dc.getWidth() / 2;
		if (needGPS) {
	    	if (myInfo == null || myInfo.accuracy == null || myInfo.accuracy < Position.QUALITY_POOR) {
		    	myInfo = Position.getInfo();
		    }
			if (myInfo.accuracy != null && myInfo.accuracy != Position.QUALITY_NOT_AVAILABLE && myInfo.position != null) {
				if (myInfo.accuracy >= Position.QUALITY_POOR) {
		            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
					needGPS = false;
	    		}
	    	}
		}

    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

    	dc.drawText(px, 10, mCoords[0], "Magnetic\nDeclination", Graphics.TEXT_JUSTIFY_CENTER);

		var myAccuracy = (!(myInfo has :accuracy) || myInfo.accuracy == null) ? Position.QUALITY_GOOD : myInfo.accuracy;
		if (myAccuracy > Position.QUALITY_LAST_KNOWN && myInfo.position != null) {
//        var info = Position.getInfo();
//	myInfo.position = new Position.Location( {:latitude => 53.3225, :longitude => -2.6454, :format => :degrees} );
//	myInfo.position = new Position.Location( {:latitude => 54.6001, :longitude => -3.1329, :format => :degrees} );

			var declination = mWMM.E0000(myInfo.position, Time.now());

			mDec = declination.format("%.2f");
	        Storage.setValue("declination", mDec);

	        dc.drawText(px, mCoords[1], mCoords[2], mDec, Graphics.TEXT_JUSTIFY_CENTER);
			var fh = dc.getFontHeight(mCoords[2]);
			var ew = "(" + ((declination < 0) ? "West" : "East") + ")";
   		    dc.drawText(px, mCoords[1]+fh, Graphics.FONT_LARGE, ew, Graphics.TEXT_JUSTIFY_CENTER);
		} else {
    	    dc.drawText(px, mCoords[1], Graphics.FONT_LARGE, "Acquiring GPS", Graphics.TEXT_JUSTIFY_CENTER);
		}

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
}

(:glance)
class MagneticDeclinationGlanceView extends WatchUi.GlanceView {

	function initialize() {
		GlanceView.initialize();
	}
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
		dc.clear();
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);

		var width = dc.getWidth();
		var str1 =  " Magnetic";
		var str1Alt =  " Mag.";
		var str2 = " Declination";
		var str = null;
		var tw = 0;
		var dec = Storage.getValue("declination");
		if (dec != null) {
			str = str1Alt + str2 + ": " + dec + "°";

			tw = dc.getTextWidthInPixels(str, Graphics.FONT_XTINY);
			if (tw > width) {
				str = str1 + str2;
			}

		} else {
			str = str1 + str2;
		}

		tw = dc.getTextWidthInPixels(str, Graphics.FONT_XTINY);
		if (tw > width) {
			str = str1Alt + str2;
		}
		dc.drawText(0, 20, Graphics.FONT_XTINY, str, Graphics.TEXT_JUSTIFY_LEFT);
	}

}