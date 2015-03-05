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
            "rulesets": {"prod": "b506607x14", 
                          "dev": "b506607x14"
            }
            "bootstrap":{"prod": "b506607x15", 
                          "dev": "b506607x15"
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
                Devtools.log("account initialized");
        if(response.length < 1) {
            throw "Account initialization failed";
        }
        cb(response);
            });
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
