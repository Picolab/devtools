(function($)
{
     var router=new $.mobile.Router( [
       {"#page-one": {handler: "PageOneHandler",
          events: "s", // do when we show the page
          argsre: true
        } },
        {"#page-two": {handler: "PageTwoHandler",
          events: "s", // do when we show the page
          argsre: true
        } }]
        ,
        { PageOneHandler: function(type, match, ui, page) {
               console.log("page One Handler");
        }},
        { PageTwoHandler: function(type, match, ui, page) {
               console.log("page Two Handler");
        }}
});
