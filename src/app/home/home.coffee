HomeCtrl = ( $scope, $location, AnchorSmoothScroll, env, $timeout ) ->
  $scope.carouselInterval = 5000
  $scope.slides = [
    {
      active: true,
      header: "The Zen of Data 1",
      caption: "Liberate your Data with an effective integration solution that improves business processes and creates value."
    },
    {
      active: false,
      header: "The Zen of Data 2",
      caption: "Liberate your Data with an effective integration solution that improves business processes and creates value."
    },
    {
      active: false,
      header: "The Zen of Data 3",
      caption: "Liberate your Data with an effective integration solution that improves business processes and creates value."
    },
    {
      active: false,
      header: "The Zen of Data 4",
      caption: "Liberate your Data with an effective integration solution that improves business processes and creates value."
    },
    {
      active: false,
      header: "The Zen of Data 5",
      caption: "Liberate your Data with an effective integration solution that improves business processes and creates value."
    },
    {
      active: false,
      header: "The Zen of Data 6",
      caption: "Liberate your Data with an effective integration solution that improves business processes and creates value."
    }
  ]
  $scope.disableSignIn = env.disableSignIn()
  $scope.scrollToTissue = ->
    $scope.scrollTo('tissue')
  $scope.scrollTo = (hash) ->
    $location.hash(hash)
    AnchorSmoothScroll.scrollTo(hash)
  $timeout(->
    angular.element("carousel").find("a.right, a.left").remove()
  , 0)

HomeCtrl.$inject = ['$scope', '$location', 'AnchorSmoothScroll', 'env', '$timeout']

Config = ( $stateProvider, USER_ROLES ) ->
  $stateProvider
  .state( 'home',
    url: '/home'
    views:
      main:
        controller: 'HomeCtrl'
        templateUrl: 'app/home/home.html'
    data:
      pageTitle: 'Home'
  )
  .state( 'home-what',
    url: '/home/what-are-we'
    views:
      main:
        controller: 'HomeCtrl'
        templateUrl: 'app/home/what.html'
    data:
      pageTitle: 'What Are We?'
  )
  .state( 'home-overview',
    url: '/home/overview'
    views:
      main:
        controller: 'HomeCtrl'
        templateUrl: 'app/home/overview.html'
    data:
      pageTitle: 'Solutions Overview'
  )
  .state( 'home-functions',
    url: '/home/functions'
    views:
      main:
        controller: 'HomeCtrl'
        templateUrl: 'app/home/functions.html'
    data:
      pageTitle: 'Functions Overview'
  )
  .state( 'home-example',
    url: '/home/example'
    views:
      main:
        controller: 'HomeCtrl'
        templateUrl: 'app/home/example.html'
    data:
      pageTitle: 'Joukou Example'
  )

Config.$inject = ['$stateProvider', 'USER_ROLES']

angular.module( 'ngJoukou.home', [
  'ui.router'
  'ngJoukou.header'
  'ngJoukou.footer'
  'ngJoukou.auth',
  'ui.bootstrap'
] )
.config(Config)
.controller( 'HomeCtrl', HomeCtrl)
