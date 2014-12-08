

module.exports = ( config ) ->

  path = require( 'path' )
  os = require( 'os' ).type()

  isCI = process.env.CI is 'true'

  if isCI # CircleCI
    browsers = [ 'PhantomJS', 'Firefox' ]
  else    # Developer's machine
    switch os
      when 'Darwin'
        #browsers = [ 'Chrome', 'ChromeCanary', 'Firefox', 'Safari' ]
        browsers = [ 'PhantomJS' ]
      when 'Windows_NT'
        browsers = [ 'Chrome', 'Firefox', 'IE' ]
      else
        browsers = [ 'Chrome', 'Firefox' ]

  config.set(
    # frameworks to use
    # available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: [
      'mocha'
      'chai'
      'chai-as-promised'
      'sinon-chai'
    ]

    # list of files / patterns to load in the browser
    files: [
      {                             # Polymer Custom Elements
        pattern: path.join( 'build', 'testing', 'elements', '**', '*.html' )
        included: false
      }
      '../bower_components/angular/angular.js' # AngularJS
      '../bower_components/angular-resource/angular-resource.js' # AngularJS $resource
      '../bower_components/angular-ui-router/release/angular-ui-router.js' # AngularJS UI Router
      '../bower_components/angular-ui-bootstrap/src/dropdown/dropdown.js' # AngularJS UI Bootstrap Dropdown
      '../bower_components/angular-mocks/angular-mocks.js'
      '../build/testing/app/**/*.js' # AngularJS application
      '../src/app/**/*.jade'         # AngularJS templates
      'unit/**/*.spec.coffee'        # AngularJS & Polymer unit tests
    ]

    # list of files to exclude
    exclude: [

    ]

    # preprocess matching files before serving them to the browser
    # available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors:
      # although karma-coverage supports preprocessing of CoffeeScript it is via
      # Ibrik which uses the CoffeeScriptRedux compiler. CoffeeScriptRedux is
      # 1. not compatible (i.e. code doesn't even compile) and 2. not a good
      # test because even for a successful compilation the generated JavaScript
      # could be functionally different. So we test the compiled JavaScript
      # sources instead until the official CoffeeScript and CoffeeScriptRedux
      # compilers are merged.
      '../build/testing/app/**/*.js': [ 'coverage' ] # AngularJS application
      '../src/app/**/*.jade': [ 'ng-jade2js' ]       # AngularJS templates
      'unit/**/*.spec.coffee': [ 'coffee' ]          # AngularJS & Polymer unit tests

    # test results reporter to use
    # available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: [
      'progress'
      'coverage'
    ]

    coverageReporter:
      reporters: [
        {
          type: 'html'
          dir: 'coverage/'
        }
        {
          type: 'lcovonly'
          dir: 'coverage/'
        }
      ]

    # web server port
    port: 9876

    # enable / disable colors in the output (reporters and logs)
    colors: true

    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN
    #                  || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_WARN

    # enable / disable watching file and executing tasks whenever any file changes
    autoWatch: false

    # start these browsers
    # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: browsers

    # Continuous Integration mode
    # if true, Karma captures browsers, runs the tests and exits
    singleRun: true
  )