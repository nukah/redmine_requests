Event.observe(window, 'load', function() {
	$$(".hascontextmenu").each(function(item) {
        item.observe('dblclick', function() {
                window.location.href = item.select("a").first().readAttribute("href");
        });
	});
});