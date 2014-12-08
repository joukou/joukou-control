{ server } = require( 'karma' )
options    = JSON.parse( process.argv[ 2 ] )

server.start( options )