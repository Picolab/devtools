
// varibles 
// ent:my_picos


// operators are cammel case, variblse are snake case.


// questions
// when should we use klogs? what is the standard? varible getters|| mutators 
// is log our choice of status setting for rules ? when should we send directives. can we send directives in postlude with status varible?
// varible validating for removing , deleteing, uninstalling
// when registering a ruleset if you pass empty peramiters what happens

//old channel create uses a "login" eci to create a new channel, why and should we do it that way? 

//whats the benifit of forking a ruleset vs creating a new one?
//pci: lacks abillity to change channel type 

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
    use module b507199x6 alias Channels
    use module b507199x7 alias Clients
    use module b507199x8 alias Picos
    use module b507199x9 alias Rulesets
    use module b507199x10 alias Schedules
    use module b507199x11 alias Subscriptions
    use module b16x29 alias Logs // https://raw.githubusercontent.com/Picolab/picologging/master/picologging.krl
    // errors raised to.... not implamented

    provides registered, singleRuleset, installed, describeRules, //ruleset
    channels, attributes, policy, type, //channel
    //clients, //client
    picos, accountProfile, //pico
    schedules, scheduleHistory, // schedule
    subscriptions, outGoing, incoming //subscription
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
    //}
  global {
    //functions
    //-------------------- Rulesets --------------------
    registered = Rulesets:registered();
    singleRuleset = Rulesets:singleRuleset(rid); 
    installed = Rulesets:installed();
    describeRules = Rulesets:describeRules(rids); //takes an array of rids as parameter // can we write this better???????
    //-------------------- Channels --------------------
    channels = Channels:channels(); 
    attributes = Channels:attributes(eci); 
    policy = Channels:policy(eci); 
    type = Channels:type(channel_id); // untested!!!!!!!!!!!!!!!!!!!
    //-------------------- Clients --------------------


    //-------------------- Picos --------------------
    //pico Logging 
    logs = Logs:getLogs();// untested
    status = Logs:loggingStatus();// untested
      accountProfile = function() {
    profile = pci:get_profile(currentSession()).defaultsTo("wrong",standardError("undefined"));
    {
     'status' : (profile != "wrong"),
     'profile'  : profile
    }
  }
  currentSession = function() {
    pci:session_token(meta:eci()).defaultsTo("", standardError("pci session_token failed")); // this is old way.. why not just eci??
  };


    children = Picos:children();
    parent = Picos:parent();
    attributes = Picos:attributes();
    picoFactory = Picos:picoFactory(myEci, protos); 
    //-------------------- Subscriptions ----------------------
    subscriptions = Subscriptions:subscriptions(); 
    outGoing = Subscriptions:outGoing(); 
    incoming = Subscriptions:incoming(); 
    //-------------------- Scheduled ----------------------
    schedules = Schedules:schedules(); 
    scheduleHistory = Schedules:scheduleHistory(id);
    //------------------------------- Utilities -------------------
    standardError = function(message) {
      error = ">> error: " + message + " >>";
      error
    }
    standardOut = function(message) {
      msg = ">> " + message + " results: >>";
      msg
    };
  }
  //Rules
  
}