//= require application
//= require helpers/jasmine-jquery.js

describe("makeClosable function", function() {
  beforeEach(function() {
    $.fx.off = true;
    loadFixtures('closable.html');
  });

  it("appends <div> with class 'close-button' and X symbol inside it to element with class 'closable'", function() {
    expect($('.close-button')).not.toExist();
    
    makeClosable();
    var x = $('<foo>').html('&times;').text();

    expect($('.closable .close-button')).toHaveText(x);
  });

  it("hides closable element when <div> with X symbol is clicked", function() {
    makeClosable();

    expect($('.closable')).toBeVisible();

    $('.close-button').trigger('click');

    expect($('.closable')).toBeHidden();    
  });
});