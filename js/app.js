(function($)
{
     var router=new $.mobile.Router( [
       {"#fue": {handler: "foo",
          events: "s", // do when we show the page
          argsre: true
        } }]
        ,
        { foo: function(type, match, ui, page) {

        }}
