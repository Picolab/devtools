
// varibles 
// ent:my_picos

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
    sharing on
    provides 

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
      eci = meta:eci().defaultsTo({},">> undefined >>");
        rulesets = rsm:list_rulesets(eci).defaultsTo({},">> undefined >>");
        rulesetGallery = rulesets.map( function(rid){
          ridInfo = rsm:get_ruleset( rid ).defaultsTo({},">> undefined >>");
          ridInfo;
        });
       rulesetGallery
        {
          'status' : ()
          'rulesets' : rulesetGallery          
        }
    }
    Ruleset = function(rid) { 
      eci = meta:eci().defaultsTo({},">> undefined >>");
      results = Registered(eci){"rulesets"};
      results = results{rid}.defaultsTo("null",">> undefined >>");
      {
        'status' : ()
        'ruleset' : results
      }
    }
    Installed = function() {
      eci = meta:eci().defaultsTo({},">> undefined >>");
      results = pci:list_ruleset(eci).defaultsTo({},">> undefined >>");  // list of RIDs installed for userToken
      rids = results{'rids'} | {};
      {
       'status'   : (rids != {}),// is this valid krl? // do we need status
        'rids'     : rids
      }
    }
  //-------------------- Channels --------------------
    Channels = function() { 
      eci = meta:eci().defaultsTo({},">> undefined >>");
      results = pci:list_eci(eci).defaultsTo({},">> undefined >>"); // list of ECIs assigned to userid
      channels = results{'channels'}.defaultsTo({},">> undefined >>"); // list of channels if list_eci request was valid
      {
        'status'   : (results),
        'channels' : channels
      }
    }
  //-------------------- Clients --------------------
    Clients = function() { 
      eci = meta:eci().defaultsTo({},">> undefined >>");
      clients = pci:get_authorized(eci).defaultsTo({},">> undefined >>"); // pci does not have this function yet........
      krl_struct = clients.decode() // I dont know if we needs decode
      .klog(">>>>krl_struct")
      ;
      {
        'status' : (clients)
        'clients' : krl_struct
      }
    }
  //-------------------- Picos ----------------------
    Picos = function() {
      picos = ent:my_picos.defaultsTo({},">> undefined >>");
      {
        'status' : (picos)
        'picos'  : picos
      }
     }
  //-------------------- Subscriptions ----------------------
    Subscriptions = function() { }
    OutGoing = function() { }
    Incoming = function() { }
  //-------------------- Scheduled ----------------------
    Scheduled = function() { }

  //defactions

  }
  //Rules
  //-------------------- Rulesets --------------------
  rule RegisterRuleset {
    select when nano_manager ruleset_registered
    pre {
      rulesetURL= event:attr("rulesetURL")defaultsTo("", ">> missing event attr rids >> ");
    }
    {// do we nee to check for a url or is it done on a different level?? like if (rulesetURL != "")
      rsm:register(rulesetURL) setting (rid);// rid is empty? is it just created by default
    }
    fired {
      log ">>>> <<<<";
      raise system event rulesetRegistered // do we need to raise an event ???
      with rulsetID = rid{"rid"} if(rid);
    }
    else{
      log""
    }
  }
  rule DeleteRuleset {
    select when nano_manager ruleset_deleted
    pre {
      rid = event:attr("rid").defaultsTo("", ">> missing event attr rids >> ");
    }
    if(Ruleset(){"ruleset"} != "null" ) then// is this check redundent??
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
      rid = event:attr("rid").defaultsTo("", ">> missing event attr rid >> ");
    }
    if(rid.length() > 0 ) then
    {
      rsm:flush(rid) 
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
      rid = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
      newURL = event:attr("url"); //should pull from the form on update url template
    }
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
      raise system event rulesetUpdated // why do we raise an event ?? 
      with rid = rid if(updatedSuccessfully);
    }
    else{
      log ""
    }
  }  
  rule ValidateRuleset {
    select when nano_manager ruleset_Validated
    pre{}
    {}
    fired{}
  }
  rule InstallRuleset {
    select when nano_manager ruleset_installed
    pre{}
    {}
    fired{}
  }
  rule UninstallRuleset {
    select when nano_manager ruleset_uninstalled
    pre{}
    {}
    fired{}
  }
  //-------------------- Channels --------------------

  rule UpdateChannel {
    select when nano_manager channel_updated
  }
  rule DeleteChannel {
    select when nano_manager channel_deleted
  }
  rule Create Channel{
    select when nano_manager channel_created
  }
  //-------------------- Clients --------------------
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
  //-------------------- Subscriptions ----------------------
  rule SubscriptionRequest {
    select when nano_manager subscription_requested
    pre{}
    {}
    fired{}
  }
  rule ReceiveSubscriptionRequest {
    select when nano_manager subscription_request_recieved
    pre{}
    {}
    fired{}
  }
  rule ApproveSubscriptionRequest {
    select when nano_manager subscription_request_approved
    pre{}
    {}
    fired{}
  }
  rule RejectSubscriptionRequest {
    select when nano_manager subscription_request_rejected
    pre{}
    {}
    fired{}
  }
  rule ApproveSubscription {
    select when nano_manager subscription_approved
    pre{}
    {}
    fired{}
  }
  rule RejectSubscription {
    select when nano_manager subscription_rejected
    pre{}
    {}
    fired{}
  }  
  //-------------------- Scheduled ----------------------
  rule DeleteScheduled {
    select when nano_manager scheduled_deleted
    pre{}
    {}
    fired{}
  }  
  rule CreateScheduled {
    select when nano_manager scheduled_created
    pre{}
    {}
    fired{}
  } */ 
}