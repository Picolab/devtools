ruleset b507199x10 {
  meta {
    name "nano_schedules"
    description <<
      Nano Schedules
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials

    provides 
    schedules, scheduleHistory 
    sharing on

  }

  global {
    //functions

    schedules = function() { 
      sched_event_list = event:get_list().defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (sched_event_list != "wrong"),
        'schedules'  : sched_event_list
      }

    }
    scheduleHistory = function(id) { 
      sched_event_history = event:get_history(id).defaultsTo("wrong",standardError("undefined"));
      {
        'status' : (sched_event_history != "wrong"),
        'history'  : sched_event_history
      }
    
    }
  }
  //Rules
  rule DeleteScheduled {
    select when nano_schedules scheduled_deleted
    pre{
      sid = event:attr("sid").defaultsTo("", standardError("missing event attr sid"));
    }
    if (sid neq "") then
    {
      event:delete(sid);
    }
    fired {
      log(">> successfull>>");
          } 
    else {
      log(">> falure >>");
    }
  }  
  rule CreateScheduled {
    select when nano_schedules scheduled_created
    pre{
      eventtype = event:attr("eventtype").defaultsTo("wrong", standardError("missing event attr eventtype"));
      time = event:attr("time").defaultsTo("wrong", standardError("missing event attr type"));
      do_main = event:attr("do_main").defaultsTo("wrong", standardError("missing event attr type"));
      timespec = event:attr("timespec").defaultsTo("{}", standardError("missing event attr timespec"));
      date_time = event:attr("date_time").defaultsTo("wrong", standardError("missing event attr type"));
      attributes = event:attr("attributes").defaultsTo("{}", standardError("missing event attr type"));
      attr = attributes.decode();

    }
    if (type eq "single" && type neq "wrong" ) then
    {
      noop();
    }
    fired {
      log(">> single >>");
      schedule do_main event eventype at date_time attributes attr ;
          } 
    else {
      log(">> multiple >>");
      schedule do_main event eventype repeat timespec attributes attr ;
    }
  }  
}