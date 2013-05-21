var loc = window.location.href;
function refresh() {
  $.get(loc, function(data) {
    $("div#content").html(data);
  });
}
$(document).ready(function() {
  setInterval(function() { refresh(); }, 10000);
});