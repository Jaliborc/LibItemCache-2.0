# LibItemCache-2.0
LibItemCache is a library that allows you to query for inventory information of players and guilds, while keeping you abstracted from the source of the information. Internally, it checks whether the information should be queried from the server and, if not, it will search for compatible caches and request them the information.

It solves two major issues:
* Makes querying information about item possesions consistent independently of their location (inventory, void storage, etc) and their owners (players or guilds).
* Allows item databases to easly distribute their recorded information for other addons to use.

Interested? See the [Wiki](https://github.com/Jaliborc/LibItemCache-2.0/wiki) for more information
