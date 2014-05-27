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

function missionCheckboxes(clazz) {
  $('input.'+clazz).change(function() {
    $.post("/togglemission", {
      name: $(this).val(),
      which: clazz
    })
    .always(function() {
      window.location.href = '/missions';
    });
  });
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

  $('#newfloor').select2({
    placeholder: "Add a new floor"
  }).change(function() {
    $.post("/addfloor", {
      floor: $('#newfloor').val(),
      story: $('tr.userFloor').length + 1
    })
    .always(function() {
      window.location.href = '/';
    });
  });

  $('tr:nth-child(2) > td:last-child').html('<a href="">X</a>').click(function(e) {
    e.preventDefault();
    $.post("/removefloor", {
      story: $('td:nth-child(1)', $(this).parent()).text()
    }).always(function() {
      window.location.href = '/';
    });
  });

  missionCheckboxes('finish');
  missionCheckboxes('undo');
});
