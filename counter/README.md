# Elm Counter Project

# Overview

This is a simple counter iimplemented with Elm. It's about the simplest thing
you can do with user input, but it's enough to show the flow of data in the Elm
architecture. This also makes it very easy to add to and modify.

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

* Add buttons to Increment & Decrement by 5
  * You should be able to just copy the basic increment pattern
* Add a second counter to the app
  * You'll need a way to distinguish between counters in Msg
* Add an arbitrary number of counters to the app
  * `List.indexedMap` will probably help you here
