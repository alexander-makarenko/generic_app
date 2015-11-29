// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


function toggleEmailConfirmationFields() {
  var $toggleableRows = $('.user-info .padded'),
      $toggle = $('.user-info .collapse-toggle'),
      $spanWithIcon = $toggle.find('span.glyphicon');

  $toggleableRows.hide();
  $toggle.on('click', function() {
    $toggleableRows.toggle();
    $spanWithIcon.toggleClass('glyphicon-menu-down glyphicon-menu-up');
  });
}

function pageIsScrolledToAlmostBottom() {
  return $(window).scrollTop() > $(document).height() - $(window).height() - 250;
}


function enableEndlessScrolling() {
  if ($('.pagination').length) {
    $(window).scroll(function() {
      var url = $('.pagination .next a').attr('href');
      if (url && url !== '#' && pageIsScrolledToAlmostBottom()) {
        $('.pagination').empty();
        $('.ajax-in-progress').removeClass('hidden');
        $.getScript(url, function() {
          $('.ajax-in-progress').addClass('hidden');
        });
      }
    });
    $(window).scroll();
  }
};


function Validator(settings) {

  var self = this;

  $.each(['model', 'form'], function(index, value) {
    if (typeof settings[value] === 'undefined') {
      throw new Error(self.constructor.name + " cannot be instantiated without '"
        + value + "' parameter");
    }
  });

  this.model = settings.model;

  this.url = '/' + this.model + 's/validate';

  this.$form = function() {
    return $(settings.form);
  };

  if (typeof settings.errorPlacement !== 'undefined') {
    this.placeErrors = settings.errorPlacement;
  } else {
    this.placeErrors = function(errors) {
      self.$form().prepend(errors);
    };
  }

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

Validator.prototype = {
  constructor: Validator,

  errorDivClass: 'validation-errors',

  invalidFieldClass: 'has-error',

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
      this.placeErrors($newErrorDiv);
      $newErrorDiv.hide().slideDown(200);
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
  
  new Validator({
    model: 'user',
    form: '#signup',
    errorPlacement: function(errors) {
      $('#signup .panel-body').prepend(errors);
    }
  }).enable();

  toggleEmailConfirmationFields();

  enableEndlessScrolling();
});