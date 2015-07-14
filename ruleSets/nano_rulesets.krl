
ruleset b507199x9 {
  meta {
    name "nano_rulesets"
    description <<
      Nano Rulesets
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials

    provides registered, singleRuleset, installed, describeRules

    sharing on

  }

  global {
    //functions
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
  }
  //Rules
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
    if( rulesetURL neq "" ) then// is this check redundent??
    {// do we nee to check for a url or is it done on a different level?? like if (rulesetURL != "")
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
    //if(Ruleset(){"status"} != "null" ) then// is this check redundent??
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
    if(rid.length() > 0 ) then // redundent??
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
      pci:new_ruleset(eci, ridlist);
      send_directive("installed #{rids}");
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
      pci:delete_ruleset(eci, ridlist);
      send_directive("uninstalled #{rids}");
    }
    fired {
      log(">> successfully uninstalled rids #{rids} >>");
          } 
    else {
      log(">> could not uninstall rids #{rids} >>");
    }
  }

}