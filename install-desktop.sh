#!/bin/sh

# done manually for now
#   * install chrome
#   * keyboard layout > options > key sequence to kill x server

# remove the default Ubuntu cruft
rmdir Documents/ Music/ Public/ Pictures/ Templates/ Videos/ examples.desktop

# fix some bad decisions that Ubuntu made
sudo apt-get install aptitude
sudo apt-get remove appmenu-gtk3 appmenu-gtk appmenu-qt

# install some things we're going to want
sudo aptitude install \
    build-essential python-dev libxslt-dev \
    python-pip python-virtualenv virtualenvwrapper python-boto \
    git mercurial subversion \
    nautilus-dropbox terminator meld gitg \
    ack-grep tree s3cmd mosh \
    mongodb vim-nox exuberant-ctags \
    gcolor2 inkscape
sudo pip install fabric ipython sphinx flake8

# XMonad stuff
sudo apt-get install \
    xmonad gnome-panel notification-daemon libdbus-1-dev cabal-install \
    autoconf libglib2.0-dev libdbus-glib-1-dev libpanel-applet-4-dev

cabal update
cabal unpack DBus
cd Dbus-0.4
vim DBus/Internal.hsc  # replace Exception with OldException
vim DBus/Message.hsc   # prepend Foreign. to unsafePerformIO
cabal configure
cabal build
sudo cabal install

git clone https://github.com/alexkay/xmonad-log-applet
cd xmonad-log-applet
./autogen.sh  # let this fail?
./configure --with-panel=gnome3
make
sudo make install
