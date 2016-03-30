// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('page:change', function() {

  // clear errors when the modal is closed
  $('#signinModal').on('hidden.bs.modal', function(event) {
    $(this).find('.alert').remove();
  });

  // don't show the modal on the signin page
  if ($('.main #signinForm').length || $('.main #signupForm').length) {
    $("header nav a[data-toggle='modal']").attr('data-toggle', '');
  }
});