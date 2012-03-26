Event.observe(window, 'load', function() {
	$$(".hascontextmenu").each(function(item) {
        item.observe('click', function() {
                window.location.href = item.select("a").first().readAttribute("href");
        });
	});
});