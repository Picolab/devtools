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
              //  $('ruleset-list').html(snippets.List_Rulesets_template());
            
              Devtools.getRulesets(function(rids_json){ //the callback/function is where we need to have all of our code
              console.log(rids_json);

             // var keys = rids_json.sort(sortBy("rid"));
             // $.each(keys, format_rids_paint);// paint will call $('#ruleset-list').apend......

              //this is for a table
              /*
              var len = rids_json.length;
              var txt = "";
              if(len > 0){
                for(var i=0;i<len;i++){
                    txt += "<tr><td>"+rids_json[i].rid+"</td><td>"+rids_json[i].uri+"</td><td><a href=\""+rids_json[i].uri+"\" data-role=\"button\" data-icon=\"arrow-r\">button</a></td></tr>";
                      
                  }
                if(txt !== ""){
                        $("#ruleset-list").html(txt);
                        $("#ruleset-list").listview('refresh');
                  }
                else{
                    $("#ruleset-list").html("<tr><td> NONE </td><td> NONE </td>");
                    $("#ruleset-list").listview('refresh');
                }
              } */

              //trying for a list

              console.log("attempting rough listview");

              var keys = json.sort(sortBy("rid"));
              $.each(keys, paint_item);

              $('#manage-list').listview('refresh');
                });



          //var obj_json = '[{"rid":"b506607x0.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/HelloWorld.krl"},{"rid_index":0,"last_modified":1418237853,"rid":"b506607x0.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/HelloWorld.krl","prefix":"b506607"},{"rid":"b506607x1.dev","uri":"w.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl"},{"rid_index":1,"last_modified":1418234018,"rid":"b506607x1.prod","uri":"w.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl","prefix":"b506607"},{"last_modified":1422397298,"rid":"b506607x10.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl"},{"rid_index":10,"last_modified":1423525230,"rid":"b506607x10.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl","prefix":"b506607"},{"rid":"b506607x11.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl"},{"rid_index":11,"last_modified":1418237853,"rid":"b506607x11.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/StockChecker.krl","prefix":"b506607"},{"last_modified":1418234156,"rid":"b506607x12.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlog.krl"},{"rid_index":12,"rid":"b506607x12.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlog.krl","prefix":"b506607"},{"last_modified":1418238023,"rid":"b506607x13.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlogData.krl"},{"rid_index":13,"rid":"b506607x13.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/smsBlogData.krl","prefix":"b506607"},{"last_modified":1423689382,"rid":"b506607x14.dev","uri":"https://raw.githubusercontent.com/kre/devtools/gh-pages/ruleSets/devtools.krl"},{"rid_index":14,"last_modified":1423525738,"rid":"b506607x14.prod","uri":"https://raw.githubusercontent.com/kre/devtools/gh-pages/ruleSets/devtools.krl","prefix":"b506607"},{"last_modified":1412788749,"rid":"b506607x2.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl"},{"rid_index":2,"last_modified":1418234018,"rid":"b506607x2.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/RuleExercise1.krl","prefix":"b506607"},{"rid":"b506607x3.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter7Ruleset.krl"},{"rid_index":3,"last_modified":1418237852,"rid":"b506607x3.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter7Ruleset.krl","prefix":"b506607"},{"rid":"b506607x4.dev","uri":"https://raw.github.com/bobsmeuncle/Practice-with-KRL/master/ch7book_example.krl"},{"rid_index":4,"last_modified":1418234018,"rid":"b506607x4.prod","uri":"https://raw.github.com/bobsmeuncle/Practice-with-KRL/master/ch7book_example.krl","prefix":"b506607"},{"rid":"b506607x5.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/ch8RottenTomatoes"},{"rid_index":5,"last_modified":1418234018,"rid":"b506607x5.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/ch8RottenTomatoes","prefix":"b506607"},{"last_modified":1421862706,"rid":"b506607x6.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter9.krl"},{"rid_index":6,"last_modified":1421736146,"rid":"b506607x6.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/chapter9.krl","prefix":"b506607"},{"rid":"b506607x7.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/setA.krl"},{"rid_index":7,"last_modified":1418237852,"rid":"b506607x7.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/setA.krl","prefix":"b506607"},{"rid":"b506607x8.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/steB.krl"},{"rid_index":8,"last_modified":1418237852,"rid":"b506607x8.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/steB.krl","prefix":"b506607"},{"last_modified":1421862706,"rid":"b506607x9.dev","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/pythonCode/buttonpresssed.krl"},{"rid_index":9,"last_modified":1421862708,"rid":"b506607x9.prod","uri":"https://raw.githubusercontent.com/bobsmeuncle/Practice-with-KRL/master/pythonCode/buttonpresssed.krl","prefix":"b506607"}]';
          // var rids_json = JSON.parse(obj_json);
          // document.getElementById("List-Rulesets").innerHTML = obj;

            //$("#List-Rulesets").html("<p id='demo'>"+ruleset_obj+"</p>");
            //$('#List-Rulesets').listview('refresh');

            //console.log(rids_json.rid);
            //console.log(ruleset_obj.rid);
            

            /*var frm = "#ruleset-form";
            $(frm)[0].reset();
            var owner_eci = CloudOS.defaultECI; //from pageUpdateProfile

              $("#RID", frm).val(ruleset_obj.rid);
              $("#source-URL", frm).val(ruleset_obj.uri);*/
            

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
      // Handlebar templates compiled at load time to create functions
      // templates are included to index.html from Templates directory.
      window['snippets'] = {
        list_rulesets_template: Handlebars.compile($("#list-rulesets-template").html() || ""),
      };

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
    };

    $('.logout').off("tap").on("tap", function(event)
       {
            CloudOS.removeSession(true); // true for hard reset (log out of login server too)
            $.mobile.changePage('#page-authorize', {
              transition: 'slide'
            }); // this will go to the authorization page.


          });

    function paint_item(id, vehicle) {

          /*if (typeof vehicle === "undefined") {
        return;
          }*/


        $("#manage-list li:nth-child(1)" ).after( //was #manage-fleet prior
            snippets.list_rulesets_template(
              {"rid": vehicle.profileName,
               "uri": id,
               "description": status,
              }));
    };
     


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


    /////////////////////////////////////////////////////////////////////
    // this is the actual code that runs and sets everything off
    // pull the session out of the cookie.
    $(document).bind("mobileinit", onMobileInit);
    $(document).ready(onPageLoad);
  })(jQuery);
