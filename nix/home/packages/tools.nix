# admin devops profile defines tools for administrating databases

{ config, pkgs, ... }:

{
  imports = [ ../base.nix ];

  config = {
    home.packages = with pkgs; [
      # database
      sqlite
      mysql57
      #mysql-workbench
      postgresql
      redis
      etcdctl
      vault

      # storage
      s3fs
      minio-client
      gzrt # gzip recovery

      # remote
      rdesktop
      gtk-vnc
      openvpn
      remmina

      # crypto
      mkpasswd
      pwgen
      apacheHttpd # for htpasswd
      xca
      cfssl

      # networking
      ncftp
      curl_unix_socket
      socat
      bmon
      tcptrack
      stunnel
      wireshark
      ack # grep-like text finder
      act # run github actions locally
      awscli # aws cli
      bat # better version of `cat`
      bottom # fancy version of `top` with ASCII graphs
      calc # calculator
      coreutils # gnu!
      cowsay # fun!
      curl
      dos2unix # convert CRLF <--> CR
      du-dust # fancy version of `du`
      exa # better version of `ls`
      fd # fancy version of `find`
      geoip # find where an IP address comes from
      git-crypt # secrets in git
      gnupg
      gnupg
      gzip
      htop # fancy version of `top`
      hyperfine # benchmarking tool
      irssi # irc client
      jq # sed for json data
      less # less is more
      lftp # commandline ftp
      links # text mode web browser
      lynx # another text mode web browser
      mosh # wrapper for `ssh` that better and not dropping connections
      ncdu
      niv # easy dependency management for nix projects
      nix-prefetch-git
      nmap
      parallel # runs commands in parallel
      procs # fancy version of `ps`
      ripgrep # better version of `grep`
      tealdeer # rust implementation of `tldr`
      thefuck
      tree
      unrar # extract RAR archives
      watch # perv!
      wget
      xz # extract XZ archives
      yubikey-personalization
    ];
  };
}
