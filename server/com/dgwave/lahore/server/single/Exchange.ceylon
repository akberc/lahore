import com.dgwave.lahore.api { ... }
import ceylon.net.http.server { CnRequest = Request }
import ceylon.io.charset { Charset, utf8 }
import ceylon.collection { HashMap }
import ceylon.net.http { ... }

class DefaultRequest(CnRequest cnReq) satisfies Request {

    shared actual Map<String,String> headers = HashMap<String, String>();
    shared actual HttpMethod method {
        if (is AbstractMethod m = cnReq.method) {
            switch(m)
            case(get) { return httpGET;}
            case(post) { return httpPOST;}
            case(options) { return httpOPTIONS;}
            case(head) { return httpHEAD;}
            case(put) { return httpPUT;}
            case(delete) { return httpDELETE;}
            case(trace) { return httpTRACE;}
            case(connect) { return httpCONNECT;}
        }
        return httpGET;
    }
    
    shared actual object parameters satisfies Map<String, String> {
        value transient = HashMap<String, String>();
        shared actual Map<String,String> clone() => transient.clone();        
        shared actual String? get(Object key) {
            if (exists i = transient.get(key)) {
                return i;
            } else {
                if (is String key,
                    exists ii = cnReq.parameter(key)) {
                    transient.put(key,ii);
                }
            }
            return transient.get(key);
        }
        shared actual Iterator<String->String> iterator() => transient.iterator();
        shared actual Boolean equals(Object that) => transient.equals(that);
        shared actual Integer hash => transient.hash;
    }
    
    shared actual String path => cnReq.path;
    shared actual Session session => nothing;
    
}

class DefaultResponse(Request req) satisfies Response {
    
    StringBuilder builder = StringBuilder();
    shared variable [String, Charset] contentType = ["text/html", utf8];

    shared variable Integer status = 200;
    
    shared actual void withStatus(Integer status) {
        this.status = status;
    }
    
    shared actual void withContentType([String, Charset] contentType) {
        this.contentType = contentType;
    }
    
    shared actual void writeString(String write) {
        builder.append(write);
    }
    
    shared actual String string => builder.string;
}