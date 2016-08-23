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
				{"#account": {handler: "account",
					events: "s", // do when we create the page
					argsre: true
				} },
				{"#pico-creation": {handler: "pico_creation",
				events: "s",
				argsre: true
			}},
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
				{"#page-prototypes": {handler: "prototype_listing",
					events: "s", // do when we show the page
					argsre: true
				} },
				{"#add-prototype": {handler: "addPrototype",
					events: "s", // do when we show the page
					argsre: true
				} },
				{"#update-prototype": {handler: "updatePrototype",
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
				{"#page-client-authorize": {handler: "authorized_clients",
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

      } },			
      {"#page-schedules": {handler: "scheduled_events",
					events: "s", // do page before show
					argsre: true
				} },			
				{"#schedule-event": {handler: "schedule_event",
					events: "s", // do page before show
					argsre: true
				} },
				{"#page-subscription-management": {handler: "subscriptions",
					events: "s", // do page before show
					argsre: true
				} },
				{"#Subscribe": {handler: "subscribe",
					events: "s", // do page before show
					argsre: true
				} }
				],

				{

					authCheck: function(type, match, ui, page, e) {
						e.preventDefault();
						console.log("authChecked");
						if (!wrangler.authenticatedSession()){
							var pageComponents = ui.toPage.split("#");
							pageComponents[pageComponents.length-1] = "page-authorize";
							ui.toPage = pageComponents.join("#");
						}
						ui.bCDeferred.resolve();
					},

					pageAuthorize: function(type, match, ui, page) {
						console.log("manage fuse: authorize page");
						PicoNavigator.clear();
						$.mobile.loading("hide");
					}, 

					home: function(type, match, ui, page) {
						console.log("home Handler");
						$.mobile.loading("hide");
					},

					account: function(type, match, ui, page) {
						$("#about-account" ).empty();
						$.mobile.loading("show", {
							text: "Loading account page...",
							textVisible: true
						});

						Devtools.about(function(json){ 
							$.mobile.loading("hide");
							$("#about-account").html(snippets.about_account(json));
						}, {"eci":wrangler.defaultECI});
					},

					about: function(type, match, ui, page) {
						console.log("About Page Handler");

						$("#upwards-navigation-options").hide();

						Devtools.picoName(function(name_res) {
							$("#about-pico-name" ).empty();
							$("#about-pico-name").html(name_res["picoName"] || "Primary Pico");
						});

						$("#about-eci" ).empty();
						$("#about-eci").html(PicoNavigator.currentPico || wrangler.defaultECI);
						$.mobile.loading("show", {
							text: "Loading about page...",
							textVisible: true
						});

						Devtools.picoName(function(name_res) {
							$("#Open-primary-button").text("Open Primary Pico : " + (name_res["picoName"] || "Primary Pico") + " (" + wrangler.defaultECI + ")");
							$("#Open-primary-button").off('tap').on('tap', function() {
								PicoNavigator.navigateTo(wrangler.defaultECI);
								$.mobile.changePage("#about", {
									transition: 'slide',
									allowSamePageTransition : true
								});
							});
						}, {"eci":wrangler.defaultECI});

						Devtools.parentPico(function(parent_result) {
							parentECI = (parent_result.parent != "error") ? parent_result.parent[0] : "none";
							if (parentECI != "none") {
								Devtools.picoName(function(name_res) {
									$("#Open-parent-button").text("Open Parent : " + (name_res["picoName"] || "Primary Pico") + " (" + parentECI + ")");
									$("#Open-parent-button").off('tap');
									if (parent_result.parent != "error") {
										$("#upwards-navigation-options").show();
										$("#Open-parent-button").on('tap', function() {
											PicoNavigator.navigateTo(parentECI);
											$.mobile.changePage("#about", {
												transition: 'slide',
												allowSamePageTransition : true
											});
										});
									}
								}, {"eci":parentECI});
							}
						});


						Devtools.childPicos(function(children_result){
							console.log("Children");
							$("#child-picos").empty();
							childrenArray = [];
							dynamicChildrenList = "";
							if (!children_result["status"])
							{
								$.mobile.loading("hide");
								return;
							}
							else
							{
								var sortedChildren = children_result["children"].sort(sortBy("name"));

								$.each(sortedChildren, function (index, child) {
									dynamicChildrenList += 
									snippets.child_pico_template(child);
								});
								$("#child-picos").append(dynamicChildrenList).collapsibleset().collapsibleset("refresh");
								$.mobile.loading("hide");

							}

				//			resLength = children_result["children"].length;
				//			readyCount = 0;


					//quick barrier for the async name calls
				//	upCount = function() {
				//		readyCount++;
				//		if (readyCount == resLength) {
				//			$.mobile.loading("hide");
							
				//			childrenArray.sort(function(a, b) {
				//				if (a.picoName == 0) return -1;
				//				else if (b.picoName == 0) return 1;
				//				else if (a.picoName.toLowerCase() > b.picoName.toLowerCase()) return 1;
				//				else return -1;
				//			})
				//			for (i = 0; i < childrenArray.length; i++)
				//			{
				//				dynamicChildrenList += 
				//				snippets.child_pico_template(childrenArray[i]);
				//			}
							
				//			$("#child-picos").append(dynamicChildrenList).collapsibleset().collapsibleset("refresh");

							$(".openPicoButton").off('tap').on('tap', function() {
								console.log(this.id);
								picoToOpen = this.id;
								$.mobile.loading("show", {
									text: "Ensuring child pico is bootstrapped...",
									textVisible: true
								});
								Devtools.ensureBootstrap(function() {
									$.mobile.loading("hide");
									PicoNavigator.navigateTo(picoToOpen);
									$.mobile.changePage("#about", {
										transition: 'slide',
										allowSamePageTransition : true
									});
								}, {"eci":picoToOpen});
							});

							$(".deletePicoButton").off('tap').on('tap', function() {
								console.log("DELETE button pushed for " + this.id);
								wrangler.deleteChild({"pico_name":this.id}, function() {
									$.mobile.changePage("#about", {
										transition: 'slide',
										allowSamePageTransition : true
									});
								});
							});

							if (window.innerWidth <= 600) {
								$(".childPicoButton").css('font-size', '12px');
								//$(".childPicoButton").addClass('ui-nodisc-icon');
								//$(".childPicoButton").addClass('ui-alt-icon');
							}
				//		}
				//	}
				//		console.log("children name: ", children_result["children"]);
					
				//	$.each(children_result["children"], function(index,child){
				//		console.log("children name: ",child["name"]);
				//		console.log("children name: ",child["eci"]);
					/*	Devtools.picoName(function(name_res){
							console.log(name_res["picoName"]);
							childrenArray.push({
								"eci": child[0],
								"picoName": name_res["picoName"]
							});
							/*dynamicChildrenList += 
								snippets.child_pico_template(
									{
										"eci": child[0],
										"picoName": name_res["picoName"]
									}
								);
								*/

						//		upCount();
						//	}, {"eci":child[0]});
				//	});
					
				});
					},

					pico_creation: function(type, match, ui, page) {
						console.log("creating a Pico");
						var frm = "#form-new-pico";
				$(frm)[0].reset(); // clear the fields in the form

				//Fill the Prototypes select/menu
				$("#prototypeMenu").empty();
				Devtools.prototypes(function(pros) {
					if (pros["status"]) {
						var prototypes = pros["prototypes"];

						$("#prototypeMenu").append("<option value='None'>None</option>");
						$("#prototypeMenu").trigger("change");
						for (p in prototypes) {
							$("#prototypeMenu").append("<option value='" + p + "'>" + p + "</option>");
						}
					}
				});

				createThePico = function(){
					$.mobile.loading("show", {
						text: "creating pico...",
						textVisible: true
					});
					var create_pico_form_data = process_form(frm);
					console.log(">>>>>>>>> Pico ", create_pico_form_data);

					var selProto = $("#prototypeMenu").val();
					if (selProto == "None")
						selProto = "";
					var pico_Data={
						"name": create_pico_form_data.Pico_name,
						//"prototypes": create_pico_form_data.Pico_prototypes,
						"prototype": selProto
					};
					console.log("Selected Prototype:", $("#prototypeMenu").val());
					
					Devtools.createPico(pico_Data, function(directives) {
						console.log("create pico ", pico_Data, directives);
						$.mobile.changePage("#about", {
							transition: 'slide'
						});
					});
				};

				$(frm).off('keypress').on('keypress', function(event) {
					if (event.which == 13) {
						event.preventDefault();
						createThePico();
					}
				});

				$('#Create-pico-confirm-button').off('tap').on('tap', createThePico);
			},

			listing: function(type, match, ui, page) {
				console.log("listing Handler");
				loadSpinner("#manage-list", "registered rulesets");

				function populate_registered_rulesets(){	
					Devtools.getRulesets(function(rids_json){ //the callback/function is where we need to have all of our code
						$("#manage-list" ).empty();
						var sortedRids = rids_json['description'].sort(sortBy("rid"));

						dynamicRegRulesets="";
						$.each(sortedRids, function (id, rids) {
							dynamicRegRulesets += 
							snippets.list_rulesets_template(
								{"rid": rids["rid"],
								"uri": rids["uri"],
								"name": rids["description"]["name"],
								"description": rids["description"]["description"],
								"encoded": encodeURIComponent(rids["uri"])}
								);
						});
						$("#manage-list").append(dynamicRegRulesets).collapsibleset().collapsibleset("refresh");
						$.mobile.loading("hide");

						console.log("refreshing manage-list listview.");

						//----------------install button-----------------------------
						$(".installButton").click( function() {
							rid = this.id;

							$.mobile.loading("show", {
								text: "Installing ruleset...",
								textVisible: true
							});
							console.log(">>>>>>>>> RID to install", rid);
							if(typeof rid !== "undefined") {
								Devtools.installRulesets(rid, function(directives) {
									console.log("installed ", rid, directives);
									if (directives.directives.length === 0) {
										var n = noty({
											type: 'warning',
											text: rid + ' failed to install.'
										});
										$.noty.get(n);
									}
									$.mobile.loading("hide");
								});
							}
						});

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
													//refreshes the page because refreshPage() takes us to the homepage
													$("#manage-list" ).empty();
													populate_registered_rulesets();
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
						if (window.innerWidth <= 400) {
							$(".listRulesetsButton").css('font-size', '10px');
							$(".listRulesetsButton").removeClass('ui-btn-icon-right');
							//$(".listRulesetsButton").addClass('ui-nodisc-icon');
							//$(".listRulesetsButton").addClass('ui-alt-icon');
						} else if (window.innerWidth <= 600) {
							$(".listRulesetsButton").css('font-size', '12px');
							//$(".listRulesetsButton").addClass('ui-nodisc-icon');
							//$(".listRulesetsButton").addClass('ui-alt-icon');
						}
					});
				}

				Devtools.parentPico(function(parent_result) {
					if (parent_result.parent != "error") { // if in child, not root
						$.mobile.loading("hide");
						$.noty.get(noty({
							timeout: false,
							text: 'Rulesets can only be registered in the Primary Pico.  You\'ve been routed to the about page in case you\'d like to change picos.',
							type: 'warning'
						}));
						$.mobile.changePage("#about", {
							transition: 'slide'
						});		
					}
					else { // else in root
						populate_registered_rulesets();
					}
				});
				
			},

			registeringRuleset: function(type, match, ui, page) {

				console.log("registering Ruleset Handler");
				var frm = "#formRegisterNewRuleset";
					$(frm)[0].reset(); // clear the fields in the form
					$('#register-ruleset-confirm-button').off('tap').on('tap', function(event)
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

			prototype_listing: function(type, match, ui, page) {
				console.log("Prototype Listing Handler");
				loadSpinner("#manage-prototype-list", "Prototypes");

				function populate_prototypes(){	
					Devtools.prototypes(function(proto_info){ //the callback/function is where we need to have all of our code
						$("#manage-prototype-list" ).empty();
						dynamicPrototypes = "";

						$.each(proto_info["prototypes"], function(id, info) {
							var dynamicProtoChannels = [];
							$.each(info["channels"], function(id, info) {
								dynamicProtoChannels.push("<br/>" 
									+ info["name"] + " " 
									+ info["type"] + " (" 
									+ info["attributes"] + ")");
							});

							var dynamicProtoSubscriptions = [];
							$.each(info["subscriptions_request"], function(id, info) {
								dynamicProtoSubscriptions.push("<br/>" 
									+ info["name"] + " (" 
									+ info["name_space"] + ": " 
									+ info["my_role"] + "-" 
									+ info["subscriber_role"] + ")");
							});

							var dynamicProtoEvents = [];
							$.each(info["Prototype_events"], function(id, info) {
								dynamicProtoEvents.push("<br/>" 
									+ info["domain"] + "/" 
									+ info["type"]);
							});
							
							dynamicPrototypes += 
							snippets.list_prototypes_template( {
								"title": id,
								"meta": info["meta"]["description"],
								"rids": info["rids"],
								"channels": dynamicProtoChannels,
								"subs": dynamicProtoSubscriptions,
								"events": dynamicProtoEvents
									//"pds": info["PDS"]["profile"] + ": " + info["PDS"]["general"]
								});
						});
						$("#manage-prototype-list").append(dynamicPrototypes).collapsibleset().collapsibleset("refresh");
						$.mobile.loading("hide");

						console.log("refreshing manage-list listview.");

						//---------------delete button----------------------
						$('.deleteButton').off('tap').on('tap', function(event)
						{	
							delProto = this.id;
							console.log("Deleting this prototype: " + delProto);
							noty({
								layout: 'topCenter',
								text: 'Are you sure you want to delete this prototype?',
								type: 'warning',

								buttons: [
								{addClass: 'btn btn-primary', text: 'Delete', onClick: function($noty) {
									$noty.close();
									if(typeof delProto !== "undefined") {
										$.mobile.loading("show", {
											text: "Deleting prototype...",
											textVisible: true
										});
										Devtools.removePrototype(delProto, function(directives){
											console.log("Deleting the rid", rid, directives);
											$.mobile.loading("hide");
													//refreshes the page because refreshPage() takes us to the homepage
													$("#manage-prototype-list" ).empty();
													populate_prototypes();
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

				populate_prototypes();
			},

			addPrototype: function(type, match, ui, page) {
				console.log("Add Prototype Handler");
				
				$('.added-channel').remove();
				$('.added-event').remove();
				$('.added-subscription').remove();
				document.getElementById('form-add-prototype-meta').reset();
				document.getElementById('form-add-prototype-channels0').reset();
				document.getElementById('form-add-prototype-subs0').reset();
				document.getElementById('form-add-prototype-events0').reset();
				document.getElementById('form-add-prototype-pds').reset();

				function addChannel(event) {
					//event.preventDefault();
					var newChannel = '<li id="li-add-prototype-channels'+chNum+'" class="ui-li-static ui-body-inherit added-channel">  <form id="form-add-prototype-channels'+chNum+'">        <div data-role="fieldcontain" class="ui-field-contain">     <label for="prototype_channel_name">Name:</label>  <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">    <input type="text" name="prototype_channel_name" id="a_prototype_channel_name'+chNum+'" value="" placeholder="Channel Name" /> </div>  <label for="prototype_channel_type">Type:</label>   <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">   <input type="text" name="prototype_channel_type" id="a_prototype_channel_type'+chNum+'" value="" placeholder="Channel Type" />  </div>    <label for="prototype_channel_attributes">Attributes:</label>   <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">   <input type="text" name="prototype_channel_attributes" id="a_prototype_channel_attributes'+chNum+'" value="" placeholder="Channel Attributes" />  </div>    <label for="prototype_channel_policy">Policy:</label>  <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">    <input type="text" name="prototype_channel_policy" id="a_prototype_channel_policy'+chNum+'" value="" placeholder="Channel Policy" /> </div> </div> </form> </li>';
					$('#li-add-prototype-channels' + (chNum - 1)).after(newChannel);
					$('#li-add-prototype-channels' + (chNum)).attr('data-source', $('#li-add-prototype-channels' + (chNum - 1)).attr('data-source'));
					chNum += 1;
				}

				function addSubscription(event) {
					//event.preventDefault();
					var newSub = '<li id="li-add-prototype-subs'+subNum+'" class="ui-li-static ui-body-inherit added-subscription">      <form id="form-add-prototype-subs'+subNum+'">        <div data-role="fieldcontain" class="ui-field-contain">          <label for="prototype_sub_name">Name:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_name" id="a_prototype_sub_name'+subNum+'" class="proto-field" value="" placeholder="Subscription Name" />  </div>        <label for="prototype_sub_namespace">Namespace:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_namespace" id="a_prototype_sub_namespace'+subNum+'" class="proto-field" value="" placeholder="ex: school_picos" />    </div>      <label for="prototype_sub_type">Channel Type:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_type" id="a_prototype_sub_type'+subNum+'" class="proto-field" value="" placeholder="Type" />   </div>       <label for="prototype_sub_myRole">My Role:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_myRole" id="a_prototype_sub_myRole'+subNum+'" class="proto-field" value="" placeholder="ex: Teacher" />    </div>      <label for="prototype_sub_subRole">Subscriber Role:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">     <input type="text" name="prototype_sub_subRole" id="a_prototype_sub_subRole'+subNum+'" class="proto-field" value="" placeholder="ex: Student" />    </div>      <label for="prototype_sub_eci">Target:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">       <input type="text" name="prototype_sub_eci" id="a_prototype_sub_eci'+subNum+'" class="proto-field" value="" placeholder="Target Pico ECI (ex: 01234567-89AB-CDEF-0123-456789ABCDEF" />   </div>       <label for="prototype_sub_attributes">Attributes:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">       <input type="text" name="prototype_sub_attributes" id="a_prototype_sub_attributes'+subNum+'" class="proto-field" value="" placeholder="Subscription Attributes" />   </div>     </div>      </form>   </li>';
					$('#li-add-prototype-subs' + (subNum - 1)).after(newSub);
					$('#li-add-prototype-subs' + (subNum)).attr('data-source', $('#li-add-prototype-subs' + (subNum - 1)).attr('data-source'));
					subNum += 1;
				}

				function addEvent(event) {
					//event.preventDefault();
					var newEvent = '<li id="li-add-prototype-events'+evNum+'" class="ui-li-static ui-body-inherit added-event">     <form id="form-add-prototype-events'+evNum+'">        <div data-role="fieldcontain" class="ui-field-contain">          <label for="prototype_event_domain">Event Domain:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">     <input type="text" name="prototype_event_domain" id="a_prototype_event_domain'+evNum+'" class="proto-field" value="" placeholder="explicit" /> </div>         <label for="prototype_event_type">Event Type:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">     <input type="text" name="prototype_event_type" id="a_prototype_event_type'+evNum+'" class="proto-field" value="" placeholder="status" />  </div>        <label for="prototype_event_attributes">Event Attributes:</label>   <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">       <input type="text" name="prototype_event_attributes" id="a_prototype_event_attributes'+evNum+'" class="proto-field" value="" placeholder="{\'wrangler\': rocks, ...}" />   </div>     </div>     </form>    </li>';
					$('#li-add-prototype-events' + (evNum - 1)).after(newEvent); //:
					$('#li-add-prototype-events' + (evNum)).attr('data-source', $('#li-add-prototype-events' + (evNum - 1)).attr('data-source'));
					evNum += 1;
				}

				var chNum = 1;
				$('.add-channel').off('tap').on('tap', addChannel);
				var subNum = 1;
				$('.add-subscription').off('tap').on('tap', addSubscription);
				var evNum = 1;
				$('.add-event').off('tap').on('tap', addEvent);


				$('#add-prototype-confirm-button').off('tap').on('tap', function(event)
				{
					var metaForm = process_form("#form-add-prototype-meta");
					var channelForms = [];
					for (i = 0; i < chNum; i++) {
						channelForms.push(process_form("#form-add-prototype-channels" + i));
					}
					var subscriptionForms = [];
					for (i = 0; i < subNum; i++) {
						subscriptionForms.push(process_form("#form-add-prototype-subs" + i));
					}
					var eventForms = [];
					for (i = 0; i < evNum; i++) {
						eventForms.push(process_form("#form-add-prototype-events" + i));
					}
					var pdsForm = process_form("#form-add-prototype-pds");

					var arr_channels = [];
					var arr_subscriptions = [];
					var arr_events = [];

					for (i = 0; i < chNum; i++) {
						i_channel = {
							name: channelForms[i]["prototype_channel_name"],
							type: channelForms[i]["prototype_channel_type"],
							attributes: channelForms[i]["prototype_channel_attributes"],
							policy: channelForms[i]["prototype_channel_policy"]
						};
						if (i_channel["name"] || i_channel["type"] || i_channel["attributes"] || i_channel["policy"])
							arr_channels.push(i_channel);
					}

					for (i = 0; i < subNum; i++) {
						i_subscription = {
							name: subscriptionForms[i]["prototype_sub_name"],
							name_space: subscriptionForms[i]["prototype_sub_namespace"],
							my_role: subscriptionForms[i]["prototype_sub_myRole"],
							subscriber_role: subscriptionForms[i]["prototype_sub_subRole"],
							subscriber_eci: subscriptionForms[i]["prototype_sub_eci"],
							channel_type: subscriptionForms[i]["prototype_sub_type"],
							attrs: subscriptionForms[i]["prototype_sub_attributes"]
						};
						if (i_subscription["name"] || i_subscription["name_space"] || i_subscription["my_role"] || i_subscription["subscriber_role"] || i_subscription["subscriber_eci"] || i_subscription["channel_type"] || i_subscription["attrs"])
							arr_subscriptions.push(i_subscription);
					}

					for (i = 0; i < evNum; i++) {
						i_event = {
							domain: eventForms[i]["prototype_event_domain"],
							type: eventForms[i]["prototype_event_type"],
							attrs: eventForms[i]["prototype_event_attributes"],
						};
						if (i_event["domain"] || i_event["type"] || i_event["attrs"])
							arr_events.push(i_event);
					}

					var proto_rids = [];
					var arr_rids = metaForm["prototype_rids"].split(";");
					for (var i in arr_rids)
						if (arr_rids[i] != "")
							proto_rids.push(arr_rids[i]);

					createdPrototype = {
						meta: {
							name: metaForm["prototype_name"],
							description: metaForm["prototype_description"]
						},

						rids: proto_rids,

						channels: arr_channels,
						subscriptions_request: arr_subscriptions,
						Prototype_events: arr_events,

						PDS: {
							profile: pdsForm["prototype_pds_profile"],
							general: pdsForm["prototype_pds_general"],
							settings: pdsForm["prototype_pds_settings"],
						}
					};

					console.log(">>>>>>>>> CREATED PROTOTYPE", createdPrototype);

					var protoJSON = JSON.stringify(createdPrototype);
					protoAttrs = {
						prototype_name: metaForm["prototype_name"],
						prototype: protoJSON
					}

					console.log(">>>>>>>>> JSON'D PROTOTYPE", protoAttrs);

					if(typeof protoAttrs !== "undefined") {
						$.mobile.loading("show", {
							text: "Adding Prototype...",
							textVisible: true
						});
						
						Devtools.addPrototype(protoAttrs, function(protoJSON) {
							console.log("Added Prototype: ", protoAttrs);
							$.mobile.changePage("#page-prototypes", {
								transition: 'slide'
							});
						}); 
						
					}
				}); 
			},

			updatePrototype: function(type, match, ui, page) {
				console.log("Update Prototype Handler");

				$('.added-channel').remove();
				$('.added-event').remove();
				$('.added-subscription').remove();
				document.getElementById('form-update-prototype-meta').reset();
				document.getElementById('form-update-prototype-channels0').reset();
				document.getElementById('form-update-prototype-subs0').reset();
				document.getElementById('form-update-prototype-events0').reset();
				document.getElementById('form-update-prototype-pds').reset();

				function addChannel(event) {
					//event.preventDefault();
					var newChannel = '<li id="li-update-prototype-channels'+chNum+'" class="ui-li-static ui-body-inherit added-channel">  <form id="form-update-prototype-channels'+chNum+'">        <div data-role="fieldcontain" class="ui-field-contain">     <label for="prototype_channel_name">Name:</label>  <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">    <input type="text" name="prototype_channel_name" id="u_prototype_channel_name'+chNum+'" value="" placeholder="Channel Name" /> </div>  <label for="prototype_channel_type">Type:</label>   <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">   <input type="text" name="prototype_channel_type" id="u_prototype_channel_type'+chNum+'" value="" placeholder="Channel Type" />  </div>    <label for="prototype_channel_attributes">Attributes:</label>   <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">   <input type="text" name="prototype_channel_attributes" id="u_prototype_channel_attributes'+chNum+'" value="" placeholder="Channel Attributes" />  </div>    <label for="prototype_channel_policy">Policy:</label>  <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">    <input type="text" name="prototype_channel_policy" id="u_prototype_channel_policy'+chNum+'" value="" placeholder="Channel Policy" /> </div> </div> </form> </li>';
					$('#li-update-prototype-channels' + (chNum - 1)).after(newChannel);
					$('#li-update-prototype-channels' + (chNum)).attr('data-source', $('#li-update-prototype-channels' + (chNum - 1)).attr('data-source'));
					chNum += 1;
				}

				function addSubscription(event) {
					//event.preventDefault();
					var newSub = '<li id="li-update-prototype-subs'+subNum+'" class="ui-li-static ui-body-inherit added-subscription">      <form id="form-update-prototype-subs'+subNum+'">        <div data-role="fieldcontain" class="ui-field-contain">          <label for="prototype_sub_name">Name:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_name" id="u_prototype_sub_name'+subNum+'" class="proto-field" value="" placeholder="Subscription Name" />  </div>        <label for="prototype_sub_namespace">Namespace:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_namespace" id="u_prototype_sub_namespace'+subNum+'" class="proto-field" value="" placeholder="ex: school_picos" />    </div>      <label for="prototype_sub_type">Channel Type:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_type" id="u_prototype_sub_type'+subNum+'" class="proto-field" value="" placeholder="Type" />   </div>       <label for="prototype_sub_myRole">My Role:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">      <input type="text" name="prototype_sub_myRole" id="u_prototype_sub_myRole'+subNum+'" class="proto-field" value="" placeholder="ex: Teacher" />    </div>      <label for="prototype_sub_subRole">Subscriber Role:</label>      <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">     <input type="text" name="prototype_sub_subRole" id="u_prototype_sub_subRole'+subNum+'" class="proto-field" value="" placeholder="ex: Student" />    </div>      <label for="prototype_sub_eci">Target:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">       <input type="text" name="prototype_sub_eci" id="u_prototype_sub_eci'+subNum+'" class="proto-field" value="" placeholder="Target Pico ECI (ex: 01234567-89AB-CDEF-0123-456789ABCDEF" />   </div>       <label for="prototype_sub_attributes">Attributes:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">       <input type="text" name="prototype_sub_attributes" id="u_prototype_sub_attributes'+subNum+'" class="proto-field" value="" placeholder="Subscription Attributes" />   </div>     </div>      </form>   </li>';
					$('#li-update-prototype-subs' + (subNum - 1)).after(newSub);
					$('#li-update-prototype-subs' + (subNum)).attr('data-source', $('#li-update-prototype-subs' + (subNum - 1)).attr('data-source'));
					subNum += 1;
				}

				function addEvent(event) {
					//event.preventDefault();
					var newEvent = '<li id="li-update-prototype-events'+evNum+'" class="ui-li-static ui-body-inherit added-event">     <form id="form-update-prototype-events'+evNum+'">        <div data-role="fieldcontain" class="ui-field-contain">          <label for="prototype_event_domain">Event Domain:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">     <input type="text" name="prototype_event_domain" id="u_prototype_event_domain'+evNum+'" class="proto-field" value="" placeholder="explicit" /> </div>         <label for="prototype_event_type">Event Type:</label>     <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">     <input type="text" name="prototype_event_type" id="u_prototype_event_type'+evNum+'" class="proto-field" value="" placeholder="status" />  </div>        <label for="prototype_event_attributes">Event Attributes:</label>   <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">       <input type="text" name="prototype_event_attributes" id="u_prototype_event_attributes'+evNum+'" class="proto-field" value="" placeholder="{\'wrangler\': rocks, ...}" />   </div>     </div>     </form>    </li>';
					$('#li-update-prototype-events' + (evNum - 1)).after(newEvent); //:
					$('#li-update-prototype-events' + (evNum)).attr('data-source', $('#li-update-prototype-events' + (evNum - 1)).attr('data-source'));
					evNum += 1;
				}

				var chNum = 1;
				$('.add-channel').off('tap').on('tap', addChannel);
				var subNum = 1;
				$('.add-subscription').off('tap').on('tap', addSubscription);
				var evNum = 1;
				$('.add-event').off('tap').on('tap', addEvent);


				var prototypeName = router.getParams(match[1])["prototype"];
				console.log(">>>>>>>>>>>> PROTOTYPE NAME: ", prototypeName);

				function populate_prototype_info() {
					Devtools.prototypes(function(proto_info) {
						var prototypeInfo = proto_info["prototypes"][prototypeName];
						console.log(">>>>>>>>>>>> PROTOTYPE INFORMATION: ", prototypeInfo);

						$("#u_prototype_name").val(prototypeName || "");
						$("#u_prototype_description").val(prototypeInfo["meta"]["description"] || "");
						$("#u_prototype_rids").val(prototypeInfo["rids"].toString().replace(/,/g, ";") || "");

						while (prototypeInfo["channels"].length > chNum)
							addChannel(null);
						for (i = 0; i < chNum; i++) {
							if (prototypeInfo["channels"][i] != undefined) {
								$("#u_prototype_channel_name" + i).val(prototypeInfo["channels"][i]["name"] || "");
								$("#u_prototype_channel_type" + i).val(prototypeInfo["channels"][i]["type"] || "");
								$("#u_prototype_channel_attributes" + i).val(prototypeInfo["channels"][i]["attributes"] || "");
								$("#u_prototype_channel_policy" + i).val(prototypeInfo["channels"][i]["name"] || "");
							}
						}

						while (prototypeInfo["subscriptions_request"].length > subNum)
							addSubscription(null);
						for (i = 0; i < subNum; i++) {
							if (prototypeInfo["subscriptions_request"][i] != undefined) {
								$("#u_prototype_sub_name" + i).val(prototypeInfo["subscriptions_request"][i]["name"] || "");
								$("#u_prototype_sub_namespace" + i).val(prototypeInfo["subscriptions_request"][i]["name_space"] || "");
								$("#u_prototype_sub_myRole" + i).val(prototypeInfo["subscriptions_request"][i]["my_role"] || "");
								$("#u_prototype_sub_subRole" + i).val(prototypeInfo["subscriptions_request"][i]["subscriber_role"] || "");
								$("#u_prototype_sub_eci" + i).val(prototypeInfo["subscriptions_request"][i]["subscriber_eci"] || "");
								$("#u_prototype_sub_type" + i).val(prototypeInfo["subscriptions_request"][i]["channel_type"] || "");
								$("#u_prototype_sub_attributes" + i).val(prototypeInfo["subscriptions_request"][i]["attrs"] || "");
							}
						}

						while (prototypeInfo["Prototype_events"].length > evNum)
							addEvent(null);
						for (i = 0; i < evNum; i++) {
							if (prototypeInfo["Prototype_events"][i] != undefined) {
								$("#u_prototype_event_domain" + i).val(prototypeInfo["Prototype_events"][i]["domain"] || "");
								$("#u_prototype_event_type" + i).val(prototypeInfo["Prototype_events"][i]["type"] || "");
								$("#u_prototype_event_attributes" + i).val(JSON.stringify(prototypeInfo["Prototype_events"][i]["attrs"] || ""));
							}
						}

						$("#u_prototype_pds_profile").val(JSON.stringify(prototypeInfo["PDS"]["profile"] || ""));
						$("#u_prototype_pds_general").val(JSON.stringify(prototypeInfo["PDS"]["general"] || ""));
						$("#u_prototype_pds_settings").val(JSON.stringify(prototypeInfo["PDS"]["settings"] || ""));
					});
				}

				populate_prototype_info();

				$('#update-prototype-confirm-button').off('tap').on('tap', function(event)
				{
					var metaForm = process_form("#form-update-prototype-meta");
					var channelForms = [];
					for (i = 0; i < chNum; i++) {
						channelForms.push(process_form("#form-update-prototype-channels" + i));
					}
					var subscriptionForms = [];
					for (i = 0; i < subNum; i++) {
						subscriptionForms.push(process_form("#form-update-prototype-subs" + i));
					}
					var eventForms = [];
					for (i = 0; i < evNum; i++) {
						eventForms.push(process_form("#form-update-prototype-events" + i));
					}
					var pdsForm = process_form("#form-update-prototype-pds");

					var arr_channels = [];
					var arr_subscriptions = [];
					var arr_events = [];

					for (i = 0; i < chNum; i++) {
						i_channel = {
							name: channelForms[i]["prototype_channel_name"],
							type: channelForms[i]["prototype_channel_type"],
							attributes: channelForms[i]["prototype_channel_attributes"],
							policy: channelForms[i]["prototype_channel_policy"]
						};
						if (i_channel["name"] || i_channel["type"] || i_channel["attributes"] || i_channel["policy"])
							arr_channels.push(i_channel);
					}

					for (i = 0; i < subNum; i++) {
						i_subscription = {
							name: subscriptionForms[i]["prototype_sub_name"],
							name_space: subscriptionForms[i]["prototype_sub_namespace"],
							my_role: subscriptionForms[i]["prototype_sub_myRole"],
							subscriber_role: subscriptionForms[i]["prototype_sub_subRole"],
							subscriber_eci: subscriptionForms[i]["prototype_sub_eci"],
							channel_type: subscriptionForms[i]["prototype_sub_type"],
							attrs: subscriptionForms[i]["prototype_sub_attributes"]
						};
						if (i_subscription["name"] || i_subscription["name_space"] || i_subscription["my_role"] || i_subscription["subscriber_role"] || i_subscription["subscriber_eci"] || i_subscription["channel_type"] || i_subscription["attrs"])
							arr_subscriptions.push(i_subscription);
					}

					for (i = 0; i < evNum; i++) {
						i_event = {
							domain: eventForms[i]["prototype_event_domain"],
							type: eventForms[i]["prototype_event_type"],
							attrs: eventForms[i]["prototype_event_attributes"],
						};
						if (i_event["domain"] || i_event["type"] || i_event["attrs"])
							arr_events.push(i_event);
					}

					var proto_rids = [];
					var arr_rids = metaForm["prototype_rids"].split(";");
					for (var i in arr_rids)
						if (arr_rids[i] != "")
							proto_rids.push(arr_rids[i]);

					createdPrototype = {
						meta: {
							name: metaForm["prototype_name"],
							description: metaForm["prototype_description"]
						},

						rids: proto_rids,

						channels: arr_channels,
						subscriptions_request: arr_subscriptions,
						Prototype_events: arr_events,

						PDS: {
							profile: pdsForm["prototype_pds_profile"],
							general: pdsForm["prototype_pds_general"],
							settings: pdsForm["prototype_pds_settings"],
						}
					};

					console.log(">>>>>>>>> CREATED PROTOTYPE", createdPrototype);

					/*
					if(typeof url !== "undefined" && url_check === true) {
						$.mobile.loading("show", {
							text: "Adding Prototype...",
							textVisible: true
						});
						
						Devtools.RegisterRuleset(url, function(directives) {
							console.log("registered ", url, directives);
							$.mobile.changePage("#page-prototypes", {
								transition: 'slide'
							});
						}); 
						
					}
					*/
				});
			},

			picologging: function(type, match, ui, page) {
				console.log("pico logging page");
				//$.mobile.loading("hide");
				eci = PicoNavigator.currentPico;
				function populate_logpage() {
					Pico.logging.status(eci, function(json){
						console.log("Logging status: ", json);
						$("#loglist" ).empty();
						if(json) {
							$("#logstatus").val("on").slider("refresh");
							loadSpinner("#loglist", "pico logs");


							Pico.logging.getLogs(eci, function(logdata){
								console.log("Retrieved logs");

								dynamicLogItems = "";
								$.each(logdata, function(i, logobj) {
									var eid_re = RegExp("\\s+" + logobj.eid);
									logobj.log_items = logobj.log_items.map(function(i){ return i.replace(eid_re, ''); 
								});
									var type="wrong";
									for (var i = 0; i < logobj.log_items.length; i++) {
										eventtype = logobj.log_items[i].match(/eventtype:hello/);
										if (eventtype !== null) {
											for (var i = 0; i < logobj.log_items.length; i++) {
												var eventtype = logobj.log_items[i].match(/function_name:.*$/);
												if (eventtype!== null) {
													type = eventtype[0].substring(eventtype[0].indexOf(':')+1);
													break;
												}
											}
											break;
										}
									}
									if(type === "wrong"){
										for (var i = 0; i < logobj.log_items.length; i++) {
											eventtype = logobj.log_items[i].match(/eventtype:.*$/);
											event_attrs = logobj.log_items[i].match(/event_attrs:.*$/);
											if (eventtype!== null && event_attrs === null) {
												type = eventtype[0].substring(eventtype[0].indexOf(':')+1);
												break;
											}
										}
									}
									logobj["type"] = type;
									dynamicLogItems += snippets.logitem_template(logobj);

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
						Pico.logging.reset(eci, {}, function() {
							populate_logpage();
						});
					} else {
						Pico.logging.inactive(eci, {});
						$("#loglist" ).empty();
					}
				});
				$( "#logrefresh" ).unbind("click").click(function(event, ui) {
					$("#loglist" ).empty();
					populate_logpage();
				});
				$( "#logclear" ).unbind("click").click(function(event, ui) {
					$("#loglist" ).empty();
					Pico.logging.flush(eci, {});
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
							channel_data = {
								"channel_name": install_form_data.channel_name,
								"channel_type" : install_form_data.channel_type,
								"attributes" : install_form_data.channel_attributes,
								"policy" : install_form_data.channel_policy
							};

							if( true //typeof channel_name !== "undefined"
						 		//&& channel_name.match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) // valid eci
						 		) {
								Devtools.installChannel(channel_data, function(directives) {
									console.log("installed ", channel_name, directives);
									$.mobile.changePage("#page-channel-management", {
										transition: 'slide'
									});
								}); 
							} else { // never will get here....................
								console.log("Invalid channel_name ", channel_name);
								$.mobile.loading("hide");
								$.mobile.changePage("#page-channel-management", {
									transition: 'slide'
								});
							}
						}
					};
					
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
							if (!/(OAUTH)+[.]*/.test(key)){// filter oauth for issue #44
								if(map[key]){map[key].push(channel);}
								else{
									map[key]=[channel];
								}
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
									"cid": channel["eci"],
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
						  $("#"+key.replace(new RegExp('[ ]', 'g'), "\\ ")+"2").append(dynamicChannelItems2).collapsibleset().collapsibleset( "refresh" );

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
          		"bootstrap_rids": client_bootstrapRids,

          		"app_name": client_name,
          		"app_description": client_Description,
          		"app_image_url": client_image_url,
          		"app_callback_url": client_callback_url,
          		"app_declined_url": client_declined_url

          	};
          	Devtools.authorizeClient(appData, function(directives) {
          		console.log("authorize ", client_name, directives);
          		$.mobile.changePage("#page-client-authorize", {
          			transition: 'slide'
          		});
          	}); 
          } else {//never comes here, we dont check for valid name.........
          	console.log("Invalid client_name ", client_name);
          	$.mobile.loading("hide");
          	$.mobile.changePage("#page-client-authorize", {
          		transition: 'slide'
          	});
          }
      });
      },

      authorized_clients: function(type, match, ui, page) {
      	console.log("authorized Clients page");

      	loadSpinner("#authorized client", "authorized client");

      	function populate_Authorized_clients() {
      		Devtools.showAuthorizedClients(function(client_list){
      			$("#authorized-clients" ).empty();

      			$.each(client_list, function(index, client) {
      				if (client !== null) {
      					if (typeof client["app_info"] !== 'undefined') {
      						$("#authorized-clients" ).append(
      							snippets.authorized_clients_template(
      								{"appClientName": client["app_info"]["name"].replace(new RegExp('[/]', 'g'), "%2F"),
      								"appECI": index,
      								"appDescription": client["app_info"]["description"].replace(new RegExp('[/]', 'g'), "%2F"),
      								"appImgURL":client["app_info"]["icon"].replace(new RegExp('[/]', 'g'), "%2F"),
      								"appCallbackURL": client["callbacks"].toString().replace(new RegExp('[/]', 'g'), "%2F").replace(new RegExp('[,]', 'g'), ";"),
      								"appDeclinedURL": client["app_info"]["declined_url"].replace(new RegExp('[/]', 'g'), "%2F"),
      								"appInfoPageURL": client["app_info"]["info_url"].replace(new RegExp('[/]', 'g'), "%2F"),
      								"appBootstrapRids": client["bootstrap"].toString().replace(new RegExp('[,]', 'g'), ";")}
      								)
      							).collapsibleset().collapsibleset( "refresh" );
	              //$("#installed-rulesets").listview("refresh");
	          }else if (typeof client["callbacks"] !== 'undefined'){
	          	$("#authorized-clients" ).append(
	          		snippets.authorized_clients_template(
	          			{"appName": client["callbacks"],
	                "appECI": index//,
	                //"appImageURL":client["app_info"]["icon"] // need a default..
	            }
	            )
	          		).collapsibleset().collapsibleset( "refresh" );
	          }else if (typeof client["bootstrap"] !== 'undefined'){
	          	$("#authorized-clients" ).append(
	          		snippets.authorized_clients_template(
	          			{"appName": client["bootstrap"],
	                "appECI": index//,
	                //"appImageURL":client["app_info"]["icon"]
	            }

	            )
	          		).collapsibleset().collapsibleset( "refresh" );
	          }
	      }
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
      				$.mobile.changePage("#page-client-authorize", {
      					transition: 'slide'
      				});
      			}); 
      		}
      	});
      },

      update_client: function(type, match, ui, page){
      	console.log("Showing update client page");
      	$.mobile.loading("hide");
      	var frm = "#form-update-client";
          $(frm)[0].reset(); // clear the fields in the form
          var client = router.getParams(match[1])["client"];
			//$(frm)[0].update_client_name.value = "client_name";

			// --- Fill fields with existing client data ---

			var urlClientName = router.getParams(match[1])["appName"];
			var urlClientDesc = router.getParams(match[1])["appDesc"];
			var iurlClientImage = router.getParams(match[1])["appImg"];
			var urlClientCallback = router.getParams(match[1])["appCb"];
			var urlClientDeclined = router.getParams(match[1])["appDec"];
			var urlClientInfo = router.getParams(match[1])["appInfo"];
			var urlClientRids = router.getParams(match[1])["appRids"];

			console.log("Name of client to update: ", urlClientName);

			$("#update_client_name").val(urlClientName);
			$("#update_client_Description").val(urlClientDesc);
			$("#update_client_image_url").val(iurlClientImage);
			$("#update_client_callback_url").val(urlClientCallback);
			$("#update_client_declined_url").val(urlClientDeclined);
			$("#update_client_info_page_url").val(urlClientInfo);
			$("#update_client_bootstrapRids").val(urlClientRids);

			$('#update-client-confirm-button').off('tap').on('tap', function(event)
			{
				$.mobile.loading("show", {
					text: "Updating Client...",
					textVisible: true
				});
				var athorize_form_data = process_form(frm);
				console.log(">>>>>>>>> client to update", athorize_form_data);
				var client_name = athorize_form_data.update_client_name;
				var client_Description = athorize_form_data.update_client_Description;
				var client_image_url = athorize_form_data.update_client_image_url;
				var client_callback_url = athorize_form_data.update_client_callback_url;
				var client_declined_url = athorize_form_data.update_client_declined_url;
				var client_info_page_url = athorize_form_data.update_client_info_page_url;
				var client_bootstrapRids = athorize_form_data.update_client_bootstrapRids;
          if( true //typeof channel_name !== "undefined"
            //&& channel_name.match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) // valid eci
            ) {
          	var appData={
          		"info_page": client_info_page_url,
          		"bootstrap_rids": client_bootstrapRids,

          		"app_name": client_name,
          		"app_description": client_Description,
          		"app_image_url": client_image_url,
          		"app_callback_url": client_callback_url,
          		"app_declined_url": client_declined_url
          	};
          	Devtools.updateClient(client,appData, function(directives) {
          		console.log("update ", client_name, directives);
          		$.mobile.changePage("#page-client-authorize", {
          			transition: 'slide'
          		});
          	}); 
          } else {//never comes here, we dont check for valid name.........
          	console.log("Invalid client_name ", client_name);
          	$.mobile.loading("hide");
          	$.mobile.changePage("#page-client-authorize", {
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
      			$.each(ruleset_list.description, function(k, ruleset) {
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
				alert_uniqueness = function(rid){
					var ridroot = rid.split(".");
					console.log("checking uniqueness: ", ridroot[0]);

					// this will slow things down. should we store a list in window so we dont have to racall the rulesets?
					Devtools.showInstalledRulesets( function(ruleset_list){
						$.each(ruleset_list.description, function(k, ruleset) {
							var root = k.split(".");
							console.log("root: ",root[0]);
							if (ridroot[0] ==root[0]) {
								$.noty.get(noty({
									timeout: false,
									text: 'You have installed a possible duplicate ruleset.  When you have duplicate rulesets installed, all events will be handled twice.  This can result in buggy behavior.',
									type: 'alert'
								}));
								// i wish i could break here
							}
						});
					});
				};
				submitInstall = function(){
					$.mobile.loading("show", {
						text: "Installing ruleset...",
						textVisible: true
					});
					var install_form_data = process_form(frm);
					console.log(">>>>>>>>> RIDs to install", install_form_data);
					var rid = install_form_data.rid;

						if( typeof rid !== "undefined" && rid.match(/^[A-Za-z][\w\d]+\.[\w\d]+$/) // valid RID
							) {
							alert_uniqueness(rid); 
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
				};
				
				$(frm).off('keypress').on('keypress', function(event){
					if (event.which == 13) {
						event.preventDefault();
						submitInstall();
					}
				});
				$('#install-ruleset-confirm-button').off('tap').on('tap', submitInstall);
			},
//--------------------------------Subscriptions---------------------------------
subscriptions: function(type, match, ui, page) {
	console.log("subscriptions page");
	loadSpinner("#page-subscription-management", "subscriptions");


	function populate_subscriptions() {
		Devtools.showSubscriptions(function(subscriptions){
			subscriptions = subscriptions.subscriptions;
			$("#Subscriptions" ).empty();
			if('inbound' in subscriptions){
				incoming = subscriptions.inbound;
				dynamic_subscriptions_items = "";
				dynamic_subscriptions_items2 = "";

				$.each(incoming, function(key, object) {
					$.each(object, function(key2, object) {
						dynamic_subscriptions_items2 +=
						snippets.subscription_incoming_template(
							{"name": object["subscription_name"],
							"name_space": object["name_space"],
							"relationship": object["relationship"],
							"e_cid": object["outbound_eci"],
							"c_name": object["channel_name"],
							"attributes": object["attributes"]
											//"attributes":JSON.stringify(object["attrs"])
										}
										);
					});
				});
								  //outter div
								  Type = "Pending-Inbound";
								  dynamic_subscriptions_items += 
								  snippets.subscription_tab_template(
											{"Type": Type,
											"Type-Name": "Pending Inbound"}
											);
								  $("#Subscriptions").append(dynamic_subscriptions_items).collapsibleset().collapsibleset( "refresh" );
								  $("#"+Type+"2").append(dynamic_subscriptions_items2).collapsibleset().collapsibleset( "refresh" );
								}
								if('outbound' in subscriptions){
									OutGoing = subscriptions.outbound;
									dynamic_subscriptions_items = "";
									dynamic_subscriptions_items2 = "";

									$.each(OutGoing, function(key, object) {
										$.each(object, function(key2, object) {
											console.log("outbound",object);
											console.log("key",key2);
											dynamic_subscriptions_items2 +=
											snippets.subscription_out_going_template(
												{"name": object["subscription_name"],
												"name_space": object["name_space"],
												"relationship": object["relationship"],
												"t_cid": object["subscriber_eci"],
												"e_cid": object["subscriber_eci"],
												"c_name": object["channel_name"],
											//"c_name": key2,
											"attributes": object["attributes"]
											//"attributes":JSON.stringify(object["attrs"])
										}
										);
										});
									});
								  //outter div
								  Type = "Pending-Outbound";
								  dynamic_subscriptions_items += 
								  snippets.subscription_tab_template(
											{"Type": Type,
											"Type-Name": "Pending Outbound"}
											);
								  $("#Subscriptions").append(dynamic_subscriptions_items).collapsibleset().collapsibleset( "refresh" );
								  $("#"+Type+"2").append(dynamic_subscriptions_items2).collapsibleset().collapsibleset( "refresh" );
								};
								if('subscribed' in subscriptions){
									subscribed = subscriptions.subscribed;
							//use teplate to format 

							dynamic_subscriptions_items = "";
							dynamic_subscriptions_items2 = "";
							
							$.each(subscribed, function(key, object) {
								$.each(object, function(key2, object) {
									dynamic_subscriptions_items2 +=
									snippets.subscription_template(
										{"name": object["subscription_name"],
										"name_space": object["name_space"],
										"relationship": object["relationship"],
										"outbound_cid": object["outbound_eci"],
										"inbound_cid": object["inbound_eci"],
										"c_name": key2,
										"attributes": object["attributes"]
										//"attributes":JSON.stringify(object["attrs"])
									}
									);
								});
							});
							  //outter div
							  Type = "subscriptions";
							  dynamic_subscriptions_items += 
							  snippets.subscription_tab_template(
											{"Type": Type,
											"Type-Name": "Subscriptions"}
											);
							  $("#Subscriptions").append(dynamic_subscriptions_items).collapsibleset().collapsibleset( "refresh" );
							  $("#"+Type+"2").append(dynamic_subscriptions_items2).collapsibleset().collapsibleset( "refresh" );
							}

							$('.approveButton').off('tap').on('tap', function(event){	
								event_eci = this.dataset.eventeci;
								console.log("event_eci: ",event_eci);
								channel_name =this.dataset.channelname;

								noty({
									layout: 'topCenter',
									text: 'Are you sure you want to approve subscription?',
									type: 'warning',

									buttons: [
									{addClass: 'btn btn-primary', text: 'Approve', onClick: function($noty) {
										$noty.close();

										Devtools.ApproveSubscription(
											{"channel_name": channel_name},
											function(directives){
												$.mobile.loading("hide");
												$("#Subscriptions" ).empty();
												populate_subscriptions();
											});
									}
								},
								{addClass: 'btn btn-danger', text: 'Cancel', onClick: function($noty) {
									$noty.close();

											//noty({layout: 'topCenter', text: 'You clicked "Cancel" button', type: 'error'});
										}
									}
									]
								});
							})
							$('.rejectButton').off('tap').on('tap', function(event){	
								event_eci = this.dataset.eventeci;
								console.log("event_eci: ",event_eci);
								channel_name =this.dataset.channelname;
								console.log("channel_name: ",channel_name);

								noty({
									layout: 'topCenter',
									text: 'Are you sure you want to reject subscription?',
									type: 'warning',

									buttons: [
									{addClass: 'btn btn-primary', text: 'Approve', onClick: function($noty) {
										$noty.close();

										Devtools.RejectIncomingSubscription(
											{"channel_name": channel_name},
											function(directives){
												$.mobile.loading("hide");
												$("#Subscriptions" ).empty();
												populate_subscriptions();
											});
									}
								},
								{addClass: 'btn btn-danger', text: 'Cancel', onClick: function($noty) {
									$noty.close();

											//noty({layout: 'topCenter', text: 'You clicked "Cancel" button', type: 'error'});
										}
									}
									]
								});
							})
							$('.CancelSubscriptionButton').off('tap').on('tap', function(event){	
								event_eci = this.dataset.eventeci;
								console.log("event_eci: ",event_eci);
								channel_name =this.dataset.channelname;

								noty({
									layout: 'topCenter',
									text: 'Are you sure you want to Cancel subscription?',
									type: 'warning',

									buttons: [
									{addClass: 'btn btn-primary', text: 'Approve', onClick: function($noty) {
										$noty.close();

										Devtools.RejectOutgoingSubscription(
											{"channel_name": channel_name},
											function(directives){
												$.mobile.loading("hide");
												$("#Subscriptions" ).empty();
												populate_subscriptions();
											});
									}
								},
								{addClass: 'btn btn-danger', text: 'Cancel', onClick: function($noty) {
									$noty.close();

											//noty({layout: 'topCenter', text: 'You clicked "Cancel" button', type: 'error'});
										}
									}
									]
								});
							})
							$('.UnSubscribeButton').off('tap').on('tap', function(event){	
								event_eci = this.dataset.eventeci;
								console.log("event_eci: ",event_eci);
								channel_name =this.dataset.channelname;

								noty({
									layout: 'topCenter',
									text: 'Are you sure you want to unsubscribe?',
									type: 'warning',

									buttons: [
									{addClass: 'btn btn-primary', text: 'Approve', onClick: function($noty) {
										$noty.close();

										Devtools.Unsubscribe(
											{"channel_name": channel_name},
											function(directives){
												$.mobile.loading("hide");
												$("#Subscriptions" ).empty();
												populate_subscriptions();
											});
									}
								},
								{addClass: 'btn btn-danger', text: 'Cancel', onClick: function($noty) {
									$noty.close();

											//noty({layout: 'topCenter', text: 'You clicked "Cancel" button', type: 'error'});
										}
									}
									]
								});
							})
						})
}

$.mobile.loading("hide");

populate_subscriptions();

},
subscribe: function(type, match, ui, page) {
	console.log("Subscribe page");
	$.mobile.loading("hide");
	var frm = "#form-subscribe";
					$(frm)[0].reset(); // clear the fields in the form
					
					subscribeForm = function(){
						{
							$.mobile.loading("show", {
								text: "subscribing...",
								textVisible: true
							});
							var subscribe_form_data = process_form(frm);
							console.log(">>>>>>>>> Subscription ", subscribe_form_data);
							var subscription_Data={
								"name": subscribe_form_data.Subscription_name,
								"name_space": subscribe_form_data.Subscription_name_space,
								"subscriber_eci": subscribe_form_data.Subscription_target.trim(),
								"channel_type": subscribe_form_data.Subscription_type,
								"my_role" : subscribe_form_data.Subscription_my_role,
								"subscriber_role" : subscribe_form_data.Subscription_your_role,
								"attrs": subscribe_form_data.Subscription_attrs
							};
							if( true 	) {
								Devtools.RequestSubscription(subscription_Data, function(directives) {
									console.log("subscribe ", subscription_Data, directives);
									$.mobile.changePage("#page-subscription-management", {
										transition: 'slide'
									});
								}); 
							} else {// dead code
								console.log("Invalid subscriptions ", subscription_Data);
								$.mobile.loading("hide");
								$.mobile.changePage("#page-subscription-management", {
									transition: 'slide'
								});
							}
						}
					}
					
					$(frm).off('keypress').on('keypress', function(event) {
						if (event.which == 13) {
							event.preventDefault();
							subscribeForm();
						}
					});
					
					$('#Subscribe-confirm-button').off('tap').on('tap', subscribeForm);
				},

//--------------------------------End oF Subscriptions---------------------------------

			//<!-- -------------------- Scheduled Templates---------------------- -->
			schedule_event: function(type, match, ui, page) {
				console.log("schedule event");
				$.mobile.loading("hide");
				var frm = "#form-schedule-event";
					$(frm)[0].reset(); // clear the fields in the form
					
					submitEventSchedule = function(){
						{
							var schedule_form_data = process_form(frm);
							console.log(">>>>>>>>> event to schedule", schedule_form_data);
							var event_domain = schedule_form_data.event_domain;
							var event_type 	 = schedule_form_data.event_type;
							var	date_time 	 = schedule_form_data.date_time;
							var recurrment   = schedule_form_data.recurrment;
							var event_attributes	 = schedule_form_data.event_attributes;
							var tz_date_time = moment(date_time);
							console.log("time with moment:", tz_date_time.tz('America/Phoenix').format());
							var sch_data ={
								"event_type": event_type,
								"time" : date_time,
								"do_main": event_domain,
								//"timespec": ,
								"date_time" : tz_date_time.tz('America/Phoenix').format(), //date_time,
								"recurrment" : recurrment,
								"attributes" : event_attributes
							}
							if( schedule_form_data.date_time ) {
								$.mobile.loading("show", {
									text: "Scheduling event...",
									textVisible: true
								});
								Devtools.scheduleEvent(sch_data, function(directives) {
									console.log("scheduled ", sch_data, directives);
									$.mobile.changePage("#page-schedules", {
										transition: 'slide'
									});
								}); 
							} else {

								noty({
									layout: 'topCenter',
									text: 'You are missing a proper time and date to schedule this event.',
									type: 'warning',

									buttons: [
									{addClass: 'btn btn-primary', text: 'Continue', onClick: function($noty) {
										$noty.close();
										noty({layout: 'topCenter', text: 'Include a date/time', type: 'error'});

									}
								},
								{addClass: 'btn btn-danger', text: 'Return to Scheduled Events', onClick: function($noty) {
									$noty.close();

									$.mobile.loading("show", {
										text: "Canceling scheduling this event...",
										textVisible: true
									});
									$.mobile.loading("hide");
													//refreshes the page because refreshPage() takes us to the homepage
													$.mobile.changePage("#page-schedules", {
														transition: 'slide'
													});
												}
											}
											]
										});







								//	console.log("Invalid channel_name ", channel_name);
								//	$.mobile.loading("hide");
								//	$.mobile.changePage("#page-channel-management", {
								//		transition: 'slide'
								//	});
							}
						}
					}
					
					$(frm).off('keypress').on('keypress', function(event) {
						if (event.which == 13) {
							event.preventDefault();
							submitEventSchedule();
						}
					});
					
					$('#schedule-event-confirm-button').off('tap').on('tap', submitEventSchedule);
				},
				scheduled_events: function(type, match, ui, page) {
					console.log("scheduled events");
					loadSpinner("#schedule_events", "Schedule Events");

					function populate_scheduled_events() {

						Devtools.showScheduledEvents(function(events_list){

							$("#scheduled-events-list").empty();

							dynamicScheduledEvents = "";
							$.each(events_list, function(k, scheduled_event) {
								var d = new Date(scheduled_event[4] * 1000);
								var cron = scheduled_event[5] || "";
								if (cron)
									cron = ": " + cron;
								dynamicScheduledEvents += snippets.scheduled_events_template({
									"sid": scheduled_event[0],
									"title": scheduled_event[1] + cron,
									"name": scheduled_event[1],
									"type": scheduled_event[2] + cron,
									"rid": scheduled_event[3],
									"epoch_time": d
								});
							//console.log(Date.parse(d)/1000);
							//console.log(scheduled_event[4]);
						});

							$("#scheduled-events-list").append(dynamicScheduledEvents).collapsibleset().collapsibleset( "refresh" );
							$.mobile.loading("hide");


					//-------------cancel scheduled event-------------------
					$('.cancelEventButton').off('tap').on('tap', function(event)
					{	
						console.log(this.id);
						sid = this.id;

						console.log("Canceling this event");
						noty({
							layout: 'topCenter',
							text: 'Are you sure you want to cancel this scheduled event?',
							type: 'warning',

							buttons: [
							{addClass: 'btn btn-primary', text: 'Yes', onClick: function($noty) {
								$noty.close();
								if(typeof sid !== "undefined") {
									$.mobile.loading("show", {
										text: "Canceling this scheduled event...",
										textVisible: true
									});
									Devtools.cancelEvent(sid, function(directives){
										console.log("Canceling the event", sid, directives);
										$.mobile.loading("hide");
													//refreshes the page because refreshPage() takes us to the homepage
													$("#scheduled-events").empty();
													populate_scheduled_events();
												});
								}
							}
						},
						{addClass: 'btn btn-danger', text: 'No', onClick: function($noty) {
							$noty.close();
							noty({layout: 'topCenter', text: 'You clicked "No" button', type: 'error'});
						}
					}
					]
				});
						

					});
				});
					}

					function populate_schedule_history() {

						Devtools.showScheduledEvents(function(events_list){
							$("#schedule-history-list").empty();

							dynamicScheduleHistory = "";
							$.each(events_list, function(k, scheduled_event) {
								var event_data = {
									id: scheduled_event[0]
								};

								Devtools.showScheduleHistory(event_data, function(event_history){
									var last_fire = event_history["fired"];
									if(last_fire == "1970-01-01T00:00:00+00:00") {
										last_fire = "Has Not Fired";
									}
									var cron = scheduled_event[5] || "";
									if (cron)
										cron = ": " + cron;

									dynamicScheduleHistory = snippets.schedule_history_template({
										"sid": scheduled_event[0],
										"title": scheduled_event[1] + cron,
										"name": scheduled_event[1],
										"next": event_history["next"] || "Already Fired",
										"fired": last_fire || "N/A",
										"keep": event_history["keep_until"] || "N/A"
									});
									$("#schedule-history-list").append(dynamicScheduleHistory).collapsibleset().collapsibleset( "refresh" );

								});
							});
							$.mobile.loading("hide");
						});
					}

					populate_scheduled_events();
					populate_schedule_history();
				},
			},
	// <!-- -------------------- <End oF> Scheduled ---------------------- -->

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
		list_prototypes_template: Handlebars.compile($("#list-prototypes-template").html() || ""),
		logitem_template: Handlebars.compile($("#logitem-template").html() || ""),
		installed_channels_template: Handlebars.compile($("#installed-channels-template").html() || ""),
		installed_channels_template2: Handlebars.compile($("#installed-channels-template2").html() || ""),
		installed_ruleset_template: Handlebars.compile($("#installed-ruleset-template").html() || ""),
		confirm_ruleset_remove: Handlebars.compile($("#confirm-ruleset-remove-template").html() || ""),
		confirm_channel_remove: Handlebars.compile($("#confirm-channel-remove-template").html() || ""),
		about_account: Handlebars.compile($("#about-account-template").html() || ""),
		child_pico_template: Handlebars.compile($("#child-pico-template").html() || ""),

		// spime
		spime_template: Handlebars.compile($("#Spime-template").html() || ""),
		// spime 

		authorized_clients_template: Handlebars.compile($("#authorized-clients-template").html() || ""),
		confirm_client_remove_template: Handlebars.compile($("#confirm-client-remove-template").html() || ""),
		scheduled_events_template: Handlebars.compile($("#scheduled-events-template").html() || ""),
		schedule_history_template: Handlebars.compile($("#schedule-history-template").html() || ""),
		//subscriptions
		subscription_tab_template: Handlebars.compile($("#subscription-tab-template").html() || ""),
		subscription_incoming_template: Handlebars.compile($("#subscription-incoming-template").html() || ""),
		subscription_out_going_template: Handlebars.compile($("#subscription-out-going-template").html() || ""),
		subscription_template: Handlebars.compile($("#subscription-template").html() || "")
	};

	function plant_authorize_button()
	{
		//Oauth through kynetx
		console.log("plant authorize button");
		var OAuth_kynetx_URL = wrangler.getOAuthURL();
		$('#authorize-link').attr('href', OAuth_kynetx_URL);
		var OAuth_kynetx_newuser_URL = wrangler.getOAuthNewAccountURL();
		$('#create-link').attr('href', OAuth_kynetx_newuser_URL);
		
		$('#account-link').attr('href', "https://" + wrangler.login_server + "/login/profile");
		$('#account-link-2').attr('href', "https://" + wrangler.login_server + "/login/profile");
		
		$('#logout-link').off('tap').on('tap', function(event) {
			window.open("https://" + wrangler.login_server + "/login/logout?" + Math.floor(Math.random() * 9999999), "_blank");
			wrangler.removeSession(true); // true for hard reset (log out of login server too)
			$.mobile.changePage('#page-authorize', {
				transition: 'slide'
			}); // this will go to the authorization page.
		});
	}

	function onMobileInit() {
		console.log("mobile init");
		$.mobile.autoInitialize = false;
	}

	function onPageLoad() {// Document.Ready
		console.log("document ready");
		wrangler.retrieveSession();
		// only put static stuff here...
		plant_authorize_button();

		$('.logout').off("tap").on("tap", function(event)
		{
			$.mobile.changePage('#account', {
				transition: 'slide'
			});
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
		
		
		try {
			var authd = wrangler.authenticatedSession();
			if(authd) {
				console.log("Authorized");
				Devtools.ensureBootstrap();
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


