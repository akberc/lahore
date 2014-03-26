import ceylon.collection { LinkedList }
import com.dgwave.lahore.api { Request, Response, PluginInfo }

shared void console(Request request, Response response) {
    HtmlBuilder htmlPage = HtmlBuilder("/admin.site");
    htmlPage.addToServers({}); // TODO
    htmlPage.addToSites(emptyMap); // TODO
    htmlPage.refreshPlugins();
    htmlPage.refreshConsole();
    response.writeString(htmlPage.html().render());
}

LinkedList<String> consoleHistory = LinkedList<String>();

shared void addConsoleMessage(String msg) {
    if (consoleHistory.size > 100) {
        consoleHistory.clear();
    }
    consoleHistory.add(msg);
}

shared List<PluginInfo> lahorePlugins = LinkedList<PluginInfo>();
