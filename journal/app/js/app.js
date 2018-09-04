import { Elm } from '../elm/Main.elm'
import storageBindings from './localstorage.js'

const app = Elm.Main.init();

storageBindings.setup(app.ports);
