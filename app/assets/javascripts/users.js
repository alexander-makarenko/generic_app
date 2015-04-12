// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function ModelValidator(model, formSelector) {  
  if (typeof model === 'undefined') {
    throw new Error(this.constructor.name + ' cannot be instantiated without model name!');
  }

  this.model = model;

  this.formSelector = formSelector;

  this.url = '/' + model + 's/validate';

  this.$editedFields = $();

  this.validate = function(data) {
    var prevData;
    return function(data) {
      var self = this;
      if (data.length && JSON.stringify(data) !== JSON.stringify(prevData)) {
        prevData = data;
        $.post(self.url, data).done(function(response) {
          self.response = response;
          self.updateErrors();
          self.markInvalidFields();
          self.$lastFocused.focus();
        });
      }
    };
  }();
}

ModelValidator.prototype = {
  constructor: ModelValidator,

  errorDivClass: 'validation-errors',

  invalidFieldClass: 'has-error',

  $form: function() {
    var model = this.model,
        formSelector = this.formSelector;
    if (typeof formSelector !== 'undefined') {
      return $(formSelector);
    } else {
      return $('form').filter(function() {
        return (new RegExp('^new_' + model, 'i')).test($(this).attr('id')); // later modify to '^(new|edit)_'
      });
    }
  },

  $fields: function() {
    return this.$form().find('input:not([type="submit"], [type="hidden"])');    
  },

  $invalidFields: function() {
    var self = this;
    return self.$fields().filter(function() {
      return $(this).parent().hasClass(self.invalidFieldClass);
    });
  },

  considerEdited: function(field) {
    this.$editedFields = this.$editedFields.add(field);
  },

  dataToValidate: function() {
    return this.$editedFields.serializeArray();
  },

  buildErrorDiv: function() {
    if (!$.isEmptyObject(this.response)) {
      var $errorDiv = $('<div>');
      $errorDiv
        .addClass(this.errorDivClass)
        .html('<p>' + this.response.description + '</p><ul></ul>');
      $.each(this.response.errors, function(attr, messages) {
        $.each(messages, function(index, message) {
          $errorDiv.find('ul').append('<li>' + message + '</li>');
        });
      });
      return $errorDiv;
    } else {
      return $();
    }
  },

  markInvalidFields: function() {
    var self = this, $invalidField;
    $('.' + self.invalidFieldClass).removeClass(self.invalidFieldClass);
    if (!$.isEmptyObject(self.response)) {
      $.each(self.response.errors, function(attr, messages) {
        $invalidField = $('#' + self.model + '_' + attr);
        $invalidField.parent().addClass(self.invalidFieldClass);
      });
    }
  },

  updateErrors: function() {
    var $errorDiv = $('.' + this.errorDivClass),
        $newErrorDiv = this.buildErrorDiv();
    if ($errorDiv.length) {
      if ($newErrorDiv.length) {
        if ($newErrorDiv.text() !== $errorDiv.text()) {
          var height = $errorDiv.find('ul').outerHeight();
          $errorDiv.html($newErrorDiv.html());
          var newHeight = $errorDiv.find('ul').outerHeight();
          if (newHeight !== height) {
            $errorDiv.find('ul').outerHeight(height).animate({
              height: newHeight
            }, 200);
          }
          $errorDiv.find('li').hide().fadeIn(200);
        }
      } else {
        $errorDiv.slideUp(200, function() {
          $(this).remove();
        });
      }
    } else {
      $newErrorDiv.insertAfter(this.$form().find('h2')).hide().slideDown(200);
    }
  },

  enable: function() {
    var self = this;
    self.$fields()
      .on('focus', function() {
        self.$lastFocused = $(document.activeElement);
      })
      .on('input', function() {
        self.considerEdited(this);
        callDelayed(function() {
          self.validate(self.dataToValidate());
        }, 1000);
      })
      .on('blur', function() {
        self.validate(self.dataToValidate());
      });
    self.$invalidFields().length ? self.$invalidFields().first().focus() : self.$fields().first().focus();
    self.$invalidFields().each(function() {
      self.considerEdited(this);
    });
  }
};

$(document).on('page:change', function() {
  (new ModelValidator('user', '#signup')).enable();
});