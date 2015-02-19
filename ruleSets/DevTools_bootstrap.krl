ruleset DevTools_bootstrap {
    meta {
        name "DevTools Bootstrap"
        description <<
            Bootstrap ruleset for DevTools
        >>

        use module a169x625 alias CloudOS
        use module a169x676 alias pds

    }

    global {

        apps = {
            "core": [
                   "a169x625.prod",  // CloudOS Service
                   "a169x676.prod",  // PDS
                   "a16x161.prod",   // Notification service
                   "a169x672.prod",  // MyProfile
                   "a169x695.prod",  // Settings
                   "a41x174.prod",   // Amazon S3 module
                   "a16x129.dev",    // SendGrid module
                  // "b506607x14.dev", // DevTools
                   "b506607x14.prod" //DevTools
            ],
	    "unwanted": [ 
                   "a169x664.prod",	// CloudUIService 
                   "a169x667.prod",	// myThings
                   "a41x178.prod",	// SquareTag
                   "a169x669.prod",	// appStore
    //               "a169x727.prod",	// CloudAPI
                   "b177052x7.prod"
            ]
        };
    }

    rule bootstrap_guard {
      select when DevTools bootstrap// <-------------------------------------------------------NEED TO UPDATE EVENT NAME !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      pre {
        namespace = "fuse-meta"; // this is defined in fuse_common.krl, but we haven't got it yet.
       
    //    eci = CloudOS:subscriptionList(namespace,"Fleet").head().pick("$.eventChannel") ------------------------------ IF USER DOES NOT HAVE RULE INSTALLED 
	  // || pds:get_item(namespace,"fleet_channel");
	
	
      }
      if (! eci.isnull() ) then
      {
        send_directive("found_eci_for_fleet") 
	         with eci = eci
      }
      fired {//?????????????????????????????????????????????????????????????????????should this be not fired?
        log ">>>> pico needs a bootstrap >>>> ";
	      raise explicit event bootstrap_needed;
      } else {
        log ">>>> pico already bootstraped, saw : " + eci;
      }
    }

    rule strap_some_boots {
        select when explicit bootstrap_needed
        pre {
	  remove_rulesets = CloudOS:rulesetRemoveChild(apps{"unwanted"}, meta:eci());

	  // not using yet
	  already_installed = CloudOS:rulesetList(meta:eci()).pick("$.rids").join(",").klog(">>>> rids >>>> ");
	  no_init = not already_installed.match(re#owner|16x16#).klog(">>>> seeing an init ruleset >>>>");

          installed = CloudOS:rulesetAddChild(apps{"core"}, meta:eci());
	  account_profile = CloudOS:accountProfile();
          profile = {
            "myProfileName": account_profile{"firstname"} + " " + account_profile{"lastname"},
            "myProfileEmail": account_profile{"email"}
          };
        }

        if (installed) then {
            send_directive("New DevTools user bootstrapped") with
	      profile = profile;
        }

        fired {
            log "DevTools user bootstrap succeeded";

        } else {
            log "DevTools user bootstrap failed";
        }
    }

}