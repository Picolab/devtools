(function($)
{
    var router=new $.mobile.Router( [
       	{"#page-one": {handler: "pageOneHandler",
          events: "s", // do when we show the page
          argsre: true
        } },
        {"#page-two": {handler: "pageTwoHandler",
          events: "s", // do when we show the page
          argsre: true
        } }
	],
	{ 
        pageOneHandler: function(type, match, ui, page) {
        	console.log("page One Handler");
        },
        pageTwoHandler: function(type, match, ui, page) {
            console.log("page Two Handler");
        }
    });
})(jQuery);
