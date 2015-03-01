//b506607x14
//Flush the ruleset webpage: http://cs.kobj.net/ruleset/flush/b506607x14.prod;b506607x14.dev
ruleset devtools {
	meta {
		name "DevTools"
		description <<
		ruleset for DevTools website.
		>>
		author "KRL-DevTools Developer"

		use module b16x24 alias system_credentials


		logging on

		use module a169x625 alias CloudOS

		provides showRulesets, showInstalledRulesets
		sharing on
	}

	global {
		
		showRulesets = function(){
			rulesets = rsm:list_rulesets(meta:eci()).sort();

			rulesetGallery = rulesets.map(function(rid){

				ridInfo = rsm:get_ruleset(rid).defaultsTo({});

				appURL = ridInfo{"uri"};

				ridInfo
				});

			rulesetGallery
		};

		showInstalledRulesets = function() {
		  rulesets = CloudOS:rulesetList(meta:eci()).defaultsTo({}, ">> list of installed rulesets undefined >>");
		  rids_string = rulesets{"rids"}.join(";");
		  describe_url = "https://#{meta:host()}/ruleset/describe/#{$rids_string}";
		  resp = http:get(describe_url);
		  resp{"status_code"} eq "200" => resp{"content"}.decode()
		                                | resp.klog(">> error retrieving description for rid list >> ")
		}; 
		
	}

	rule createRulesetSubmit {
		select when web submit "#formRegisterNewRuleset"
		pre {
			appURL = event:attr("appURL");
		}
		{
			rsm:register(appURL) setting (rid);
			CloudRain:setHash('/app/#{meta:rid()}/listRulesets');
		}
		fired {
			raise system event rulesetCreated
			with rulsetID = rid{"rid"} if(rid);
		}
	}

	rule deleteRulesets {
		select when web cloudAppAction action re/deleteRulesets/
		{
			CloudRain:setHash('/app/#{meta:rid()}/listRulesets');
		}
		//fired {
			//TODO: Need to delete the ruleset.
			//}
	}

	
	rule updateRuleset {
		select when web submit "#formUpdateRuleset"
		pre {
			rulesetID = event:attr("rulesetID");
			newURL = event:attr("appURL");
		}
		{
			rsm:update(rulesetID) setting(updatedSuccessfully)
			with uri = newURL;
			CloudRain:setHash('/refresh');
		}
		fired {
			raise system event rulesetUpdated
			with rulsetID = rulesetID if(updatedSuccessfully);
		}
	}

	// ---------- ruleset installation ----------
	rule installRulesets {
	  select when devtools install_rulesets
	  pre {
	    rids = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
	    result = CloudOS:rulesetAddChild().klog(">> result of installing #{rids}", meta:eci());
          }
	  if(result{"status"}) then {
 	    send_directive("installed #{rids}");
          }
	  fired {
	    log(">> successfully installed rids #{rids} >>");
          } else {
	    log(">> could not install rids #{rids} >>");
          }
        }

        rule uninstallRulesets {
	  select when devtools uninstall_rulesets
	  pre {
	    rids = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
	    result = CloudOS:rulesetRemoveChild().klog(">> result of uninstalling #{rids}", meta:eci());
          }
	  if(result{"status"}) then {
 	    send_directive("uninstalled #{rids}");
          }
	  fired {
	    log(">> successfully uninstalled rids #{rids} >>");
          } else {
	    log(">> could not uninstall rids #{rids} >>");
          }
        }
}