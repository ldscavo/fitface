using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Time as Time;
using Toybox.System as Sys;
using Toybox.Background;

class FitFaceApp extends App.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state) {}

  // onStop() is called when your application is exiting
  function onStop(state) {}

  // Return the initial view of your application here
  function getInitialView() {
    if(Toybox.System has :ServiceDelegate) {
      Background.registerForTemporalEvent(new Time.Duration(5 * 60));
    }    
    return [ new FitFaceView() ];
  }

  function getServiceDelegate(){
    return [new BackgroundServiceDelegate()];
  }

  function onBackgroundData(data) {
    Sys.println("onBackgroundData="+data);
    Ui.requestUpdate();
  }   

  // New app settings have been received so trigger a UI update
  function onSettingsChanged() {
    Ui.requestUpdate();
  }
}