
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
    // errors raised to unknown

    // Accounting keys
      //none
    provides Registered, Ruleset, Installed, Channels,Attributes, Policy, Clients,Picos,Schedules,History
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
    // notes
    // do not use ent:userToken !!!!!
    // || should be defaultsTo()
  //-------------------- Rulesets --------------------
    Registered = function() {
      eci = meta:eci();
        rulesets = rsm:list_rulesets(eci).defaultsTo({},standardError("undefined"));
        rulesetGallery = rulesets.map( function(rid){
          ridInfo = rsm:get_ruleset( rid ).defaultsTo({},standardError("undefined"));
          ridInfo
        }).defaultsTo("wrong",standardError("undefined"));
        {
          'status' : (rulesetGallery neq "wrong"),
          'rulesets' : rulesetGallery          
        };
    }
    Ruleset = function(rid) { 
      eci = meta:eci();
      results = Registered().defaultsTo({},standardError("undefined"));
      results = results{"rulesets"}.defaultsTo({},standardError("undefined"));
      result = results.filter( function(rule_set){rule_set{"rid"} eq rid } ).defaultsTo( "wrong",standardError("undefined"));
      {
        'status' : (result neq "wrong"),
        'ruleset' : result[0]
      };
    }
    Installed = function() {
      eci = meta:eci().klog(">> meta:eci results: >>");
      results = pci:list_ruleset(eci).defaultsTo("wrong",standardError("pci list_ruleset failed"));  // list of RIDs installed for userToken
      results;
   //   rids = results{'rids'}.defaultsTo([],standardError("no hash key rids"));
   //   {
   //    'status'   : (rids neq "wrong"),// is this valid krl? // do we need status
   //     'rids'     : rids
   //   };
    }
  //-------------------- Channels --------------------
    Channels = function() { 
      eci = meta:eci();
      results = pci:list_eci(eci).defaultsTo({},standardError("undefined")); // list of ECIs assigned to userid
      channels = results{'channels'}.defaultsTo("wrong",standardError("undefined")); // list of channels if list_eci request was valid
      {
        'status'   : (results neq "wrong"),
        'channels' : channels
      };
    }
    Attributes = function(eci) {
      results = pci:get_eci_attributes(eci).defaultsTo("wrong",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "wrong"),
        'Attributes' : results
      };
    }
    Policy = function(eci) {
      results = pci:get_eci_policy(eci).defaultsTo("wrong",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "wrong"),
        'Policy' : results
      };
    }
   /* Type = function(channel_id) { 
      channels = Channels().defaultsTo("wrong",">> undefined >>");

      GetType = function(channel_id,channels) {
    //    channels = channels{"channels"}.defaultsTo("undefined",standardError("undefined"));
    //    channel = channels.filter( function(channel){channel{"cid"} eq channel_id } ).defaultsTo( "wrong",standardError("undefined"));
    //    channel = channel[0];
    //    type = channel{"type"};
    //    temp = (type.typeof() eq "str" ) => type | type.typeof() eq "array" => type[0] |  type.keys();
    //    type = (temp.typeof() eq "array") => temp[0] | temp;   
        type;
      };
      GetType();
     // type = GetType(channel_id,channels);

      //type = ((channels neq "wrong") && (channels neq {} )) => getType() | "wrong";

      
      {
        'status'   : (type neq "wrong"),
        'channels' : channels
      }
    }*/
  //-------------------- Clients --------------------
    Clients = function() { 
      eci = meta:eci();
      clients = pci:get_authorized(eci).defaultsTo("wrong",standardError("undefined")); // pci does not have this function yet........
      //krl_struct = clients.decode() // I dont know if we needs decode
     // .klog(">>>>krl_struct")
     // ;
      {
        'status' : (clients != "wrong"),
        'clients' : krl_struct
      }
    }
  //-------------------- Picos ----------------------
    Picos = function() {
      picos = ent:my_picos.defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (picos != "wrong"),
        'picos'  : picos
      }
     }
  //-------------------- Subscriptions ----------------------
    /*Subscriptions = function(namespace, relationship) { 
      ent:subscriptions;
    }
    OutGoing = function() { 
      ent:pending_out_going;
    }
    Incoming = function() { 
      ent:pending_in_coming;
    }*/
  //-------------------- Scheduled ----------------------
    Schedules = function() { 
      sched_event_list = event:get_list().defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (sched_event_list != "wrong"),
        'schedules'  : sched_event_list
      }

    }
    History = function(id) { 
      sched_event_history = event:get_history(id).defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (sched_event_history != "wrong"),
        'history'  : sched_event_history
      }
    
    }
  
  //-------------------- error handling ----------------------


    standardError = function(message) {
      error = ">> error: " + message + " >>";
      error
    }

  }
  //defactions
  //Rules
  //-------------------- Rulesets --------------------
  rule RegisterRuleset {
    select when nano_manager ruleset_registered
    pre {
      rulesetURL= event:attr("rulesetURL").defaultsTo("", standardError("missing event attr rids"));
      //description = event:attr("description")defaultsTo("", ">>  >> ");
      //flush_code = event:attr("flush_code")defaultsTo("", ">>  >> ");
      //version = event:attr("version")defaultsTo("", ">>  >> ");
      //username = event:attr("username")defaultsTo("", ">>  >> ");
      //password = event:attr("password")defaultsTo("", ">>  >> ");
    }
    if( rulesetURL neq "" ) then// is this check redundent??
    {// do we nee to check for a url or is it done on a different level?? like if (rulesetURL != "")
      rsm:register(rulesetURL) setting (rid);// rid is empty? is it just created by default
       // (description != "") => description = description |  //ummm .....
       // flush_code = 
       // version = //alias ? 
       // username = //??
       // password = //??
    }
    fired {
      log ">>>> <<<<";
    }
    else{
      log""
    }
  }
  rule DeleteRuleset {
    select when nano_manager ruleset_deleted
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rids"));
    }
    //if(Ruleset(){"status"} != "null" ) then// is this check redundent??
    {
      rsm:delete(rid); 
    }
    fired {
      log ">>>> Deleted #{rid} <<<<";
    }
    else{
      log ">>>> #{rid} not found "; 
    }
  }
  rule FlushRulesets {
    select when nano_manager ruleset_flushed
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
    }
    if(rid.length() > 0 ) then // redundent??
    {
      rsm:flush(rid); 
    }
    fired {
      log ">>>> flushed #{rid} <<<<"
    }
    else {
      log ">>>> failed to flush #{rid} <<<<"

    } 
  }
  rule RelinkRuleset {
    select when nano_manager ruleset_relinked
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
      newURL = event:attr("url").defaultsTo("", standardError("missing event attr url")); 
    }
    if(rid neq "") then // redundent??
    {// do we nee to check for a url or is it done on a different level?? like if (rulesetURL != "") or should we check for the rid 
      rsm:update(rid) setting(updatedSuccessfully)
      with 
        uri = newURL;
        //description = 
        //flush_code = 
        //version = //alias ? 
        //username = //??
        //password = //??
    }
    fired {
      log ""
    }
    else{
      log ""
    }
  }  
  rule InstallRuleset {// should this handle multiple rulesets or a single one
    select when nano_manager ruleset_installed
    pre {
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    if(rids neq "") then { // should we be valid checking?
      pci:new_ruleset(eci, ridlist);
      send_directive("installed #{rids}");
    }
    fired {
      log(">> successfully installed rids #{rids} >>");
          } 
    else {
      log(">> could not install rids #{rids} >>");
    }
  }
  rule UninstallRuleset { // should this handle multiple uninstalls ??? 
    select when nano_manager ruleset_uninstalled
    pre {
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    { 
      pci:delete_ruleset(eci, ridlist);
      send_directive("uninstalled #{rids}");
    }
    fired {
      log(">> successfully uninstalled rids #{rids} >>");
          } 
    else {
      log(">> could not uninstall rids #{rids} >>");
    }
  }
 
 //-------------------- Channels --------------------

  rule UpdateChannelAttributes {
    select when nano_manager channel_attributes_updated
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
      attributes = event:attr("attributes").defaultsTo("", standardError("undefined"));
      channels = Channels();
    }
    if(channels{"channel_id"} && attributes != "") then { // check??redundent????
      pci:set_eci_attributes(channel_id, attributes);// attributes need to be an array, do we need to cast type?
      send_directive("updated #{channelID} attributes");
    }
    fired {
      log(">> successfully updated channel #{channel_id} attributes >>");
    } 
    else {
      log(">> could not update channel #{channel_id} attributes >>");
    }
  }

  rule UpdateChannelPolicy {
    select when nano_manager channel_policy_updated
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
      policy = event:attr("policy").defaultsTo("", standardError("undefined"));
      channels = Channels();
    }
    if(channels{"channelID"} && policy != "") then { // check??redundent??whats better??
      pci:set_eci_policy(channel_id, policy); // policy needs to be a map, do we need to cast types?
      send_directive("updated #{channel_id} policy");
    }
    fired {
      log(">> successfully updated channel #{channel_id} policy >>");
    }
    else {
      log(">> could not update channel #{channel_id} policy >>");
    }

  }
  rule DeleteChannel {
    select when nano_manager channel_deleted
    pre {
      channelID = event:attr("channelID").defaultsTo("", standardError("missing event attr channels"));
    }
    {
      pci:delete_eci(channelID);
      send_directive("deleted #{channelID}");
    }
    fired {
      log(">> successfully deleted channel #{channelID} >>");
          } else {
      log(">> could not delete channel #{channelID} >>");
          }
        }
  rule CreateChannel {
    select when nano_manager channel_created
    pre {
      channels = Channels().defaultsTo({}, standardError("list of installed channels undefined"));
      channelName = event:attr("channelName").defaultsTo("", standardError("missing event attr channels"));
      user = pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
      options = {
        'name' : channelName//,
        //'eci_type' : ,
        //'attributes' : ,
        //'policy' : ,
      };
          }
    if(channelName.match(re/\w[\w\d_-]*/) && user != "") then {
      pci:new_eci(user, options);
      send_directive("Created #{channelName}");
      //with status= true; // should we send directives??
          }
    fired {
      log(">> successfully created channels #{channelName} >>");
          } 
    else {
      log(">> could not create channels #{channelName} >>");
          }
    }
  
 /* //-------------------- Clients --------------------
  rule AuthorizeClient {
    select when nano_manager client_authorized


  }
  rule CRemovelient {
    select when nano_manager client_removed

  }
  rule UpdateClient {
    select when nano_manager client_updated

  }
  /*
  //-------------------- Picos ----------------------
  rule DeletePico {
    select when nano_manager pico_deleted

  }
  rule CreatePicoChild {
    select when nano_manager pico_created_child

  }
  rule DeletePicoChild {
    select when nano_manager pico_child_deleted

  }
  rule SetPicoAttributes { // assign vs set ??
    select when nano_manager pico_attributes_set

  }
  rule ClearPicoAttributes {// why ??
    select when nano_manager pico_attributes_cleared
    pre {
      picoChannel = event:attr("picoChannel");
    }
    {
      send_directive("picoAttrClear") with picoResults = "ok";
    }
    fired {
      clear ent:myPicos{picoChannel};
    }
  }
  rule SetPicoParent {
    select when nano_manager pico_parent_set

  }
  rule DeletePicoParent {
    select when nano_manager pico_parent_deleted

  }
  */
  //-------------------- Subscriptions ----------------------http://developer.kynetx.com/display/docs/Subscriptions+in+the+CloudOS+Service
   // ========================================================================
  // Persistent Variables:
  //
  // ent:subscriptions {
  //    "backChannel" : {
  //      "channelName"   : ,
  //      "namespace" : ,
  //      "relationship"   : ,
  //      "eventChannel"  : ,
  //      "backChannel"   : 
  //    }
  //  }
  //
  // ent:pending_out_going {
  //    "backChannel" : {
  //      "channelName"   : ,
  //      "namespace" : ,
  //      "relationship"   : ,
  //      "backChannel"   : 
  //    }
  //  }
  //
  // ent:pending_in_coming {
  //    "eventChannel" : {
  //      "channelName"  : ,
  //      "namespace"    : ,
  //      "relationship" : ,
  //      "eventChannel" : ,
  //      "subSummary"   : ,
  //      "profileName"  : ,
  //      "profilePhoto" : 
  //    }
  //  }
  //
  // ========================================================================
 /* rule SubscriptionRequest {// need to change varibles to snake case.
    select when nano_manager subscription_requested
   pre {
      channelName   = event:attr("channelName").defaultsTo("orphan", standardError(""));
      namespace     = event:attr("namespace").defaultsTo("shared", standardError(""));
      relationship  = event:attr("relationship").defaultsTo("peer-peer", standardError(""));
      targetChannel = event:attr("targetChannel").defaultsTo("NoTargetChannel", standardError(""));
      subSummary    = event:attr("subSummary").defaultsTo("", standardError(""));
      profileName   = event:attr("profileName").defaultsTo("Unknown", standardError(""));
      profilePhoto  = event:attr("profilePhoto").defaultsTo("", standardError(""));
      subAttrs      = event:attr("subAttrs").defaultsTo({}, standardError(""));

      // --------------------------------------------
      // extract roles of the relationship
      roles   = relationship.split(re/\-/);
      myRole  = roles[0];
      youRole = roles[1];
      
      subscription_map = {
            "cid" : targetChannel
      };

      options = {
        'name' : "#{namespace}:#{myRole}:#{channelName}"//,
        //'eci_type' : ,
        //'attributes' : ,
        //'policy' : ,
      }
      user = pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed"); 
      backChannel = pci:new_eci(user, options){"cid"}.defaultsTo("", standardError("pci session_token failed");  // cant find a way to move this out of pre and still capture backChannel
      // build pending subscription entry
      pendingEntry = {
        "channelName"  : channelName,
        "namespace"    : namespace,
        "relationship" : myRole,
        "backChannel"  : backChannel,
        "subAttrs"     : subAttrs.encode()
      }; 
    }
    if(targetChannel neq "NoTargetChannel" &&
     user neq "" &&
     backChannel neq "") 
    then
    {
      event:send(subscription_map, "system", "requestSubscription")
        with attrs = {
          "channelName"  : channelName,
          "namespace"    : namespace,
          "relationship" : relationship,
          "backChannel"  : backChannel,
          "subSummary"   : subSummary,
          "profileName"  : profileName,
          "profilePhoto" : profilePhoto,
          "subAttrs"     : subAttrs
        };
    }
    fired {
      log(">> successfull>>");
      set ent:pending_out_going{backChannel} pendingEntry;

    } 
    else {
      log(">> falure >>");
    }
  }
  rule ReceiveSubscriptionRequest {
    select when nano_manager subscription_request_recieved
    pre {
      channelName  = event:attr("channelName")   || "orphan";
      namespace    = event:attr("namespace")     || "shared";
      relationship = event:attr("relationship")  || "peer-peer";
      eventChannel = event:attr("backChannel")   || "NoEventChannel";
      subSummary   = event:attr("subSummary")    || "";
      profileName  = event:attr("profileName")   || "Unknown";
      profilePhoto = event:attr("profilePhoto")  || "";
      subAttrs     = event:attr("subAttrs")      || "";

      // --------------------------------------------
      // build pending pending approval entry

      pendingApprovalEntry = {
        "channelName"  : channelName,
        "namespace"    : namespace,
        "relationship" : relationship,
        "eventChannel" : eventChannel,
        "subSummary"   : subSummary,
        "profileName"  : profileName,
        "profilePhoto" : profilePhoto,
        "subAttrs"     : subAttrs
      };
    }
    {}
    fired {
      log(">> successfull>>");
      set ent:pending_in_coming pending_in_coming;
          } 
    else {
      log(">> falure >>");
    }
  }
  rule ApproveSubscriptionRequest {
    select when nano_manager subscription_request_approved
    pre{}
    {}
    fired {
      log(">> successfull>>");
      set ent:pending_in_coming pending_in_coming;
      set ent:subscriptions subscriptions;
          } 
    else {
      log(">> falure >>");
    }
  }
  rule RejectSubscriptionRequest {
    select when nano_manager subscription_request_rejected
    pre{}
    {}
    fired {
      log(">> successfull>>");
      set ent:pending_in_coming pending_in_coming;
          } 
    else {
      log(">> falure >>");
    }
  }
  rule ApproveSubscription {
    select when nano_manager subscription_approved
    pre{}
    {}
    fired {
      log(">> successfull>>");
      set ent:pending_out_going pending_out_going;
      set ent:subscriptions subscriptions;
          } 
    else {
      log(">> falure >>");
    }
  }
  rule RejectSubscription {
    select when nano_manager subscription_rejected
    pre{}
    {}
    fired {
      log(">> successfull>>");
      set ent:pending_out_going pending_out_going;
          } 
    else {
      log(">> falure >>");
    }
  }  
  *///-------------------- Scheduled ----------------------
  rule DeleteScheduled {
    select when nano_manager scheduled_deleted
    pre{
      sid = event:attr("sid").defaultsTo("", standardError("missing event attr sid"));
    }
    if (sid neq "") then
    {
      event:delete(sid);
    }
    fired {
      log(">> successfull>>");
          } 
    else {
      log(">> falure >>");
    }
  }  
  rule CreateScheduled {
    select when nano_manager scheduled_created
    pre{
      eventtype = event:attr("eventtype").defaultsTo("wrong", standardError("missing event attr eventtype"));
      time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
      do_main = event:attr("do_main").defaultsTo("wrong", standardError("missing event attr type"));
      timespec = event:attr("timespec").defaultsTo("{}", standardError("missing event attr timespec"));
      date_time = event:attr("date_time").defaultsTo("wrong", standardError("missing event attr type"));
      attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
      attr = attributes.decode();

    }
    if (type eq "single" && type neq "wrong" ) then
    {
      noop();
    }
    fired {
      log(">> single >>");
      schedule do_main event eventype at date_time attributes attr ;
          } 
    else {
      log(">> multiple >>");
      schedule do_main event eventype repeat timespec attributes attr ;
    }
  }  
}