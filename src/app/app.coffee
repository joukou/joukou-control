###*
This is our main app configuration file. It kickstarts the whole process by
requiring all the modules from `src/app` that we need. We must load these now
to ensure the routes are loaded. We only require the top-level module, and allow
the submodules to require their own submodules.
###
AppCtrl = ( $rootScope, $scope, $location, USER_ROLES, AuthService, $log ) ->
  ###*
  Main application controller. This is a good place for logic not specific to
  the template or route, such as menu logic or page title wiring.
  ###
  # Initialize authentication. Based on
  # https://medium.com/opinionated-angularjs/7bbf0346acec
  $scope.currentUser = null
  $scope.userRoles = USER_ROLES
  $scope.isAuthorized = AuthService.isAuthorized
  $scope.validateHeaderAndFooter = (pageData) ->
    hideHeader = (if pageData.hideHeader then pageData.hideHeader else false)
    hideFooter = (if pageData.hideFooter then pageData.hideFooter else false)
    $rootScope.hideHeader = hideHeader
    $rootScope.hideFooter = hideFooter
  $scope.onStateChangeSuccess = (event,toState,toParams,fromState,fromParam) ->
    if not toState or not toState.data
      return
    $log.debug( "stateChangeSuccess = #{toState.data.pageTitle}" )
    return if !(angular.isDefined( toState.data.pageTitle ) )
    $scope.pageTitle = toState.data.pageTitle + ' | Joukou'
    $scope.validateHeaderAndFooter(toState.data)
  # Handle page title changes
  $scope.$on( '$stateChangeSuccess', $scope.onStateChangeSuccess )

AppCtrl.$inject = ['$rootScope', '$scope', '$location', 'USER_ROLES', 'AuthService', '$log']

Run = ( ApiService, env, Hyperagent ) ->
  ###*
  Use the main application's run method to execute any code after services have
  been instantiated.
  ###
  new Hyperagent.Resource( env.getApiBaseUrl() ).fetch().then(
    (( root ) ->
      ApiService.saveLinks( root.links )
    ),
    ((error) ->
      if(error.status is 404)
        console.error('API can not be accessed!')
        console.error(error)
      # ApiService.setNotAvailable(true);
    ))
Run.$inject = [ 'ApiService', 'env', 'Hyperagent']

Config = ( $stateProvider, $urlRouterProvider ) ->
  ###*
  All routing is performed by the submodules that are included (e.g.
  ngJoukou.signin), as that is where the app's functionality is really
  defined. So all we need to do in `app.coffee` is specify a default route to
  follow, which route of course is defined in a submodule. In this case, our
  `home` module is where we want to start, which has a defined route for
  `/home` in `src/app/home/home.coffee`.
  ###
  $urlRouterProvider.otherwise( '/home' )

Config.$inject = ['$stateProvider', '$urlRouterProvider']

angular.module( 'ngJoukou', [
  'ngJoukou.api'
  'ngJoukou.env'
  'ngJoukou.angularPolymer'
  'ngJoukou.contact'
  'ngJoukou.home'
  'ngJoukou.signin'
  'ngJoukou.solutions'
  'ngJoukou.marketplace'
  'ngJoukou.grapheditor'
  'ngJoukou.persona'
  'ngJoukou.graphs'
  'ngJoukou.privacy'
  'ngJoukou.product'
  'ngJoukou.pricing'
  'ngJoukou.authCallback'
  'ngJoukou.terms'
  'ui.router'
  'ui.router.stateHelper'
  'eee-c.angularBindPolymer'
  'ui.bootstrap'
  'ngMaterial'
] )
.config(Config)
.run( Run )
.controller( 'AppCtrl', AppCtrl)
