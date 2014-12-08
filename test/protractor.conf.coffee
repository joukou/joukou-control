path        = require( 'path' )
protractor  = require( 'protractor' )

exports.config =
  framework: 'mocha'

  mochaOpts:
    reporter: 'spec'
    timeout: 10000

  seleniumServerJar:  path.join( __dirname, 'selenium-server-standalone-2.42.2.jar' )

  capabilities:
    browserName: 'firefox'

  # by is a keyword in CoffeeScript, so create an alias findBy.
  onPrepare: ->
    global.findBy = protractor.By