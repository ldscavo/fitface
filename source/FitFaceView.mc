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
        var steps = ActivityMonitor.History.steps;
        if (steps == null) {
            steps = 0;
        }
        
        return steps;
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
        stepsView.setText(stepsString);
    }
    
    function updateTimeDisplay() {
        var timeString = getTimeString();
        var font = Ui.loadResource(Rez.Fonts.Carlito_Large);
        
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setFont(font);
        timeView.setText(timeString);
    }
    
    function updateDateDisplay() {
        var dateString = getDateString();                
        var font = Ui.loadResource(Rez.Fonts.Carlito);
        
        var dateView = View.findDrawableById("DateLabel");
        dateView.setFont(font);
        dateView.setText(dateString);
    }
    
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {     
        updateTimeDisplay();
        updateDateDisplay(); 
        updateStepsDisplay();       

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
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
