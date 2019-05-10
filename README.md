# Region Teleport

Auto configured region teleports network.

This permits to simply add locations inside a region.
* When the avatar sits, he gets a menu of available locations (where other telepads are rezzed).
* When selecting a location, it is moved to it.

If the user dismiss the menu, he can get it again by touching the telepad.

## Setup

Rez a telepad or drop the `auto-telepad` script inside an object (without description).

A dialog asks the name of this location. The telepad is ready to work. If you missed the dialog, touch the telepad.

Rez another telepad somewhere else and do the same. Be sure the location name is not used by another telepad, or there will be a conflict.

You can rotate the telepad to change the direction to look at when arriving.

## Network updates

Each telepad sends its information to other telepads each **2 minutes**. So if you move, rotate or delete a telepad, others will see the change within 2 minutes. To force an update, reset the scripts of the telepad you modified.

If a telepad does not receive the update from another telepad within **5 minutes**, it deletes this location (automatic update for delete).

## Animation

If you want to play an animation when the avatar sits, drop an animation in the telepad, it will use it.

## Sounds

You can get sounds playing by dropping sound files with special names in the telepad:
* `menu` when the user gets the menu
* `tp` when the teleporting begins
