//b506537x0.prod
//b506607x14
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
    
    provides showRulesets
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

	}
	
}