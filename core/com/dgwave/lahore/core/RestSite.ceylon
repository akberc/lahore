import com.dgwave.lahore.api { Config, Site, Route }
import ceylon.file { Path }
import ceylon.net.http.server { Response, Request, Matcher }
import ceylon.net.http { Method }


class RestSite(String siteId, Config siteConfig) satisfies Site {
    
    shared actual {Method*} acceptMethods = nothing; /* TODO auto-generated stub */
    
    shared actual Config config = nothing; /* TODO auto-generated stub */
    
    shared actual String context = nothing; /* TODO auto-generated stub */
    
    shared actual {String*} enabledPlugins = nothing; /* TODO auto-generated stub */
    
    shared actual Anything(Request, Response) endService = nothing; /* TODO auto-generated stub */
    
    shared actual String host = nothing; /* TODO auto-generated stub */
    
    shared actual Matcher matcher = nothing; /* TODO auto-generated stub */
    
    shared actual Integer port = nothing; /* TODO auto-generated stub */
    
    shared actual {Route*} routes = nothing; /* TODO auto-generated stub */
    
    shared actual String site = nothing; /* TODO auto-generated stub */
    
    shared actual Path staticURI = nothing; /* TODO auto-generated stub */
    
    
    
}