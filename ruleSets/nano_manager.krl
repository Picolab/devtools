
// varibles 
// ent:my_picos

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
      eci = meta:eci();
        rulesets = rsm:list_rulesets(eci).defaultsTo({},">> undefined >>");
        rulesetGallery = rulesets.map( function(rid){
          ridInfo = rsm:get_ruleset( rid ).defaultsTo({},">> undefined >>");
          ridInfo;
        });
       rulesetGallery
        {
          'status' : (),
          'rulesets' : rulesetGallery          
        }
    }
    Ruleset = function(rid) { 
      eci = meta:eci();
      results = Registered(eci){"rulesets"};
      results = results{rid}.defaultsTo( null,">> undefined >>");// is this dangerous in krl
      {
        'status' : (results ),
        'ruleset' : results
      }
    }
    Installed = function() {
      eci = meta:eci();
      results = pci:list_ruleset(eci).defaultsTo({},">> undefined >>");  // list of RIDs installed for userToken
      rids = results{'rids'} | {};
      {
       'status'   : (rids != {}),// is this valid krl? // do we need status
        'rids'     : rids
      }
    }
    Validate = function(rid) {
      eci = meta:eci();
      valid = rsm:is_valid(rid);
      {
        'status'  : valid
      }
    }
  //-------------------- Channels --------------------
    Channels = function() { 
      eci = meta:eci();
      results = pci:list_eci(eci).defaultsTo({},">> undefined >>"); // list of ECIs assigned to userid
      channels = results{'channels'}.defaultsTo({},">> undefined >>"); // list of channels if list_eci request was valid
      {
        'status'   : (results != {}),
        'channels' : channels
      }
    }
    Attributes = function() {
      {
        'status'   : (results != {}),
        'channels' : channels
      }
    }
    Policy = function() {
      {
        'status'   : (results != {}),
        'channels' : channels
      }
    }
    /*Type = function(channel_id) { // we dont need this yet.....
      channels = Channels().defaultsTo({},">> undefined >>");
      channel = Channels{channel_id}.defaultsTo("undefined",">> undefined >>");

      getType = function() {
        type = (channel{"type"}.typeof() eq ;

      }

      type = (channel != "undefined") => Type(Channel) | "";

      type = () =>
      
      {
        'status'   : (results != {}),
        'channels' : channels
      }
    }*/
  //-------------------- Clients --------------------
    Clients = function() { 
      eci = meta:eci();
      clients = pci:get_authorized(eci).defaultsTo({},">> undefined >>"); // pci does not have this function yet........
      krl_struct = clients.decode() // I dont know if we needs decode
      .klog(">>>>krl_struct")
      ;
      {
        'status' : (clients != {}),
        'clients' : krl_struct
      }
    }
  //-------------------- Picos ----------------------
    Picos = function() {
      picos = ent:my_picos.defaultsTo({},">> undefined >>");
      {
        'status' : (picos != {}),
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
      //description = event:attr("description")defaultsTo("", ">>  >> ");
      //flush_code = event:attr("flush_code")defaultsTo("", ">>  >> ");
      //version = event:attr("version")defaultsTo("", ">>  >> ");
      //username = event:attr("username")defaultsTo("", ">>  >> ");
      //password = event:attr("password")defaultsTo("", ">>  >> ");
    }
    if(Ruleset(){"status"} != "null" ) then// is this check redundent??
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
      rid = event:attr("rid").defaultsTo("", ">> missing event attr rid >> ");
    }
    if(rid.length() > 0 ) then // redundent??
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
    if(Validate(rid)) then // redundent??
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
  rule InstallRuleset {// should this handle multiple rulesets or a single one
    select when nano_manager ruleset_installed
    pre {
      eci = meta:eci().defaultsTo({},">> undefined >>");
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      rid = rids[0] //for validat
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    if(Validate(rid)) then { // can rsm take an array of rulesets ?? no.. need a better way.. should we be valid checking?
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
      eci = meta:eci().defaultsTo({},">> undefined >>");
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    { // can rsm take an array of rulesets ?? // redundent ?? 
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
      channel_id = event:attr("channel_id").defaultsTo("", ">> missing event attr channels >> ");
      attributes = event:attr("attributes").defaultsTo("", ">> >> ");
    }
    if(Channels(){"channel_id"} and attributes != "") then { // check??redundent????
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
      channel_id = event:attr("channel_id").defaultsTo("", ">> missing event attr channels >> ");
      policy = event:attr("policy").defaultsTo("", ">> >> ");
    }
    if(Channels(){"channelID"} and policy != "") then { // check??redundent??whats better??
      pci:set_eci_policy(channel_id, policy) // policy needs to be a map, do we need to cast types?
      send_directive("updated #{channel_id} policy");
    }
    fired {
      log(">> successfully updated channel #{channel_id} policy >>");
    }
    else {
      log(">> could not update channel #{channel_id} policy >>");
    }

  }
  rule UpdateChannel {
    select when nano_manager channel_updated
    select when devtools update_channel
    pre {
      channel_id = event:attr("channelID").defaultsTo("", ">> missing event attr channels >> ");

          }
    if(Channels(){"channelID"}) then { // check??redundent????
      attributes = pci:get_eci_attributes(channel_id).defaultsTo("", ">>  >> ");
      policy = pci:get_eci_policy(channel_id).defaultsTo("", ">>  >> ");
     
      send_directive("update #{channelID}");
          }
    fired {
      log(">> successfully updated channel #{channelID} >>");
          } else {
      log(">> could not update channel #{channelID} >>");
          }
  }
  rule DeleteChannel {
    select when nano_manager channel_deleted
    pre {
      channelID = event:attr("channelID").defaultsTo("", ">> missing event attr channels >> ");
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
  }
  rule Create Channel{
    select when nano_manager channel_created
    pre {
      channels = Channels().defaultsTo({}, ">> list of installed channels undefined >>");
      channelName = event:attr("channelName").defaultsTo("", ">> missing event attr channels >> ");
      user = pci:session_token(meta:eci()).defaultsTo("", ">> missing event attr channels >> "); // this is old way.. why not just eci??
      options = {
        'name' : channelName//,
        //'eci_type' : ,
        //'attributes' : ,
        //'policy' : ,
      }
          }
    // is this a valid if statement??
    if(channelName.match(re/\w[\w\d_-]*/) and user != "") then {
      pci:new_eci(user, options);
      send_directive("Created #{channelName}");
      //with status= true; // should we send directives??
          }
    fired {
      log(">> successfully created channels #{channelName} >>");
          } else {
      log(">> could not create channels #{channelName} >>");
          }
        }
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