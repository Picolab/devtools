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
    {"#install-ruleset": {handler: "install_ruleset",
		    events: "bs", // do when we show the page
		    argsre: true
		} },
    {"#confirm-uninstall-ruleset": {handler: "uninstall_ruleset",
				events: "bs", // do when we show the page
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
          $.mobile.loading("hide");
        },


        listing: function(type, match, ui, page) {
          console.log("listing Handler");
          $("#manage-list" ).empty();
          
          Devtools.getRulesets(function(rids_json){ //the callback/function is where we need to have all of our code
            console.log("attempting rough listview");
            //    var keys = rids_json.sort(sortBy("rid_index"));
            $.each(rids_json, paint_item);
            console.log("refreshing manage-list listview.");
            $('#manage-list').listview('refresh');
          });

        },

        registeringRuleset: function(type, match, ui, page) {

          console.log("registering Ruleset Handler");
          var frm = "#formRegisterNewRuleset";
            $(frm)[0].reset(); // clear the fields in the form
          $('#regester-ruleset-confirm-button').off('tap').on('tap', function(event)
           {
            $.mobile.loading("show", {
              text: "registering ruleset...",
              textVisible: true
            });
            var registering_form_data = process_form(frm);
            console.log(">>>>>>>>> RID to register", registering_form_data);
            var appURL = registering_form_data.appURL;

            if(typeof appURL !== "undefined") {
              Devtools.RegisterRuleset(appURL, function(directives) {
                console.log("registered ", appURL, directives);
                $.mobile.changePage("#listing", {
                 transition: 'slide'
               });
              }); 
            }
          });
         
        },

        confirmingDeletion: function(type, match, ui, page) {
          console.log("confirming Deletion Handler");
        },

        updatingUrl: function(type, match, ui, page) {
            console.log("Registered Ruleset Manager Handler");
	    
            var url_frm = "#form-update-url";
            $(url_frm)[0].reset(); // clear the fields in the form
	    
            var flush_frm = "#form-flush-rid";
            $(flush_frm)[0].reset(); // clear the fields in the form           
          var rid = router.getParams(match[1])["rid"]; //not sure if this will still work
          console.log("RID to update URL of: ", rid);
          
          var frmLabel = "URL for " + rid + " ";
          $("#urlLabel").html(frmLabel);
          $("#flushLabel").html("Flush ruleset with RID " + rid);
          $("#flush-input").val(rid);

          $('#update-url-confirm-button').off('tap').on('tap', function(event)
          {
            $.mobile.loading("show", {
              text: "Updating URL...",
              textVisible: true
            });
            var update_form_data = process_form(url_frm);
            console.log(">>>>>>>>> RIDs to register", update_form_data);
            var url = update_form_data.url;

            if(typeof url !== "undefined") {
                Devtools.updateUrl(rid, url, function(directives){
                  console.log("updating the function is running", rid, directives);
                  $.mobile.changePage("#listing", {
                    transition: 'slide'
                   });
                });

            }
          });

          $('#flush-rid-button').off('tap').on('tap', function(event)
          {
              $.mobile.loading("show", {
		  text: "Flushing ruleset...",
		  textVisible: true
              });
              var update_form_data = process_form(flush_frm);
              console.log(">>>>>>>>> RID to flush", update_form_data);
	      var rid = update_form_data.flush;

              if(typeof rid !== "undefined") {
                  Devtools.flushRID(rid, function(directives){
                      console.log("Flushing the rid", rid, directives);
                      $.mobile.changePage("#listing", {
			  transition: 'slide'
                      });
                  });

              }
          });

	    
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
      			    ruleset["OK"] = k !== "a169x625.prod"; // don't allow deletion of CloudOS; this could be more robust
      			    $("#installed-rulesets" ).append(
                 snippets.installed_ruleset_template(ruleset)
                 ).collapsibleset().collapsibleset( "refresh" );
//      			    $("#installed-rulesets").listview("refresh");
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
         var frm = "#form-install-ruleset";
      	    $(frm)[0].reset(); // clear the fields in the form
            $('#install-ruleset-confirm-button').off('tap').on('tap', function(event)
	    {
		$.mobile.loading("show", {
		    text: "Installing ruleset...",
		    textVisible: true
		});
		var install_form_data = process_form(frm);
		console.log(">>>>>>>>> RIDs to install", install_form_data);
		var rid = install_form_data.rid;
		
		if( typeof rid !== "undefined"
		 && rid.match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) // valid RID
		  ) {
		      Devtools.installRulesets(rid, function(directives) {
			  console.log("installed ", rid, directives);
			  $.mobile.changePage("#page-installed-rulesets", {
			      transition: 'slide'
			  });
		      });	
		  } else {
		      console.log("Invalid rid ", rid);
		      $.mobile.loading("hide");
		      $.mobile.changePage("#page-installed-rulesets", {
			  transition: 'slide'
		      });
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
  };

  function paint_item(id, rids) {
    var status = "no status"; // place holder for description
    //console.log("rid: "+ rids.rid);

    $('#manage-list').append( 
      snippets.list_rulesets_template(
        {"rid": rids["rid"],
        "uri": rids["uri"]}
      )
    );
  };

  var sortByName = function (a, b) {
  	if (a.name > b.name) {
  	    return 1;
  	}
  	if (a.name < b.name) {
  	    return -1;
  	}
  	// a must be equal to b
  	return 0;
  };

    // process an array of objects from a form to be a proper object
  var process_form_results = function(raw_results) {
  	var results = {};
  	$.each(raw_results, function(i, v) {
  		var nym = v.name,
   	  val = v.value;
  		if (results[nym] && results[nym] instanceof Array) {
  		  results[nym].push(val);
  		} else if (results[nym]) {
  		  results[nym] = [results[nym], val];
  		} else {
  		  results[nym] = val;
  		}
  	});
  	return results;
  };

  var process_form = function(frm) {
	 var results = process_form_results($(frm).serializeArray());
	 return results;
  };

