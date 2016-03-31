// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function showSearchFields() {
  $('#users tr.hidden').removeClass('hidden');
}

function toggleLoadingSpinner() {
  $('.loading').toggleClass('hidden');
}

function makeUsersTableRowsClickable() {
  $('.clickable-row').off('click').on('click', function() {
    window.document.location = $(this).data('href');
  });
}

function togglePaginationLinks() {
  $('div.pagination').toggleClass('hidden');
}

function pageIsScrolledToAlmostBottom() {
  return $(window).scrollTop() > $(document).height() - $(window).height() - 300;
}

function enableEndlessScrolling() {
  $(window).off('scroll');
  if ($('.pagination').length) {
    var ready = true;
    $(window).scroll(function() {
      var url = $('div.pagination .next a').attr('href');
      if (ready && url && url !== '#' && pageIsScrolledToAlmostBottom()) {
        ready = false;
        var data = { task: 'load_next_page' };
        togglePaginationLinks();
        toggleLoadingSpinner();
        $.ajax({
          url: url,
          data: data,
          dataType: 'script'
        })
        .done(makeUsersTableRowsClickable)
        .done(togglePaginationLinks)
        .done(toggleLoadingSpinner)
        .done(function() {
          ready = true;
        });
      }
    });
    $(window).scroll();
  }
};

function makeUsersTableSortableViaAjax() {
  $('.main').on('click', '#users th a', function() {
    var url, $form, data;
    url = this.href;
    $form = $(this).closest('form');
    $form.find(':hidden').remove(); // remove the hidden form fields, because the information about sort order and direction is available in the url
    data = $form.serializeArray();
    data.push({ name: 'task', value: 'sort' });    
    $.ajax({
      url: url,
      data: data,
      dataType: 'script'
    })
    .done(showSearchFields)
    .done(enableEndlessScrolling);    
    return false;
  });
}

function makeUsersTableSearchableViaAjax() {
  showSearchFields();
  $('.main').on('blur', '#users :text', function() {
    var url, $form, data;
    $form = $(this.form);
    url = $form.attr('action');
    data = $form.serializeArray();
    data.push({ name: 'task', value: 'search' });
    $.ajax({
      url: url,
      data: data,
      dataType: 'script'
    })
    .done(enableEndlessScrolling);
    return false;
  });
}


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
    var $errorDiv    = $('.' + this.errorDivClass);
    var $newErrorDiv = this.buildErrorDiv();
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
        }, 750);
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
    form: '#signupForm',
    errorPlacement: function(errors) {
      $('#signupForm').prepend(errors);
    }
  }).enable();

  enableEndlessScrolling();  
  makeUsersTableSortableViaAjax();
  makeUsersTableSearchableViaAjax();
  makeUsersTableRowsClickable();  
});