(function($) {
     window.Devtools = { //window represents the browser window
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
            }
        };

	    return this.defaults.production ? rids[name].prod : rids[name].dev;
	},
    // whats this for?
    rid_eci: null, //fleet_eci
    rid_summary: {}, //vehicle_summary
    rid_list: [], //vehicles
    // ------------------------------------------------------------------------ bootStrap/ utilities

    log: function() {
        if (this.defaults.logging && console && console.log) {
            [].unshift.call(arguments, "Devtools:"); // arguments is Array-like, it's not an Array 
            console.log.apply(console, arguments);
        }
    },


    bootstrapped: function(cb,options){
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI;
        Devtools.log("bootstrapped?");
        return wrangler.skyCloud(Devtools.get_rid("bootstrap"), "testingReturns", {}, function(json) {
            Devtools.log("Displaying testingReturns", json);
            cb(json);
        }, {"eci":eci});
    },
	
	ensureBootstrap: function(cb, options){
		cb = cb || function(){};
		options = options || {};
		var eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI;
		Devtools.log("Ensuring Bootstrap for " + eci);
		
		//Check for wrangler and devtools on pico.. could this be a rule in bootrap rulesets?
		checkForBootstrapped = function(justNeedsBootstrap, needsBootstrapRuleset) {
            return wrangler.bootstrapCheck(function(json) {
				console.log(json);
				if ($.inArray('b507199x0.dev', json.rids) > -1 && $.inArray('b507199x5.dev', json.rids) > -1) {
					console.log("Pico is bootstrapped");
					cb();
				}
				else if ($.inArray('b507199x1.dev', json.rids) > -1) { // will never make it here ...
					justNeedsBootstrap();
				}
				else {
					needsBootstrapRuleset();
				}
			}, {"eci":eci});
		};
		
		//Add bootstrap ruleset, this will do nothing if primary is missing bootstrap.
		addBootstrapRuleset = function(localCB) {
			return wrangler.raiseEvent("bootstrap", "bootstrap_rid_needed_on_child", {"target":eci}, function(json) {
	            //console.log("Directive from installing bootstrap", json);
				localCB();
			}, {"eci":wrangler.defaultECI});
		};
		
		//attempt bootstrap
		bootstrapPico = function(localCB) {
			wrangler.raiseEvent("devtools", "bootstrap", {}, function(response) {
				localCB();
			}, {"eci":eci}); // where is this eci coming from? should you pass options and let wrangler default handle this?
		};
		
        var timeToWait = 0;
        var timeStep = 500;
		stallBootstrap = function(localCB) {
            //timer for bootstrapping
			if (timeToWait >= 10 * timeStep) {
				throw "Bootstrap failed consistently";
			}
			else {
				setTimeout(function() {
					timeToWait += timeStep;
					localCB();
				}, timeToWait);
			}
		};
		
		
		//tie together and run
		persistent_bootstrap = function() {
			checkForBootstrapped(function() {
				console.log("NOT bootstrapped");
				stallBootstrap(function() {
					bootstrapPico(persistent_bootstrap);
				})
			}, function() {
				console.log("NEEDS bootstrap ruleset");
				addBootstrapRuleset(function() {
					stallBootstrap(function() {
						bootstrapPico(persistent_bootstrap);
					})
				})
				
			});
		};
		
		persistent_bootstrap();
		
	},
        // this is called in _layouts/code.html when the account is created
    initAccount: function(attrs, cb, options)
        {
        cb = cb || function(){};
        attrs = attrs || {};
            Devtools.log("Initializing account for user with attributes ", attrs);

            return wrangler.raiseEvent("devtools", "bootstrap", {}, function(response)
            {
        // note that because the channel is create asynchronously, processing callback does
        // NOT mean the channel exists. 
        //        Devtools.log("account initialized");
        if(response.length < 1) {
            throw "Account initialization failed";
        }
        cb(response);
            },options);
        },

    status: function(cb, options){ 
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI;
        Devtools.log("Showing the channels");
        return wrangler.installedRulesets({}, function(json) {
            Devtools.log("Displaying installed rulesets", json);
            cb(json);
        }, {"eci":eci});   
    },

// ------------------------------------------------------------------------ Rulesets 
    getRulesets: function(cb, options) //almost like getProfile in fuse-api.js
    {
        cb = cb || function(){};
        options = options || {};
        //var rid = "rulesets";
        var eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI;
        Devtools.log("Showing the rulesets");
        return wrangler.skyCloud(Devtools.get_rid("rulesets"), "showRulesets", {}, function(json) {
            Devtools.log("Displaying rulesets", json);
            cb(json);
        }, {"eci":eci});
    },

    RegisterRuleset: function(url,cb,options)
    {
        cb = cb || function(){};
    var json = {ruleset_url: url}; // json for attribute thats passed to the ruleset as eventattribute 
        Devtools.log("Registering rulesets");
        return wrangler.raiseEvent("devtools", "register_ruleset", json, function(json) {
            Devtools.log("Directive from register ruleset", json);
            cb(json);
        }, options);
    },

    updateUrl: function(rid, url, cb, options) //basing this off of updateCarvoyantVehicle
    {
        cb = cb || function(){};
        var json = {rid: rid,url: url}; 
        Devtools.log("Updating the URL");
        return wrangler.raiseEvent("devtools", "update_url", json, function(json) {
            Devtools.log("Directive from updating URL", json);
            cb(json);
        }, options);
    },

    flushRID: function(rid, cb, options)
    {
        cb = cb || function(){};
        var json = {rid: rid}; 
        Devtools.log("Flushing RID " + rid);
        return wrangler.raiseEvent("devtools", "flush_rid", json, function(json) {
            Devtools.log("Directive from Flushing Rid", json);
            cb(json);
        }, options);
    },

    deleteRID: function(rid, cb, options)
    {
        cb = cb || function(){};
        var json = {rid: rid}; 
        Devtools.log("Deleting RID " + rid);
        return wrangler.raiseEvent("devtools", "delete_rid", json, function(json) {
            Devtools.log("Directive from Deleting Rid", json);
            cb(json);
        }, options);
    },

// ------------------------------------------------------------------------ installed Rulesets 

    showInstalledRulesets: function(cb, options) 
    {
        var parameters = {};
        Devtools.log("Showing installed rulesets");
        cb = cb || function(){};
        post_function = function(json) {
            Devtools.log("Displaying installed rulesets", json);
            cb(json);
        };
        return wrangler.installedRulesetsWithDiscription(parameters, post_function, options);
    },

    installRulesets: function(ridlist, cb, options) 
    {

        var attributes = {rids: ridlist}; 
        Devtools.log("Installing rulesets");
        cb = cb || function(){};
        post_function = function(json) {
            Devtools.log("Directive from installing rulesets", json);
            cb(json);
        };

        return wrangler.installRulesets(attributes,post_function,options);

    },

    uninstallRulesets: function(ridlist, cb, options) 
    {

        var attributes = {rids: ridlist}; 
        Devtools.log("Uninstalling rulesets",ridlist);
        cb = cb || function(){};
        post_function = function(json) {
            Devtools.log("Directive from uninstalling rulesets", json);
            cb(json);
        };

        return wrangler.uninstallRuleset(attributes,post_function,options);

    },


// ------------------------------------------------------------------------ Picos
// we need to add Pico calls to wrangler.js and call them from here.

    about: function(cb, options) 
    {
        cb = cb || function(){};
        //var json = {rids: rid,url: url}; //not sure what this does// never passed or used, dead code
        Devtools.log("Getting info about pico ");
        return wrangler.skyCloud(Devtools.get_rid("rulesets"), "aboutPico", {}, function(json) {
            Devtools.log("This pico: ", json);
            cb(json);
        }, options);
    },
	
    createPico: function(data, cb, options)
    {
        cb = cb || function(){};
        Devtools.log("Creating pico");
       return wrangler.raiseEvent("wrangler", "child_creation", data, function(json) {
           Devtools.log("Directive from createPico", json);
           cb(json);
       }, options);
    },
	
	parentPico: function(cb, options)
	{
		cb = cb || function(){};
		Devtools.log("Getting parent pico");
		return wrangler.skyCloud(Devtools.get_rid("rulesets"), "parentPico", {}, function(json) {
			Devtools.log("Parent: ", json);
			cb(json);
		}, options);
	},
	
	childPicos: function(cb, options)
	{
		cb = cb || function(){};
		//var json = {rids: rid, url: url};
		Devtools.log("Getting child picos ");
		return wrangler.skyCloud(Devtools.get_rid("rulesets"), "childPicos", {}, function(json) {
			Devtools.log("Children: ", json);
			cb(json);
		}, options);	
	},


// ------------------------------------------------------------------------ Channels mannagement
    showInstalledChannels: function(cb, options)
    {
        cb = cb || function(){};
        var parameters = {};
        Devtools.log("Showing the channels");
        post_function = function(json) {
            Devtools.log("Displaying installed channels", json);
            cb(json);
        };
        return wrangler.channels(parameters,post_function,options);

    },
    installChannel: function(attributes, cb, options) 
    {
        cb = cb || function(){};
        Devtools.log("Installing channels");
        post_function = function(json) {
           Devtools.log("Directive from create channel", json);
           cb(json);
       };
       return wrangler.createChannel(attributes, post_function, options);
    },
    uninstallChannel: function(ECI, cb, options) 
    {
        cb = cb || function(){};
        var attributes = {eci:ECI}; 
        Devtools.log("Destroy channels");
        post_function = function(json) {
            Devtools.log("Directive from create channel", json);
           cb(json);
        };
        return wrangler.deleteChannel(attributes, post_function, options);

    },
//---------------------------------(Apps) Authorize Client mannagement----------------
    authorizeClient: function(app_Data, cb, options)
    {
        cb = cb || function(){};
        Devtools.log("authorizing clientlient ");
       return wrangler.raiseEvent("devtools", "authorize_client", app_Data, function(json) {
           Devtools.log("Directive from AuthorizeClient", json);
           cb(json);
       }, options);
    },
	showAuthorizedClients: function(cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI;
        Devtools.log("Showing the showing clients");
        return wrangler.skyCloud(Devtools.get_rid("rulesets"), "showClients", {}, function(json) {
            Devtools.log("Displaying athorize clients", json);
            cb(json);
        }, {"eci":eci});
    },
    removeClient: function(app_ECI, cb, options)
    {
        cb = cb || function(){};
        var json = {"app_id":app_ECI}; 
        Devtools.log("remove client");
        console.log("attributes",json);
        return wrangler.raiseEvent("devtools", "remove_client", json, function(json) {
           Devtools.log("Directive from remove client", json);
           cb(json);
        }, options);
    },
    updateClient: function(app_ECI, app_Data, cb, options)
    {
        cb = cb || function(){};
        app_Data["app_id"]=app_ECI;
        Devtools.log("Updating client");
        return wrangler.raiseEvent("devtools", "update_client", app_Data, function(json) {
            Devtools.log("Directive from updating Client", json);
            cb(json);
        }, options);
    },

//-------------------------------------------------------------- scheduled events
    showScheduledEvents: function(cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        var eci = options.eci || PicoNavigator.currentPico || wrangler.defaultECI;
        Devtools.log("show scheduled events");
        return wrangler.skyCloud(Devtools.get_rid("rulesets"), "showScheduledEvents", {}, function(json) {
            Devtools.log("Displaying scheduled events", json);
            cb(json);
        }, {"eci":eci});   
    },
    /*scheduleEvent: function(Data, cb, options)
    {
        cb = cb || function(){};
        Devtools.log("scheduling event");
       return wrangler.raiseEvent("devtools", "event_scheduled", Data, function(json) {
           Devtools.log("Directive from ScheduleEvent", json);
           cb(json);
       }, options);
    },*/
    //TESTING CODE WRITTEN IN Wrangler
   scheduleEvent: function(data, cb, options) 
    {
        cb = cb || function(){};
        var parameters = {channelName:channel_name}; 
        Devtools.log("Scheduling event");
       return wrangler.raiseEvent("wrangler", "schedule_created", data, function(json) {
           Devtools.log("Creating a scheduled event", json);
           cb(json);
       }, options);
    },
    cancelEvent: function(sid, cb, options) 
    {
        cb = cb || function(){};
        //var parameters = {channelName:channel_name}; 
        Devtools.log("Canceling scheduled event",sid);
        var json = {sid: sid};
       return wrangler.raiseEvent("wrangler", "schedule_canceled", json, function(json) {
           Devtools.log("Canceling a scheduled event", json);
           cb(json);
       }, options);
    },
//-------------------Subscriptions--------------------
    showSubscriptions: function(cb, options)
    {
        cb = cb || function(){};
        var parameters = {};
        Devtools.log("show Subscriptions");
        post_function = function(json) {
            Devtools.log("Displaying showSubscriptions", json);
            cb(json);
        };
        return wrangler.subscriptions(parameters, post_function, options);  
    },

    SubscriptionAttributes: function(name,cb, options)
    {
        cb = cb || function(){};
        var parameters = {};
        Devtools.log("show Subscriptions");
        post_function = function(json) {
            Devtools.log("Displaying showSubscriptions", json);
            cb(json)
        };
        return wrangler.subscriptionAttributes(parameters, post_function, options);

    },
   
    ApproveSubscription: function(attributes, cb, options)
    {
        cb = cb || function(){};
        Devtools.log("approve subscription");
        post_function = function(json) {
           Devtools.log("Directive from ApproveSubscription", json);
           cb(json);
       };
       return wrangler.approvePendingSubscription(attributes , post_function , options);
    },
    RequestSubscription: function(data, cb, options)
    {
        cb = cb || function(){};
        var attributes = data;
        Devtools.log("Request subscription");
        post_function = function(json) {
           Devtools.log("Directive from RequestSubscription", json);
           cb(json);
       };
       return wrangler.requestSubscription(attributes, post_function, options);
    },
    RejectIncomingSubscription: function(data, cb, options)
    {
        cb = cb || function(){};
        Devtools.log("reject in coming subscription");
        post_function = function(json) {
           Devtools.log("Directive from incoming_request_rejected", json);
           cb(json);
       };
       return wrangler.rejectInBoundSubscription( data, post_function , options);
    },
    Unsubscribe: function(data, cb, options)
    {
        cb = cb || function(){};
        var attributes = data;
        Devtools.log("unsubscription");
        post_function = function(json) {
           Devtools.log("Directive from init_unsubscribed", json);
           cb(json);
       };
       return wrangler.cancelSubscription( attributes, post_function, options);
    },
   RejectOutgoingSubscription: function(data, cb, options)
    {
        cb = cb || function(){};
        var attributes = data;
        Devtools.log("cancel subscription request");
        post_function = function(json) {
           Devtools.log("Directive from out_going_request_rejected_by_origin", json);
           cb(json);
       };
       return wrangler.cancelOutBoundSubscription( attributes, post_function, options);
    }
//
}; //closes the "window" inside the function DON'T DELETE
//----------------------------------

	window['PicoNavigator'] = {
		currentPico : sessionStorage.getItem("currentPico"),
		
		navigateTo : function(newLocation) {
			this.currentPico = newLocation;
			sessionStorage.setItem("currentPico", newLocation);
		},
		
		clear : function() {
			this.currentPico = null;
			sessionStorage.removeItem("currentPico");
		}
	};


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
