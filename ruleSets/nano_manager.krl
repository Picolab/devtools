
// varibles 
// ent:my_picos


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
    provides registered, singleRuleset, installed, describeRules, //ruleset
    channels, attributes, policy, type, //channel
    clients, //client
    picos, accountProfile, //pico
    schedules, scheduleHistory, // schedule
    subscriptions, outGoing, incoming, //subscription
    newPico, newCloud, fixPico, deletePico, listChildren, listParent, setParent //testing pci pico functions
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
	
	
	//----------------------testing PCI pico functions-------------------
	
	newPico = function(eci) {
		newEci = pci:new_pico(eci);
		{ 
			'newEci' : newEci
		}
	}

	newCloud = function(eci) {
		newEci = pci:new_cloud(eci);
		{
			'newEci' : newEci
		}
	}
	
	fixPico = function(eci) {
		a = pci:new_ruleset(newEci, "507199x5.dev");
		{
			'nanoAdded?' : a
		}
	}
	
	deletePico = function(eci, cascade) {
		pci:delete_cloud(eci, {"cascade" : cascade});
	}
	
	listChildren = function(eci) {
		children = pci:list_children(eci);
		{
			'children' : children
		}
	}
	
	listParent = function(eci) {
		parent = pci:list_parent(eci);
		{
			'parent' : parent
		}
	}
	
	setParent = function(child, newParent) {
		target = pci:set_parent(child, newParent);
		{
			'newParent' : target
		}
	}
	
	
	
	
	
	
	
  //-------------------- Rulesets --------------------
    registered = function() {
      eci = meta:eci();
        rulesets = rsm:list_rulesets(eci).defaultsTo({},standardError("undefined"));
        ruleset_gallery = rulesets.map( function(rid){
          ridInfo = rsm:get_ruleset( rid ).defaultsTo({},standardError("undefined"));
          ridInfo
        }).defaultsTo("error",standardError("undefined"));
        {
          'status' : (ruleset_gallery neq "error"),
          'rulesets' : ruleset_gallery          
        };
    }
    singleRuleset = function(rid) { 
      eci = meta:eci();
      results = registered().defaultsTo({},standardError("undefined"));
      rulesets = results{"rulesets"}.defaultsTo({},standardError("undefined"));
      result = rulesets.filter( function(rule_set){rule_set{"rid"} eq rid } ).defaultsTo( "error",standardError("undefined"));
      {
        'status' : (result neq "error"),
        'ruleset' : result[0]
      };
    }
    installed = function() {
      eci = meta:eci().klog("eci: ");
      results = pci:list_ruleset(eci).klog("results of pci list_ruleset");//defaultsTo("error",standardError("pci list_ruleset failed"));  
      rids = results{'rids'}.defaultsTo("error",standardError("no hash key rids"));
      {
       'status'   : (rids neq "error"),
        'rids'     : rids
      };
    }
    describeRules = function(rids) {//takes an array of rids as parameter // can we write this better???????
      rids_string = rids.join(";");
      describe_url = "https://#{meta:host()}/ruleset/describe/#{$rids_string}";
      resp = http:get(describe_url);
      results = resp{"content"}.decode().defaultsTo("",standardError("content failed to return"));
      {
       'status'   : (resp{"status_code"} eq "200"),
       'description'     : results
      };
    }
    install = defaction(eci, ridlist){
      new_ruleset = pci:new_ruleset(eci, ridlist);
      send_directive("installed #{ridlist}");
    }
    uninstall = defaction(eci, ridlist){
      deleted = pci:delete_ruleset(eci, ridlist);
      send_directive("uninstalled #{ridlist}");
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
    attributes = function(eci) {
      results = pci:get_eci_attributes(eci).defaultsTo("error",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "error"),
        'Attributes' : results
      };
    }
    policy = function(eci) {
      results = pci:get_eci_policy(eci).defaultsTo("error",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "error"),
        'Policy' : results
      };
    }
    type = function(channel_id) { // untested!!!!!!!!!!!!!!!!!!!
      channels = Channels().defaultsTo("error",">> undefined >>");

      getType = function(channel_id,channels) {
        channels = channels{"channels"}.defaultsTo("undefined",standardError("undefined"));
        channel = channels.filter( function(channel){channel{"cid"} eq channel_id } ).defaultsTo( "error",standardError("undefined"));
        channel = channel[0];
        type = channel{"type"};
        temp = (type.typeof() eq "str" ) => type | type.typeof() eq "array" => type[0] |  type.keys();
        type2 = (temp.typeof() eq "array") => temp[0] | temp;   
        type2;
      };
      type = ((channels neq "error") && (channels neq {} )) => getType() | "error";
      {
        'status'   : (type neq "error"),
        'channels' : channels
      };
    }
    updateAttrs = defaction(channel_id, attributes){
      set_eci = pci:set_eci_attributes(channel_id, attributes);
      send_directive("updated #{channel_id} attributes");
    }
    updatePolicy = defaction(channel_id, policy){
      set_polcy = pci:set_eci_policy(channel_id, policy); // policy needs to be a map, do we need to cast types?
      send_directive("updated #{channel_id} policy");
    }
    deleteEci = defaction(channelID) {
      deleteeci =pci:delete_eci(channelID);
      send_directive("deleted #{channelID}");
    }
    createEci = defaction(user, options){
      new_eci = pci:new_eci(user, options);
      send_directive("created new eci");
    }
  //-------------------- Clients --------------------
    Clients = function() { 
      eci = meta:eci();
      clients = pci:get_authorized(eci).defaultsTo("error",standardError("undefined")); // pci does not have this function yet........
      //krl_struct = clients.decode() // I dont know if we needs decode
     // .klog(">>>>krl_struct")
     // ;
      {
        'status' : (clients != "error"),
        'clients' : krl_struct
      }
    }
    addPCIbootstraps = defaction(appECI,bootstrapRids){
      boot = bootstrapRids.map(function(rid) { pci:add_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap add result >>>>>>>");
      send_directive("pci bootstraps updated.")
        with rulesets = list_bootstrap(appECI); // is this working?
    };
    removePCIbootstraps = defaction(appEC,IbootstrapRids){
      boot = bootstrapRids.map(function(rid) { pci:remove_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap removed result >>>>>>>");
      send_directive("pci bootstraps removed.")
        with rulesets = list_bootstrap(appECI); 
    };
    removePCIcallback = defaction(appECI,PCIcallbacks){
      PCIcallbacks =( PCIcallbacks || []).append(PCIcallbacks);
      boot = PCIcallbacks.map(function(url) { pci:remove_callback(appECI, url); }).klog(">>>>>> callback remove result >>>>>>>");
      send_directive("pci callback removed.")
        with rulesets = pci:list_callback(appECI);
    };
        get_my_apps = function(){
              ent:apps
          };
          get_registry = function(){
            app:appRegistry;
          };
          get_app = function(appECI){
            (app:appRegistry{appECI}).delete(["appSecret"])
          };
          get_secret = function(appECI){
            app:appRegistry{[appECI, "appSecret"]}
          };
          list_bootstrap = function(appECI){
            pci:list_bootstrap(appECI);
          };
          get_appinfo = function(appECI){
            pci:get_appinfo(appECI);
          };
          list_callback = function(appECI){
            pci:list_callback(appECI);
          };
		  
	//-------------------- Picos --------------------
  accountProfile = function() {
    profile = pci:get_profile(currentSession()).defaultsTo("error",standardError("undefined"))
    .put( ["oauth_eci"], meta:eci() );
    {
     'status' : (profile != "error"),
     'profile'  : profile
    }
  }
  currentSession = function() {
    pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
  };

	children = function() {
		{
			'status' : true,
			'children' : ent:children
		}
	}
	parent = function() {
		{
			'status' : true,
			'parent' : ent:parent
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
			"b507199x5.dev"
		]
	};
	picoFactory = function(myEci, protos) {
		newPico = pci:new_cloud(myEci);
		a = pci:new_ruleset(newPico, prototypes{"core"});
		b = protos.map(function(x) {pci:new_ruleset(newPico, prototypes{x});});
		newPico;
	}

  //-------------------- Subscriptions ----------------------
    subscriptions = function() { 
      subscriptions = ent:subscriptions.defaultsTo("error",standardError("undefined"));
      {
        'status' : (subscriptions != "error"),
        'subscriptions'  : subscriptions
      }
    }
    outGoing = function() { 
      pending = ent:pending_outgoing.defaultsTo("error",standardError("undefined"));
      {
        'status' : (pending != "error"),
        'subscriptions'  : pending
      }
    }
    incoming = function() { 
      pending = ent:pending_incoming.defaultsTo("error",standardError("undefined"));
      {
        'status' : (pending != "error"),
        'subscriptions'  : pending
      }
    }
    createBackChannel = function(name,namespace,attrs){ // should this be a function? we use this block of code a few times but its a mutator
        options = {
          'name' : name, // generate name and check if its unique
          'eci_type' : namespace,
          'attributes' : attrs
          //'policy' : ,
        };

        user = currentSession();
        backChannel = pci:new_eci(user, options);
        backChannel_b = backChannel{"cid"}.defaultsTo("", standardError("pci session_token failed"));  // cant find a way to move this out of pre and still capture backChannel
        backChannel_b;
    }
  //-------------------- Scheduled ----------------------
    schedules = function() { 
      sched_event_list = event:get_list().defaultsTo("error",standardError("undefined"));
      {
        'status' : (sched_event_list != "error"),
        'schedules'  : sched_event_list
      }

    }
    scheduleHistory = function(id) { 
      sched_event_history = event:get_history(id).defaultsTo("error",standardError("undefined"));
      {
        'status' : (sched_event_history != "error"),
        'history'  : sched_event_history
      }
    
    }
  
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
  //defactions
  //Rules
  //-------------------- Rulesets --------------------
  rule RegisterRuleset {
    select when nano_manager ruleset_registration_requested
    pre {
      rulesetURL= event:attr("rulesetURL").defaultsTo("", standardError("missing event attr rids"));
      //description = event:attr("description")defaultsTo("", ">>  >> ");
      //flush_code = event:attr("flush_code")defaultsTo("", ">>  >> ");
      //version = event:attr("version")defaultsTo("", ">>  >> ");
      //username = event:attr("username")defaultsTo("", ">>  >> ");
      //password = event:attr("password")defaultsTo("", ">>  >> ");
    }
    if( rulesetURL neq "" ) then// is this check redundant??
    {// do we need to check for a url or is it done on a different level?? like if (rulesetURL != "")
      rsm:register(rulesetURL) setting (rid);// rid is empty? is it just created by default
       // (description != "") => description = description |  //ummm .....
       // flush_code = 
       // version = //alias ? 
       // username = //??
       // password = //??
    }
    fired {
      log (standardOut("success"));
    }
    else{
      log""
    }
  }
  rule DeleteRuleset {
    select when nano_manager ruleset_deletion_requested
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rids"));
    }
    //if(Ruleset(){"status"} != "null" ) then// is this check redundant??
    {
      rsm:delete(rid); 
    }
    fired {
      log (standardOut("success Deleted #{rid}"));
      log ">>>>  <<<<";
    }
    else{
      log ">>>> #{rid} not found "; 
    }
  }
  rule FlushRulesets {
    select when nano_manager ruleset_flush_requested
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
    }
    if(rid.length() > 0 ) then // redundant??
    {
      rsm:flush(rid); 
    }
    fired {
      log (standardOut("success flushed #{rid}"));
      log ">>>>  <<<<"
    }
    else {
      log ">>>> failed to flush #{rid} <<<<"

    } 
  }
  rule RelinkRuleset {
    select when nano_manager ruleset_relink_requested
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
      log (standardOut("success"));
      log ""
    }
    else{
      log ""
    }
  }  
  rule InstallRuleset {// should this handle multiple rulesets or a single one
    select when nano_manager ruleset_install_requested
    pre {
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    if(rids neq "") then { // should we be valid checking?
      install(eci, ridlist);
    }
    fired {
      log (standardOut("success installed rids #{rids}"));
      log(">> successfully  >>");
          } 
    else {
      log(">> could not install rids #{rids} >>");
    }
  }
  rule UninstallRuleset { // should this handle multiple uninstalls ??? 
    select when nano_manager ruleset_uninstall_requested
    pre {
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    { 
      uninstall(eci,ridlist);
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

  rule UpdateChannelAttributes {
    select when nano_manager channel_attributes_update_requested
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
      attributes = event:attr("attributes").defaultsTo("error", standardError("undefined"));
      attrs = attributes.split(re/;/);
      //attrs = attributes.decode();
      channels = Channels();
    }
    if(channels{"channel_id"} neq "" && attributes neq "error") then { // check?? redundant????
      updateAttrs(channel_id,attributes);
    }
    fired {
      log (standardOut("success updated channel #{channel_id} attributes"));
      log(">> successfully >>");
    } 
    else {
      log(">> could not update channel #{channel_id} attributes >>");
    }
  }

  rule UpdateChannelPolicy {
    select when nano_manager channel_policy_updat_requested // channel_policy_update_requested
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
      policy = event:attr("policy").defaultsTo("error", standardError("undefined"));// policy needs to be a map, do we need to cast types?
      channels = Channels();
    }
    if(channels{"channelID"} neq "" && policy neq "error") then { // check?? redundant?? whats better??
      updatePolicy(channel_id, policy);
    }
    fired {
      log (standardOut("success updated channel #{channel_id} policy"));
      log(">> successfully  >>");
    }
    else {
      log(">> could not update channel #{channel_id} policy >>");
    }

  }
  rule DeleteChannel {
    select when nano_manager channel_delete_requested
    pre {
      channelID = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
    }
    {
      deleteEci(channelID);
    }
    fired {
      log (standardOut("success deleted channel #{channelID}"));
      log(">> successfully  >>");
          } else {
      log(">> could not delete channel #{channelID} >>");
          }
        }
  rule CreateChannel {
    select when nano_manager channel_create_requested
    pre {
     // channels = Channels().defaultsTo({}, standardError("list of installed channels undefined")); // why do we do this ????
      channelName = event:attr("channelName").defaultsTo("", standardError("missing event attr channels"));
     // user = currentSession();
      user = pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
      
      options = {
        'name' : channelName//,
        //'eci_type' : ,
        //'attributes' : ,
        //'policy' : ,
      };
          }
    if(channelName.match(re/\w[\w\d_-]*/) && user neq "") then {
      createEci(user, options);
      send_directive("Created #{channelName}");
      //with status= true; // should we send directives??
          }
    fired {
      log (standardOut("success created channels #{channelName}"));
      log(">> successfully  >>");
          } 
    else {
      log(">> could not create channels #{channelName} >>");
          }
    }
  
 /* //-------------------- Clients --------------------
  rule AuthorizeClient {
    select when nano_manager client_authorized

  }
  rule RemoveClient {
    select when nano_manager client_removed

  }
  rule UpdateClient {
    select when nano_manager client_updated

  }
  */
  //-------------------- Picos ----------------------
	rule createChild {
		select when nano_manager child_creation_requested
		
		pre {
			childName = event:attr("name").defaultsTo("", standardError("No name for new pico"));
			childAttrs = event:attr("attributes").defaultsTo("{}"); //string representation of a hash, will be decoded in child
			childProtos = event:attr("prototypes").defaultsTo([]);
			
			myName = ent:name;
			myEci = meta:eci();
			myInfo = {"#{myName}" : myEci};
			
			newPico = (childName neq "") => picoFactory(myEci, childProtos) | "";
			
			myChildren = ent:children.put({"#{childName}" : newPico});
		}
		
		if (childName neq "") then
		{
			event:send({"cid":newPico}, "nano_manager", "child_created")
				with attrs = {"parent": myInfo,
								"name": childName,
								"attributes": childAttrs
							};
		}
		
		fired {
			set ent:children myChildren;
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
  //      "backChannel"  :"" ,
  //      "attrs"  :
  //    }
  //  }
  //
  // ========================================================================
  rule requestSubscription {// need to change varibles to snake case.
    select when nano_manager subscription_requested
   pre {
      name   = event:attr("channelName").defaultsTo("orphan", standardError("channelName"));
      namespace     = event:attr("namespace").defaultsTo("shared", standardError("namespace"));
      relationship  = event:attr("relationship").defaultsTo("peer-peer", standardError("relationship"));
      targetChannel = event:attr("targetChannel").defaultsTo("NoTargetChannel", standardError("targetChannel"));
      attrs      = event:attr("attrs").defaultsTo({}, standardError("attrs"));
      //attrs_b = attrs.decode();
      // --------------------------------------------
      // extract roles of the relationship
      roles   = relationship.split(re/\-/);
      myRole  = roles[0];
      youRole = roles[1];
      
      subscription_map = {
            "cid" : targetChannel
      };

      backChannel = createBackChannel(name,namespace,{"namespace":namespace,"role" : myRole });
            // build pending subscription entry
      pendingEntry = {
        "name"  : name,
        "namespace"    : namespace,
        "relationship" : myRole,
        "backChannel"  : backChannel,
        "targetChannel"  : targetChannel,
        "attrs"     : attrs
      }.klog("pending subscription"); 
    }
    if(targetChannel neq "NoTargetChannel" &&
     backChannel neq "") 
    then
    {
      event:send(subscription_map, "nano_manager", "add_pending_subscription_requested") // send request
        with attrs = {
          "name"  : name,
          "namespace"    : namespace,
          "relationship" : youRole,
          "eventChannel"  : backChannel,
          "attrs"     : attrs
        };
    }
    fired {
      log (standardOut("success"));
      log(">> successful >>");
      raise nano_manager event add_pending_subscription_requested
        with 
        name = name
        and namespace = namespace
        and relationship = myRole
        and backChannel = backChannel
        and eventChannel = targetChannel
        and attrs = subAttrs.decode();
    } 
    else {
      log(">> failure >>");
    }
  }

  rule addPendingSubscription { // depends on wether or not a backChannel is being passed as an attribute
    select when nano_manager add_pending_subscription_requested
   pre {
      pendingEntry = {
        "name"  : event:attr("name").defaultsTo("", standardError("")),
        "namespace"    : event:attr("namespace").defaultsTo("", standardError("")),
        "relationship" : event:attr("relationship").defaultsTo("", standardError("")),
        "backChannel"  : event:attr("backChannel").defaultsTo("", standardError("")),
        "eventChannel"  : event:attr("eventChannel").defaultsTo("", standardError("")),
        "attrs"     : event:attr("attrs").defaultsTo("", standardError(""))
      }.klog("pending subscription"); 
      
      backChannel = pendingEntry{"backChannel"}.defaultsTo("", standardError("no backChannel"));
      eventChannel = pendingEntry{"eventChannel"}.defaultsTo("", standardError("no eventChannel"));
    }
    if(backChannel eq "") // no backChannel means its incoming
    then
    {
     noop();
    }
    fired { //can i put multiple lines in a single guard?????????????????
      log(">> successful pending incoming >>");
      raise nano_manager event subscription_incoming_pending;
      set ent:pending_incoming{eventChannel} pendingEntry;
      log(">> failure >>") if (eventChannel eq "");
    } 
    else { 
      log (standardOut("success pending outgoing >>"));
      raise nano_manager event subscription_outgoing_pending;
      set ent:pending_outgoing{backChannel} pendingEntry;
    }
  }

  
  rule approvePendingSubscription {
    select when nano_manager approve_pending_subscription_requested
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      
      backChannel_b = createBackChannel(pendingsubscription{'name'},
        pendingsubscription{'namespace'},
        {"namespace":namespace,"role" : myRole });

      pendingsubscription = ent:pending_incoming{eventChannel};
      // create subscription for both picos
      mySubscription = ((pendingsubscription).put(["backChannel"],backChannel_b)).klog("subscription"); /// needs standard output
      yourSubscription = ((mySubscription).put(["backChannel"],mySubscription{"eventChannel"})).klog("Your subscription A"); /// needs standard output
      yourSubscriptionB = ((yourSubscription).put(["eventChannel"],backChannel_b)).klog("Your subscription B"); /// needs standard output
      subscription_map = {
            "cid" : eventChannel
      };
    }
    if (mySubscription{"backChannel"} neq "") then
    {
      event:send(subscription_map, "nano_manager", "remove_pending_subscription_requested"); 
      event:send(subscription_map, "nano_manager", "add_subscription_requested")
       with attrs = yourSubscriptionB;
    }
    fired 
    {
      log (standardOut("success"));
      raise nano_manager event remove_pending_subscription_requested 
      with eventChannel = eventChannel;
      raise nano_manager event add_subscription_requested
      attributes mySubscription;
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
          "namespace"    : event:attr("namespace").defaultsTo( "Nonamespace", standardError("")),
          "relationship" : event:attr("relationship").defaultsTo( "Norelationship", standardError("")),
          "eventChannel" : event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError("")),
          "backChannel" : event:attr("backChannel").defaultsTo( "NoBackChannel", standardError("")),
          "attrs"     : attrs
        }
     
    }
    if (subscription{"backChannel"} neq "NoBackChannel") then
    {
     noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_manager event subscription_added
      with backChannel = subscription{"backChannel"};
      set ent:subscriptions{subscription{"backChannel"}}  subscription;
          } 
    else {
      log(">> failure >>");
    }
  }
  rule removePendingSubscription{// ugly attempt to combine two rules.
    select when nano_manager remove_pending_subscription_requested
    pre{
      out = event:attr("type_of_subscription").defaultsTo( "No_type_of_subscription", standardError("type_of_subscription"));
      backChannel = meta:eci();
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      path = (eventChannel eq "NoEventChannel");
      pending = path =>
             ( ent:pending_outgoing{backChannel}.defaultsTo( "No pending outgoing", standardError("")) )
           | ( ent:pending_incoming{eventChannel}.defaultsTo( "No pending incoming", standardError("")) );
    }
    if (path) then 
    {
      noop();
    }
    fired 
    {
      log (standardOut("success removing outgoing"));
      raise nano_manager event removed_pending_out;
      clear ent:pending_outgoing{backChannel};
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
      clear ent:pending_incoming{eventChannel} if (pending_incoming neq "No pending incoming");
      log(">> failure subscription request not found >>") if (pending_incoming eq "No pending incoming");
    }
  }
 rule rejectPendingSubscription {
    select when nano_manager reject_incoming_subscription_requested
           or   nano_manager cancel_outgoing_subscription_requested

    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
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
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError("no backChannel"));
    }
    if(backChannel neq "No backChannel") then
    {
      noop();
    }
    fired {
      log (standardOut("success"));
      raise nano_manager event subscription_unsubscribed;
      // clean up
      raise nano_manager event channel_delete_requested with channel_id = backChannel;  
      clear ent:subscriptions{backChannel};
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule cancelSubscription {
    select when nano_manager cancel_subscription__requested
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "No eventChannel", standardError(""));
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError(""));
      subscription_map = {
            "cid" : eventChannel
      };
    }
    if(eventChannel neq "No eventChannel") then
    {
      event:send(subscription_map, "nano_manager", "remove_subscription_requested")
        with attrs = {
          "backChannel"  : eventChannel
        };

    }
    fired {
      raise nano_manager event remove_subscription_requested with backChannel = backChannel; 
      log (standardOut("success"));
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule SubscribeReset {// for testing purpose, will not be in production 
      select when nano_manager subscriptionsReset
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

  ///-------------------- Scheduled ----------------------
  rule DeleteScheduledEvent {
    select when nano_manager delete_scheduled_event_requested
    pre{
      sid = event:attr("sid").defaultsTo("", standardError("missing event attr sid"));
    }
    if (sid neq "") then
    {
      event:delete(sid);
    }
    fired {
      log (standardOut("success"));
          } 
    else {
      log(">> failure >>");
    }
  }  
  rule ScheduleEvent {
    select when nano_manager schedule_event_requested
    pre{
      eventtype = event:attr("eventtype").defaultsTo("error", standardError("missing event attr eventtype"));
      time = event:attr("time").defaultsTo("error", standardError("missing event attr type"));
      do_main = event:attr("do_main").defaultsTo("error", standardError("missing event attr type"));
      timespec = event:attr("timespec").defaultsTo("{}", standardError("missing event attr timespec"));
      date_time = event:attr("date_time").defaultsTo("error", standardError("missing event attr type"));
      attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
      attr = attributes.decode();

    }
    if (type eq "single" && type neq "error" ) then
    {
      noop();
    }
    fired {
      log (standardOut("success single"));
      schedule do_main event eventype at date_time attributes attr ;
          } 
    else {
      log (standardOut("success multiple"));
      schedule do_main event eventype repeat timespec attributes attr ;
    }
  }  
}