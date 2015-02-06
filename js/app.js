(function($)
{
  var router = new $.mobile.Router( [
   {"#page-authorize": {handler: "pageAuthorize",
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
          pageAuthorize: function(type, match, ui, page) {
            console.log("manage fuse: authorize page");
            $.mobile.loading("hide");
          }, 
          
          home: function(type, match, ui, page) {
            console.log("home Handler");
          },


          listing: function(type, match, ui, page) {
            console.log("listing Handler");

            //get the ruleset here using CloudOS??
            //var rulesets_list = Devtools.getRulesets();
            console.log(Devtools.getRulesets());
            

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
        },
      { 
        defaultHandler: function(type, ui, page) {
          console.log("Default handler called due to unknown route (" + type + ", " + ui + ", " + page + ")");
        },
        defaultHandlerEvents: "s",
        defaultArgsRe: true

      });

function plant_authorize_button()
{
        //Oauth through kynetx
        console.log("plant authorize button");
        var OAuth_kynetx_URL = CloudOS.getOAuthURL();
        $('#authorize-link').attr('href', OAuth_kynetx_URL);
        var OAuth_kynetx_newuser_URL = CloudOS.getOAuthNewAccountURL();
        $('#create-link').attr('href', OAuth_kynetx_newuser_URL);

      };

      function onMobileInit() {
       console.log("mobile init");
       $.mobile.autoInitialize = false;
     }

    function onPageLoad() {// Document.Ready
    	console.log("document ready");
      CloudOS.retrieveSession();


  // only put static stuff here...
  plant_authorize_button();

  $('.logout').off("tap").on("tap", function(event)
  {
            CloudOS.removeSession(true); // true for hard reset (log out of login server too)
            $.mobile.changePage('#page-authorize', {
              transition: 'slide'
            }); // this will go to the authorization page.


          });

  try {
    var authd = CloudOS.authenticatedSession();
    if(authd) {
      console.log("Authorized");
      document.location.hash = "#home";
    } else {  
      console.log("Asking for authorization");
      document.location.hash = "#page-authorize";
    }
  } catch (exception) {

  } finally {
    $.mobile.initializePage();
    $.mobile.loading("hide");
  }

}

    /////////////////////////////////////////////////////////////////////
    // this is the actual code that runs and sets everything off
    // pull the session out of the cookie.
    $(document).bind("mobileinit", onMobileInit);
    $(document).ready(onPageLoad);
  })(jQuery);
