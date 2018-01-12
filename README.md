# LibItemCache-2.0 :floppy_disk:
LibItemCache is a library that allows you to query for inventory information of players and guilds, while keeping you abstracted from the source of the information. Internally, it checks whether the information should be queried from the server and, if not, it will search for compatible caches and request them the information.

It solves two major issues:
* Makes querying information about item possesions consistent independently of their location (inventory, void storage, etc) and their owners (players or guilds).
* Allows item databases to easly distribute their recorded information for other addons to use.


## Getting Started
* To learn how to use the library, see the [API](https://github.com/Jaliborc/LibItemCache-2.0/wiki/API).
* To learn how to expose your own cache to the library, see [Interface Protocol](https://github.com/Jaliborc/LibItemCache-2.0/wiki/Interface-Protocol).
