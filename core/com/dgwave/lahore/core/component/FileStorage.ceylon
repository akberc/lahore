import com.dgwave.lahore.api { Storage, Config, Primitive }
import ceylon.file { File, Resource, Directory, Path, Nil, Link }

shared class FileStorage( configDir) satisfies Storage<Config> {

    Directory configDir;

    shared actual Boolean append(String relativePath, Config config){
        return false;
    }

    doc("Think of path as a table and keys of a row in the table")
    shared actual Config? load(String relativePath, {Primitive+} uniqueKey)  {
        Resource r = configDir.childResource(relativePath);
        switch(r)
        case (is File) {
            if (relativePath.endsWith("json")) {
                return parseJsonAsConfig(readFileAsString(r));	
            } else if (relativePath.endsWith("yml") || relativePath.endsWith("yaml")) {
               // TODO return parseYamlAsConfig(readFileAsString(r));
               return null;	
            } else {
                log.error("Configuration file ``relativePath`` is not supported");
                return null;
            }
        } else {
            log.error("Configuration file ``relativePath`` does not exist!");
            return null;
        }		
    }

    shared actual {Config*} loadAllVersions(String relativePath, {Primitive+} uniqueKey) {
        return {};
    }

    shared actual {Config*} find (String relativePath, String query) {
        return {};
    }

    shared actual Config? remove(String relativePath, {Primitive+} uniquKey) {
        return null;
    }

    shared actual Boolean save(String relativePath, Config config) {
        return false;
    }

    shared actual Path basePath => configDir.path;

    shared String readFileAsString(File file) {  
        value sb = StringBuilder();
        value reader = file.Reader();
        try {
            while(exists line = reader.readLine()) {
                sb.append(line);
                sb.append("\n");
            }
        } finally {
            reader.close();
        }
        return sb.string;
    }	
}

doc("This is a convenience method. Responsibility of the client to keep or discard the storage")
throws(`class Exception`)
shared FileStorage fileStorage(Path path) {
    Resource dir = path.resource;
    try {
        switch(dir)
        case (is Nil) {
            dir.createDirectory();
            return fileStorage(dir.path);
        }
        case(is Directory) {
            return FileStorage(dir);
        }
        case (is File) {
            throw Exception("File exists at location ``path.string``. It should be a directory");
        }
        case (is Link) {
            return fileStorage(dir.linkedPath);
        }
    } catch (Exception ex) {
        throw ex;
    }
}
