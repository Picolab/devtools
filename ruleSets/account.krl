

ruleset b507199x5 {
  meta {
    name "nano_manager"
    description <<
      Nano Manager ( ) Module

      use module a169x625 alias nano_manager

      This Ruleset/Module provides a developer interface to the PICO (persistent computer object).
      When a PICO is created or authenticated this ruleset
      will be installed into the Personal Cloud to provide an Event layer.
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