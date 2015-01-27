(function($) {
     window['Fuse'] = {

        // development settings.
        VERSION: 0.1,

        defaults: {
            logging: false,  // false to turn off logging
	    production: false,
	    hostsite: "http://windley.github.io/Joinfuse/carvoyant.html" // can't contain ,
        },

	get_rid : function(name) {
        
        var rids = {
        "rulesets": {"prod": "b506537x0",
            "dev": "b506537x0"
            },
        }

	    return this.defaults.production ? rids[name].prod : rids[name].dev;
	},

})(jQuery);