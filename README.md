# pdParticles

[![Lua Version](https://img.shields.io/badge/Lua-5.4-yellowgreen)](https://lua.org) [![Toybox Compatible](https://img.shields.io/badge/toybox.py-compatible-brightgreen)](https://toyboxpy.io) [![Latest Version](https://img.shields.io/github/v/tag/PossiblyAxolotl/pdParticles)](https://github.com/PossiblyAxolotl/pdParticles/tags)

pdParticles is a free Playdate particle library created by [PossiblyAxolotl](https://www.youtube.com/PossiblyAxolotl).

![playdate-20230131-144652](https://user-images.githubusercontent.com/76883695/215882419-0d358b40-1236-477b-a207-c5ba053922fd.gif)

You can use pdParticles to draw circles, basic shapes, and custom sprites.

![playdate-20230131-145305](https://user-images.githubusercontent.com/76883695/215882184-feb815a5-5964-432c-a96d-5274c46adb32.gif)

![playdate-20230201-000033](https://user-images.githubusercontent.com/76883695/215965042-7c7b5622-e4b9-460a-95e2-3b5b875a8ff0.gif)

![playdate-20230201-183243](https://user-images.githubusercontent.com/76883695/216210932-96f53f97-a7ac-477d-9776-eb9704093f89.gif)

Check out the [wiki](https://github.com/PossiblyAxolotl/pdParticles/wiki) to see how to get started and use the library. 

#### Installing using toybox.py

You can add it to your **Playdate** project by installing [**toybox.py**](https://toyboxpy.io), going to your project folder in a Terminal window and typing:

```console
toybox add pdParticles
toybox update
```

Then, if your code is in the `source` folder, just import the following:

```lua
import '../toyboxes/toyboxes.lua'
```

#### Manual installation
Download the newest version of pdParticles from this repo.

Add pdParticles.lua to the same directory as your main.lua file.

In your main.lua file add:
```lua
import "CoreLibs/graphics"
import "coreLibs/object"
import "pdParticles"
```

More info on the [Getting Started](https://github.com/PossiblyAxolotl/pdParticles/wiki/Getting-Started#setup) page.
#### Donating

If you're interested in donating to me you can do so on my [itch.io](https://possiblyaxolotl.itch.io/pdparticles).
