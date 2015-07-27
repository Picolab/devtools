
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
    subscriptions, outGoing, incoming //subscription
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
	
	
  //-------------------- Rulesets --------------------
    registered = function() {
      eci = meta:eci();
        rulesets = rsm:list_rulesets(eci).defaultsTo({},standardError("undefined"));
        rulesetGallery = rulesets.map( function(rid){
          ridInfo = rsm:get_ruleset( rid ).defaultsTo({},standardError("undefined"));
          ridInfo
        }).defaultsTo("wrong",standardError("undefined"));
        {
          'status' : (rulesetGallery neq "wrong"),
          'rulesets' : rulesetGallery          
        };
    }
    singleRuleset = function(rid) { 
      eci = meta:eci();
      results = Registered().defaultsTo({},standardError("undefined"));
      results = results{"rulesets"}.defaultsTo({},standardError("undefined"));
      result = results.filter( function(rule_set){rule_set{"rid"} eq rid } ).defaultsTo( "wrong",standardError("undefined"));
      {
        'status' : (result neq "wrong"),
        'ruleset' : result[0]
      };
    }
    installed = function() {
      eci = meta:eci().klog("eci: ");
      results = pci:list_ruleset(eci).klog("results of pci list_ruleset");//defaultsTo("wrong",standardError("pci list_ruleset failed"));  
      rids = results{'rids'}.defaultsTo("wrong",standardError("no hash key rids"));
      {
       'status'   : (rids neq "wrong"),
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
      channels = results{'channels'}.defaultsTo("wrong",standardError("undefined")); // list of channels if list_eci request was valid
      {
        'status'   : (channels neq "wrong"),
        'channels' : channels
      };
    }
    attributes = function(eci) {
      results = pci:get_eci_attributes(eci).defaultsTo("wrong",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "wrong"),
        'Attributes' : results
      };
    }
    policy = function(eci) {
      results = pci:get_eci_policy(eci).defaultsTo("wrong",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "wrong"),
        'Policy' : results
      };
    }
    type = function(channel_id) { // untested!!!!!!!!!!!!!!!!!!!
      channels = Channels().defaultsTo("wrong",">> undefined >>");

      getType = function(channel_id,channels) {
        channels = channels{"channels"}.defaultsTo("undefined",standardError("undefined"));
        channel = channels.filter( function(channel){channel{"cid"} eq channel_id } ).defaultsTo( "wrong",standardError("undefined"));
        channel = channel[0];
        type = channel{"type"};
        temp = (type.typeof() eq "str" ) => type | type.typeof() eq "array" => type[0] |  type.keys();
        type2 = (temp.typeof() eq "array") => temp[0] | temp;   
        type2;
      };
      type = ((channels neq "wrong") && (channels neq {} )) => getType() | "wrong";
      {
        'status'   : (type neq "wrong"),
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
      clients = pci:get_authorized(eci).defaultsTo("wrong",standardError("undefined")); // pci does not have this function yet........
      //krl_struct = clients.decode() // I dont know if we needs decode
     // .klog(">>>>krl_struct")
     // ;
      {
        'status' : (clients != "wrong"),
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
    profile = pci:get_profile(currentSession()).defaultsTo("wrong",standardError("undefined"))
    .put( ["oauth_eci"], meta:eci() );
    {
     'status' : (profile != "wrong"),
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
    subscriptions = function(namespace, relationship) { 
      subscriptions = ent:subscriptions.defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (subscriptions != "wrong"),
        'subscriptions'  : subscriptions
      }
    }
    outgoing = function() { 
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
    createBackChannel = function(name,namespace,attrs){
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
      sched_event_list = event:get_list().defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (sched_event_list != "wrong"),
        'schedules'  : sched_event_list
      }

    }
    scheduleHistory = function(id) { 
      sched_event_history = event:get_history(id).defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (sched_event_history != "wrong"),
        'history'  : sched_event_history
      }
    
    }
  
  //-------------------- error handling ----------------------


    standardError = function(message) {
      error = ">> error: " + message + " >>";
      error
    }

  }
  //defactions
  //Rules
  //-------------------- Rulesets --------------------
  rule RegisterRuleset {
    select when nano_manager ruleset_registered
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
      log ">>>> <<<<";
    }
    else{
      log""
    }
  }
  rule DeleteRuleset {
    select when nano_manager ruleset_deleted
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rids"));
    }
    //if(Ruleset(){"status"} != "null" ) then// is this check redundant??
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
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
    }
    if(rid.length() > 0 ) then // redundant??
    {
      rsm:flush(rid); 
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
      log ""
    }
    else{
      log ""
    }
  }  
  rule InstallRuleset {// should this handle multiple rulesets or a single one
    select when nano_manager ruleset_installed
    pre {
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    if(rids neq "") then { // should we be valid checking?
      install(eci, ridlist);
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
      eci = meta:eci().defaultsTo({},standardError("undefined"));
      rids = event:attr("rids").defaultsTo("", ">>  >> ").klog(">> rids attribute <<");
      ridlist = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    { 
      uninstall(eci,ridlist);
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
      log(">> successfully updated channel #{channel_id} attributes >>");
    } 
    else {
      log(">> could not update channel #{channel_id} attributes >>");
    }
  }

  rule UpdateChannelPolicy {
    select when nano_manager channel_policy_updated // channel_policy_update_requested
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
      policy = event:attr("policy").defaultsTo("error", standardError("undefined"));// policy needs to be a map, do we need to cast types?
      channels = Channels();
    }
    if(channels{"channelID"} neq "" && policy neq "error") then { // check?? redundant?? whats better??
      updatePolicy(channel_id, policy);
    }
    fired {
      log(">> successfully updated channel #{channel_id} policy >>");
    }
    else {
      log(">> could not update channel #{channel_id} policy >>");
    }

  }
  rule DeleteChannel {
    select when nano_manager channel_deleted
    pre {
      channelID = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
    }
    {
      deleteEci(channelID);
    }
    fired {
      log(">> successfully deleted channel #{channelID} >>");
          } else {
      log(">> could not delete channel #{channelID} >>");
          }
        }
  rule CreateChannel {
    select when nano_manager channel_created
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
      log(">> successfully created channels #{channelName} >>");
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
  //      "attrs"  :
  //    }
  //  }
  //
  // ========================================================================
  rule request {// need to change varibles to snake case.
    select when nano_manager request_subscrition
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

      backChannel_b = createBackChannel(name,namespace,{"namespace":namespace,"role" : myRole });
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
      event:send(subscription_map, "nano_manager", "add_pending_in") // send request
        with attrs = {
          "name"  : name,
          "namespace"    : namespace,
          "relationship" : youRole,
          "eventChannel"  : backChannel_b,
          "attrs"     : attrs
        };
    }
    fired {
      log(">> successful >>");
      raise nano_manager event add_pending_out
        with 
        name = name
        and namespace = namespace
        and relationship = myRole
        and backChannel = backChannel_b
        and targetChannel = targetChannel
        and attrs = subAttrs.decode();
    } 
    else {
      log(">> failure >>");
    }
  }

  rule addPendingOut {
    select when nano_manager add_pending_out
   pre {
      backChannel = pendingEntry{"backChannel"};
      pendingEntry = {
        "name"  : event:attr("name").defaultsTo("", standardError("")),
        "namespace"    : event:attr("namespace").defaultsTo("", standardError("")),
        "relationship" : event:attr("myRole").defaultsTo("", standardError("")),
        "backChannel"  : event:attr("backChannel_b").defaultsTo("", standardError("")),
        "targetChannel"  : event:attr("targetChannel").defaultsTo("", standardError("")),
        "attrs"     : event:attr("subAttrs").defaultsTo("", standardError(""))
      }.klog("pending subscription"); 

    }
    if(pendingEntry neq "" &&
     backChannel_b neq "") 
    then
    {
     noop();
    }
    fired {
      log(">> successful >>");
      raise nano_manager event subscription_outgoing_pending;
      set ent:pending_outgoing{backChannel_b} pendingEntry;
    } 
    else {
      log(">> failure >>");
    }
  }

  rule addPendingIn {
    select when nano_manager add_pending_in
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
      log(">> successful >>");
      raise nano_manager event subscription_incoming_pending;
      set ent:pending_incoming{eventChannel} pendingApprovalEntry;
          } 
    else {
      log(">> failure >>");
    }
  }

  rule accept {
    select when nano_manager incoming_request_approved
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      pendingsubscription = ent:pending_incoming{eventChannel};
      
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
    if (subscription{"backChannel"} neq "") then
    {
      event:send(subscription_map, "nano_manager", "remove_pending_out"); 
      event:send(subscription_map, "nano_manager", "add_subscription")
       with attrs = yourSubscriptionB;
    }
    fired 
    {
      log(">> successful> >");
      raise nano_manager event remove_pending_in
      with eventChannel = eventChannel;
      raise nano_manager event add_subscription
      with backChannel = backChannel_b
      and eventChannel = eventChannel;
    } 
    else 
    {
      log(">> failure >>");
    }
  }
  rule addSubscription {
    select when nano_manager add_subscription
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
      log(">> successful> >");
      raise nano_manager event subscription_added
      with backChannel = subscription{"backChannel"};
      set ent:subscriptions{subscription{"backChannel"}}  subscription;
          } 
    else {
      log(">> failure >>");
    }
  }
  rule remove{// ugly attempt to combine two rules.
    select when nano_manager remove_pending
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
      log(">>successful removing outgoing>>");
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
      log(">>successful removing incoming>>") if (pending_incoming neq "No pending incoming");
      raise nano_manager event removed_pending_in if (pending_incoming neq "No pending incoming");
      clear ent:pending_incoming{eventChannel} if (pending_incoming neq "No pending incoming");
      log(">> failure subscription request not found >>") if (pending_incoming eq "No pending incoming");
    }
  }
  rule removeInComingRequest {
    select when nano_manager remove_pending_in
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "NoEventChannel", standardError(""));
      pendingsubscription = ent:pending_incoming{eventChannel};
    }
    if (eventChannel neq "NoEventChannel") then
    {
      noop();
    }
    fired 
    {
      log(">> successful> >");
      raise nano_manager event removed_pending_in;
      clear ent:pending_incoming{eventChannel};
    } 
    else 
    {
      log(">> failure >>");
    }
  }
  rule removeOutgoingRequest {
    select when nano_manager remove_pending_out
    pre{
      backChannel = meta:eci();
      pending_outgoing = ent:pending_outgoing{backChannel}.defaultsTo( "No pending", standardError(""));
    }
    if (pending_outgoing neq "No pending") then 
    {
      noop();
    }
    fired 
    {
      log(">> successful >>");
      raise nano_manager event removed_pending_out;
      clear ent:pending_outgoing{backChannel};
    } 
    else 
    {
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
      log(">> successful >>");
      raise nano_manager event subscription_incoming_rejected;
      clear ent:pending_incoming{eventChannel};
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
      log(">> successful >>");
      raise nano_manager event subscription_outgoing_rejected;
      // clean up your channels buddie, no loose ends....
      raise nano_manager event channel_deleted with channel_id = backChannel;  
      clear ent:pending_outgoing{backChannel};
    } 
    else {
      log(">> failure >>");
    }
  }
  rule removeIncomingRequest {
    select when nano_manager incoming_request_rejected_by_origin
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "No eventChannel", standardError(""));
    }
    if(eventChannel neq "No eventChannel") then
    {
      noop();
    }
    fired {
      log(">> successful >>");
      raise nano_manager event subscription_incoming_rejected;
      clear ent:pending_incoming{eventChannel};
          } 
    else {
      log(">> failure >>");
    }
  }
  rule removeOutgoingRequest {
    select when nano_manager outgoing_request_rejected
    pre{
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError(""));
    }
    if(backChannel neq "No backChannel") then
    {
      noop();
    }
    fired {
      log(">> successful >>");
      raise nano_manager event subscription_outgoing_rejected;
      // clean up..
      raise nano_manager event channel_deleted with channel_id = backChannel;  
      clear ent:pending_outgoing{backChannel};
          } 
    else {
      log(">> failure >>");
    }
  } 
    rule Unsubscribe {
    select when nano_manager unsubscribed
    pre{
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError("no backChannel"));

    }
    if(backChannel neq "No backChannel") then
    {
      noop();
    }
    fired {
      log(">> successful >>");
      raise nano_manager event subscription_unsubscribed;
      // clean up
      raise nano_manager event channel_deleted with channel_id = backChannel;  
      clear ent:subscriptions{backChannel};
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule INITUnsubscribe {
    select when nano_manager init_unsubscribed
    pre{
      eventChannel = event:attr("eventChannel").defaultsTo( "No eventChannel", standardError(""));
      backChannel = event:attr("backChannel").defaultsTo( "No backChannel", standardError(""));
      subscription_map = {
            "cid" : eventChannel
      };
    }
    if(eventChannel neq "No eventChannel") then
    {
      event:send(subscription_map, "nano_manager", "unsubscribed")
        with attrs = {
          "backChannel"  : eventChannel
        };

    }
    fired {
      raise nano_manager event unsubscribed with backChannel = backChannel; 
      log(">> successful >>");
          } 
    else {
      log(">> failure >>");
    }
  } 
  rule SubscribeReset {
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
  rule DeleteScheduled {
    select when nano_manager scheduled_deleted
    pre{
      sid = event:attr("sid").defaultsTo("", standardError("missing event attr sid"));
    }
    if (sid neq "") then
    {
      event:delete(sid);
    }
    fired {
      log(">> successful >>");
          } 
    else {
      log(">> failure >>");
    }
  }  
  rule CreateScheduled {
    select when nano_manager scheduled_created
    pre{
      eventtype = event:attr("eventtype").defaultsTo("wrong", standardError("missing event attr eventtype"));
      time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
      do_main = event:attr("do_main").defaultsTo("wrong", standardError("missing event attr type"));
      timespec = event:attr("timespec").defaultsTo("{}", standardError("missing event attr timespec"));
      date_time = event:attr("date_time").defaultsTo("wrong", standardError("missing event attr type"));
      attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
      attr = attributes.decode();

    }
    if (type eq "single" && type neq "wrong" ) then
    {
      noop();
    }
    fired {
      log(">> single >>");
      schedule do_main event eventype at date_time attributes attr ;
          } 
    else {
      log(">> multiple >>");
      schedule do_main event eventype repeat timespec attributes attr ;
    }
  }  
}