{
  image = "b4bz/homer:latest";

  environment = {
    "TZ" = "America/New_York";
  };

  user = "root:root";

  #volumes = [
  #  "/home/USER/homer/assets:/www/assets"
  #];

  extraOptions = [
    "--pull=newer" # Pull if the image on the registry is newer than the one in the local containers storage
    "--name=homer"
    "--hostname=homer"
    "--network=net_macvlan"
    #"--ip=IP"
    #"--mac-address=MAC"
  ];
}
