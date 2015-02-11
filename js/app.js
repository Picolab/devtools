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
           // var json_text = Devtools.getRulesets();
           // var ruleset_obj = JSON.parse(json_text);

           // console.log(ruleset_obj);

          var obj = '[{"rid":"b506607x0.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/HelloWorld.krl"},{"rid_index":0,"last_modified":1418237853,"rid":"b506607x0.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/HelloWorld.krl","prefix":"b506607"},{"rid":"b506607x1.dev","uri":"w.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl"},{"rid_index":1,"last_modified":1418234018,"rid":"b506607x1.prod","uri":"w.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl","prefix":"b506607"},{"last_modified":1422397298,"rid":"b506607x10.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl"},{"rid_index":10,"last_modified":1423525230,"rid":"b506607x10.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl","prefix":"b506607"},{"rid":"b506607x11.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl"},{"rid_index":11,"last_modified":1418237853,"rid":"b506607x11.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl","prefix":"b506607"},{"last_modified":1418234156,"rid":"b506607x12.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlog.krl"},{"rid_index":12,"rid":"b506607x12.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlog.krl","prefix":"b506607"},{"last_modified":1418238023,"rid":"b506607x13.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlogData.krl"},{"rid_index":13,"rid":"b506607x13.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlogData.krl","prefix":"b506607"},{"last_modified":1423689382,"rid":"b506607x14.dev","uri":"https://raw.githubusercontent.com/kre/devtools/gh-pages/ruleSets/devtools.krl"},{"rid_index":14,"last_modified":1423525738,"rid":"b506607x14.prod","uri":"https://raw.githubusercontent.com/kre/devtools/gh-pages/ruleSets/devtools.krl","prefix":"b506607"},{"last_modified":1412788749,"rid":"b506607x2.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl"},{"rid_index":2,"last_modified":1418234018,"rid":"b506607x2.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl","prefix":"b506607"},{"rid":"b506607x3.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter7Ruleset.krl"},{"rid_index":3,"last_modified":1418237852,"rid":"b506607x3.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter7Ruleset.krl","prefix":"b506607"},{"rid":"b506607x4.dev","uri":"https://raw.github.com/bobsmeuncle/Practice-with-KRL/master/ch7book_example.krl"},{"rid_index":4,"last_modified":1418234018,"rid":"b506607x4.prod","uri":"https://raw.github.com/bobsmeuncle/Practice-with-KRL/master/ch7book_example.krl","prefix":"b506607"},{"rid":"b506607x5.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/ch8RottenTomatoes"},{"rid_index":5,"last_modified":1418234018,"rid":"b506607x5.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/ch8RottenTomatoes","prefix":"b506607"},{"last_modified":1421862706,"rid":"b506607x6.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter9.krl"},{"rid_index":6,"last_modified":1421736146,"rid":"b506607x6.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter9.krl","prefix":"b506607"},{"rid":"b506607x7.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/setA.krl"},{"rid_index":7,"last_modified":1418237852,"rid":"b506607x7.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/setA.krl","prefix":"b506607"},{"rid":"b506607x8.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/steB.krl"},{"rid_index":8,"last_modified":1418237852,"rid":"b506607x8.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/steB.krl","prefix":"b506607"},{"last_modified":1421862706,"rid":"b506607x9.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/pythonCode/buttonpresssed.krl"},{"rid_index":9,"last_modified":1421862708,"rid":"b506607x9.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/pythonCode/buttonpresssed.krl","prefix":"b506607"}]';
         // document.getElementById("List-Rulesets").innerHTML = obj;

            $("#List-Rulesets").html("<p id='demo'>"+obj+"</p>");
            $('#List-Rulesets').listview('refresh');
          
            
           // $("#List-Rulesets").html(
             // obj.name + "<br>" +
             // obj.street + "<br>" +
              //obj.phone;);
            

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

      }

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
