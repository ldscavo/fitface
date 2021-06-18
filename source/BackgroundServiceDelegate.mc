using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comm;

(:background)
class BackgroundServiceDelegate extends Toybox.System.ServiceDelegate {

	function initialize() {
		Sys.ServiceDelegate.initialize();
	}
	  
  function onTemporalEvent() {
    Sys.println("Creating the http request...");

    var url = "https://api.openweathermap.org/data/2.5/weather";
    var apiKey = "<API Key>";
    var params = {
      "appId" => apiKey,
      "units" => "metric",
      "lat" => 40.4406,
      "lon" => -79.9959
    };
    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_GET,
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    Sys.println("Sending the http request!");

    Comm.makeWebRequest(url, params, options, method(:onWeatherReceive));
    
    Sys.println("Sent the http request!");
  }

  function onWeatherReceive(responseCode, data) {
    Sys.println("Got a response!");
    
    var temp = data["main"]["temp"];
    Sys.println("temp is " + temp);

    Background.exit(responseCode);
  }  

}