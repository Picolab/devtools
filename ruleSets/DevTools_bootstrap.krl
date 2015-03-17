//for flushing: http://cs.kobj.net/ruleset/flush/b506607x15.prod;b506607x15.dev
ruleset DevTools_bootstrap {
    meta {
        name "DevTools Bootstrap"
        description <<
            Bootstrap ruleset for DevTools
        >>

        use module a169x625 alias CloudOS
        logging on

        provides testingReturns
        sharing on
    }

    global {

        rulesets = {
            "core": [
                   "a169x625.prod",  // CloudOS Service
                   "a169x676.prod",  // PDS
                   "a16x129.dev",    // SendGrid module
                   "b506607x14.prod", //DevTools
                   "b16x29.prod"     // logging
            ],
	    "unwanted": []
        };

        testingReturns = function(){
          rulesets = CloudOS:rulesetList(meta:eci()).defaultsTo({}, ">> list of installed rulesets undefined >>");
          rulesets;
        };
    }

    rule bootstrap_guard {
      select when devtools bootstrap
      pre {
        installed_rids = CloudOS:rulesetList(meta:eci())
                            .klog(">> the ruleset list >>  ")
                            .defaultsTo({}, ">> list of installed rulesets undefined >>");
	   //   rids = rulesets{"rids"};
        rids_string = installed_rids{"rids"}.join(";");

        bootstrapped = installed_rids{"rids"}
                         .klog(">>>> pico installed_rids before filter >>>> ")
                         .filter(function(v){v eq "b506607x14.prod"})
                         .klog(">>>> pico installed_rids after filter >>>> ")
                         .length()
                         .klog(">>>> pico installed_rids length >>>> ")
                         ;// check if installed_rids includes b506607x14.prod --- use a filter and check if length is > 0.
      
      }
      if (bootstrapped > 0 ) then
      {
        send_directive("found_b506607x14.prod_for_developer") 
	         with eci = eci;
      }
      fired {
	      log ">>>> pico already bootstraped, saw : " + installed_rids;
      } else {
        send_directive("did not find b506607x14.prod_for_developer") 
           with eci = eci
        log ">>>> pico needs a bootstrap >>>> ";
        log ">>>> pico installed_rids, saw : " + rids.encode();
        log ">>>> pico installed_rids, saw : " + rids_string;
        log ">>>> pico installed_rids.filter(function(k,v){v eq b506607x14.prod}), saw : " + installed_rids.filter(function(k,v){v eq "b506607x14.prod"}).encode();
        log ">>>> pico installed_rids.filter(function(k,v){v eq b506607x14.prod}).length();, saw : " + installed_rids.filter(function(k,v){v eq "b506607x14.prod"}).length();
        raise explicit event devtools_bootstrap_needed ;  // don't bootstrap everything
        
      }
    }

    rule devtools_bootstrap {
        select when explicit devtools_bootstrap_needed
        pre {
          installed = CloudOS:rulesetAddChild(rulesets{"core"}.klog(">> rulesets to install >>"), 
	                                      meta:eci())
                           .klog(">> installed rulesets >>");
        }
        if (installed) then {
            send_directive("New DevTools user bootstrapped") //with
        }
        fired {
            log "DevTools user bootstrap succeeded";

        } else {
            log "DevTools user bootstrap failed";
        }
    }

}