// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('page:change', function() {

  var fileUploadForm = $('#avatar-selector'),
      fileInput = $('#file-select'),
      fileNameField = $('#avatar-selector :text'),
      fileSubmitButton = $('#avatar-selector :submit');

  // unhide the text field for showing the file name
  fileNameField.removeClass('hidden');

  // make the avatar selector toggleable
  fileUploadForm.hide();
  $('#avatar-change-btn')
    .removeClass('hidden')
    .on('click', function() {
      fileUploadForm.toggle();
      return false;
    });

  // disable the submit button
  fileSubmitButton.addClass('disabled');

  // when a file is selected, show its name in the text field and enable the
  // upload button
  fileInput.on('change', function() {    
    var fileName = fileInput.val().replace(/\\/g, '/').replace(/.*\//, '');
    fileNameField.val(fileName);
    fileSubmitButton.removeClass('disabled');
  });

  // when the form is submitted, prevent the default behavior, clear the file
  // name field and disable the submit button
  fileUploadForm.on('submit', function(event) {
    event.preventDefault();    
    fileNameField.val('');
    fileSubmitButton.addClass('disabled');
  });

  // submit the form via the jQuery-File-Upload plugin
  $(function() {    
    fileInput.fileupload({
      dataType: 'script',
      add: function(e, data) {
        fileSubmitButton.off('click').on('click', function() {
          data.submit();          
        });
      }
    });
  });
});