using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time.Gregorian;

class AlkalicFaceView extends WatchUi.WatchFace {

	hidden var m_height_by_2;
	hidden var m_width_by_2;
	hidden var m_pi;
    hidden var m_hour_hand_length;
	hidden var m_start_of_tip;
	hidden var m_start_of_tip_minute;
	
    function initialize() {
        WatchFace.initialize();
		m_pi = 3.141592654;

		m_start_of_tip = 0.8;
		m_hour_hand_length = 0.65;
		m_start_of_tip_minute = 1 - m_hour_hand_length*(1-m_start_of_tip);
		
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
		m_width_by_2=dc.getWidth()/2.0;
		m_height_by_2=dc.getHeight()/2.0;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view (once per minute)
    function onUpdate(dc) {
       	dc.clearClip();
    	System.println("full");
        var clockTime = System.getClockTime();

		var info = ActivityMonitor.getInfo();
		
        View.findDrawableById("StepsLabel").setText(info.steps.format("%1d"));
        
		var message_label = View.findDrawableById("MsgLabel");
		var notification_text = "--";
		var phone_connected = System.getDeviceSettings().phoneConnected;
		if (phone_connected)
		{
			var notification_count = System.getDeviceSettings().notificationCount;
			if (notification_count>2) {
				message_label.setColor(Graphics.COLOR_RED);
			}
			else if (notification_count>0){
				message_label.setColor(Graphics.COLOR_ORANGE);
			}
			else {
				message_label.setColor(Graphics.COLOR_BLUE);
			}
			notification_text = notification_count.format("%2d");
		}
		else {
			message_label.setColor(Graphics.COLOR_BLUE);
		}
	    message_label.setText(notification_text);
	            
        var battery = System.getSystemStats().battery;
        var batteryLabel = View.findDrawableById("BatteryLabel");
        if (battery < 10) {
        	batteryLabel.setColor(Graphics.COLOR_RED);        	
        }
        else if (battery < 20) {
        	batteryLabel.setColor(Graphics.COLOR_ORANGE);        	
		} else {
	        	batteryLabel.setColor(Graphics.COLOR_GREEN);        	
		}	        
        batteryLabel.setText(battery.format("%5.2f"));

	    var date_info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$ $2$", [date_info.day_of_week, date_info.day]);
        View.findDrawableById("DateLabel").setText(dateStr);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

		// analog hands
		var hour = clockTime.hour;
        if (hour > 12) {
            hour = hour - 12;
        }
        var min = clockTime.min;

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		drawPointedHand(dc, m_width_by_2, m_height_by_2, (hour+min/60.0)/6.0 * m_pi, m_hour_hand_length*m_width_by_2, 12, m_start_of_tip);
		drawPointedHand(dc, m_width_by_2, m_height_by_2, min/30.0 * m_pi, m_width_by_2, 12, m_start_of_tip_minute);

    }

    function onPartialUpdate(dc)
    {
    }    

	function drawPointedHand(dc, cx, cy, angle, length, width, ratio2)
	{
		var over_shoot = 15;
	    var coords = [[-1, over_shoot], [-width/2, over_shoot], [-width/2, -length*ratio2], [0, -length],
	    			  [width/2, -length*ratio2], [width/2, over_shoot], [1, over_shoot]];
	    drawHand(dc, cx, cy, angle, coords);
	}

	function drawHand(dc, cx, cy, angle, coords)
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
	
		for (var i = 0; i < coords.size(); i += 1)
	    {
	        var x = (coords[i][0] * cos) - (coords[i][1] * sin);
	        var y = (coords[i][0] * sin) + (coords[i][1] * cos);
			coords[i] = [ cx+x, cy+y];
	    }
	    dc.fillPolygon(coords);
	}    
    	

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    
    }
}
