import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.system_theme { SystemThemeConfig }
import com.dgwave.lahore.help {

	HelpContribution
}

shared class InitialSite() satisfies Site {
	shared late actual Dispatcher dispatcher;
	
    shared actual {Resource*} resources = {

    };

    shared actual {PluginConfig*} pluginsConfig = {

    };

    shared actual ThemeConfig themeConfig = SystemThemeConfig(Assoc {

    });
    
    shared actual Region pageHome {
			return Div ({}.chain(narrow<ContainerMarkup>({
            dispatcher.produceRoute(`function HelpContribution.help`,
    			{"path"->"admin/help"})
        	}).sequence())
    		);
		}
}