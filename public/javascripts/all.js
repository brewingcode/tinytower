var timers = {
  username: 0,
  ajaxresult: 0
};

function runLater(name, t, fn) {
  if (timers[name]) {
    clearTimeout(timers[name]);
  }
  timers[name] = setTimeout(fn, t);
}

$(document).ready(function() {
  $('#username').keyup(function() {
    $('#ajaxresult').finish().html('').show();
    runLater('username', 500, function() {
      $.post("/setusername", {username:$('#username').val()})
      .done(function() {
        $('#ajaxresult').css('color', 'green').html('name saved');
      })
      .fail(function() {
        $('#ajaxresult').css('color', 'red').html('failed to save your name');
      })
      .always(function() {
        runLater('ajaxresult', 500, function() {
          $('#ajaxresult').fadeOut(3000);
        });
      });
    });
  });

  $('#newfloor').autocomplete({
    serviceUrl: '/newfloors'
  });
});
