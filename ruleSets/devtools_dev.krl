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
	            clients = NanoManager:apps().klog(standardOut("NanoManager:clients()"));
	            clients{'apps'};
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
	            token = event:attr("app_identifier").defaultsTo("", standardOut("missing event attr app_token").klog(">>>>>> app_token >>>>>>>"));
	        }
	        if (token != "") then {
	        	noop();
	        }
	        fired {
	            log( "success");
	            raise nano_manager event "remove_app_requested"
	            attributes event:attrs();
	        }
	        else {
	            log( "failure");
	        }
	    }

	    rule UpdateClient {
	      select when devtools update_client
	        pre {
	            app_Data={
	                "app_name": event:attr("app_name").defaultsTo("error", standardOut("missing event attr appName"))
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
      	rule ScheduleEvent {
	        select when devtools event_scheduled
	        pre {
	          event_type = event:attr("event_type").defaultsTo("wrong", standardError("missing event attr eventtype"));
	          time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
	        }
	        if( event_type neq "wrong" || time neq "wrong" ) then
	        {
	          noop();
	        }
	        fired {
	          log (standardOut("success"));
	            raise nano_manager event "schedule_event_requested"
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