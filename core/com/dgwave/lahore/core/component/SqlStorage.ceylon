import com.dgwave.lahore.api { Storage, Entity, Primitive }
import ceylon.file { Path }

shared class SqlStorage(Path sqlPath) satisfies Storage<Entity> {

    shared actual Boolean append(String relativePath, Entity elem) {return false;}

    shared actual Entity? load(String relativePath, {Primitive+} uniqueKey) {return null;}

    shared actual {Entity*} loadAllVersions(String relativePath, {Primitive+} uniqueKey) {return {};}

    shared actual {Entity*} find (String relativePath, String query) {return {};}

    shared actual Entity? remove(String relativePath, {Primitive+} uniquKey) {return null;}

    shared actual Boolean save(String relativePath, Entity elem) {return false;}

    shared actual Path basePath = sqlPath;
}
