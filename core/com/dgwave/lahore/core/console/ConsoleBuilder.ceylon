import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core { Site }
import com.dgwave.lahore.core.component { plugins }

shared class HtmlBuilder(String path) {

  value tableClasses = ["table", "table-hover"];
	
	value serverHeading = thead("Server", "Tasks");
  variable Table servers = Table { 
    classes = tableClasses; 
    thead = serverHeading; 
	};
	
	value siteHeading = thead("Site", "Server/Context", "Details", "Actions");
  variable Table sites = Table { 
    classes = tableClasses; 
    thead = siteHeading; 
	};
	
	value pluginHeading = thead("Plugin", "Name/Desc", "Sites", "Actions");
  variable Table pluginlist = Table { 
    classes = tableClasses; 
    thead = pluginHeading; 
  };
  
  value messageHeading = thead("Context", "Message", "Time");
  variable Table messages = Table { 
    classes = tableClasses; 
    thead = messageHeading; 
  };
  
  value taskHeading = thead("Task", "Status");
  variable Table tasks = Table { 
    classes = tableClasses; 
    thead = taskHeading; 
  };

	shared Html html() { 
  return Html { 
    attrs = {"lang" -> "en"};
	  head = Head {
		  title = PageTitle("Lahore Console");
		  Meta ({"http-equiv" -> "Content-Type", "content" -> "text/html; charset=UTF-8"}),
		  Link ({"href" -> "``path``/css/bootstrap.min.css", "rel" -> "stylesheet"}),
		  Link ({"href" -> "``path``/css/style.css", "rel" -> "stylesheet"})
	  };
	  body = Body {
		 Div { classes=["container"];
		  Div { classes=["row", "tabbbable"]; attrs = {"style" -> "margin-bottom: 18px;"};
		  	H1 ("Lahore Console"),
			  Ul { id="consoleTabs"; classes=["nav","nav-tabs"];
          Li { content = a("#servers", "Servers", {"data-toggle" -> "tab"}); classes=["active"];},
          Li { content = a("#sites", "Sites", {"data-toggle" -> "tab"}); },
          Li { content = a("#plugins", "Plugins", {"data-toggle" -> "tab"}); },
          Li { content = a("#messages", "Messages", {"data-toggle" -> "tab"}); },
          Li { content = a("#tasks", "Tasks", {"data-toggle" -> "tab"}); }
			  },
			Div { id="consoleTabsContent"; classes=["tab-content"]; attrs = {"style" -> "padding-bottom: 9px; border-bottom: 1px solid #ddd;"};
			  Div { id = "servers"; classes=["tab-pane", "active"];
			  	servers	
			  },
			  Div { id = "sites"; classes=["tab-pane"];
			  	sites
			  },
        Div { id = "plugins"; classes=["tab-pane"];
          pluginlist
        },
        Div { id = "messages"; classes=["tab-pane"];
          messages
        },
        Div { id = "tasks"; classes=["tab-pane"];
          tasks
        }                 			  	  
			} // div tab-content
		 } // div container
		},
      Script ({"src" -> "``path``/js/jquery-1.10.2.min.js"}),
      Script ({"src" -> "``path``/js/bootstrap.min.js"})		
	 }; // body
	}; //html
	}
	

    shared void addToServers({String*} serverKeys) {
	  value cfs = servers.containedFragments;
	  servers = 
	  Table { 
	    classes = tableClasses; 
    	thead = serverHeading; 
    	rows = {
    	  for (cf in cfs ) if (is Tr cf) cf
    	}.chain( {
    	  for (sk in serverKeys) 
	    	  Tr ({
	    	  	Td (sk),
	    	  	Td ( 
	    	  	  Div { classes= ["btn-group"];
	    	  	    button ("Stop", false, null, "btn", "btn-inverse"),
	    	  	    button ("Start", false, null, "btn", "btn-inverse"),
	    	  	    button ("Messages", true, "btnServerMessages", "btn", "btn-info")
	    	  	  }.render()
	    	  	 )
	    	   }) // Tr
    	   }); // chain
	     };
	   }

    shared void addToSites(Map<String, Site> webSites) {
    value cfs = sites.containedFragments;
    sites = 
    Table { 
      classes = tableClasses; 
      thead = siteHeading; 
      rows = {
        for (cf in cfs ) if (is Tr cf) cf
      }.chain( {
        for (ws in webSites) 
          Tr ({
            Td (ws.item.site),
            Td (ws.key),
            Td ("``ws.item.acceptMethods`` ``ws.item.contentTypes`` with plugins ``ws.item.enabledPlugins``"),
            Td ( 
              Div { classes= ["btn-group"];
                button ("Stop", false, null, "btn", "btn-inverse"),
                button ("Start", false, null, "btn", "btn-inverse"),
                button ("Edit", true, "btnSiteEdit", "btn", " btn-info"),
                button ("Save", true, "btnSiteSave", "btn", " btn-warning")
              }.render()
             )
           }) // Tr
         }); // chain
       };
     }
    
    
    shared void refreshPlugins() {      
      pluginlist = 
      Table { 
        classes = tableClasses; 
        thead = pluginHeading; 
        rows = {
          for (p in plugins.list ) 
            if (exists pi = plugins.info(p)) Tr ( {
              Td (pi.id),
              Td (pi.name + " : " + pi.description),
              Td ("Sites"),
              Td (Div { classes= ["btn-group"];
                button ("Stop", false, null, "btn", "btn-inverse"),
                button ("Start", false, null, "btn", "btn-inverse"),
                button ("Configure", true, "btnPluginConfigure", "btn", " btn-info"),
                button ("Reset", true, "btnPluginReset", "btn", " btn-warning")
              }.render())
             })
        };
      };
    }
    
    shared void refreshConsole() {
      messages = 
      Table {
        classes = tableClasses;
        thead = messageHeading;
        rows = {
          for (line in consoleListener.history.reversed)  Tr ( {
            Td ("admin"),
            Td (line),
            Td ("")
          })
        };
      };
    }
    
    shared void addTasks(String q, TaskDAO dao) {
      Form { method="GET"; action=".";
        Label ("New Task"),
        Div { classes = ["input-append"];
          Text { name = "message"; placeHolder="Enter new task ..."; content="";},
          Button {type="submit"; classes=["btn"]; content="Add";}
        },
        Div { classes = ["input-append"];
          Label ("Filter"),
          Text { name = "q"; content=q;},
          Button {type="submit"; classes=["btn"]; content="Apply";},
          Button {type="submit"; classes=["btn"]; content="Remove";
            invoke="this.form.q.value=''; this.form.submit();";}
        }
      };
     
      Tr makeTr (Task task) {
        String onClickDone="onclick=\"document.location='?q=" + q + "&" + (task.done then "markNotDone" else "markDone") + "=" + task.id + "'\"";
        String onClickRemove="onclick=\"document.location='?q=" + q + "&remove=" + task.id + "'\"";
  
        return Tr( {
          Td (Label {classes=["checkbox"];)
        });
      }
      for (Task task in dao.tasks(q)) {

        html += "<tr>\n";
        html += "<td>\n";
        html += "<label class=\"checkbox\">\n";
        html += "<input type=\"checkbox\"" + (task.done then "checked=\"checked\"" else "");
        html += " " + onClickDone + "/>\n";
        html += "<span class=\"" + (task.done then "taskDone" else "taskNotDone") + "\">" +  task.message + "</span>\n";
        html += "</label>\n";
        html += "</td>\n";
        html += "<td width=\"20px\">\n";
        html += "<i class=\"icon-remove\" " + onClickRemove + "/>\n";
        html += "</td>\n";
        html += "</tr>\n";
    }
}
