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



//---------the functions for updating rulesets


    ridSummary: function(cb, options) //vehicleSummary
    {
            cb = cb || function(){};
            options = options || {};
            //if(isEmpty(Devtools.vehicle_summary)) {
            //options.force = true;
            //}
            return Devtools.ask_fleet("ridSummary", {}, Devtools.rid_summary, function(json) {
            if(typeof json.error === "undefined") {
                Devtools.rid_summary = json;
                Devtools.log("Retrieve vehicle summary", json);
                cb(json);
            } else {
                console.log("Bad vehicle summary fetch ", json);
            }
            }, options);
        },

    ridChannels: function(cb, options) //vehicleChannels
    {
            cb = cb || function(){};
            options = options || {};
                Devtools.log("Retrieving vehicles"); 
            return Devtools.ask_fleet("ridChannels", {}, Devtools.rid_list, function(json) {
            if(typeof json.error === "undefined") {
                Devtools.rid_list = json;       //retrieved vehicles
                Devtools.log("Retrieved vehicles", json);
                cb(json);
            } else {
                console.log("Bad vehicle channel fetch: ", json);
            }
            }, options);
        },

    updateRIDSummary: function(id, profile) //updateVehicleSummary
    {
            Devtools.rid_summary = Devtools.rid_summary || {};
            Devtools.rid_summary[id] = Devtools.rid_summary[id] || {};
            $.each(profile, function(k,v){
            k = (k === "myProfileName") ? "profileName"
                      : (k === "myProfilePhoto") ? "profilePhoto"
                      : k;  
            console.log("Storing in vehicle summary ", k, v);
            Devtools.rid_summary[id][k] = v;
            });
        },

    ask_fleet: function(funcName, args, cache, cb, options) {  //replace fleet with pico?
            cb = cb || function(){};
            options = options || {};
            var rid = options.rid || "fleet";

            if (isEmpty(cache)
              || options.force
               ) {
                       Devtools.log("Calling " + funcName);
               Devtools.picoChannel(function(fc) {
                   Devtools.log("Using fleet channel ", fc);
                   if(fc !== "none") {
                   return CloudOS.skyCloud(Devtools.get_rid(rid), funcName, args, cb, {"eci": fc});
                   } else {
                   Devtools.log("fleet_eci is undefined, you must get the fleet channel first");
                   return null;
                   }
               });
               } else {
               cb(cache);
               return cache;
               }
        },

    picoChannel: function(cb, options) //fleetChannel
    {
        cb = cb || function(){};
        options = options || {};
        if (typeof Devtools.rid_eci === "undefined" || Devtools.rid_eci == "" || Devtools.rid_eci == null || options.force) {
                Devtools.log("Retrieving fleet channel");
        return CloudOS.skyCloud(Devtools.get_rid("owner"), "picoChannel", {}, function(json) {
            if(json.eci != null)  {
            Devtools.rid_eci = json.eci;
            Devtools.log("Retrieved fleet channel", json);
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
    },


}; //closes the "window" inside the function DON'T DELETE

//----------------------------------

    function isEmpty(obj) {

        // null and undefined are "empty"
        if (obj == null) return true;

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