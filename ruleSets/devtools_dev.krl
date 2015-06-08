//b506607x14
//Flush the ruleset webpage: http://cs.kobj.net/ruleset/flush/b506607x14.prod;b506607x14.dev
ruleset devtools {
	meta {
		name "DevTools"
		description <<
			ruleset for DevTools developing website
		>>
		author "KRL-DevTools Developer"

		use module b16x24 alias system_credentials


		logging on

		use module a169x625 alias CloudOS
		use module a41x226 alias OAuthRegistry //(appManager)
		//use module a169x625 alias PicoInspector

		provides showRulesets, showInstalledRulesets, aboutPico, showInstalledChannels, showClients, get_my_apps, get_app, get_secret
		sharing on
	}
	global {
		
		
		showRulesets = function(){
			rulesets = rsm:list_rulesets(meta:eci()).sort();

			rulesetGallery = rulesets.map(function(rid){
				ridInfo = rsm:get_ruleset(rid).defaultsTo({});
				appURL = ridInfo{"uri"};
				ridInfo
				});

			rulesetGallery
		};

		showInstalledRulesets = function() {
		  rulesets = CloudOS:rulesetList(meta:eci()).defaultsTo({}, ">> list of installed rulesets undefined >>");
		  rids_string = rulesets{"rids"}.join(";");
		  describe_url = "https://#{meta:host()}/ruleset/describe/#{$rids_string}";
		  resp = http:get(describe_url);
		  resp{"status_code"} eq "200" => resp{"content"}.decode()
		                                | resp.klog(">> error retrieving description for rid list >> ")
		}; 

		aboutPico = function() {
	          account_profile = CloudOS:accountProfile()
		                      .put( ["oauth_eci"], meta:eci() )
		  		      ;
		  account_profile 
		};

		showInstalledChannels = function() {
		  channels = CloudOS:channelList(meta:eci()).defaultsTo({}, ">> list of installed channels undefined >>")
		  //.klog(">>> channels cloud call >>>")
		  ;
		  krl_struct = channels.decode()
		  .klog(">>krl_struct>> ")
		  ;
		krl_struct;
		};
		showClients = function() {
			clients = get_my_apps();
			//clients = OAuthRegistry:get_my_apps();//__________----------------------------------- should not use this ruleset
			krl_struct = clients.decode()
			.klog(">>>>krl_struct")
			;
			krl_struct;
		};
		updatePCIbootstrap = defaction(bootstrapRids){
			boot = bootstrapRids.map(function(rid) { pci:add_bootstrap(appECI, rid) }).klog(">>>>>> bootstrap add result >>>>>>>");
			send_directive("pci bootstraps updated");
		}
		//------------------------------- Authorize clients-------------------
		get_my_apps = function(){
	      ent:appRegistry
	    };

	    get_app = function(appECI){
	      (app:appRegistry{appECI}).delete(["appSecret"])
	    };
	    
	    get_secret = function(appECI){
	      app:appRegistry{[appECI, "appSecret"]}
	    };
	}

	

	rule deleteRulesets {
		select when devtools delete_rid//subm form-update-url
		pre {
			rid = event:attr("rid").defaultsTo("", ">> missing event attr rids >> ");
		}
		if(rid.length() > 0 ) then
		{
			rsm:delete(rid); 
		}
		fired {
			log ">>>> flushed #{rid} <<<<";
		}
		
	}

	
	rule updateRuleset {
		select when web submit "#formUpdateRuleset"
		pre {
			rulesetID = event:attr("rulesetID");
			newURL = event:attr("appURL");
		}
		{
			rsm:update(rulesetID) setting(updatedSuccessfully)
			with uri = newURL;
			CloudRain:setHash('/refresh');
		}
		fired {
			raise system event rulesetUpdated
			with rulsetID = rulesetID if(updatedSuccessfully);
		}
	}

	rule updateUrl {
		select when devtools update_url//subm form-update-url
		pre {
			rid = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
			newURL = event:attr("url"); //should pull from the form on update url template
		}
		{
			rsm:update(rid) setting(updatedSuccessfully)
			with uri = newURL;
		}
		fired {
			raise system event rulesetUpdated
			with rid = rid if(updatedSuccessfully);
		}
	}

	rule flushRuleset {
		select when devtools flush_rid
		pre {
			rid = event:attr("rid").defaultsTo("", ">> missing event attr rid >> ");
		}
		if(rid.length() > 0 ) then
		{
			rsm:flush(rid) 
		}
		fired {
		  log ">>>> flushed #{rid} <<<<"
		} 
	}

	// ---------- ruleset installation ----------
	rule installRulesets {
	  select when devtools install_rulesets
	  pre {
	    rids = event:attr("rids").klog(">> rids attribute <<").defaultsTo("", ">> missing event attr rids >> ").klog(">> rids attribute <<");
            result = rsm:is_valid(rids) => CloudOS:rulesetAddChild(rids, meta:eci()).klog(">> result of installing #{rids} >> ")
	                                 | {"status": false};
          }
	  if(result{"status"}) then {
 	    send_directive("installed #{rids}");
          }
	  fired {
	    log(">> successfully installed rids #{rids} >>");
          } else {
	    log(">> could not install rids #{rids} >>");
          }
        }

    rule uninstallRulesets {
	  select when devtools uninstall_rulesets
	  pre {
	    rids = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
	    result = CloudOS:rulesetRemoveChild(rids, meta:eci()).klog(">> result of uninstalling #{rids} >> ");
          }
	  if(result{"status"}) then {
 	    send_directive("uninstalled #{rids}");
          }
	  fired {
	    log(">> successfully uninstalled rids #{rids} >>");
          } else {
	    log(">> could not uninstall rids #{rids} >>");
          }
        }

    rule registerRuleset {
		select when devtools register_ruleset
		pre {
			rulesetURL= event:attr("rulesetURL");
		}
		{
			rsm:register(rulesetURL) setting (rid);
		}
		fired {
			raise system event rulesetRegistered
			with rulsetID = rid{"rid"} if(rid);
		}
	}
	//---------------- channel manager ---------------

	rule CreateChannel {
	  select when devtools create_channel
	  pre {
		channels = CloudOS:channelList(meta:eci()).defaultsTo({}, ">> list of installed channels undefined >>")
		.klog(">>>>> list of channel. ");
	    channelName = event:attr("channelName").defaultsTo("", ">> missing event attr channels >> ");
            result = channelName.match(re/\w[\w\d_-]*/) => CloudOS:channelCreate(channelName).klog(">> result of creating #{channels} >> ")
	                                 | {"status": false};
          }
	  if(result{"status"}) then {
 	    send_directive("Created #{channelName}");
          }
	  fired {
	    log(">> successfully created channels #{channelName} >>");
          } else {
	    log(">> could not create channels #{channelName} >>");
          }
        }

    rule DestroyChannel {
	  select when devtools channel_destroy
	  pre {
	    channelID = event:attr("channelID").defaultsTo("", ">> missing event attr channels >> ");
	    result = CloudOS:channelDestroy(channelID).klog(">> result of creating #{channels} >> ");
          }
	  if(result{"status"}) then {
 	    send_directive("deleted #{channelID}");
          }
	  fired {
	    log(">> successfully deleted channel #{channelID} >>");
          } else {
	    log(">> could not delete channel #{channelID} >>");
          }
        }
        //----------------- not a CloudOS function yet (update channel) ----------------
    rule UpdateChannel {
	  select when devtools update_channel
	  pre {
	    channelID = event:attr("channelID").defaultsTo("", ">> missing event attr channels >> ");
	    result = CloudOS:channelUpdate(channelID, meta:eci()).klog(">> result of updating #{channels} >> ");
          }
	  if(result{"status"}) then {
 	    send_directive("update #{channelID}");
          }
	  fired {
	    log(">> successfully updated channel #{channelID} >>");
          } else {
	    log(">> could not update channel #{channelID} >>");
          }
        }
    //-------------------OAuthRegistry---------------

// why are there apps and appRegistry, not just 1?????

    rule AuthorizeClient {
		select when devtools authorize_client
	    pre {
	      appDataPassed = event:attr("appData").klog(">>>>>> attr appData >>>>>>>");
	      appCallbackURL = appDataPassed{"appCallbackURL"};

	      bootstrapRids = appDataPassed{"bootstrapRid"}.split(re/;/).klog(">>>>>> bootstrap in >>>>>>>");

	      application_eci_result = (pci:new_eci(meta:eci(), {
	        'name' : 'Oauth Developer ECI',
	        'eci_type' : 'OAUTH'
	      }) || {});

	      application_eci = application_eci_result{"cid"};

	      developer_secret = pci:create_developer_key();
	      permission = pci:set_permissions(application_eci, developer_secret, ['oauth','access_token']);
	      callback = pci:add_callback(application_eci, appCallbackURL);
      	  
      	  bs = bootstrapRids.map(function(rid) { pci:add_bootstrap(application_eci, rid) }).klog(">>>>>> bootstrap add result >>>>>>>");

      	  // [FIXME, PJW] hack. a41x226 shouldn't be keeping this data, should be in PCI
    	  appinfo = pci:add_appinfo(appECI, // is appinfo used anywhere????????
    	    {"icon": appDataPassed{"appImageURL"},
      		"name": appDataPassed{"appName"},
         	"description": appDataPassed{"appDescription"},
         	"info_page": appDataPassed{"info_page"}
        	}).klog(">>>>> stored appinfo >>>>>> ");
	      
	      appData = (
	        ((appDataPassed
	        ).put(["appSecret"], developer_secret)
	        ).put(["appECI"], application_eci)
	      );

	      apps = (app:appRegistry || {}).put([application_eci], appData);
	    }
	    if (// redundant???
	      appData &&
	      appData{"appName"} &&
	      appData{"appImageURL"} &&
	      appData{"appCallbackURL"} &&
	      appData{"appDeclinedURL"}
	    ) then{
	      noop();
	    }
	    fired {
	      log appCallbackURL;//???????????
	      //set app:appRegistry {} if (not app:appRegistry); // whats this line do? clear if empty or not created????
	      //set app:appRegistry{application_eci} appData if (application_eci);
	      set app:appRegistry apps;
	    }
    }

    rule RemoveClient {
	  	select when devtools remove_client
	  	pre {
	    	appECI = event:attr("appECI").defaultsTo("", ">> missing event attr channels >> ").klog(">>>>>> appECI >>>>>>>");
	    	developer_secret = get_secret(appECI);
	    	//isset = pci:remove
	    	//isset = pci:remove_appinfo(appECI);
	    	apps = app:appRegistry;
		}//remove app from persistant varibles. 
	    if (app:appRegistry{appECI} != {}) then {
	  		//undo all of pci pemissions
	    	pci:clear_permissions(appECI,developer_secret, ['oauth','access_token']); // do I need to do anything else then clear_permissions??
			send_directive("removing  #{appECI}");
        }
	  	fired { 
	  		set app:appRegistry apps.delete([appECI,"appData"]).klog(">>>>>> app >>>>>>>");
        }
    }
    rule UpdateClient {
	  select when devtools update_client
	    pre {
	      oldApp = app:appRegistry{event:attr("appECI").klog(">>>>>> appECI >>>>>>>")}.klog(">>>>>> oldApp >>>>>>>");
	      appData = ( // keep apps secrets 
	        ((event:attr("appData")
	        ).put(["appSecret"], oldApp{"appSecret"})
	        ).put(["appECI"], oldApp{"appECI"})
	      );
	    
	      bootstrapRids = appData{"bootstrapRid"}.split(re/;/).klog(">>>>>> bootstrap in >>>>>>>");
	      apps = (ent:appRegistry || {}).put([oldApp{"appECI"}], appData);// create new appRegistry

	    }
	        if ( // valid input for update... is it checked one level down? do we need this check?
	      oldApp &&
	      appData &&
	      appData{"appName"} &&
	      appData{"appImageURL"} &&
	      appData{"appCallbackURL"} &&
	      appData{"appDeclinedURL"}
	    ) then{
	        send_directive("Updating clients");
	      	pci:remove_callback(eci, oldApp{"appCallbackURL"});// remove old callback. do we need this????
          	pci:add_callback(eci, appData{"appCallbackURL"}); // update callback. should this be in pre block(it mutates).
	     	pci:list_bootstrap(appECI);
	     	pci:add_appinfo(appECI, 
		        {"icon": appData{"appImageURL"},
		         "name": appData {"appName"},
		         "description": appData {"appDescription"},
		         "info_page": appData {"appInfoURL"}
		        });
	      	pci:remove_bootstrap(appECI, oldBootstrapRids);
	      	updatePCIbootstrap(bootstrapRids);// hack.. is there a better way?
      	//	bootstrapRids.map(function(rid) { pci:add_bootstrap(appECI, rid) }).klog(">>>>>> bootstrap add result >>>>>>>");
	    }
	    fired {
	    //  set app:appRegistry {} if (not app:appRegistry);
	    //  set app:appRegistry{oldApp{"appECI"}} appData if(appData);
	      set ent:appRegistry apps;
	   //   raise explicit event updateCallback 
	   //       with appECI = oldApp{"appECI"}
	   //       and  oldCbURL = oldApp{"appCallbackURL"};
	    }
	}
	  rule ImportClientDataBase {// only call once before you create any clients.
	  select when devtools ImportClientDataBase
	  pre {
	    	apps = OAuthRegistry:get_my_apps().klog(">>>>>> apps >>>>>>>");// does this get the secrets too?
	    	//apps = apps.union(app:appRegistry);
          }
          {
          	noop();
          }
	  always {
	  	set ent:appRegistry apps;
        }
    }
    /*
    rule UpdateClientCallBack {
		select when devtools update_client_call_back
		pre {
          // get the applications eci for which we are updating
          // the callback url
          eci = event:attr("appECI");
          // get the old callback url that we need to remove
          // via the pci
          oldCbURL = event:attr("oldCbURL");
          // get the new callback that we need to register
          // via the pci
          cbURL = app:appRegistry{[eci, "appCallbackURL"]};
          // perform deregistration of old callback
          // url
          resp = pci:remove_callback(eci, oldCbURL);
          // perform registry of new callback url
          reg = pci:add_callback(eci, cbURL)
      }
      if (true) then {
          noop();
      }
    }*/
}