import ceylon.file { Path }
import ceylon.language.meta.declaration { ClassDeclaration, Module }

//TODO see how we can inject the context (and config) with  the right scope
shared alias Primitive => String | Integer | Float | Boolean;
shared alias TaggedMarkup => [Map<String, String>, List<String>];

shared abstract class Scope() of 
    globalScope | pluginScope | siteScope | sessionScope | conversationScope | requestScope | callScope {}

shared object globalScope extends Scope() { shared actual String string = "global";}
shared object pluginScope extends Scope() { shared actual String string = "plugin";}
shared object siteScope extends Scope() { shared actual String string = "site";}
shared object sessionScope extends Scope() { shared actual String string = "session";}	
shared object conversationScope extends Scope() { shared actual String string = "conversation";}	
shared object requestScope extends Scope() { shared actual String string = "request";}	
shared object callScope extends Scope() { shared actual String string = "call";}		

" This should be injectable into plugin providers"
shared interface Context {
    shared default String? contextParam(String name) { return null;}
    shared default String? queryParam(String name) { return null;}	
    shared default String? pathParam(String placeHolder) { return null;}	
    shared formal String staticResourcePath(String type, String name);	
    shared default Entity? entity { return null;} // incoming form or JSON/XML object

    "Passing parameters between plugins"
    shared default Context passing(String string, Assocable arg)  {return this;}
    shared default Assocable passed(String key)  {return "";} 
}

shared interface Storage<Element> {
    shared formal Element? load(String relativePath, {Primitive+} uniqueKey = {"*"});	
    shared formal {Element*} loadAllVersions(String relativePath, {Primitive+} uniquKey);
    shared formal Element? remove(String relativePath, {Primitive+} uniquKey);
    shared formal Boolean save(String relativePath, Element elem);
    shared formal {Element*} find(String relativePath, String query);
    shared formal Boolean append(String relativePath, Element elem);
    shared formal Path basePath;}

shared interface Entity satisfies Storable {
    shared formal {Primitive+} uniqueKey;
    shared formal Integer version;
}

shared abstract class ThemeConfig(shared ClassDeclaration themeClass) extends AbstractConfig() {}

shared abstract class PluginConfig(Module mod) extends AbstractConfig() {}

shared abstract class Theme (ThemeConfig config) {
    shared default String id = "none";
    shared formal Layout layout;
    shared formal Renderer renderer;
    shared formal Binder binder;
    
    shared default {Template<Markup>*} templates = {};
    shared default {Style*} styles = {};
    shared default {Script*} scripts = {};
    shared default {Region*} regions = {};
    
    shared formal String assemble(TaggedMarkup  tm);
}