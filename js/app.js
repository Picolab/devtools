(function($)
{
	var router = new $.mobile.Router( 
		[
			{"#page-authorize": {handler: "pageAuthorize",
					events: "s", // do when we show the page
					argsre: true
			} },
			{"#home": {handler: "home",
					events: "s", // do when we show the page
					argsre: true
			} },

			{"#about": {handler: "about",
					events: "s", // do when we create the page
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
			{"#updating-url": {handler: "updatingUrl",
					events: "s", // do when we show the page
					argsre: true
			} },
			{"#page-picologging": {handler: "picologging",
					events: "bs", // do page before show
					argsre: true
			} },
			{"#page-installed-rulesets": {handler: "installed_rulesets",
					events: "s", // do when we show the page
					argsre: true
			} },
			{"#install-ruleset": {handler: "install_ruleset",
					events: "bs", // do page before show
					argsre: true
			} },
			{"#confirm-uninstall-ruleset": {handler: "uninstall_ruleset",
					events: "bs", // do page before show
					argsre: true
			} },
			{"#page-channel-management": {handler: "installed_channels",
					events: "s", // do when we show the page
					argsre: true
			} },
			{"#install-channel": {handler: "install_channel",
					events: "bs", // do page before show
					argsre: true
			} },
			{"#confirm-uninstall-channel": {handler: "uninstall_channel",
					events: "bs", // do page before show
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

				about: function(type, match, ui, page) {
					console.log("About Page Handler");
            $("#about-account" ).empty();
            $("#about-eci" ).empty();
					   $.mobile.loading("show", {
              text: "Loading about page...",
              textVisible: true
            });
					//place in a better method for loading on this page
					
					Devtools.about(function(json){ 
							console.log("About informtion ");
              $.mobile.loading("hide");
							$("#about-account").html(snippets.about_account(json));
							$("#about-eci").html(json.oauth_eci);
							$('#about-list').listview('refresh');
					});
				},

				listing: function(type, match, ui, page) {
					console.log("listing Handler");
					//$("#manage-list" ).empty();
						$.mobile.loading("show", {
							text: "Loading registered rulesets...",
							textVisible: true
						});
					Devtools.getRulesets(function(rids_json){ //the callback/function is where we need to have all of our code
						$("#manage-list" ).empty();
						var sortedRids = rids_json.sort(sortBy("rid"));

						$.each(sortedRids, paint_item);
						$.mobile.loading("hide");
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
						
						var registering_form_data = process_form(frm);
						console.log(">>>>>>>>> RID to register", registering_form_data);
						var url = registering_form_data.appURL;

						var url_check = check_html(url);

						if(typeof url !== "undefined" && url_check === true) {
							$.mobile.loading("show", {
								text: "Registering ruleset...",
								textVisible: true
							});
							Devtools.RegisterRuleset(url, function(directives) {
								console.log("registered ", url, directives);
								$.mobile.changePage("#listing", {
								 transition: 'slide'
							 });
							}); 
						}
					}); 
				},

				updatingUrl: function(type, match, ui, page) {
					console.log("Registered Ruleset Manager Handler");
		
					var url_frm = "#form-update-url";
					$(url_frm)[0].reset(); // clear the fields in the form
		
					var flush_frm = "#form-flush-rid";
					$(flush_frm)[0].reset(); // clear the fields in the form

					var delete_frm = "#form-delete-rid";
					$(delete_frm)[0].reset(); // clear the fields in the form 

					var rid = router.getParams(match[1])["rid"]; 
					console.log("RID to update URL of: ", rid);
					
					var frmLabel = "URL for " + rid + " ";
					$("#urlLabel").html(frmLabel);
					$("#flushLabel").html("Flush ruleset with RID " + rid);
					$("#flush-input").val(rid);
					$("#deleteLabel").html("Delete ruleset with RID " + rid);
					$("#delete-input").val(rid);

					//-------------------Update URL-------------------------------
					$('#update-url-confirm-button').off('tap').on('tap', function(event)
					{
						
						
						var update_form_data = process_form(url_frm);
						console.log(">>>>>>>>> RIDs to register", update_form_data);
						var url = update_form_data.url;

						var url_check = check_html(url);

						if(typeof url !== "undefined" && url_check === true) {
								$.mobile.loading("show", {
									text: "Updating URL...",
									textVisible: true
								});
								Devtools.updateUrl(rid, url, function(directives){
									console.log("updating the function", rid, directives);
									$.mobile.changePage("#listing", {
										transition: 'slide'
									 });
								});
						}
					});

					//-------------------Flush Ruleset-------------------------------
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

					//-------------------Delete Ruleset-------------------------------
					$('#delete-rid-button').off('tap').on('tap', function(event)
					{
						noty({
							layout: 'topCenter',
							text: 'Are you sure you want to delete this ruleset?',
							type: 'warning',

							buttons: [
								{addClass: 'btn btn-primary', text: 'Delete', onClick: function($noty) {
										$noty.close();
										if(typeof rid !== "undefined") {
											$.mobile.loading("show", {
												text: "Deleting ruleset...",
												textVisible: true
											});
											Devtools.deleteRID(rid, function(directives){
												console.log("Deleting the rid", rid, directives);
												$.mobile.changePage("#listing", {
													transition: 'slide'
												});
											});
										}
									}
								},
								{addClass: 'btn btn-danger', text: 'Cancel', onClick: function($noty) {
										$noty.close();
										noty({layout: 'topCenter', text: 'You clicked "Cancel" button', type: 'error'});
									}
								}
							]
						});
						
					});
				},

				picologging: function(type, match, ui, page) {
					console.log("pico logging page");
					//$.mobile.loading("hide");

					function populate_logpage() {
						Pico.logging.status(CloudOS.defaultECI, function(json){
							console.log("Logging status: ", json);
							if(json) {
							 $("#logstatus").val("on").slider("refresh");
							 $.mobile.loading("show", {
									text: "Loading pico logs...",
									textVisible: true
								});
							 Pico.logging.getLogs(CloudOS.defaultECI, function(logdata){
							 	$("#loglist" ).empty();
								 console.log("Retrieved logs");
								 $.each(logdata, function(i, logobj) {
									var eid_re = RegExp("\\s+" + logobj.eid);
									logobj.log_items = logobj.log_items.map(function(i){ return i.replace(eid_re, ''); 
									});
									$("#loglist" ).append( 
									 snippets.logitem_template(logobj)
									 ).collapsibleset().collapsibleset( "refresh" );
									$("#loglist").listview("refresh");
									$.mobile.loading("hide");
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
				
				install_channel: function(type, match, ui, page) {
					console.log("Showing install channel page");
					$.mobile.loading("hide");
				 	var frm = "#form-install-channel";
						$(frm)[0].reset(); // clear the fields in the form
						$('#install-channel-confirm-button').off('tap').on('tap', function(event)
				 	{
						$.mobile.loading("show", {
							text: "Installing channel...",
							textVisible: true
						});
						var install_form_data = process_form(frm);
						console.log(">>>>>>>>> channels to install", install_form_data);
						var channel_name = install_form_data.channel_name;
					
						if( true //typeof channel_name !== "undefined"
					 		//&& channel_name.match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) // valid eci
						) {
							Devtools.installChannel(channel_name, function(directives) {
								console.log("installed ", channel_name, directives);
								$.mobile.changePage("#page-channel-management", {
									transition: 'slide'
								});
							}); 
						} else {
								console.log("Invalid channel_name ", channel_name);
								$.mobile.loading("hide");
								$.mobile.changePage("#page-channel-management", {
									transition: 'slide'
								});
						}
					});
				},

				installed_channels: function(type, match, ui, page) {
					console.log("channel installation page");
					$.mobile.loading("show", {
							text: "Loading installed channels...",
							textVisible: true
						});

					function populate_installed_channels() {
						Devtools.showInstalledChannels(function(channel_list){
							$("#installed-channels" ).empty();
							var channels = channel_list["channels"];
							$.each(channels, function(index, channel) {
								$("#installed-channels" ).append(
								 snippets.installed_channels_template(
									{"channel_name": channel["name"],
									"cid": channel["cid"]}
									)
								 ).collapsibleset().collapsibleset( "refresh" );
                //$("#installed-rulesets").listview("refresh");
						  });
						  $.mobile.loading("hide");
					  });
					}
					populate_installed_channels();
				},

				uninstall_channel: function(type, match, ui, page) {
					 console.log("Showing uninstall channel page");
					 $.mobile.loading("hide");
					 var channel = router.getParams(match[1])["channel"];
					 console.log("channel to uninstall: ", channel);
					 $("#remove-channel" ).empty();
					 $("#remove-channel").append(snippets.confirm_channel_remove({"channel": channel}));
					 $("#remove-channel").listview().listview("refresh");
					 $('#remove-channel-button').off('tap').on('tap', function(event)
					 {
						$.mobile.loading("show", {
							text: "Uninstalling channel...",
							textVisible: true
						});
						console.log("Uninstalling channel ", channel);
						if(typeof channel !== "undefined") {
							Devtools.uninstallChannel(channel, function(directives) {
								console.log("uninstalled ", channel, directives);
								$.mobile.changePage("#page-channel-management", {
								 transition: 'slide'
							 });
							}); 
						}
					 });
				},

				installed_rulesets: function(type, match, ui, page) {
					console.log("ruleset installation page");
					
					$.mobile.loading("show", {
							text: "Loading installed rulesets...",
							textVisible: true
						});

					function populate_installed_rulesets() {
						

						Devtools.showInstalledRulesets(function(ruleset_list){
							$("#installed-rulesets" ).empty();
						 	console.log("Retrieved installed rulesets");
						 	$.each(ruleset_list, function(k, ruleset) {
							 	ruleset["rid"] = k;
				 			 	ruleset["provides_string"] = ruleset.provides.map(function(x){return x.function_name;}).sort().join("; ");
					 		 	ruleset["OK"] = k !== "a169x625.prod"; // don't allow deletion of CloudOS; this could be more robust
							 	$("#installed-rulesets" ).append(
								 	snippets.installed_ruleset_template(ruleset)
								 	).collapsibleset().collapsibleset( "refresh" );
						 	});
						 	$.mobile.loading("hide");

						});
					}

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
							var n = noty({
								type: 'error',
								text: rid + ' is not a valid ruleset. Please check your ruleset and try again. The general format is b######x##.prod or .dev',
							});
							$.noty.get(n);
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
			//confirm_channel_remove
			window['snippets'] = {
					list_rulesets_template: Handlebars.compile($("#list-rulesets-template").html() || ""),
					logitem_template: Handlebars.compile($("#logitem-template").html() || ""),
					installed_channels_template: Handlebars.compile($("#installed-channels-template").html() || ""),
					installed_ruleset_template: Handlebars.compile($("#installed-ruleset-template").html() || ""),
					confirm_ruleset_remove: Handlebars.compile($("#confirm-ruleset-remove-template").html() || ""),
					confirm_channel_remove: Handlebars.compile($("#confirm-channel-remove-template").html() || ""),
					about_account: Handlebars.compile($("#about-account-template").html() || "")
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

        function persistant_bootstarp(){
          Devtools.status(function(rid_list){
             var rids = rid_list["rids"];
            if ($.inArray('b506607x14.prod', rids) > -1) {
            console.log("true , Bootstrapped");

            return true;}
          else {
            console.log("false , Bootstrapped");
            
            return false;}
             
           });
          

        }
				try {

          persistant_bootstarp();

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

	function sortBy(rid){

		return function(a,b){
			if(a[rid].match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) && b[rid].match(/^[A-Za-z][\w\d]+\.[\w\d]+$/))
			//if a and b both are b###x##.dev/.prod
			{
				// split on . ex: b506537x11, prod
				var aSplitrid = a[rid].split(".");
				var bSplitrid = b[rid].split(".");

				// split on x ex: b506537, 11
				var aSplitx = aSplitrid[0].split("x");
				var bSplitx = bSplitrid[0].split("x");

				//makes the string into an integer so "11" becomes 11
				var aRidNum = parseFloat(aSplitx[1]); 
				var bRidNum = parseFloat(bSplitx[1]);

				//compare
				if (aSplitx[0] > bSplitx[0]) { return 1; } //if b506537 is bigger than 
				else if (aSplitx[0] < bSplitx[0]) { return -1; } //if b506537 is smaller than
				else { 															//if both are b506537
					if (aRidNum < bRidNum) { return -1; }//checks if 11 is less than
					else if (aRidNum > bRidNum) { return 1; }
 					else { 																		//only happens if both are x11
 						if (aSplitrid[1] > bSplitrid[1]) { return -1; } //checks which one is prod or dev
						else { return 1; } 
						return 0; //only if both are literally the same rid
					}
				}
			} 
			return 1; //if it doesn't follow the normal b##x##.prod, it gets placed at the end
		};
			
	}

	function paint_item(id, rids) {
		$('#manage-list').append( 
			snippets.list_rulesets_template(
				{"rid": rids["rid"],
				"uri": rids["uri"]}
			)
		);
	}

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

	var check_html = function(url) {
		
		if (url.match(/^(http\:\/\/|https\:\/\/)?([a-z0-9][a-z0-9\-]*\.)+([a-z0-9][a-z0-9\-]*\.)[a-z0-9][a-z0-9\-]*/)) {
			console.log("This is a URL");
			return true;
		} else {
			console.log("This is not a valid URL");
			var n = noty({
				type: 'error',
				text: '\'' + url + '\' is not a valid URL. Please check and try again.',
			});
			$.noty.get(n);
			return false;
		}
	};

