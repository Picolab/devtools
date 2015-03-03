ruleset DevTools_bootstrap {
    meta {
        name "DevTools Bootstrap"
        description <<
            Bootstrap ruleset for DevTools
        >>

        use module a169x625 alias CloudOS

    }

    global {

        rulesets = {
            "core": [
                   "a169x625.prod",  // CloudOS Service
                   "a169x676.prod",  // PDS
                   "a16x161.prod",   // Notification service
                   "a169x672.prod",  // MyProfile
                   "a169x695.prod",  // Settings
                   "a41x174.prod",   // Amazon S3 module
                   "a16x129.dev",    // SendGrid module
                  // "b506607x15.prod", // DevTools
                   "b506607x14.prod", //DevTools
                   "b16x29.prod"     // logging
            ],
	    "unwanted": []
        };
    }

    rule bootstrap_guard {
      select when devtools bootstrap
      pre {
        installed_rids = CloudOS:listRulest(meta:eci);
	      bootstrapped = installed_rids.filter(function(k,v){k eq "b506607x14.prod"}).length();// check if installed_rids includes b506607x14.prod" --- use a filter and check if length is > 0.
      }
      if (bootstrapped > 0 ) then
      {
        send_directive("found_eci_for_developer") 
	         with eci = eci
      }
      fired {
        log ">>>> pico needs a bootstrap >>>> ";
	      raise explicit event bootstrap_needed;
      } else {
        log ">>>> pico already bootstraped, saw : " + installed_rids;
      }
    }

    rule strap_some_boots {
        select when explicit bootstrap_needed
        pre {
	       //remove_rulesets = CloudOS:rulesetRemoveChild(rulesets{"unwanted"}, meta:eci());

          installed = CloudOS:rulesetAddChild(rulesets{"core"}, meta:eci());
//	  account_profile = CloudOS:accountProfile();
  //        profile = {
    //        "myProfileName": account_profile{"firstname"} + " " + account_profile{"lastname"},
       //     "myProfileEmail": account_profile{"email"}
      //    };
        }

        if (installed) then {
            send_directive("New DevTools user bootstrapped") //with
	     // profile = profile;
        }

        fired {
            log "DevTools user bootstrap succeeded";

        } else {
            log "DevTools user bootstrap failed";
        }
    }

}