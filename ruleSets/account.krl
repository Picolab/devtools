

ruleset b507199x6 { 
  meta {
    name "wrangler:account"
    description <<
    wrangler account mannagement.
    >>
    author "BYUPICOLab"
    
    logging on

    use module b16x24 alias system_credentials
    use module v1_wrangler alias wrangler

    // errors raised to.... unknown

    // Accounting keys
      //none
    provides accountProfile
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
	  
	//-------------------- Acounts --------------------
  accountProfile = function() { // move to account mannagement rulesets
    profile = pci:get_profile(wrangler:currentSession()).defaultsTo("error",wrangler:standardError("undefined"));
    {
     'status' : (profile neq "error"),
     'profile'  : profile
    }
  }


}

}