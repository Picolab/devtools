//b507199x0
//Flush the ruleset webpage: http://cs.kobj.net/ruleset/flush/b507199x0.prod;b507199x0.dev
ruleset devtools {
	meta {
		name "DevTools"
		description <<
			ruleset for DevTools produciton (picolabs)
		>>
		author "KRL-DevTools Developer"

		use module b16x24 alias system_credentials


		logging on

		use module a169x625 alias CloudOS
		use module a41x226 alias OAuthRegistry //(appManager)
		//use module a169x625 alias PicoInspector

		provides rulesetList, showRulesets, showInstalledRulesets, aboutPico, showInstalledChannels, showClients, get_my_apps, get_app, get_registry, get_secret, list_bootstrap, get_appinfo, list_callback
		sharing on
	}
	global {
		
        showRulesets = function(){
            rulesets = rsm:list_rulesets(meta:eci()).sort().klog(">>>>>> rsm:list_rulesets result vs.15>>>>>>>");

            rulesetGallery = rulesets.map( function(rid){
                foo = rid.klog(">>>>>> rid >>>>>>>");
                ridInfo = rsm:get_ruleset( foo ).defaultsTo({}).klog(">>>>>> rsm:get_ruleset result >>>>>>>");
                appURL = ridInfo{"uri"};
                ridInfo
                }).klog(">>>>>> rulesets map() ... rsm:get_ruleset result >>>>>>>");

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
		//------------------------------- Authorize clients-------------------
		showClients = function() {
			clients = get_my_apps();
			//clients = OAuthRegistry:get_my_apps();//__________----------------------------------- should not use this ruleset
			krl_struct = clients.decode()
			.klog(">>>>krl_struct")
			;
			krl_struct;
		};
		addPCIbootstraps = defaction(appECI,bootstrapRids){
			boot = bootstrapRids.map(function(rid) { pci:add_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap add result >>>>>>>");
			send_directive("pci bootstraps updated.")
			 	with rulesets = list_bootstrap(appECI); // is this working?
		};
		removePCIbootstraps = defaction(appEC,IbootstrapRids){
			boot = bootstrapRids.map(function(rid) { pci:remove_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap removed result >>>>>>>");
			send_directive("pci bootstraps removed.")
			 	with rulesets = list_bootstrap(appECI); 
		};
		removePCIcallback = defaction(appECI,PCIcallbacks){
			PCIcallbacks =( PCIcallbacks || []).append(PCIcallbacks);
			boot = PCIcallbacks.map(function(url) { pci:remove_callback(appECI, url); }).klog(">>>>>> callback remove result >>>>>>>");
			send_directive("pci callback removed.")
			 	with rulesets = pci:list_callback(appECI);
		};
		get_my_apps = function(){
      	  ent:apps
	    };
	    get_registry = function(){
	    	app:appRegistry;
	    };
	    get_app = function(appECI){
	      (app:appRegistry{appECI}).delete(["appSecret"])
	    };
	    get_secret = function(appECI){
	      app:appRegistry{[appECI, "appSecret"]}
	    };
	    list_bootstrap = function(appECI){
	    	pci:list_bootstrap(appECI);
	    };
	    get_appinfo = function(appECI){
	    	pci:get_appinfo(appECI);
	    };
	    list_callback = function(appECI){
	    	pci:list_callback(appECI);
	    };
		//------------------------------- <End oF> Authorize clients-------------------
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
			with rulesetID = rid{"rid"} if(rid);
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

    rule AuthorizeClient {
		select when devtools authorize_client
	    pre {
	    	appData={
         	"info_page": event:attr("info_page"),
         	"bootstrapRids": event:attr("bootstrapRids"),
            "appName": event:attr("appName"),
            "appDescription": event:attr("appDescription"),
            "appImageURL": event:attr("appImageURL"),
            "appCallbackURL": event:attr("appCallbackURL"),
            "appDeclinedURL": event:attr("appDeclinedURL")
          };
	      appDataPassed = appData;
	      //appDataPassed = event:attr("appData").klog(">>>>>> attr appData >>>>>>>");
	      appCallbackURL = appDataPassed{"appCallbackURL"}.klog(">>>>>> app callback >>>>>>>");

	      bootstrapRids = appDataPassed{"bootstrapRids"}.klog(">>>>>> bootstrap >>>>>>>").split(re/;/).klog(">>>>>> bootstrap in >>>>>>>");

	      options = {
	      	'name' :	'Oauth Developer ECI',
	      	'eci_type'	:	'CLIENT OAUTH'//, /*'OAUTH'*/
	      	//'attributes'	:	attributes,	
	      	//'policy'	:	policy
	      };
	      //creates new eci 
	      application_eci_result = (pci:new_eci(meta:eci(), options ) || {}).klog(">>>>>>>>>> eci results >>>>>>>>>>");

	      application_eci = application_eci_result{"cid"};

	      developer_secret = pci:create_developer_key().klog(">>>>>> developer secret >>>>>>>");
      	  //bs = bootstrapRids.map(function(rid) { pci:add_bootstrap(application_eci, rid) }).klog(">>>>>> bootstrap add result >>>>>>>");
	      
	      appData = (
	        ((appDataPassed
	        ).put(["appSecret"], developer_secret)
	        ).put(["appECI"], application_eci)
	      );

	      registery = (app:appRegistry || {}).put([application_eci], appData);
	      apps = (ent:apps || {}).put([application_eci], appData);

	    }
	   /* if (// redundant???
	      appData &&
	      appData{"appName"} &&
	      appData{"appImageURL"} &&
	      appData{"appCallbackURL"} &&
	      appData{"appDeclinedURL"}
	    )*/
	    if (application_eci_result.typeof() eq "hash" && // pci returns null on failure
	    	developer_secret neq ""	// check to see if you have secrets 
	    	) then{
	      pci:set_permissions(application_eci, developer_secret, ['oauth','access_token']);
	      pci:add_callback(application_eci, appCallbackURL);
	      addPCIbootstraps(application_eci,bootstrapRids);
	      // [FIXME, PJW] hack. a41x226/b507199x0 shouldn't be keeping this data, should be in PCI
    	  pci:add_appinfo(application_eci, 
    	    {"icon": appDataPassed{"appImageURL"},
      		"name": appDataPassed{"appName"},
         	"description": appDataPassed{"appDescription"},
         	"info_page": appDataPassed{"info_page"}
        	});
    	  //pci:add_client(application_eci, appData); <- this is not in pci yet........
	    }
	    fired {
	      log appCallbackURL;//???????????
	      set app:appRegistry registery;
	      set ent:apps apps;
	    }
	    else {
	    	log( " failure");
	    }
    }

    rule RemoveClient {//pci may not be working how I think.
	  	select when devtools remove_client
	  	pre {
	    	appECI = event:attr("appECI").defaultsTo("", ">> missing event attr channels >> ").klog(">>>>>> appECI >>>>>>>");
	    	registery = app:appRegistry;
	    	apps = ent:apps;
		}
	    if (registery{appECI} != {}) then {
	  		//undo all of pci pemissions
	    	pci:clear_permissions(appECI,get_secret(appECI), ['oauth','access_token']); // do I need to do anything else then clear_permissions??
	    	pci:remove_appinfo(appECI);
          	pci:remove_callback(appECI,pci:list_callback(appECI));
	    	//removePCIcallback(appECI,pci:list_callback(appECI));//not working
	    	removePCIbootstraps(appECI,pci:list_bootstrap(appECI));
        }
	  	fired { 
	  		set app:appRegistry registery.delete([appECI]).klog(">>>>>> app >>>>>>>");
	  		set ent:apps apps.delete([appECI]).klog(">>>>>> app >>>>>>>");
        }
    }
    rule UpdateClient {
	  select when devtools update_client
	    pre {
	    	app_Data={
	         	"info_page": event:attr("info_page"),
	         	"bootstrapRids": event:attr("bootstrapRids"),
	            "appName": event:attr("appName"),
	            "appDescription": event:attr("appDescription"),
	            "appImageURL": event:attr("appImageURL"),
	            "appCallbackURL": event:attr("appCallbackURL"),
	            "appDeclinedURL": event:attr("appDeclinedURL")
          	};
          appECI = event:attr("appECI").klog(">>>>>> appECI >>>>>>>");
	      oldApp = app:appRegistry{appECI}.klog(">>>>>> oldApp >>>>>>>");
	      appData = ( // keep app secrets for update
	        ((app_Data
	        ).put(["appSecret"], oldApp{"appSecret"})
	        ).put(["appECI"], oldApp{"appECI"})
	      );
	      bootstrapRids = appData{"bootstrapRids"}.split(re/;/).klog(">>>>>> bootstrap in >>>>>>>");
	      registery = (app:appRegistry || {}).put([appECI], appData);
	      apps = (ent:apps || {}).put([appECI], appData);
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
	        //remove all 
	    	//removePCIcallback(appECI,pci:list_callback(appECI)); //not working
          	pci:remove_callback(appECI,pci:list_callback(appECI));
          	pci:remove_appinfo(appECI);
	     	removePCIbootstraps(appECI,list_bootstrap(appECI));
          	// add new 
          	pci:add_callback(appECI, appData{"appCallbackURL"}); // update callback. should this be in pre block(it mutates).
	     	pci:add_appinfo(appECI, 
		        {"icon": appData{"appImageURL"},
		         "name": appData {"appName"},
		         "description": appData {"appDescription"},
		         "info_page": appData {"appInfoURL"}
		        });
	      	addPCIbootstraps(appECI,bootstrapRids);// hack.. is there a better way?
	    }
	    fired {
	      set app:appRegistry registery;
	      set ent:apps apps;
	    }
	}
	  rule ImportClientDataBase {// only call once before you create any clients.
	  select when devtools ImportClientDataBase
	 // foreach ent:apps setting (n,v)
		  pre {
		    	apps = OAuthRegistry:get_my_apps().klog(">>>>>> apps >>>>>>>");// does this get the secrets too?
		   // 	newapp = ent:apps;
		    //	newregistery = app:appRegistry;
		    //	apps = apps.keys().map(function(k,v) {v+2}); 
		    	//	{ newapp = newapp.put([eci],apps{eci}); newregistery = newregistery.put([eci],apps{eci}); });
          		registery = (app:appRegistry || {}).put(apps);
	      		apps = (ent:apps || {}).put(apps);

	          }
	          {
	          	noop();
	          }
		  always {
		  	set ent:apps apps;
		  	set app:appRegistry registery;
	        }
    }
/*    rule AddClient { // to local persistance...
	  select when explicit add
		  pre {
		  		app_Data={
	         	"info_page": event:attr("info_page"),
	         	"bootstrapRids": event:attr("bootstrapRids"),
	            "appName": event:attr("appName"),
	            "appDescription": event:attr("appDescription"),
	            "appImageURL": event:attr("appImageURL"),
	            "appCallbackURL": event:attr("appCallbackURL"),
	            "appDeclinedURL": event:attr("appDeclinedURL")
          			};
          		appECI = event:attr("appECI").klog(">>>>>> appECI >>>>>>>");

          		registery = (app:appRegistry || {}).put([appECI], appData);
	      		apps = (ent:apps || {}).put([appECI], appData);
	          }
	          if ( // valid input for update... is it checked one level down? do we need this check?
			      oldApp &&
			      appData &&
			      appData{"appName"} &&
			      appData{"appImageURL"} &&
			      appData{"appCallbackURL"} &&
			      appData{"appDeclinedURL"}
			    ) then{
	          	noop();
	          }
		  always {
		  	set ent:apps apps;
		  	set app:appRegistry registery;
	        }
    }*/
    	rule clear_registery {
	  select when devtools clear_registery
		  pre {

	          }
	          {
	          	noop();
	          }
		  always {
		  	clear ent:apps;
		  	clear app:appRegistry;
	        }
    }



    //TESTING NEW CODE WHICH IS FROM NANO MANAGER

    rule CreateScheduled {
	    select when nano_manager scheduled_created
	    pre {
	    //  eventtype = event:attr("eventtype").defaultsTo("wrong", standardError("missing event attr eventtype"));
	      //time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
	    //  do_main = event:attr("do_main").defaultsTo("wrong", standardError("missing event attr type"));
	      //timespec = event:attr("timespec").defaultsTo("{}", standardError("missing event attr timespec"));
	    //  date_time = event:attr("date_time").defaultsTo("wrong", standardError("missing event attr type"));
	    //  attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
	    //  attr = attributes.decode();



	    }
//	    log("create schedule running");
	    //if (type eq "single" && type neq "wrong" ) then
	    {
	      noop();
	    }
	    fired {
	      log(">> single >>");
	      //schedule do_main event eventype at date_time attributes attr ;
	      schedule notification event status at time:add(time:now(),{"seconds":30}) attributes event:attrs();
	          } 
	    else {
	      log(">> multiple >>");
	      //schedule do_main event eventype repeat timespec attributes attr ;
	      schedule notification event status at time:add(time:now(),{"seconds":30}) attributes event:attrs();
	    }
	  }  

}