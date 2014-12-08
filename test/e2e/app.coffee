chai            = require( 'chai' )
chai.use( require( 'chai-as-promised' ) )
should          = chai.should()

describe 'ngJoukou App', ->

  specify 'redirects index.html to index.html#/home', ( done ) ->
    browser.get( 'build/testing/index.html' )
    browser.getCurrentUrl().then( ( url ) ->
      url.split( '#' )[ 1 ].should.equal( '/home' )
      done()
    )