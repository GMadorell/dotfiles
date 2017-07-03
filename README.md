# Dotfiles

Hello! Welcome to where I store my configuration files!

## How to import the files

1. Clone the repo: `git clone https://github.com/GMadorell/dotfiles ~/.dotfiles`
2. Install [RCM](https://github.com/thoughtbot/rcm): `brew tap thoughtbot/formulae && brew install rcm`
3. Check what symlinks are going to be created: `rcls`
4. Create the symlinks: `rcup`

Some configuration files need extra work though!

### Jetbrains IDEs (IntelliJ, PyCharm, PhpStorm, Datagrip, etc)
Import the jars inside the ide `file -> import settings`

### Better touch tool
Import inside the program

### Iterm2
Thanks to: http://stratus3d.com/blog/2015/02/28/sync-iterm2-profile-with-dotfiles-repository/
```
# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.dotfiles/iterm2"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
```
