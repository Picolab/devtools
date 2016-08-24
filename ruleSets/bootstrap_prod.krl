//for flushing: http://cs.kobj.net/ruleset/flush/b507199x13.prod;b507199x13.dev
ruleset DevTools_bootstrap {
    meta {
        name "DevTools Bootstrap"
        description <<
            Bootstrap ruleset for DevTools developing website
        >>

       // use module a169x625 alias CloudOS
        use module b16x42 alias system_credentials

        logging on
        

        provides installedRulesets
        sharing on
    }

    global {

        rulesets = {
            "core": [
                   "a169x676.prod",  // PDS
                   "a16x129.prod",    // SendGrid module
                   "b507199x14.prod", //DevTools
                   "b16x29.prod"     // logging
            ],
      "unwanted": []
        };
      // from wrangler...
      installedRulesets = function() {
        eci = meta:eci();
        results = pci:list_ruleset(eci).klog("results of pci list_ruleset");  
        rids = results{'rids'}.defaultsTo("error","no hash key rids");
        {
         'status'   : (rids neq "error"),
          'rids'     : rids
        };
      }
      // from cloudOS.. needs to be updated(defaction) and placed into wrangler, was called rulesetAddChild.
      InstallRulesets = function(rulesetID, eci) {
      // array of rids needed. 
      ridlist = rulesetID.typeof() eq "array" => rulesetID | rulesetID.split(re/;/);

      // pci will not install dublicate rulesets, so there is no need to filter list.      
      r = (ridlist.length() != 0) =>
       pci:new_ruleset(eci, ridlist) | 
       false;

      rids = (r) => 
        ((r{'rids'}.length() != 0) => 
          r{'rids'} | 
          []) | 
        [];

      status = (r) => true | false;
      {
        'rids'     : rids,
        'status'   : status
      }
    };
    }

    rule bootstrap_guard {
      select when devtools bootstrap
      pre {// why is this written like this? cant we filter without the join?
        installed_rids = pci:list_ruleset(meta:eci())
                            .klog(">> the ruleset list >>  ")
                            .defaultsTo({}, ">> list of installed rulesets undefined >>");
     //   rids = rulesets{"rids"};
        rids_string = installed_rids{"rids"}.join(";");

        bootstrapped = installed_rids{"rids"}
                         .klog(">>>> pico installed_rids before filter >>>> ")
                         .filter(function(v){v eq "b507199x14.prod"})
                         .klog(">>>> pico installed_rids after filter >>>> ")
                         .length()
                         .klog(">>>> pico installed_rids length >>>> ")
                         ;// check if installed_rids includes b507199x14.prod --- use a filter and check if length is > 0.
      
      }
      if (bootstrapped > 1 ) then
      {
        send_directive("found_b507199x14.prod_for_developer") 
           with eci = eci;
      }
      fired {
        log ">>>> pico already bootstraped, saw : " + installed_rids;
      } else {
        
        log ">>>> pico needs a bootstrap >>>> ";
        log ">>>> pico installed_rids, saw : " + rids.encode();
        log ">>>> pico installed_rids, saw : " + rids_string;
        log ">>>> pico installed_rids.filter(function(k,v){v eq b507199x14.prod}), saw : " + installed_rids.filter(function(k,v){v eq "b507199x14.prod"}).encode();
        log ">>>> pico installed_rids.filter(function(k,v){v eq b507199x14.prod}).length();, saw : " + installed_rids.filter(function(k,v){v eq "b507199x14.prod"}).length();
        raise explicit event devtools_bootstrap_needed ;  // don't bootstrap everything
        
      }
    }

    rule devtools_bootstrap {
        select when explicit devtools_bootstrap_needed
        pre {
          installed = InstallRulesets(rulesets{"core"}.klog(">> rulesets to install >>"), 
                                        meta:eci())
                           .defaultsTo("error","InstallRulesets");
        }
        if (installed neq "error") then {
            send_directive("New DevTools user bootstrapped") //with
        }
        fired {
            log "DevTools user bootstrap succeeded";

        } else {
            log "DevTools user bootstrap failed";
        }
    }
  
  rule install_bootstrap_on_child {
    select when bootstrap bootstrap_rid_needed_on_child
    pre {
      target_pico = event:attr("target");
      installed = InstallRulesets(["b507199x13.prod"], target_pico)
                .defaultsTo("error","installing bootstrap");
    }
    {
      send_directive("added bootstrap rids to #{target_pico}");
    }
    fired {
      log "added bootstrap ruleset to #{target_pico}";
    }
  }

}
