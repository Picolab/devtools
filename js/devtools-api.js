(function($) {
     window['Devtools'] = {

        // development settings.
        VERSION: 0.1,

        defaults: {
            logging: false,  // false to turn off logging
	    production: false,
	    hostsite: "http://windley.github.io/Joinfuse/carvoyant.html" // can't contain ,
        //change this hostsite??
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

    log: function()
    {
        if (this.defaults.logging && console && console.log) {
            [].unshift.call(arguments, "Devtools:"); // arguments is Array-like, it's not an Array 
            console.log.apply(console, arguments);
        }
    },

    getRulesets: function(cb, options) //almost like getProfile in fuse-api.js
    {
        //need to figure out the .fleet_eci call first
        cb = cb || function(){};
        options = options || {};
        var rid = "rulesets";
        var eci = options.eci || CloudOS.defaultECI;
        Devtools.log("Showing the rulesets");
        return CloudOS.skyCloud(Devtools.get_rid("rulesets"), "showRulesets", {}, function(json) {
            Devtools.log("Displaying rulesets", json);
            cb(json);
        }, {"eci":eci});
    }



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
        Fuse.log("Using cached value of fleet channel ", Devtools.rid_eci);
        cb(Devtools.rid_eci);
        return Devtools.rid_eci;
        }
    }

})(jQuery);