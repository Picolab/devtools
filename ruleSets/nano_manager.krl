


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
  global {
    Rulsets = function() { 
      //single
      //list
      //installed
    }

    Channels = function() {

    }
    Clients = function() {

    }
    Picos = function() {

    }
  }

  rule Rulesets {
    select when nano_manager rulesets with  option eq "register"
    pre{}
    {}
    fired{}
  }
  rule Rulesets {
    select when nano_manager rulesets with  option eq "update"
    pre{}
    {}
    fired{}
  }
  rule Update {
    select when nano_manager update 

  }

  rule Channels {
    select when nano_manager channels with  option eq "update"

  }
  rule Clients {
    select when nano_manager clients with  option eq "Authorize"

  }
  rule Clients {
    select when nano_manager clients with option eq "update"

  }
  rule Picos {
    select when nano_manager picos with  option eq "delete"

  }