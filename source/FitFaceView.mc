using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class FitFaceView extends Ui.WatchFace {
    function getTimeString() {
        var timeFormat = "$1$:$2$";
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour;
        if (!Sys.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (App.getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        return Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
    }
    
    function getDateString() {
        var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateFormat = "$1$ $2$ $3$";
        
        return Lang.format(dateFormat, [date.day_of_week, date.month, date.day]);
    }
    
    function getSteps() {
        var steps = ActivityMonitor.getInfo().steps;
        if (steps == null) {
            steps = 0;
        }
        
        return steps;
    }
    
    function getStepGoal() {
        var stepGoal = ActivityMonitor.getInfo().stepGoal;
        if (stepGoal == null) {
            stepGoal = 0;
        }
        
        return stepGoal;
    }
    
    function getStepString() {
        var steps = getSteps();
        
        return Lang.format("$1$ Steps", [steps]);
    }
    
    function updateStepsDisplay() {
        var stepsString = getStepString();
        var font = Ui.loadResource(Rez.Fonts.Carlito);
        
        var stepsView = View.findDrawableById("StepsLabel");
        stepsView.setFont(font);
        stepsView.setColor(0xffaaaa);
        stepsView.setText(stepsString);
    }
    
    function updateTimeDisplay() {
        var timeString = getTimeString();
        var font = Ui.loadResource(Rez.Fonts.Carlito_Large);
        
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setFont(font);
        timeView.setColor(0xffffff);
        timeView.setText(timeString);
    }
    
    function updateDateDisplay() {
        var dateString = getDateString();              
        var font = Ui.loadResource(Rez.Fonts.Carlito);
        
        var dateView = View.findDrawableById("DateLabel");
        dateView.setFont(font);
        dateView.setColor(0xffffff);
        dateView.setText(dateString);
    }
    
    function getHeartRate() {
        return 185;
    }
    
    function getHeartRateString() {
        return Lang.format("$1$", [getHeartRate()]);
    }
    
    function updateHeartRateDisplay() {
        var heartRateString = getHeartRateString();              
        var font = Ui.loadResource(Rez.Fonts.Carlito);
        
        var heartRateView = View.findDrawableById("HeartRateLabel");
        heartRateView.setFont(font);
        heartRateView.setColor(0xffaaaa);
        heartRateView.setText(heartRateString);
    }
    
    function updateTextFields() {
        updateTimeDisplay();
        updateDateDisplay(); 
        updateStepsDisplay();
        updateHeartRateDisplay();
    }
    
    function getArcAngle() {
        var steps = getSteps();
        var stepGoal = getStepGoal();
        
        var arc_angle = 360;
        if (stepGoal > steps) {
            arc_angle = (360 * steps) / stepGoal;
        }
        
        arc_angle = 90 - arc_angle;
        if (arc_angle < 0) {
            arc_angle += 360;
        }
        
        return arc_angle;
    }
        
    function drawStepArc(dc) {
        var height = dc.getHeight();
        var width = dc.getWidth();
        
        dc.setColor(0xaaaaaa, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        
        dc.drawCircle(width/2, height/2, (width/2)-6);
        
        var steps = getSteps();
        var angle = getArcAngle();
                        
        dc.setColor(0xffaa00, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(12);
        if (steps > 0) {
            dc.drawArc(width/2, height/2, (width/2)-5, dc.ARC_CLOCKWISE, 90, angle);
        }        
    }
    
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        var layout = Rez.Layouts.WatchFace(dc);
        setLayout(layout);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // update time, date, and step count    
        updateTextFields();
        
        // Call the parent onUpdate function to redraw the layout        
        View.onUpdate(dc);
        
        // Draw the arc showing progress towards the step goal
        drawStepArc(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        updateStepsDisplay();
        updateHeartRateDisplay();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
