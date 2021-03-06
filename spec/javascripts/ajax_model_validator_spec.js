//= require application
//= require helpers/jasmine-jquery.js
//= require helpers/mock-ajax.js
//= require helpers/test_responses/signup_validation.js
//= require users

describe("Validator", function() {
  var validator;
  
  beforeEach(function() {
    validator = new Validator({
      model: 'foo',
      form: '#new_foo'
    });
    $.fx.off = true;
  });

  it("throws exception if instantiated without 'model' or 'form' option", function() {
    expect(function(){ new Validator({ model: 'foo' }) }).toThrow();
    expect(function(){ new Validator({ form: '#bar ' }) }).toThrow();
    expect(function(){ new Validator({ model: 'foo', form: '#bar ' }) }).not.toThrow();
  });

  it("has prototype's constructor property referencing Validator", function() {
    expect(validator.constructor).toBe(Validator);
  });

  it("has errorDivClass property defined", function() {
    expect(validator.errorDivClass).toEqual(jasmine.any(String));
  });

  it("has invalidFieldClass property defined", function() {
    expect(validator.invalidFieldClass).toEqual(jasmine.any(String));
  });

  it("has url property set to proper value", function() {
    expect(validator.url).toEqual('/foos/validate');
  });

  describe("placeErrors method takes errors content and", function() {
    var errors;

    beforeEach(function() {
      errors = $('<div>').addClass(validator.errorDivClass);
      loadFixtures('ajax_model_validation/form_without_errors.html');
    });

    describe("by default", function() {
      it("prepends it to form", function() {
        expect($('.' + validator.errorDivClass)).not.toExist();

        validator.placeErrors(errors);

        expect($('.' + validator.errorDivClass)).toEqual($('#new_foo').children(':first'));
      });
    });

    describe("when errorPlacement function was provided as option to constructor", function() {
      beforeEach(function() {
        validator = new Validator({
          model: 'foo',
          form: '#new_foo',
          errorPlacement: function(errors) {
            $('#new_foo').append(errors);
          }
        });
      });

      it("uses that function to detemine where to place errors", function() {
        expect($('.' + validator.errorDivClass)).not.toExist();

        validator.placeErrors(errors);

        expect($('.' + validator.errorDivClass)).toEqual($('#new_foo').children(':last'));
      });
    });
  });

  describe("$form method", function() {
    beforeEach(function() {
      loadFixtures('ajax_model_validation/multiple_forms.html');
    });

    it("returns form element based on provided selector", function() {
      validator = new Validator({ model: 'foo', form: '#baz' });

      expect(validator.$form()).toHaveLength(1);
      expect(validator.$form().first().attr('id')).toBe('baz');
    });
  });

  it("$fields method returns all form inputs except those of type 'submit' and 'hidden'", function() {
    loadFixtures('ajax_model_validation/form_without_errors.html');
    var $fields = validator.$fields();

    expect(validator.$fields()).toHaveLength(4);
    expect(validator.$fields()).toEqual($('#new_foo').find('input:not([type="submit"], [type="hidden"])'));
  });

  it("$invalidFields method returns fields whose parent has class set in invalidFieldClass property", function() {
    loadFixtures('ajax_model_validation/form_with_errors.html');
    expect(validator.$invalidFields()).toEqual($('.' + validator.invalidFieldClass).children('input'));
  });

  describe("$editedFields property", function() {
    beforeEach(function() {
      loadFixtures('ajax_model_validation/form_without_errors.html');
    });

    it("initially references an empty object", function() {
      expect(validator.$editedFields).toHaveLength(0);
    });

    it("holds all fields that have been marked as edited with considerEdited method", function() {
      var $fieldsAssumedEdited = $('#foo_second_attr, #foo_fourth_attr');
      $fieldsAssumedEdited.each(function() {
        validator.considerEdited(this);
      });

      expect(validator.$editedFields).toHaveLength(2);
      expect(validator.$editedFields).toEqual($fieldsAssumedEdited);
    });
  });

  it("dataToValidate method encodes fields considered edited as array of names and values", function() {
    loadFixtures('ajax_model_validation/form_without_errors.html');
    var $fieldsAssumedEdited = $('#foo_second_attr, #foo_fourth_attr');
    $fieldsAssumedEdited.each(function() {
      validator.considerEdited(this);
    });
    var nameValuePairs = validator.dataToValidate();
    
    expect(nameValuePairs.length).toBe(2);

    $.each(nameValuePairs, function() {

      expect(this.name).toMatch(/^foo\[/);
      expect(this.value).toEqual('');
    });
  });

  describe("validate method", function() {
    var data, request;

    beforeEach(function() {
      jasmine.Ajax.install();
      data = [{ name: 'foo', value: 'bar' }];
    });

    afterEach(function() {
      jasmine.Ajax.uninstall();
    });

    describe("sends provided array to server", function() {
      it("in POST request to correct URL", function() {
        validator.validate(data);
        request = jasmine.Ajax.requests.mostRecent();

        expect(request.url).toBe(validator.url);
        expect(request.method).toBe('POST');
      });

      it("unless it is empty", function() {
        validator.validate([]);
        
        expect(jasmine.Ajax.requests.count()).toEqual(0);

        validator.validate(data);

        expect(jasmine.Ajax.requests.count()).toEqual(1);
      });

      it("unless it is same as in previous request", function() {
        validator.validate(data);
        
        expect(jasmine.Ajax.requests.count()).toEqual(1);

        validator.validate(data);

        expect(jasmine.Ajax.requests.count()).toEqual(1);
      });
    });

    describe("after receiving server's response", function() {

      beforeEach(function() {
        loadFixtures('ajax_model_validation/form_without_errors.html');
        spyOn(validator, 'markInvalidFields');
        spyOn(validator, 'updateErrors');
        spyOnEvent('#foo_third_attr', 'focus');
        validator.$lastFocused = $('#foo_third_attr');
        validator.validate(data);
        jasmine.Ajax.requests.mostRecent().respondWith(testResponses.formValidation.withErrors);
      });

      it("calls updateErrors method", function() {
        expect(validator.updateErrors).toHaveBeenCalled();
      });

      it("calls markInvalidFields method", function() {
        expect(validator.markInvalidFields).toHaveBeenCalled();
      });

      it("restores focus on element that was focused before request was sent", function() {
        expect('focus').toHaveBeenTriggeredOn('#foo_third_attr');
      });
    });
  });

  describe("buildErrorDiv method", function() {
    var $errorDiv, errorMessages;

    describe("when server's response is empty", function() {
      beforeEach(function() {
        validator.response = {};
        $errorDiv = validator.buildErrorDiv();
      });

      it("returns empty object", function() {
        expect($errorDiv).toHaveLength(0);
      });
    });

    describe("when server's response is not empty", function() {
      beforeEach(function() {
        validator.response = testResponses.formValidation.withErrors.responseText;
        $errorDiv = validator.buildErrorDiv();
      });

      describe("returns object with HTML structure built from it that includes:", function() {
        it("<div> element with class set in errorDivClass property", function() {
          expect($errorDiv).toEqual('div');
          expect($errorDiv).toHaveClass(validator.errorDivClass);
        });

        it("<p> element with errors description", function() {
          expect($errorDiv).toContainElement('p');
          expect($errorDiv.find('p').text()).toEqual(validator.response.description);
        });

        it("<ul> element with <li> for each error message", function() {
          errorMessages = [];
          $.each(validator.response.errors, function(attr, messages) {
            $.each(messages, function(index, message) {
              errorMessages.push(message);
            });
          });

          expect($errorDiv).toContainElement('ul li');

          $errorDiv.find('li').each(function() {

            expect(errorMessages).toContain($(this).text());
          });
        });
      });
    });
  });

  describe("updateErrors method", function() {
    it("calls buildErrorDiv method", function() {
      spyOn(validator, 'buildErrorDiv').and.callThrough();
      validator.updateErrors();

      expect(validator.buildErrorDiv).toHaveBeenCalled();
    });

    describe("when some errors are currently listed", function() {
      var $errorDiv;

      beforeEach(function() {
        loadFixtures('ajax_model_validation/form_with_errors.html');
        $errorDiv = $('.' + validator.errorDivClass);
      });

      describe("and newly received errors", function() {
        
        describe("are different", function() {
          beforeEach(function() {
            validator.response = testResponses.formValidation.withErrors.responseText;
          });

          it("updates existing errors", function() {
            var errorTextBefore = $errorDiv.text();
            validator.updateErrors();
            var errorTextAfter = $errorDiv.text();
            
            expect(errorTextAfter).not.toEqual(errorTextBefore);
          });
        });

        describe("are the same", function() {
          it("does not change existing errors", function() {
            var errorTextBefore = $errorDiv.text();
            validator.updateErrors();
            var errorTextAfter = $errorDiv.text();
            
            expect(errorTextAfter).toEqual(errorTextBefore);
          });
        });
      });

      describe("and no new errors are received", function() {
        beforeEach(function(){
          validator.response = {};
        });

        it("removes existing errors from DOM", function() {
          expect($errorDiv).toBeInDOM();

          validator.updateErrors();

          expect($errorDiv).not.toBeInDOM();
        });
      });
    });

    describe("when no errors are currently listed", function() {

      beforeEach(function() {
        loadFixtures('ajax_model_validation/form_without_errors.html');
      });

      it("calls placeErrors method", function() {
        spyOn(validator, 'placeErrors');
        validator.updateErrors();

        expect(validator.placeErrors).toHaveBeenCalled();
      });

      describe("and some new are received", function() {
        beforeEach(function() {
          validator.response = testResponses.formValidation.withErrors.responseText;
        });

        it("adds new errors to DOM", function() {
          expect($('.' + validator.errorDivClass)).not.toExist();

          validator.updateErrors();

          expect($('.' + validator.errorDivClass)).toBeVisible();
        });
      });

      describe("and no new are received", function() {
        beforeEach(function() {
          validator.response = {};
        });

        it("does not add anything to DOM", function() {
          expect($('.' + validator.errorDivClass)).not.toExist();

          validator.updateErrors();

          expect($('.' + validator.errorDivClass)).not.toExist();
        });
      });
    });
  });

  describe("markInvalidFields method", function() {
    it("removes class set in invalidFieldClass property from all elements that have it", function() {
      loadFixtures('ajax_model_validation/form_with_errors.html');
      validator.response = {};
      
      expect($('.' + validator.invalidFieldClass)).toHaveLength(validator.$invalidFields().length);

      validator.markInvalidFields();

      expect($('.' + validator.invalidFieldClass)).toHaveLength(0);
    });

    it("adds class set in invalidFieldsClass property to parent of each field that is invalid as per server's response", function() {
      var $invalidField;
      loadFixtures('ajax_model_validation/form_without_errors.html');
      validator.response = testResponses.formValidation.withErrors.responseText;

      expect($('.' + validator.invalidFieldClass)).toHaveLength(0);

      validator.markInvalidFields();

      $.each(validator.response.errors, function(attr, messages) {
        $invalidField = $('#' + validator.model + '_' + attr);

        expect($invalidField.parent()).toHaveClass(validator.invalidFieldClass);
      });      
    });
  });

  describe("enable method", function() {
    it("focuses first invalid field if there is any", function() {
      loadFixtures('ajax_model_validation/form_with_errors.html');
      spyOnEvent('#foo_second_attr', 'focus');
      validator.enable();

      expect('focus').toHaveBeenTriggeredOn('#foo_second_attr');
    });

    it("focuses first field if there are no invalid fields", function() {
      loadFixtures('ajax_model_validation/form_without_errors.html');
      spyOnEvent('#foo_first_attr', 'focus');
      validator.enable();

      expect('focus').toHaveBeenTriggeredOn('#foo_first_attr');
    });

    it("marks every invalid fields as edited by calling considerEdited method", function() {
      loadFixtures('ajax_model_validation/form_with_errors.html');
      spyOn(validator, 'considerEdited');
      validator.enable();

      expect(validator.considerEdited.calls.count()).toEqual(validator.$invalidFields().length);
    });

    describe("when any of fields receives", function() {
      beforeEach(function() {
        loadFixtures('ajax_model_validation/form_without_errors.html');
      });

      describe("focus event", function() {
        it("stores this field in $lastFocused property", function() {
          validator.enable();

          expect(validator.$lastFocused).not.toEqual('#foo_third_attr');

          $('#foo_third_attr').focus();

          expect(validator.$lastFocused).toEqual('#foo_third_attr');
        });
      });

      describe("input event", function() {
        it("marks this field as edited by calling considerEdited method", function() {
          spyOn(validator, 'considerEdited');
          validator.enable();

          expect(validator.considerEdited).not.toHaveBeenCalled();

          $("#foo_second_attr").trigger('input');

          expect(validator.considerEdited).toHaveBeenCalledWith($('#foo_second_attr').get());
        });

        it("calls validate method after timeout, passing it data for validation", function() {
          jasmine.clock().install();
          spyOn(validator, 'validate');
          validator.enable();
          $("#foo_second_attr").trigger('input');
          jasmine.clock().tick(500);

          expect(validator.validate).not.toHaveBeenCalled();

          jasmine.clock().tick(1001);

          expect(validator.validate).toHaveBeenCalledWith(validator.dataToValidate());

          jasmine.clock().uninstall();
        });
      });

      describe("blur event", function() {
        it("calls validate method, passing it data for validation", function() {
          spyOn(validator, 'validate');
          validator.enable();

          expect(validator.validate).not.toHaveBeenCalled();

          $("#foo_second_attr").trigger('blur');

          expect(validator.validate).toHaveBeenCalledWith(validator.dataToValidate());
        });
      });
    });
  });
});