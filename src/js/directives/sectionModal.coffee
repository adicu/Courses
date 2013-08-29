angular.module('Courses.directives')
.directive 'sectionModal', () ->
    templateUrl: 'partials/directives/sectionModal.html'

    scope:
      calendar: '='
      modalSection: '='
      removeCourse: '='

    link: (scope, iElement, iAttrs, controller) ->
      $(iElement).foundation()

    controller: ($scope, $element, $attrs, $transclude, otherInjectables) ->
      calendar = $scope.calendar

      $scope.$watch 'isOpen', (newValue, oldValue) ->
        $(modal).foundation('reveal', newValue)

      $scope.removeCourse = (id) ->
        $scope.closeModal()
        calendar.removeCourse id
        calendar.updateURL()

      $scope.closeModal = () ->
        $scope.isModalOpen = false
      $scope.openModal = () ->
        $scope.isModalOpen = true

      $scope.changeSections = (section) ->
        closeModal()
        course = section.parent
        calendar.changeSections course
