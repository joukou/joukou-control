###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

#
# Modules
#
gulp      = require( 'gulp' )
plugins   = require( 'gulp-load-plugins' )( lazy: false )
joukou    = require( 'joukou-gulp' )( gulp, plugins )


path      = require( 'path' )
lazypipe  = require( 'lazypipe' )
async     = require( 'async' )
nib       = require( 'nib' )
cheerio   = require( 'cheerio' )
path      = require( 'path' )
fs        = require( 'fs' )
mkdirp    = require( 'mkdirp' )
{ spawn, exec } = require( 'child_process' )
lr        = require( 'tiny-lr' )
yaml      = require( 'js-yaml' )
request   = require( 'request' )

lrServer  = lr()

#
# Paths
#
paths =
  build: 'build'
  src:
    coffee: path.join( 'src', '**', '*.coffee' )
    jade: path.join( 'src', '**', '*.jade' )
    stylus: path.join( 'src', '**', '*.styl' )
    images: path.join( 'src', 'images', '**', '*' )
  testing:
    dest: path.join( 'build', 'testing' )
    images: path.join( 'build', 'testing', 'images' )
    index: path.join( 'build', 'testing', 'index.html' )
    elements: path.join( 'build', 'testing', 'elements' )
    css: path.join( 'build', 'testing', '**', '*.css' )
  production:
    dir: path.join( 'build', 'production' )
    index: path.join( 'build', 'production', 'index.html' )
    js: path.join( 'build', 'production', 'all.js' )
    css: path.join( 'build', 'production', 'main.css' )
    images: path.join( 'build', 'production', 'images' )

###*
@namespace lazypipes
###
lazypipes = {
  coffee: lazypipe().pipe( plugins.coffee,
    bare: false
    sourceMap: false
    sourceDest: paths.testing.dest
  )
  .pipe( gulp.dest, paths.testing.dest )

  coffeelint: lazypipe().pipe( plugins.coffeelint,
    optFile: 'coffeelint.json'
   )
   .pipe( plugins.coffeelint.reporter )
}

###*
@class joukou-control.gulpfile.utils

Util functions are defined independently of task functions to enable code re-use across multiple tasks and/or because
recursion is required; e.g. recursive directory search.
###
utils =
  ###*
  @method filterDir
  @param {String} directory
  @param {Function} iterator A truth test to apply to each file found in `directory`. The `iterator` is called with
                            `interator( filename, stats, callback )` and `callback` must be called with a boolean
                            argument once it has completed.
  @param {Function} done A callback which is called after all the `iterator` functions have finished. It is passed the
                         array of filenames that have passed the `iterator`'s truth test.
  @return {joukou-control.gulpfile.utils}
  ###
  filterDir: ( directory, iterator, done ) ->
    fs.readdir( directory, ( err, files ) ->
      return done( err ) if err

      async.reduce( files, [], ( memo, file, next ) ->
        filename = path.join( directory, file )
        fs.lstat( filename, ( err, stats ) ->
          if err
            next( err )
          else if stats.isDirectory()
            utils.filterDir( filename, iterator, ( err, filenames ) ->
              if err
                next( err )
              else
                memo = memo.concat( filenames )
                next( null, memo )
            )
          else
            iterator( filename, stats, ( includeFile ) ->
              if includeFile
                memo.push( filename )
              next( null, memo )
            )
        )
      , done )
    )
    utils

  getDeploymentEnvironment: ->
    switch process.env.CIRCLE_BRANCH
      when 'master'
        'production'
      when 'develop'
        'staging'
      else
        ''

  getPackage: ->
    require( './package.json' )

  getName: ->
    utils.getPackage().name

  getVersion: ->
    utils.getPackage().version

  getSha: ->
    process.env.CIRCLE_SHA1

  getBuildNum: ->
    process.env.CIRCLE_BUILD_NUM

  getArtifactsDir: ->
    process.env.CIRCLE_ARTIFACTS

  getZipFilename: ->
    "#{utils.getName()}-#{utils.getVersion()}-#{utils.getSha()}-#{utils.getBuildNum()}.zip"

  getDeployRemotePath: ->
    switch utils.getDeploymentEnvironment()
      when 'production'
        '/var/www/joukou.com'
      when 'staging'
        '/var/www/staging.joukou.com'
      else
        throw new Error( 'Invalid deployment environment!' )

  getScpCommand: ( { host } ) ->
    [
      'scp'
      '-o'
      'IdentityFile=/home/ubuntu/.ssh/id_joukou.com'
      '-o'
      'ControlMaster=no'
      path.join( utils.getArtifactsDir(), utils.getZipFilename() )
      "www-data@#{host}:#{path.join( '/tmp', utils.getZipFilename() )}"
    ].join( ' ' )

###*
@class joukou-control.gulpfile.tasks
@singleton

Task functions are defined independently of dependencies to enable re-use in
different lifecycles; e.g. single pass build vs watch based develop mode.
####
tasks =
  ###*
  @method sloc
  Counts SLOC (source lines of code). Of the source languages that we use it
  currently only supports CoffeeScript so gives a somewhat distorted view of
  reality.
  ###
  sloc: ->
    gulp.src( paths.src.coffee )
      .pipe( plugins.sloc( ) )

  ###*
  @method clean
  Removes the build directory.
  ###
  clean: ->
    gulp.src( paths.build, read: false )
      .pipe( plugins.rimraf( force: true ) )
      .on( 'error', plugins.util.log )

  ###*
  @method mkBuildDirs
  Creates required build directories.
  ###
  mkBuildDirs: ( done ) ->
    async.each( [ paths.testing.dest, paths.production.dir ], ( directory, next ) ->
      mkdirp( directory, next )
    , done )

  ###*
  @method coffeelint
  Lints CoffeeScript.
  ###
  coffeelint: ->
    gulp.src( paths.src.coffee )
      .pipe( lazypipes.coffeelint() )
      .pipe( plugins.coffeelint.reporter( 'fail' ) )
      .on( 'error', plugins.util.log )

  ###*
  @method coffee
  Compiles CoffeeScript to JavaScript.
  ###
  coffee: ->
    gulp.src( paths.src.coffee )
      .pipe( lazypipes.coffee() )
      .pipe( plugins.livereload( lrServer, silent: true ) )
      .on( 'error', plugins.util.log )

  ###*
  @method jade
  Compiles Jade to HTML.
  ###
  jade: ->
    gulp.src( paths.src.jade )
      .pipe( plugins.jade(
        pretty: true
      ))
      .pipe( gulp.dest( paths.testing.dest ) )
      # Remove `build/testing/index.html` from the stream as when being run as
      # part of the develop meta-task the same file will be modified again by
      # the import-polymer-elements task. If two livereload changed events for
      # the same file occur too fast in succession the browser appears to miss
      # the second event, so we simply don't fire the first event as we want the
      # final change to be loaded.
      .pipe( plugins.grepStream( path.join( '**', paths.testing.index ), invertMatch: true ) )
      .pipe( plugins.livereload( lrServer, silent: true ) )
      .on( 'error', plugins.util.log )

  ###*
  @method stylus
  Compiles Stylus to CSS.
  ###
  stylus: ->
    gulp.src( paths.src.stylus )
      .pipe( plugins.stylus(
        trace:true
        use: [ nib() ]
        errors: true
      ) )
      .pipe( gulp.dest( paths.testing.dest ) )
      .pipe( plugins.livereload( lrServer, silent: true ) )
      .on( 'error', plugins.util.log )

  ###*
  @method injectScriptTags
  1. Iterates through the list of `scripts` in `src/inject.yml` and appends a
  script tag to `build/testing/index.html` for every JavaScript file.
  2. Iterates recursively through the `build/testing/app` directory and appends
  a script tag to `build/testing/index.html` for every JavaScript file that is
  discovered.
  ###
  injectScriptTags: ( done ) ->
    fs.readFile( paths.testing.index, encoding: 'utf8', ( err, html ) ->
      return done( err ) if err

      $ = cheerio.load( html )
      $head = $( 'head' )

      { scripts } = yaml.safeLoad( fs.readFileSync( 'src/inject.yml', encoding: 'utf8' ) )

      utils.filterDir( path.join( paths.testing.dest, 'app' ), ( filename, stats, next ) ->
        next( /\.js$/.test( filename ) )
      , ( err, appScripts ) ->
        appScripts = appScripts.map( ( appScript ) ->
          path.relative( paths.testing.dest, appScript )
        )
        scripts = scripts.concat( appScripts )
        scripts.forEach( ( src ) ->
          $head.append( "<script src='#{src}'></script>\n" )
          return
        )

        fs.writeFile( paths.testing.index, $.html(), ->
          # We don't notify `lrServer` of the change here as you might expect as the importPolymerElements function will
          # modify the same file again later in the lifecycle.
          done()
          return
        )
        return
      )
      return
    )
    return

  injectStyleTags: ( done ) ->
    fs.readFile( paths.testing.index, encoding: 'utf8', ( err, html ) ->
      return done( err ) if err

      $ = cheerio.load( html )
      $head = $( 'head' )

      { styles } = yaml.safeLoad( fs.readFileSync( 'src/inject.yml', encoding: 'utf8' ) )

      utils.filterDir( path.join( paths.testing.dest, 'app' ), ( filename, stats, next ) ->
        next( /\.css$/.test( filename ) )
      , ( err, appStyles ) ->
        appStyles = (appStyles or []).map( ( appStyle ) ->
          path.relative( paths.testing.dest, appStyle )
        )
        addToHead = ( src ) ->
          $head.append( "<link href=\"#{src}\" rel=\"stylesheet\" type=\"text/css\"/>\n" )
          return

        (styles or []).forEach(addToHead)
        addToHead( "main.css" )
        (appStyles or []).forEach(addToHead)

        fs.writeFile( paths.testing.index, $.html(), ->
          # We don't notify `lrServer` of the change here as you might expect as the importPolymerElements function will
          # modify the same file again later in the lifecycle.
          done()
          return
        )
        return
      )
      return
    )
    return

  ###*
  @method importPolymerElements
  Iterates through the `build/testing/elements` directory and adds a link tag to `build/testing/index.html` for every
  custom element directory found.
  ###
  importPolymerElements: ( done ) ->
    fs.readFile( paths.testing.index, encoding: 'utf8', ( err, html ) ->
      return done( err ) if err

      $ = cheerio.load( html )
      $head = $( 'head' )

      fs.readdir( paths.testing.elements, ( err, files ) ->
        return done( err ) if err

        async.filter( files, ( file, next ) ->
          fs.lstat( path.join( paths.testing.elements, file ), ( err, stats ) ->
            if err
              done( err )
            else
              next( stats.isDirectory() )
          )
        , ( elements ) ->
          elements.forEach( ( element ) ->
            href = path.join( 'elements', element, 'index.html' )
            $head.append( "<link rel='import' href='#{href}'>\n" )
          )

          fs.writeFile( paths.testing.index, $.html(), ->
            lrServer.changed(
              body:
                files: [ path.join( __dirname, paths.testing.index ) ]
            )
            done()
          )
        )
      )
    )
    return

  ###*
  @method vulcanize
  Concatenates all the Polymer Web Components into one file.
  ###
  vulcanize: ->
    gulp.src( paths.testing.index )
      .pipe( plugins.vulcanize( dest: paths.production.dir ) )
      .pipe( gulp.dest( paths.production.dir ) )
      .pipe( plugins.livereload( lrServer, silent: true ) )

  ###*
  @method transformProductionIndex
  Convenience hook to modify production index HTML without needed to read/write
  the file as concatScripts task is already doing this for us.
  ###
  ###
  transformProductionIndex: ( $ ) ->
    $( "link[href*='main.css']" ).remove()
    $( 'head' ).append( "<link href='main.css' rel='stylesheet'>" )
    $('img').each( ( i ) ->
      $img = $( this )
      $img.attr( 'src', $img.attr( 'src' ).replace( '../testing/images', './images' ) )
    )
  ###

  ###*
  @method concatScripts
  Concatenate all the JavaScripts.

  TODO
  - merging source maps; can be done with combine-source-map or source-map
  ###
  concatScripts: ( done ) ->
    fs.readFile( paths.production.index, encoding: 'utf8', ( err, html ) ->
      return done( err ) if err

      $ = cheerio.load( html )

      elems = $( 'script' ).get()

      #tasks.transformProductionIndex( $ )

      async.map( elems, ( elem, next ) ->
        if elem.attribs.src
          fs.readFile( path.resolve( path.dirname( paths.production.index ), elem.attribs.src ), encoding: 'utf8', next )
        else
          next( null, elem.children[0].data )
      , ( err, scripts ) ->
        js = scripts.reduce( ( memo, script, i, array ) ->
          memo + '\n' + script
        , '' )
        fs.writeFile( paths.production.js, js, ->
          $( 'script' ).remove()
          $( 'head' ).append( "<script src='all.js'></script>\n" )

          fs.writeFile( paths.production.index, $.html(), ->
            lrServer.changed(
              body:
                files: [
                  path.join( __dirname, paths.production.index )
                  path.join( __dirname, paths.production.js )
                ]
            )
            done()
          )
        )
      )
    )

  ###*
  @method concatStyles
  Concatenate all the Styles.

  TODO
  - merging source maps; can be done with combine-source-map or source-map
  ###
  concatStyles: (done) ->
    fs.readFile( paths.production.index, encoding: 'utf8', ( err, html ) ->
      return done( err ) if err

      $ = cheerio.load( html )

      cssSelector = 'link[type="text/css"][rel="stylesheet"][href]:not([href^="//"]):not([href^="http"])'

      elems = $( cssSelector ).get()

      async.map( elems, ( elem, next ) ->
        fs.readFile( path.resolve( path.dirname( paths.production.index ), elem.attribs.href ), encoding: 'utf8', next )
      , ( err, styles ) ->
        css = styles.reduce( ( memo, style, i, array ) ->
          memo + '\n' + style
        , '' )
        fs.writeFile( paths.production.css, css, ->
          $( cssSelector ).remove()
          $( 'head' ).append( '<link href="main.css" rel="stylesheet" type="text/css"/>\n' )

          fs.writeFile( paths.production.index, $.html(), ->
            lrServer.changed(
              body:
                files: [
                  path.join( __dirname, paths.production.index )
                  path.join( __dirname, paths.production.css )
                ]
            )
            done()
          )
        )
      )
    )

  minifyScripts: ->
    gulp.src( paths.production.js )
      .pipe( plugins.size( title: 'unminified JavaScript' ) )
      .pipe( plugins.ngmin( dynamic: false ) )
      .pipe( plugins.uglify() )
      .pipe( plugins.size( title: 'minified JavaScript' ) )
      .pipe( gulp.dest( paths.production.dir ) )

  minifyCss: ->
    gulp.src( paths.production.css )
      .pipe( plugins.size( title: 'unminified CSS' ) )
      .pipe( plugins.minifyCss() )
      .pipe( plugins.size( title: 'minified CSS' ) )
      .pipe( gulp.dest( paths.production.dir ) )

  minifyHtml: ->
    gulp.src( paths.production.index )
      .pipe( plugins.size( title: 'unminified HTML' ) )
      .pipe( plugins.htmlmin( collapseWhitespace: true ) )
      .pipe( plugins.size( title: 'minified HTML' ) )
      .pipe( gulp.dest( paths.production.dir ) )

  ###
  <temp-hacks>
  ###
  copyAngularTemplates: ->
    gulp.src( 'build/testing/app/**/*.html' )
      .pipe( gulp.dest( 'build/production/app' ) )

  copyJS: ->
    gulp.src( 'src/**/*.js' )
    .pipe( gulp.dest( 'build/testing' ) )

  copyCss: ->
    gulp.src( paths.testing.css )
    .pipe( gulp.dest( 'build/production' ) )

  copyJson: ->
    gulp.src( 'src/**/*.json' )
    .pipe( gulp.dest( 'build/testing' ) )
    .pipe( gulp.dest( 'build/production' ) )

  copyKlayWorkerFile: ->
    gulp.src( 'bower_components/klay-js/klay-worker.js' )
    .pipe( gulp.dest( 'build/testing/vendor' ) )
    .pipe( gulp.dest( 'build/production/vendor' ) )

  copyFonts: ->
    gulp.src( 'src/fonts/**/*' )
      .pipe( gulp.dest( 'build/testing/fonts' ) )
      .pipe( gulp.dest( 'build/production/fonts' ) )

  copyFontAwesome: ->
    gulp.src( 'bower_components/font-awesome-stylus/fonts/**/*' )
      .pipe( gulp.dest( 'build/testing/fonts' ) )
      .pipe( gulp.dest( 'build/production/fonts' ) )

  ###
  </temp-hacks>
  ###

  ###*
  @method imagemin
  ###
  imagemin: ->
    gulp.src( paths.src.images )
      .pipe( plugins.imagemin( optimizationLevel: 0 ) )
      .pipe( gulp.dest( paths.testing.images ) )
      .pipe( plugins.livereload( lrServer, silent: true ) )

  copyImages: ->
    gulp.src( paths.src.images )
      .pipe( gulp.dest( paths.testing.images ) )
      .pipe( gulp.dest( paths.production.images ) )

  ###*
  @method unitTest
  ###
  unitTest: ( done ) ->
    child = spawn(
      path.join( __dirname, 'node_modules', '.bin', 'coffee' ),
      [
        path.join( __dirname, 'test', 'karma.coffee' )
        JSON.stringify(
          configFile: path.join( __dirname, 'test', 'karma.conf.coffee' )
          action: 'run'
        )
      ],
      {
        stdio: 'inherit'
      }
    )

    child.on( 'exit', ( code ) ->
      # Stop the server if it is still running
      child.kill() if child

      if code
        process.exit( code )
      else
        done()
    )

  protractorTest: ->
    gulp.src( [ 'test/e2e/**/*.coffee' ] )
      .pipe( plugins.protractor.protractor(
        configFile: 'test/protractor.conf.coffee'
        args: [
          '--baseUrl'
          'http://localhost:2100/'
        ]
      ) )
      .on( 'error', ( err ) ->
        throw err;
      )

  ###*
  @method coveralls
  ###
  coveralls: ->
    gulp.src( 'test/coverage/PhantomJS*/lcov.info' )
      .pipe( plugins.coveralls() )

  ###*
  Create a ZIP file of the production build for deployment.
  @method deployZip
  ###
  deployZip: ->
    gulp.src( "build/production/**/*" )
      .pipe( plugins.zip( utils.getZipFilename() ) )
      .pipe( gulp.dest( utils.getArtifactsDir() ) )

  deployNotification: ( done ) ->
    requestOptions =
      uri: 'https://api.flowdock.com/v1/messages/team_inbox/87d6d03d770e3ea007f7fe747fede5f4'
      method: 'POST'
      json:
        source: 'Circle'
        from_address: 'deploy+ok@joukou.com'
        subject: "Success: deployment to #{utils.getDeploymentEnvironment()} from build \##{utils.getBuildNum()}"
        content: '''
                 <b>joukou-control</b> has been deployed to https://staging.joukou.com.
                 '''
        from_name: ''
        project: 'joukou-control'
        tags: [ '#deploy', "\##{utils.getDeploymentEnvironment()}" ]
        link: 'http://staging.joukou.com'
    request( requestOptions, ->
      done()
    )
    return

#
# General tasks.
#

gulp.task( 'sloc', tasks.sloc )
gulp.task( 'coffeelint', tasks.coffeelint )

#
# Build related tasks.
#

gulp.task( 'clean:build', tasks.clean )
gulp.task( 'mkdir:build', [ 'clean:build' ], tasks.mkBuildDirs )
gulp.task( 'coffee:build', [ 'mkdir:build' ], tasks.coffee )
gulp.task( 'stylus:build', [ 'mkdir:build' ], tasks.stylus )
gulp.task( 'jade:build', [ 'mkdir:build' ], tasks.jade )
gulp.task( 'inject-script-tags:build', [ 'jade:build', 'coffee:build' ], tasks.injectScriptTags )
gulp.task( 'inject-style-tags:build', [ 'jade:build', 'stylus:build', 'inject-script-tags:build' ], tasks.injectStyleTags )
gulp.task( 'import-polymer-elements:build', [ 'inject-script-tags:build', 'inject-style-tags:build' ], tasks.importPolymerElements )
gulp.task( 'vulcanize:build', [ 'import-polymer-elements:build' ], tasks.vulcanize )
gulp.task( 'copy-js:build', [ 'mkdir:build' ], tasks.copyJS )
gulp.task( 'copy-json:build', [ 'mkdir:build' ], tasks.copyJson )
gulp.task( 'copy-fonts:build', [ 'mkdir:build' ], tasks.copyFonts )
gulp.task( 'copy-css:build', [ 'mkdir:build', 'stylus:build' ], tasks.copyCss )
gulp.task( 'copy-font-awesome:build', [ 'mkdir:build' ], tasks.copyFontAwesome )
gulp.task( 'copy-klay-worker:build', [ 'mkdir:build' ], tasks.copyKlayWorkerFile )
gulp.task( 'concat-scripts:build', [ 'vulcanize:build', 'copy-js:build', 'copy-json:build', 'copy-fonts:build', 'copy-font-awesome:build', 'copy-klay-worker:build' ], tasks.concatScripts )
gulp.task( 'concat-styles:build', [ 'copy-css:build', 'concat-scripts:build', 'stylus:build' ], tasks.concatStyles )
gulp.task( 'minify-scripts:build', [ 'concat-scripts:build', 'concat-styles:build' ], tasks.minifyScripts )
gulp.task( 'minify-css:build', [ 'concat-styles:build' ], tasks.minifyCss )
gulp.task( 'minify-html:build', [ 'concat-scripts:build', 'concat-styles:build' ], tasks.minifyHtml )

gulp.task( 'imagemin:build', [ 'mkdir:build' ], tasks.imagemin )

gulp.task( 'copy-images:develop', tasks.copyImages )
gulp.task( 'copy-images:build', [ 'mkdir:build' ], tasks.copyImages )

gulp.task( 'copy-angular-templates:build', [ 'jade:build' ], tasks.copyAngularTemplates ) # Work-around until angular-templatecache works

gulp.task( 'build:main', [ 'sloc', 'coffeelint', 'concat-scripts:build', 'concat-styles:build', 'copy-images:build', 'copy-angular-templates:build' ] )
gulp.task( 'build:minify', [ 'minify-css:build', 'minify-html:build', 'minify-scripts:build' ] )

gulp.task( 'build', [ 'build:main', 'build:minify' ] )

gulp.task( 'unit-test:build', [ 'build' ], tasks.unitTest )
#gulp.task( 'protractor-test:build', [ 'build' ], tasks.protractorTest )

gulp.task( 'test', [ 'unit-test:build' ] ) #, 'protractor-test:build' ] )

#
# Continuous integration.
#

gulp.task( 'ci', [ 'unit-test:build' ] ) # , 'protractor-test:build' ], tasks.coveralls )

#
# Continuous deployment.
#

gulp.task( 'zip:deploy', tasks.deployZip )

gulp.task( 'upload:deploy', [ 'zip:deploy' ], joukou.doPackageDeploymentUpload )
gulp.task( 'commands:deploy', [ 'upload:deploy' ], joukou.doPackageDeploymentCommands )
gulp.task( 'notification:deploy', [ 'commands:deploy' ], tasks.deployNotification )
gulp.task( 'deploy', [ 'notification:deploy' ] )

#
# Develop-related tasks.
#

gulp.task( 'coffee:develop', tasks.coffee )
gulp.task( 'stylus:develop', tasks.stylus )
gulp.task( 'jade:develop', tasks.jade )
gulp.task( 'inject-script-tags:develop', [ 'jade:develop', 'coffee:develop' ], tasks.injectScriptTags )
# Must inject script first as they will write at the same time
gulp.task( 'inject-style-tags:develop', [ 'jade:develop', 'stylus:develop', 'inject-script-tags:develop' ], tasks.injectStyleTags )
gulp.task( 'import-polymer-elements:develop', [ 'inject-style-tags:develop' ], tasks.importPolymerElements )
gulp.task( 'vulcanize:develop', [ 'import-polymer-elements:develop' ], tasks.vulcanize )
gulp.task( 'imagemin:develop', tasks.imagemin )

# no minification
gulp.task( 'develop:nm',  [ 'sloc', 'coffeelint', 'concat-scripts:build', 'concat-styles:build', 'copy-images:build', 'copy-angular-templates:build' ] )

gulp.task( 'develop', [ 'build:main' ], ->
  lrServer.listen( 35728, ( err ) ->
    if err
      plugins.util.log( err )

    gulp.watch( paths.src.coffee, [ 'sloc', 'coffeelint', 'coffee:develop' ] )
    gulp.watch( paths.src.stylus, [ 'stylus:develop' ] )
    gulp.watch( paths.src.jade, [ 'vulcanize:develop' ] )
    gulp.watch( paths.src.images, [ 'copy-images:develop' ] )
  )
)
gulp.task( 'default', [ 'develop' ] )
