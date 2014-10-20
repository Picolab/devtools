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


    function onMobileInit() {
    console.log("mobile init");
    $.mobile.autoInitialize = false;
    }

    function onPageLoad() {// Document.Ready
    console.log("document ready");
    //CloudOS.retrieveSession();

    /////////////////////////////////////////////////////////////////////
    // this is the actual code that runs and sets everything off
    // pull the session out of the cookie.
    $(document).bind("mobileinit", onMobileInit);
    $(document).ready(onPageLoad);
})(jQuery);
