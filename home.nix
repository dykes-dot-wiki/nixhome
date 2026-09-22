{ config, pkgs, lib, inputs, ... }:

{
	home.username = "dykewiki";
	home.homeDirectory = "/home/dykewiki";
	home.stateVersion = "26.05";
	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		fishPlugins.tide
		fishPlugins.sponge
		fishPlugins.puffer
		fishPlugins.fzf-fish
		fishPlugins.fish-you-should-use
		fishPlugins.fish-bd
		fishPlugins.colored-man-pages
	];

	programs = {
		neovim = {
			enable = true;
			viAlias = true;
			vimAlias = true;
			defaultEditor = true;
			plugins = with pkgs.vimPlugins; [
				lazy-nvim
				nvim-treesitter
				auto-pairs
				ale
				nvim-treesitter-parsers.nix
			];
		};
		superfile = {
			enable = true;
		};

		lazygit = {
			enable = true;
			enableFishIntegration = true;
		};

		fzf = {
			enable = true;
			enableFishIntegration = true;
		};

		zoxide = {
			enable = true;
			enableFishIntegration = true;
			options = [
				"--cmd cd"
			];
		};

		bat = {
			enable = true;
			extraPackages = with pkgs.bat-extras; [
			batdiff
			batman
			batgrep
			batwatch
			prettybat
			];
		};

		fd = {
			enable = true;
			hidden  = true;
			ignores = [
				".git/"
				"*.bak"
			];
		};

		eza = {
			enable = true;
			enableFishIntegration = true;
			colors = "always";
			icons = "always";
			git = true;
		};
	};
}
