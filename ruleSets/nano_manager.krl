


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

    	sharing on
    provides 


    author "BYU PICO Lab"
    logging off
    // errors raised to unknown

    // Accounting keys
      //none
  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
  //-------------------- Rulesets --------------------
    Registrations = function() { }
    Ruleset = function() { }
    Installed = function(eci) {
      userToken = eci || ent:userToken || "none";
      results = pci:list_ruleset(userToken);  // list of RIDs installed for userToken
      rids = results{'rids'};
      {
        'rids'     : rids,
        'status'   : rids.length() != 0
      }
    }
  //-------------------- Channels --------------------
    Channels = function() { }
  //-------------------- Clients --------------------
    Clients = function() { }
  //-------------------- Picos ----------------------
    Picos = function() { }
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
    select when nano_manager ruleset_register
    pre{}
    {}
    fired{}
  }
  rule DeleteRuleset {
    select when nano_manager ruleset_delete
    pre{}
    {}
    fired{}
  }
  rule FlushRulesets {
    select when nano_manager ruleset_flush
    pre{}
    {}
    fired{}
  }
  rule RelinkRuleset {
    select when nano_manager ruleset_relink
    pre{}
    {}
    fired{}
  }  
  rule ValidateRuleset {
    select when nano_manager ruleset_Validate
    pre{}
    {}
    fired{}
  }
  rule InstallRuleset {
    select when nano_manager ruleset_install
    pre{}
    {}
    fired{}
  }
  rule UninstallRuleset {
    select when nano_manager ruleset_uninstall
    pre{}
    {}
    fired{}
  }
  //-------------------- Channels --------------------

  rule UpdateChannel {
    select when nano_manager channel_update
  }
  rule DeleteChannel {
    select when nano_manager channel_update
  }
  rule Create Channel{
    select when nano_manager channel_update
  }
  //-------------------- Clients --------------------
  rule AuthorizeClient {
    select when nano_manager client_authorize

  }
  rule CRemovelient {
    select when nano_manager client_remove

  }
  rule UpdateClient {
    select when nano_manager client_update

  }
  //-------------------- Picos ----------------------
  rule DeletePico {
    select when nano_manager pico_delete

  }
  rule CreatePicoChild {
    select when nano_manager pico_create_child

  }
  rule DeletePicoChild {
    select when nano_manager pico_child_delete

  }
  rule SetPicoAttributes {
    select when nano_manager pico_set_attributes

  }
  rule ClearPicoAttributes {// why ??
    select when nano_manager pico_clear_attributes

  }
  rule SetPicoParent {
    select when nano_manager pico_set_parent

  }
  rule DeletePicoParent {
    select when nano_manager pico_parent_delete

  }
  //-------------------- Subscriptions ----------------------
  rule SubscriptionRequest {
    select when nano_manager subscription_request
    pre{}
    {}
    fired{}
  }
  rule ReceivedSubscriptionRequest {
    select when nano_manager subscription_request_recieved
    pre{}
    {}
    fired{}
  }
  rule ApprovedSubscriptionRequest {
    select when nano_manager subscription_request_approved
    pre{}
    {}
    fired{}
  }
  rule RejectedSubscriptionRequest {
    select when nano_manager subscription_request_rejected
    pre{}
    {}
    fired{}
  }
  rule ApproveSubscription {
    select when nano_manager subscription_approve
    pre{}
    {}
    fired{}
  }
  rule RejectSubscription {
    select when nano_manager subscription_reject
    pre{}
    {}
    fired{}
  }  
  //-------------------- Scheduled ----------------------
  rule DeleteScheduled {
    select when nano_manager scheduled_delete
    pre{}
    {}
    fired{}
  }  
  rule CreateScheduled {
    select when nano_manager scheduled_delete
    pre{}
    {}
    fired{}
  }  
}