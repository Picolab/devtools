//b507199x0
//Flush the ruleset webpage: http://cs.kobj.net/ruleset/flush/b507199x0.prod;b507199x0.dev
ruleset devtools {
  meta {
    name "DevTools"
    description <<
      ruleset for DevTools developing website
    >>
        author "KRL-DevTools Developer"

        use module b16x24 alias system_credentials


        logging on

        use module a41x226 alias OAuthRegistry //(appManager)
        use module b507199x5 alias NanoManager 
        use module b507199x6 alias Account
        //use module a169x625 alias PicoInspector

        provides showRulesets,showRuleset, showInstalledRulesets, aboutPico, childPicos,
         showScheduledEvents,showScheduleHistory,schedules, scheduleHistory, // schedule
         showInstalledChannels,
        showClients, showClient,/*testing*/list_bootstrap, get_appinfo, list_callback, //apps
        showSubscriptions, showIncoming, showOutgoing 
        sharing on
    }
    global {
        //------------------------------- Utilities -------------------
	        standardOut = function(message) {
	            msg = ">> " + message + " results: >>";
	            msg
	        };
	        standardError = function(message) {
      			error = ">> error: " + message + " >>";
      			error
   		 	};
        //------------------------------- <End oF> Utilities -------------------

        //------------------------------- Rulesets -------------------
	        showRulesets = function(){
	            rulesets = registeredRulesets().klog(standardOut("NanoManager:Registered()"));
	            rulesets{'rulesets'};
	        };
	        showRuleset = function(rid){
	            rulesets = registeredRulesets(rid).klog(standardOut("NanoManager:Registered()"));
	            rulesets{'rulesets'};
	        };
			registeredRulesets = function(rid) { // move to devtools
		      eci = meta:eci();
		        rulesets = rsm:list_rulesets(eci).defaultsTo([],standardError("undefined"));
		        ruleset_gallery = rulesets.map( function(rid){
		          ridInfo = rsm:get_ruleset( rid ).defaultsTo({},standardError("undefined"));
		          ridInfo
		        }).defaultsTo("error",standardError("undefined"));
		        single = function(rulesets){
		          rulesets_array = rulesets.filter( function(rule_set){rule_set{"rid"} eq rid } );
		          rulesets_array[0];
		        };
		        result = (rid.isnull()) => ruleset_gallery | single(ruleset_gallery);
		        {
		          'status' : (ruleset_gallery neq "error"),
		          'rulesets' : result          
		        };
		    }
	        showInstalledRulesets = function() {
	            rulesets = NanoManager:installedRulesets().klog(standardOut("NanoManager:Installed()"));
	            rids = rulesets{'rids'};
	            description = NanoManager:describeRulesets(rids).klog(standardOut("NanoManager:DescribeRules()"));
	            description{'description'};
	        }; 
        //------------------------------- <End oF>  Rulesets -------------------

        //------------------------------- Channnels -------------------
	        showInstalledChannels = function() {
	            channels = NanoManager:channels().klog(standardOut("NanoManager:Channels()"));
	            channels;
	        };
        //------------------------------- <End oF>  Channnels -------------------

        //------------------------------- Authorize clients-------------------
	        showClients = function() {
	            clients = apps().klog(standardOut("NanoManager:clients()"));
	            clients{'apps'};
	        };
	        showClient = function(appECI){
	            clients = apps(appECI).klog(standardOut("NanoManager:clients()"));
	            clients{'app'};
          	};

		    apps = function(app_eci) { 
		      eci = meta:eci();
		      apps = pci:list_apps(eci); 
		      // check for parameter and return acordingly 
		      results = (app_eci.isnull()) => 
		          apps |
		          apps{app_eci};
		      {
		        'status' : (true),
		        'apps' : apps
		      }
		    }    
		    list_bootstrap = function(appECI){
		      pci:list_bootstrap(appECI);
		    }
		    get_appinfo = function(appECI){
		      pci:get_appinfo(appECI);
		    }
		    list_callback = function(appECI){
		      pci:list_callback(appECI);
		    }
		    addPCIbootstraps = defaction(appECI,bootstrapRids){
		      boot = bootstrapRids.map(function(rid) { pci:add_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap add result >>>>>>>");
		      send_directive("pci bootstraps updated.")
		        with rulesets = list_bootstrap(appECI); // is this working?
		    }
		    removePCIbootstraps = defaction(appEC,IbootstrapRids){
		      boot = bootstrapRids.map(function(rid) { pci:remove_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap removed result >>>>>>>");
		      send_directive("pci bootstraps removed.")
		        with rulesets = list_bootstrap(appECI); 
		    }
		    removePCIcallback = defaction(appECI,PCIcallbacks){
		      PCIcallbacks =( PCIcallbacks || []).append(PCIcallbacks);
		      boot = PCIcallbacks.map(function(url) { pci:remove_callback(appECI, url); }).klog(">>>>>> callback remove result >>>>>>>");
		      send_directive("pci callback removed.")
		        with rulesets = pci:list_callback(appECI);
		    }
		    update_app = defaction(app_eci,app_data,bootstrap_rids){
		      //remove all 
		      remove_defact = removePCIcallback(app_eci);
		      remove_appinfo = pci:remove_appinfo(app_eci);
		      remove_defact = removePCIbootstraps(app_eci);
		      // add new 
		      add_callback = pci:add_callback(app_eci, app_data{"appCallbackURL"}); 
		      add_info = pci:add_appinfo(app_eci,{
		        "icon": app_data{"appImageURL"},
		        "name": app_data{"appName"},
		        "description": app_data{"appDescription"},
		        "info_url": app_data{"info_page"},
		        "declined_url": app_data{"appDeclinedURL"}
		      });
		      addPCIbootstraps(app_eci,bootstrap_rids);
		    };
        //------------------------------- <End oF> Authorize clients-------------------

        //------------------------------- Picos -------------------
	        aboutPico = function() { // not in cOSng yet
	            account_profile = Account:accountProfile().klog(standardOut("Account:Picos()"));
	          account_profile {'profile'};
	        };
			
			childPicos = function() {
				children = NanoManager:children();
				children;
			};
        //------------------------------- <End of> Picos -------------------

        // -------------------- Scheduled ---------------------- 
	        showScheduledEvents = function() {
	          events = schedules().klog(standardOut("NanoManager:Schedules()"));
	          events{'schedules'};
	        };
	        showScheduleHistory = function(id) {
	          events = scheduleHistory(id).klog(standardOut("NanoManager:History()"));
	          events{'history'};
	        };
		    schedules = function() { 
		      sched_event_list = event:get_list().defaultsTo("error",standardError("undefined"));
		      {
		        'status' : (sched_event_list neq "error"),
		        'schedules'  : sched_event_list
		      }

		    }
		    scheduleHistory = function(id) { 
		      sched_event_history = event:get_history(id).defaultsTo("error",standardError("undefined"));
		      {
		        'status' : (sched_event_history neq "error"),
		        'history'  : sched_event_history
		      }
		    
		    }
        // -------------------- <End oF> Scheduled ---------------------- 

        // -------------------- SUBSCRIPTIONS ---------------------- 
	        showSubscriptions = function() {
	          subscriptions = NanoManager:subscriptions().klog(standardOut("NanoManager:subscriptions()"));
	          subscription = subscriptions{'subscriptions'};
	          subscription{'subscriptions'};
	        };
	        showIncoming = function() {
	          subscriptions = NanoManager:subscriptions().klog(standardOut("NanoManager:subscriptions()"));
	          pending = subscriptions{'subscriptions'};
	          incoming = pending{'pending_incoming'};
	          incoming;
	        };
	        showOutgoing = function() {
	          subscriptions = NanoManager:subscriptions().klog(standardOut("NanoManager:subscriptions()"));
	          pending = subscriptions{'subscriptions'};
	          out = pending{'pending_outgoing'};
	          out;
	        };
        // -------------------- <End oF> SUBSCRIPTIONS ---------------------- 

    }
	
	
	//------------------------------ Picos -----------------------------
		rule createPico {
			select when devtools createChild
			pre {
			}

			{
				noop();
			}
			
			fired {
				raise nano_manager event "child_creation_requested"
					attributes event:attrs();
			}
		}
	
	
	

    //------------------------------- Rulesets -------------------
	    rule devtoolsUpdateRuleset { // whats this for ????
	        select when web submit "#formUpdateRuleset" // is this current ?
	        pre {
	            rulesetID = event:attr("rid").defaultsTo("", ">> missing event attr rulesetID >> ");
	            newURL = event:attr("url").defaultsTo("", ">> missing event attr appURL >> ");
	        } if(rulesetID neq "" && newURL neq "") then
	        {
	           noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "ruleset_relink_requested"
	              with rid = rulesetID
	              and url = newURL;
	        }
	        else{
	          log (standardOut("update failure: #{rulesetID}"));
	        }
	    }

		rule registerRuleset {
	        select when devtools register_ruleset
		    pre {
		      ruleset_url= event:attr("ruleset_url").defaultsTo("", standardError("missing event attr rids"));
		      //description = event:attr("description")defaultsTo("", ">>  >> ");
		      //flush_code = event:attr("flush_code")defaultsTo("", ">>  >> ");
		      //version = event:attr("version")defaultsTo("", ">>  >> ");
		      //username = event:attr("username")defaultsTo("", ">>  >> ");
		      //password = event:attr("password")defaultsTo("", ">>  >> ");
		    }
		    if( ruleset_url neq "" ) then// is this check redundant??
		    {// do we need to check for a url or is it done on a different level?? like if (rulesetURL neq "")
		      rsm:register(ruleset_url) setting (rid);// rid is empty? is it just created by default
		       // (description neq "") => description = description |  //ummm .....
		       // flush_code = 
		       // version = //alias ? 
		       // username = //??
		       // password = //??
		    }
		    fired {
		      log (standardOut("success"));
		    }
		    else{
		      log""
		    }
		  }
		  rule deleteRuleset {
	        select when devtools delete_rid
		    pre {
		      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
		    }
		    //if(Ruleset(){"status"} neq "null" ) then// is this check redundant??
		    {
		      rsm:delete(rid); 
		    }
		    fired {
		      log (standardOut("success Deleted #{rid}"));
		      log ">>>>  <<<<";
		    }
		    else{
		      log ">>>> #{rid} not found "; 
		    }
		  }
		  rule flushRulesets {
	        select when devtools flush_rid
		    pre {
		      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
		    }
		    if(rid.length() > 0 ) then // redundant??
		    {
		      rsm:flush(rid); 
		    }
		    fired {
		      log (standardOut("success flushed #{rid}"));
		      log ">>>>  <<<<"
		    }
		    else {
		      log ">>>> failed to flush #{rid} <<<<"

		    } 
		  }
		  rule relinkRuleset {
		    select when nano_manager ruleset_relink_requested
		    pre {
		      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
		      new_url = event:attr("url").defaultsTo("", standardError("missing event attr url")); 
		    }
		    if(rid neq "") then // redundent??
		    {// do we nee to check for a url or is it done on a different level?? like if (rulesetURL != "") or should we check for the rid 
		      rsm:update(rid) setting(updatedSuccessfully)// we can change varible name?
		      with 
		        uri = new_url;
		        //description = 
		        //flush_code = 
		        //version = //alias ? 
		        //username = //??
		        //password = //??
		    }
		    fired {
		      log (standardOut("success"));
		      log ""
		    }
		    else{
		      log ""
		    }
		  }  
    // ---------- ruleset installation ----------
	    rule installRulesets {
	      select when devtools install_rulesets
	      pre {
	        rids = event:attr("rids").klog(">> rids attribute <<").defaultsTo("", ">> missing event attr rids >> ").klog(">> rids attribute <<");
	          }
	      if(rids neq "") then {
	        noop();
	          }
	      fired {
	        log (standardOut("successfully installed rids #{rids}"));
	        raise nano_manager event "install_rulesets_requested"
	              attributes event:attrs();
	      } 
	      else {
	        log (standardOut("failure"));
	      }
	        }

	    rule uninstallRulesets {
	      select when devtools uninstall_rulesets
	      pre {
	        rids = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
	          }
	      if(rids neq "") then {
	        noop();
	          }
	      fired {
	        log(">> successfully uninstalled rids #{rids} >>");
	        raise nano_manager event "uninstall_rulesets_requested"
	              attributes event:attrs();
	      } 
	      else {
	        log(">> could not uninstall rids #{rids} >>");
	      }
	    }

    //---------------- channel manager ---------------

	    rule CreateChannel {
	      select when devtools create_channel
	      pre {
	        channel_name = event:attr("channel_name").defaultsTo("", ">> missing event attr channels >> ");
	          }
	      if(channel_name.match(re/\w[\w\d_-]*/)) then {
	        send_directive("Created #{channel_name}");
	          }
	      fired {
	        log(">> successfully raised create channel #{channel_name} event >>");
	        raise nano_manager event "channel_creation_requested"
	              attributes event:attrs();
	      } 
	      else {
	        log(">> could not create channels #{channel_name} >>");
	      }
	    }

	    rule DestroyChannel {
	      select when devtools channel_destroy
	      pre {
	        channel_id = event:attr("channel_id").defaultsTo("", ">> missing event attr channelID >> ");
	          }
	      if(channel_id neq "") then {
	        send_directive("deleteing #{channel_id}");
	          }
	      fired {
	        log(">> success, raising delete channel #{channel_id} event >>");
	        raise nano_manager event "channel_deletion_requested"
	              attributes event:attrs();
	      } 
	      else {
	        log(">> could not delete channel #{channel_id} >>");
	      }
	    }
	    rule UpdateChannelAttributes {
	      select when devtools channel_attributes_updated
	      pre {
	        channelID = event:attr("channel_id").defaultsTo("", ">> missing event attr channelID >> ");
	          }
	      if(channelID neq "") then {
	        send_directive("updateing #{channelID} attrs");
	          }
	      fired {
	        log(">> success, raiseing updated channel attrs  #{channelID} event >>");
	        raise nano_manager event "update_channel_attributes_requested"
	              attributes event:attrs();
	      } 
	      else {
	        log(">> could not update channel #{channelID} >>");
	      }
	    }
	    rule UpdateChannelPolicy {
	      select when devtools channel_policy_updated
	      pre {
	        channelID = event:attr("channel_id").defaultsTo("", ">> missing event attr channelID >> ");
	          }
	      if(channelID neq "") then {
	        send_directive("updateing #{channelID} policy");
	          }
	      fired {
	        log(">> success, raiseing updated policy channel #{channelID} event >>");
	        raise nano_manager event "update_channel_policy_requested"
	              attributes event:attrs();
	      } 
	      else {
	        log(">> could not update channel #{channelID} >>");
	      }
	    }	

    //-------------------OAuthRegistry---------------

	    rule AuthorizeClient {
	        select when devtools authorize_client
	        pre {
	            appName = event:attr("app_name").defaultsTo("error", standardOut("missing event attr appName"));
	            appCallbackURL = event:attr("app_callback_url").defaultsTo("error", standardOut("missing event attr appCallbackURL"));
	            appCallBackUrl = appCallbackURL.split(re/;/).defaultsTo("error", standardOut("split callback failure"));
	        }
	        if (
	          appName neq "error" &&
	          appCallBackUrl neq "error"
	        ) 
	        then{
				noop();
	        }
	        fired {
	            log( "success");
	            raise nano_manager event "authorize_app_requested"
	              attributes event:attrs();
	        }
	        else {
	            log( "failure");
	        }
	    }

	    rule RemoveClient {
	        select when devtools remove_client
	        pre {
	            token = event:attr("app_id").defaultsTo("", standardOut("missing event attr app_id"));
	        }
	        if (token neq "") then {
	        	noop();
	        }
	        fired {
	            log( "success");
	            raise nano_manager event "remove_app_requested"
	            attributes event:attrs();
	        }
	        else {
	            log( "failure , #{token} not removed");
	        }
	    }

	    rule UpdateClient {
	      select when devtools update_client
	        pre {
	            app_Data={
	                "app_name": event:attr("app_name").defaultsTo("error", standardOut("missing event attr app_name"))
	            };

	        }
	        if ( 
	          appData{"app_name"} neq "error"
	        ) then{
	        	noop();
	        }
	        fired {
	            log("success");
	            raise nano_manager event "update_app_requested"
	            attributes event:attrs();
	        }
	        else {
	            log("failure");
	        }
	    }
	      //-------------------- Apps --------------------
	      rule authorizeApp {
	      	select when nano_manager authorize_app_requested
	      	pre {
	      		info_page = event:attr("info_page").defaultsTo("", standardOut("missing event attr info_page"));
	      		bootstrap_rids = event:attr("bootstrap_rids").defaultsTo("", standardOut("missing event attr bootstrap_rids"));
	      		app_name = event:attr("app_name").defaultsTo("error", standardOut("missing event attr app_name"));
	      		app_description = event:attr("app_description").defaultsTo("", standardOut("missing event attr app_description"));
	      		app_image_url = event:attr("app_image_url").defaultsTo("", standardOut("missing event attr app_image_url"));
	      		app_callback_url_attr = event:attr("app_callback_url").defaultsTo("error", standardOut("missing event attr app_callback_url"));
	      		app_callback_url = app_callback_url_attr.split(re/;/).defaultsTo("error", standardOut("split callback failure"));
	      		app_declined_url = event:attr("app_declined_url").defaultsTo("", standardOut("missing event attr app_declined_url"));
	      		bootstrap = bootstrap_rids.split(re/;/).defaultsTo("", standardOut("split bootstraps failure"));
	      		pico_id = meta:eci();
	      	}
	      	if (
	      		app_name neq "error" &&
	      		app_callback_url neq "error"
	      		) 
	      	then{
	      		pci:register_app(pico_id) setting(token, secret)
	      		with name = app_name and
	      		icon = app_image_url and
	      		description = app_description and
	      		info_url = info_page and
	      		declined_url = app_declined_url and
	      		callbacks = app_callback_url and 
	      		bootstrap = bootstrap;
	      	}
	      	fired {
	      		log (standardOut("success authenticated app #{app_name}"));
	      	}
	      	else {
	      		log( "failure");
	      	}
	      }

	      rule removeApp {
	      	select when nano_manager remove_app_requested
	      	pre {
	      		identifier = event:attr("app_id").defaultsTo("", standardOut("missing event attr app_id"));
	      	}
	      	if (identifier neq "") then {
	      		pci:delete_app(identifier);
	      	}
	      	fired {
	      		log (standardOut("success deauthenticated app with token #{identifier}"));
	      	}
	      	else {
	      		log( "failure");
	      	}
	      }

	      rule updateApp {
	      	select when nano_manager update_app_requested
	      	pre {
	      		app_data_attrs={
	      			"info_page": event:attr("info_page").defaultsTo("", standardOut("missing event attr info_page")),
	      			"bootstrap_rids": event:attr("bootstrap_rids").defaultsTo("", standardOut("missing event attr bootstrap_rids")),
	      			"app_name": event:attr("app_name").defaultsTo("", standardOut("missing event attr app_name")),
	      			"app_description": event:attr("app_description").defaultsTo("", standardOut("missing event attr app_description")),
	      			"app_image_url": event:attr("app_image_url").defaultsTo("", standardOut("missing event attr app_image_url")),
	      			"app_call_back_url": event:attr("app_call_back_url").defaultsTo("", standardOut("missing event attr app_call_back_url")),
	      			"app_declined_url": event:attr("app_declined_url").defaultsTo("", standardOut("missing event attr app_declined_url"))
	      		};
	      		identifier = event:attr("app_id").klog(">>>>>> token >>>>>>>");
	      		old_apps = pci:list_apps(meta:eci());
	      		old_app = old_apps{app_identifier}.defaultsTo("error", standardOut("oldApp not found")).klog(">>>>>> old_app >>>>>>>");
	      		app_data = (app_data_attrs)// keep app secrets for update// need to see what the real varibles are named........
	      		.put(["appSecret"], old_app{"appSecret"}.defaultsTo("error", standardOut("no secret found")))
	      		.put(["appECI"], old_app{"appECI"}) //------------------------------------------------/ whats this used for????????????
	      		;
	      		bootstrap_rids = app_data{"bootstrap_rids"}.split(re/;/).klog(">>>>>> bootstrap in >>>>>>>");
	      	}
	      	if ( 
	      		old_app neq "error" &&
	      		app_data{"app_name"} neq "error" &&
	      		app_data{"appSecret"} neq "error" &&
	      		app_data{"app_call_back_url"} neq "error" 
	      		) then{
	      		update_app(identifier,app_data,bootstrap_rids);
	      	}
	      	fired {
	      		log (standardOut("success update app with #{app_data}"));
	      	}
	      	else {
	      		log (standardOut("failure"));
	      	}
	      }
 	// <!-- -------------------- Subscription ---------------------- -->
	  rule addSubscriptionRequest {
	        select when devtools subscribe
	        pre {
	            target_channel = event:attr("target_channel").defaultsTo("", ">> missing event attr targetChannel >> ");
	        }
	        if(target_channel neq "" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "subscription_requested"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
	    }
	  rule ApproveIncomingRequest {
	        select when devtools incoming_request_approved
	        pre {
	            event_channel= event:attr("event_channel").defaultsTo("", ">> missing event attr eventChannel >> ");
	        }
	        if(event_channel neq "" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "approve_pending_subscription_requested"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
	    }
	  rule RejectIncomingRequest {
	        select when devtools incoming_request_rejected
	        or out_going_request_rejected
	        pre {
	        }
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "reject_incoming_subscription_requested"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
	    }
	  rule INITUnsubscribe {
	        select when devtools init_unsubscribed
	        pre {
	            event_channel= event:attr("event_channel").defaultsTo("", ">> missing event attr eventChannel >> ");
	        }
	        if(event_channel neq "" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "cancelSubscription"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
	    }

 	// <!-- --------------------<End oF> Subscription ---------------------- -->

 	// <!-- -------------------- Scheduled ---------------------- -->
      rule DeleteScheduledEvent {
	    select when nano_manager delete_scheduled_event_requested
	    pre{
	      sid = event:attr("sid").defaultsTo("", standardError("missing event attr sid"));
	    }
	    if (sid neq "") then
	    {
	      event:delete(sid);
	    }
	    fired {
	      log (standardOut("success"));
	          } 
	    else {
	      log(">> failure >>");
	    }
	  }  
	  rule ScheduleEvent {
	    select when devtools event_scheduled
	    pre{
	      event_type = event:attr("event_type").defaultsTo("error", standardError("missing event attr event_type"));
	      time = event:attr("time").defaultsTo("error", standardError("missing event attr type"));
	      do_main = event:attr("do_main").defaultsTo("error", standardError("missing event attr type"));
	      time_spec = event:attr("time_spec").defaultsTo("{}", standardError("missing event attr time_spec"));
	      date_time = event:attr("date_time").defaultsTo("error", standardError("missing event attr type"));
	      attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
	      attr = attributes.decode();

	    }
	    if (type eq "single" && type neq "error" ) then
	    {
	      noop();
	    }
	    fired {
	      log (standardOut("success single"));
	      schedule do_main event eventype at date_time attributes attr ;
	          } 
	    else {
	      log (standardOut("success multiple"));
	      schedule do_main event eventype repeat timespec attributes attr ;
	    }
	  }  
	    //TESTING NEW CODE WHICH IS FROM NANO MANAGER

	    rule CreateScheduled {
	      select when nano_manager scheduled_created
	      pre {
	      	event_type = event:attr("event_type").defaultsTo("wrong", standardError("missing event attr eventtype"));
	        //time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
	        do_main = event:attr("do_main").defaultsTo("wrong", standardError("missing event attr type"));
	        //timespec = event:attr("timespec").defaultsTo("{}", standardError("missing event attr timespec"));
	      //  date_time = event:attr("date_time").defaultsTo("wrong", standardError("missing event attr type"));
	        date_time = time:add(time:now(),{"seconds":120});
	        attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
	        attr = attributes.decode();
	      }
	//      log("create schedule running");
	      //if (type eq "single" && type neq "wrong" ) then
	      {
	        noop();
	      }
	      fired {
	        log(">> single >>");
	        //schedule do_main event eventype at date_time attributes attr ;
	        schedule do_main event event_type at date_time attributes event:attrs();
	        //schedule notification event status at time:add(time:now(),{"seconds":120}) attributes event:attrs();
	            } 
	      else {
	        log(">> multiple >>");
	        //schedule do_main event eventype repeat timespec attributes attr ;
	        schedule do_main event event_type at date_time attributes event:attrs();
	        //schedule notification event status at time:add(time:now(),{"seconds":120}) attributes event:attrs();
	      }
	    }  

  //<!-- -------------------- <End oF> Scheduled ---------------------- -->

}