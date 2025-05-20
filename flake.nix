{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }:
    let
      inherit nixpkgs;

      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    rec {
      # default to linux
      devShells.x86_64-linux.default = devShells.x86_64-linux.linux;

      devShells.x86_64-linux.linux = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          ninja
          just
          cmake
          validatePkgConfig
          gcc
          wayland-scanner
          zenity
          libffi
          python313
        ];

        # runtime dependencies
        buildInputs = with pkgs; [
          vulkan-headers
          vulkan-loader
          libGL
          libusb1
          libayatana-appindicator
          libdrm
          mesa
          wayland
          wayland-protocols
          pipewire
          libpulseaudio
          alsa-lib
          dbus
          libxkbcommon
          xorg.libX11
          xorg.libXScrnSaver
          xorg.libXcursor
          xorg.libXext
          xorg.libXfixes
          xorg.libXi
          xorg.libXrandr
        ];

        # use Ninja generator by default
        CMAKE_GENERATOR = "Ninja";
      };
    };
}
