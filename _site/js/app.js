(function($)
{
    var router=new $.mobile.Router( [
       	{"login": {handler: "login",
          events: "s", // do when we show the page
          argsre: true
        } },
        {"register": {handler: "register",
          events: "s", // do when we show the page
          argsre: true
        } },
            {"forgot-password": {handler: "forgotPassword",
          events: "s", // do when we show the page
          argsre: true
        } },
            {"home": {handler: "home",
          events: "s", // do when we show the page
          argsre: true
        } }
	],
	{ 
        login: function(type, match, ui, page) {
        	console.log("login Handler");
        },
        forgotPassword: function(type, match, ui, page) {
            console.log("forgotPassword Handler");
        },
        home: function(type, match, ui, page) {
            console.log("home Handler");
        },
        register: function(type, match, ui, page) {
            console.log("Create-Account Handler");
        }
    });


    function onMobileInit() {
    console.log("mobile init");
    $.mobile.autoInitialize = false;
    }

    function onPageLoad() {// Document.Ready
    console.log("document ready");

    /////////////////////////////////////////////////////////////////////
    // this is the actual code that runs and sets everything off
    // pull the session out of the cookie.
    $(document).bind("mobileinit", onMobileInit);
    $(document).ready(onPageLoad);
})(jQuery);
