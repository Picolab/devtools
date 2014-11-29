(function($)
{
    var router = new $.mobile.Router( [
       	{"#login": {handler: "login",
          events: "s", // do when we show the page
          argsre: true
        } },
        {"#register": {handler: "register",
          events: "s", // do when we show the page
          argsre: true
        } },
            {"#forgot-password": {handler: "forgotPassword",
          events: "s", // do when we show the page
          argsre: true
        } },
            {"#home": {handler: "home",
          events: "s", // do when we show the page
          argsre: true
        } },


            {"#listing": {handler: "listing",
          events: "s", // do when we show the page
          argsre: true
        } },
            {"#registering-ruleset": {handler: "registeringRuleset",
          events: "s", // do when we show the page
          argsre: true
        } },
            {"#confirming-deletion": {handler: "confirmingDeletion",
          events: "s", // do when we show the page
          argsre: true
        } },
            {"#updating-url": {handler: "updatingUrl",
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
        },


        listing: function(type, match, ui, page) {
            console.log("listing Handler");
        },
        registeringRuleset: function(type, match, ui, page) {
            console.log("registering Ruleset Handler");
        },
        confirmingDeletion: function(type, match, ui, page) {
            console.log("confirming Deletion Handler");
        },
        updatingUrl: function(type, match, ui, page) {
            console.log("updating Url Handler");
        }
    });


    function onMobileInit() {
    	console.log("mobile init");
    	$.mobile.autoInitialize = false;
    }

    function onPageLoad() {// Document.Ready
    	console.log("document ready");
    }

    /////////////////////////////////////////////////////////////////////
    // this is the actual code that runs and sets everything off
    // pull the session out of the cookie.
    $(document).bind("mobileinit", onMobileInit);
    $(document).ready(onPageLoad);
})(jQuery);
