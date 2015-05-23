import ceylon.collection {
    HashMap
}
import ceylon.io.buffer {
    ByteBuffer,
    newByteBufferWithData
}
import ceylon.io.charset {
    Charset,
    utf8
}
import ceylon.net.http {
    CnHeader=Header,
    ...
}
import ceylon.net.http.server {
    CnRequest=Request,
    CnResponse=Response
}

import com.dgwave.lahore.api {
    ...
}

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
        shared actual Boolean defines(Object key) => transient.defines(key);
    }
    
    shared actual String path => cnReq.path;
    shared actual Session session => nothing; 
}

class DefaultResponse(Request req, CnResponse cnRes) satisfies Response {
 
    shared actual void addHeader(String name, String* vals) {
        cnRes.addHeader(CnHeader(name, *vals));
    }
    
    shared actual void withStatus(Integer status) {
        cnRes.responseStatus = status;
    }
    
    shared actual void withContentType(ContentType cType) {
        switch(cType)
        case (applicationJavascript | applicationJson | textHtml | textCss) {
            cnRes.addHeader(contentType(cType.string, utf8));
        }
        else {
            cnRes.addHeader(contentType(cType.string));
        }
    }
    
    shared actual void writeString(String write) {
        cnRes.writeString(write);
    }
  
    shared actual void writeBytes(Array<Byte> bytes) {
        cnRes.writeByteBuffer(newByteBufferWithData(*bytes));
    }
}