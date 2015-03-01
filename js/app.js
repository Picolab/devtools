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
		    events: "s", // do when we create the page
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
			} },
      {"#page-picologging": {handler: "picologging",
			     events: "bs", // do when we show the page
			     argsre: true
        } },
      {"#page-installed-rulesets": {handler: "installed_rulesets",
			     events: "bs", // do when we show the page
			     argsre: true
				   } },
      {"#install-ruleset": {handler: "install_rulesets",
			     events: "bs", // do when we show the page
			     argsre: true
				   } },
      {"#confirm-uninstall-ruleset": {handler: "uninstall_ruleset",
				     events: "bs", // do when we show the page
				     argsre: true
	  
                                    }}
        ],
        {
          pageAuthorize: function(type, match, ui, page) {
            console.log("manage fuse: authorize page");
            $.mobile.loading("hide");
          }, 
          
          home: function(type, match, ui, page) {
            console.log("home Handler");
            $.mobile.loading("hide");
          },


          listing: function(type, match, ui, page) {
            console.log("listing Handler");

            $("#manage-list" ).empty();
            
              Devtools.getRulesets(function(rids_json){ //the callback/function is where we need to have all of our code
          //      console.log(rids_json);
              console.log("attempting rough listview");

          //    var keys = rids_json.sort(sortBy("rid_index"));
          //    console.log("keys: " + keys);
              $.each(rids_json, paint_item);
            //  $.each(keys, paint_item);

            console.log("refreshing manage-list listview.");

            $('#manage-list').listview('refresh');
          });


          // document.getElementById("List-Rulesets").innerHTML = obj;


            /*var frm = "#ruleset-form";
            $(frm)[0].reset();
            var owner_eci = CloudOS.defaultECI; //from pageUpdateProfile

              $("#RID", frm).val(ruleset_obj.rid);
              $("#source-URL", frm).val(ruleset_obj.uri);*/


          },

          registeringRuleset: function(type, match, ui, page) {
            //example
//http://www.jquery4u.com?city=Gold Coast
//console.log($.urlParam('city'));  
//output: Gold%20Coast
//console.log(decodeURIComponent($.urlParam('city'))); 
//output: Gold Coast
            

            console.log("registering Ruleset Handler");
        //    var frm = "#formRegisterNewRuleset";
           // $(frm)[0].reset();
            // clear_error_msg(frm);
        //    $('.save', frm).off('tap').on('tap');//,

            //  function(event){
            //  var results= $(frm).serializeArray();
            //  console.log("Form results for ", frm, ": ", results);
              //should check url to be valid


           // });
          },
          confirmingDeletion: function(type, match, ui, page) {
            console.log("confirming Deletion Handler");
          },
          updatingUrl: function(type, match, ui, page) {
            var rid = $.urlParam('rid');

            console.log("updating Url Handler");
          },
          picologging: function(type, match, ui, page) {
            console.log("pico logging page");
            $.mobile.loading("hide");

	    function populate_logpage() {
		Pico.logging.status(CloudOS.defaultECI, function(json){
		    console.log("Logging status: ", json);
		    if(json) {
			$("#logstatus").val("on").slider("refresh");
			$("#loglist" ).empty();
			Pico.logging.getLogs(CloudOS.defaultECI, function(logdata){
			    console.log("Retrieved logs");
			    $.each(logdata, function(i, logobj) {
				var eid_re = RegExp("\\s+" + logobj.eid);
				logobj.log_items = logobj.log_items.map(function(i){ return i.replace(eid_re, ''); 
});
				$("#loglist" ).append( 
 				    snippets.logitem_template(logobj)
				).collapsibleset().collapsibleset( "refresh" );
				$("#loglist").listview("refresh");
			    });
			});
			
		    } else {
			$("#logstatus").val("off").slider("refresh");
		    }
		});
            }

	    populate_logpage();
	    
	    // triggers 
            $("#logstatus").unbind("change").change(function(){
		var newstatus = $("#logstatus").val();
		if(newstatus === "on") {
		    Pico.logging.reset(CloudOS.defaultECI, {});
		    populate_logpage();
		} else {
		    Pico.logging.inactive(CloudOS.defaultECI, {});
		    $("#loglist" ).empty();
		}
	    });
	    $( "#logrefresh" ).unbind("click").click(function(event, ui) {
		$("#loglist" ).empty();
		populate_logpage();
	    });
	    $( "#logclear" ).unbind("click").click(function(event, ui) {
		$("#loglist" ).empty();
		Pico.logging.flush(CloudOS.defaultECI, {});
	    });

          },
          installed_rulesets: function(type, match, ui, page) {
		console.log("ruleset installation page");
		$.mobile.loading("hide");
		
		function populate_installed_rulesets() {
		    $("#installed-rulesets" ).empty();
		    Devtools.showInstalledRulesets(function(ruleset_list){
			console.log("Retrieved installed rulesets");
			$.each(ruleset_list, function(k, ruleset) {
			    ruleset["rid"] = k;
			    $("#installed-rulesets" ).append(
 				snippets.installed_ruleset_template(ruleset)
			    ).collapsibleset().collapsibleset( "refresh" );
			    $("#installed-rulesets").listview("refresh");
			});
		    });
		};

		populate_installed_rulesets();

		
        },
	uninstall_ruleset: function(type, match, ui, page) {
	    console.log("Showing uninstall ruleset page");
	    $.mobile.loading("hide");
	    var rid = router.getParams(match[1])["rid"];
	    console.log("RID to uninstall: ", rid);
	    $("#remove-ruleset" ).empty();
	    $("#remove-ruleset").append(snippets.confirm_ruleset_remove({"rid": rid}));
	    $("#remove-ruleset").listview().listview("refresh");
    	    $('#remove-ruleset-button').off('tap').on('tap', function(event)
            {
		$.mobile.loading("show", {
                    text: "Uninstalling ruleset...",
                    textVisible: true
		});
   	        console.log("Uninstalling RID ", rid);
		if(typeof rid !== "undefined") {
		    Devtools.uninstallRulesets(rid, function(directives) {
 			console.log("uninstalled ", rid, directives);
			$.mobile.changePage("#page-installed-rulesets", {
			    transition: 'slide'
			});
		    });	
		}
            });
	},
	install_ruleset: function(type, match, ui, page) {
	    console.log("Showing install ruleset page");
	    $.mobile.loading("hide");
	    var rid = router.getParams(match[1])["rid"];
	    console.log("RID to uninstall: ", rid);
	    $("#remove-ruleset" ).empty();
	    $("#remove-ruleset").append(snippets.confirm_ruleset_remove({"rid": rid}));
	    $("#remove-ruleset").listview().listview("refresh");
    	    $('#remove-ruleset-button').off('tap').on('tap', function(event)
            {
		$.mobile.loading("show", {
                    text: "Uninstalling ruleset...",
                    textVisible: true
		});
   	        console.log("Uninstalling RID ", rid);
		if(typeof rid !== "undefined") {
		    // Fuse.deleteVehicle(pid, function(directives) {
		    // 	    // deletion is simple, so the return indicates completion; thus invalidation works
		    // 	    Fuse.invalidateVehicleSummary();
		    // 	    console.log("Deleted ", pid, directives);
		    // 	    $.mobile.loading("hide");
			    $.mobile.changePage("#page-installed-rulesets", {
				transition: 'slide'
			    });
			// });	
		}
            });
	}
      },
      { 
        defaultHandler: function(type, ui, page) {
          console.log("Default handler called due to unknown route:", type, ui, page );
        },
        defaultHandlerEvents: "s",
        defaultArgsRe: true

      });

      // Handlebar templates compiled at load time to create functions
      // templates are included to index.html from Templates directory.
      window['snippets'] = {
          list_rulesets_template: Handlebars.compile($("#list-rulesets-template").html() || ""),
          logitem_template: Handlebars.compile($("#logitem-template").html() || ""),
          installed_ruleset_template: Handlebars.compile($("#installed-ruleset-template").html() || ""),
	  confirm_ruleset_remove: Handlebars.compile($("#confirm-ruleset-remove-template").html() || "")
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

	$('.logout').off("tap").on("tap", function(event)
				   {
	       CloudOS.removeSession(true); // true for hard reset (log out of login server too)
	       $.mobile.changePage('#page-authorize', {
         transition: 'slide'
	       }); // this will go to the authorization page.
       });

	Handlebars.registerHelper('ifDivider', function(v1, options) {
	    if(v1.match(/-----\*\*\*----/)) {
		return options.fn(this);
	    }
	    return options.inverse(this);
	});

	console.log("Choose page to show");

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
  function clear_error_msg(frm) {// we dont have #error-msg ---------------
       $("#error-msg", frm).html("").hide();
    }
  function sortBy(prop){

    return function(a,b){

    //if a and b match regex /\w+\d+xd+\.\w+/
    // split on .
      // split on x
        //compare 
      if( a[prop] < b[prop]){
        return 1;
      }else if( a[prop] > b[prop] ){
        return -1;
      }
      return 0;
    };
  }
    function paint_item(id, rids) {//(key,value)

          /*if (typeof vehicle === "undefined") {
        return;
      }*/
          var status = "no status"; // place holder for description
         // console.log("in paint_item");
        //  console.log(id, rids);
          console.log("rid: "+ rids.rid);

        $('#manage-list').append( //was #manage-fleet prior
          snippets.list_rulesets_template(
            {"rid": rids["rid"],
            "uri": rids["uri"]}
            )
          );
      }

