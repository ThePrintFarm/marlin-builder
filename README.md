# Marlin Builder

This project consists of a re-usable workflow for Github Actions, and a set of configurations for Marlin 3d printer firmware. Currently the following vendors have at least 1 build with it's configuration
managed here. I try to maintain a current `stock` firmware, as well as any standard customizations such as bltouch.

- Creality Firmwares: [![Build Creality Weeklies](https://github.com/fuzzy/marlin-builder/actions/workflows/creality-weekly.yaml/badge.svg)](https://github.com/fuzzy/marlin-builder/actions/workflows/creality-weekly.yaml)
- Geeetech Firmwares: [![Build Geeetech Weeklies](https://github.com/fuzzy/marlin-builder/actions/workflows/geeetech-weekly.yaml/badge.svg)](https://github.com/fuzzy/marlin-builder/actions/workflows/geeetech-weekly.yaml)
- Kinroon Firmwares: [![Build Kingroon Weeklies](https://github.com/fuzzy/marlin-builder/actions/workflows/kingroon-weekly.yaml/badge.svg)](https://github.com/fuzzy/marlin-builder/actions/workflows/kingroon-weekly.yaml)

PR's are always welcome, as are isseues and comments.

## Weeklies

I have also added as a matter of pattern weekly scheduled builds for each vendor. This checks out the current Marlin source for each branch configured during build, so this will be a steady source of fresh
firmwares.

## Stuffs
