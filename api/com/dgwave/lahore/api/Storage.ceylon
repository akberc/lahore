import ceylon.collection { ArrayList }
import ceylon.language.meta.declaration { Module }

shared interface Storage {
    shared formal Locator base;
    shared formal Store<Config> configStore(String context, Module mod);
    shared formal Store<Document> dataStore(String context);
    shared formal Store<Preference> preferenceStore();
}

"Supported Schemes"
shared abstract class Scheme() of httpScheme | httpsScheme | fileScheme | dbcScheme {}
shared object dbcScheme extends Scheme() {string => "dbc";}
shared object fileScheme extends Scheme() {string => "file";}
shared object httpsScheme extends Scheme() {string => "https";}
shared object httpScheme extends Scheme() {string => "http";}


"Similar to URI/URL"
shared class Locator(scheme, contextPath, address="", resourceName="", parameters={}) {
    shared Scheme scheme;
    shared String address;
    shared String contextPath;
    shared String resourceName;
    shared {Entry<String, String>*} parameters;
    shared default String canonical() {
        return "``scheme.string``:``address````contextPath``/``resourceName``?``"&".join({
                for (p in parameters) "``p.key``=``p.item``"
            })``";
    }
    shared actual String string => canonical();
}

shared interface Storable {
    shared formal {Primitive+} uniqueKey;
    shared formal Integer version;  
}

shared abstract class Document() satisfies Storable {

    shared formal Basic payLoad;
}

shared abstract class Preference() satisfies Storable {
    shared formal Human user;
    shared formal String key;
    shared formal String item;
}

shared abstract class Config() satisfies Storable {

    shared formal String[] stringsWithDefault (String key, String[] defValues = []);
    
    shared default String stringWithDefault(String key, String defValue) {
        if (exists s = stringsWithDefault(key, [defValue]).first) {
            return s;
        } else {
            return defValue;
        }
    }
    
    shared default String? stringOnly(String key) {
        if (exists s = stringsWithDefault(key, []).first) {
            return s;
        } else {
            return null;
        }
    }
}

"Store method with implied error handling"
shared interface Store<T> given T satisfies Storable {
    shared formal String relativePath;
    "[[null] return indicates load not successful]"
    shared formal T? load({Primitive+} uniqueKey, Integer version = 0);
    
    "All versions of a storable"
    shared formal {T*} loadAll({Primitive+} uniqueKey);
    
    shared formal T? remove({Primitive+} uniqueKey, Integer version = 0);
    shared formal Boolean save(T storable);
    shared formal {T*} find(String query);
    shared formal Boolean append(T storable);
    
    shared formal Locator base;}

shared abstract class ModuleConfig(Module mod) extends Config() {
    shared actual {Primitive+} uniqueKey = {mod.name};
    shared actual Integer version = 0;
}

shared abstract class AssocConfig(assoc = Assoc()) extends Config() {
    Assoc assoc;
    
    shared actual String[] stringsWithDefault(String key, String[] defValues) {
        if (exists a = assoc.getArray(key)) {
            return filterStrings(a);
        } else {
            return defValues;
        }
    }
    
    String[] filterStrings(Array a) { 
        value sb = ArrayList<String>(); 
        for (ae in a) {
            if (is String ae) {
                sb.add(ae);
            }
        }
        return sb.sequence();
    }	
}
