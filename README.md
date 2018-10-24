# SuperStarFighter
Scenes and actors (with basic animation and FSM) templates. Menu>Game>Victory. Written in Godot

## Content
This template is composed by: 

- addons: Folder in which are contained [FSM](https://github.com/kubecz3k/FiniteStateMachine) and [tiled-importer](https://github.com/vnen/godot-tiled-importer) plugins 
- assets: Folder where there are assets for the scenes, in particular assets for the default theme:
  - textures: contains texture for blocks and panels and labels
  - utilities: contains fonts and frames
- characters: Folder where there are the scenes of a generic character, will handle FSM and animation
- screens: Folder containing generic scenes, all inherited from basic_screen

## Resources used and aknowledgement

Fonts: [Londrina](https://www.dafont.com/it/londrina.font?l[]=10&l[]=1)
Frame Texture: [Freepik](https://www.freepik.com/free-photos-vectors/frame)
Scenes structure and theme: inspired by [PigDev](https://pigdev.itch.io/)
Character structure: inspired by [GDquest](https://www.youtube.com/channelavalaible/UCxboW7x0jZqFdvMdCFKTMsQ)

## Sounds
- https://freesound.org/people/aidave/downloaded_sounds/
- https://v-play.net/game-resources/16-sites-featuring-free-game-sounds
- https://freesound.org/people/uso_sketch/sounds/443865/
- https://freesound.org/people/GameAudio/packs/13940/
- https://freesound.org/people/jalastram/packs/17801/

### Utility script
https://superuser.com/questions/373889/batch-convert-wav-to-mp3-and-ogg
From a Unix-like (Linux, OSX, etc) commandline, ffmpeg can be used like this:

`for f in *.wav; do ffmpeg -i "$f" -c:a libmp3lame -q:a 2 "${f/%wav/mp3}" -c:a libvorbis -q:a 4 "${f/%wav/ogg}"; done`

## Images
- dashedcircle: found [here](https://www.flaticon.com/free-icon/dashed-circle_105113)
- keyboard icons: made by "Nicolae Berbece" (also known as Xelu) - founder of "Those Awesome Guys" - nick@thoseawesomeguys.com
- planets: [here](https://opengameart.org/content/big-space-gun-free-pixel-art-graphics-for-your-game-0)
- tiny planets : [here](https://opengameart.org/content/pixel-planets)
- icon lock : [here](https://icons8.com/icon/set/lock/all)
- icons got from [icons8](https://icons8.com) website
- other planets: https://opengameart.org/content/2d-space-shooter-assets
- Kenneys for some aliens

## Techniques
### Steering
- Demo on https://youtu.be/J9RUTUvZvy0
- https://natureofcode.com/book
