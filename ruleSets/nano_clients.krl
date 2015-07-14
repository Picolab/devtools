// waiting on pci new functionality.......
ruleset b507199x5 {
  meta {
    name "nano_clients"
    description <<
      Nano Clients
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials

    provides clients
    sharing on

  }

  global {
    //functions
	
    Clients = function() { 
      eci = meta:eci();
      clients = pci:get_authorized(eci).defaultsTo("wrong",standardError("undefined")); // pci does not have this function yet........
      //krl_struct = clients.decode() // I dont know if we needs decode
     // .klog(">>>>krl_struct")
     // ;
      {
        'status' : (clients != "wrong"),
        'clients' : krl_struct
      }
    }
    addPCIbootstraps = defaction(appECI,bootstrapRids){
      boot = bootstrapRids.map(function(rid) { pci:add_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap add result >>>>>>>");
      send_directive("pci bootstraps updated.")
        with rulesets = list_bootstrap(appECI); // is this working?
    };
    removePCIbootstraps = defaction(appEC,IbootstrapRids){
      boot = bootstrapRids.map(function(rid) { pci:remove_bootstrap(appECI, rid); }).klog(">>>>>> bootstrap removed result >>>>>>>");
      send_directive("pci bootstraps removed.")
        with rulesets = list_bootstrap(appECI); 
    };
    removePCIcallback = defaction(appECI,PCIcallbacks){
      PCIcallbacks =( PCIcallbacks || []).append(PCIcallbacks);
      boot = PCIcallbacks.map(function(url) { pci:remove_callback(appECI, url); }).klog(">>>>>> callback remove result >>>>>>>");
      send_directive("pci callback removed.")
        with rulesets = pci:list_callback(appECI);
    };
        get_my_apps = function(){
              ent:apps
          };
          get_registry = function(){
            app:appRegistry;
          };
          get_app = function(appECI){
            (app:appRegistry{appECI}).delete(["appSecret"])
          };
          get_secret = function(appECI){
            app:appRegistry{[appECI, "appSecret"]}
          };
          list_bootstrap = function(appECI){
            pci:list_bootstrap(appECI);
          };
          get_appinfo = function(appECI){
            pci:get_appinfo(appECI);
          };
          list_callback = function(appECI){
            pci:list_callback(appECI);
          };
	
  }
  //Rules
 
 /* //-------------------- Clients --------------------
  rule AuthorizeClient {
    select when nano_manager client_authorized


  }
  rule CRemovelient {
    select when nano_manager client_removed

  }
  rule UpdateClient {
    select when nano_manager client_updated

  }
  */
  
}