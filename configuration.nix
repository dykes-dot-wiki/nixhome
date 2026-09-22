{ config, pkgs, lib, inputs, ... }:
let
	home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
	"${home-manager}/nixos"
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixhome"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."dykewiki" = {
    isNormalUser = true;
    description = "DykeWiki";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };
  
  home-manager = {
  	extraSpecialArgs = { inherit inputs;};
	users = {
		"dykewiki" = import ./home.nix;
		};
	backupFileExtension = "bak";
	};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

   environment.systemPackages = with pkgs; [
	vim
	microfetch
	git
	gh	
	cifs-utils
   ];

nix = {

	settings = { 
		experimental-features = ["nix-command" "flakes"];
		auto-optimise-store = true;
		};
	optimise.automatic = true;
	};
	
environment = {
	variables = {
		SHELL = "fish";
		};
	};

programs = {
	htop = {
		enable = true;
		};
	fish = {
		enable = true;
		interactiveShellInit = "microfetch";
		shellAliases = {
			build = "sudo nixos-rebuild switch -I nixos-config=/home/dykewiki/nixhome/configuration.nix";
		};

		shellAbbrs = {};
		};
	neovim = {
		enable = true;
		viAlias = true;
		vimAlias = true;
		defaultEditor = true;
		};
	nh = {
		enable = true;
		clean = {
			enable = true;
			dates = "weekly";
			extraArgs = "--keep-since 7d --keep 5";
			};
		};
	};

 
 services = {
	openssh = {
		enable = true;
		ports = [6969];
		openFirewall = true;
	};
	journald.extraConfig = ''
		SystemMaxUse=100M
		RuntimeMaxUse=50M
		SystemMaxFileSize=50M
	'';
	radicale = {
		enable = true;
		settings = {
			server  = {
				hosts = [ "0.0.0.0:5232"];
			};
			auth = {
				type = "htpasswd";
				htpasswd_encryption = "bcrypt";
				htpasswd_filename = "/etc/radicale/users";
			};
		};
	};
	yarr = {
		enable = true;
		authFilePath = "/etc/nixos/rss-secrets";
		};
	
	homepage-dashboard = {
		enable = false;
	};

	};



 security.sudo.wheelNeedsPassword = false;

 fileSystems."/home/dykewiki/NAS" = {
	device = "//192.168.0.107/nas-share";
	fsType = "cifs";
	options = let
	automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
	in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100" "nofail"];
 };
 
  # Open ports in the firewall.
  networking = {
  	firewall = {
	enable = true;
	allowedTCPPorts = [ 
  			4200
			4000
			5232
			6969
			7070
			];
	};
  };
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "26.05"; # Did you read the comment?

}
