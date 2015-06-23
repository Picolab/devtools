(function($)
{
	var router = new $.mobile.Router( 
		[
			{"": {handler: "authCheck", //run before every page change
					events: "bC", // before change
					step: "string"
			} },
			
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
					events: "s", // do page before show
					argsre: true
			} },
			{"#page-installed-rulesets": {handler: "installed_rulesets",
					events: "s", // do when we show the page
					argsre: true
			} },
			{"#install-ruleset": {handler: "install_ruleset",
					events: "s", // do page before show
					argsre: true
			} },
			{"#confirm-uninstall-ruleset": {handler: "uninstall_ruleset",
					events: "s", // do page before show
					argsre: true
			} },
			{"#page-channel-management": {handler: "installed_channels",
					events: "s", // do when we show the page
					argsre: true
			} },
			{"#install-channel": {handler: "install_channel",
					events: "s", // do page before show
					argsre: true
			} },
			{"#confirm-uninstall-channel": {handler: "uninstall_channel",
					events: "s", // do page before show
					argsre: true
			
			} },
      {"#oAuth-client-registration": {handler: "authorized_clients",
          events: "s", // do page before show
          argsre: true
      
      } },
      {"#authorize-client": {handler: "authorize_client",
          events: "s", // do page before show
          argsre: true
      
      } },
      {"#confirm-client-remove": {handler: "remove_client",
          events: "s", // do page before show
          argsre: true
      
      } },
      {"#update-client": {handler: "update_client",
          events: "s", // do page before show
          argsre: true
      
      } }      
		],

		{
			authCheck: function(type, match, ui, page, e) {
				e.preventDefault();
				console.log("authChecked");
				if (!CloudOS.authenticatedSession()){
					var pageComponents = ui.toPage.split("#");
					pageComponents[pageComponents.length-1] = "page-authorize";
					ui.toPage = pageComponents.join("#");
				}
				ui.bCDeferred.resolve();
			},
			
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
				loadSpinner("#manage-list", "registered rulesets");

				function populate_registered_rulesets(){	
					Devtools.getRulesets(function(rids_json){ //the callback/function is where we need to have all of our code
						$("#manage-list" ).empty();
						var sortedRids = rids_json.sort(sortBy("rid"));

						dynamicRegRulesets="";
						$.each(sortedRids, function (id, rids) {
							dynamicRegRulesets += 
								snippets.list_rulesets_template(
									{"rid": rids["rid"],
									"uri": rids["uri"],
									"encoded": encodeURIComponent(rids["uri"])}
									);
						});
						$("#manage-list").append(dynamicRegRulesets).collapsibleset().collapsibleset("refresh");
						$.mobile.loading("hide");

						console.log("refreshing manage-list listview.");

						//----------------flush button-----------------------------
						$(".flushButton").click( function() {
						    console.log(this.id);
						    rid = this.id;

						    $.mobile.loading("show", {
									text: "Flushing ruleset...",
									textVisible: true
								});
								//var update_form_data = process_form(flush_frm);
								console.log(">>>>>>>>> RID to flush", rid);
								//var rid = update_form_data.flush;

								if(typeof rid !== "undefined") {
									Devtools.flushRID(rid, function(directives){
										console.log("Flushing the rid", rid, directives);
										$.mobile.loading("hide");
									});
								}
						});

						//---------------delete button----------------------
						$('.deleteButton').off('tap').on('tap', function(event)
						{	
							rid = this.id;
							console.log("Deleting this rid: " + rid);
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
													$.mobile.loading("hide");
													/*$.mobile.changePage('#listing',{
														reloadPage: 'true'
													});*/
													//refreshPage(); //takes us to an empty about page at the moment
													//want to update page
													$.mobile.changePage("#home", {
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
					});
				}

				populate_registered_rulesets();
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
	

				var rid = router.getParams(match[1])["rid"];
				var oldUrl = router.getParams(match[1])["url"];
				console.log("RID to update URL of: ", rid);
				
				var frmLabel = "URL for " + rid + " ";
				$("#urlLabel").html(frmLabel);
				
				$("#url").val(oldUrl);
				

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
			},

			picologging: function(type, match, ui, page) {
				console.log("pico logging page");
				//$.mobile.loading("hide");

				function populate_logpage() {
					Pico.logging.status(CloudOS.defaultECI, function(json){
						console.log("Logging status: ", json);
						if(json) {
						 	$("#logstatus").val("on").slider("refresh");
						 	loadSpinner("#loglist", "pico logs");
						 	

						 	Pico.logging.getLogs(CloudOS.defaultECI, function(logdata){
							 	$("#loglist" ).empty();
								console.log("Retrieved logs");

								dynamicLogItems = "";
								$.each(logdata, function(i, logobj) {
									var eid_re = RegExp("\\s+" + logobj.eid);
									logobj.log_items = logobj.log_items.map(function(i){ return i.replace(eid_re, ''); 
									});
									dynamicLogItems += snippets.logitem_template(logobj)

								 });
								$("#loglist").append(dynamicLogItems).collapsibleset().collapsibleset( "refresh" );
								$.mobile.loading("hide");
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
					
					submitChannel = function(){
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
						}
					}
					
					$(frm).off('keypress').on('keypress', function(event) {
						if (event.which == 13) {
							event.preventDefault();
							submitChannel();
						}
					});
					
					$('#install-channel-confirm-button').off('tap').on('tap', submitChannel);
			},

			installed_channels: function(type, match, ui, page) {
				console.log("channel installation page");
				loadSpinner("#installed-channels", "installed channels");


				function populate_installed_channels() {
					Devtools.showInstalledChannels(function(channel_list){
						function generateKey(channel){ // could be optimized.........
							var key ="";
							if ("type" in channel){ // if channel["type"] is a valled hash
							var keytype = channel["type"];
								if(/OAUTH-/.test(keytype)){
									key = "OAUTH_TOKEN";
								}
								else if(/OAUTH/.test(keytype)){
									key = "OAUTH_LOGIN";
								}else if (typeof keytype === 'object'){
										key = JSON.stringify(keytype);
										key = key.replace(/"|{|}/g,"");
										key = key.substring(0,key.indexOf(':')); // robust for any object hash key name to be added dynamicaly
								}else{
									key = keytype;
								}
							}
							else{ // if channel does not have type hash
								key = "GENERIC";
							}
							return key;
						}

						//parse json into list of list by type

						//use teplate to format 
						$("#installed-channels" ).empty();
						var channels = channel_list["channels"];
						var map = {};
						var key = "";

						$.each(channels, function(index, channel) {
							key = generateKey(channel);
							if(map[key]){map[key].push(channel);}
							else{
								map[key]=[channel];
							}
						});

						console.log("map of channels",map);
						dynamicChannelItems = "";
						dynamicChannelItems2 = "";
						var type = "";
						$.each(map, function(index, chAray) {
							dynamicChannelItems2 = "";
							dynamicChannelItems = "";
							//Sort
							chAray.sort(function(a, b){
							return ((a.last_active>b.last_active) ?-1:1);
							//return ((a.name.toLowerCase()<b.name.toLowerCase()) ?-1:1);
							});
							//inner div
							type = "";
							$.each(chAray,function(index,channel){
								time = new Date(channel["last_active"]*1000);
								if ("type" in channel ){// checks for hash... do we need to check??????
									var keytype = channel["type"];
									if (typeof keytype === 'object'){
										type = JSON.stringify(keytype);
										type = type.replace(/"|{|}/g,"");
									}else{
										type = keytype;
									}
								}
								else{type = "generic";}

								dynamicChannelItems2 +=
								 snippets.installed_channels_template2(
									{"channel_name": channel["name"],
									"cid": channel["cid"],
									"type": type,
									"time": time,
									"attributes":JSON.stringify(channel["attributes"]).replace(/"|{|}/g,"")}
									);
									key = generateKey(channel);//hack of how to get key, assigned every iteration(bad)
						  });
						  //outter div
							dynamicChannelItems += 
								snippets.installed_channels_template(
									{"Type": key}//,
										//"channelDivs": dynamicChannelItems2}
									);
					  		$("#installed-channels").append(dynamicChannelItems).collapsibleset().collapsibleset( "refresh" );
					  		$("#"+key+"2").append(dynamicChannelItems2).collapsibleset().collapsibleset( "refresh" );

							});
						
					 // $("#installed-channels").append(dynamicChannelItems).collapsibleset().collapsibleset( "refresh" );
					  $.mobile.loading("hide");
				  });
				}
				populate_installed_channels();
			},

			uninstall_channel: function(type, match, ui, page) {
				 console.log("Showing uninstall channel page");
				 $.mobile.loading("hide");
				 var channel = router.getParams(match[1])["channel"];
				 var name = router.getParams(match[1])["name"];
				 console.log("channel to uninstall: ", channel);
				 $("#remove-channel" ).empty();
				 $("#remove-channel").append(snippets.confirm_channel_remove({"channel": channel,"name":name}));
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
      //------------------------------- Authorize Clients --------------------
      authorize_client: function(type, match, ui, page) {
        console.log("Showing authorize client page");
        $.mobile.loading("hide");
        var frm = "#form-authorize-client";
          $(frm)[0].reset(); // clear the fields in the form
          $('#authorize-client-confirm-button').off('tap').on('tap', function(event)
        {
          $.mobile.loading("show", {
            text: "Authorizing Client...",
            textVisible: true
          });
          var athorize_form_data = process_form(frm);
          console.log(">>>>>>>>> client to authorize", athorize_form_data);
          var client_name = athorize_form_data.client_name;
          var client_Description = athorize_form_data.client_Description;
          var client_image_url = athorize_form_data.client_image_url;
          var client_callback_url = athorize_form_data.client_callback_url;
          var client_declined_url = athorize_form_data.client_declined_url;
          var client_info_page_url = athorize_form_data.client_info_page_url;
          var client_bootstrapRids = athorize_form_data.client_bootstrapRids;
          if( true //typeof channel_name !== "undefined"
            //&& channel_name.match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) // valid eci
          ) {
          var appData={

         		"info_page": client_info_page_url,
         		"bootstrapRids": client_bootstrapRids,

            "appName": client_name,
            "appDescription": client_Description,
            "appImageURL": client_image_url,
            "appCallbackURL": client_callback_url,
            "appDeclinedURL": client_declined_url

          };
            Devtools.authorizeClient(appData, function(directives) {
              console.log("authorize ", client_name, directives);
              $.mobile.changePage("#oAuth-client-registration", {
                transition: 'slide'
              });
            }); 
          } else {//never comes here, we dont check for valid name.........
              console.log("Invalid client_name ", client_name);
              $.mobile.loading("hide");
              $.mobile.changePage("#oAuth-client-registration", {
                transition: 'slide'
              });
          }
        });
      },

      authorized_clients: function(type, match, ui, page) {
        console.log("authorized Clients page");
        
        loadSpinner("#authorized client", "authorized client");

        function populate_Authorized_clients() {
          Devtools.showAthorizedClients(function(client_list){

            $("#authorized-clients" ).empty();

            $.each(client_list, function(index, client) {
              $("#authorized-clients" ).append(
               snippets.authorized_clients_template(
                {"appName": client["appName"],
                "appECI": client["appECI"],
                "appImageURL":client["appImageURL"]}
                )
               ).collapsibleset().collapsibleset( "refresh" );
              //$("#installed-rulesets").listview("refresh");
            });

            $.mobile.loading("hide");
          });
        }
        populate_Authorized_clients();
      },

      remove_client: function(type, match, ui, page) {
         console.log("Showing remove client page");
         $.mobile.loading("hide");
         var client = router.getParams(match[1])["client"];
         console.log("client to remove ", client);
         $("#remove-client" ).empty();
         $("#remove-client").append(snippets.confirm_client_remove_template({"client": client}));
         $("#remove-client").listview().listview("refresh");
         $('#remove-client-button').off('tap').on('tap', function(event)
         {
          $.mobile.loading("show", {
            text: "Removing client...",
            textVisible: true
          });
          console.log("removing client ", client);
          if(typeof client !== "undefined") {
            Devtools.removeClient(client, function(directives) {
              console.log("uninstalled ", client, directives);
              $.mobile.changePage("#oAuth-client-registration", {
               transition: 'slide'
             });
            }); 
          }
         });
      },

      update_client: function(type, match, ui, page){
        console.log("Showing update client page")
        $.mobile.loading("hide");
        var frm = "#form-update-client";
          $(frm)[0].reset(); // clear the fields in the form
				var client = router.getParams(match[1])["client"];
          $('#update-client-confirm-button').off('tap').on('tap', function(event)
        {
          $.mobile.loading("show", {
            text: "Updating Client...",
            textVisible: true
          });
          var athorize_form_data = process_form(frm);
          console.log(">>>>>>>>> client to update", athorize_form_data);
          var client_name = athorize_form_data.client_name;
          var client_Description = athorize_form_data.client_Description;
          var client_image_url = athorize_form_data.client_image_url;
          var client_callback_url = athorize_form_data.client_callback_url;
          var client_declined_url = athorize_form_data.client_declined_url;
          var client_info_page_url = athorize_form_data.client_info_page_url;
          var client_bootstrapRids = athorize_form_data.client_bootstrapRids;
          if( true //typeof channel_name !== "undefined"
            //&& channel_name.match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) // valid eci
          ) {
          var appData={

         		"info_page": client_info_page_url,
         		"bootstrapRids": client_bootstrapRids,

            "appName": client_name,
            "appDescription": client_Description,
            "appImageURL": client_image_url,
            "appCallbackURL": client_callback_url,
            "appDeclinedURL": client_declined_url

          };
            Devtools.updateClient(client,appData, function(directives) {
              console.log("update ", client_name, directives);
              $.mobile.changePage("#oAuth-client-registration", {
                transition: 'slide'
              });
            }); 
          } else {//never comes here, we dont check for valid name.........
              console.log("Invalid client_name ", client_name);
              $.mobile.loading("hide");
              $.mobile.changePage("#oAuth-client-registration", {
                transition: 'slide'
              });
          }
        });

      },

      //--------------------------Installed Rulesets------------------------
			installed_rulesets: function(type, match, ui, page) {
				console.log("ruleset installation page");
				loadSpinner("#installed-rulesets", "installed rulesets");

				function populate_installed_rulesets() {
					

					Devtools.showInstalledRulesets(function(ruleset_list){
						if (ruleset_list.error == 102) {
							$.noty.get(noty({
								timeout: false,
								text: "You just broke your account, please reload this app to fix it.",
								type: "error"
							}));
							return;
						}
						$("#installed-rulesets" ).empty();
					 	console.log("Retrieved installed rulesets");
					 	
					 	dynamicInsRulesets = "";
					 	$.each(ruleset_list, function(k, ruleset) {
						 	ruleset["rid"] = k;
			 			 	ruleset["provides_string"] = ruleset.provides.map(function(x){return x.function_name;}).sort().join("; ");
				 		 	ruleset["OK"] = k !== "a169x625.prod"; // don't allow deletion of CloudOS; this could be more robust 	
							dynamicInsRulesets+=snippets.installed_ruleset_template(ruleset);
					 	});
					 	$("#installed-rulesets" ).append(dynamicInsRulesets).collapsibleset().collapsibleset( "refresh" );
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
				
				submitInstall = function(){
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
								if (directives.directives.length === 0) {
									var n = noty({
										type: 'warning',
										text: rid + ' not found.  Please confirm your desired rid.'
									});
									$.noty.get(n);
								}
								
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
					}	
				}
				
				$(frm).off('keypress').on('keypress', function(event){
					if (event.which == 13) {
						event.preventDefault();
						submitInstall();
					}
				});
				$('#install-ruleset-confirm-button').off('tap').on('tap', submitInstall);
			},
		},

		{ 
			defaultHandler: function(type, ui, page) {
				console.log("Default handler called due to unknown route:", type, ui, page );
			},
			defaultHandlerEvents: "s",
			defaultArgsRe: true
		}
	);

	// Handlebar templates compiled at load time to create functions
	// templates are included to index.html from Templates directory.
	//confirm_channel_remove
	window['snippets'] = {
			list_rulesets_template: Handlebars.compile($("#list-rulesets-template").html() || ""),
			logitem_template: Handlebars.compile($("#logitem-template").html() || ""),
			installed_channels_template: Handlebars.compile($("#installed-channels-template").html() || ""),
			installed_channels_template2: Handlebars.compile($("#installed-channels-template2").html() || ""),
			installed_ruleset_template: Handlebars.compile($("#installed-ruleset-template").html() || ""),
			confirm_ruleset_remove: Handlebars.compile($("#confirm-ruleset-remove-template").html() || ""),
			confirm_channel_remove: Handlebars.compile($("#confirm-channel-remove-template").html() || ""),
			about_account: Handlebars.compile($("#about-account-template").html() || ""),
      authorized_clients_template: Handlebars.compile($("#authorized-clients-template").html() || ""),
      confirm_client_remove_template: Handlebars.compile($("#confirm-client-remove-template").html() || "")
	};

	function plant_authorize_button()
	{
		//Oauth through kynetx
		console.log("plant authorize button");
		var OAuth_kynetx_URL = CloudOS.getOAuthURL();
		$('#authorize-link').attr('href', OAuth_kynetx_URL);
		var OAuth_kynetx_newuser_URL = CloudOS.getOAuthNewAccountURL();
		$('#create-link').attr('href', OAuth_kynetx_newuser_URL);
		
		$('#account-link').attr('href', "https://" + CloudOS.login_server + "/login/profile");
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
			window.open("https://" + CloudOS.login_server + "/login/logout?" + Math.floor(Math.random() * 9999999), "_blank");
			CloudOS.removeSession(true); // true for hard reset (log out of login server too)
			$.mobile.changePage('#page-authorize', {
				transition: 'slide'
			}); // this will go to the authorization page.
		});

		Handlebars.registerHelper({

			ifDivider: function(v1, options) {
		 		if(v1.match(/-----\*\*\*----/)) {
					return options.fn(this);
		 		}
				return options.inverse(this);
		 	},

		 	formatDate: function(datetime) {
				// For now just be cheap and lazy and use .toLocaleString(). We can get even fancier later.
				return new Date(datetime).toLocaleString();
			}
			
		});

		console.log("Choose page to show");


		var timeToWait = 0;
		var timeStep = 500;
		function persistant_bootstrap(){
			Devtools.status(function(rid_list){
				var rids = rid_list["rids"];
				if ($.inArray('b507199x0.prod', rids) > -1) {
					console.log("true , Bootstrapped");
					return true;
				}
				else {
					console.log("false , Bootstrapped");
					if (timeToWait >= 10 * timeStep) {
						throw "Bootstrap failure";
					}
					else {
						setTimeout(function() {
							CloudOS.raiseEvent("devtools", "bootstrap", {}, {}, function(response) {
								timeToWait += timeStep;
								persistant_bootstrap();
						})}, timeToWait);
					}
					return false;
				}
			});
		}
		
		
		
		try {
			var authd = CloudOS.authenticatedSession();
			if(authd) {
				console.log("Authorized");
				persistant_bootstrap();
				//document.location.hash = "#home";
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

function loadSpinner(listID, pageData) {
	var listName = listID + " > div";
	if ( $(listName).length > 0 ) {
		$.mobile.loading("show", {
			text: "Updating " + pageData + "...",
			textVisible: true
		});
	} else {
		$.mobile.loading("show", {
			text: "Loading " + pageData + "...",
			textVisible: true
		});
	}
}

function refreshPage() { //takes us to the empty about page again... just like entering on input fields...
  $.mobile.changePage(
    window.location.href,
    {
      //allowSamePageTransition : true,
      //transition              : 'none',
      //showLoadMsg             : false,
      reloadPage              : true
    }
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


