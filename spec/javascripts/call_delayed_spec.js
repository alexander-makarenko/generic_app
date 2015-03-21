//= require application

describe("callDelayed function", function() {
  var callback;

  beforeEach(function() {
    callbackFunction = jasmine.createSpy('callbackFunction');
    jasmine.clock().install();
  });

  afterEach(function() {
    jasmine.clock().uninstall();
  });

  it("executes provided callback after specified time", function() {
    callDelayed(function() {
      callbackFunction();
    }, 200);
    
    expect(callbackFunction).not.toHaveBeenCalled();
    jasmine.clock().tick(201);
    expect(callbackFunction).toHaveBeenCalled();
  });

  it("cancels original callback if called again before it was executed", function() {
    callDelayed(function() {
      callbackFunction();
    }, 200);

    jasmine.clock().tick(199);
    expect(callbackFunction).not.toHaveBeenCalled();

    callDelayed(function() {
      callbackFunction();
    }, 100);

    jasmine.clock().tick(2);
    expect(callbackFunction).not.toHaveBeenCalled();
    jasmine.clock().tick(99);
    expect(callbackFunction).toHaveBeenCalled();
  });
});