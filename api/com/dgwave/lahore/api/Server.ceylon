import ceylon.io.charset { Charset }
import ceylon.io.buffer { ByteBuffer }

"A server container that presents system services to Core"
shared interface Server {
    shared formal String name;
    shared formal String version;
    
    shared formal String host;
    shared formal Integer port;
    
    shared formal void loadModule(String modName, String modVersion);
       
    shared formal Boolean booted;
}

"A site that has a context, configures plugins and a theme,
 and provides resources.
 Implementations should NOT have any parameters"
shared interface Site {
    
    "Theme"
    shared formal ThemeConfig themeConfig;
    
    "Final configuration for this site and plugin matrix"
    shared formal {PluginConfig*} pluginsConfig;
    
    "Exported Resources"
    shared formal {Resource *} resources;
    
    "Not a route to avoid circular references"
    shared default Region page404 => Div({Span("Page not Found")});
    shared default Region page403 => Div({Span("Not Authorized")});
    shared default Region page500 => Div({Span("Internal Error")});
}

shared interface Request {
    shared formal String path;
    shared formal HttpMethod method;
    shared formal Map<String, String> parameters;
    shared formal Map<String, String> headers;
    shared formal Session session;
}

shared interface Response {
    shared formal void addHeader(String name, String* vals);
    shared formal void withContentType([String, Charset] contentType);
    shared formal void withStatus(Integer status);
    shared formal void writeString(String write);
    shared formal void writeByteBuffer(ByteBuffer item);
}

shared interface Session {
    
}