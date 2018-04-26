$(document).on('shiny:sessioninitialized', function() {
  var access_token = localStorage.accessToken;
  Shiny.onInputChange("access_token", access_token);
});
