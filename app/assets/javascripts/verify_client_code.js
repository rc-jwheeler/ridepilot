// function to check if need to verify code
function check_if_verify_client_code(url, callback_fn) {
  $.ajax({
    url: url,
    success: function(data) {
      callback_fn(data);
    }
  });
}


// prompt dialog to verify customer code
function verify_client_code(code, code_verify_url, callback_fn, abort_fn) {
  bootbox.confirm({
    message: 'The customer code is: <b>' + code + '</b>. Please confirm.', 
    buttons: {
        confirm: {
            label: 'Confirm'
        },
        cancel: {
            label: 'Abort'
        }
    }, 
    callback: function(result) {
      if(result) {
        // flag as confirmed
        $.ajax({
          url: code_verify_url,
          type: 'POST'
        }).done(function() {
          //proceed callback
          if(callback_fn) {
            callback_fn();
          }
        });
      } else {
        if(abort_fn) {
          abort_fn();
        }
      }
    }
  });
}