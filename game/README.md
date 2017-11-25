# Jumpy Guy - Not Quite a Game in Elm

This is the bare-bones beginning of what might become a game. It uses
subscriptions for animation and listening to keypresses, so it might be worth
playing with to see how subscriptions work, even if you're not interested in
building a game.

Also, as you add more enemies you might find that they share some data in common
with the player. That's a good chance to experiment with extensible records.

## Getting Started

### Install

`npm install`

`npx elm-package install`

### Run

`npm start`

### Production build

`npm build`

### Elm commands

Elm binaries can be found in `node_modules/.bin`, if you do not have Elm
installed globally. With the latest npm you can run:

`npx elm-package install <packageName>`

to install new packages. Alternatively, you could add scripts in `package.json`
and run them via `npm run ...`

## Suggested Next Steps

* Tweak the character's movement (change speeds, add intertia, whatever)
* Add some stationary obstacles and restart the game on collisions with them.
* Add a hole in the ground and restart the game when the player falls in.
* Add a moving obstacle/enemy and restart the game on collision with it.
* Add different types of obstacles/enemies to the game.
