
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
    name "wrangler"
    description <<
      Wrangler ( ) Module

      use module  b507199x5 alias wrangler

      This Ruleset/Module provides a developer interface to the PICO (persistent computer object).
      When a PICO is created or authenticated this ruleset
      will be installed into the Personal Cloud to provide an Event layer.
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials
    use module b507199x8 alias pds
    // errors raised to.... unknown

    // Accounting keys
      //none
    provides skyQuery, rulesets, rulesetsInfo, //ruleset
    channels, channelAttributes, channelPolicy, channelType, //channel
    children, parent, attributes, prototypes, name, profile, pico, //pico
    subscriptions, channel, eciFromName, subscriptionsAttributes, //subscription
    standardError
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
    // taken from website, not tested. function call to a different pico on the same kre  
	  cloud_url = "https://#{meta:host()}/sky/cloud/";

      skyQuery = function(eci, mod, func, params) {
              response = http:get("#{cloud_url}#{mod}/#{func}", (params || {}).put(["_eci"], eci));
   
   
              status = response{"status_code"};
   
   
              error_info = {
                  "error": "sky cloud request was unsuccesful.",
                  "httpStatus": {
                      "code": status,
                      "message": response{"status_line"}
                  }
              };
   
   
              response_content = response{"content"}.decode();
              response_error = (response_content.typeof() eq "hash" && response_content{"error"}) => response_content{"error"} | 0;
              response_error_str = (response_content.typeof() eq "hash" && response_content{"error_str"}) => response_content{"error_str"} | 0;
              error = error_info.put({"skyCloudError": response_error, "skyCloudErrorMsg": response_error_str, "skyCloudReturnValue": response_content});
              is_bad_response = (response_content.isnull() || response_content eq "null" || response_error || response_error_str);
   
   
              // if HTTP status was OK & the response was not null and there were no errors...
              (status eq "200" && not is_bad_response) => response_content | error
          };

	
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
    channel = function (value){
      // if value is a number with ((([A-Z]|\d)*-)+([A-Z]|\d)*) attribute is cid.
      my_channels = channels();
      attribute = (value.match(re/(^(([A-Z]|\d)+-)+([A-Z]|\d)+$)/)) => 
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
        channels = my_channels{"channels"}.defaultsTo("undefined",standardError("undefined"));
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
    deleteChannel = defaction(value) {
      eci = (value.match(re/(^(([A-Z]|\d)+-)+([A-Z]|\d)+$)/)) => 
              value |
              eciFromName(value);
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

  profile = function(key) {
    pds:profile(key);
  }
  pico = function(namespace) {
    {
      "profile" : pds:profile(),
      "settings" : pds:settings(),
      "general" : pds:items(namespace)
    }
  }

  name = function() {
    pdsProfiles = pds:profile();
    pdsProfile = pdsProfiles{"profile"};
    name = (pdsProfile.typeof() eq 'hash') => pdsProfile{"name"} | ent:name ;
    {
      'status' : pdsProfiles{"status"},
      'picoName' : name
    }
  }

	attributes = function() {
		{
			'status' : true,
			'attributes' : ent:attributes
		}
	}
	prototypes = function() {
		{
			'status' : true,
			'prototypes' : ent:prototypes
		}
	}
	
	
	deletePico = defaction(eci) {
		noret = pci:delete_pico(eci, {"cascade":1});
		send_directive("deleted pico #{eci}");
	}
	
	
	prototypeDefinitions = {
		"core": [
        "b507199x5.dev",
        "b507199x8.dev", // pds
        "b507199x1.dev"// quick fix and a ugly one! bootstrap rid
			//"a169x625"
		]
	}

  //defaultPrototype = {
      Prototype_rids = "";//"asdf;asdf;asdf"
      Prototype_init_event_domain = "wrangler"; //  used to dynamicaly raise any desired events.
      Prototype_init_event_type = "init_events"; //  used to dynamicaly raise any desired events.
      Prototype_events = [["wrangler","init_general"],["wrangler","init_profile"],["wrangler","init_settings"]]; // array of arrays [[domain,type],....], used to create data structure in pds.
  //}

  createChildFromPrototype = defaction(attributes){ 
    a = attributes.klog("attributes: ");
    init_event_domain = attributes{"Prototype_init_event_domain"}; // array [domain,type]
    init_event_type = attributes{"Prototype_init_event_type"}; // array [domain,type]
    prototype_rids = attributes{"Prototype_rids"};

    rids = prototype_rids.split(re/;/); 
    // create child 
    newPicoInfo = pci:new_pico(meta:eci());
    newPicoEci = newPicoInfo{"cid"};// store child eci
    // bootstrap child
    a = pci:new_ruleset(newPicoEci, prototypeDefinitions{"core"}); // install core rids (bootstrap child) 
    // create child structure from prototype
    b = pci:new_ruleset(newPicoEci, rids);// install protypes rules 

    event:send({"cid":newPicoEci}, init_event_domain, init_event_type) // event to child to handle prototype creation 
      with attrs = attributes
  }

  //-------------------- Subscriptions ----------------------
    subscriptions = function() { // slow, whats a better way to prevent channel call, bigO(n^2)
      // list of channels
      channels_result = channels();
      channel_list = channels_result{'channels'};
      // filter list channels to only have subs
      filtered_channels = channel_list.filter( function(channel){
        isSubscription = function(channel) {
            attributes = channel{'attributes'};
            (attributes.isnull()) => null |
            (attributes{'subscription_name'}.isnull() eq false); // how do u use not in krl?
          };
        isSubscription(channel).klog("isSubscriptions(): ");

      }); 
      // reconstruct list, to have a backchannel in attributes.
      subs = filtered_channels.map( function(channel){
           channel.put(["attributes","back_channel"],channel{"cid"});
      });
      // name to attributes hash
      subsript = subs.map( function(channel){
          {channel{'name'}:channel{'attributes'}}
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
      subscription = subsript.collect(function(sub){
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
      v = value; // we dont need this right? // remove when you can test
      eci = (value.match(re/(^(([A-Z]|\d)+-)+([A-Z]|\d)+$)/)) => 
              value |
              eciFromName(value);

      attributes = channelAttributes(eci);
      attributes{'Attributes'};
    } 


    /*findVehicleByBackchannel = function (bc) {
       garbage = bc.klog(">>>> back channel <<<<<");
       vehicle_ecis = wrangler:subscriptionList(common:namespace(),"Vehicle");
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
    select when wrangler install_rulesets_requested
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
    select when wrangler uninstall_rulesets_requested
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
 // we should add a append / modifie channel attributes rule set. takes in new and modified values and puts them in.
  rule updateChannelAttributes {
    select when wrangler update_channel_attributes_requested
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
    select when wrangler update_channel_policy_requested // channel_policy_update_requested
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
    select when wrangler channel_deletion_requested
    pre {
      value = event:attr("eci").defaultsTo(event:attr("name").defaultsTo("", standardError("missing event attr eci or name")), standardError("looking for name instead of eci."));
    }
    {
      deleteChannel(value);
    }
    fired {
      log (standardOut("success deleted channel #{value}"));
      log(">> successfully  >>");
    } 
   // else { -------------------------------------------// can we reach this point?
    //  log(">> could not delete channel #{value} >>");
   //    }
  }
  
  rule createChannel {
    select when wrangler channel_creation_requested
    pre {
      event_attributes = event:attrs();
    /*  <eci options>
    name     : <string>        // default is "Generic ECI channel" 
    eci_type : <string>        // default is "PCI"
    attributes: <array>
    policy: <map>  */
      channel_name = event:attr("channel_name").defaultsTo("", standardError("missing event attr channels"));
      type = event:attr("channel_type").defaultsTo("Unknown", standardError("missing event attr channel_type"));
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
          // do we need to check the format of name? is it wrangler's job?
    if(channel_name.match(re/\w[\w-]*/)) then 
          { 
      createChannel(meta:eci(), options);
          }
    fired {
      log (standardOut("success created channels #{channel_name}"));
      log(">> successfully  >>");
      raise wrangler event 'channel_created' // event to nothing  
            attributes event_attributes;
          } 
    else {
      log(">> could not create channels #{channel_name} >>");
          }
    }
  
  
  //-------------------- Picos ----------------------
	rule createChild { // must pass list of rids to install in child and domain / type for init event.
		select when wrangler child_creation
		pre {
      attribute = event:attrs();
      name = event:attr("name");
      Attribute = attribute // defaultsTo 
                  .put(["Prototype_rids"],(event:attr("Prototype_rids") || Prototype_rids))
                  .put(["Prototype_init_event_domain"],(event:attr("Prototype_init_event_domain") || Prototype_init_event_domain))
                  .put(["Prototype_init_event_type"],(event:attr("Prototype_init_event_type") || Prototype_init_event_type))
                  ;                  
		}

		{
			createChildFromPrototype( Attribute ); 
		}
		always {
			log(standardOut("pico created with name #{name}"));
		}
	}
	 
	rule initializeEvents {// this rule should raise events to self that then raise events to pds
		select when wrangler init_events 
		  foreach Prototype_events.klog("Prototype_events : ") setting (PT_event)
		pre {
      PTE_domain = PT_event[0].klog("domain : ");
		  PTE_type = PT_event[1].klog("type : ");
    }
		{
      event:send({"cid":meta:eci()}, PTE_domain, PTE_type)  
      with attrs = event:attrs();
		}
		
		always {
      log("init pds");
      //raise PTE_domain event PTE_type 
      //raise "wrangler" event PTE_type 
      //      attributes event:attrs().klog("attributes : ")
		}
	}




    rule initializeGeneral {
    select when wrangler init_general 
    pre {

    }
    {
      noop();
    }
    always {
      raise pds event map_item // init general  
            attributes 
          { 
            "namespace": "developer",
              "mapvalues": { "name": "tedrub",
                  "discription": "ted rub was a programer!" 
                 }
          }
    }
  }
  rule initializeProfile {// this rule should build pds data structure
    select when wrangler init_profile
    
    pre {}
    
    {
      noop();
    }
    
    always {

    raise pds event updated_profile // init prototype  // rule in pds needs to be created.
            attributes event:attrs()
    }
  }
/*
	rule setPicoAttributes {
		select when wrangler set_attributes_requested
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
		select when wrangler clear_attributes_requested
		pre {
		}
		{
			noop();
		}
		fired {
			clear ent:attributes;
		}
	}
	*/

	rule deleteChild {
		select when wrangler child_deletion
		pre {
			eciDeleted = event:attr("deletionTarget").defaultsTo("", standardError("missing pico for deletion"));
		}
		if(eciDeleted neq "") then
		{
			deletePico(eciDeleted);
		}
		notfired {
			log "deletion failed because no child was specified";
		}
	}

  //-------------------- Subscriptions ----------------------http://developer.kynetx.com/display/docs/Subscriptions+in+the+wrangler+Service
  /* 
   ========================================================================
   No Persistent Variables for subscriptions, subscriptions information is stored in the "backChannel" Channels attributes varible
    backChannel : {
        type: <string>
        name: <string>
        policy: ?? // not used.
        attrs: {
          (Subscription attributes) 
           "name"  : <string>,
           "name_space": <string>,
           "relationship" : <string>,
           "target_eci": <string>, // this is only stored in the origanal requestie
           "event_eci" : <string>,
           "attributes" : <string>, // this will be a object(mostlikely an array) that has been encoded as a string. 
           "status": <string> // discribes subscription status, incouming, outgoing, subscribed
        }
    }
    ========================================================================
   */

   // creates back_channel and sends event for other pico to create back_channel.
  rule subscribe {// need to change varibles to snake case.
    select when wrangler subscription
   pre {
      // attributes for back_channel attrs
      name   = event:attr("name").defaultsTo("standard", standardError("channel_name"));
      name_space     = event:attr("name_space").defaultsTo("shared", standardError("name_space"));
      my_role  = event:attr("my_role").defaultsTo("peer", standardError("my_role"));
      your_role  = event:attr("your_role").defaultsTo("peer", standardError("your_role"));
      target_eci = event:attr("target_eci").defaultsTo("no_target_eci", standardError("target_eci"));
      channel_type      = event:attr("channel_type").defaultsTo("subs", standardError("type"));
      //status      = event:attr("status").defaultsTo("status", standardError("status ")); 
      attributes = event:attr("attrs").defaultsTo("status", standardError("status "));

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
        "status" : "outbound", // should this be passed in from out side? I dont think so.
        "attributes" : attributes

      }; 
      //create call back for subscriber     
      options = {
          'name' : unique_name, 
          'eci_type' : channel_type,
          'attributes' : pending_entry
          //'policy' : ,
      };
    }
    if(target_eci neq "no_target_eci") // check if we have someone to send a request too
    then
    {

      createChannel(meta:eci(),options);// just use meta:eci()??

      event:send(subscription_map, "wrangler", "pending_subscription") // send request
        with attrs = {
          "name"  : name,
          "name_space"    : name_space,
          "relationship" : your_role,
          "event_eci"  : eciFromName(unique_name), 
          "status" : "inbound",
          "channel_type" : channel_type,
          "attributes" : attributes
        };
    }
    fired {
      log (standardOut("success"));
      log(">> successful >>");
      raise wrangler event pending_subscription
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
    select when wrangler pending_subscription
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
            "status"  : event:attr("status").defaultsTo("", standardError("status")),
            "attributes" : event:attr("attributes").defaultsTo("", standardError("attributes"))
          } |
          {};
          // should this go into the hash above?
      unique_name = (status eq "inbound") => 
            randomName(pending_subscriptions{'name_space'}) |
            channel_name;
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
      raise wrangler event inbound_pending_subscription_added // event to nothing
          with status = pending_subscriptions{'status'}
            and name = pending_subscriptions{'subscription_name'}
            and channel_name = unique_name;
      log(standardOut("failure >>")) if (channel_name eq "");
    } 
    else { 
      log (standardOut("success pending outgoing >>"));
      raise wrangler event outbound_pending_subscription_added; // event to nothing
    }
  }
  rule approvePendingSubscription { // used to notify both picos to add subscription request
    select when wrangler pending_subscription_approval
    pre{
      channel_name = event:attr("channel_name").defaultsTo( "no_channel_name", standardError("channel_name"));
      back_channel = channel(channel_name);
      back_channel_eci = back_channel{'cid'}; // this is why we call channel and not subscriptionsAttributes.
      attributes = back_channel{'attributes'};
      status = attributes{'status'};
      //back_channel_eci = eciFromName(channel_name).klog("back eci: ");
      event_eci = attributes{'event_eci'}; // whats better?
      subscription_map = {
            "cid" : event_eci
      }.klog("subscription Map: ");
    }// this is a possible place to create a channel for subscription
    if (event_eci neq "no event_eci") then
    {
      event:send(subscription_map, "wrangler", "pending_subscription_approved") // pending_subscription_approved..
       with attrs = {"event_eci" : back_channel_eci , 
                      "status" : "outbound"}
    }
    fired 
    {
      log (standardOut("success"));
      raise wrangler event 'pending_subscription_approved' // event to nothing  
        with channel_name = channel_name
        and status = "inbound";
    } 
    else 
    {
      log(">> failure >>");
    }
  }
  rule addSubscription { // changes attribute status value to subscribed
    select when wrangler pending_subscription_approved
    pre{
      status = event:attr("status").defaultsTo("", standardError("status"));
      outGoing = function(event_eci){
        attributes = subscriptionsAttributes(meta:eci().klog("meta:eci for attributes: ")).klog("outgoing attributes: ");
        attr = attributes.put({"status" : "subscribed"}).klog("put outgoing status: "); // over write original status
        attrs = attr.put({"event_eci" : event_eci}).klog("put outgoing event_eci: "); // add event_eci
        attrs;
      };

      incoming = function(channel_name){
        attributes = subscriptionsAttributes(channel_name);
        attr = attributes.put({"status": "subscribed"}).klog("incoming attributes: ");
        attr;
      };

      attributes = (status eq "outbound" ) => 
            outGoing(event:attr("event_eci").defaultsTo( "no event_eci", standardError("no event_eci"))) | 
            incoming(event:attr("channel_name").defaultsTo( "no channel name", standardError("no channel name")));
      
      // get eci to change channel attributes
      eci = (status eq "outbound" ) => 
            meta:eci() | 
            eciFromName(event:attr("channel_name").defaultsTo( "no channel name", standardError("no channel name")).klog("attribute channel_name: ")).klog("eci from name: ");
    }
    // always update attribute changes
    {
     updateAttributes(eci,attributes.klog("updateAttributes: "));
    }
    fired {
      log (standardOut("success"));
      raise wrangler event 'subscription_added' // event to nothing
        with channel_name = event:attr("channel_name").defaultsTo( "no channel name", standardError("no channel name"));
      } 
    else {
      log(">> failure >>");
    }
  }

  rule cancelSubscription {
    select when wrangler subscription_cancellation
            or  wrangler inbound_subscription_rejection
            or  wrangler outbound_subscription_cancellation
    pre{
      status = event:name();

      channel_name = event:attr("channel_name").defaultsTo( "No channel_name", standardError("channel_name"));
      //get channel from name
      back_channel = channel(channel_name);
      // look up back channel for canceling outbound.
      back_channel_eci = back_channel{'cid'}.klog("back_channel_eci: "); // this is why we call channel and not subscriptionsAttributes.
      // get attr from channel
      attributes = back_channel{'attributes'};
      // get event_eci for subscription_map // who we will notify
      event_eci = attributes{'event_eci'}.defaultsTo(attributes{'target_eci'}, " target_eci used."); // whats better?
      // send remove event to event_eci
      // raise remove event to self with eci from name .

      subscription_map = {
            "cid" : event_eci
      }.klog("subscription_map: ");
    }
    //if( eci neq "No event_eci") then // always try to notify other party
    {
      event:send(subscription_map, "wrangler", "subscription_removal")
        with attrs = {
          // this will catch the problem with canceling outbound
          "eci"  : back_channel_eci, // tabo to pass this but other pico has no other way to know ...
          "status": status//"outbound"
        };
    }
    fired {
      log (standardOut("success"));
      raise wrangler event subscription_removal 
        with eci = eciFromName(channel_name) // this probly could be back_channel_eci to save on computations
        and status = "internal"; 
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule removeSubscription {
    select when wrangler subscription_removal
    pre{
      status = event:attr("status").defaultsTo("", standardError("status"));
      passedEci= event:attr("eci").defaultsTo("", standardError("eci"));
      eciLookUpFromEvent = function(event_eci){
          get_event_eci = function(channel){
              attributes = channel{'attributes'};
              return = (attributes.isnull()) => 
                  null |
                  (attributes{'event_eci'} ); 
              return;
          };
          my_channels = channels();
          channel_list = my_channels{"channels"}.defaultsTo("no Channel",standardOut("no channel found, by channels"));
          filtered_channels = channel_list.filter( function (channel) {
          ( get_event_eci(channel) eq event_eci);
          }); 
        result = filtered_channels.head().defaultsTo("",standardError("no channel found, by .head()"));
        // a channel with the correct event_eci
        return = result{'cid'} // the correct eci to be removed.
        (return);
      };

      eci = ( status eq "inbound_subscription_rejection" || status eq "subscription_cancellation" ) => meta:eci() |
             (status eq "outbound_subscription_cancellation") => eciLookUpFromEvent( passedEci ) |
                passedEci; // passed is used to deleted backchannel on self 

      channel_name = nameFromEci(eci); // for event to nothing

    }
    {
      //clean up channel
     deleteChannel(eci.klog("eci being deleted. : ")); 
    }
    always {
      log (standardOut("success, attemped to remove subscription"));
      raise wrangler event subscription_removed // event to nothing
        with removed_channel_name = channel_name;
    } 
  } 
  /* 
  rule update{
    // check status is subscribed

    // raise mod/updated attrs event to both subscribed picos 

  }
  rule update/modChannelAttributes {
      select when wrangler subscription_attribute_update
            pre{
   
            //get all attributes to be updated. passed in

            //get current attributes.

            //"put" updated values into current
          
            // use deffaction to update attributes
  */

// unsubscribed all, check event from parent // just cancelSubscription... 
// let all your connection know your leaving.

}