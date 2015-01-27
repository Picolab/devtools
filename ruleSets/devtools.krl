//b506537x0.prod
ruleset devtools {
	meta {
		name "DevTools"
		description <<
		ruleset for DevTools website.
		>>
		author "Krl-DevTools Developer"
		logging on

    use module a169x625 alias CloudOS
	}

	global {
		
	}
	rule showRulesets {
    select when web cloudAppAction action re/listRulesets/
    pre {
      rulesets = rsm:list_rulesets(meta:eci()).sort();
 
      rulesetGallery = rulesets.map(function(rid){
        ridInfo = (rid) => rsm:get_ruleset(rid) | {};
 
        appURL = ridInfo{"uri"};
 
        ridHTML = <<
          <tr>
            <td>
              <a href="#!/app/#{meta:rid()}/editRuleset&rulesetID=#{rid}">
                #{rid}
              </a>
            </td>
            <td>
              <a href="#{appURL}">
                #{appURL}
              </a>
            </td>
          </tr>
        >>;
 
        (ridInfo) => ridHTML | ""
      }).join("");
 
      html = <<
        <div class="squareTag wrapper">
          <table class="table table-striped">
            <thead>
              <tr>
                <th>
                  RID
                </th>
                <th>
                  Source URL
                </th>
              </tr>
            </thead>
            <tbody>
              #{rulesetGallery}
            </tbody>
          </table>
        </div>
      >>;
 
      appMenu = [
        {
          "label": "Register Ruleset",
          "action": "registerRuleset"
        }
      ];
    }
    {
        notify("Rulesets", rulesets.encode());
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Rulesets", appMenu, html);
    }
  }
  rule editRuleset {
    select when web cloudAppAction action re/editRuleset/
    pre {
      rid = event:attr("rulesetID");
 
      rulesetData = rsm:get_ruleset(rid);
 
      html = displayRuleset(rulesetData);
 
      appURL = rulesetData{"uri"};
 
      html = <<
        <form id="formUpdateRuleset" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="appURL">Source URL</label>
              <div class="controls">
                <textarea class="input-xlarge" name="appURL" title="The location your KRL source resides" placeholder="The location your KRL source resides" required>#{appURL}</textarea>
              </div>
            </div>
            <div class="form-actions">
              <input type="hidden" value="#{rid}" name="rulesetID" />
              <button type="submit" class="btn btn-primary">Update Ruleset</button>
            </div>
          </fieldset>
        </form>
      >>;
    }
    {
      CloudRain:createLoadPanel("Edit Rulesets", [], html);
      CloudRain:skyWatchSubmit("#formUpdateRuleset", "");
    }
  }
 
  rule updateRuleset {
    select when web submit "#formUpdateRuleset"
    pre {
      rulesetID = event:attr("rulesetID");
      newURL = event:attr("appURL");
    }
    {
      rsm:update(rulesetID) setting(updatedSuccessfully)
        with uri = newURL;
      CloudRain:setHash('/refresh');
    }
    fired {
      raise system event rulesetUpdated
        with rulsetID = rulesetID if(updatedSuccessfully);
    }
  }
 
  rule createRuleset {
    select when web cloudAppAction action re/registerRuleset/
    pre {
      html = <<
        <p>
          Here you can register a new ruleset. In order to
          successfully register it, the source code must be
          accessible by HTTP access. You can encode the username
          and password into the URL by using
          <a href="https://en.wikipedia.org/wiki/Basic_access_authentication">
            HTTP basic authentication.
          </a>
          At some point I will expose the functionality to allow you to put authentication data in the headers as well. For now, though, you're restricted to Basic Auth only.
        </p>
        <form id="formRegisterNewRuleset" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="appURL">Source URL</label>
              <div class="controls">
                <textarea class="input-xlarge" name="appURL" title="The location your KRL source resides" placeholder="The location your KRL source resides" required></textarea>
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">Register Ruleset</button>
            </div>
          </fieldset>
        </form>
      >>;
    }
    {
      CloudRain:createLoadPanel("Create Ruleset", [], html);
      CloudRain:skyWatchSubmit("#formRegisterNewRuleset", "");
    }
  }
 
  rule createRulesetSubmit {
    select when web submit "#formRegisterNewRuleset"
    pre {
      appURL = event:attr("appURL");
    }
    {
      rsm:register(appURL) setting (rid);
      CloudRain:setHash('/app/#{meta:rid()}/listRulesets');
    }
    fired {
      raise system event rulesetCreated
        with rulsetID = rid{"rid"} if(rid);
    }
  }
 
  rule deleteRulesets {
    select when web cloudAppAction action re/deleteRulesets/
    {
      CloudRain:setHash('/app/#{meta:rid()}/listRulesets');
    }
    //fired {
      //TODO: Need to delete the ruleset.
    //}
  }
}