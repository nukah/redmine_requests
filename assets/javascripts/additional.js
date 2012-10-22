$(document).ready(function() {
	$(".hascontextmenu").each(function() {
        $(this).dblclick(function() {
                window.location.href = $(this).find("a").first().attr("href");
        });
	});
});