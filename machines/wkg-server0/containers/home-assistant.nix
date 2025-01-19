{
      autoStart = true;
      ports = [ "8123:8123" ];
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "America/New_York";
      pull = "always";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [ 
	"--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        # "--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];
}