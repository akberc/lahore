import ceylon.file {
    Path
}

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
    shared formal Assocable passed(String string);
    shared formal Context passing(String string, Assocable arg);
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

" Web Context"
shared interface WebContext satisfies Context {
    shared formal Theme theme;
}

shared interface Theme {
    shared formal String id;
    shared formal Layout layout;
    shared formal Renderer renderer;
    shared formal Binder binder;
    
    shared formal {Template<Markup>*} templates;
    shared formal {Style*} styles;
    shared formal {Script*} scripts;
    shared formal {Region*} regions;
    
    shared formal String assemble(TaggedMarkup  tm);
}