import com.dgwave.lahore.api { ... }

"Prints a page listing a glossary of terms."
methods(httpGET)
route("help_main", "admin/help")
permission("access administration pages")
shared Content helpMain(Context c, PluginRuntime plugin) {
    return Paged {
        top = {Attached("style1", "style.css", textCss)};
        region = Div {
            H2(t("Help topics")),
            P(t("Help is available on the following items:")),
            helpLinksAsList(c, plugin)
        };
    };
}

"Prints a page listing general help for a module."
methods(httpGET)
route("help_page", "admin/help/{name}")
permission("access administration pages")
shared Content? helpPage(Context c, PluginRuntime plugin) {
    String? otherPluginName = c.passed("{name}")?.string;
    if (exists otherPluginName) {
        if (plugin.isContributedToBy(otherPluginName)) {

            value temp = plugin.contributionFrom(otherPluginName,
                `function HelpContribution.help`, c.passing("path", "admin/help#" + otherPluginName));

            if (exists temp, is Div contr = temp[1]) {
                return Paged { region = contr;};
            } else {
                return Paged { region = Div {
                    Span(t("No help is available for module %module.", {"%module" -> otherPluginName}))
                    };
                };
            }
        }

        // How to query another plugin
        Boolean? something = plugin.plugin(otherPluginName)?.providesResource("icon"); // array of assocs
        if (exists something) {

        }
    }
    return null;
}

"Provides a formatted list of available help topics."
Div helpLinksAsList(Context c, PluginRuntime plugin) {

    {String*} impls = plugin.contributors;

    return Div { classes = ["clearfix"];
            Div { classes = ["help-items"];
                Ul {
                    for (mod in impls) Li(a("help/" + mod, mod))
                }
            }
        };
}
