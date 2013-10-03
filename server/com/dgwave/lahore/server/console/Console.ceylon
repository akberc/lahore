import ceylon.net.http.server { Response, Request, Session, StatusListener, Status}
import ceylon.net.http { contentType }
import ceylon.io.charset { utf8 }
import ceylon.collection { LinkedList }
import com.dgwave.lahore.server.single { lahoreServers, lahoreSites }

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
	  htmlPage.addToServers(lahoreServers.keys);
	  htmlPage.addToSites( lahoreSites);
    htmlPage.refreshPlugins();
    htmlPage.refreshConsole();
    htmlPage.addTasks(q, tasksDAO);
    response.writeString(htmlPage.html().render());
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
