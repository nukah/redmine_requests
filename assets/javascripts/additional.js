function RowClick(el) {
	row = $('#issue-' + el);
	link = '/issues/'+el;
	row.dblclick(function() {
		window.location = link;
	});
}