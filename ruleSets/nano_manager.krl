


ruleset nano_manager {
  meta {
    name "nano_manager"
    description <<
      Nano Manager ( ) Module

      use module a169x625 alias nano_manager

      This Ruleset/Module provides a developer interface to the PICO (persistent computer object).
      When a PICO is created or authenticated this ruleset
      will be installed into the Personal Cloud to provide an Event layer.
    >>

    	sharing on
    provides 


    author "BYU PICO Lab"
    logging off
    // errors raised to unknown

    // Accounting keys
      //none
  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
