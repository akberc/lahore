import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.help { HelpContribution }

id("menu")
name("Menu")
description("Allows administrators to customize the site navigation menu.")
configure("admin/structure/menu")
shared class MenuPlugin(plugin) satisfies Plugin & HelpContribution {
	
	shared actual Runtime plugin;
	
	MenuController ctl1 = MenuController();
	MenuEntityForm entForm1 = MenuEntityForm();
	ctl1.plugin = this;
	entForm1.plugin = this;

	methods(httpGET)
	route("menu_settings", "/admin/structure/menu/settings")
	permission("administer menu")
	shared Result menuSettings(Context c) => ctl1.menuSettings(c);
	
	methods(httpGET)
	route("menu_link_reset", "admin/structure/menu/item/{menu_link}/reset")
	permission("administer menu")
	shared Result menuLinkReset(Context c) => ctl1.menuLinkReset(c);

	methods(httpGET)
	route("menu_link_delete", "admin/structure/menu/item/{menu_link}/delete")
	permission("_access_menu_delete_link: 'TRUE'")
	shared Result menuLink_delete(Context c) => entForm1.menuLink_delete(c);

	methods(httpGET)
	route("menu_delete_menu", "admin/structure/menu/manage/{menu}/delete")
	permission("_access_menu_delete_link: 'TRUE'")
	shared Result menu_delete(Context c) => entForm1.menu_delete(c);
 
 	shared actual Result help(String path, String[]? args) {

	    if (path == "admin/help#menu") {
		  return {
		      	H3(t("About")),
		      	P( t("The Menu module provides an interface for managing menus. A menu is a hierarchical collection of links, which can be within or external to the site, generally used for navigation. Each menu is rendered in a block that can be enabled and positioned through the <a href=\"@blocks\">Blocks administration page</a>. You can view and manage menus on the <a href=\"@menus\">Menus administration page</a>. For more information, see the online handbook entry for the <a href=\"@menu\">Menu module</a>.", 
		      			{"@blocks" -> url("admin/structure/block"), "@menus" -> url("admin/structure/menu"), "@menu" -> "http://drupal.org/documentation/modules/menu/"}
		      		)
		      	),
		      	H3(t("Uses")),
		      Dl{
		      	Dt(t("Managing menus")),
		      	Dd(t("Users with the <em>Administer menus and menu items</em> permission can add, edit and delete custom menus on the <a href=\"@menu\">Menus administration page</a>. Custom menus can be special site menus, menus of external links, or any combination of internal and external links. You may create an unlimited number of additional menus, each of which will automatically have an associated block. By selecting <em>list links</em>, you can add, edit, or delete links for a given menu. The links listing page provides a drag-and-drop interface for controlling the order of links, and creating a hierarchy within the menu.", 
		      			{"@menu" -> url("admin/structure/menu"), "@add-menu" -> url("admin/structure/menu/add")}
		      		)
		      	),
		      	Dt(t("Displaying menus")),
		      	Dd(t("After you have created a menu, you must enable and position the associated block on the <a href=\"@blocks\">Blocks administration page</a>.", 
		      			{"@blocks" -> url("admin/structure/block")}
		      		)
		      	)
		  	  }
		  };
	  	}
	    else if (path == "admin/structure/menu/add") {
	      return {
	          P(t("You can enable the newly-created block for this menu on the <a href=\"@blocks\">Blocks administration page</a>.", 
	          		{"@blocks" -> url("admin/structure/block")})
	          	)
	      	};
	    }
	    
	    if (path == "admin/structure/menu") { 
	        if (plugin.another("block")) {
	      		return {
	      			P(t("Each menu has a corresponding block that is managed on the <a href=\"@blocks\">Blocks administration page</a>.", 
	      				{"@blocks" -> url("admin/structure/block")})
	      			)
	      		};
	    	}
		}
	
		return null;
	  }
}

