angular.module('Courses.directives')
.directive 'sectionModal', () ->
    templateUrl: 'partials/directives/sectionModal.html'

    scope:
      isModalOpen: '='
      modalSection: '='

    link: (scope, iElement, iAttrs, controller) ->
      $(iElement).foundation()

    controller: ($scope, $element, $attrs, $transclude, otherInjectables) ->
      $scope.$watch 'isOpen', (newValue, oldValue) ->
        $(modal).foundation('reveal', newValue)
