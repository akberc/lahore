import ceylon.collection { HashMap }
import com.dgwave.lahore.api { ... }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }

shared HashMap<String, [ContentType, String|ByteBuffer]> attachmentCache
        = HashMap<String, [ContentType, String|ByteBuffer]>();

shared void cacheResource(String key, Attached tb, Resource? resource) {
    if (exists resource,
        !attachmentCache.contains(key)) { // TODO expire at some point
        value contentType = tb.contentType;
        switch (contentType)
        case (textCss, applicationJavascript, applicationJson) {
            String? stuff = resource.textContent();
            if (exists stuff) {
                attachmentCache.put(key, [tb.contentType, stuff]);
            }
        }
        case (imageIcon, imageJpg, imagePng) {
            BinaryResource bRes = BinaryResource(resource);
            attachmentCache.put(key, [tb.contentType,
                bRes.binaryContent() else newByteBuffer(0)]);
        }
    } else {
        log.warn("Resource ``tb.name`` could not be found");
    }
}