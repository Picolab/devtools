
ruleset b507199x11 {
  meta {
    name "nano_subscriptions"
    description <<
      Nano Subscriptions
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials

    provides 
    subscriptions, outGoing, incoming 
    sharing on

  }

  global {
    //functions
    subscriptions = function(namespace, relationship) { 
      subscriptions = ent:subscriptions.defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (subscriptions != "wrong"),
        'subscriptions'  : subscriptions
      }
    }
    outGoing = function() { 
      pending = ent:pending_out_going.defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (pending != "wrong"),
        'subscriptions'  : pending
      }
    }
    incoming = function() { 
      pending = ent:pending_in_coming.defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (pending != "wrong"),
        'subscriptions'  : pending
      }
    }
  }
  //Rules
 

  //-------------------- Subscriptions ----------------------http://developer.kynetx.com/display/docs/Subscriptions+in+the+CloudOS+Service
   // ========================================================================
  // Persistent Variables:
  // new way, not implamented yet...
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
      name   = event:attr("channelName").defaultsTo("orphan", standardError(""));
      namespace     = event:attr("namespace").defaultsTo("shared", standardError(""));
      relationship  = event:attr("relationship").defaultsTo("peer-peer", standardError(""));
      targetChannel = event:attr("targetChannel").defaultsTo("NoTargetChannel", standardError(""));
      attrs      = event:attr("attrs").defaultsTo({}, standardError(""));

      // --------------------------------------------
      // extract roles of the relationship
      roles   = relationship.split(re/\-/);
      myRole  = roles[0];
      youRole = roles[1];
      
      subscription_map = {
            "cid" : targetChannel
      };

      options = {
        'name' : name,// generate name and check if its uniqe
        'eci_type' : namespace,
        'attributes' : {"namespace":namespace,
                          "role" : myRole }
        //'policy' : ,
      };

      user = currentSession();
      backChannel = pci:new_eci(user, options);
      backChannel_b = backChannel{"cid"}.defaultsTo("", standardError("pci session_token failed"));  // cant find a way to move this out of pre and still capture backChannel
      // build pending subscription entry
      pendingEntry = {
        "name"  : name,
        "namespace"    : namespace,
        "relationship" : myRole,
        "backChannel"  : backChannel_b,
        "targetChannel"  : targetChannel,
        "attrs"     : subAttrs.decode()
      }.klog("pending subscription"); 
    }
    if(targetChannel neq "NoTargetChannel" &&
     user neq "" &&
     backChannel_b neq "") 
    then
    {
      event:send(subscription_map, "nano_manager", "subscription_requested") // send request
        with attrs = {
          "name"  : name,
          "namespace"    : namespace,
          "relationship" : youRole,
          "eventChannel"  : backChannel_b,
          "attrs"     : attrs
        };
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_out_going_pending;
      set ent:pending_out_going{backChannel_b} pendingEntry;

    } 
    else {
      log(">> falure >>");
    }
  }

  rule subscriptionRequestPending {
    select when nano_manager subscription_requested
    pre {
      name  = event:attr("name").defaultsTo("orphan", standardError(""));
      namespace    = event:attr("namespace").defaultsTo("shared", standardError(""));
      relationship = event:attr("relationship").defaultsTo("peer-peer", standardError(""));
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      attrs     = event:attr("attrs").defaultsTo("", standardError(""));

      // --------------------------------------------
      // build pending pending approval entry

      pendingApprovalEntry = {
        "name"  : name,
        "namespace"    : namespace,
        "relationship" : relationship,
        "eventChannel" : eventChannel,
        "attrs"     : attrs
      };
    }
    if(eventChannel neq "NoEventChannel") then
    {
      noop();
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_in_coming_pending;
      set ent:pending_in_coming{eventChannel} pendingApprovalEntry;
          } 
    else {
      log(">> falure >>");
    }
  }

  rule ApproveInComeingRequest {
    select when nano_manager incoming_request_approved
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      pendingsubscription = ent:pending_in_coming{eventChannel};
      subscriptions = ent:subscriptions;
      options = {
        'name' : pendingsubscription{'name'},
        'eci_type' : pendingsubscription{'namespace'},
        'attributes' : {"namespace":namespace,
                          "role" : myRole }
        //'policy' : ,
      };

      user = currentSession();
      backChannel = pci:new_eci(user, options);
      backChannel_b = backChannel{"cid"}.defaultsTo("", standardError("pci new_eci failed")); 
      // build subscription entry
      subscription = ((pendingsubscription).put(["backChannel"],backChannel_b)).klog("subscription"); /// needs standard output
      new_subscriptions = subscriptions.put([backChannel_b],subscription);
      subscription_map = {
            "cid" : eventChannel
      };
    }
    if (subscription{"backChannel"} neq "") then
    {
      event:send(subscription_map, "nano_manager", "out_going_request_approved") // send request
        with attrs = {
          "eventChannel"  : backChannel_b
        };
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_added;
      set ent:pending_in_coming pending_in_coming.delete([eventChannel]).klog("pending_in_coming after delete");
      set ent:subscriptions new_subscriptions;
          } 
    else {
      log(">> falure >>");
    }
  }

  rule ApproveOutGoingRequest {
    select when nano_manager out_going_request_approved
    pre{
      backChannel = meta:eci();
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      pendingout_going = ent:pending_out_going{backChannel}.defaultsTo( "No pending", standardError(""));
      // build subscription entry
      subscription = ((pendingout_going).put(["eventChannel"],eventChannel));
    }
    if (pendingout_going neq "No pending") then 
    {
      noop();
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_added;
      set ent:pending_out_going pending_out_going.delete([backChannel]);
      set ent:subscriptions subscriptions.put([eventChannel],subscription);
          } 
    else {
      log(">> falure >>");
    }
  }
  rule RejectIncomingRequest {
    select when nano_manager incoming_request_rejected
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      subscription_map = {
        "cid" : eventChannel
      };
    }
    if(eventChannel neq "NoEventChannel") then
    {
      event:send(subscription_map, "nano_manager", "out_going_request_rejected") // send request
        with attrs = {
          "backChannel"  : eventChannel
        };
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_in_coming_rejected;
      set ent:pending_in_coming pending_in_coming.delete([eventChannel]);
    } 
    else {
      log(">> falure >>");
    }
  }
  rule rejectOutGoingRequest {
    select when nano_manager out_going_request_rejected_by_origin
    pre{
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError(""));
      targetChannel = event:attr("targetChannel").defaultsTo( "No targetChannel", standardError(""));
      subscription_map = {
        "cid" : targetChannel
      };
    }
    if(backChannel neq "No backChannel") then
    {
      event:send(subscription_map, "nano_manager", "incoming_request_rejected_by_origin") // send request
        with attrs = {
          "eventChannel"  : backChannel
        };
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_out_going_rejected;
      set ent:pending_out_going pending_out_going.delete([backChannel]);
    } 
    else {
      log(">> falure >>");
    }
  }
  rule removeIncomingRequest {
    select when system incoming_request_rejected_by_origin
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "No eventChannel", standardError(""));
    }
    if(eventChannel neq "No eventChannel") then
    {
      noop();
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_in_coming_rejected;
      set ent:pending_in_coming pending_in_coming.delete([eventChannel]);
          } 
    else {
      log(">> falure >>");
    }
  }
  rule removeOutGoingRequest {
    select when system out_going_request_rejected
    pre{
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError(""));
    }
    if(backChannel neq "No backChannel") then
    {
      noop();
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_out_going_rejected;
      set ent:pending_out_going pending_out_going.delete([backChannel]);
          } 
    else {
      log(">> falure >>");
    }
  } 
    rule UnSubscribe {
    select when nano_manager unsubscribed
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "No eventChannel", standardError(""));

    }
    if(eventChannel neq "No eventChannel") then
    {
      noop();
    }
    fired {
      log(">> successfull>>");
      raise nano_manager event subscription_unsubscribed;
      set ent:subscriptions subscriptions.delete([eventChannel]);
          } 
    else {
      log(">> falure >>");
    }
  } 
  rule INITUnSubscribe {
    select when nano_manager init_unsubscribed
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "No eventChannel", standardError(""));
      subscription_map = {
            "cid" : eventChannel
      };
    }
    if(eventChannel neq "No eventChannel") then
    {
      event:send(subscription_map, "nano_manager", "unsubscribed") // can we change system to something else ?// send request
        with attrs = {
          "eventChannel"  : eventChannel
        };

    }
    fired {
      raise nano_manager event unsubscribed with eventChannel = eventChannel; //????????????? may not work with this domain.........
      log(">> successfull>>");
          } 
    else {
      log(">> falure >>");
    }
  } 
// unsubscribed all, check event from parent 

}