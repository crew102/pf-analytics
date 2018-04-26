$(document).on('shiny:sessioninitialized', function(event) {
  var access_token = localStorage.accessToken;
  Shiny.onInputChange("access_token", access_token);
});
