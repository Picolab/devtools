
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

      use module  b507199x5 alias nano_manager

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
    subscriptions, channelByName, channelByEci, subscriptionsAttributesEci, subscriptionsAttributesName, //subscription
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
      rids_string = ( rids.typeof() eq "array" ) => rids.join(";") | ( rids.typeof() eq "str" ) => rids | "" ;
      describe_url = "https://#{meta:host()}/ruleset/describe/#{$rids_string}";
      resp = http:get(describe_url);
      results = resp{"content"}.decode().defaultsTo("",standardError("content failed to return"));
      {
       'status'   : (resp{"status_code"} eq "200"),
       'description'     : results
      };
    }
 /*  installedRulesetsDiscription = function(){ // for develpers ??
      rulesets = installedRulesets();
      rids = rulesets{"rids"};
      description = describeRulesets(rids);
      {
       'status'   : (description{'status'}),
       'descriptions'     : description{'description'}
      };
    }*/
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
      type = ((my_channels{"status"}) && (channels neq {} )) => getType() | "error";
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
    //pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
    meta:eci();
  };

	children = function() {
		self = meta:eci();
		children = pci:list_children(self).defaultsTo("error", standardError("pci children list failed"));
		{
			'status' : (children neq "error"),
			'children' : children
		}
	}
	parent = function() {
		self = meta:eci();
		parent = pci:list_parent(self).defaultsTo("error", standardError("pci parent retrival failed"));
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
    subscriptions = function() { // slow, whats a better way to prevent channel call, bigO(n^2)
      subscriptions = ent:subscriptions.defaultsTo("error",standardError("undefined"));
      status = function(name){
        attributes = subscriptionsAttributesName(name).klog("attributes: ");
        (attributes{"status"});
      };
      subscription = subscriptions.collect(function(name){
        (status(name));
      });
   //   pending =  subscription.collect(function(name){
  //      (subscriptionsAttributesName(name){"status"} eq "pending_incoming") => "pending_incoming"| "pending_outgoing";
  //      });
  //    subscriptions = subscription.put(['pending_subcriptions'],pending); // will this over write ...
      {
        'status' : (subscriptions neq "error"),
        'subscriptions'  : subscription
      }
    }

    randomName = function(namespace){
        n = 5;
        array = (0).range(n).map(function(n){
          (random:word());
          });
        names= array.collect(function(name){
          (checkName( namespace +':'+ name )) => "unique" | "taken";
        });
        name = names{"unique"} || [];

        unique_name =  name.head().defaultsTo("",standardError("unique name failed"));
        (namespace +':'+ unique_name);
    }
    checkName = function(name){
          chan = channels();
          //channels = channels(); worse bug evver!!!!!!!!!!!!!!!!!!!!!!!!!!!
          // in our meetings we said to check name_space, how is that done?
          /*{
          "last_active": 1426286486,
          "name": "Oauth Developer ECI",
          "type": "OAUTH",
          "cid": "158E6E0C-C9D2-11E4-A556-4DDC87B7806A",
          "attributes": null}
          */
          chs = chan{"channels"}.defaultsTo("no Channel",standardOut("no channel found"));
          //chan{'channels'} bug????????????
          names = chs.none(function(channel){channel{"name"} eq name});
          (names);

    }
    subscriptionsAttributesName = function (channel_name){
      channel = channelByName(channel_name);
      eci = channel{'cid'};
      attributes = channelAttributes(eci);
      attributes{'Attributes'};
    } 
    subscriptionsAttributesEci = function (eci){
      channel = getChannelByEci(eci);
      eci = channel{'cid'};
      attributes = channelAttributes(eci);
      attributes{'Attributes'};
    }
    channelEciByName = function (name) {
      my_channels = channels();
      chs = my_channels{"channels"}.defaultsTo("no Channel",standardOut("no channel found, by channels"));
      filtered_channels = chs.filter(function(channel){
        (channel{'name'} eq name);});
      channel = filtered_channels.head().defaultsTo("",standardError("no channel found, by head"));
      channel{'cid'};
    }
    //I can join these two functions if I can tell the differents between a name and eci....
    channelByName = function (name){
      my_channels = channels();
      chs = my_channels{"channels"}.defaultsTo("no Channel",standardOut("no channel found, by channels"));
      filtered_channels = chs.filter(function(channel){
        (channel{'name'} eq name);});
      filtered_channels.head().defaultsTo("",standardError("no channel found, by head"));
    }
    channelByEci = function (eci) {
      my_channels = channels();
      chs = my_channels{"channels"}.defaultsTo("no Channel",standardOut("no channel found"));
      filtered_channels = chs.filter(function(channel){
        (channel{'cid'} eq eci);});
      filtered_channels.head().defaultsTo("",standardError("no channel found"));
    }
      nameFromEci = function(){ // not used
        eci = meta:eci();
        channel = channelByEci(back_channel_eci);
        channel{'name'};
      } 

      eciFromName = function(name){
        channel = channelByName;
        channel{'cid'};
      }
    /*findVehicleByBackchannel = function (bc) {
       garbage = bc.klog(">>>> back channel <<<<<");
       vehicle_ecis = nano_manager:subscriptionList(common:namespace(),"Vehicle");
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
      installRulesets(eci, rid_list);
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
      uninstallRulesets(eci,rid_list);
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
      eci = event:attr("eci").defaultsTo("", standardError("missing event attr eci"));
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

  //-------------------- Subscriptions ----------------------http://developer.kynetx.com/display/docs/Subscriptions+in+the+nano_manager+Service
   // ========================================================================
  // Persistent Variables:
  //
  // ent:subscriptions = [ uniqe_channel_name,uniqe_channel_name2,..]
  //
  //
  //{
  //     backChannel : {
  //      type: 
  //      name: 
  //       
  //       
  //       attrs: {
  //      ""
  //      (Subscription) "name"  : ,
  //      "name_space": ,
  //       "relationship" : ,
  //        "target_channel"/"event_channel" : ,
  //        "status": 
  //       ],
  //      }
  //    }
  //  }
  //
   // ========================================================================
   // creates back_channel and sends event for other pico to create back_channel.
  rule requestSubscription {// need to change varibles to snake case.
    select when nano_manager subscription_requested
   pre {
      // attributes for back_channel attrs
      name   = event:attr("name").defaultsTo("standard", standardError("channel_name"));
      name_space     = event:attr("name_space").defaultsTo("shared", standardError("name_space"));
      relationship  = event:attr("relationship").defaultsTo("peer-peer", standardError("relationship"));
      target_channel = event:attr("target_channel").defaultsTo("no_target_channel", standardError("target_channel"));
      channel_type      = event:attr("channel_type").defaultsTo("subs", standardError("type"));
      
      // extract roles of the relationship
      roles   = relationship.split(re/\-/);
      my_role  = roles[0];
      your_role = roles[1];
     // // destination for external event
      subscription_map = {
            "cid" : target_channel
      };
      // create unique_name for channel
      unique_name = randomName(name_space).klog(standardOut("v2.16   unique_name: "));

      // build pending subscription entry

      pending_entry = {
        "subscription_name"  : name,
        "name_space"    : name_space,
        "relationship" : my_role,
        "target_channel"  : target_channel, // this will remain after accepted
        "status" : "pending_outgoing"
      }.klog("pending subscription"); 
      //create call back for subscriber     
      options = {
          'name' : unique_name, 
          'eci_type' : channel_type,
          'attributes' : pending_entry
          //'policy' : ,
      };
    }
    if(target_channel neq "no_target_channel") 
    then
    {
      createChannel(meta:eci(),options);

      event:send(subscription_map, "nano_manager", "add_pending_subscription_requested") // send request
        with attrs = {
          "name"  : name,
          "name_space"    : name_space,
          "relationship" : your_role,
          "event_channel"  : channelEciByName(unique_name).klog("event_channel eci: "), 
          "status" : "pending_incoming",
          "channel_type" : channel_type
        };
    }
    fired {
      log (standardOut("success"));
      log(">> successful >>");
      raise nano_manager event add_pending_subscription_requested
        with 
        channel_name = unique_name;
      log(standardOut("failure")) if (unique_name eq "");
    } 
    else {
      log(">> failure >>");
    }
  }
  // creates back channel if needed, then it adds pending subscription to list of subscriptions.
  // can we put all this in a map and pass it as a attr? the rules internal.
  rule addPendingSubscription { // depends on wether or not a channel_name is being passed as an attribute
    select when nano_manager add_pending_subscription_requested
   pre {
        channel_name = event:attr("channel_name").defaultsTo("", standardError("channel_name"));
        channel_type = event:attr("channel_type").defaultsTo("SUBSCRIPTION", standardError("type")); // never will defaultto
        name_space = event:attr("name_space").defaultsTo("", standardError("name_space"));

      pending_subcriptions = (channel_name eq "") =>
         {
            "subscription_name"  : event:attr("name").defaultsTo("", standardError("")),
            "name_space"    : event:attr("name_space").defaultsTo("", standardError("name_space")),
            "relationship" : event:attr("relationship").defaultsTo("", standardError("relationship")),
            "event_channel"  : event:attr("event_channel").defaultsTo("", standardError("event_channel")),
            "status"  : event:attr("status").defaultsTo("", standardError("status"))
          }.klog("incoming pending subscription") |
          {};



      new_channel_name = (channel_name eq "") => // no channel name means its incoming.
            random_name(name_space) |
            channel_name;
    
      new_subscriptions = ent:subscriptions.append(new_channel_name); // create new list of subscriptions.

      options = {
        'name' : new_channel_name.klog("new_channel_name : "), 
        'eci_type' : channel_type,
        'attributes' : pending_subcriptions
          //'policy' : ,
      };
    }
    if(channel_name eq "") 
    then
    {
      createChannel(meta:eci(),options);
    }
    fired { //can i put multiple lines in a single guard?????????????????
      log(standardOut("successful pending incoming"));
      raise nano_manager event incoming_subscription_pending;
      set ent:subscriptions new_subscriptions; 
      log(standardOut("failure >>")) if (channel_name eq "");
    } 
    else { 
      log (standardOut("success pending outgoing >>"));
      raise nano_manager event outgoing_subscription_pending;
      set ent:subscriptions new_subscriptions;
    }
  }
  rule approvePendingSubscription { // used to notify both picos to add subscription request
    select when nano_manager approve_pending_subscription_requested
    pre{
      channel_name = event:attr("channel_name").defaultsTo( "no_channel_name", standardError("channel_name"));
      back_channel = channelByName(channel_name);
      event_channel = event:attrs("event_channel").defaultsTo( "no event_channel", standardError("no event_channel"));
      subscription_map = {
            "cid" : event_channel
      };
    }
    if (back_channel neq "") then
    {
      event:send(subscription_map, "nano_manager", "remove_pending_subscription"); // event to nothing needs better name
      event:send(subscription_map, "nano_manager", "add_subscription_requested")
       with attrs = {"event_channel" : back_channel};
    }
    fired 
    {
      log (standardOut("success"));
      raise nano_manager event 'remove_pending_subscription' // event to nothing  
      with channel_name = channel_name;
      raise nano_manager event 'event add_subscription_requested'
      with channel_name = channel_name;
    } 
    else 
    {
      log(">> failure >>");
    }
  }
  rule addSubscription { // changes attribute status value to subscribed
    select when nano_manager add_subscription_requested
    pre{
      channel_name = event:attrs("channel_name").defaultsTo( "no channel name", standardError("no channel name"));
      event_channel = event:attrs("event_channel").defaultsTo( "no event_channel", standardError("no event_channel"));
// can i get the eci at the same time as attributes?
      createOutGoing = function(event_channel){
        back_channel_eci = meta:eci();
        attributes = subscriptionsAttributesEci(back_channel_eci);
        attr = attributes.put(["status"],"subscribed");
        attrs = attr.put(["event_channel"],event_channel);
        attrs;
      };

      createIncoming = function(channel_name){
        attributes = subscriptionsAttributesName(channel_name);
        attr = attributes.put(["status"],"subscribed");
        attr;
      };
      // if no name its outgoing accepted
      // if name its incoming accepted
      attributes = (channel_name eq "no channel name" ) => 
            createOutGoing(event_channel) | 
            createIncoming(channel_name);
      
      // get eci to raise change attributes event
      eci = (channel_name eq "no channel name" ) => 
            meta:eci() | 
            eciFromName(channel_name);
    }
    if (channel_name eq "no channel name") then
    {
     noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_manager event 'subscription_added'
      with channel_name = channel_name;
      // set attributes to new values
      raise nano_manager event 'update_channel_attributes_requested'
      with attributes = attributes// need to be a array of attributes
      and eci = eci;
          } 
    else {
      log(">> failure >>");
    }
  }
    rule removeSubscription {
    select when nano_manager remove_subscription_requested
    pre{
      // if i get a name i need to look up eci 
      channel_name = event:attr("channel_name").defaultsTo( "No channel_name", standardError("channel_name"));
      eci = event:attr("eci").defaultsTo( "no eci", standardError("eci"));
      name = (channel_name eq 'No channel_name') => nameFromEci(eci) | channel_name;
    }
    if(channel_name neq "No channel_name") then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_manager event subscription_removed
      with channel_name = channel_name;
      // clean up
      raise nano_manager event channel_delete_requested with eci = eci;  
      clear ent:subscriptions{channel_name}; // will this remove array value?
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule cancelSubscription {
    select when nano_manager cancel_subscription__requested
            or  nano_manager reject_incoming_subscription_requested
            or  nano_manager cancel_outgoing_subscription_requested
    pre{
      event_channel = event:attr("event_channel").defaultsTo( "No event_channel", standardError("event_channel"));
      channel_name = event:attr("channel_name").defaultsTo( "No channel_name", standardError("channel_name"));
      subscription_map = {
            "cid" : event_channel
      };
      eci = eciFromName(channel_name);
    }
    if(event_channel neq "No event_channel") then
    {
      event:send(subscription_map, "nano_manager", "remove_subscription_requested")
        with attrs = {
          "eci"  : event_channel
        };

    }
    fired {
      raise nano_manager event remove_subscription_requested 
      with channel_name = channel_name
      and eci = eci; 
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