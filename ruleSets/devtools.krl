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

		provides showRulesets, showInstalledRulesets, aboutPico, showInstalledChannels

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

		showInstalledChannels = function() {
		  channels = CloudOS:channelList(meta:eci()).defaultsTo({}, ">> list of installed channels undefined >>")
		  //.klog(">>> channels cloud call >>>")
		  ;
		  krl_struct = channels.decode()
		  .klog(">>krl_struct>> ")
		  ;
		 // channels_string = channels{"channels"}
		 // 	.join(";")
		 // 	.klog(">> after join >>  ")
		 // 	;
		//	channels_string.decode()
		krl_struct;
		}; 

		aboutPico = function() {
	          account_profile = CloudOS:accountProfile()
		                      .put( ["oauth_eci"], meta:eci() )
		  		      ;
		  account_profile 
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

	rule updateUrl {
		select when devtools update_url//subm form-update-url
		pre {
			rid = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
			newURL = event:attr("url"); //should pull from the form on update url template
		}
		{
			rsm:update(rid) setting(updatedSuccessfully)
			with uri = newURL;
		}
		fired {
			raise system event rulesetUpdated
			with rid = rid if(updatedSuccessfully);
		}
	}

	rule flushRuleset {
		select when devtools flush_rid
		pre {
			rid = event:attr("rid").defaultsTo("", ">> missing event attr rid >> ");
		}
		if(rid.length() > 0 ) then
		{
			rsm:flush(rid) 
		}
		fired {
		  log ">>>> flushed #{rid} <<<<"
		} 
	}

	// ---------- ruleset installation ----------
	rule installRulesets {
	  select when devtools install_rulesets
	  pre {
	    rids = event:attr("rids").defaultsTo("", ">> missing event attr rids >> ");
            result = rsm:is_valid(rids) => CloudOS:rulesetAddChild(rids, meta:eci()).klog(">> result of installing #{rids} >> ")
	                                 | {"status": false};
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
	    result = CloudOS:rulesetRemoveChild(rids, meta:eci()).klog(">> result of uninstalling #{rids} >> ");
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

    rule registerRuleset {
		select when devtools register_ruleset
		pre {
			rulesetURL= event:attr("rulesetURL");
		}
		{
			rsm:register(rulesetURL) setting (rid);
		}
		fired {
			raise system event rulesetRegistered
			with rulsetID = rid{"rid"} if(rid);
		}
	}
	//---------------- channel manager ---------------
	rule installChannels {
	  select when devtools install_channels
	  pre {
	    channels = event:attr("channels").defaultsTo("", ">> missing event attr channels >> ");
            result = rsm:is_valid(channels) => CloudOS:rulesetAddChild(channels, meta:eci()).klog(">> result of installing #{channels} >> ")
	                                 | {"status": false};
          }
	  if(result{"status"}) then {
 	    send_directive("installed #{channels}");
          }
	  fired {
	    log(">> successfully installed channels #{channels} >>");
          } else {
	    log(">> could not install channels #{channels} >>");
          }
        }

    rule uninstallChannels {
	  select when devtools uninstall_channels
	  pre {
	    channels = event:attr("channels").defaultsTo("", ">> missing event attr channels >> ");
	    result = CloudOS:rulesetRemoveChild(channels, meta:eci()).klog(">> result of uninstalling #{channels} >> ");
          }
	  if(result{"status"}) then {
 	    send_directive("uninstalled #{channels}");
          }
	  fired {
	    log(">> successfully uninstalled channels #{channels} >>");
          } else {
	    log(">> could not uninstall channels #{channels} >>");
          }
        }
}