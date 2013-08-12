import com.dgwave.lahore.api { ... }

class HelpController() {
	
	shared late Plugin plugin;
	
  /**
   * Prints a page listing a glossary of lahore terminology.
   *
   * @return string
   *   An HTML string representing the contents of help page.
   */
	shared Result helpMain(Context c) { 
		Assoc output = assoc(
			"#attached" -> assoc(
				"css" -> array(c.staticResourcePath("plugin", "help").string + "/style.css")
			), 
			"#markup" -> "<h2>" + t("Help topics") + "</h2><p>" + t("Help is available on the following items:") + "</p>"  + helpLinksAsList(c)
			);
	
	    return result(output);
  	}

  /**
   * Provides a formatted list of available help topics.
   *
   * @return string
   *   A string containing the formatted list.
   */
  String helpLinksAsList(Context c) {
	variable String output = "";

	{String*} impls = c.hookImplementations;

    //asort(impls);

    // Output pretty four-column list.
    value cnt = impls.size;
    Integer brk = ceil(cnt/4.0).integer;
    output = "<div class=\"clearfix\"><div class=\"help-items\"><ul>";
    
	variable Integer i = 0;
	variable String cls = "";
    for (mod in impls) {
      output = output + "<li>" + l(mod, "admin/help/" + mod) + "</li>";
      if ((i + 1) % brk == 0 && (i + 1) != cnt) {
		if (i + 1 == brk * 3) {cls = " help-items-last";} else {cls = "";}
        output = output + "</ul></div><div class=\"help-items\" ``cls`` ><ul>";
      }
      i++;
    }
    output = output + "</ul></div></div>";

    return output;
  }

  /**
   * Prints a page listing general help for a module.
   *
   * @param String $name
   *   A module name to display a help page for.
   *
   * @return Assoc
   *   A render array as expected by lahore_render().
   */
	shared Result helpPage(Context c) {
	String? pluginName = c.pathParam("{name}");
	if (exists pluginName) {
	    Assoc build = assoc();
	    if (c.hookIsImplementedBy(pluginName)) {
	        
	      value temp = c.hook(pluginName, "help", ["admin/help#" + pluginName]);
		  
		  if (exists temp) {
			build.put("top", assoc ("#markup" -> temp.string) );  
		  }
	      else {
	        build.put("top", assoc ("#markup" -> t("No help is available for module %module.", {"%module" -> pluginName})));
	      }
	
	      // Only print list of administration pages if the module in question has
	      // any such pages associated to it.
	      value adminTasks = getPluginAdminTasks(pluginName); // array of assocs
	      if (!adminTasks.empty) {
	        value links = array();
	        for (Assoc task in adminTasks) { // one assoc
	          //value link = assoc ("localized_options" -> task.getAssoc("localized_options"));
	          //link.put ("href", task.getString("link_path"));
	          //link.put ("title", task.getString("title"));
	          //links.add(link);
	        }
			build.put("links", assoc ("#links" -> assoc (
	          "#heading" -> assoc(
	            "level" -> "h3",
	            "text" -> t("@module administration pages", {"@module" -> pluginName})
	          ),
	          "#links" -> links
	        )));
	      }
	    }
	
	    return build;
		}
	return null;
  }
}