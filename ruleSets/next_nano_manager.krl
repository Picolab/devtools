
// varibles 
// ent:my_picos


// operators are cammel case, variblse are snake case.


// questions
// when should we use klogs? what is the standard? varible getters|| mutators 
// is log our choice of status setting for rules ? when should we send directives. can we send directives in postlude with status varible?
// varible validating for removing , deleteing, uninstalling
// when registering a ruleset if you pass empty peramiters what happens

//old channel create uses a "login" eci to create a new channel, why and should we do it that way? 

//whats the benifit of forking a ruleset vs creating a new one?
//pci: lacks abillity to change channel type 

ruleset b507199x5 {
  meta {
    name "nano_manager"
    description <<
    Nano Manager ( ) Module

    use module a169x625 alias nano_manager

    This Ruleset/Module provides a developer interface to the PICO (persistent computer object).
    When a PICO is created or authenticated this ruleset
    will be installed into the Personal Cloud to provide an Event layer.
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials
    use module b507199x6 alias Channels
    use module b507199x7 alias Clients
    use module b507199x8 alias Picos
    use module b507199x9 alias Rulesets
    use module b507199x10 alias Schedules
    use module b507199x11 alias Subscriptions
    use module b16x29 alias Logs // https://raw.githubusercontent.com/Picolab/picologging/master/picologging.krl
    // errors raised to.... not implamented

    provides registered, singleRuleset, installed, describeRules, //ruleset
    channels, attributes, policy, type, //channel
    //clients, //client
    picos, accountProfile, //pico
    schedules, scheduleHistory, // schedule
    subscriptions, outGoing, incoming //subscription
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
    //}
  global {
    //functions
    //-------------------- Rulesets --------------------
    registered = Rulesets:registered();
    singleRuleset = Rulesets:singleRuleset(rid); 
    installed = Rulesets:installed();
    describeRules = Rulesets:describeRules(rids); //takes an array of rids as parameter // can we write this better???????
    //-------------------- Channels --------------------
    channels = Channels:channels(); 
    attributes = Channels:attributes(eci); 
    policy = Channels:policy(eci); 
    type = Channels:type(channel_id); // untested!!!!!!!!!!!!!!!!!!!
    //-------------------- Clients --------------------


    //-------------------- Picos --------------------
    //pico Logging 
    logs = Logs:getLogs();// untested
    status = Logs:loggingStatus();// untested

    children = Picos:children();
    parent = Picos:parent();
    attributes = Picos:attributes();
    picoFactory = Picos:picoFactory(myEci, protos); 
    //-------------------- Subscriptions ----------------------
    subscriptions = Subscriptions:subscriptions(); 
    outGoing = Subscriptions:outGoing(); 
    incoming = Subscriptions:incoming(); 
    //-------------------- Scheduled ----------------------
    schedules = Schedules:schedules(); 
    scheduleHistory = Schedules:scheduleHistory(id);
    //------------------------------- Utilities -------------------
    standardError = function(message) {
      error = ">> error: " + message + " >>";
      error
    }
    standardOut = function(message) {
      msg = ">> " + message + " results: >>";
      msg
    };
  }
  //Rules
  //-------------------- Rulesets --------------------
  rule RegisterRuleset {
    select when nano_manager ruleset_registered
    pre {
      rulesetURL= event:attr("rulesetURL").defaultsTo("", ">> missing event attr rulesetURL >> ");
    }
    if(rulesetURL neq "" ) then
    {
      noop();
    }
    fired {
      log (standardOut("Registering Success: #{rulesetURL}"));
      raise nano_rulesets event "ruleset_registered"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));

    }
  }
  rule DeleteRuleset {
    select when nano_manager ruleset_deleted
    pre {
      rid = event:attr("rid").defaultsTo("", ">> missing event attr rids >> ");
    }
    if(rid.length() > 0 ) then
    {
      noop();
    }
    fired {
      log (standardOut("delete Success: #{rid}"));
      raise nano_rulesets event "ruleset_deleted"
      attributes event:attrs();
    }
    else{
      log (standardOut("delete failure: #{rid}"));
    }

  }
  rule FlushRulesets {
    select when nano_manager ruleset_flushed
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
      raise nano_rulesets event "ruleset_flushed"
      attributes event:attrs();
    } 
    else {
      log (standardOut("failure"));
    }
  }
  rule RelinkRuleset {
    select when nano_manager ruleset_relinked
    pre {
      rulesetID = event:attr("rulesetID").defaultsTo("", ">> missing event attr rulesetID >> ");
      newURL = event:attr("appURL").defaultsTo("", ">> missing event attr appURL >> ");
      } if(rulesetID neq "" && newURL neq "") then
      {
       noop();
     }
     fired {
      log (standardOut("success"));
      raise nano_rulesets event "ruleset_relinked"
      with rid = rulesetID
      and url = newURL;
    }
    else{
      log (standardOut("update failure: #{rulesetID}"));
    }
  }  
  rule InstallRuleset {// should this handle multiple rulesets or a single one
    select when nano_manager ruleset_installed
    pre {
      rids = event:attr("rids").klog(">> rids attribute <<").defaultsTo("", ">> missing event attr rids >> ").klog(">> rids attribute <<");
    }
    if(rids neq "") then {
      noop();
    }
    fired {
      log (standardOut("successfully installed rids #{rids}"));
      raise nano_rulesets event "ruleset_installed"
      attributes event:attrs();
    } 
    else {
      log (standardOut("failure"));
    }
  }
  rule UninstallRuleset { // should this handle multiple uninstalls ??? 
    select when nano_manager ruleset_uninstalled
    pre {
      rids = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
    }
    if(rids neq "") then {
      noop();
    }
    fired {
      log(">> successfully uninstalled rids #{rids} >>");
      raise nano_rulesets event "ruleset_uninstalled"
      attributes event:attrs();
    } 
    else {
      log(">> could not uninstall rids #{rids} >>");
    }
  }

  //-------------------- Channels --------------------

  rule UpdateChannelAttributes {
    select when nano_manager channel_attributes_updated
    pre {
      channelID = event:attr("channel_id").defaultsTo("", ">> missing event attr channelID >> ");
    }
    if(channelID neq "") then {
      send_directive("updateing #{channelID} attrs");
    }
    fired {
      log(">> success, raiseing updated attrs channel #{channelID} event >>");
      raise nano_channels event "channel_attributes_updated"
      attributes event:attrs();
    } 
    else {
      log(">> could not update channel #{channelID} >>");
    }
  }

  rule UpdateChannelPolicy {
    select when nano_manager channel_policy_updated // channel_policy_update_requested
    pre {
      channelID = event:attr("channel_id").defaultsTo("", ">> missing event attr channelID >> ");
    }
    if(channelID neq "") then {
      send_directive("updateing #{channelID} policy");
    }
    fired {
      log(">> success, raiseing updated policy channel #{channelID} event >>");
      raise nano_channels event "channel_policy_updated"
      attributes event:attrs();
    } 
    else {
      log(">> could not update channel #{channelID} >>");
    }

  }
  rule DeleteChannel {
    select when nano_manager channel_deleted
    pre {
      channelID = event:attr("channel_id").defaultsTo("", ">> missing event attr channelID >> ");
    }
    if(channelID neq "") then {
      send_directive("deleteing #{channelID}");
    }
    fired {
      log(">> success, raising delete channel #{channelID} event >>");
      raise nano_channels event "channel_deleted"
      attributes event:attrs();
    } 
    else {
      log(">> could not delete channel #{channelID} >>");
    }
  }
  rule CreateChannel {
    select when nano_manager channel_created
    pre {
      channelName = event:attr("channelName").defaultsTo("", ">> missing event attr channels >> ");
    }
    if(channelName.match(re/\w[\w\d_-]*/)) then {
      send_directive("Created #{channelName}");
    }
    fired {
      log(">> successfully raised create channel #{channelName} event >>");
      raise nano_channels event "channel_created"
      attributes event:attrs();
    } 
    else {
      log(">> could not create channels #{channelName} >>");
    }
  }

  //-------------------- Clients --------------------

  //-------------------- Picos ----------------------


  //-------------------- Subscriptions ----------------------http://developer.kynetx.com/display/docs/Subscriptions+in+the+CloudOS+Service
  // ========================================================================
  // Persistent Variables:
  //
  // ent:subscriptions {
  //     backChannel : {
  //      "name" : 
  //      "eventChannel"  : ,
  //      "backChannel"{"attrs"} : [
  //                <namespace>,
  //                <relationship>,
  //                <attrs>:
  //       ],
  //    }
  //  }
  //
  // ent:pending_out_going {
  //     backChannel: {
  //      "name" : ,
  //      "namespace"   : ,
  //      "relationship"   : ,
  //      "backChannel"   : ,
  //      "Target" : , 
  //      "attrs"  :
  //    }
  //  }
  //
  // ent:pending_in_coming {
  //     eventChannel: {
  //      "name" : 
  //      "namespace"   : ,
  //      "relationship"   : ,
  //      "eventChannel"  : ,
  //      "attrs"  :
  //    }
  //  }
  //
  // ========================================================================
  rule addSubscriptionRequest {// need to change varibles to snake case.
    select when nano_manager subscribe
    pre {
      targetChannel = event:attr("targetChannel").defaultsTo("", ">> missing event attr targetChannel >> ");
    }
    if(targetChannel neq "" ) then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_subscriptions event "subscribe"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));
    }
  }

  rule ApproveInComeingRequest {
    select when nano_manager incoming_request_approved
    pre {
      eventChannel= event:attr("eventChannel").defaultsTo("", ">> missing event attr eventChannel >> ");
    }
    if(eventChannel neq "" ) then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_subscriptions event "incoming_request_approved"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));
    }
  }

  rule RejectIncomingRequest {
    select when nano_manager incoming_request_rejected
    pre {
      eventChannel= event:attr("eventChannel").defaultsTo("", ">> missing event attr eventChannel >> ");
    }
    if(eventChannel neq "" ) then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_subscriptions event "incoming_request_rejected"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));
    }
  }
  rule rejectOutGoingRequest {
    select when nano_manager out_going_request_rejected_by_origin
    pre{
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError(""));
    }
    if(backChannel neq "No backChannel") then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_subscriptions event "out_going_request_rejected_by_origin"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));
    }
  }

  rule INITUnSubscribe {
    select when nano_manager init_unsubscribed
    pre {
      eventChannel= event:attr("eventChannel").defaultsTo("", ">> missing event attr eventChannel >> ");
    }
    if(eventChannel neq "" ) then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_subscriptions event "init_unsubscribed"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));
    }
  } 
  // rule unsubscribed_all{} // check event from parent // for pico distruction.. 

  ///-------------------- Scheduled ----------------------
  rule DeleteScheduled {
    select when nano_manager scheduled_deleted
    pre{
      sid = event:attr("sid").defaultsTo("", standardError("missing event attr sid"));
    }
    if (sid neq "") then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_schedules event "scheduled_deleted"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));
    }
  }  
  rule CreateScheduled {
    select when nano_manager scheduled_created
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
      raise nano_schedules event "scheduled_created"
      attributes event:attrs();
    }
    else {
      log (standardOut("failure"));
    }
  }  
}