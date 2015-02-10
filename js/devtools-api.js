(function($) {
     window['Devtools'] = {

        // development settings.
        //VERSION: 0.1,

        defaults: {
            logging: false,  // false to turn off logging
            production: false,
        },


	get_rid : function(name) {
        
        var rid = {
            "rulesets": {"prod": "b506607x14", 
                          "dev": "b506607x14"
            },
        }

	    return this.defaults.production ? rids[name].prod : rids[name].dev;
	},

    rid_eci: null,
    rid_list: [],


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



        //This is the other options -- fleetChannel  would make sense?----------------------
    ridChannel: function (cb, options)
    {
        cb = cb || function(){};
        options = options || {};
        if (typeof Devtools.rid_eci === "undefined" || Devtools.rid_eci == "" || Devtools.rid_eci == null || options.force) {
                Fuse.log("Retrieving fleet channel");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showRulesets", {}, function(json) {
            if(json.eci != null)  {
            Devtools.rid_eci = json.eci;
            Devtools.log("Retrieved rid channel", json);
            cb(json.eci);
            } else {
            console.log("Seeing null fleet eci, not storing...");
            cb(null);
            }
        });
        } else {
        Devtools.log("Using cached value of fleet channel ", Devtools.rid_eci);
        cb(Devtools.rid_eci);
        return Devtools.rid_eci;
        }
    }

    };

})(jQuery);