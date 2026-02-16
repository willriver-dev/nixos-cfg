{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.fish.enable = true;

  # We require this because we use lazy.nvim against the best wishes
  # a pure Nix system so this lets those unpatched binaries run.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  users.users.thangha = {
    isNormalUser = true;
    home = "/home/thangha";
    extraGroups = [ "docker" "lxd" "wheel" ];
    shell = pkgs.fish;
    # TODO: Set your own password with: mkpasswd -m sha-512
    # Or use initialPassword = "yourpassword"; for first login
    hashedPassword = "$6$p5nPhz3G6k$6yCK0m3Oglcj4ZkUXwbjrG403LBZkfNwlhgrQAqOospGJXJZ27dI84CbIYBNsTgsoH650C1EBsbCKesSVPSpB1";
    # TODO: Add your own SSH public key(s) here
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAA... your-key-here"
    # ];
  };
}
