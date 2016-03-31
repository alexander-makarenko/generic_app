// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('page:change', function() {
  $('#feature-list .collapse').on('show.bs.collapse hide.bs.collapse', function() {
    $(this).parent().find('.glyphicon').toggleClass('glyphicon-chevron-right glyphicon-chevron-down');
  });
});