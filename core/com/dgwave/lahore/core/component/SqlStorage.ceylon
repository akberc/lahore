import com.dgwave.lahore.api { Storage, Data, Primitive, Store, Locator, Config, Preference }
import ceylon.file { Path}
import ceylon.language.meta.declaration { Module }

shared class SqlStorage(Path sqlPath) satisfies Storage {
    shared actual Locator base => nothing;
    
    shared actual Store<Config> configStore(String context, Module mod) => nothing;
    
    shared actual Store<Data> dataStore(String context) => nothing;
    
    shared actual Store<Preference> preferenceStore() => nothing;
}

shared class SqlDataStore(Locator sqlPath) satisfies Store<Data> {

    shared actual Boolean append(Data storable) {return false;}

    shared actual Data? load({Primitive+} uniqueKey, Integer version) {return null;}

    shared actual {Data*} loadAll({Primitive+} uniqueKey) {return {};}

    shared actual {Data*} find (String relativePath) {return {};}

    shared actual Data? remove({Primitive+} uniqueKey, Integer version) {return null;}

    shared actual Boolean save(Data storable) {return false;}

    shared actual Locator base = sqlPath;
    shared actual String relativePath => nothing;
    
}


doc("This is a convenience method. Responsibility of the client to keep or discard the storage")
throws(`class Exception`)
shared SqlStorage sqlStorage(Path path) {
    
    return SqlStorage(path);
}