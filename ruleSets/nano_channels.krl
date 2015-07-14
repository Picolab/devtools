

ruleset b507199x6 {
  meta {
    name "nano_channels"
    description <<
      Nano Channels
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials

    provides channels, attributes, policy, type
    
    sharing on

  }

  global {
    //functions
  //-------------------- Channels --------------------
    channels = function() { 
      eci = meta:eci();
      results = pci:list_eci(eci).defaultsTo({},standardError("undefined")); // list of ECIs assigned to userid
      channels = results{'channels'}.defaultsTo("wrong",standardError("undefined")); // list of channels if list_eci request was valid
      {
        'status'   : (results neq "wrong"),
        'channels' : channels
      };
    }
    attributes = function(eci) {
      results = pci:get_eci_attributes(eci).defaultsTo("wrong",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "wrong"),
        'Attributes' : results
      };
    }
    policy = function(eci) {
      results = pci:get_eci_policy(eci).defaultsTo("wrong",standardError("undefined")); // list of ECIs assigned to userid
      {
        'status'   : (results neq "wrong"),
        'Policy' : results
      };
    }
    type = function(channel_id) { // untested!!!!!!!!!!!!!!!!!!!
      channels = Channels().defaultsTo("wrong",">> undefined >>");

      getType = function(channel_id,channels) {
        channels = channels{"channels"}.defaultsTo("undefined",standardError("undefined"));
        channel = channels.filter( function(channel){channel{"cid"} eq channel_id } ).defaultsTo( "wrong",standardError("undefined"));
        channel = channel[0];
        type = channel{"type"};
        temp = (type.typeof() eq "str" ) => type | type.typeof() eq "array" => type[0] |  type.keys();
        type2 = (temp.typeof() eq "array") => temp[0] | temp;   
        type2;
      };
      type = ((channels neq "wrong") && (channels neq {} )) => getType() | "wrong";
      {
        'status'   : (type neq "wrong"),
        'channels' : channels
      };
    }
  }
  //Rules
  rule CreateChannel {
    select when nano_manager channel_created
    pre {
     // channels = Channels().defaultsTo({}, standardError("list of installed channels undefined")); // why do we do this ????
      channelName = event:attr("channelName").defaultsTo("", standardError("missing event attr channels"));
      user = currentSession();
      options = {
        'name' : channelName//,
        //'eci_type' : ,
        //'attributes' : ,
        //'policy' : ,
      };
          }
    if(channelName.match(re/\w[\w\d_-]*/) && user != "") then {
      pci:new_eci(user, options);
      send_directive("Created #{channelName}");
      //with status= true; // should we send directives??
          }
    fired {
      log(">> successfully created channels #{channelName} >>");
          } 
    else {
      log(">> could not create channels #{channelName} >>");
          }
    }
  rule UpdateChannelAttributes {
    select when nano_manager channel_attributes_updated
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
      attributes = event:attr("attributes").defaultsTo("", standardError("undefined"));
      channels = Channels();
    }
    if(channels{"channel_id"} && attributes != "") then { // check??redundent????
      pci:set_eci_attributes(channel_id, attributes);// attributes need to be an array, do we need to cast type?
      send_directive("updated #{channelID} attributes");
    }
    fired {
      log(">> successfully updated channel #{channel_id} attributes >>");
    } 
    else {
      log(">> could not update channel #{channel_id} attributes >>");
    }
  }

  rule UpdateChannelPolicy {
    select when nano_manager channel_policy_updated // channel_policy_update_requested
    pre {
      channel_id = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
      policy = event:attr("policy").defaultsTo("", standardError("undefined"));
      channels = Channels();
    }
    if(channels{"channelID"} && policy != "") then { // check??redundent??whats better??
      pci:set_eci_policy(channel_id, policy); // policy needs to be a map, do we need to cast types?
      send_directive("updated #{channel_id} policy");
    }
    fired {
      log(">> successfully updated channel #{channel_id} policy >>");
    }
    else {
      log(">> could not update channel #{channel_id} policy >>");
    }

  }
  rule DeleteChannel {
    select when nano_manager channel_deleted
    pre {
      channelID = event:attr("channel_id").defaultsTo("", standardError("missing event attr channels"));
    }
    {
      pci:delete_eci(channelID);
      send_directive("deleted #{channelID}");
    }
    fired {
      log(">> successfully deleted channel #{channelID} >>");
          } else {
      log(">> could not delete channel #{channelID} >>");
          }
        }

 
}