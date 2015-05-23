import ceylon.collection { HashMap }
import com.dgwave.lahore.api { ... }

shared HashMap<String, [ContentType, String|Array<Byte>]> attachmentCache
        = HashMap<String, [ContentType, String|Array<Byte>]>();

shared void cacheResource(String key, Attached tb, Resource? resource) {
    if (exists resource,
        !attachmentCache.contains(key)) { // TODO expire at some point
        value contentType = tb.contentType;
        switch (contentType)
        case (textHtml | textCss | applicationJavascript | applicationJson) {
            String? stuff = resource.textContent();
            if (exists stuff) {
                attachmentCache.put(key, [tb.contentType, stuff]);
            }
        }
        case (imageIcon | imageJpg | imagePng) {
            BinaryResource bRes = BinaryResource(resource);
            attachmentCache.put(key, [tb.contentType,
                bRes.binaryContent() else Array<Byte>({})]);
        }
    } else {
        log.warn("Resource ``tb.name`` could not be found");
    }
}