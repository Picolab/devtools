(function($) {
     window['Devtools'] = { //window represents the browser window
        //by putting it in window, it's essentially greating a global variable

        // development settings.
        //VERSION: 0.1,

        defaults: {
            logging: false,  // false to turn off logging
            production: false
        },


	get_rid : function(name) {
        
        var rids = {
            "rulesets": {"prod": "b507199x0.prod", 
                          "dev": "b507199x0.dev"
            },
            "bootstrap":{"prod": "b507199x1.prod", 
                          "dev": "b507199x1.dev"
            },
            "cloud_os":{"prod": "a169x625.prod", 
                          "dev": "a169x625.prod"
            }
        };

	    return this.defaults.production ? rids[name].prod : rids[name].dev;
	},

    rid_eci: null, //fleet_eci
    rid_summary: {}, //vehicle_summary
    rid_list: [], //vehicles


    log: function() {
        if (this.defaults.logging && console && console.log) {
            [].unshift.call(arguments, "Devtools:"); // arguments is Array-like, it's not an Array 
            console.log.apply(console, arguments);
        }
    },

    getProfile: function(channel, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
            Devtools.log("Retrieving profile for user");

        return CloudOS.skyCloud("a169x676", "get_all_me", {}, function(res) { //fix this up. what rule is this calling?
            CloudOS.clean(res);
            if(typeof cb !== "undefined"){
                cb(res);
            }
        },
        {"eci": channel});
    },

    bootstrapped: function(cb,options){
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("bootstrapped ??");
        return CloudOS.skyCloud(Devtools.get_rid("bootstrap"), "testingReturns", {}, function(json) {
            Devtools.log("Displaying testingReturns", json);
            cb(json);
        }, {"eci":eci});
    },

    getRulesets: function(cb, options) //almost like getProfile in fuse-api.js
    {
        cb = cb || function(){};
        options = options || {};
        //var rid = "rulesets";
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Showing the rulesets");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showRulesets", {}, function(json) {
            Devtools.log("Displaying rulesets", json);
            cb(json);
        }, {"eci":eci});
    },

    status: function(cb, options){
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Showing the channels");
        //return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "rulesetList", {}, function(json) {
        return CloudOS.skyCloud(Devtools.get_rid("cloud_os"), "rulesetList", {}, function(json) {
            Devtools.log("Displaying installed rulesets", json);
            cb(json);
        }, {"eci":eci});   
    },
// ---------- account ----------
    // this is called in _layouts/code.html when the account is created
    initAccount: function(attrs, cb, options)
        {
        cb = cb || function(){};
        options = options || {};
        attrs = attrs || {};
            Devtools.log("Initializing account for user with attributes ", attrs);

            return CloudOS.raiseEvent("devtools", "bootstrap", {}, {}, function(response)
            {
        // note that because the channel is create asynchronously, processing callback does
        // NOT mean the channel exists. 
        //        Devtools.log("account initialized");
        if(response.length < 1) {
            throw "Account initialization failed";
        }
        cb(response);
            });
        },


    about: function(cb, options) 
    {
        cb = cb || function(){};
        options = options || {};
        var json = {rids: rid,url: url}; //not sure what this does
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Getting info about pico ");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "aboutPico", {}, function(json) {
            Devtools.log("This pico: ", json);
            cb(json);
        }, {"eci":eci});
    },

//---------the functions for updating rulesets

    updateUrl: function(rid, url, cb, options) //basing this off of updateCarvoyantVehicle
    {
        cb = cb || function(){};
        options = options || {};
        var json = {rids: rid,url: url}; //not sure what this does
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Updating the URL");
        return CloudOS.raiseEvent("devtools", "update_url", json, {}, function(json) {
            Devtools.log("Directive from updating URL", json);
            cb(json);
        }, {"eci":eci});
    },

    flushRID: function(rid, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var json = {rid: rid}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Flushing RID " + rid);
        return CloudOS.raiseEvent("devtools", "flush_rid", json, {}, function(json) {
            Devtools.log("Directive from Flushing Rid", json);
            cb(json);
        }, {"eci":eci});
    },

    deleteRID: function(rid, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var json = {rid: rid}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Deleting RID " + rid);
        return CloudOS.raiseEvent("devtools", "delete_rid", json, {}, function(json) {
            Devtools.log("Directive from Deleting Rid", json);
            cb(json);
        }, {"eci":eci});
    },


    showInstalledRulesets: function(cb, options) // PJW
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Showing the rulesets");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showInstalledRulesets", {}, function(json) {
            Devtools.log("Displaying installed rulesets", json);
            cb(json);
        }, {"eci":eci});
    },

    installRulesets: function(ridlist, cb, options) // PJW
    {
        cb = cb || function(){};
        options = options || {};
	var json = {rids: ridlist}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Installing rulesets");
        return CloudOS.raiseEvent("devtools", "install_rulesets", json, {}, function(json) {
            Devtools.log("Directive from installing rulesets", json);
            cb(json);
        }, {"eci":eci});
    },

    uninstallRulesets: function(ridlist, cb, options) // PJW
    {
        cb = cb || function(){};
        options = options || {};
	var json = {rids: ridlist}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Uninstalling rulesets");
        return CloudOS.raiseEvent("devtools", "uninstall_rulesets", json, {}, function(json) {
            Devtools.log("Directive from uninstalling rulesets", json);
            cb(json);
        }, {"eci":eci});
    },
    RegisterRuleset: function(url,cb,options)
    {
        cb = cb || function(){};
        options = options || {};
    var json = {rulesetURL: url}; // json for attribute thats passed to the ruleset as eventattribute 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Registering rulesets");
        return CloudOS.raiseEvent("devtools", "register_ruleset", json, {}, function(json) {
            Devtools.log("Directive from register ruleset", json);
            cb(json);
        }, {"eci":eci});
    },

    //--------------------------------Channels mannagement----------------------
    showInstalledChannels: function(cb, options) // copied PJW
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Showing the channels");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showInstalledChannels", {}, function(json) {
            Devtools.log("Displaying installed channels", json);
            cb(json);
        }, {"eci":eci});
    },
    installChannel: function(channel_name, cb, options) 
    {
        cb = cb || function(){};
        options = options || {};
    var parameters = {channelName:channel_name}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Installing channels");
       return CloudOS.raiseEvent("devtools", "create_channel", parameters,{}, function(json) {
           Devtools.log("Directive from create channel", json);
           cb(json);
       }, {"eci":eci});
    },
    uninstallChannel: function(ECI, cb, options) 
    {
        cb = cb || function(){};
        options = options || {};
    var json = {channel_id:ECI}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Destroy channels");
        return CloudOS.raiseEvent("devtools", "channel_destroy", json,{}, function(json) {
           Devtools.log("Directive from create channel", json);
           cb(json);
        }, {"eci":eci});

    },
    //---------------------------------Authorize Client mannagement----------------
    authorizeClient: function(app_Data, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("authorizing clientlient ");
       return CloudOS.raiseEvent("devtools", "authorize_client", app_Data,{}, function(json) {
           Devtools.log("Directive from AuthorizeClient", json);
           cb(json);
       }, {"eci":eci});
    },
	showAuthorizedClients: function(cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Showing the showing clients");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showClients", {}, function(json) {
            Devtools.log("Displaying athorize clients", json);
            cb(json);
        }, {"eci":eci});
    },
    removeClient: function(app_ECI, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var json = {"appECI":app_ECI}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("remove client");
        console.log("attributes",json);
        return CloudOS.raiseEvent("devtools", "remove_client", json,{}, function(json) {
           Devtools.log("Directive from remove client", json);
           cb(json);
        }, {"eci":eci});
    },
    updateClient: function(app_ECI, app_Data, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        app_Data["appECI"]=app_ECI;
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Updating client");
        return CloudOS.raiseEvent("devtools", "update_client", app_Data, {}, function(json) {
            Devtools.log("Directive from updating Client", json);
            cb(json);
        }, {"eci":eci});
    },

    showScheduledEvents: function(cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("show scheduled events");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showScheduledEvents", {}, function(json) {
            Devtools.log("Displaying scheduled events", json);
            cb(json);
        }, {"eci":eci});   
    },
    /*scheduleEvent: function(Data, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("scheduling event");
       return CloudOS.raiseEvent("devtools", "event_scheduled", Data,{}, function(json) {
           Devtools.log("Directive from ScheduleEvent", json);
           cb(json);
       }, {"eci":eci});
    },*/
    //TESTING CODE WRITTEN IN NANO MANAGER
   scheduleEvent: function(data, cb, options) 
    {
        cb = cb || function(){};
        options = options || {};
        var parameters = {channelName:channel_name}; 
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Installing channels");
       return CloudOS.raiseEvent("nano_manager", "scheduled_created", data,{}, function(json) {
           Devtools.log("Creating a scheduled event", json);
           cb(json);
       }, {"eci":eci});
    },
    //-------------------Subscriptions--------------------
    showSubscriptions: function(cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("show Subscriptions");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showSubscriptions", {}, function(json) {
            Devtools.log("Displaying showSubscriptions", json);
            cb(json);
        }, {"eci":eci});  
    },
    showIncoming: function(cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("show Incoming");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showIncoming", {}, function(json) {
            Devtools.log("Displaying showIncoming", json);
            cb(json);
        }, {"eci":eci});  
    },
    showOutgoing: function(cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("show OutGoing");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showOutgoing", {}, function(json) {
            Devtools.log("Displaying showOutGoing", json);
            cb(json);
        }, {"eci":eci});  
    },
    ApproveSubscription: function(event_channel, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("approve subscription");
       return CloudOS.raiseEvent("devtools", "incoming_request_approved", event_channel,{}, function(json) {
           Devtools.log("Directive from ApproveSubscription", json);
           cb(json);
       }, {"eci":eci});
    },
    RequestSubscription: function(data, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Request subscription");
       return CloudOS.raiseEvent("devtools", "subscribe", data,{}, function(json) {
           Devtools.log("Directive from RequestSubscription", json);
           cb(json);
       }, {"eci":eci});
    },
    RejectIncomingSubscription: function(data, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("reject in coming subscription");
       return CloudOS.raiseEvent("devtools", "incoming_request_rejected", data,{}, function(json) {
           Devtools.log("Directive from incoming_request_rejected", json);
           cb(json);
       }, {"eci":eci});
    },
    Unsubscribe: function(data, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("unsubscription");
       return CloudOS.raiseEvent("devtools", "init_unsubscribed", data,{}, function(json) {
           Devtools.log("Directive from init_unsubscribed", json);
           cb(json);
       }, {"eci":eci});
    },
   RejectOutgoingSubscription: function(data, cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("cancel subscription request");
       return CloudOS.raiseEvent("devtools", "out_going_request_rejected_by_origin", data,{}, function(json) {
           Devtools.log("Directive from out_going_request_rejected_by_origin", json);
           cb(json);
       }, {"eci":eci});
    }
//
}; //closes the "window" inside the function DON'T DELETE

//----------------------------------

    function isEmpty(obj) {

        // null and undefined are "empty"
        if (obj === null) return true;

        // Assume if it has a length property with a non-zero value
        // that that property is correct.
        if (obj.length > 0)    return false;
        if (obj.length === 0)  return true;

        // Otherwise, does it have any properties of its own?
        // Note that this doesn't handle
        // toString and valueOf enumeration bugs in IE < 9
        for (var key in obj) {
                if (hasOwnProperty.call(obj, key)) return false;
        }

        return true;


        }

    

})(jQuery);
