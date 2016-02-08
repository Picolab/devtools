/* jshint undef: true, unused: true */
/* globals console:false, wrangler:false  */
/* globals console, setTimeout, wrangler, Fuse */

(function($)
{
    window['Pico'] = window['Pico'] || {};

    
    window.Pico['logging'] = {

        // development settings.
        VERSION: 0.2,

        defaults: {
            logging: false,  // false to turn off logging
	    production: false
        },

	get_rid : function(name) {

	    var rids = {
		"logging": {"prod": "b16x29",
			    "dev":  "b16x29"
			   }
	    };
	    
	    var version = Pico.logging.pico_version || (Pico.logging.defaults.production ? "prod" : "dev");
	    	    
	    return rids[name][version];
	},

	// ---------- logging ----------

        status: function(channel, cb, options)
        {
	    cb = cb || function(){};
	    options = options || {};
            console.log("Retrieving logging status");

	    return wrangler.skyQuery(Pico.logging.get_rid("logging"), "loggingStatus", {}, function(res) {
		console.log("Saw log status: ", res);
		if(typeof cb !== "undefined"){
		    cb(res);
		}
	    },
	    {"eci": channel});
        },
	
        getLogs: function(channel, cb, options)
        {
	    cb = cb || function(){};
	    options = options || {};
            console.log("Retrieving logs");

	    return wrangler.skyQuery(Pico.logging.get_rid("logging"), "getLogs", {}, function(res) {
		console.log("Saw logs: ", res);
		if(typeof cb !== "undefined"){
		    cb(res);
		}
	    },
	    {"eci": channel});
        },

        reset: function(channel, json, cb)
        {
	    json = json || {};
            return wrangler.raiseEvent("picolog", "reset", json, {}, cb, {"eci": channel});
        },

	active: this.reset,
	
        inactive: function(channel, json, cb)
        {
            return wrangler.raiseEvent("picolog", "inactive", json, {}, cb, {"eci": channel});
        },

        flush: function(channel, json, cb)
        {
            return wrangler.raiseEvent("picolog", "flush", json, {}, cb, {"eci": channel});
        }

    };

    function isEmpty(obj) {

	// null and undefined are "empty"
	if (obj == null) return true;

	if( typeof obj === "number" 
	 || typeof obj === "string" 
	 || typeof obj === "boolean" 	
	  ) return false;

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


    };


})(jQuery);