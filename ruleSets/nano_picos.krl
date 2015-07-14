

ruleset b507199x5 {
  meta {
    name "nano_picos"
    description <<
      Nano Picos
    >>
    author "BYUPICOLab"
    
    logging off

    use module b16x24 alias system_credentials

    provides picos, accountProfile

    sharing on

  }


  global {
    //functions

	children = function() {
		{
			'status' : true,
			'children' : ent:children
		}
	}
	parent = function() {
		{
			'status' : true,
			'parent' : ent:parent
		}
	}
	attributes = function() {
		{
			'status' : true,
			'attributes' : ent:attributes.put( {'picoName' : ent:name} )
		}
	}
	prototypes = {
		"core": [
			"b507199x5.dev"
		]
	};
	picoFactory = function(myEci, protos) {
		newPico = pci:new_cloud(myEci);
		a = pci:new_ruleset(newPico, prototypes{"core"});
		b = protos.map(function(x) {pci:new_ruleset(newPico, prototypes{x});});
		newPico;
	}


  }
  //Rules

	rule createChild {
		select when nano_manager child_creation_requested
		
		pre {
			childName = event:attr("name").defaultsTo("", standardError("No name for new pico"));
			childAttrs = event:attr("attributes").defaultsTo("{}"); //string representation of a hash, will be decoded in child
			childProtos = event:attr("prototypes").defaultsTo([]);
			
			myName = ent:name;
			myEci = meta:eci();
			myInfo = {"#{myName}" : myEci};
			
			newPico = (childName neq "") => picoFactory(myEci, childProtos) | "";
			
			myChildren = ent:children.put({"#{childName}" : newPico});
		}
		
		if (childName neq "") then
		{
			event:send({"cid":newPico}, "nano_manager", "child_created")
				with attrs = {"parent": myInfo,
								"name": childName,
								"attributes": childAttrs
							};
		}
		
		fired {
			set ent:children myChildren;
		}
	}
	
	rule initializeChild {
		select when nano_manager child_created
		
		pre {
			parentInfo = event:attr("parent");
			name = event:attr("name");
			attrs = event:attr("attributes").decode();
		}
		
		{
			noop();
		}
		
		fired {
			set ent:parent parentInfo;
			set ent:children {};
			set ent:name name;
			set ent:attributes attrs;
		}
	}

	rule setPicoAttributes {
		select when nano_manager set_attributes_requested
		pre {
			newAttrs = event:attr("attributes").decode().defaultsTo("", standardError("no attributes passed"));
		}
		if(newAttrs neq "") then
		{
			noop();
		}
		fired {
			set ent:attributes newAttrs;
		}
		else {
			log "no attributes passed to set pico rule";
		}
	}
	
	rule clearPicoAttributes {
		select when nano_manager clear_attributes_requested
		pre {
		}
		{
			noop();
		}
		fired {
			clear ent:attributes;
		}
	}
	
	rule deleteChild {
		select when nano_manager child_deletion_requested
		pre {
			picoDeleted = event:attr("picoName").defaultsTo("", standardError("missing pico name for deletion"));
			eciDeleted = (picoDeleted neq "") => ent:children{picoDeleted} | "none";
		}
		if(picoDeleted neq "" || ent:children{picoDeleted}.isnull()) then
		{
			pci:delete_cloud(eciDeleted);
		}
		notfired {
			log "deletion failed because no child name was specified";
		}
	}

}