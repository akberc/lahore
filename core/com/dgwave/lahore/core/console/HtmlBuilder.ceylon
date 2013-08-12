by("Matej Lazar")
doc ("Adapted from Openshift Ceylon template by Matej Lazar")
shared class HtmlBuilder(String path) {

    variable String servers = "";
	variable String sites = "";
	variable String plugins = "";
	variable String console = "";
	variable String pending = "";	

    shared String html {
        String html="<!DOCTYPE html>\n" +
                "<html lang=\"en\">\n" +
                "<head>\n" +
                "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n" +
                "<title>Lahore Console</title>\n" +
                "<link href=\"" +  path + "/css/bootstrap.css\" rel=\"stylesheet\">\n" +
                "<link href=\"" + path + "/css/bootstrap-responsive.min.css\" rel=\"stylesheet\">"+
                "<link href=\"" +  path + "/css/style.css\" rel=\"stylesheet\">\n" +
                "</head>\n" +
                "<body>\n" +
                "<div class=\"container\">\n" +
                 "<div class=\"row tabbable\" style=\"margin-bottom: 18px;\">\n" +
                                  "<h1>Lahore Console</h1>" +
                   "<ul class=\"nav nav-tabs\">" +
					 "<li class=\"active\"><a href=\"#tab1\" data-toggle=\"tab\">Servers</a></li>" +
					 "<li><a href=\"#tab2\" data-toggle=\"tab\">Sites</a></li>" +
					 "<li><a href=\"#tab3\" data-toggle=\"tab\">Plugins</a></li>" +
					 "<li><a href=\"#tab4\" data-toggle=\"tab\">Console</a></li>" +
					 "<li><a href=\"#tab5\" data-toggle=\"tab\">Pending Tasks</a></li>" +					 
					"</ul>" +
					"<div class=\"tab-content\" style=\"padding-bottom: 9px; border-bottom: 1px solid #ddd;\">" +
					 "<div class=\"tab-pane active\" id=\"tab1\">" +
                 		servers + "\n" +
                     "</div>\n" +
					 "<div class=\"tab-pane\" id=\"tab2\">" +
                 		sites + "\n" +
                     "</div>\n" +
			 		  "<div class=\"tab-pane\" id=\"tab3\">" +
                 		plugins + "\n" +
                     "</div>\n" + 
			 		 "<div class=\"tab-pane\" id=\"tab4\">" +
                 		console + "\n" +
                     "</div>\n" +
			 		 "<div class=\"tab-pane\" id=\"tab5\">" +
                 		pending + "\n" +
                     "</div>\n" +                                                                               
                    "</div>\n" +
                  "</div>\n" + // row
                 "</div>\n" + // container
                "<script src=\"" +  path + "/js/bootstrap.js\"></script>\n" +
                "<script type=\"text/javascript\">\n" +
                "$('#tab2').load('/admin/console/servers');\n" +
				"$('#tab3').load('/admin/console/sites');\n" +
				"$('#tab3').load('/admin/console/plugins');\n" +
                "</script>" +              
                "</body>\n" +
                "</html>\n";
        return html;
    }

    shared void addToServers(String html) {
        servers += html;
    }
    shared void addToSites(String html) {
        sites += html;
    }
    shared void addToPlugins(String html) {
        plugins += html;
    }
    shared void addToConsole(String html) {
        console += html;
    }
    shared void addToPending(String html) {
        pending += html;
    }    
}
