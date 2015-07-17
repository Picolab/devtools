
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
    subscriptions, outgoing, incoming 
    sharing on

  }

  global {
    //functions
    subscriptions = function() { 
      subscriptions = ent:subscriptions.defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (subscriptions != "wrong"),
        'subscriptions'  : subscriptions
      }
    }
    outgoing = function() { 
      pending = ent:pending_outgoing.defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (pending != "wrong"),
        'subscriptions'  : pending
      }
    }
    incoming = function() { 
      pending = ent:pending_incoming.defaultsTo("wrong",standardError("undefined"));
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
  // new way, not implemented yet...
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
  // ent:pending_outgoing {
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
  // ent:pending_incoming {
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
      backChannel_b = backChannel{"cid"}.defaultsTo("", standardError("pci session_token failed"));  // can't find a way to move this out of pre and still capture backChannel
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
        log(">> successful>>");
        raise nano_manager event subscription_outgoing_pending;
        set ent:pending_outgoing{backChannel_b} pendingEntry;

      } 
      else {
        log(">> failure >>");
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
        log(">> successful>>");
        raise nano_manager event subscription_incoming_pending;
        set ent:pending_incoming{eventChannel} pendingApprovalEntry;
      } 
      else {
        log(">> failure >>");
      }
    }

    rule ApproveIncomingRequest {
      select when nano_manager incoming_request_approved
      pre{
        eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
        pendingsubscription = ent:pending_incoming{eventChannel};
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
        event:send(subscription_map, "nano_manager", "outgoing_request_approved") // send request
        with attrs = {
          "eventChannel"  : backChannel_b
        };
      }
      fired {
        log(">> successful>>");
        raise nano_manager event subscription_added;
        set ent:pending_incoming pending_incoming.delete([eventChannel]).klog("pending_incoming after delete");
        set ent:subscriptions new_subscriptions;
      } 
      else {
        log(">> failure >>");
      }
    }

    rule ApproveOutGoingRequest {
      select when nano_manager outgoing_request_approved
      pre{
        backChannel = meta:eci();
        eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
        pending_outgoing = ent:pending_outgoing{backChannel}.defaultsTo( "No pending", standardError(""));
        // build subscription entry
        subscription = ((pending_outgoing).put(["eventChannel"],eventChannel));
      }
      if (pending_outgoing neq "No pending") then 
      {
        noop();
      }
      fired {
        log(">> successful>>");
        raise nano_manager event subscription_added;
        set ent:pending_outgoing pending_outgoing.delete([backChannel]);
        set ent:subscriptions subscriptions.put([eventChannel],subscription);
      } 
      else {
        log(">> failure >>");
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
        event:send(subscription_map, "nano_manager", "outgoing_request_rejected") // send request
        with attrs = {
          "backChannel"  : eventChannel
        };
      }
      fired {
        log(">> successful>>");
        raise nano_manager event subscription_incoming_rejected;
        set ent:pending_incoming pending_incoming.delete([eventChannel]);
      } 
      else {
        log(">> failure >>");
      }
    }
    rule rejectOutgoingRequest {
      select when nano_manager outgoing_request_rejected_by_origin
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
        log(">> successful>>");
        raise nano_manager event subscription_outgoing_rejected;
        set ent:pending_outgoing pending_outgoing.delete([backChannel]);
      } 
      else {
        log(">> failure >>");
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
        log(">> successful>>");
        raise nano_manager event subscription_incoming_rejected;
        set ent:pending_incoming pending_incoming.delete([eventChannel]);
      } 
      else {
        log(">> failure >>");
      }
    }
    rule removeOutGoingRequest {
      select when system outgoing_request_rejected
      pre{
        backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError(""));
      }
      if(backChannel neq "No backChannel") then
      {
        noop();
      }
      fired {
        log(">> successful>>");
        raise nano_manager event subscription_outgoing_rejected;
        set ent:pending_outgoing pending_outgoing.delete([backChannel]);
      } 
      else {
        log(">> failure >>");
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
        log(">> successful>>");
        raise nano_manager event subscription_unsubscribed;
        set ent:subscriptions subscriptions.delete([eventChannel]);
      } 
      else {
        log(">> failure >>");
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
        log(">> successful>>");
      } 
      else {
        log(">> failure >>");
      }
    } 
    // unsubscribed all, check event from parent 

}