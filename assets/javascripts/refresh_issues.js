var loc = window.location.href;
function refresh() {
  $.get(loc, function(data) {
    $("div.autoscroll").html(data);
  });
}
$(document).ready(function() {
  refresh();
});