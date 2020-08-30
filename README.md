SharpShooter
===

A utility addon for Hunters for World of Warcraft Classic.

Introduction
---

SharpShooter is intended to help you with your rotation, as well as warn you not to ruin it for others.

**Check note at the bottom on development status before using!**


Features:

- Tells you whether your target has a Hunter's Mark, be it yours or anyone elses, so you don't have to search through the list of buffs on you target.
- Lets you know if Serpent Sting should be cast on the target. If your target already has Serpent Sting or another sting from you, it won't suggest Serpent Sting.
- Keeps track of the cooldowns of your Aimed Shot and Multi-Shot.
- Analyzes your environment and warns you when you single shots or Multi-Shots can cancel important effects, such as Polymorph.
- Warns you when a party or raid member may take friendly fire from your single shots of Multi-Shots.


Polymorph & friendly fire
---

### How it works

The combat log, party members, raid members and your target are constantly scraped for information. For example, if someone close to you casts a Polymorph on an enemy target, you get a warning on Multi-Shot as long as the Polymorph is active. Similarly, if a raid member is attackable, you get a warning on Multi-Shot. If you are targeting an enemy that is polymorphed, you are also warned for single target shots.

### Accuracy

Unfortunately, the WoW API is limited in what it can do, so it's not possible to exactly tell whether your Multi-Shot will wreak havoc.

It is possible that, for example:
- a polymorphed target picked up by the combat log is not in your range,
- you are facing away from an attackable raid member,
- or the warning remains active for the full duration of the effect if you leave the combat environment.

As a result, you get more warnings than you should. What this really means is that as long as there are no warnings, you can shoot around all you want. If there are warnings however, feel free to ignore them as long as you have taken a careful look at the situation, or just follow them to stay safe.


Other classes
---

This addon has limited use for other classes, so by default it disables itself. The polymorph and friendly fire features can be useful with other classes, for spells like Arcane Explosion or Chain Lightning. If you want that, you can always enable the addon bar in the options, however, the UI is not tuned for this usage at all. If there is enough interest, I may be able to come up with something.

Development Status
---

The code is very fresh and the addon is pretty rough at the moment, so expect problems.

The mark, sting and cooldown tracking feature works quite well, so that can be relied upon.

The polymorph and friendly fire features are not well-tested, and the list of polymorph effects checked for is not exhaustive. Because of this, you should not rely on this feature: you are not safe, even if you don't get a warning.

The UI is something that needs tuning, as the first step was to get the functionality working. I plan to remove icons for unavailable Hunter spells, add decent backgrounds, and perhaps animations and cooldown trackers.


License
---
