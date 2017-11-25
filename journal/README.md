# Elm Local Journal

## Overview

This app allows a user to create journal entries and save them to local storage.
The content of entries supports markdown.

Ports are used to communicate with the local storage API, so this is probably a
good project to look at if you're interested in interop with Javascript

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

* Automatically add the current date to a journal entry
* Add an ability to filter entries by title and/or date
* Add URL navigation so the back/forward buttons work sensibly
