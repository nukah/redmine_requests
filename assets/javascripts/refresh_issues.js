var loc = window.location.href;
function refresh() {
  $.get(loc, function(data) {
    $("div.autoscroll").html(data);
  });
}
$(document).ready(function() {
  setInterval(function() { refresh(); }, 10000);
  console.log("refresh run");
});