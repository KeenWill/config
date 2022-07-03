{ options, config, lib, ... }:

with lib;

{

  options.modules.home = {
    homeConfig = mkOption {
      type = options.home-manager.users.type.functor.wrapped;
      default = {};
      description = "Home-manager configuration to be used for the user";
    };
  };

#   config = {
#     home-manager.users."${config.modules.home.homeConfig.userName}" =
#       mkAliasDefinitions options.mine.homeConfig;
#   };

}