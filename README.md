# LibItemCache-1.1
World of Warcraft item caching simplified

## The problem
It's common for _World of Warcraft addons_ to require information of the items the player possesses, wether it is from the inventory, bank, vault, or even from other characters he owns. The problem is that, to be able to access such information, you can't rely on the server, as it only provides it on certain conditions.

The solution sounds simple: _addons_ much cache the information when it is available for later use. But, as addons can't share recorded databases, each add-on must implement its own caching system, or to require the installation  of an already existent one.

Both of them have flaws. For the first, users may end up having several copies of the same data running on their RAM (bad, but not awful) and each developer must code and maintain his own system (OH NO!). For the second, users must download the required dependency separately (hey, users don't have time for that!).

## The solution
LibItemCache provides a simple solution: it handles all the access to information for the developer. When the data is available from the server, it retrieves it that way. When not, it retrieves it from a caching system. Support for other caching systems is easy and simple to implement.

![LibItemCache explained](https://github.com/Jaliborc/LibItemCache-1.0/wiki/Graph.png)

_* Account thieves usually return no information, as they empty banks, vaults and inventories._

## An API on steroids
So, how do you use it? Putting it simple, you use it as if you were simply retrieving the information from the server, not having to regard wether it is available online or cached.

For instance, the method `LibItemCache:GetItemInfo(player, bag, slot)` works exactly like the standard method `GetItemInfo(bag, slot)`, except it allows you to select the player by it's name (if not provided defaults to the current one) and works even if the information is not available from the server (returning an extra final argument, _isCached_, as `true`). Furthermore, if `"vault"` is provided as the _bag_ argument, then the method will behave like `GetVoidItemInfo`.

See the [full API list here](https://github.com/Jaliborc/LibItemCache-1.1/wiki/API-List).

## But you still have to depend on other caching systems
For that purpose you could use BagBrother, a simple caching system: it only caches the information when available, and automatically disables itself when another cache system supported by LibItemCache is available.
Simply include it in your add-on.

## Supporting other caches
Support is implemented by making a _wrapper_ file for each caching system. Looking at the existing _wrappers_ code (Caches/*.lua) should be more the enough to understand how to make new ones. If you need extra help, feel free to contact me.
