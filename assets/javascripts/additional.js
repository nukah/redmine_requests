$("tr").filter(".hascontextmenu").click(function() {
  window.location.href = $(this).find("a").attr("href");
});