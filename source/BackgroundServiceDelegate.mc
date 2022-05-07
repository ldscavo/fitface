using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Application.Properties as Properties;
using Toybox.Position as Positon;

(:background)
class BackgroundServiceDelegate extends Toybox.System.ServiceDelegate {

	function initialize() {
		Sys.ServiceDelegate.initialize();
	}
	  
  function onTemporalEvent() {
    if (Properties.getValue("SecondaryDisplay") != 1) {
      Sys.println("Weather is disabled");
      return;
    }

    Sys.println("Creating the http request...");

    var units = Properties.getValue("Units") == 0
      ? "metric"
      : "imperial";

    var url = "https://api.openweathermap.org/data/2.5/weather";
    var apiKey = Properties.getValue("ApiKey");
    var location = Position.getInfo().position;

    if (location == null) {
      Sys.println("Location is null - cannot continue");
      return;
    }

    var coords = location.toDegrees();

    Sys.println("latitude: " + coords[0]);
    Sys.println("longitude: " + coords[1]);

    var params = {
      "appId" => apiKey,
      "units" => units,
      "lat" => coords[0],
      "lon" => coords[1]
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
    
    var response =
      responseCode == 200
        ? data["main"]["temp"]
        : -1;

    Sys.println("response: " + response);

    var formattedResponse = Properties.getValue("Units") == 0
      ? response.toDouble().format("%.1f") + "°C"
      : response.toNumber().toString() + "°F";

    Background.exit(formattedResponse);
  }  

}