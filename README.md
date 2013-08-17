crafty.sh:
=========

original BASH project was just to keep my MC server up-to-date. Its scope changed so much that after I was done I wanted to rewrite it in python. 

USAGE:
 
$ ./minecraft_updater.sh -i "plugin_name"  <-- install new plugin

the script will search google and attempt to determine the location of the latest version on bukkit.org, download it into minecraft_home and unpack if needed. it will then restart MC in screen.

$ ./minecraft_updater.sh   <- This will update the Craftbukkit version and all plugins


crafty.py:
=========

This is a WIP to do the exact same thing in python.

