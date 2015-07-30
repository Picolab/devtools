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
        //use module a169x625 alias PicoInspector

        provides rulesetList, showRulesets, showInstalledRulesets, aboutPico,
         showScheduledEvents,showScheduleHistory,
         showInstalledChannels,
        showClients, Clients, get_app,list_bootstrap, get_appinfo, list_callback,
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
	            rulesets = NanoManager:registered().klog(standardOut("NanoManager:Registered()"));
	            rulesets{'rulesets'};
	        };
	        showInstalledRulesets = function() {
	            rulesets = NanoManager:installed().klog(standardOut("NanoManager:Installed()"));
	            rids = rulesets{'rids'};
	            description = NanoManager:describeRules(rids).klog(standardOut("NanoManager:DescribeRules()"));
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
	            clients = NanoManager:clients().klog(standardOut("NanoManager:clients()"));
	            clients{'clients'};
	        };
	        get_app = function(appECI){
	            clients = NanoManager:get_app().klog(standardOut("NanoManager:clients()"));
	            clients{'app'};
          	};
        //------------------------------- <End oF> Authorize clients-------------------

        //------------------------------- Picos -------------------
	        aboutPico = function() { // not in cOSng yet
	            account_profile = NanoManager:accountProfile().klog(standardOut("NanoManager:Picos()"));
	          account_profile {'profile'};
	        };
        //------------------------------- <End of> Picos -------------------

        // -------------------- Scheduled ---------------------- 
	        showScheduledEvents = function() {
	          events = NanoManager:schedules().klog(standardOut("NanoManager:Schedules()"));
	          events{'schedules'};
	        };
	        showScheduleHistory = function(id) {
	          events = NanoManager:scheduleHistory(id).klog(standardOut("NanoManager:History()"));
	          events{'history'};
	        };
        // -------------------- <End oF> Scheduled ---------------------- 

        // -------------------- SUBSCRIPTIONS ---------------------- 
	        showSubscriptions = function() {
	          subscriptions = NanoManager:subscriptions().klog(standardOut("NanoManager:Subscriptions()"));
	          subscriptions{'subscriptions'};
	        };
	        showIncoming = function() {
	          subscriptions = NanoManager:incoming().klog(standardOut("NanoManager:incoming()"));
	          subscriptions{'subscriptions'};
	        };
	        showOutgoing = function() {
	          subscriptions = NanoManager:outGoing().klog(standardOut("NanoManager:Outgoing()"));
	          subscriptions{'subscriptions'};
	        };
        // -------------------- <End oF> SUBSCRIPTIONS ---------------------- 

    }

    //------------------------------- Rulesets -------------------
	    rule registerRuleset {
	        select when devtools register_ruleset
	        pre {
	            ruleset_url= event:attr("ruleset_url").defaultsTo("", ">> missing event attr rulesetURL >> ");
	        }
	        if(ruleset_url neq "" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("Registering Success: #{ruleset_url}"));
	            raise nano_manager event "ruleset_registration_requested"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));

	        }
	    }
	    rule deleteRulesets {
	        select when devtools delete_rid//subm form-update-url
	        pre {
	            rid = event:attr("rid").defaultsTo("", ">> missing event attr rids >> ");
	        }
	        if(rid.length() > 0 ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("Success raising delete #{rid} event"));
	          raise nano_manager event "ruleset_deletion_requested"
	              attributes event:attrs();
	        }
	        else{
	          log (standardOut("delete failure: #{rid}"));
	        }
	        
	    }

	    
	    rule updateRuleset { // whats this for ????
	        select when web submit "#formUpdateRuleset" // is this current ?
	        pre {
	            rulesetID = event:attr("rulesetID").defaultsTo("", ">> missing event attr rulesetID >> ");
	            newURL = event:attr("appURL").defaultsTo("", ">> missing event attr appURL >> ");
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

	    rule flushRuleset {
	        select when devtools flush_rid
	        pre {
	            rid = event:attr("rid").defaultsTo("", ">> missing event attr rid >> ");
	        }
	        if(rid.length() > 0 ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	          log (">>>> flushed #{rid} <<<<");
	          raise nano_manager event "ruleset_flush_requested"
	              attributes event:attrs();
	        } 
	        else {
	          log (standardOut("failure"));
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
	        channelName = event:attr("channelName").defaultsTo("", ">> missing event attr channels >> ");
	          }
	      if(channelName.match(re/\w[\w\d_-]*/)) then {
	        send_directive("Created #{channelName}");
	          }
	      fired {
	        log(">> successfully raised create channel #{channelName} event >>");
	        raise nano_manager event "channel_created"
	              attributes event:attrs();
	      } 
	      else {
	        log(">> could not create channels #{channelName} >>");
	      }
	    }

	    rule DestroyChannel {
	      select when devtools channel_destroy
	      pre {
	        channelID = event:attr("channel_id").defaultsTo("", ">> missing event attr channelID >> ");
	          }
	      if(channelID neq "") then {
	        send_directive("deleteing #{channelID}");
	          }
	      fired {
	        log(">> success, raising delete channel #{channelID} event >>");
	        raise nano_manager event "channel_deleted"
	              attributes event:attrs();
	      } 
	      else {
	        log(">> could not delete channel #{channelID} >>");
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
	        log(">> success, raiseing updated attrs channel #{channelID} event >>");
	        raise nano_manager event "channel_attributes_updated"
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
	        raise nano_manager event "channel_policy_updated"
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
	            info_page = event:attr("info_page").defaultsTo("", standardOut("missing event attr info_page"));
	            bootstrapRids = event:attr("bootstrapRids").defaultsTo("", standardOut("missing event attr bootstrapRids"));
	            appName = event:attr("appName").defaultsTo("error", standardOut("missing event attr appName"));
	            appDescription = event:attr("appDescription").defaultsTo("", standardOut("missing event attr appDescription"));
	            appImageURL = event:attr("appImageURL").defaultsTo("", standardOut("missing event attr appImageURL"));
	            appCallbackURL = event:attr("appCallbackURL").defaultsTo("error", standardOut("missing event attr appCallbackURL"));
	            appCallBackUrl = appCallbackURL.split(re/;/).defaultsTo("error", standardOut("split callback failure"));
	            appDeclinedURL = event:attr("appDeclinedURL").defaultsTo("", standardOut("missing event attr appDeclinedURL"));
	            bootstrap = bootstrapRids.split(re/;/).defaultsTo("", standardOut("split bootstraps failure"));
	            picoId = meta:eci();
	        }
	        if (
	          appName neq "error" &&
	          appCallBackUrl neq "error"
	        ) 
	        then{
	        	pci:register_app(picoId) setting(token, secret)
   				with name = appName and
        			icon = appImageURL and
        			description = appDescription and
        			info_url = info_page and
        			declined_url = appDeclinedURL and
        			callbacks = appCallBackUrl and 
        			bootstrap = bootstrap;
	        }
	        fired {
	            log( "success");
	        }
	        else {
	            log( "failure");
	        }
	    }

	    rule RemoveClient {
	        select when devtools remove_client
	        pre {
	            token = event:attr("appECI").defaultsTo("", standardOut("missing event attr appECI").klog(">>>>>> appECI >>>>>>>"));
	        }
	        if (token != "") then {
	        	pci:delete_app(token);
	        }
	        fired {
	            log( "success");
	        }
	        else {
	            log( "failure");
	        }
	    }

	    rule UpdateClient {
	      select when devtools update_client
	        pre {
	            app_Data={
	                "info_page": event:attr("info_page").defaultsTo("", standardOut("missing event attr info_page")),
	                "bootstrapRids": event:attr("bootstrapRids").defaultsTo("", standardOut("missing event attr bootstrapRids")),
	                "appName": event:attr("appName").defaultsTo("", standardOut("missing event attr appName")),
	                "appDescription": event:attr("appDescription").defaultsTo("", standardOut("missing event attr appDescription")),
	                "appImageURL": event:attr("appImageURL").defaultsTo("", standardOut("missing event attr appImageURL")),
	                "appCallbackURL": event:attr("appCallbackURL").defaultsTo("", standardOut("missing event attr appCallbackURL")),
	                "appDeclinedURL": event:attr("appDeclinedURL").defaultsTo("", standardOut("missing event attr appDeclinedURL"))
	            };
	          token = event:attr("appECI").klog(">>>>>> token >>>>>>>");
	         // oldApp = pci:list_apps(meta:eci()){token}.defaultsTo("error", standardOut("oldApp not found")).klog(">>>>>> oldApp >>>>>>>");
	          appData = (app_Data)// keep app secrets for update
	            		.put(["appSecret"], oldApp{"appSecret"}.defaultsTo("error", standardOut("no secret found")))
	            		.put(["appECI"], oldApp{"appECI"}) //------------------------------------------------/ whats this used for????????????
	          			;
	          bootstrapRids = appData{"bootstrapRids"}.split(re/;/).klog(">>>>>> bootstrap in >>>>>>>");
	        }
	        if ( 
	          oldApp neq "error" &&
	          appData{"appName"} neq "error" &&
	          appData{"appSecret"} neq "error" &&
	          appData{"appCallbackURL"} neq "error" 
	        ) then{
				update_app(appECI,appData,bootstrapRids);
	        }
	        fired {
	            log("success");
	        }
	        else {
	            log("failure");
	        }
	    }
	      rule ImportClientDataBase {// only call once before you create any clients.
	      select when devtools ImportClientDataBase
	          pre {
	                apps = OAuthRegistry:get_my_apps().klog(">>>>>> apps >>>>>>>");
	                token = meta:eci();
	              	value = apps.values().klog("apps values: ");
	              }
	              {
	              	noop();
	              	//apps.map(function(apptoken,appData) { 
	              //		pci:register_app(token) setting(token, secret)
				//		   with name = "Oauth App 2" and
				//		        icon = "http://example.com/default.png" and
				//		        description = "Second Oauth App for Testing" and
				//		        info_url = "http://example.com/info" and
				//		        declined_url = "http://example.com/declined" and
				//		        callbacks = ["http://example.com/callbacks"] and
				//		        bootstrap = ["b16x876.prod"]})
	              }
	        fired {
	            log("success");
	        }
	        else {
	            log("failure");
	        }
	    }
 
 	// <!-- -------------------- Subscription ---------------------- -->
	  rule addSubscriptionRequest {
	        select when devtools subscribe
	        pre {
	            targetChannel = event:attr("targetChannel").defaultsTo("", ">> missing event attr targetChannel >> ");
	        }
	        if(targetChannel neq "" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "request_subscrition"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
	    }
	  rule ApproveIncomingRequest {
	        select when devtools incoming_request_approved
	        pre {
	            eventChannel= event:attr("eventChannel").defaultsTo("", ">> missing event attr eventChannel >> ");
	        }
	        if(eventChannel neq "" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "incoming_request_approved"
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
	            raise nano_manager event "incoming_request_rejected"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
	    }
	  rule INITUnsubscribe {
	        select when devtools init_unsubscribed
	        pre {
	            eventChannel= event:attr("eventChannel").defaultsTo("", ">> missing event attr eventChannel >> ");
	        }
	        if(eventChannel neq "" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "unsubscribed"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
	    }

 	// <!-- --------------------<End oF> Subscription ---------------------- -->

 	// <!-- -------------------- Scheduled ---------------------- -->
      	rule ScheduleEvent {
	        select when devtools event_scheduled
	        pre {
	          eventtype = event:attr("eventtype").defaultsTo("wrong", standardError("missing event attr eventtype"));
	          time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
	        }
	        if( eventtype neq "wrong" || time neq "wrong" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "scheduled_created"
	              attributes event:attrs();
	        }
	        else {
	          log (standardOut("failure"));
	        }
    	}	

	    //TESTING NEW CODE WHICH IS FROM NANO MANAGER

	    rule CreateScheduled {
	      select when nano_manager scheduled_created
	      pre {
	      	eventtype = event:attr("eventtype").defaultsTo("wrong", standardError("missing event attr eventtype"));
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
	        schedule do_main event eventtype at date_time attributes event:attrs();
	        //schedule notification event status at time:add(time:now(),{"seconds":120}) attributes event:attrs();
	            } 
	      else {
	        log(">> multiple >>");
	        //schedule do_main event eventype repeat timespec attributes attr ;
	        schedule do_main event eventtype at date_time attributes event:attrs();
	        //schedule notification event status at time:add(time:now(),{"seconds":120}) attributes event:attrs();
	      }
	    }  

  //<!-- -------------------- <End oF> Scheduled ---------------------- -->

}