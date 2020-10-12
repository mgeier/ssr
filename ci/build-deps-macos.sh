#!/usr/bin/env bash

set -euo pipefail

git clone git://github.com/zaphoyd/websocketpp.git
cd websocketpp
mkdir build
cd build
cmake ..
make
sudo make install
cd ..
cd ..

git clone git://github.com/hoene/libmysofa.git
cd libmysofa
cd build
cmake ..
make
sudo make install
cd ..
cd ..

sudo cpan Parse::RecDescent

git clone https://github.com/vrpn/vrpn.git
cd vrpn
mkdir build
cd build
cmake -DVRPN_BUILD_JAVA=OFF ..
make
sudo make install
cd ..
cd ..
