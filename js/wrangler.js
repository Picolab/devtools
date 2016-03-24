; (function()
    /**
     * @fileOverview Wrangler javascript API.
     * @author <a href="mailto:picos@byu.edu">PicoLab</a>
     * @version 1.0.0
     * @since 1.0.0
     * @deprecated CloudOS.js has been improved and released as Wrangler. The improvements include cleaner coding practices and removal of dead code.
     * @example <caption> example usage of Wrangler API.</caption>
     * showInstalledRulesets: function(callback, options) 
     * {
     *   var parameters = {};
     *   callback = callback || function(){};
     *   post_function = function(json) {
     *       console.log("Displaying installed rulesets", json);
     *       callback(json);
     *   };
     *   return wrangler.installedRulesetsWithDiscription(parameters, post_function, options);
     * }
     */
{
    window.wrangler = {};

    // ------------------------------------------------------------------------

    wrangler.defaultECI = "none";
    wrangler.access_token = "none";

/**
 * check_eci , returns a valid cid.......
 * @param  {String} cid, channel id.
 * @return {String} returns the cid, if no cid passed then check_eci returns wrangler.defaultECI.
 */
    var check_eci = function(cid) {
       var res = cid || wrangler.defaultECI;
       if (res === "none") {
           throw "No wrangler event channel identifier (ECI) defined";
       }
       return res;
   };

   var mkEsl = function(parts) {
    if (wrangler.host === "none") {
        throw "No wrangler host defined";
    }
    parts.unshift(wrangler.host); // adds host to beginning of array
    var res = 'https://'+ parts.join("/"); // returns a url structure string
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

    // use status return type to through javascript exception ... 

/**
 * raiseEvent, Raise event to the server specified in wrangler-config.js with the given attributes as well as a randomly created event id between 0 and 9999999.
 * @param {string} eventDomain, domain of event being raised.
 * @param  {string} eventType,  type of event being raised.
 * @param  {object} eventAttributes
 * @param  {Function} callback, function to be called on success.
 * @param  {object} options contain eci to be used, eci defaults to PicoNavigator.currentPico and then to wrangler.defaultECI.
 * @return returns null.
 * @throws {"No wrangler host defined"} If wrangler.host === "none" 
 * @throws {"No wrangler event channel identifier (ECI) defined"} If no channel id is passed and no default event channel id is not found.
 * @interface raiseEvent is used by other functions to raise events.
 */
    wrangler.raiseEvent = function(eventDomain, eventType, eventAttributes, callback, options)
    {
     try {

       options = options || {};
       options.eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI; //<-- is this vallid?

       callback = callback || function(){};

       var eci = check_eci(options.eci);
           var eid = Math.floor(Math.random() * 9999999); // whats the event id used for and do we need it?
           //url constructor
           var esl = mkEsl(
            //['sky/event',
            [ wrangler.eventPath ,
            eci,
            eid,
            eventDomain,
            eventType
            ]);

         console.log("wrangler.raise ESL: ", esl);
         console.log("event attributes: ", eventAttributes);

         return $.ajax({
          type: 'POST',
          url: esl,
          data: $.param(eventAttributes),
          dataType: 'json',
      		headers: { 'Kobj-Session': eci }, // not sure needed since eci in URL
      		success: callback,
      		error: options.errorFunc || function(res) { console.error(res) }
        });
       } catch(error) {
         console.error("[raise]", error);
         return null;
       }
     };

    wrangler.skyQuery = function(module, func_name, parameters, getSuccess, options)
    {
      //put options stuff here.
    	try {
          options = options || {};
          options.eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI; //<-- is this vallid?
          var retries = 2;

          if (typeof options.repeats !== "undefined") {
              console.warn("This is a repeated request: ", options.repeats);
              if (options.repeats > retries) {
                throw "terminating repeating request due to consistent failure.";
            }
        }

        var eci = check_eci(options.eci);
        //url constructor
        var esl = mkEsl(
          //['sky/cloud',
          [ wrangler.functionPath ,
            module,
            func_name
            ]);

        $.extend(parameters, { "_eci": eci });

        console.log("Attaching event parameters ", parameters);
        // should this go in mkEsl ?
        esl = esl + "?" + $.param(parameters);

        var process_error = function(res)
        {
          console.error("skyQuery Server Error with esl ", esl, res);
          if (typeof options.errorFunc === "function") {
            options.errorFunc(res);
        }
    };

    var process_result = function(res) // whats this for???
    {
      console.log("Seeing res ", res, " for ", esl);
      var sky_cloud_error = typeof res === 'Object' && typeof res.skyQueryError !== 'undefined';
      if (! sky_cloud_error ) {
        getSuccess(res);
    } else {
        console.error("skyQuery Error (", res.skyQueryError, "): ", res.skyQueryErrorMsg);
        if (!!res.httpStatus && 
         !!res.httpStatus.code && 
         (parseInt(res.httpStatus.code) === 400 || parseInt(res.httpStatus.code) === 500)) 
        {
         console.error("The request failed due to an ECI error. Going to repeat the request.");
         var repeat_num = (typeof options.repeats !== "undefined") ? ++options.repeats : 0;
         options.repeats = repeat_num;
    			// I don't think this will support promises; not sure how to fix
    			wrangler.skyQuery(module, func_name, parameters, getSuccess, options);
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
       console.error("[skyQuery]", error);
       if (typeof options.errorFunc === "function") {
          options.errorFunc();
      } 
      return null;
    }
    };



    // ------------------------------------------------------------------------ spime testing 
    wrangler.createSpime = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("spime", "create_spime", eventAttributes, postFunction, options);
    };



    // ------------------------------------------------------------------------ installed Rulests
    // function(eventDomain, eventType, eventAttributes, postFunction, options) // <--- raiseEvent paramiters 


    wrangler.installedRulesets = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "rulesets", parameters, postFunction , options); 
    };

    wrangler.describeRulesets = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "rulesetsInfo", parameters, postFunction , options); 
    };

    wrangler.installedRulesetsWithDiscription = function(parameters, postFunction, options)
    {
      return wrangler.installedRulesets({},function(rids){
        console.log("rids.rids", rids.rids);
         return wrangler.skyQuery(get_rid("rulesets"), "rulesetsInfo", {'rids':rids.rids.join(';')}, postFunction , options);
      }, options);
    };

    wrangler.installRulesets = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "install_rulesets_requested", eventAttributes, postFunction, options);
    };

    wrangler.uninstallRuleset = function( eventAttributes, postFunction, options)
    {
        console.log("uninstalling ruleset: ",eventAttributes.eci);
        var results = wrangler.raiseEvent("wrangler", "uninstall_rulesets_requested", eventAttributes,  postFunction, options);
        console.log("uninstalled rulesets: ", eventAttributes.eci);
        return results;
    };

    // ------------------------------------------------------------------------ Channels
        wrangler.channels = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "channels", parameters, postFunction , options); 
    };
        wrangler.channel = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "channel", parameters, postFunction , options); 
    };
        wrangler.channelAttributes = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "channelAttributes", parameters, postFunction , options); 
    };
        wrangler.channelPolicy = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "channelPolicy", parameters, postFunction , options); 
    };
        wrangler.channelType = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "channelType", parameters, postFunction , options); 
    };

    wrangler.updateChannelAttributes = function( eventAttributes,  postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "update_channel_attributes_requested", eventAttributes, postFunction, options);
    };    
    wrangler.updateChannelPolicy = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "update_channel_policy_requested", eventAttributes, postFunction, options);
    };    
    wrangler.deleteChannel = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "channel_deletion_requested", eventAttributes, postFunction, options);
    };   
    wrangler.createChannel = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "channel_creation_requested", eventAttributes, postFunction, options);
    };

    // ------------------------------------------------------------------------ pico
        wrangler.children = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "children", parameters, postFunction , options); 
    };
        wrangler.parent = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "parent", parameters, postFunction , options); 
    };
        wrangler.name = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "name", parameters, postFunction , options); 
    };
        wrangler.attributes = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "attributes", parameters, postFunction , options); 
    };

     wrangler.createChild = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "child_creation", eventAttributes, postFunction, options);
    }; 
     wrangler.initializeChild = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "child_created", eventAttributes, postFunction, options);
    }; 
     wrangler.setPicoAttributes = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "set_attributes_requested", eventAttributes, postFunction, options);
    }; 
     wrangler.clearPicoAttributes = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "clear_attributes_requested", eventAttributes, postFunction, options);
    }; 
     wrangler.deleteChild = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "child_deletion", eventAttributes, postFunction, options);
    }; 
    // ------------------------------------------------------------------------ subscription

    wrangler.subscriptions = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "subscriptions", parameters, postFunction , options); 
    };
        wrangler.channelByName = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "channelByName", parameters, postFunction , options); 
    };
        wrangler.channelByEci = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "channelByEci", parameters, postFunction , options); 
    };
        wrangler.subscriptionsAttributesEci = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "subscriptionsAttributesEci", parameters, postFunction , options); 
    };
        wrangler.subscriptionsAttributesName = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "subscriptionsAttributesName", parameters, postFunction , options); 
    };
         wrangler.requestSubscription = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "subscription", eventAttributes, postFunction, options);
    }; 
         wrangler.addPendingSubscription = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "pending_subscription", eventAttributes, postFunction, options);
    }; 
         wrangler.approvePendingSubscription = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "pending_subscription_approval", eventAttributes, postFunction, options);
    }; 
         wrangler.addSubscription = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "pending_subscription_approved", eventAttributes, postFunction, options);
    }; 

         wrangler.cancelSubscription = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "subscription_cancellation", eventAttributes, postFunction, options);
    }; 
        wrangler.rejectInBoundSubscription = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "inbound_subscription_rejection", eventAttributes, postFunction, options);
    }; 
        wrangler.cancelOutBoundSubscription = function( eventAttributes, postFunction, options)
    {
        return wrangler.raiseEvent("wrangler", "outbound_subscription_cancellation", eventAttributes, postFunction, options);
    }; 
    // ------------------------------------------------------------------------ other

        wrangler.currentSession = function(parameters, postFunction, options)
    {
        return wrangler.skyQuery(get_rid("rulesets"), "currentSession", parameters, postFunction , options); 
    };
		wrangler.bootstrapCheck = function(postFunction, options)
	{
		return wrangler.skyQuery(get_rid("bootstrap"), "installedRulesets", {}, postFunction, options);
	};




    // ========================================================================
    // Profile Management

    wrangler.getMyProfile = function(getSuccess)
    {
        return wrangler.skyQuery("a169x676", "get_all_me", {}, function(res) {
           clean(res);
           if(typeof getSuccess !== "undefined"){
              getSuccess(res);
          }
      });
    };

    wrangler.updateMyProfile = function(eventAttributes, postFunction)
    {
        var eventParameters = { "element": "profileUpdate.post" };
        return wrangler.raiseEvent('web', 'submit', eventAttributes, postFunction);
    };

    wrangler.getFriendProfile = function(friendToken, getSuccess)
    {
        var parameters = { "myToken": friendToken };
        return wrangler.skyQuery("a169x727", "getFriendProfile", parameters, getSuccess);
    };

    // ========================================================================
    // PDS Management

    // ------------------------------------------------------------------------
    wrangler.PDSAdd = function(namespace, pdsKey, pdsValue, postFunction)
    {
        var eventAttributes = {
            "namespace": namespace,
            "pdsKey": pdsKey,
            "pdsValue": JSON.stringify(pdsValue)
        };

        return wrangler.raiseEvent('wrangler', 'api_pds_add', eventAttributes, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    wrangler.PDSDelete = function(namespace, pdsKey, postFunction)
    {
        var eventAttributes = {
            "namespace": namespace,
            "pdsKey": pdsKey
        };

        return wrangler.raiseEvent('wrangler', 'api_pds_delete', eventAttributes, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    wrangler.PDSUpdate = function()
    {
    };

    // ------------------------------------------------------------------------
    wrangler.PDSList = function(namespace, getSuccess)
    {
        var callParmeters = { "namespace": namespace };
        return wrangler.skyQuery("pds", "get_items", callParmeters, getSuccess);
    };

    // ------------------------------------------------------------------------
    wrangler.sendEmail = function(ename, email, subject, body, postFunction)
    {
        var eventAttributes = {
            "ename": ename,
            "email": email,
            "subject": subject,
            "body": body
        };
        return wrangler.raiseEvent('wrangler', 'api_send_email', eventAttributes, {}, postFunction);
    };

    // ------------------------------------------------------------------------
    wrangler.sendNotification = function(application, subject, body, priority, token, postFunction)
    {
        var eventAttributes = {
            "application": application,
            "subject": subject,
            "body": body,
            "priority": priority,
            "token": token
        };
        return wrangler.raiseEvent('wrangler', 'api_send_notification', eventAttributes, {}, postFunction);
    };


    // ========================================================================
    // Login functions
    // ========================================================================
    wrangler.login = function(username, password, success, failure) {


       var parameters = {"email": username, "pass": password};

       if (typeof wrangler.anonECI === "undefined") {
           console.error("wrangler.anonECI undefined. Configure wrangler.js in wrangler-config.js; failing...");
           return null;
       }

       return wrangler.skyQuery("wrangler",
        "cloudAuth", 
        parameters, 
        function(res){
				    // patch this up since it's not OAUTH
				    if(res.status) {
                       var tokens = {"access_token": "none",
                       "OAUTH_ECI": res.token
                   };
                   wrangler.saveSession(tokens); 
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
           {eci: wrangler.anonECI,
               errorFunc: failure
           }
           );


   };



    // ========================================================================
    // OAuth functions
    // ========================================================================

    // ------------------------------------------------------------------------
    wrangler.getOAuthURL = function(fragment)
    {
        if (typeof wrangler.login_server === "undefined") {
            wrangler.login_server = wrangler.host;
        }


        var client_state = Math.floor(Math.random() * 9999999);
        var current_client_state = window.localStorage.getItem("wrangler_CLIENT_STATE");
        if (!current_client_state) {
            window.localStorage.setItem("wrangler_CLIENT_STATE", client_state.toString());
        }
        var url = 'https://' + wrangler.login_server +
        '/oauth/authorize?response_type=code' +
        '&redirect_uri=' + encodeURIComponent(wrangler.callbackURL + (fragment || "")) +
        '&client_id=' + wrangler.clientKey +
        '&state=' + client_state;

        return (url)
    };

    wrangler.getOAuthNewAccountURL = function(fragment)
    {
        if (typeof wrangler.login_server === "undefined") {
            wrangler.login_server = wrangler.host;
        }


        var client_state = Math.floor(Math.random() * 9999999);
        var current_client_state = window.localStorage.getItem("wrangler_CLIENT_STATE");
        if (!current_client_state) {
            window.localStorage.setItem("wrangler_CLIENT_STATE", client_state.toString());
        }
        var url = 'https://' + wrangler.login_server +
        '/oauth/authorize/newuser?response_type=code' +
        '&redirect_uri=' + encodeURIComponent(wrangler.callbackURL + (fragment || "")) +
        '&client_id=' + wrangler.clientKey +
        '&state=' + client_state;

        return (url)
    };

//https://kibdev.kobj.net/oauth/authorize/newuser?response_type=code&redirect_uri=http%3A%2F%2Fjoinfuse.com%2Fcode.html&client_id=D98022C6-C4F4-11E3-942D-E857D61CF0AC&state=6970625


    // ------------------------------------------------------------------------
    wrangler.getOAuthAccessToken = function(code, callback, error_func)
    {
        var returned_state = parseInt(getQueryVariable("state"));
        var expected_state = parseInt(window.localStorage.getItem("wrangler_CLIENT_STATE"));
        if (returned_state !== expected_state) {
            console.warn("OAuth Security Warning. Client states do not match. (Expected %d but got %d)", wrangler.client_state, returned_state);
        }
        console.log("getting access token with code: ", code);
        if (typeof (callback) !== 'function') {
            callback = function() { };
        }
        var url = 'https://' + wrangler.login_server + '/oauth/access_token';
        var data = {
            "grant_type": "authorization_code",
            "redirect_uri": wrangler.callbackURL,
            "client_id": wrangler.clientKey,
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
                wrangler.saveSession(json);
                window.localStorage.removeItem("wrangler_CLIENT_STATE");
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
    wrangler.retrieveSession = function()
    {
        var SessionCookie = kookie_retrieve();

        console.log("Retrieving session ", SessionCookie);
        if (SessionCookie != "undefined") {
            wrangler.defaultECI = SessionCookie;
        } else {
            wrangler.defaultECI = "none";
        }
        return wrangler.defaultECI;
    };

    // ------------------------------------------------------------------------
    wrangler.saveSession = function(token_json)
    {
       var Session_ECI = token_json.OAUTH_ECI;
       var access_token = token_json.access_token;
       console.log("Saving session for ", Session_ECI);
       wrangler.defaultECI = Session_ECI;
       wrangler.access_token = access_token;
       kookie_create(Session_ECI);
   };
    // ------------------------------------------------------------------------
    wrangler.removeSession = function(hard_reset)
    {
        console.log("Removing session ", wrangler.defaultECI);
        if (hard_reset) {
            var cache_breaker = Math.floor(Math.random() * 9999999);
            var reset_url = 'https://' + wrangler.login_server + "/login/logout?" + cache_breaker;
            $.ajax({
                type: 'POST',
                url: reset_url,
                headers: { 'Kobj-Session': wrangler.defaultECI },
                success: function(json)
                {
                    console.log("Hard reset on " + wrangler.login_server + " complete");
                }
            });
        }
        wrangler.defaultECI = "none";
        kookie_delete();
    };

    // ------------------------------------------------------------------------
    wrangler.authenticatedSession = function()
    {
        var authd = wrangler.defaultECI != "none";
        if (authd) {
            console.log("Authenicated session");
        } else {
            console.log("No authenicated session");
        }
        return (authd);
    };

    // exchange OAuth code for token
    // updated this to not need a query to be passed as it wasnt used in the first place.
    wrangler.retrieveOAuthCode = function()
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

    wrangler.clean = function(obj) {
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
