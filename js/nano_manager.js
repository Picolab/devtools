; (function()
{
    window.nano_manager = {};

    // ------------------------------------------------------------------------

    nano_manager.defaultECI = "none";
    nano_manager.access_token = "none";

    var mkEci = function(cid) {
       var res = cid || nano_manager.defaultECI;
       if (res === "none") {
           throw "No nano_manager event channel identifier (ECI) defined";
       }
       return res;
   };

   var mkEsl = function(parts) {
    if (nano_manager.host === "none") {
        throw "No nano_manager host defined";
    }
    parts.unshift(nano_manager.host);
    var res = 'https://'+ parts.join("/");
    return res;
    };
    get_rid = function(name) {
        
        var rids = {
            "rulesets": {"prod": "b507199x5.prod", 
                          "dev": "b507199x5.dev"
            },
            "bootstrap":{"prod": "b507199x1.prod", 
                          "dev": "b507199x1.dev"
            }
        };

        return rids[name].dev;
    };

    // ------------------------------------------------------------------------
    // Raise Sky Event
    nano_manager.raiseEvent = function(eventDomain, eventType, eventAttributes, eventParameters, postFunction, options)
    {
       try {

           options = options || {};

           var eci = mkEci(options.eci);
           var eid = Math.floor(Math.random() * 9999999); // whats the event id used for and do we need it?
           var esl = mkEsl(['sky/event',
            eci,
            eid,
            eventDomain,
            eventType
            ]);

           if (typeof eventParameters !== "undefined" &&
              eventParameters !== null &&
              eventParameters !== ""
              ) {
               console.log("Attaching event parameters ", eventParameters);
           var param_string = $.param(eventParameters);
           if (param_string.length > 0) {
             esl = esl + "?" + param_string;
         }
     }

     console.log("nano_manager.raise ESL: ", esl);
     console.log("event attributes: ", eventAttributes);

     return $.ajax({
      type: 'POST',
      url: esl,
      data: $.param(eventAttributes),
      dataType: 'json',
		headers: { 'Kobj-Session': eci }, // not sure needed since eci in URL
		success: postFunction,
		error: options.errorFunc || function(res) { console.error(res) }
    });
 } catch(error) {
   console.error("[raise]", error);
   return null;
}
};

nano_manager.skyCloud = function(module, func_name, parameters, getSuccess, options)
{
	try {

       var retries = 2;


       options = options || {};

       if (typeof options.repeats !== "undefined") {
          console.warn("This is a repeated request: ", options.repeats);
          if (options.repeats > retries) {
            throw "terminating repeating request due to consistent failure.";
        }
    }

    var eci = mkEci(options.eci);

    var esl = mkEsl(['sky/cloud',
        module,
        func_name
        ]);

    $.extend(parameters, { "_eci": eci });

    console.log("Attaching event parameters ", parameters);
    esl = esl + "?" + $.param(parameters);

    var process_error = function(res)
    {
      console.error("skyCloud Server Error with esl ", esl, res);
      if (typeof options.errorFunc === "function") {
        options.errorFunc(res);
    }
};

var process_result = function(res) // whats this for???
{
  console.log("Seeing res ", res, " for ", esl);
  var sky_cloud_error = typeof res === 'Object' && typeof res.skyCloudError !== 'undefined';
  if (! sky_cloud_error ) {
    getSuccess(res);
} else {
    console.error("skyCloud Error (", res.skyCloudError, "): ", res.skyCloudErrorMsg);
    if (!!res.httpStatus && 
     !!res.httpStatus.code && 
     (parseInt(res.httpStatus.code) === 400 || parseInt(res.httpStatus.code) === 500)) 
    {
     console.error("The request failed due to an ECI error. Going to repeat the request.");
     var repeat_num = (typeof options.repeats !== "undefined") ? ++options.repeats : 0;
     options.repeats = repeat_num;
			// I don't think this will support promises; not sure how to fix
			nano_manager.skyCloud(module, func_name, parameters, getSuccess, options);
        }
    }
};

console.log("sky cloud call to ", module+':'+func_name, " on ", esl, " with token ", eci);

return $.ajax({
  type: 'GET',
  url: esl,
  dataType: 'json',
		// try this as an explicit argument
		//		headers: {'Kobj-Session' : eci},
		success: process_result
		// error: process_error
    });
} catch(error) {
   console.error("[skyCloud]", error);
   if (typeof options.errorFunc === "function") {
      options.errorFunc();
  } 
  return null;
}
};
/*    nano provides installedRulesets, describeRulesets, //ruleset
    channels, channelAttributes, channelPolicy, channelType, //channel
    children, parent, attributes, //pico
    subscriptions, channelByName, channelByEci, subscriptionsAttributesEci, subscriptionsAttributesName, //subscription
    currentSession,standardError

    */


    // ------------------------------------------------------------------------ installed Rulests
    // function(eventDomain, eventType, eventAttributes, eventParameters, postFunction, options) // <--- raiseEvent paramiters 

    nano_manager.installedRulesets = function(parameters, postFunction, options)
    {
        console.log("Getting installed rulesets");
        var rulesets = nano_manager.skyCloud(get_rid("rulesets"), "installedRulesets", parameters, postFunction , options); // do we need options , whats getsucces???
        console.log("Got installed rulesets", results);
        var rids = rulesets.rids;
        var description = nano_manager.describeRulesets(rids,postFunction,options);
        console.log("Installed rulesets with description", description.description);
        return description.description;

        return results; 
    };
    


    nano_manager.describeRulesets = function(parameters, postFunction, options)
    {
        console.log("Getting ruleset discription ");
        var results = nano_manager.skyCloud(get_rid("rulesets"), "installedRulesets", parameters, postFunction , options); // do we need options , whats getsucces???
        console.log("Got discription :", results);
        return results; 
    };

    nano_manager.installRulesets = function( eventAttributes, eventParameters, postFunction, options)
    {
        console.log("Installing rulesets");
        var results = nano_manager.raiseEvent("nano_manager", "install_rulesets_requested", eventAttributes, eventParameters, postFunction, options);
        console.log("Installed rulesets", eventAttributes.rids);
        return results;
    };

    nano_manager.uninstallRuleset = function( eventAttributes, eventParameters, postFunction, options)
    {
        console.log("uninstalling ruleset: ",eventAttributes.eci);
        var results = nano_manager.raiseEvent("nano_manager", "uninstall_rulesets_requested", eventAttributes, eventParameters, postFunction, options);
        console.log("uninstalled rulesets: ", eventAttributes.eci);
        return results;
    };

    // ------------------------------------------------------------------------ Channels
    // ------------------------------------------------------------------------ pico
    // ------------------------------------------------------------------------ subscription

    nano_manager.createChannel = function(postFunction)
    {
        return nano_manager.raiseEvent('nano_manager', 'api_Create_Channel', {}, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    nano_manager.destroyChannel = function(myToken, postFunction)
    {
        return nano_manager.raiseEvent('nano_manager', 'api_Destroy_Channel',
         { "token": myToken }, {}, postFunction);
    };

    // ========================================================================
    // Profile Management

    nano_manager.getMyProfile = function(getSuccess)
    {
        return nano_manager.skyCloud("a169x676", "get_all_me", {}, function(res) {
           clean(res);
           if(typeof getSuccess !== "undefined"){
              getSuccess(res);
          }
      });
    };

    nano_manager.updateMyProfile = function(eventAttributes, postFunction)
    {
        var eventParameters = { "element": "profileUpdate.post" };
        return nano_manager.raiseEvent('web', 'submit', eventAttributes, eventParameters, postFunction);
    };

    nano_manager.getFriendProfile = function(friendToken, getSuccess)
    {
        var parameters = { "myToken": friendToken };
        return nano_manager.skyCloud("a169x727", "getFriendProfile", parameters, getSuccess);
    };

    // ========================================================================
    // PDS Management

    // ------------------------------------------------------------------------
    nano_manager.PDSAdd = function(namespace, pdsKey, pdsValue, postFunction)
    {
        var eventAttributes = {
            "namespace": namespace,
            "pdsKey": pdsKey,
            "pdsValue": JSON.stringify(pdsValue)
        };

        return nano_manager.raiseEvent('nano_manager', 'api_pds_add', eventAttributes, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    nano_manager.PDSDelete = function(namespace, pdsKey, postFunction)
    {
        var eventAttributes = {
            "namespace": namespace,
            "pdsKey": pdsKey
        };

        return nano_manager.raiseEvent('nano_manager', 'api_pds_delete', eventAttributes, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    nano_manager.PDSUpdate = function()
    {
    };

    // ------------------------------------------------------------------------
    nano_manager.PDSList = function(namespace, getSuccess)
    {
        var callParmeters = { "namespace": namespace };
        return nano_manager.skyCloud("pds", "get_items", callParmeters, getSuccess);
    };

    // ------------------------------------------------------------------------
    nano_manager.sendEmail = function(ename, email, subject, body, postFunction)
    {
        var eventAttributes = {
            "ename": ename,
            "email": email,
            "subject": subject,
            "body": body
        };
        return nano_manager.raiseEvent('nano_manager', 'api_send_email', eventAttributes, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    nano_manager.sendNotification = function(application, subject, body, priority, token, postFunction)
    {
        var eventAttributes = {
            "application": application,
            "subject": subject,
            "body": body,
            "priority": priority,
            "token": token
        };
        return nano_manager.raiseEvent('nano_manager', 'api_send_notification', eventAttributes, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    nano_manager.subscriptionList = function(callParmeters, getSuccess)
    {
        return nano_manager.skyCloud("nano_manager", "subscriptionList", callParmeters, getSuccess);
    };


    // ========================================================================
    // Login functions
    // ========================================================================
    nano_manager.login = function(username, password, success, failure) {


       var parameters = {"email": username, "pass": password};

       if (typeof nano_manager.anonECI === "undefined") {
           console.error("nano_manager.anonECI undefined. Configure nano_manager.js in nano_manager-config.js; failing...");
           return null;
       }

       return nano_manager.skyCloud("nano_manager",
        "cloudAuth", 
        parameters, 
        function(res){
				    // patch this up since it's not OAUTH
				    if(res.status) {
                       var tokens = {"access_token": "none",
                       "OAUTH_ECI": res.token
                   };
                   nano_manager.saveSession(tokens); 
                   if(typeof success == "function") {
                       success(tokens);
                   }
               } else {
                   console.log("Bad login ", res);
                   if(typeof failure == "function") {
                       failure(res);
                   }
               }
           },
           {eci: nano_manager.anonECI,
               errorFunc: failure
           }
           );


   };



    // ========================================================================
    // OAuth functions
    // ========================================================================

    // ------------------------------------------------------------------------
    nano_manager.getOAuthURL = function(fragment)
    {
        if (typeof nano_manager.login_server === "undefined") {
            nano_manager.login_server = nano_manager.host;
        }


        var client_state = Math.floor(Math.random() * 9999999);
        var current_client_state = window.localStorage.getItem("nano_manager_CLIENT_STATE");
        if (!current_client_state) {
            window.localStorage.setItem("nano_manager_CLIENT_STATE", client_state.toString());
        }
        var url = 'https://' + nano_manager.login_server +
        '/oauth/authorize?response_type=code' +
        '&redirect_uri=' + encodeURIComponent(nano_manager.callbackURL + (fragment || "")) +
        '&client_id=' + nano_manager.appKey +
        '&state=' + client_state;

        return (url)
    };

    nano_manager.getOAuthNewAccountURL = function(fragment)
    {
        if (typeof nano_manager.login_server === "undefined") {
            nano_manager.login_server = nano_manager.host;
        }


        var client_state = Math.floor(Math.random() * 9999999);
        var current_client_state = window.localStorage.getItem("nano_manager_CLIENT_STATE");
        if (!current_client_state) {
            window.localStorage.setItem("nano_manager_CLIENT_STATE", client_state.toString());
        }
        var url = 'https://' + nano_manager.login_server +
        '/oauth/authorize/newuser?response_type=code' +
        '&redirect_uri=' + encodeURIComponent(nano_manager.callbackURL + (fragment || "")) +
        '&client_id=' + nano_manager.appKey +
        '&state=' + client_state;

        return (url)
    };

//https://kibdev.kobj.net/oauth/authorize/newuser?response_type=code&redirect_uri=http%3A%2F%2Fjoinfuse.com%2Fcode.html&client_id=D98022C6-C4F4-11E3-942D-E857D61CF0AC&state=6970625


    // ------------------------------------------------------------------------
    nano_manager.getOAuthAccessToken = function(code, callback, error_func)
    {
        var returned_state = parseInt(getQueryVariable("state"));
        var expected_state = parseInt(window.localStorage.getItem("nano_manager_CLIENT_STATE"));
        if (returned_state !== expected_state) {
            console.warn("OAuth Security Warning. Client states do not match. (Expected %d but got %d)", nano_manager.client_state, returned_state);
        }
        console.log("getting access token with code: ", code);
        if (typeof (callback) !== 'function') {
            callback = function() { };
        }
        var url = 'https://' + nano_manager.login_server + '/oauth/access_token';
        var data = {
            "grant_type": "authorization_code",
            "redirect_uri": nano_manager.callbackURL,
            "client_id": nano_manager.appKey,
            "code": code
        };

        return $.ajax({
            type: 'POST',
            url: url,
            data: data,
            dataType: 'json',
            success: function(json)
            {
                console.log("Recieved following authorization object from access token request: ", json);
                if (!json.OAUTH_ECI) {
                    console.error("Received invalid OAUTH_ECI. Not saving session.");
                    callback(json);
                    return;
                };
                nano_manager.saveSession(json);
                window.localStorage.removeItem("nano_manager_CLIENT_STATE");
                callback(json);
            },
            error: function(json)
            {
                console.log("Failed to retrieve access token " + json);
                error_func = error_func || function(){};
                error_func(json);
            }
        });
    };

    // ========================================================================
    // Session Management

    // ------------------------------------------------------------------------
    nano_manager.retrieveSession = function()
    {
        var SessionCookie = kookie_retrieve();

        console.log("Retrieving session ", SessionCookie);
        if (SessionCookie != "undefined") {
            nano_manager.defaultECI = SessionCookie;
        } else {
            nano_manager.defaultECI = "none";
        }
        return nano_manager.defaultECI;
    };

    // ------------------------------------------------------------------------
    nano_manager.saveSession = function(token_json)
    {
       var Session_ECI = token_json.OAUTH_ECI;
       var access_token = token_json.access_token;
       console.log("Saving session for ", Session_ECI);
       nano_manager.defaultECI = Session_ECI;
       nano_manager.access_token = access_token;
       kookie_create(Session_ECI);
   };
    // ------------------------------------------------------------------------
    nano_manager.removeSession = function(hard_reset)
    {
        console.log("Removing session ", nano_manager.defaultECI);
        if (hard_reset) {
            var cache_breaker = Math.floor(Math.random() * 9999999);
            var reset_url = 'https://' + nano_manager.login_server + "/login/logout?" + cache_breaker;
            $.ajax({
                type: 'POST',
                url: reset_url,
                headers: { 'Kobj-Session': nano_manager.defaultECI },
                success: function(json)
                {
                    console.log("Hard reset on " + nano_manager.login_server + " complete");
                }
            });
        }
        nano_manager.defaultECI = "none";
        kookie_delete();
    };

    // ------------------------------------------------------------------------
    nano_manager.authenticatedSession = function()
    {
        var authd = nano_manager.defaultECI != "none";
        if (authd) {
            console.log("Authenicated session");
        } else {
            console.log("No authenicated session");
        }
        return (authd);
    };

    // exchange OAuth code for token
    // updated this to not need a query to be passed as it wasnt used in the first place.
    nano_manager.retrieveOAuthCode = function()
    {
        var code = getQueryVariable("code");
        return (code) ? code : "NO_OAUTH_CODE";
    };

    function getQueryVariable(variable)
    {
        var query = window.location.search.substring(1);
        var vars = query.split('&');
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split('=');
            if (decodeURIComponent(pair[0]) == variable) {
                return decodeURIComponent(pair[1]);
            }
        }
        console.log('Query variable %s not found', variable);
        return false;
    };

    nano_manager.clean = function(obj) {
       delete obj._type;
       delete obj._domain;
       delete obj._async;

   };

   var SkyTokenName = '__SkySessionToken';
   var SkyTokenExpire = 7;

    // --------------------------------------------
    function kookie_create(SkySessionToken)
    {
        if (SkyTokenExpire) {
            // var date = new Date();
            // date.setTime(date.getTime() + (SkyTokenExpire * 24 * 60 * 60 * 1000));
            // var expires = "; expires=" + date.toGMTString();
            var expires = "";
        }
        else var expires = "";
        var kookie = SkyTokenName + "=" + SkySessionToken + expires + "; path=/";
        document.cookie = kookie;
        // console.debug('(create): ', kookie);
    }

    // --------------------------------------------
    function kookie_delete()
    {
        var kookie = SkyTokenName + "=foo; expires=Thu, 01-Jan-1970 00:00:01 GMT; path=/";
        document.cookie = kookie;
        // console.debug('(destroy): ', kookie);
    }

    // --------------------------------------------
    function kookie_retrieve()
    {
        var TokenValue = 'undefined';
        var TokenName = '__SkySessionToken';
        var allKookies = document.cookie.split('; ');
        for (var i = 0; i < allKookies.length; i++) {
            var kookiePair = allKookies[i].split('=');
            // console.debug("Kookie Name: ", kookiePair[0]);
            // console.debug("Token  Name: ", TokenName);
            if (kookiePair[0] == TokenName) {
                TokenValue = kookiePair[1];
            };
        }
        // console.debug("(retrieve) TokenValue: ", TokenValue);
        return TokenValue;
    }

})();
