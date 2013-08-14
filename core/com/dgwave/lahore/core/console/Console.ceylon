import ceylon.net.http.server { Response, Request, Session, StatusListener, Status}
import ceylon.net.http { contentType }
import ceylon.io.charset { utf8 }
import ceylon.collection { LinkedList }
import com.dgwave.lahore.core { lahoreServers, lahoreSites }
import com.dgwave.lahore.api { Task }

doc ("Adapted from Openshift Ceylon template by Matej Lazar")
shared void console(Request request, Response response) {
    Session session = request.session;
    
    response.addHeader(contentType { contentType = "text/html"; charset = utf8; });

    TaskDAO tasksDAO = TaskDAO(session);

    String q = request.parameter("q") else "";

    String? message = request.parameter("message");
    String? markDone = request.parameter("markDone");
    String? markNotDone = request.parameter("markNotDone");
    String? remove = request.parameter("remove");

    if (exists message, !message.empty) {
        tasksDAO.addTask(createTask(message));
    }

    if (exists markDone, !markDone.empty) {
        tasksDAO.taskDone(markDone, true);
    }

    if (exists markNotDone, !markNotDone.empty) {
        tasksDAO.taskDone(markNotDone, false);
    }

    if (exists remove, !remove.empty) {
        tasksDAO.delete(remove);
    }

    HtmlBuilder htmlPage = HtmlBuilder("/admin.site");
	StringBuilder sb = StringBuilder();
	sb.append("<table class=\"table table-hover\">\n<tr><td>Server</td><td>Tasks</td></tr>\n");
	for (server in lahoreServers) {
		sb.append("<tr><td>" + server.key + "</td><td>" + 
		    "<div class=\"btn-group\">" +
    		 "<button disabled class=\"btn btn-inverse\">Stop</button>" +
    		 "<button disabled class=\"btn btn-inverse\">Start</button>" +
    		 "<a href=\"#tab4\" data-toggle=\"tab\"><button id=\"btnConsole\" class=\"btn btn-info\">Console</button></a>" +
    		"</div>" + 
		"</td></tr>");
	}
	sb.append("</table>");
	htmlPage.addToServers(sb.string);
	
	sb.reset();
	sb.append("<table class=\"table table-hover\">\n<tr><td>Server</td><td>Messages</td></tr>\n");
	for (line in consoleListener.history) {
		sb.append("<tr><td>admin</td><td>" + line + "</td></tr>\n"); 
	}
	sb.append("</table>\n");
	htmlPage.addToConsole(sb.string);
	
	sb.reset();
	sb.append("<table class=\"table table-hover\">\n<tr><td>Site</td><td>Server/Context</td><td>Details</td><td>Actions</td></tr>\n");
	for (site in lahoreSites) {
		sb.append("<tr><td>" + site.item.site + "</td><td>" + site.key + "</td><td>" + site.item.acceptMethods.string + "<br/>" +
		site.item.accepts.string + "<br/>" + site.item.contentTypes.string +
		"</td><td>" + 
		    "<div class=\"btn-group span6\">" +
    		 "<button disabled class=\"btn btn-inverse\">Stop</button>" +
    		 "<button disabled class=\"btn btn-inverse\">Start</button>" +
			 "<a href=\"#tabPending\" data-toggle=\"tab\"><button id=\"btnPending\" class=\"btn btn-info\">Edit</button></a>" + 
			 "<a href=\"#tabPending\" data-toggle=\"tab\"><button id=\"btnSave\" class=\"btn btn-warning\">Save</button></a>" +  			 	 
		"</div></td></tr>\n"); 
	}
	sb.append("</table>\n");
	htmlPage.addToSites(sb.string);	
    //htmlPage.addToPending(inputForm(q));
    //htmlPage.addToPending(taksList(tasksDAO.tasks(q), q));

    response.writeString(htmlPage.html);
}


by("Matej Lazar")

shared String inputForm(String q) {
    return "<form method=\"GET\">\n" +
            "<label>New Task</label>\n" +
            "<div class=\"input-append\">\n" +
            "<input type=\"text\" name=\"message\" placeholder=\"Enter new task ...\"/>\n" +
            "<button type=\"submit\" class=\"btn\">Add</button>\n" +
            "</div>\n" +
            "<div class=\"input-append\">\n" +
            "<label>Filter</label>\n" +
            "<input type=\"text\" name=\"q\" value=\""+ q + "\"/>\n" +
            "<button type=\"submit\" class=\"btn\">Apply</button>\n" +
            "<button type=\"submit\" class=\"btn\" onclick=\"this.form.q.value='';this.form.sumit();\">Remove</button>\n" +
            "</div>\n" +
            "</form>\n";
}

shared String taksList(Collection<Task> tasks, String q) {
    variable String html = "\n";
    html += "<table class=\"table table-hover\">\n";

    for (Task task in tasks) {
        String onClickDone="onclick=\"document.location='?q=" + q + "&" + (task.done then "markNotDone" else "markDone") + "=" + task.id + "'\"";
        String onClickRemove="onclick=\"document.location='?q=" + q + "&remove=" + task.id + "'\"";

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
    html += "</table>\n";
    html += "\n";
    return html;
}

shared String title(String title) {
    return "<h1>" + title + "</h1>";
}

shared object consoleListener satisfies StatusListener {
	shared LinkedList<String> history = LinkedList<String>();
	shared actual void onStatusChange(Status status) {
		addMessage(status.string);
	}
	shared void addMessage(String msg) {
		if (history.size > 100) {
			history.clear(); //TODO fix tp some configured length
		}
		history.add(msg);
	}
}
