

ruleset b507199x6 { // this is not registered yet
  meta {
    name "nano_manager:account"
    description <<
    nano_manager account mannagement.
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials
    use module b507199x5 alias nano_manager

    // errors raised to.... unknown

    // Accounting keys
      //none
    provides 
    accountProfile
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  global {
    //functions
	  
	//-------------------- Acounts --------------------
  accountProfile = function() { // move to account mannagement rulesets
    profile = pci:get_profile(nano_manager:currentSession()).defaultsTo("error",nano_manager:standardError("undefined"))
    .put( ["oauth_eci"], meta:eci() );
    {
     'status' : (profile neq "error"),
     'profile'  : profile
    }
  }


}