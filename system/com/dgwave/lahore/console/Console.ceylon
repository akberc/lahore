import ceylon.collection { LinkedList }
import com.dgwave.lahore.api { ... }

"Prints a page listing a glossary of terms."
methods(httpGET)
route("console_main", "admin/console")
permission("access console")
shared Content consoleMain(Context c, PluginRuntime plugin) {
	return Paged {
		top= {PageTitle("Lahore Console")};
		region = tabs;
		bottom = {
			Script ({"src" -> "/admin/js/jquery-1.10.2.min.js"}),
			Script ({"src" -> "/admin/js/bootstrap.min.js"})   
		};
	};
}


LinkedList<String> consoleHistory = LinkedList<String>();

shared void addConsoleMessage(String msg) {
    if (consoleHistory.size > 100) {
        consoleHistory.clear();
    }
    consoleHistory.add(msg);
}

shared List<PluginInfo> lahorePlugins = LinkedList<PluginInfo>();
