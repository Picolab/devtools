
// varibles 
// ent:my_picos
// ent:picos_attributes


// operators are camel case, variables are snake case.


// questions
// standard state change raiseevent post function??
// when should we use klogs?
// when registering a ruleset if you pass empty peramiters what happens

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
    provides rulesets, rulesetsInfo, //ruleset
    channels, channelAttributes, channelPolicy, channelType, //channel
    children, parent, attributes, //pico
    subscriptions, channel, eciFromName, subscriptionsAttributes, //subscription
    standardError
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
	
	
  //-------------------- Rulesets --------------------
    rulesets = function() {
      eci = meta:eci().klog("eci: ");
      results = pci:list_ruleset(eci).klog("results of pci list_ruleset");//defaultsTo("error",standardError("pci list_ruleset failed"));  
      rids = results{'rids'}.defaultsTo("error",standardError("no hash key rids"));
      {
       'status'   : (rids neq "error"),
        'rids'     : rids
      };
    }
    // pci method? 
    rulesetsInfo = function(rids) {//takes an array of rids as parameter // can we write this better???????
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
      results = pci:get_eci_attributes(eci.klog("get_eci_attributes passed eci: ")).defaultsTo("error",standardError("get_eci_attributes")); // list of ECIs assigned to userid
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
		parent = pci:list_parent(self).defaultsTo("error", standardError("pci parent retrieval failed"));
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
        "b507199x5"
			//"a169x625"
		]
	};// defaction needs to return a result to solve this 
	picoFactory = function(myEci, protos) {
		newPicoInfo = pci:new_pico(myEci);
		newPico = newPicoInfo{"cid"};
		a = pci:new_ruleset(newPico, prototypes{"core"}); 
		b = protos.map(function(x) {pci:new_ruleset(newPico, prototypes{x});});
		newPico;
	}

  //-------------------- Subscriptions ----------------------
    subscriptions = function() { // slow, whats a better way to prevent channel call, bigO(n^2)
      // list of subs
      subscriptions = ent:subscriptions.defaultsTo("error",standardError("undefined"));
      // list of channels
      channels_result = channels();
      channel_list = channels_result{'channels'};
      // filter list channels to only have subs
      // 2nbigO(n^2) but is faster because of less server calls to database
      filtered_channels = channel_list.filter( function(channel){
        //channel{'name'} in other array? 
        subscriptions.any( function(name){ 
          (name eq channel{'name'});  
        }); 
      }); 
      // reconstruct list, to be channelname hashed to attributes.
      subs = filtered_channels.map( function(channel){
          {channel{'name'}:channel{'attributes'}};
      });
      /* 
      {"18:floppy" :
          {"status":"inbound","relationship":"","name_space":"18",..}
      */
      status = function(sub){ // takes a subscription and returns its status.
        value = sub.values(); // array of values [attributes]
        attributes = value.head(); // get attributes
        status = (attributes.typeof() eq 'hash')=> // for robustness check type.
        attributes{'status'} |
          'error';
        (status);
      };
      // return a collection of subs based on status.
      subscription = subs.collect(function(sub){
        (status(sub));
      });

      {
        'status' : (subscriptions neq "error"),
        'subscriptions'  : subscription
      };

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
    // optimize by taking a list of names, to prevent multiple network calls for channels
    checkName = function(name){
          chan = channels();
          //channels = channels(); worse bug ever!!!!!!!!!!!!!!!!!!!!!!!!!!!
          // in our meetings we said to check name_space, how is that done?
          /*{
          "last_active": 1426286486,
          "name": "Oauth Developer ECI",
          "type": "OAUTH",
          "cid": "158E6E0C-C9D2-11E4-A556-4DDC87B7806A",
          "attributes": null}
          */
          chs = chan{"channels"}.defaultsTo("no Channel",standardOut("no channel found"));
          names = chs.none(function(channel){channel{"name"} eq name});
          (names);

    }
    // takes name or eci 
    subscriptionsAttributes = function (value){
      v = value;
      eci = (value.match(re/((([A-Z]|\d)*-)+([A-Z]|\d)*)/)) => 
              value |
              eciFromName(value);

      attributes = channelAttributes(eci);
      attributes{'Attributes'};
    } 

     channel = function (value){
      // if value has a ":"" then attribute is name otherwise its cid 
      // if value is a number with ((([A-Z]|\d)*-)+([A-Z]|\d)*) attribute is cid.
      my_channels = channels();
      attribute = (value.match(re/((([A-Z]|\d)*-)+([A-Z]|\d)*)/)) => 
              'cid' |
              'name';
      channel_list = my_channels{"channels"}.defaultsTo("no Channel",standardOut("no channel found, by channels"));
      filtered_channels = channel_list.filter(function(channel){
        (channel{attribute} eq value);}); 
      result = filtered_channels.head().defaultsTo("",standardError("no channel found, by .head()"));
      (result);
    }

      nameFromEci = function(eci){ 
        //eci = meta:eci();
        channel_single = channel(eci);
        channel_single{'name'};
      } 

      eciFromName = function(name){
        channel_single = channel(name);
        channel_single{'cid'};
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
  
  rule installRulesets {
    select when nano_manager install_rulesets_requested
    pre { 
      eci = meta:eci();
      rids = event:attr("rids").defaultsTo("",standardError(" "));
      // this will never get an array from a url/event ?
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
  rule uninstallRulesets { // should this handle multiple uninstalls ??? 
    select when nano_manager uninstall_rulesets_requested
    pre {
      eci = meta:eci();
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
      eci = event:attr("eci").defaultsTo("", standardError("missing event attr channels")); // should we force the event to be raised to the eci being updated.
      attributes = event:attr("attributes").defaultsTo("error", standardError("undefined"));
      attrs = attributes.split(re/;/);
      //attrs = attributes.decode();
      //channels = Channels();
    }
    if(eci neq "" && attributes neq "error") then { // check?? redundant????
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
      eci = event:attr("eci").defaultsTo("", standardError("missing event attr channels")); // should we force... use meta:eci()
      policy_string = event:attr("policy").defaultsTo("error", standardError("undefined"));// policy needs to be a map, do we need to cast types?
      policy = policy_string.decode();
    }
    if(eci neq "" && policy neq "error") then { // check?? redundant?? whats better??
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
    } 
   // else { -------------------------------------------// can we reach this point?
    //  log(">> could not delete channel #{eci} >>");
   //    }
  }
  rule createChannel {
    select when nano_manager channel_creation_requested
    pre {
    /*  <eci options>
    name     : <string>        // default is "Generic ECI channel" 
    eci_type : <string>        // default is "PCI"
    attributes: <array>
    policy: <map>  */
      channel_name = event:attr("channel_name").defaultsTo("", standardError("missing event attr channels"));
      type = event:attr("channel_type").defaultsTo("", standardError("missing event attr channel_type"));
      attributes = event:attr("attributes").defaultsTo("", standardError("missing event attr attributes"));
      policy = event:attr("policy").defaultsTo("", standardError("missing event attr attributes"));
      // do we need to check if we need to decode ?? what would we check?
      
      options = {
        'name' : channel_name,
        'eci_type' : type,
        'attributes' : {"channel_attributes" : attributes},
        'policy' : {"policy" : policy}
      };
          }
          // do we need to check the format of name? is it nano_manager's job?
    if(channel_name.match(re/\w[\w-]*/)) then 
          { 
      createChannel(meta:eci(), options);
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
			
			newPico = picoFactory(myEci, []); // breaks the rules, mutates.............
		}

		{
			noop();
		}
		
		fired {
			log(standardOut("pico created"));
		}
	}
	 // move attributes to create child. 
	rule initializeChild {
		select when nano_manager child_created
		
		pre {
      //parentInfo = event:attr("parent");
	//		name = event:attr("name");
			attrs = event:attr("attributes").decode();
		}
		
		{
			noop();
		}
		
		fired {
		//	set ent:parent parentInfo;
		//	set ent:children {};
			//set ent:name name;
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
			pci:delete_pico(eciDeleted);
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
  //        "target_eci"/"event_eci" : ,
  //        "status": 
  //       ],
  //      }
  //    }
  //  }
  //
   // ========================================================================
   // creates back_channel and sends event for other pico to create back_channel.

  rule subscribe {// need to change varibles to snake case.
    select when nano_manager subscription
   pre {
    // update to use a status instead of target channel 
      // attributes for back_channel attrs
      name   = event:attr("name").defaultsTo("standard", standardError("channel_name"));
      name_space     = event:attr("name_space").defaultsTo("shared", standardError("name_space"));
      relationship  = event:attr("relationship").defaultsTo("peer-peer", standardError("relationship"));
      target_eci = event:attr("target_eci").defaultsTo("no_target_eci", standardError("target_eci"));
      channel_type      = event:attr("channel_type").defaultsTo("subs", standardError("type"));
      status      = event:attr("status").defaultsTo("status", standardError("status "));
      
      // extract roles of the relationship
      roles   = relationship.split(re/\-/);
      my_role  = roles[0];
      your_role = roles[1];
     // // destination for external event
      subscription_map = {
            "cid" : target_eci
      };
      // create unique_name for channel
      unique_name = randomName(name_space);

      // build pending subscription entry

      pending_entry = {
        "subscription_name"  : name,
        "name_space"    : name_space,
        "relationship" : my_role,
        "target_eci"  : target_eci, // this will remain after accepted
        "status" : "outbound"
      }; 
      //create call back for subscriber     
      options = {
          'name' : unique_name, 
          'eci_type' : channel_type,
          'attributes' : pending_entry
          //'policy' : ,
      };
    }
    if(target_eci neq "no_target_eci") 
    then
    {
      createChannel(meta:eci(),options);// just use meta:eci()??

      event:send(subscription_map, "nano_manager", "pending_subscription") // send request
        with attrs = {
          "name"  : name,
          "name_space"    : name_space,
          "relationship" : your_role,
          "event_eci"  : eciFromName(unique_name), 
          "status" : "inbound",
          "channel_type" : channel_type
        };
    }
    fired {
      log (standardOut("success"));
      log(">> successful >>");
      raise nano_manager event pending_subscription
        with status = pending_entry{'status'}
        and channel_name = unique_name;
      log(standardOut("failure")) if (unique_name eq "");
    } 
    else {
      log(">> failure >>");
    }
  }
  // creates back channel if needed, then it adds pending subscription to list of subscriptions.
  // can we put all this in a map and pass it as a attr? the rules internal.
  rule addPendingSubscription { // depends on wether or not a channel_name is being passed as an attribute
    select when nano_manager pending_subscription
   pre {
        channel_name = event:attr("channel_name").defaultsTo("SUBSCRIPTION", standardError("channel_name")); // never will defaultto
        channel_type = event:attr("channel_type").defaultsTo("SUBSCRIPTION", standardError("type")); // never will defaultto
        status = event:attr("status").defaultsTo("", standardError("status"));
      pending_subscriptions = (status eq "inbound") =>
         {
            "subscription_name"  : event:attr("name").defaultsTo("", standardError("")),
            "name_space"    : event:attr("name_space").defaultsTo("", standardError("name_space")),
            "relationship" : event:attr("relationship").defaultsTo("", standardError("relationship")),
            "event_eci"  : event:attr("event_eci").defaultsTo("", standardError("event_eci")),
            "status"  : event:attr("status").defaultsTo("", standardError("status"))
          } |
          {};
          // should this go into the hash above?
      unique_name = (status eq "inbound") => 
            randomName(pending_subscriptions{'name_space'}) |
            channel_name;
      // create new list of subscriptions, if its empty start a new one.
      new_subscriptions = (ent:subscriptions.head() eq 0) => //--------------------------------------could erase your list of subscriptions is there a better way?
              [unique_name] |
              ent:subscriptions.append(unique_name); 

      options = {
        'name' : unique_name, 
        'eci_type' : channel_type,
        'attributes' : pending_subscriptions
          //'policy' : ,
      };
    }
    if(status eq "inbound") 
    then
    {
      createChannel(meta:eci(),options);
    }
    fired { 
      log(standardOut("successful pending incoming"));
      raise nano_manager event inbound_pending_subscription_added; // event to nothing
      set ent:subscriptions new_subscriptions; 
      log(standardOut("failure >>")) if (channel_name eq "");
    } 
    else { 
      log (standardOut("success pending outgoing >>"));
      raise nano_manager event outbound_pending_subscription_added; // event to nothing
      set ent:subscriptions new_subscriptions;
    }
  }
  rule approvePendingSubscription { // used to notify both picos to add subscription request
    select when nano_manager pending_subscription_approval
    pre{
      channel_name = event:attr("channel_name").defaultsTo( "no_channel_name", standardError("channel_name"));
      back_channel = channel(channel_name);
      back_channel_eci = back_channel{'cid'};
      attributes = back_channel{'attributes'};
      status = attributes{'status'};
      //back_channel_eci = eciFromName(channel_name).klog("back eci: ");
      event_eci = attributes{'event_eci'}; // whats better?
      subscription_map = {
            "cid" : event_eci
      };
    }// this is a possible place to create a channel for subscription
    if (event_eci neq "no event_eci") then
    {
      event:send(subscription_map, "nano_manager", "pending_subscription_approved") // pending_subscription_approved..
       with attrs = {"event_eci" : back_channel_eci}
       and status = "outbound";
    }
    fired 
    {
      log (standardOut("success"));
      raise nano_manager event 'pending_subscription_approved' // event to nothing  
        with channel_name = channel_name
        and status = "inbound";
    } 
    else 
    {
      log(">> failure >>");
    }
  }
  rule addSubscription { // changes attribute status value to subscribed
    select when nano_manager pending_subscription_approved
    pre{
      channel_name = event:attr("channel_name").defaultsTo( "no channel name", standardError("no channel name"));
      event_eci = event:attr("event_eci").defaultsTo( "no event_eci", standardError("no event_eci"));
      status = event:attr("status").defaultsTo("", standardError("status"));
      s = status.klog("status: ");
      outGoing = function(event_eci){
        attributes = subscriptionsAttributes(meta:eci().klog("meta:eci for attributes: ")).klog("outgoing attributes: ");
        attr = attributes.put({"status" : "subscribed"}).klog("put outgoing status: "); // over write original status
        attrs = attr.put({"event_eci" : event_eci}).klog("put outgoing event_eci: "); // add event_eci
        attrs;
      };

      incoming = function(channel_name){
        attributes = subscriptionsAttributes(channel_name).klog("incoming attributes: ");
        attr = attributes.put({"status": "subscribed"}).klog("incoming attributes: ");
        attr;
      };
      // if no name its outgoing accepted
      // if name its incoming accepted
      attributes = (status eq "outbound" ) => 
            outGoing(event_eci) | 
            incoming(channel_name);
      
      // get eci to change channel attributes
      eci = (status eq "outbound" ) => 
            meta:eci() | 
            eciFromName(channel_name.klog("attribute channel_name: ")).klog("eci from name: ");
    }
    // always update attribute changes
    {
     updateAttributes(eci,attributes.klog("updateAttributes: "));
    }
    fired {
      log (standardOut("success"));
      raise nano_manager event 'subscription_added' // event to nothing
        with channel_name = channel_name;
      } 
    else {
      log(">> failure >>");
    }
  }

  rule cancelSubscription {
    select when nano_manager subscription_cancellation
            or  nano_manager inbound_subscription_rejection
            or  nano_manager outbound_subscription_cancellation
    pre{
      channel_name = event:attr("channel_name").defaultsTo( "No channel_name", standardError("channel_name"));
      eci = eciFromName(channel_name);
      subscription_map = {
            "cid" : eci
      };
    }
    if( eci neq "No event_eci") then
    {
      event:send(subscription_map, "nano_manager", "subscription_removal")
        with attrs = {
          "eci"  : eci,
          "channel_name" : channel_name
        };

    }
    fired {
      raise nano_manager event subscription_removal 
        with channel_name = channel_name
          and eci = eci; 
      log (standardOut("success"));
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule removeSubscription {
    select when nano_manager subscription_removal
    pre{
      channel_name = event:attr("channel_name").defaultsTo( "No channel_name", standardError("channel_name"));
      eci = event:attr("eci").defaultsTo( "no eci", standardError("eci"));
    }
    {
      //clean up channel
      deleteChannel(eci); 
    }
    always {
      log (standardOut("success, attemped to remove subscription"));
      raise nano_manager event subscription_removed // event to nothing
        with channel_name = channel_name;
      // clean up
      clear ent:subscriptions{channel_name};
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
      }
    } 
// unsubscribed all, check event from parent // just cancelSubscription... 
// let all your connection know your leaving.

}