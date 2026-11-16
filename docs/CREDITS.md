# Lunar Life: credits and data sources

## NASA data
- **Solar energetic particle (SEP) event** used for the radiation alert: NASA CCMC DONKI record
  `2024-05-10T13:35:00-SEP-001` (event time 2024-05-10T13:35Z, instrument GOES-P: SEISS >10 MeV).
  Record page: https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/30677/-1
  Retrieved 2026-11-14 from `https://ccmc.gsfc.nasa.gov/DONKI-API/get/SEP?startDate=2024-05-01&endDate=2024-06-15`
  and stored unchanged in `data/nasa/donki_sep_cached.json` (provenance: ARCHIVED).
- The record is a detection near Earth. It is **not** a radiation dose at a lunar outpost.
  Exposure, battery, power and time in the game are simplified game units set in
  `data/nasa/sep_replay_config.json` and `scripts/autoload/resource_sim.gd`.
- The sunlight/shadow pattern is a fictional stand-in for south-polar terrain shadowing and is unrelated to the SEP event.
- There is no live API call in the game yet.

## Art
- Character sprites (player astronaut, commander, engineer, botanist): generated with SpriteCook
  (Pixel Engine model). Asset IDs are in `spritecook-assets.json`.
- Astronaut walk cycle (`assets/art/characters/player_walk_sheet.png`, 8 frames of 32 x 32): made by Kareem Dahrouj by
  rearranging pixels of the SpriteCook astronaut sprite. Played at 10 frames per second.
- Directional astronaut animations (`assets/art/characters/astronaut/`: idle, 8-frame walk in 4 directions, 3/4 turn frames): made by Kareem Dahrouj by
  redrawing the SpriteCook astronaut in side profile and back view. Played by `scripts/player/player.gd`.
- Room and exterior backgrounds (`assets/art/world/*.png`): painted by the scripts in `tools/art/`
  (Python, numpy, Pillow) from the floor plans in `scripts/outpost/outpost_layout.gd` and
  `scripts/academy/academy_layout.gd`. Lights, screens, the shelter hatch and the UI are drawn by the game.
- Title screen and intro slides are drawn in code.
- `docs/handoff/.../references/*.png`: AI-generated concept images supplied by Jimmy as visual targets.
  They are not used as game assets and are excluded from the Godot project by `docs/.gdignore`.

## Fonts
- Galmuri7, Galmuri9, Galmuri11 and Galmuri11 Bold by Lee Minseo, SIL Open Font License 1.1
  (`assets/fonts/OFL.txt`). Subset to Latin characters with fonttools.

## Sound
- All sound is synthesised by the team's own code: short tones in `scripts/autoload/sfx.gd`,
  the hatch, alert, ambience and music loop by `tools/audio/make_audio.py`. No recordings or samples.

## Field notes (facts shown in the game)
- NASA SVS, Shadows near the Moon's South Pole: https://svs.gsfc.nasa.gov/4893
- NASA, The Harsh Environment of the Lunar South Pole (Moon Base reference)
- NASA, Sunrise Through the Solar Arrays; NASA, Space Station Facts and Figures
- NASA, Meals Ready to Eat: Expedition 44 Crew Members Sample Leafy Greens Grown on Space Station (2015)
- NASA CCMC, DONKI: https://ccmc.gsfc.nasa.gov/tools/DONKI
- NASA, How NASA Tracked the Most Intense Solar Storm in Decades
- NASA, How NASA Will Protect Astronauts From Space Radiation at the Moon

## Five-day mission facts (activities in `data/learning/activities.json` and the new field notes)
- NASA, Become an Astronaut (requirements): https://www.nasa.gov/humans-in-space/astronauts/become-an-astronaut
- NASA, Astronaut Candidates Get to Work at Johnson Space Center (NBL, T-38, Canadarm2, survival, geology)
- NASA Johnson Space Center, Training for Space fact sheet (Neutral Buoyancy Laboratory: 6.2 million gallons):
  https://www.nasa.gov/wp-content/uploads/2015/10/160410main_space_training_fact_sheet.pdf
- NASA, Counteracting Bone and Muscle Loss in Microgravity (2023): about two hours of exercise a day;
  bone loss of about 1 to 1.5 percent per month in weight-bearing bones (also reported by NASA research summaries)
- NASA Kennedy Space Center, Veggie; Veg-01 reports of 10 August 2015 ("Outredgeous" red romaine, 33 days of growth,
  plant pillows, red/blue/green LEDs): e.g. https://www.livescience.com/51811-astronauts-eat-space-lettuce.html
- Paul, A.-L. et al. (2022), Plants grown in Apollo lunar regolith present stress-associated transcriptomes,
  Communications Biology 5, 382 (NASA-funded): https://www.nature.com/articles/s42003-022-03334-8
- NASA Science, To Protect Artemis II Astronauts, NASA Experts Keep Eyes on Sun (solar particle events,
  shielding is about mass): https://science.nasa.gov/missions/artemis/artemis-2/to-protect-artemis-ii-astronauts-nasa-experts-keep-eyes-on-sun/
- ESA, Protecting Artemis and lunar explorers from space radiation (the Moon has no magnetosphere)
- NASA, John Glenn: STS-95 (1998), flew at age 77.
- Simplified in the game: the light-recipe growth heights, crop health, and how much partial gravity protects
  bones (still being studied). The facts above are real; the numbers in play are game units.

## Tools
- Godot 4.7.2.

## To confirm with the team
- Which work done before the event start may be included in the submission.

## Day 3 interactive lessons
- Dust Detective uses illustrative sample drawings. Lunar regolith growth comparisons are qualitative, based on NASA's account of the 2022 study: https://www.nasa.gov/humans-in-space/scientists-grow-plants-in-lunar-soil/ . The control illustration represents experimental control material, not a measured yield prediction.
- Harvesting illustrates the fresh-food lesson already credited above. The three beds, harvest speed and science reward are gameplay simplifications.

## Suit and pool training
- NASA Spacewalk Spacesuit Basics: https://www.nasa.gov/centers-and-facilities/johnson/spacewalk-spacesuit-basics/ . Suit Up illustrates cooling, pressure, gloves, helmet and crew checks. Its sequence omits real procedures and is explicitly labelled simplified.
- NASA Neutral Buoyancy Laboratory: https://www.nasa.gov/johnson/neutral-buoyancy-laboratory/ . Floaty Fix illustrates careful underwater task practice. The drift, speed limit and bolt count are game mechanics. Buoyancy simulates only some aspects of spacewalk work.
