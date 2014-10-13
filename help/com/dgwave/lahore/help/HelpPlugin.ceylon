import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.menu { Menu, MenuContribution }

shared class HelpPlugin(plugin) satisfies Plugin & MenuContribution & HelpContribution & TemplateContribution {

    shared PluginRuntime plugin;

    "Contributes to help"
    shared actual Div? help(Context c)  {
        String path = c.passed("path")?.string else "";
        variable Li optional = Li("");
        if (plugin.another("node")) {
            optional = Li(t("Start posting content. Finally, you can <a href=\"@content\">add new content</a> for your website.",
            {"@content" -> "/node/add"}));
        }
        if (path == "admin/help") {
            return Div{
                P(t("Follow these steps to set up and start using your web site:")),
                Ol({
                    Li(t("This is the default site. Configure your main site by creating a plugin module of type 'sites'")),
                    Li(t("Visit the <a href=\"@console\">administration console</a> to learn more about the system.", 
                        {"@console" -> "/admin/console"})),
                    Li(t("To change the 'look and feel' of your website, associate your site module with another theme module")),
                    optional // Display a link to the create content page if Node module is enabled.
                }
                ),
                P(t("For more information, refer to the <a href=\"@wiki\">Wiki</a>.",
                {"@wiki" -> "http://github.com/dgwave/lahore/wiki"}))
            };
        }
        else if (path == "admin/help#com.dgwave.lahore.help") {
            return  Div{
                H3(t("About")),
                P(t("The Help module provides <a href=\"@help-page\">Help reference pages</a>.",
                {"@help-page" -> "/admin/help"})),
                H3(t("Uses")),
                Dl{
                    Dt(t("Providing a help reference")),
                    Dd(t("The Help module displays explanations for using each module listed on the main <a href=\"@help\">Help reference page</a>.",
                    {"@help" -> "/admin/help"})),
                    Dt(t("Providing context-sensitive help")),
                    Dd(t("The Help module displays context-sensitive advice and explanations on various pages."))
                }
            };
        }
        return null;
    }

    "Contributes to menu deletion"
    shared actual Assoc menuDelete(Menu menu) {
        return assoc();
    }

    "Contributes to menu insertion"
    shared actual Assoc menuInsert(Menu menu)  {
        return assoc();
    }

    "Contributes to menu updates"
    shared actual Assoc menuUpdate(Menu menu)  {
        return assoc();
    }

    "Contributes to template pre-processing for blocks"
    shared actual String[] preProcessBlock(String[] variables) {
        return ["b"];
    }
}

shared interface HelpContribution satisfies Contribution {

    shared default Div? help(Context c) {return null;}

}
