
$.extend($.mobile, {
	changePageFromBase: function(base, to, options)
	{
		var el = $(to),
			toid = to.substr(to.lastIndexOf('-') + 1),
			toidC = toid.substr(0, 1).toUpperCase() + toid.substr(1),
			str,
			basel,
			newel;

		console.log('toid=', toid);
		console.log('toidC=', toidC);

		if (el.length) {
			$.mobile.changePage(to, options);
			return;
		}

		basel = $(base).clone()
		console.log('base=', base);

		console.info('basel.html()=', basel.html());
		str = basel.html() || "";

		str = str.replace('create_edit', toid)
				 .replace('Create_Edit', toidC);
		//console.info(str);

		str = '<div data-role="page" id="page-manager-location-' + toid + '">'
			+ str
			+ "</div>";
		console.info(str);

		$("body").append(str);

		$.mobile.changePage(to, options);
	}
});
