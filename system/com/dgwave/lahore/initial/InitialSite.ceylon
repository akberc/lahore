import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.system_theme { SystemThemeConfig }
import com.dgwave.lahore.help {

	HelpContribution
}

shared class InitialSite() satisfies Site {
	shared late actual variable Dispatcher dispatcher;
	
    shared actual {Resource*} resources = {

    };

    shared actual {PluginConfig*} pluginsConfig = {

    };

    shared actual ThemeConfig themeConfig = SystemThemeConfig(Assoc {

    });
    
    shared actual Region pageHome {
        return Div (
            { dispatcher.produceRoute(`function HelpContribution.help`,
    			     {"path"->"admin/help"})
            }.narrow<ContainerMarkup>()
        );
    }
}