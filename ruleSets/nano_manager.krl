
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
    apps, get_app,type,/*testing*/list_bootstrap, get_appinfo, list_callback, //apps
    accountProfile, //pico
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
		a = pci:new_ruleset(eci, ["a169x625.prod","b507199x1.dev","b507199x5.dev","a169x676.prod","a16x129.dev","b507199x0.dev","b16x29.prod","507199x5.dev","b16x24"]);
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
        chan = channel[0];
        type = chan{"type"};
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
  //-------------------- Apps --------------------
    apps = function() { 
      eci = meta:eci();
      apps = pci:list_apps(eci).defaultsTo("error",standardError("undefined"));
      {
        'status' : (apps != "error"),
        'apps' : apps
      }
    }    
    get_app = function(appECI){
      apps = apps().defaultsTo("error",standardError("apps"));
      app = apps{appECI}.defaultsTo("error",standardError("app"));
     // app = (apps{appECI}).delete(["appSecret"]).defaultsTo("error",standardError("app"))
      {
        'status' : (app != "error"),
        'app' : app
      }
    }
    list_bootstrap = function(appECI){
      pci:list_bootstrap(appECI);
    }
    get_appinfo = function(appECI){
      pci:get_appinfo(appECI);
    }
    list_callback = function(appECI){
      pci:list_callback(appECI);
    }
    addPCIbootstraps = defaction(appECI,bootstrapRids){
      boot = bootstrapRids.map(function(rid) { pci:add_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap add result >>>>>>>");
      send_directive("pci bootstraps updated.")
        with rulesets = list_bootstrap(appECI); // is this working?
    }
    removePCIbootstraps = defaction(appEC,IbootstrapRids){
      boot = bootstrapRids.map(function(rid) { pci:remove_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap removed result >>>>>>>");
      send_directive("pci bootstraps removed.")
        with rulesets = list_bootstrap(appECI); 
    }
    removePCIcallback = defaction(appECI,PCIcallbacks){
      PCIcallbacks =( PCIcallbacks || []).append(PCIcallbacks);
      boot = PCIcallbacks.map(function(url) { pci:remove_callback(appECI, url); }).klog(">>>>>> callback remove result >>>>>>>");
      send_directive("pci callback removed.")
        with rulesets = pci:list_callback(appECI);
    }
    update_app = defaction(app_eci,app_data,bootstrap_rids){
      //remove all 
      remove_defact = removePCIcallback(app_eci);
      remove_appinfo = pci:remove_appinfo(app_eci);
      remove_defact = removePCIbootstraps(app_eci);
      // add new 
      add_callback = pci:add_callback(app_eci, app_data{"appCallbackURL"}); 
      add_info = pci:add_appinfo(app_eci,{
        "icon": app_data{"appImageURL"},
        "name": app_data{"appName"},
        "description": app_data{"appDescription"},
        "info_url": app_data{"info_page"},
        "declined_url": app_data{"appDeclinedURL"}
      });
      addPCIbootstraps(app_eci,bootstrap_rids);
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
    //has to be a function, but breaks methodaligy 
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
  rule registerRuleset {
    select when nano_manager ruleset_registration_requested
    pre {
      ruleset_url= event:attr("ruleset_url").defaultsTo("", standardError("missing event attr rids"));
      //description = event:attr("description")defaultsTo("", ">>  >> ");
      //flush_code = event:attr("flush_code")defaultsTo("", ">>  >> ");
      //version = event:attr("version")defaultsTo("", ">>  >> ");
      //username = event:attr("username")defaultsTo("", ">>  >> ");
      //password = event:attr("password")defaultsTo("", ">>  >> ");
    }
    if( ruleset_url neq "" ) then// is this check redundant??
    {// do we need to check for a url or is it done on a different level?? like if (rulesetURL != "")
      rsm:register(ruleset_url) setting (rid);// rid is empty? is it just created by default
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
  rule deleteRuleset {
    select when nano_manager ruleset_deletion_requested
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
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
  rule flushRulesets {
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
  rule relinkRuleset {
    select when nano_manager ruleset_relink_requested
    pre {
      rid = event:attr("rid").defaultsTo("", standardError("missing event attr rid"));
      new_url = event:attr("url").defaultsTo("", standardError("missing event attr url")); 
    }
    if(rid neq "") then // redundent??
    {// do we nee to check for a url or is it done on a different level?? like if (rulesetURL != "") or should we check for the rid 
      rsm:update(rid) setting(updatedSuccessfully)// we can change varible name?
      with 
        uri = new_url;
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

  rule updateChannelPolicy {
    select when nano_manager update_channel_policy_requested // channel_policy_update_requested
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
  rule deleteChannel {
    select when nano_manager channel_deletion_requested
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
    }
    {
      deleteEci(channel_id);
    }
    fired {
      log (standardOut("success deleted channel #{channel_id}"));
      log(">> successfully  >>");
          } else {
      log(">> could not delete channel #{channel_id} >>");
          }
        }
  rule createChannel {
    select when nano_manager channel_creation_requested
    pre {
     // channels = Channels().defaultsTo({}, standardError("list of installed channels undefined")); // why do we do this ????
      channel_name = event:attr("channel_name").defaultsTo("", standardError("missing event attr channels"));
      user = currentSession();
      //user = pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
      
      options = {
        'name' : channel_name//,
        //'eci_type' : ,
        //'attributes' : ,
        //'policy' : ,
      };
          }
    if(channel_name.match(re/\w[\w\d_-]*/) && user neq "") then {
      createEci(user, options);
      send_directive("Created #{channel_name}"); // do we need a directive?
      //with status= true; // should we send directives??
          }
    fired {
      log (standardOut("success created channels #{channel_name}"));
      log(">> successfully  >>");
          } 
    else {
      log(">> could not create channels #{channel_name} >>");
          }
    }
  
  //-------------------- Apps --------------------
      rule authorizeApp {
          select when nano_manager authorize_app_requested
          pre {
              info_page = event:attr("info_page").defaultsTo("", standardOut("missing event attr info_page"));
              bootstrap_rids = event:attr("bootstrap_rids").defaultsTo("", standardOut("missing event attr bootstrap_rids"));
              app_name = event:attr("app_name").defaultsTo("error", standardOut("missing event attr app_name"));
              app_description = event:attr("app_description").defaultsTo("", standardOut("missing event attr app_description"));
              app_image_url = event:attr("app_image_url").defaultsTo("", standardOut("missing event attr app_image_url"));
              app_callback_url_attr = event:attr("app_callback_url").defaultsTo("error", standardOut("missing event attr app_callback_url"));
              app_callback_url = app_callback_url_attr.split(re/;/).defaultsTo("error", standardOut("split callback failure"));
              app_declined_url = event:attr("app_declined_url").defaultsTo("", standardOut("missing event attr app_declined_url"));
              bootstrap = bootstrap_rids.split(re/;/).defaultsTo("", standardOut("split bootstraps failure"));
              pico_id = meta:eci();
          }
          if (
            app_name neq "error" &&
            app_callback_url neq "error"
          ) 
          then{
            pci:register_app(pico_id) setting(token, secret)
          with name = app_name and
              icon = app_image_url and
              description = app_description and
              info_url = info_page and
              declined_url = app_declined_url and
              callbacks = app_callback_url and 
              bootstrap = bootstrap;
          }
          fired {
          log (standardOut("success authenticated app #{app_name}"));
          }
          else {
              log( "failure");
          }
      }

      rule removeApp {
          select when nano_manager remove_app_requested
          pre {
              identifier = event:attr("app_id").defaultsTo("", standardOut("missing event attr app_id").klog(">>>>>> app_id >>>>>>>"));
          }
          if (identifier != "") then {
            pci:delete_app(identifier);
          }
          fired {
          log (standardOut("success deauthenticated app with token #{identifier}"));
          }
          else {
              log( "failure");
          }
      }

      rule updateApp {
        select when nano_manager update_app_requested
          pre {
              app_data_attrs={
                  "info_page": event:attr("info_page").defaultsTo("", standardOut("missing event attr info_page")),
                  "bootstrap_rids": event:attr("bootstrap_rids").defaultsTo("", standardOut("missing event attr bootstrap_rids")),
                  "app_name": event:attr("app_name").defaultsTo("", standardOut("missing event attr app_name")),
                  "app_description": event:attr("app_description").defaultsTo("", standardOut("missing event attr app_description")),
                  "app_image_url": event:attr("app_image_url").defaultsTo("", standardOut("missing event attr app_image_url")),
                  "app_call_back_url": event:attr("app_call_back_url").defaultsTo("", standardOut("missing event attr app_call_back_url")),
                  "app_declined_url": event:attr("app_declined_url").defaultsTo("", standardOut("missing event attr app_declined_url"))
              };
            identifier = event:attr("app_id").klog(">>>>>> token >>>>>>>");
            old_apps = pci:list_apps(meta:eci());
            old_app = old_apps{app_identifier}.defaultsTo("error", standardOut("oldApp not found")).klog(">>>>>> old_app >>>>>>>");
            app_data = (app_data_attrs)// keep app secrets for update// need to see what the real varibles are named........
                  .put(["appSecret"], old_app{"appSecret"}.defaultsTo("error", standardOut("no secret found")))
                  .put(["appECI"], old_app{"appECI"}) //------------------------------------------------/ whats this used for????????????
                  ;
            bootstrap_rids = app_data{"bootstrap_rids"}.split(re/;/).klog(">>>>>> bootstrap in >>>>>>>");
          }
          if ( 
            old_app neq "error" &&
            app_data{"app_name"} neq "error" &&
            app_data{"appSecret"} neq "error" &&
            app_data{"app_call_back_url"} neq "error" 
          ) then{
        update_app(identifier,app_data,bootstrap_rids);
          }
          fired {
          log (standardOut("success update app with #{app_data}"));
          }
          else {
          log (standardOut("failure"));
          }
      }
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
      name   = event:attr("name").defaultsTo("standard", standardError("channel_name"));
      name_space     = event:attr("name_space").defaultsTo("shared", standardError("name_space"));
      relationship  = event:attr("relationship").defaultsTo("peer-peer", standardError("relationship"));
      target_channel = event:attr("target_channel").defaultsTo("no_target_channel", standardError("target_channel"));
      attrs      = event:attr("attrs").defaultsTo({}, standardError("attrs"));
      //attrs_b = attrs.decode();

      // extract roles of the relationship
      roles   = relationship.split(re/\-/);
      my_role  = roles[0];
      your_role = roles[1];
      
      subscription_map = {
            "cid" : target_channel
      };
      //create call back for subscriber
      back_channel = createBackChannel(name,name_space,{"name_space":name_space,"role" : my_role });
      
      // build pending subscription entry
      pending_entry = {
        "name"  : name,
        "name_space"    : name_space,
        "relationship" : my_role,
        "back_channel"  : back_channel,
        "target_channel"  : target_channel,
        "attrs"     : attrs
      }.klog("pending subscription"); 
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
          "event_channel"  : back_channel,
          "attrs"     : attrs
        };
    }
    fired {
      log (standardOut("success"));
      log(">> successful >>");
      raise nano_manager event add_pending_subscription_requested
        with 
        name = name
        and name_space = name_space
        and relationship = my_role
        and back_channel = back_channel
        and event_channel = target_channel
        and attrs = attrs;
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
        "relationship" : event:attr("relationship").defaultsTo("", standardError("relationship")),
        "back_channel"  : event:attr("back_channel").defaultsTo("incoming", standardError("back_channel")),
        "event_channel"  : event:attr("event_channel").defaultsTo("", standardError("event_channel")),
        "attrs"     : event:attr("attrs").defaultsTo("", standardError(""))
      }.klog("pending subscription"); 
      
      back_channel = pending_entry{"back_channel"}.defaultsTo("", standardError("no back_channel"));
      event_channel = pending_entry{"event_channel"}.defaultsTo("", standardError("no event_channel"));
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
          "back_channel" : event:attr("back_channel").defaultsTo( "no_back_channel", standardError("")),
          "attrs"     : attrs
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
      raise nano_manager event channel_delete_requested with channel_id = back_channel;  
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
      event_type = event:attr("event_type").defaultsTo("error", standardError("missing event attr event_type"));
      time = event:attr("time").defaultsTo("error", standardError("missing event attr type"));
      do_main = event:attr("do_main").defaultsTo("error", standardError("missing event attr type"));
      time_spec = event:attr("time_spec").defaultsTo("{}", standardError("missing event attr time_spec"));
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