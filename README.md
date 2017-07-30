Joukou Control 
==============
[![Build Status](https://circleci.com/gh/joukou/joukou-control/tree/develop.png?circle-token=4f5b6890a3eed150bc550a785e3ce6eaa8ce277c)](https://circleci.com/gh/joukou/joukou-control/tree/develop) [![Coverage Status](https://coveralls.io/repos/joukou/joukou-control/badge.png?branch=develop)](https://coveralls.io/r/joukou/joukou-control?branch=develop) [![Docker Repository on Quay.io](https://quay.io/repository/joukou/control/status "Docker Repository on Quay.io")](https://quay.io/repository/joukou/control) [![Apache 2.0](http://img.shields.io/badge/License-Apache%202.0-brightgreen.svg)](#license) [![Stories in Ready](https://badge.waffle.io/joukou/joukou-control.png?label=ready&title=Ready)](http://waffle.io/joukou/joukou-control) [![IRC](http://img.shields.io/badge/IRC-%23joukou-blue.svg)](http://webchat.freenode.net/?channels=joukou)

![](http://media.giphy.com/media/mKxDyUVxtby3C/giphy.gif)

Joukou 2D and 3D control surfaces.

## Getting Started

1. `$ npm install`
1. `$ gulp develop`
1. `$ npm start`
1. Install the [Chrome LiveReload extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei).
1. Go to [`http://localhost:2100/build/testing/index.html`](http://localhost:2100/build/testing/index.html).

## Technology Stack

### Core

* [Polymer](http://www.polymer-project.org/docs/polymer/polymer.html)
* [AngularJS](https://angularjs.org/)
* [Angular Classy](http://davej.github.io/angular-classy/)
* [Angular UI Bootstrap](http://angular-ui.github.io/bootstrap/)
* [Angular UI Router](http://angular-ui.github.io/ui-router/)
* [Bootstrap Stylus](https://github.com/Acquisio/bootstrap-stylus#bootstrap-stylus-311)
* [hyperagent.js](http://weluse.github.io/hyperagent/)
* [Lodash](http://lodash.com/docs)
* [jQuery](http://api.jquery.com/)
* [CoffeeScript](http://coffeescript.org/)
* [Jade](http://jade-lang.com/)
* [Stylus](http://learnboost.github.io/stylus/)
* [gulp.js](http://gulpjs.com/)

### 2D

* [NoFlo Graph Editor](https://github.com/joukou/the-graph)

### 3D / VR

* [three.js](http://threejs.org/)
* [LeapJS](https://github.com/leapmotion/leapjs)
* [oculus-bridge](https://github.com/Instrument/oculus-bridge)

### Unit Tests

* [Karma](http://karma-runner.github.io/0.12/index.html)
* [Mocha](http://mochajs.org/)
* [Chai](http://chaijs.com/)

### E2E Tests

* [Protractor](https://github.com/angular/protractor#protractor-)

### Visual Tests

* [Huxley](https://github.com/joukou/gulp-huxley#gulp-huxley)

## Project Structure

* Polymer custom element definitions are at `src/elements/{component-name}/`. 
* Each Polymer custom element's markup is at `src/elements/{component-name}/index.jade` that will be converted to HTML by gulp.
* Each Polymer custom element can include any number of Stylus and CoffeeScript source files that will be compiled by gulp.
* The main application markup is at `src/index.jade`. There is no need to use `<link rel="import" herf="path-to-component-template">`. All of the components inside `elements` will be injected into the `index.jade` markup by the `import-polymer-elements` task.
* Angular modules are at `src/app/**/*.coffee`.
* The main stylesheet is at `src/main.styl`, which imports Bootstrap. Variables to modify Bootstrap should be placed in `src/variables.styl`.

## Contributors

* [Fabian Cook](https://github.com/fabiancook)
* [Isaac Johnston](https://github.com/superstructor)
* [Rowan Crawford](https://github.com/wombleton)
* [Juan Carlos Morales Mora](https://github.com/juank11memphis)

## License

Copyright &copy; 2014 Joukou Ltd.

Joukou Control is under the Apache 2.0 license. See the
[LICENSE](LICENSE) file for details.
