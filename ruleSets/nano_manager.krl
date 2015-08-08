
// varibles 
// ent:my_picos
// ent:picos_attributes


// operators are camel case, variables are snake case.


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
    // errors raised to.... unknown

    // Accounting keys
      //none
    provides installedRulesets, describeRulesets, //ruleset
    channels, channelAttributes, channelPolicy, channelType, //channel
    children, parent, attributes, //pico
    subscriptions, outgoing, incoming, //subscription
    currentSession,standardError
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
	
	
  //-------------------- Rulesets --------------------
    installedRulesets = function() {
      eci = meta:eci().klog("eci: ");
      results = pci:list_ruleset(eci).klog("results of pci list_ruleset");//defaultsTo("error",standardError("pci list_ruleset failed"));  
      rids = results{'rids'}.defaultsTo("error",standardError("no hash key rids"));
      {
       'status'   : (rids neq "error"),
        'rids'     : rids
      };
    }
    describeRulesets = function(rids) {//takes an array of rids as parameter // can we write this better???????
      //check if its an array vs string, to make this more robust.
      rids_string = rids.join(";");
      describe_url = "https://#{meta:host()}/ruleset/describe/#{$rids_string}";
      resp = http:get(describe_url);
      results = resp{"content"}.decode().defaultsTo("",standardError("content failed to return"));
      {
       'status'   : (resp{"status_code"} eq "200"),
       'description'     : results
      };
    }
    installRulesets = defaction(eci, rids){
      new_ruleset = pci:new_ruleset(eci, rids);
      send_directive("installed #{rids}");
    }
    uninstallRulesets = defaction(eci, rids){
      deleted = pci:delete_ruleset(eci, rids);
      send_directive("uninstalled #{rids}");
    }
  //-------------------- Channels --------------------
    channels = function() { 
      eci = meta:eci();
      results = pci:list_eci(eci).defaultsTo({},standardError("undefined")); // list of ECIs assigned to userid
      channels = results{'channels'}.defaultsTo("error",standardError("undefined")); // list of channels if list_eci request was valid
      {
        'status'   : (channels neq "error"),
        'channels' : channels
      };
    }
    channelAttributes = function(eci) {
      results = pci:get_eci_attributes(eci).defaultsTo("error",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "error"),
        'Attributes' : results
      };
    }
    channelPolicy = function(eci) {
      results = pci:get_eci_policy(eci).defaultsTo("error",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "error"),
        'Policy' : results
      };
    }
    channelType = function(eci) { // put this as an issue in kre engine for pci function. old accounts may have different structure as there types, "type : types"
      my_channels = channels().defaultsTo("error",">> undefined >>");

      getType = function(eci,my_channels) { // change varible names
        channels = channels{"channels"}.defaultsTo("undefined",standardError("undefined"));
        channel = channels.filter( function(channel){channel{"cid"} eq eci } ).defaultsTo( "error",standardError("undefined"));
        chan = channel[0];
        type = chan{"type"};
        temp = (type.typeof() eq "str" ) => type | type.typeof() eq "array" => type[0] |  type.keys();
        type2 = (temp.typeof() eq "array") => temp[0] | temp;   
        type2;
      };
      type = ((my_channels{'status'}) && (channels neq {} )) => getType() | "error";
      {
        'status'   : (type neq "error"),
        'channels' : channels
      };
    }
    updateAttributes = defaction(eci, attributes){
      set_eci = pci:set_eci_attributes(eci, attributes);
      send_directive("updated channel attributes for #{eci}");
    }
    updatePolicy = defaction(eci, policy){
      set_polcy = pci:set_eci_policy(eci, policy); // policy needs to be a map, do we need to cast types?
      send_directive("updated channel policy for #{eci}");
    }
    deleteChannel = defaction(eci) {
      deleteeci =pci:delete_eci(eci);
      send_directive("deleted channel #{eci}");
    }
    createChannel = defaction(eci, options){
      new_eci = pci:new_eci(eci, options);
      send_directive("created channel #{new_eci}");
    }

  //-------------------- Picos --------------------
  currentSession = function() {
    pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
  };

	children = function() {
		eci = meta:eci();
		children = pci:list_children(eci).defaultsTo("error", standardError("pci children list failed"));
		{
			'status' : (children neq "error"),
			'children' : children
		}
	}
	parent = function() {
		eci = meta:eci();
		parent = pci:list_parent(eci).defaultsTo("error", standardError("pci parent retrival failed"));
		{
			'status' : (parent neq "error"),
			'parent' : parent
		}
	}
	attributes = function() {
		{
			'status' : true,
			'attributes' : ent:attributes.put( {'picoName' : ent:name} )
		}
	}
	
	
	prototypes = {
		"core": [
			"b507199x1.dev",
			"a169x625"
		]
	};
	picoFactory = function(myEci, protos) {
		newPicoInfo = pci:new_cloud(myEci);
		newPico = newPicoInfo{"cid"};
		a = pci:new_ruleset(newPico, prototypes{"core"});
		b = protos.map(function(x) {pci:new_ruleset(newPico, prototypes{x});});
		newPico;
	}

  //-------------------- Subscriptions ----------------------
    subscriptions = function() { 
      subscriptions = ent:subscriptions.defaultsTo("error",standardError("undefined"));
      {
        'status' : (subscriptions neq "error"),
        'subscriptions'  : subscriptions
      }
    }
    outgoing = function() { 
      pending = ent:pending_outgoing.defaultsTo("error",standardError("undefined"));
      {
        'status' : (pending neq "error"),
        'subscriptions'  : pending
      }
    }
    incoming = function() { 
      pending = ent:pending_incoming.defaultsTo("error",standardError("undefined"));
      {
        'status' : (pending neq "error"),
        'subscriptions'  : pending
      }
    }
    
    randomName = function(namespace,attempt){
        n = 5;
        array = (0).range(n).map(function(n){
          (random:word());
          });
        names= array.collect(function(name){
          (checkName(namespace +':'+ name)) => "unique" | "taken";
          });
        name = names{"unique"} || [];
        unique_name = name.head().defaultsTo("",standardError("unique name failed"));
        unique_name;
    }
    checkName = function(name){
      // use filter
      // check namespace as well
          channels = channels();
          channel = channels{'channels'}.defaultsTo("no Channel",standardOut("no channel found for channel name #{name}"));
          (channel eq "no Channel"); // if true channel is unique
    }//has to be a function, but breaks methodaligy 
    createBackChannel = function(name,type,attrs){ // should this be a function? we use this block of code a few times but its a mutator
        options = {
          'name' : name, 
          'eci_type' : type,
          'attributes' : attrs
          //'policy' : ,
        };
        user = currentSession();
        backChannel = pci:new_eci(user, options);
        backChannel_b = backChannel{"cid"}.defaultsTo("", standardError("pci session_token failed"));  // cant find a way to move this out of pre and still capture backChannel
        backChannel_b;
    }
    /*findVehicleByBackchannel = function (bc) {
       garbage = bc.klog(">>>> back channel <<<<<");
       vehicle_ecis = CloudOS:subscriptionList(common:namespace(),"Vehicle");
        vehicle_ecis_by_backchannel = vehicle_ecis
                                        .collect(function(x){x{"backChannel"}})
                                     .map(function(k,v){v.head()})
                                        ;
    vehicle_ecis_by_backchannel{bc} || {}
     };*/
  //-------------------- error handling ----------------------
    standardOut = function(message) {
      msg = ">> " + message + " results: >>";
      msg
    }

    standardError = function(message) {
      error = ">> error: " + message + " >>";
      error
    }
  }
  // string or array return array 
  // string or array return string


  //------------------------------------------------------------------------------------Rules
  //-------------------- Rulesets --------------------
  
  rule installRuleset {// should this handle multiple rulesets or a single one
    select when nano_manager install_rulesets_requested
    pre {
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      rid_list = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    if(rids neq "") then { // should we be valid checking?
      install(eci, rid_list);
    }
    fired {
      log (standardOut("success installed rids #{rids}"));
      log(">> successfully  >>");
          } 
    else {
      log(">> could not install rids #{rids} >>");
    }
  }
  rule uninstallRuleset { // should this handle multiple uninstalls ??? 
    select when nano_manager uninstall_rulesets_requested
    pre {
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      rid_list = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    { 
      uninstall(eci,rid_list);
    }
    fired {
      log (standardOut("success uninstalled rids #{rids}"));
      log(">> successfully  >>");
          } 
    else {
      log(">> could not uninstall rids #{rids} >>");
    }
  }
 
 //-------------------- Channels --------------------

  rule updateChannelAttributes {
    select when nano_manager update_channel_attributes_requested
    pre {
      eci = event:attr("eci").defaultsTo("", standardError("missing event attr channels"));
      attributes = event:attr("attributes").defaultsTo("error", standardError("undefined"));
      attrs = attributes.split(re/;/);
      //attrs = attributes.decode();
      channels = Channels();
    }
    if(channels{"eci"} neq "" && attributes neq "error") then { // check?? redundant????
      updateAttributes(eci,attributes);
    }
    fired {
      log (standardOut("success updated channel #{eci} attributes"));
      log(">> successfully >>");
    } 
    else {
      log(">> could not update channel #{eci} attributes >>");
    }
  }

  rule updateChannelPolicy {
    select when nano_manager update_channel_policy_requested // channel_policy_update_requested
    pre {
      eci = event:attr("eci").defaultsTo("", standardError("missing event attr channels"));
      policy = event:attr("policy").defaultsTo("error", standardError("undefined"));// policy needs to be a map, do we need to cast types?
      channels = Channels();
    }
    if(channels{"channelID"} neq "" && policy neq "error") then { // check?? redundant?? whats better??
      updatePolicy(eci, policy);
    }
    fired {
      log (standardOut("success updated channel #{eci} policy"));
      log(">> successfully  >>");
    }
    else {
      log(">> could not update channel #{eci} policy >>");
    }

  }
  rule deleteChannel {
    select when nano_manager channel_deletion_requested
    pre {
      eci = event:attr("eci").defaultsTo("", standardError("missing event attr channels"));
    }
    {
      deleteChannel(eci);
    }
    fired {
      log (standardOut("success deleted channel #{eci}"));
      log(">> successfully  >>");
          } else {
      log(">> could not delete channel #{eci} >>");
          }
        }
  rule createChannel {
    select when nano_manager channel_creation_requested
    pre {
      channel_name = event:attr("channel_name").defaultsTo("", standardError("missing event attr channels"));
      //type = event:attr("type").defaultsTo("", standardError("missing event attr type"));
      //attributes = event:attr("attributes").defaultsTo("", standardError("missing event attr attributes"));
      //attrs = attributes.decode();
      user = currentSession();
      //user = pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
      
      options = {
        'name' : channel_name//,
     //   'eci_type' : type,
      //  'attributes' : attrs//,
        //'policy' : ,
      };
          }
    if(channel_name.match(re/\w[\w\d_-]*/) && user neq "") then {
      createChannel(user, options);
          }
    fired {
      log (standardOut("success created channels #{channel_name}"));
      log(">> successfully  >>");
          } 
    else {
      log(">> could not create channels #{channel_name} >>");
          }
    }
  
  
  //-------------------- Picos ----------------------
	rule createChild {
		select when nano_manager child_creation_requested
		
		pre {
			myEci = meta:eci();
			
			newPico = picoFactory(myEci, []);
		}

		{
			noop();
		}
		
		fired {
			log(standardOut("pico created"));
		}
	}
	
	rule initializeChild {
		select when nano_manager child_created
		
		pre {
			parentInfo = event:attr("parent");
			name = event:attr("name");
			attrs = event:attr("attributes").decode();
		}
		
		{
			noop();
		}
		
		fired {
			set ent:parent parentInfo;
			set ent:children {};
			set ent:name name;
			set ent:attributes attrs;
		}
	}

	rule setPicoAttributes {
		select when nano_manager set_attributes_requested
		pre {
			newAttrs = event:attr("attributes").decode().defaultsTo("", standardError("no attributes passed"));
		}
		if(newAttrs neq "") then
		{
			noop();
		}
		fired {
			set ent:attributes newAttrs;
		}
		else {
			log "no attributes passed to set pico rule";
		}
	}
	
	rule clearPicoAttributes {
		select when nano_manager clear_attributes_requested
		pre {
		}
		{
			noop();
		}
		fired {
			clear ent:attributes;
		}
	}
	
	rule deleteChild {
		select when nano_manager child_deletion_requested
		pre {
			picoDeleted = event:attr("picoName").defaultsTo("", standardError("missing pico name for deletion"));
			eciDeleted = (picoDeleted neq "") => ent:children{picoDeleted} | "none";
		}
		if(picoDeleted neq "" || ent:children{picoDeleted}.isnull()) then
		{
			pci:delete_cloud(eciDeleted);
		}
		notfired {
			log "deletion failed because no child name was specified";
		}
	}

  //-------------------- Subscriptions ----------------------http://developer.kynetx.com/display/docs/Subscriptions+in+the+CloudOS+Service
   // ========================================================================
  // Persistent Variables:
  //
  // ent:subscriptions {
  //     backChannel : {
  //      type: 
  //       
  //       
  //       
  //       attrs: {
  //      "eventChannel"  : ,
  //      "backChannel"{"attrs"} : [
  //                <namespace>,
  //                <relationship>,
  //                <attrs>:
  //       ],
  //      }
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
  //      "backChannel"  :"" ,
  //      "attrs"  :
  //    }
  //  }
  //
  // ========================================================================
  rule requestSubscription {// need to change varibles to snake case.
    select when nano_manager subscription_requested
   pre {
      name   = event:attr("name").defaultsTo("standard", standardError("channel_name"));
      name_space     = event:attr("name_space").defaultsTo("shared", standardError("name_space"));
      relationship  = event:attr("relationship").defaultsTo("peer-peer", standardError("relationship"));
      target_channel = event:attr("target_channel").defaultsTo("no_target_channel", standardError("target_channel"));
      type      = event:attr("type").defaultsTo("", standardError("type"));

      // extract roles of the relationship
      roles   = relationship.split(re/\-/);
      my_role  = roles[0];
      your_role = roles[1];
      // destination for external event
      subscription_map = {
            "cid" : target_channel
      };
      unique_name = randomName(name_space);
       // build pending subscription entry
      pending_entry = {
        "name"  : name,
        "name_space"    : name_space,
        "relationship" : my_role,
        "target_channel"  : target_channel
      }.klog("pending subscription"); 
      //create call back for subscriber
      back_channel = createBackChannel(unique_name,name_space,pending_entry); // needs to be created here so we can send it in the event to other pico.
    }
    if(target_channel neq "no_target_channel" &&
     back_channel neq "") 
    then
    {
      event:send(subscription_map, "nano_manager", "add_pending_subscription_requested") // send request
        with attrs = {
          "name"  : name,
          "name_space"    : name_space,
          "relationship" : your_role,
          "event_channel"  : back_channel
        };
    }
    fired {
      log (standardOut("success"));
      log(">> successful >>");
      raise nano_manager event add_pending_subscription_requested
        with 
        name = name
        and channel_name = unique_name
        and name_space = name_space
        and relationship = my_role
        and back_channel = back_channel
        and event_channel = target_channel;
    } 
    else {
      log(">> failure >>");
    }
  }
  // can we put all this in a map and pass it as a attr? the rules internal.
  rule addPendingSubscription { // depends on wether or not a backChannel is being passed as an attribute
    select when nano_manager add_pending_subscription_requested
   pre {
      pending_entry = {
        "name"  : event:attr("name").defaultsTo("", standardError("")),
        "name_space"    : event:attr("name_space").defaultsTo("", standardError("name_space")),
        "channel_name" : event:attr("channel_name").defaultsTo("", standardError("channel_name")),
        "relationship" : event:attr("relationship").defaultsTo("", standardError("relationship")),
        "back_channel"  : event:attr("back_channel").defaultsTo("incoming", standardError("back_channel")),
        "event_channel"  : event:attr("event_channel").defaultsTo("", standardError("event_channel"))
      }.klog("pending subscription"); 
      
      back_channel = pending_entry{"back_channel"}.defaultsTo("", standardError("no back_channel"));
      event_channel = pending_entry{"event_channel"}.defaultsTo("", standardError("no event_channel"));
      unique_name = random_name(pending_entry{"name_space"});
      new_back_channel = createBackChannel(unique_name,name_space,pending_entry); 
    }
    if(back_channel eq "incoming") // no backChannel means its incoming
    then
    {
     noop();
    }
    fired { //can i put multiple lines in a single guard?????????????????
      log(">> successful pending incoming >>");
      raise nano_manager event subscription_incoming_pending;
      set ent:pending_incoming{event_channel} pending_entry;
      log(">> failure >>") if (event_channel eq "");
    } 
    else { 
      log (standardOut("success pending outgoing >>"));
      raise nano_manager event subscription_outgoing_pending;
      set ent:pending_outgoing{back_channel} pending_entry;
    }
  }

  
  rule approvePendingSubscription {
    select when nano_manager approve_pending_subscription_requested
    pre{
      event_channel = event:attr("event_channel").defaultsTo( "no_event_channel", standardError("event_channel"));
      pending_subscription = ent:pending_incoming{event_channel};
      
      back_channel = createBackChannel(pendingsubscription{'name'},
        pendingsubscription{'name_space'},
        {"name_space":name_space,"role" : pendingsubscription{'my_role'} });

      // create subscription for both picos
      my_subscription = ((pending_subscription).put(["backChannel"],back_channel)).klog("subscription"); /// needs standard output
      subscription = ((my_subscription).put(["backChannel"],my_subscription{"event_channel"})).klog(" subscription A"); /// needs standard output
      yourSubscription = ((subscription).put(["event_channel"],back_channel)).klog("Your subscription B"); /// needs standard output
      subscription_map = {
            "cid" : event_channel
      };
    }
    if (my_subscription{"back_channel"} neq "") then
    {
      event:send(subscription_map, "nano_manager", "remove_pending_subscription_requested"); 
      event:send(subscription_map, "nano_manager", "add_subscription_requested")
       with attrs = yourSubscription;
    }
    fired 
    {
      log (standardOut("success"));
      raise nano_manager event remove_pending_subscription_requested 
      with event_channel = event_channel;
      raise nano_manager event add_subscription_requested
      attributes my_subscription;
    } 
    else 
    {
      log(">> failure >>");
    }
  }
  rule addSubscription {
    select when nano_manager add_subscription_requested
    pre{
      subscription=
        {  "name"  : event:attr("name").defaultsTo( "Noname", standardError("")),
          "name_space"    : event:attr("namespace").defaultsTo( "no_namespace", standardError("")),
          "relationship" : event:attr("relationship").defaultsTo( "no_relationship", standardError("")),
          "event_channel" : event:attr("event_channel").defaultsTo( "no_event_channel", standardError("")),
          "back_channel" : event:attr("back_channel").defaultsTo( "no_back_channel", standardError(""))
        }
     
    }
    if (subscription{"back_channel"} neq "no_back_channel") then
    {
     noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_manager event subscription_added
      with backChannel = subscription{"back_channel"};
      set ent:subscriptions{subscription{"back_channel"}}  subscription;
          } 
    else {
      log(">> failure >>");
    }
  }
  rule removePendingSubscription{// ugly attempt to combine two rules.
    select when nano_manager remove_pending_subscription_requested
    pre{
      back_channel = meta:eci();
      event_channel = event:attr("event_channel").defaultsTo( "no_event_channel", standardError(""));
      path = (eventChannel eq "no_event_channel");
      pending = path =>
             ( ent:pending_outgoing{back_channel}.defaultsTo( "No pending outgoing", standardError("")) )
           | ( ent:pending_incoming{event_channel}.defaultsTo( "No pending incoming", standardError("")) );
    }
    if (path) then 
    {
      noop();
    }
    fired 
    {
      log (standardOut("success removing outgoing"));
      raise nano_manager event removed_pending_out;
      clear ent:pending_outgoing{back_channel};
    } 
    else 
    {// My function does not work.............. all the checks should be put into one place 
   //   removeIncoming = function(){
   //     log(">>successful removing incoming>>");
   //     raise nano_manager event removed_pending_in;
   //     clear ent:pending_incoming{eventChannel};
   //     ent:pending_out_incoming;
   //   };
    //  removeIncoming() if (pending_incoming neq "No pending incoming");
      log (standardOut("success removing incoming")) if (pending_incoming neq "No pending incoming");
      raise nano_manager event removed_pending_in if (pending_incoming neq "No pending incoming");
      clear ent:pending_incoming{event_channel} if (pending_incoming neq "No pending incoming");
      log(">> failure subscription request not found >>") if (pending_incoming eq "No pending incoming");
    }
  }
 rule rejectPendingSubscription {
    select when nano_manager reject_incoming_subscription_requested
           or   nano_manager cancel_outgoing_subscription_requested

    pre{
      event_channel = event:attr("event_channel").defaultsTo( "No Event Channel", standardError("event_channel"));
    }
    {
      event:send(subscription_map, "nano_manager", "remove_pending_subscription_requested")
        with attrs = event:attrs(); 
    }
    always // do we need to raise a rejected event for outsiders to see? i dont think so......
    {
      log (standardOut("success raising remove pending"));
      raise nano_manager event remove_pending_subscription_requested
        attributes event:attrs();
    } 
    else 
    {
      log(">> failure >>");
    }
  }
    rule removeSubscription {
    select when nano_manager remove_subscription_requested
    pre{
      back_channel = event:attr("back_channel").defaultsTo( "No back_channel", standardError("back_channel"));
    }
    if(back_channel neq "No back_channel") then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_manager event subscription_unsubscribed;
      // clean up
      raise nano_manager event channel_delete_requested with eci = back_channel;  
      clear ent:subscriptions{back_channel};
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule cancelSubscription {
    select when nano_manager cancel_subscription__requested
    pre{
      event_channel = event:attr("event_channel").defaultsTo( "No event_channel", standardError("event_channel"));
      back_channel = event:attr("back_channel").defaultsTo( "No back_channel", standardError("back_channel"));
      subscription_map = {
            "cid" : event_channel
      };
    }
    if(event_channel neq "No event_channel") then
    {
      event:send(subscription_map, "nano_manager", "remove_subscription_requested")
        with attrs = {
          "back_channel"  : event_channel
        };

    }
    fired {
      raise nano_manager event remove_subscription_requested with back_channel = back_channel; 
      log (standardOut("success"));
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule subscribeReset {// for testing purpose, will not be in production 
      select when nano_manager sub_scrip_tions_reset
      pre{
      }
      {
        noop();
      }
      always{
        clear ent:subscriptions;
        clear ent:pending_outgoing;
        clear ent:pending_incoming;
      }
    } 
// unsubscribed all, check event from parent 

}