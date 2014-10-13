import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.help { HelpContribution }

shared class MenuPlugin(plugin) satisfies Plugin & HelpContribution {

    shared PluginRuntime plugin;

    MenuController ctl1 = MenuController();
    MenuEntityForm entForm1 = MenuEntityForm();
    ctl1.plugin = this;
    entForm1.plugin = this;

    methods(httpGET)
    route("menu_settings", "/admin/structure/menu/settings")
    permission("administer menu")
    shared Content? menuSettings(Context c) => ctl1.menuSettings(c);

    methods(httpGET)
    route("menu_link_reset", "admin/structure/menu/item/{menu_link}/reset")
    permission("administer menu")
    shared Content? menuLinkReset(Context c) => ctl1.menuLinkReset(c);

    methods(httpGET)
    route("menu_link_delete", "admin/structure/menu/item/{menu_link}/delete")
    permission("_access_menu_delete_link: 'TRUE'")
    shared Content? menuLink_delete(Context c) => entForm1.menuLink_delete(c);

    methods(httpGET)
    route("menu_delete_menu", "admin/structure/menu/manage/{menu}/delete")
    permission("_access_menu_delete_link: 'TRUE'")
    shared Content? menu_delete(Context c) => entForm1.menu_delete(c);

    shared actual Div? help(Context c) {
        String path = c.passed("path")?.string else "";
        if (path == "admin/help#com.dgwave.lahore.menu") {
            return Div {
                H3(t("About")),
                P( t("The Menu module provides an interface for managing menus.>.", {})),
                H3(t("Uses")),
                Dl{
                    Dt(t("Managing menus")),
                    Dd(t("Users with the <em>Administer menus and menu items</em> permission can add, edit and delete custom menus.>. Custom menus can be special site menus, menus of external links, or any combination of internal and external links. You may create an unlimited number of additional menus, each of which will automatically have an associated block. By selecting <em>list links</em>, you can add, edit, or delete links for a given menu. The links listing page provides a drag-and-drop interface for controlling the order of links, and creating a hierarchy within the menu.",
                    {"@menu" -> "/admin/structure/menu", "@add-menu" -> "/admin/structure/menu/add"}
                    )
                    ),
                    Dt(t("Displaying menus")),
                    Dd(t("After you have created a menu, you must enable and position the associated block on the <a href=\"@blocks\">Blocks administration page</a>.",
                    {"@blocks" -> "/admin/structure/block"}
                    )
                    )
                }
            };
        }
        else if (path == "admin/structure/menu/add") {
            return Div {
                P(t("You can enable the newly-created block for this menu on the <a href=\"@blocks\">Blocks administration page</a>.",
                {"@blocks" -> "/admin/structure/block"})
                )
            };
        }

        if (path == "admin/structure/menu") {
            if (plugin.another("block")) {
                return Div {
                    P(t("Each menu has a corresponding block that is managed on the <a href=\"@blocks\">Blocks administration page</a>.",
                    {"@blocks" -> "/admin/structure/block"})
                    )
                };
            }
        }

        return null;
    }
}

