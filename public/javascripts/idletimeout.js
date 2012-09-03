// Basic idle timeout functionality using the timer from jquery.idletimer.js.

var IdleTimer = function(user_options) {
  var options = $.extend(default_options, user_options);
  var timer = null;
  var countdown = null;
  var self = this;

  $("#session-resume").bind("click", function(e) {
    e.preventDefault();
    self.onResume();
  });

  // Start the timer
  this.start = function() {
    self.checkSession(function(session_timeout) {
      var idle_timeout = session_timeout - options.countdown_length -
                         options.session_buffer + 1;
      timer = window.setTimeout(function() {self.onIdle()}, idle_timeout*1000);
    });
  };

  // Request the time remaining from the server
  this.checkSession = function(onSuccess) {
    $.ajax({
      timeout: 5000,
      url: RidePilot.urls['check_session'],
      headers: {
        // Do not update last_request_at when checking session timeout, which
        // would defeat the purpose of this script.
        'devise.skip_trackable': 1
      },
      error: function() {
        // Not sure if there's anything useful to do here.
      },
      success: function(data) {
        onSuccess(data["timeout_in"]);
      }
    });
  };

  this.touchSession = function(onSuccess) {
    $.ajax({
      timeout: 5000,
      url: RidePilot.urls['touch_session'],
      error: function() {
        // Not sure if there's anything useful to do here.
      },
      success: onSuccess
    });
  }

  this.startCountdown = function() {
    var counter = options.countdown_length;
    $("#session-timeout-warning span").html(counter);
    $("#session-timeout-warning").slideDown();

    countdown = window.setInterval(function() {
      if (--counter === 0) {
        window.clearInterval(countdown);
        self.onTimeout();
      } else {
        $("#session-timeout-warning span").html(counter);
      }
    }, 1000);
  };

  this.stopCountdown = function() {
    $("#session-timeout-warning").slideUp();
    window.clearInterval(countdown);
    countdown = null;
  };

  this.onIdle = function() {
    console.log(self);
    self.checkSession(function(session_timeout) {
      if (session_timeout <= options.countdown_length+options.session_buffer) {
        self.startCountdown();
      } else {
        self.start();
      }
    });
  };

  this.onResume = function() {
    self.stopCountdown();
    self.touchSession(function() {
      self.start();
    });
  };

  this.onTimeout = function() {
    // One last check to see if the session has been woken up in another tab
    self.checkSession(function(timeout) {
      if (timeout <= options.session_buffer) {
        window.location = RidePilot.urls['sign_out'];
      } else {
        self.stopCountdown();
        self.start();
      }
    });
  };
};

var default_options = {

    // Countdown duration in seconds
    countdown_length: 30,

    // Buffer to handle discrepancy between server timeout and local timeout
    session_buffer: 15
};
