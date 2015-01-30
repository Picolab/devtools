(function($) {
     window['Devtools'] = {

        // development settings.
        VERSION: 0.1,

        defaults: {
            logging: false,  // false to turn off logging
	    production: false,
	    hostsite: "http://windley.github.io/Joinfuse/carvoyant.html" // can't contain ,
        },

	get_rid : function(name) {
        
        var rids = {
        "rulesets": {"prod": "b506607x14", 
            "dev": "b506607x14"
            },
        }

	    return this.defaults.production ? rids[name].prod : rids[name].dev;
	},

    log: function()
    {
        if (this.defaults.logging && console && console.log) {
            [].unshift.call(arguments, "Devtools:"); // arguments is Array-like, it's not an Array 
            console.log.apply(console, arguments);
        }
    },

    getRulesets: function(cb, options)
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

})(jQuery);