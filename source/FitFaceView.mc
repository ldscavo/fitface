using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class FitFaceView extends Ui.WatchFace {
  private var _settings as Lang.DeviceSettings;
  private var _fontRegular as FontReference;
  private var _fontLarge as FontReference;

  function initialize() {
    _settings = Sys.getDeviceSettings();
    _fontRegular = Ui.loadResource(Rez.Fonts.Carlito);
    _fontLarge = Ui.loadResource(Rez.Fonts.Carlito_Large);

    WatchFace.initialize();
  }

  //////////////////////////////////

  function formatHour(hour) {
    return (!_settings.is24Hour && hour > 12)
      ? hour - 12
      : (hour != 0) ? hour : 12;
  }
      
  function getSteps() {
    var steps = ActivityMonitor.getInfo().steps;
    
    return steps != null ? steps : 0;
  }
  
  function getStepGoal() {
    var stepGoal = ActivityMonitor.getInfo().stepGoal;

    return stepGoal != null ? stepGoal : 0;
  }
  
  function getDistance() {
    var distance = ActivityMonitor.getInfo().distance;
    
    return _settings.distanceUnits == System.UNIT_METRIC
      ? distance / 100000
      : distance * 0.0000062137;
  }

  //////////////////////////////////

  function getTimeString() {
    var clockTime = Sys.getClockTime();
    
    return Lang.format("$1$:$2$", [formatHour(clockTime.hour), clockTime.min.format("%02d")]);
  }
  
  function getDateString() {
    var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    
    return Lang.format("$1$ $2$ $3$", [date.day_of_week, date.month, date.day]);
  }

  function getStepString() {
    return Lang.format("$1$ Steps", [getSteps()]);
  }

  function getDistanceString() {
    var formattedDistance = getDistance().toDouble().format("%.1f");
    var unit = _settings.distanceUnits == System.UNIT_METRIC ? "km" : "mi";
    
    return Lang.format("$1$ $2$", [formattedDistance, unit]);
  }

  //////////////////////////////////

  function setDrawableData(drawable, font, color, text) {
    drawable.setFont(font);
    drawable.setColor(color);
    drawable.setText(text);
  }
  
  function updateStepsDisplay() {
    setDrawableData(View.findDrawableById("StepsLabel"), _fontRegular, 0xffaaaa, getStepString());
  }
  
  function updateTimeDisplay() {
    setDrawableData(View.findDrawableById("TimeLabel"), _fontLarge, 0xffffff, getTimeString());
  }
  
  function updateDateDisplay() {
    setDrawableData(View.findDrawableById("DateLabel"), _fontRegular, 0xffffff, getDateString());
  }

  function updateDistanceDisplay() {
    setDrawableData(View.findDrawableById("DistanceLabel"), _fontRegular, 0xffaaaa, getDistanceString());
  }
  
  function updateTextFields() {
    updateTimeDisplay();
    updateDateDisplay(); 
    updateStepsDisplay();
    updateDistanceDisplay();
  }

  //////////////////////////////////
  
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
    
    dc.drawCircle(width/2, height/2, (width/2)-7);
    
    var steps = getSteps();
    var angle = getArcAngle();
                    
    dc.setColor(0xffaa00, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(14);
    if (steps > 0) {
      dc.drawArc(width/2, height/2, (width/2)-7, dc.ARC_CLOCKWISE, 90, angle);
    }        
  }
    
  // Load your resources here
  function onLayout(dc) {
    var layout = Rez.Layouts.WatchFace(dc);
    setLayout(layout);
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {}

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
  function onHide() {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    updateStepsDisplay();
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {}
}
