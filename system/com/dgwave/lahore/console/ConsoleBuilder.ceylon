import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap }

Region tabs {

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

    Table refreshServers({String*} serverKeys) {
        value cfs = servers.containedFragments;
        return 
        Table { 
            classes = tableClasses; 
            thead = serverHeading; 
            rows = {
                for (cf in cfs ) if (is Tr cf) cf
            }.chain( {
                for (sk in serverKeys) 
                Tr ({
                    Td (sk),
                    Td ( {
                        Div { classes= ["btn-group"];
                            button ("Stop", false, null, "btn", "btn-inverse"),
                            button ("Start", false, null, "btn", "btn-inverse"),
                            button ("Messages", true, "btnServerMessages", "btn", "btn-info")
                        }}
                    )
                }) // Tr
            }); // chain
        };
    }

    Table refreshSites(Map<String, Site> webSites) {
        value cfs = sites.containedFragments;
        return 
        Table { 
            classes = tableClasses; 
            thead = siteHeading; 
            rows = {
                for (cf in cfs ) if (is Tr cf) cf
            }.chain( {
                for (ws in webSites) 
                Tr ({
                    Td (ws.item.string), // TODO replace with context from SiteRuntime - and below
                    Td (ws.key),
                    Td ("--"), //``ws.item.acceptMethods`` ``ws.item.contentTypes`` with plugins ``ws.item.enabledPlugins``"),
                    Td ( {
                        Div { classes= ["btn-group"];
                            button ("Stop", false, null, "btn", "btn-inverse"),
                            button ("Start", false, null, "btn", "btn-inverse"),
                            button ("Edit", true, "btnSiteEdit", "btn", " btn-info"),
                            button ("Save", true, "btnSiteSave", "btn", " btn-warning")
                        }}
                    )
                }) // Tr
            }); // chain
        };
    }
    
    Table refreshPlugins() {      
        pluginlist =  
                Table { 
            classes = tableClasses; 
            thead = pluginHeading; 
            rows = {
                for (p in lahorePlugins ) 
                Tr ( {
                    Td (p.id),
                    Td (p.name + " : " + p.description),
                    Td ("Sites"),
                    Td ({ Div { classes= ["btn-group"];
                        button ("Stop", false, null, "btn", "btn-inverse"),
                        button ("Start", false, null, "btn", "btn-inverse"),
                        button ("Configure", true, "btnPluginConfigure", "btn", " btn-info"),
                        button ("Reset", true, "btnPluginReset", "btn", " btn-warning")
                    }})
                })
            };
        };
        return pluginlist;
    }
    
    Table refreshConsole() {
        messages =
                Table {
            classes = tableClasses;
            thead = messageHeading;
            rows = {
                for (line in consoleHistory.reversed)  Tr ( {
                    Td ("admin"),
                    Td (line),
                    Td ("")
                })
            };
        };
        return messages;
    }
      
    return 
          Div { classes=["row", "tabbbable"]; attrs = {"style" -> "margin-bottom: 18px;"};
              Ul { id="consoleTabs"; classes=["nav","nav-tabs"];
          Li { content = a("#servers", "Servers", {"data-toggle" -> "tab"}); classes=["active"];},
          Li { content = a("#sites", "Sites", {"data-toggle" -> "tab"}); },
          Li { content = a("#plugins", "Plugins", {"data-toggle" -> "tab"}); },
          Li { content = a("#messages", "Messages", {"data-toggle" -> "tab"}); },
          Li { content = a("#tasks", "Tasks", {"data-toggle" -> "tab"}); }
              },
            Div { id="consoleTabsContent"; classes=["tab-content"]; attrs = {"style" -> "padding-bottom: 9px; border-bottom: 1px solid #ddd;"};
              Div { id = "servers"; classes=["tab-pane", "active"];
                refreshServers({"localhost"})
              },
              Div { id = "sites"; classes=["tab-pane"];
                refreshSites(HashMap<String, Site>())
              },
              Div { id = "plugins"; classes=["tab-pane"];
                refreshPlugins()
              },
              Div { id = "messages"; classes=["tab-pane"];
                refreshConsole()
              },
              Div { id = "tasks"; classes=["tab-pane"];
                tasks
              }
            } // div tab-content
         };
}
