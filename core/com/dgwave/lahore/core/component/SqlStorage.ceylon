import com.dgwave.lahore.api { Storage, Document, Primitive, Store, Locator, Config, Preference }
import ceylon.file { Path}
import ceylon.language.meta.declaration { Module }

shared class SqlStorage(Path sqlPath) satisfies Storage {
    shared actual Locator base => nothing;
    
    shared actual Store<Config> configStore(String context, Module mod) => nothing;
    
    shared actual Store<Document> dataStore(String context) => nothing;
    
    shared actual Store<Preference> preferenceStore() => nothing;
}

shared class SqlDataStore(Locator sqlPath) satisfies Store<Document> {

    shared actual Boolean append(Document storable) {return false;}

    shared actual Document? load({Primitive+} uniqueKey, Integer version) {return null;}

    shared actual {Document*} loadAll({Primitive+} uniqueKey) {return {};}

    shared actual {Document*} find (String relativePath) {return {};}

    shared actual Document? remove({Primitive+} uniqueKey, Integer version) {return null;}

    shared actual Boolean save(Document storable) {return false;}

    shared actual Locator base = sqlPath;
    shared actual String relativePath => nothing;
    
}


doc("This is a convenience method. Responsibility of the client to keep or discard the storage")
throws(`class Exception`)
shared SqlStorage sqlStorage(Path path) {
    
    return SqlStorage(path);
}