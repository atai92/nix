# Instructions

```
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# clone this directory and cd into it
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake $PWD
```
