// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('page:change', function() {

  var $avatarChangeLink = $('.photo a:first');
  var $avatarUploadForm = $('.photo form:last-child');
  var $fileInput        = $avatarUploadForm.find(':file');
  var $fileNameField    = $avatarUploadForm.find(':text');
  var $fileSubmitButton = $avatarUploadForm.find(':submit');

  // make the avatar upload form toggleable
  $avatarUploadForm.hide();
  $avatarChangeLink.on('click', function() {
    this.blur();
    $avatarUploadForm.toggle();
    return false;
  });

  // unhide the text field and disable the submit button
  $fileNameField.removeClass('hidden');
  $fileSubmitButton.addClass('disabled');

  // when a file is selected, show its name in the text field and enable the
  // upload button
  $fileInput.on('change', function() {
    var fileName = $fileInput.val().replace(/\\/g, '/').replace(/.*\//, '');
    $fileNameField.val(fileName);
    $fileSubmitButton.removeClass('disabled');
  });

  // when the form is submitted, prevent the default behavior, clear the file
  // name field and disable the submit button
  $avatarUploadForm.on('submit', function(event) {
    event.preventDefault();
    $fileNameField.val('');
    $fileSubmitButton.addClass('disabled');
  });

  // submit the form via the jQuery-File-Upload plugin
  $(function() {
    $fileInput.fileupload({
      dataType: 'script',
      add: function(e, data) {
        $fileSubmitButton.off('click').on('click', function() {
          data.submit();
        });
      }
    });
  });
});