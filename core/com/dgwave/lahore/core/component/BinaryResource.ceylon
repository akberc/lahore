import java.lang { ByteArray }
import java.util.zip { ZipFile }
import ceylon.io.buffer { ByteBuffer, newByteBufferWithData }
import ceylon.file { parseURI }

shared class BinaryResource(Resource res) satisfies Resource {

    shared actual Integer size => res.size;

    "No text from binary resource"
    shared actual String textContent(String encoding) => res.uri;

    shared actual String uri => res.uri;

    shared ByteBuffer? binaryContent() {
        try (Zip zip = Zip(String(res.uri.sublistTo(
            (res.uri.lastInclusion("!") else 1) - 1))) ) {

            return zip.bytes(String(res.uri.sublistFrom(
                (res.uri.lastInclusion("!") else -1) + 1)));

        } catch (Exception e) {
            log.debug(e.message);
            return null;
        }
    }
}

class Zip(String uri) satisfies Obtainable {
    String path = parseURI(uri).absolutePath.string;
    ZipFile file = ZipFile(path);

    shared actual void obtain() {

    }

    shared ByteBuffer bytes(String internalPath) {
        value entry = file.getEntry(internalPath);
        value byt = ByteArray(entry.size);
        file.getInputStream(entry).read(byt);
        return newByteBufferWithData(*byt.byteArray);
    }

    shared actual void release(Throwable? error) {
        file.close();
    }
}