## v0.14.4a5 (2023-05-18)

### Fix

- improve versioning

## v0.14.4a4 (2023-05-18)

### Fix

- improve versioning

## v0.14.4a4 (2023-05-18)

### Fix

- improved commitizen config
- v tagformat

## 0.14.4a3 (2023-05-18)

### Fix

- adding cz changelog

## 0.14.4a2 (2023-05-18)

### Fix

- cleanup
- makefile updated
- tagformat updated
- added requirements and updated makefile
- fullscreen by default
- sync among versions
- commit for tag
- changelog and cz

## v0.14.1 (2023-05-17)

### Fix

- **controls**: Controls "kb1" now accepts SPACE and ENTER in addition to M as FIRE.
- **analytics**: remove gameanalytics old setup.

## v0.14.0 (2023-05-12)

## v0.12.2 (2023-05-12)

### Feat

- **analytics**: disclaimer and opt-in and opt-out
- **analytics**: first attempt to make some analytics

### Fix

- **analytics**: Added lifecycle api to handle events
- get correct game id and minigame id and card id
- **analytics**: disclaimer without info
- bug in first time
- **ui**: disclaimer background alignment
- **disclaimer**: only first time
- send analytics only if explicitly consent to
- revert change
- **analytics**: correct hostname
- **settings**: rename hostname.debug into hostname.local since it has sideseffects
- **analytics**: endpoint for api fixed
- **halloffame**: we should not add champion
- typo for champion_info definition
- **analytics**: added different id to the event
- **analytics**: kind of broken yet
- **analytics**: added debug_mode
- **analytics**: version added and improvements
- **analytics**: handling first request
- debug and build variables
- **analytics**: added first simple analytics. Potential breaking changes
- **save**: safeget when deck/session is not a valid entity

## v0.12.1 (2023-04-29)

### Fix

- **bump**: now correctly reset on bumping any version

## v0.12.0 (2023-04-21)

## v0.10.1 (2023-04-21)

### Feat

- **worlds**: flag are now displayed on completed worlds
- **worlds**: flag are now displayed on completed worlds
- **worlds**: Art and name for "oldcrown".
- **worlds**: Art and name for "oldcrown".
- **cpu**: Rocket the Crown Brain.
- **cpu**: Rocket the Crown Brain.
- **cpu**: homesick invaders cpu
- **cpu**: homesick invaders cpu
- **demo**: guard the bridge removed from future (temporarily)
- **demo**: guard the bridge removed from future (temporarily)
- **cpu**: diamond minefield brain
- **cpu**: diamond minefield brain
- **cpu**: diamond minefield basic brain
- **cpu**: diamond minefield basic brain
- **demo**: final world message
- **demo**: final world message
- **hall_of_fame**: hall of fame added to menu screen
- **hall_of_fame**: hall of fame added to menu screen
- **cpu**: diamond warfare brain
- **cpu**: diamond warfare brain
- **ui**: flag for compleated planes
- **ui**: flag for compleated planes
- **playlists**: alternative action world
- **playlists**: alternative action world
- **minigames**: diamond halves is in
- **minigames**: diamond halves is in
- **playlists**: Future World and cards improvements.
- **playlists**: Future World and cards improvements.
- **credits**: basic credits scene (not working)
- **credits**: basic credits scene (not working)
- **minigames**: improvements on Diamond Halves
- **minigames**: improvements on Diamond Halves
- **levels**: Water in Water Deathmatch (committed from a boat going from Padoa to Venice).
- **levels**: Water in Water Deathmatch (committed from a boat going from Padoa to Venice).
- **cards**: random card appearance
- **cards**: random card appearance
- **cards**: RandomCard
- **cards**: RandomCard
- **ui**: More planet arts.
- **ui**: More planet arts.
- **playlists**: Basic playlists in (content and art need more work).
- **playlists**: Basic playlists in (content and art need more work).
- **ui**: new world system up
- **ui**: new world system up
- **minigames**: super barebone diamond halves
- **minigames**: super barebone diamond halves
- **minigames**: diamond halves base
- **minigames**: diamond halves base
- **ui**: prime universe card back
- **ui**: prime universe card back
- **minigames**: Diamond Warfare in first playlist
- **minigames**: Diamond Warfare in first playlist
- **minigames**: 3 and 4 players arena for Diamond Warfare
- **minigames**: 3 and 4 players arena for Diamond Warfare
- **vfx**: visual feedback when dropping diamonds
- **vfx**: visual feedback when dropping diamonds
- **minigames**: 2 players diamond warfare
- **minigames**: 2 players diamond warfare
- **gameplay**: damage prevention time
- **gameplay**: damage prevention time

### Fix

- **locale**: no need to translate minigame names
- **locale**: no need to translate minigame names
- **celebration**: the champion can write their name again
- **celebration**: the champion can write their name again
- **homesick_invaders**: added cpubrain for homesick
- **homesick_invaders**: added cpubrain for homesick
- **credits**: added localization to credits
- **credits**: added localization to credits
- **cards**: mystery cards now correctly trigger winter
- **cards**: mystery cards now correctly trigger winter
- **levels**: respawn from home in Homesick Invaders
- **levels**: respawn from home in Homesick Invaders
- **ui**: flag compleated for playlist show winner username (instead of id)
- **ui**: flag compleated for playlist show winner username (instead of id)
- **cpu**: Cpu underwater fixes.
- **cpu**: Cpu underwater fixes.
- **input**: input buffering and logic on Ship
- **input**: input buffering and logic on Ship
- **levels**: wrong position of half diamond
- **levels**: wrong position of half diamond
- **cards**: duplicate card ids are now respected
- **cards**: duplicate card ids are now respected
- **credits**: super-ultra barebones credits screen (functional)
- **credits**: super-ultra barebones credits screen (functional)
- **credits**: pippo, pluto and paperino have been credited
- **credits**: pippo, pluto and paperino have been credited
- **arena**: Support for single life when respawning from home (needed in Diamond Minefield).
- **arena**: Support for single life when respawning from home (needed in Diamond Minefield).
- **ui**: new neptune colors
- **ui**: new neptune colors
- **playlists**: diamond dive in neptune
- **playlists**: diamond dive in neptune
- **ui**: Uppercase world label.
- **ui**: Uppercase world label.

## gameplay/uniform_respawn_time (2023-03-23)

### Fix

- **gameplay**: Excessive glow of cards removed.
- **gameplay**: Excessive glow of cards removed.

## v0.11-alpha (2023-03-19)

### Feat

- **ui**: Floating world in world cup selection screen.
- **minigames**: Winter Claim the Banner.
- **minigames**: Claim the Banner logo and placement in "action" playlist.
- **cpu**: Claim the Banner Brain.
- **levels**: 3 and 4 players Claim the Banner.
- **minigames**: Claim the Banner for 2 players
- **minigames**: Claim the Banner skeleton
- **scripts**: create new minigame script
- **scripts**: basic create new minigame script
- **ui**: more planet names and images
- **ui**: planets
- **ui**: Back button from deck selection screen.
- **cpu**: Basic Hoopball brain.
- **minigames**: Hoopball.
- **playlists**: Temporary second playlists.

### Fix

- **scripts**: new minigame level is now correctly created as a inherited scene
- **localization**: fixed on taglines
- **localization**: revert to main for PlayerSelection
- **localization**: fallback in characterscreen taglines
- **ui**: planet buttons are now functional again
- **performance**: Spurious WorldEnvironment node in Arena removed.

## v0.10.1-alpha (2023-03-10)

### Feat

- **demo**: Skip playlist selection if demo is on.
- **vfx**: diamond collect visual feedback
- **sfx**: rising pitch for diamond collect sfx
- **gameplay**: bumpable deadship
- hotball basic stuff
- **playlists**: "first" playlist
- **playlists**: "first" playlist
- **minigames**: poseidon
- **minigames**: poseidon
- **minigames**: treasure dive for 2 players
- **minigames**: treasure dive for 2 players
- **sfx**: new sound files
- **sfx**: new sound files
- **environments**: water wall
- **environments**: water wall
- **environments**: DashWall is now functional.
- **environments**: DashWall is now functional.
- **playlists**: teasing of new playlists and deck selection screen completed
- **playlists**: teasing of new playlists and deck selection screen completed
- **playlists**: Teasing of new playlists.
- **playlists**: Teasing of new playlists.
- **playlists**: random playlist button
- **playlists**: random playlist button
- **playlist**: old crown playlist
- **playlist**: old crown playlist
- **playlist**: Skulls playlist is now good
- **playlist**: Skulls playlist is now good
- **environments**: Reflector Walls
- **environments**: Reflector Walls
- **minigames**: 3 and 4 players levels added to Old School ("two" playlist is complete for all player counts)
- **minigames**: 3 and 4 players levels added to Old School ("two" playlist is complete for all player counts)
- **minigames**: first attempt at board conquest II board
- **minigames**: first attempt at board conquest II board
- **cpu**: improved board conquest brain
- **cpu**: improved board conquest brain
- better old school arena + tweaks
- better old school arena + tweaks
- **cpu**: poor man's danger avoidance
- **cpu**: poor man's danger avoidance
- **playlist**: playlist "two" completed for two players and AI
- **playlist**: playlist "two" completed for two players and AI
- **minigames**: improved Old School minigame
- **minigames**: improved Old School minigame
- **minigames**: improved Snipermatch arena
- **minigames**: improved Snipermatch arena
- **minigames**: tentative additions to intro playlist
- **minigames**: tentative additions to intro playlist
- **minigames**: hide and seek with rabbits and stuff
- **minigames**: hide and seek with rabbits and stuff
- **levels**: smaller battlefield in capture the flags (2 players) + slight gameplay changes and CPU improvements
- **levels**: smaller battlefield in capture the flags (2 players) + slight gameplay changes and CPU improvements
- **cpu**: capture the flags basic brain
- **cpu**: capture the flags basic brain
- **cpu**: Lowering CPU FPS to 5 + Undertakers brain also used in Skull Collectors.
- **cpu**: Lowering CPU FPS to 5 + Undertakers brain also used in Skull Collectors.
- **cpu**: Undertakers brain.
- **cpu**: Undertakers brain.
- **cpu**: deathmatch brain
- **cpu**: deathmatch brain
- **cpu**: board conquest brain
- **cpu**: board conquest brain
- **cpu**: use game mode-specific cpu brain, if found
- **cpu**: use game mode-specific cpu brain, if found
- **gameplay**: magnetic "cannon" WIP
- **gameplay**: magnetic "cannon" WIP
- **playlists**: empire playlist done
- **playlists**: empire playlist done
- **playlist**: empire playlist
- **playlist**: empire playlist
- **playlists**: do not shuffle hand (buggy) + do not show cards
- **playlists**: do not shuffle hand (buggy) + do not show cards
- **playlists**: attempt to craft the first playlist
- **playlists**: attempt to craft the first playlist
- **levels**: support for different player spawners in variants
- **levels**: support for different player spawners in variants
- **levels**: portal race variant A
- **levels**: portal race variant A
- **minigames**: diamond warfare basic setup (2 players)
- **minigames**: diamond warfare basic setup (2 players)
- **minigames**: capture the flag (all player counts)
- **minigames**: capture the flag (all player counts)
- **minigames**: capture the flags (2 players)
- **minigames**: capture the flags (2 players)
- **cpu+accessibility**: smaller player IDs + brain enhancements
- **cpu**: more specialized brains + navigation "fix"
- **cpu**: specialized brains
- **cpu**: WIP navigation zones computation
- **cpu**: WIP take the crown test
- **cpu**: experiments with navigation
- **cpu**: test brain for cpu
- **cpu**: player brain done
- **cpu**: no brain in ship as default
- **cpu**: test player brain is working + refactoring
- **cpu**: new brain system for controls (strategy pattern)
- **cards**: and more mystery cards again
- **cards**: more mystery cards
- **sfx**: global sound effect manager + pew sfx bugfix
- **cards**: intro deck splitted from classic
- **cards**: starting deck option to skip the first draft
- **cards**: hybrid suit cards

### Fix

- **localization**: improved localization for italian
- **localization**: imrpove localization
- **localization**: improved special character handling
- **UI**: BACKSPACE button binding to fullscreen removed in favor of F11.
- **android**: preparing for android
- **demo**: Do not unlock content if demo + lots of fixes.
- **playlists**: Playlist "ice" removed from initially unlocked starting decks.
- **score**: crash fixed
- **score**: do not show score floating messages if game is over
- **locale**: fallback fonts and default theme
- **locale**: cleanup
- **persistence**: in case of no unlocking file better handling a clean state
- **ux**: continue from hall of fame with controller buttons too
- **celebration**: skip all of fame in case of cpu
- **celebration**: skip all of fame in case of cpu
- **analytics**: removed analytics. Waiting for new ones
- **analytics**: removed analytics. Waiting for new ones
- **ui**: rumbling and hall of fame
- **ui**: rumbling and hall of fame
- **gameplay**: water boost reduced
- **gameplay**: water boost reduced
- **playlists**: solved error when storing deck inside the deck list item
- **playlists**: solved error when storing deck inside the deck list item
- small improvements
- small improvements
- **minigames**: updated look of capture the flags
- **minigames**: updated look of capture the flags
- **unlock**: more clean and clear
- **unlock**: more clean and clear
- **unlock**: startingDeck resource- playlist or not - have now unlocks param
- **unlock**: startingDeck resource- playlist or not - have now unlocks param
- **unlocker**: starting deck
- **unlocker**: starting deck
- **gameloop**: ClassicMystery crash solved
- **gameloop**: ClassicMystery crash solved
- **unlocking**: shift reset reset everything
- **unlocking**: shift reset reset everything
- **playlist**: typo in accessing deck
- **playlist**: typo in accessing deck
- **playlists**: if playlist let's unlock and make room for a new playlist
- **playlists**: if playlist let's unlock and make room for a new playlist
- **persistence**: close #1064 - cpu in continue sessions
- **persistence**: close #1064 - cpu in continue sessions
- **draft**: close #1063 - quit to menu skip playing card
- **draft**: close #1063 - quit to menu skip playing card
- **playlist**: unlock if you play any playlist
- **playlist**: unlock if you play any playlist
- **playlist**: Everything is fixed. Print everything
- **playlist**: Everything is fixed. Print everything
- **playlists**: empire skips first draft
- **playlists**: empire skips first draft
- **cpu**: support for more than one target
- **cpu**: support for more than one target
- **crashes**: call_deferred on bitmask setting methods (should prevent lots of crashes)
- **crashes**: call_deferred on bitmask setting methods (should prevent lots of crashes)
- **cpu**: take the crown cpu update to take death into account
- **cpu**: take the crown cpu update to take death into account
- **minigames**: skull collectors name
- **minigames**: skull collectors name
- **playlist**: if it's a playlist do not shuffle in extraction.
- **playlist**: if it's a playlist do not shuffle in extraction.
- **graphics**: orange portals
- **graphics**: orange portals
- **gameplay**: working portals in race and goal, with graphics
- **gameplay**: working portals in race and goal, with graphics
- **gameplay**: gate double scoring bug fixed
- **gameplay**: gate double scoring bug fixed
- **gameplay**: WIP portal double scoring investigation
- **gameplay**: WIP portal double scoring investigation
- **gameplay**: quicker diamond waves
- **gameplay**: quicker diamond waves
- **minigames**: id of capture the flag
- **minigames**: id of capture the flag
- **look**: Pew rotation is now good
- **cards**: Z-index errors in perfectionist overlays + minor chores.
- **sfx**: partial fix to pew not disappearing (sfx is not played sometimes though)
- **geometry**: simplified geometry in Goalportal zones (avoid spamming errors about isopolygon)
- **persistance**: restore playing levels from scene
- **logger**: improved logger
- **levels**: Switching goals in 2 players Goalportal.
- **levels**: Reinstated walls in Diamondsnatch at higher player counts.
- **levels**: More space in Deathmatch at higher player counts + wall positions fixes.
- **session**: a more clean way to cycle through the session life
- **bugs**: smashing bugs and make them more reliable

## v0.9-alpha-lucca (2022-11-03)

### Feat

- **sfx**: gate
- **sfx**: pew
- **look**: hall of fame graphics and simplified pilot stats
- **demo**: autoselect character
- **tutorials**: move > fire > aim tutorials
- **tutorials**: option to appear more than once
- **look**: backgrounds are chosen according to card suit
- **cards**: connexx logo and final name + fix(accessibility): colorblind-safer logos
- saving from eventual crash
- **celebration**: improving animation on the hall of fame
- **hall-of-fame**: Ugly but beautiful first attempt to Celebrate winner and Hall of Fame
- **demo**: demo mode enable and handled (#1018)
- **draft**: more smooth hand management (#1019)
- **accessibility**: ui scaling (#895)
- **unlocking**: starting deck unlocking. Unstable
- **draft**: selection starting deck
- adding new cards to deck from pool whenever the hand is emptied
- connected to main loop
- preparation for draftarena

### Fix

- **demo**: demo playtest flag reset for pre-release
- **cards**: tweaks on cards
- **before-demo**: last one. Setting smooth animation for hand. Session persistence for mystery card
- **look**: better font settings
- **look**: z-index error in game over screen
- **gameplay**: skull outline fixed
- **session**: now can recover from session and continue draft
- **recover-session**: session recover fixes also for hand-over
- **emergency-buttons**: emergency buttons in demo_playtest mode
- **hand**: parametrized card separation
- **persistence**: local timestamp correctly setup
- **cards**: crash on continue after gameover fixed
- **hall-of-fame**: correct placeholder
- **session**: back to game after hall of fame
- **draft**: resolved almost everything
- **cycle**: cards work as usual
- **demo**: fixed character selection according to controller
- **ui**: join messages in selection
- **celebration**: reintroduce snapshot animation leaderboard
- **persistence**: latest game and confirm after gameover
- **selection**: refactoring new mode to join the game
- **demo_playtest**: control locked
- **cards**: classic mystery card with correct subcards
- **celebration**: username used in all relevant places
- **persistance**: momentarily disable snapshot_leaderboards in order to avoid crash
- **draft**: now the cards are correctly extracted, with new cards ncludede
- **look**: better background for draft arena
- **persistence**: able to choose deck even if previous one is not found
- **leaderboards**: a few fixes for leaderboard and persinstance sessions
- **gameplay**: no invincibility at the beginning of diamond minefield.
- **session**: all the crashes will disappear
- **gameplay**: Better positioning of launcher zones in Goalportal.
- **gameplay**: More skull holes in Undertakers.
- **accessibility**: Improved scaling of PlayerInfoOnShip.
- **accessibility**: "on" tiles are now more visible.
- **deck**: improvements to deck
- **accessibility**: less camera movements in diamondsnatch
- **accessibility**: fixed camera in board conquest
- **performance**: in_camera removed from tiles
- wrong ship rotation in connex
- **gameplay**: second choice is seeing light
- **persistence-session**: viva la persistance
- **session-cycle**: link session over to cycle
- **config**: remove references to card_pool.tres
- ready (not really) to merge
- small changes to Time utils
- improvements
- **cardpool**: will get all elements in folder
- adding also the minigame logo
- **session-winner**: link cycle for session winners
- **session-winner**: Link to the cycle
- **session-winners**: almost ready. need to link
- **hall-of-fame**: mockup
- **persistance**: continue from last session. If you want
- deprecated datetime
- almost ready
- skull collector tweaks
- skull collector tweaks
- **cards**: improving spreading out
- **cards**: fan out cards
- **hand**: satisfying spread fanout cards
- **reimport**: reimported assets
- **config**: updated gitignore. *.import should not be ignored
- **draft**: need to play a bit more with angles
- **draft-card**: it seems we are getting somewhere
- **signals**: get rid of nav_to_hall_of_fame
- **session-winner**: complete cycle with winning session
- **session-winner**: adding timestamp to global
- **session-winner**: info on the matches as well
- **hall-of-fame**: better handling cycle of session winner
- **session-winner**: typo on instanziate session-winner
- **hall-of-fame**: Connect with the cycle of sessions
- disable unlocking cycle as in #1022
- **hand**: correctly access to card content
- **cards**: hand like fan. Doesn't work but it's something
- **playtest**: fixes from playtest
- **unlocking**: more smooth animation in unlocking
- **unlocking**: skeleton for complete unlocked deck
- **transition**: 1 second long transition scene
- **diamondsnatch**: improved and made arena lighter
- **unlocking**: deck scene shown on top of arena.
- **memoryleak**: remove orphan nodes
- **intro-match**: match intro and larger fade intro in match
- **camera**: easing in intro
- **camera**: intro works for large arenas (with a tween)
- **transition**: tweaks on transition
- **transition**: arena zoom at the beginning reduced
- **vfx**: fade to black or white for transitions
- **ui**: radio options for starting deck. skeleton
- **camera**: tweak on values
- **camera**: let's start from far behind
- **draftcard**: get_minigame with a getter
- **design**: diamondsnatch cleanup!
- **draft**: bring back to life
- **draft**: continue refactoring
- **draft**: renaming and refactoring completed
- **draft**: renaming
- **battle**: refactoring for spawners implemented
- **battle**: since like we have a good start to re-engineer our diamondsnatch
- **battle**: spawners refactoring for Diamondsnatch (specifically)
- **battle**: attempt to rengineer diamondsnatch spawners
- **controls**: you can now map anything. No string attached
- **ui**: close #679 let's disable the sorting bars for the time being
- **ui**: better outline for device id
- **ui**: tweaks on ux
- **controls**: better handling presets
- **ui**: checkbox pressed as transparent
- **controls**: presets and defaults working for joy and kb
- **controls**: correctly startup from existing saved mapping
- **controls**: strong refactor. pt1
- **config**: fix #921 all minigames should have IDs
- rotation of decals in skull
- **map**: chose card animation with arrow
- **map**: tweaks on animation and extraction
- **map**: bug fixed on the third+ cycle
- **map**: cycle of map completed
- **map**: ships should spawn if hand is getting a refilled because empty
- in draftarena we wait for player card selection
- disappear ship when tapping it
- added logic for load resources
- **ui**: wait all players to be ready!
- tweaks
- remapping is still complicated
- worded more explicitly
- remapping is a bit complicated

## v0.7.0-alpha1 (2022-05-29)

### Feat

- camera enable into Options

### Fix

- **remapping**: generalizing template and style for joypads
- one step closer to remap custom mapping
- fix on keyboard ESCAPE button
- added presets
- presets
- almost ready for deploy
- improvements
- mapping and connecting with signal from  EventBus
- we are almost there
- first stage of refactoring and cleanup
- **ui**: needs a rewrite, unfortunately.
- **ui**: improvements on options
- rocket pursuing timeout observed
- **gameplay**: close #800 Quitting while session is in progress gives someone a star
- **camera**: closes #879 condition corrected for when disabled camera globally
- **controls**: remapping
- tweaks to scene
- **controls**: Some tweaks
- **controls**: fix ui for remapping controls and cleanup
- **unlocking**: map fixes for path and pathline
- close #855 camera override disabled
- **accessibility**: slowdown in gameover fixed
- close #855 camera override disabled
- **accessibility**: slowdown in gameover fixed
- close #855 camera override disabled
- **camera**: maparena should be fixed
- **persistence**: camera enable in persistence
- **audio**: audiolibrary fixed, making sure that fadeout will stop
- enable camera fixes in options
- fixed soundtrack fadeout once and for all
- **camera**: improvements on camera (#849)
- correctly enable camera
- fix point number (1). start of the match, arena is not correctly in camera
- implelemented anchor to center ... experimenting update every 5 frames
- **camera**: physics_process instead of process and update camera on odd frames
- **camera**: minzomm to 3.0 (was 2.5)
- correctly override time for first blood
- soundtrack and fadeout
- close #726, close #728 (#838)
- quicker description scene
- options better setup
- cleanup
- clean up and make everything work again
- tweaks on green nodes

## 120fps (2021-11-18)

### Feat

- deep tidy up folders for the upcoming ui overhaul (#758)
- unlocker overhaul (#804)
- Negacrown dashing and doubling

### Fix

- IMPORTANT! Physics fps increased to 120 + Bump tweaks.
- relincensing assets under CC-BY-NC-SA (#809)
- Slam-a-Gon in Godot 3.4 (it doesn't rely on callback order anymore)
- CRT shader now is working again on HUD
- better aspect ratio for Alchemical Bombing field
- royalty is taken into account by fields
- ships' royalty restored
- queen of the hive royalty restored
- slower respawn if holding crown + simpler respawn timeout design (needs testing)
- less thin glass walls in Negacrown
- more sophisticated holdables (avoid loading holdables of the same type twice, drop backwards when replaced)
- advanced figures are worth double in memory
- rockets pursue once
- death is sometimes swirly + less impulse
- better bump and less confusing death
- more aliens, slower aliens in Homesick Invaders
- TappablesManager connect / disconnect
- Start with one starry path locked.
- Tappables preview is now in sync with actual state.
- tappables overhaul - exit areas and better signal handling
- Size of Alchemical Bombing reduced for 3 and 4 players (the screen was difficult to read).
- post-playtest fixes to Slam-A-Gon and Homesick Invaders

## PontremoliPlaytest (2021-10-31)

### Feat

- button demo in Options (#771)
- indestructible and regen shields
- improved deathmatch with shields
- layered shields
- intro with ships and their invincibility (#694)
- intro with ships and their invincibility
- set test scene
- unlocking a bit more complete. Now you can use map (#585)
- refactoring for global Match and session (#579)
- smooth transition especially at the beginning of the match. Close #433
- skeleton for returning to map (#569)
- randomly pass from wander to seek
- added the chance to show description in mappanel
- added laser
- added flood moons in the map
- added glow enabled by menu. Close #392 (#528)
- **combat**: new weapon - bullet - in goal Portal
- show arena completely and smoothly
- **design**: Pursuing bombs is now a flag settable from Gamemode. Close #449
- race skeleton
- race mode and scoring
- experiment with rules
- **gameplay**: Add modifiers according to set choice (#446)
- when the game is a tie, give a star for each player. Related to #401
- Randomize player position at start (within session not if you run from scene) close #399
- trails are created at respawn and deleted after wrap. Close #395
- when dies the trail will wrap back
- survival rules uniformed with perfect score system (#384)
- Perfect score system (#382)
- added panels in map
- Minigames levels with water and other stuff (#373)
- new map
- skeleton for map with panels
- **combat**: sync shockwave with explosion
- **games**: Ball-based games (#363)
- **games**: First blood game (#362)
- **gameplay**: Brickbreak game and limited ammo support (#361)
- **performance**: Improvements to graphic performance (#360)
- **vfx**: Visual feedback for dash (#357)
- **ui**: Input remapping for keyboard (#356)
- **vfx**: Glowing arena (#353)
- **ui**: improved ui on mainscreen (#338)
- **design**: Drones set (#345)
- **ui**: Attempt to reduce visual clutter (#344)
- **ui**: in Combat bars will have Ticks and streaks (#343)
- **design**: Asteroid Set (#340)
- **ship**: everything is absolute controls (#335)

### Fix

- typo
- hotfix on thematch trying to access summary()
- get rid of rules and restore a single line description for minigames (some files still linger) - closes #768
- get rid of rules and restore a single line description for minigames (some files still linger)
- jagged shield sector when changing from plate to shield
- bumpversion and cleanup
- adding uuid to match and session
- is_loadable in holdables
- crash when playing a second session after a quit to map
- one shot connect from Arena for gameover
- leaderboard get the info from existing fields.
- tweaks
- font overhaul with bungee
- some weird changes on merge
- Camera on Map
- shake no more
- Dynamic labels on map, new assets, all-unlocked setup for testing.
- Sets are shown and acted upon according to their status.
- more generic way to get if a set is unlocked
- locked sets
- unlocking more complete.
- bit more satisfying randomness selection of minigame
- better feeling for random selection
- Resource might be different instances, so better check the get_id()
- correctly accessing to levels
- skip fix, continue standalone
- when arena is ran from editor. Continue will restart the match
- ship appearance in bars
- close #576. Avoid repetition of already unlock set
- remove debug sprite
- avoid crash and infinite waiting on multiple unlocking
- trail appears correctly. Close #572
- close #366
- close #543
- upgrade to godot3.2.4
- starting animation
- fix #523
- check better persistance for joypad (#568)
- follow camera won't go over the arena field (#557)
- remove megaspace from "fields" and fix avoid finally
- cpu ship more debug and more strategy
- keep decision
- better targetting new position
- debug enabled and better handling stuff
- committiamo così che per lo meno fanno qualcosa
- more strategic CPU
- timing the wanderer
- debug enabled
- no need to chase ship in some minigame
- better handling CPU with turn and shoot and
- card persisted
- flood and laser persistent. Close #537
- updated laser moon sprites
- Handling remapping for Right Analog. FIx #533
- better naming controls. Close #532
- put glow enable in persistence
- show arena and hide arena would now dark background as well
- close #485 Countdown disappears on gameover
- **ui**: close #486 - "Show arena" button now shows the arena better
- refactoring code
- **combat**: More visible deadship. Close #460
- paddle cast shapes (more like cast a spell)
- **combat**: portal in order to work for race. Close #475
- tweaks on small debug elements
- better camera handling in survival
- **ui**: race - show points scored close #463
- close #457 Keep  negative scores
- deadship will not teleport
- **ui**: fix #445
- **combat**: Camera finally follow smoothly the players (#440)
- **combat**: Give correct score in case of draw with 0 points. close #439
- **combat**: fix camera for survival games (#436)
- **selection**: close #429
- **map**: Deduplication of minigames after selection. close #405
- **map**: close #388 and close #389
- **ui**: Close #419
- **combat**: Resolves #410 and fix #409
- Restart level on menu. close #387
- skip sluggish tutorial. Close #381
- Trails fix and refactoring (#386)
- **combat**: improved and refactoring trail
- **combat**: improved and refactoring trail
- merge thing
- refactoring trails
- merge with minigames
- moving things around
- Multiple handlng wells for grid shader
- **ui**: small timeout when set a remapping control
- **design**: reset levels on restart session (#365)
- **ui**: Padding correctly for array element
- **ui**: selection screen command per player
- **locale**: if locale is not recongised, trying to use the locale instead of the locale_name. Closes #310
- **physics**: new values for ship torque and angular damp, attempt to address #349 (#355)
- **gameplay**: on start ships didn't start close #337 (#341)

## v0.6.4 (2020-03-10)

## v0.6.3 (2020-03-04)

## v0.6.1-demoherofest (2019-11-25)

## v0.6-demo1 (2019-10-31)

## v0.3.1 (2019-06-01)

## v0.3-alpha1 (2019-05-13)
