//b506537x0.prod
//b506607x14
ruleset devtools {
	meta {
		name "DevTools"
		description <<
		ruleset for DevTools website.
		>>
		author "KRL-DevTools Developer"
    

		logging on

    use module a169x625 alias CloudOS
    
    provides showRulesets
    sharing on
	}

	global {
		
    showRulesets = function(){
      rulesets = rsm:list_rulesets(meta:eci()).sort();

      rulesetGallery = rulesets.map(function(rid){

        ridInfo = (rid) => rsm:get_ruleset(rid) | {};
 
        appURL = ridInfo{"uri"};
        ridInfo
      });

      rulesetGallery
    };

	}
	
}