import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.menu { Menu, MenuContribution }

id("help")
name("Help")
description("Manages the display of online help.")
shared class HelpPlugin(plugin) satisfies Plugin & MenuContribution & HelpContribution & TemplateContribution {
	
	shared actual Runtime plugin;
	
	HelpController ctl1 = HelpController(plugin);
	
	methods(httpGET)
	route("help_main", "admin/help")
	permission("access administration pages")
	shared Result helpMain(Context c) => ctl1.helpMain(c);

	methods(httpGET)
	route("help_page", "admin/help/{name}")
	permission("access administration pages")
	shared Result helpPage(Context c) => ctl1.helpPage(c);

	
	"Contributes to help"
	shared actual Result help(String path, String[]? args)  {
		 variable Li optional = Li("");
         if (plugin.another("node")) {
      		optional = Li(t("<strong>Start posting content</strong> Finally, you can <a href=\"@content\">add new content</a> for your website.", 
      			{"@content" -> url("node/add")}));
         }
	    if (path == "admin/help") {
		  return {
			P(t("Follow these steps to set up and start using your website:")),
	      	Ol({
	     		Li(t("<strong>Configure your website</strong> Once logged in, visit the <a href=\"@admin\">administration section</a>, where you can <a href=\"@config\">customize and configure</a> all aspects of your website.", 
	     			{"@admin" -> url("admin"), "@config" -> url("admin/config")})),
	     		Li(t("<strong>Enable additional functionality</strong> Next, visit the <a href=\"@modules\">module list</a> and enable features which suit your specific needs. You can find additional modules in the <a href=\"@download_modules\">Drupal modules download section</a>.", 
	     			{"@modules" -> url("admin/modules"), "@download_modules" -> "http://drupal.org/project/modules"})),
	     		Li(t("<strong>Customize your website design</strong> To change the 'look and feel' of your website, visit the <a href=\"@themes\">themes section</a>. You may choose from one of the included themes or download additional themes from the <a href=\"@download_themes\">Drupal themes download section</a>.", 
	     			{"@themes" -> url("admin/appearance"), "@download_themes" -> "http://drupal.org/project/themes"})),
	     		optional // Display a link to the create content page if Node module is enabled.
	     	  }
	     	),
	     	P(t("For more information, refer to the specific topics listed in the next section or to the <a href=\"@handbook\">online Drupal handbooks</a>. You may also post at the <a href=\"@forum\">Drupal forum</a> or view the wide range of <a href=\"@support\">other support options</a> available.", 
	     		{"@help" -> url("admin/help"), "@handbook" -> "http://drupal.org/documentation", "@forum" -> "http://drupal.org/forum", "@support" -> "http://drupal.org/support"}))
		  };
		}
	    else if (path == "admin/help#help") {
	      return  {
	     	H3(t("About")),
	     	P(t("The Help module provides <a href=\"@help-page\">Help reference pages</a> and context-sensitive advice to guide you through the use and configuration of modules. It is a starting point for the online <a href=\"@handbook\">Drupal handbooks</a>. The handbooks contain more extensive and up-to-date information, are annotated with user-contributed comments, and serve as the definitive reference point for all Drupal documentation. For more information, see the online handbook entry for the <a href=\"@help\">Help module</a>.", 
	     			{"@help" -> "http://drupal.org/documentation/modules/help/", "@handbook" -> "http://drupal.org/documentation", "@help-page" -> url("admin/help")})),
	     	H3(t("Uses")),
	     	Dl{
	     		Dt(t("Providing a help reference")),
	     		Dd(t("The Help module displays explanations for using each module listed on the main <a href=\"@help\">Help reference page</a>.", 
	     			{"@help" -> url("admin/help")})),
	     		Dt(t("Providing context-sensitive help")),
	     		Dd(t("The Help module displays context-sensitive advice and explanations on various pages."))
	     	}
	      };
		}
		return null;
	}		

	
	"Contributes to menu deletion"
	shared actual Result menuDelete(Menu menu) {
		return null;
	}

	"Contributes to menu insertion"	
	shared actual Result menuInsert(Menu menu)  {
		return null;
	}
	
	"Contributes to menu updates"
	shared actual Result menuUpdate(Menu menu)  {
		return null;
	}
	
	"Contributes to template pre-processing for blocks"
	shared actual String[] preProcessBlock(String[] variables) {
		return ["b"];
	}


}


shared interface HelpContribution satisfies Contribution {

	shared default Result help(String path, String[]? args) {return null;}

}
