angular.module('Courses.directives')
.directive 'sectionModal', () ->
    templateUrl: 'partials/sectionModal.html'

    link: (scope, elm, attrs) ->
      scope.$on 'modalStateChange', (event, state) ->
        modal = angular.element elm.children()[0]
        modal.foundation('reveal', state)