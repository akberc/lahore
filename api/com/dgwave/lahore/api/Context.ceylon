import ceylon.file { Path }
import ceylon.language.meta.declaration { ClassDeclaration, Module }
import ceylon.language.meta { typeLiteral, type }

"Valid values in [[Assoc]] and [[Array]]"
shared alias Primitive => String | Integer | Float | Boolean;

" This should be injectable into plugin providers"
shared interface Context {
    shared default String? contextParam(String name) { return null;}
    shared default String? queryParam(String name) { return null;}	
    shared default String? pathParam(String placeHolder) { return null;}	
	
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

shared abstract class Theme (String siteContext, ThemeConfig config) {
    shared formal String id;
    
    shared formal {Attached *} attachments;
    
    shared formal Layout layout;

    shared formal Binder binder;

    "Any custom regions exported by this theme and returnable by plugins"
    shared default Region? newRegion<T>() given T satisfies Region {
        value it = typeLiteral<T>();
        value et = type(it).extendedType;
        if (exists et, is Region rg = et.declaration.instantiate()) {
            return rg;
        }
        return null;
    }
    
    shared formal String assemble(Map<String, String> keyMap, Paged  tm);
}