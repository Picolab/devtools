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

        use module a169x625 alias CloudOS
        use module a41x226 alias OAuthRegistry //(appManager)
        use module b507199x5 alias NanoManager 
        //use module a169x625 alias PicoInspector

        provides rulesetList, showRulesets, showInstalledRulesets, aboutPico,
         showScheduledEvents,showScheduleHistory,
         showInstalledChannels,
        showClients, showSubscriptions, showIncoming, showOutGoing
        sharing on
    }
    global {
        //------------------------------- Utilities -------------------
        standardOut = function(message) {
            msg = ">> " + message + " results: >>";
            msg
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
            clients = NanoManager:clients().klog(standardOut("NanoManager:Clients()"));
            clients{'clients'};
        };
        //------------------------------- <End oF> Authorize clients-------------------

        //------------------------------- Picos -------------------
        showPicos = function() {
            picos = NanoManager:picos().klog(standardOut("NanoManager:Picos()"));
            picos{'picos'};
        };
        aboutPico = function() { // not in cOSng yet
              account_profile = CloudOS:accountProfile()
                              .put( ["oauth_eci"], meta:eci() )
                      ;
          account_profile 
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
          subscriptions = NanoManager:incoming().klog(standardOut("NanoManager:Incoming()"));
          subscriptions{'subscriptions'};
        };
        showOutGoing = function() {
          subscriptions = NanoManager:outGoing().klog(standardOut("NanoManager:OutGoing()"));
          subscriptions{'subscriptions'};
        };
        // -------------------- <End oF> SUBSCRIPTIONS ---------------------- 

    }

        //------------------------------- Rulesets -------------------
    rule registerRuleset {
        select when devtools register_ruleset
        pre {
            rulesetURL= event:attr("rulesetURL").defaultsTo("", ">> missing event attr rulesetURL >> ");
        }
        if(rulesetURL neq "" ) then
        {
          noop();
        }
        fired {
          log (standardOut("Registering Success: #{rulesetURL}"));
            raise nano_manager event "ruleset_registered"
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
          log (standardOut("delete Success: #{rid}"));
          raise nano_manager event "ruleset_deleted"
              attributes event:attrs();
        }
        else{
          log (standardOut("delete failure: #{rid}"));
        }
        
    }

    
    rule updateRuleset {
        select when web submit "#formUpdateRuleset"
        pre {
            rulesetID = event:attr("rulesetID").defaultsTo("", ">> missing event attr rulesetID >> ");
            newURL = event:attr("appURL").defaultsTo("", ">> missing event attr appURL >> ");
        } if(rulesetID neq "" && newURL neq "") then
        {
           noop();
        }
        fired {
          log (standardOut("success"));
            raise nano_manager event "ruleset_relinked"
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
          raise nano_manager event "ruleset_flushed"
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
        raise nano_manager event "ruleset_installed"
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
        raise nano_manager event "ruleset_uninstalled"
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
            'name' :    'Oauth Developer ECI',
            'eci_type'  :   'CLIENT OAUTH'//, /*'OAUTH'*/
            //'attributes'  :   attributes, 
            //'policy'  :   policy
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
            developer_secret neq "" // check to see if you have secrets 
            ) 
        then{
          pci:set_permissions(application_eci, developer_secret, ['oauth','access_token']);
          pci:add_callback(application_eci, appCallbackURL);
          addPCIbootstraps(application_eci,bootstrapRids);
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
           //   newapp = ent:apps;
            //  newregistery = app:appRegistry;
            //  apps = apps.keys().map(function(k,v) {v+2}); 
                //  { newapp = newapp.put([eci],apps{eci}); newregistery = newregistery.put([eci],apps{eci}); });
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
            raise nano_manager event "subscribe"
              attributes event:attrs();
        }
        else {
          log (standardOut("failure"));
        }
    }
  rule ApproveInComeingRequest {
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
        pre {
            eventChannel= event:attr("eventChannel").defaultsTo("", ">> missing event attr eventChannel >> ");
        }
        if(eventChannel neq "" ) then
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
  rule INITUnSubscribe {
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
            raise nano_manager event "init_unsubscribed"
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
      //  eventtype = event:attr("eventtype").defaultsTo("wrong", standardError("missing event attr eventtype"));
        //time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
      //  do_main = event:attr("do_main").defaultsTo("wrong", standardError("missing event attr type"));
        //timespec = event:attr("timespec").defaultsTo("{}", standardError("missing event attr timespec"));
      //  date_time = event:attr("date_time").defaultsTo("wrong", standardError("missing event attr type"));
      //  attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
      //  attr = attributes.decode();



      }
//      log("create schedule running");
      //if (type eq "single" && type neq "wrong" ) then
      {
        noop();
      }
      fired {
        log(">> single >>");
        //schedule do_main event eventype at date_time attributes attr ;
        schedule notification event status at time:add(time:now(),{"seconds":120}) attributes event:attrs();
            } 
      else {
        log(">> multiple >>");
        //schedule do_main event eventype repeat timespec attributes attr ;
        schedule notification event status at time:add(time:now(),{"seconds":120}) attributes event:attrs();
      }
    }  

  //<!-- -------------------- <End oF> Scheduled ---------------------- -->

}