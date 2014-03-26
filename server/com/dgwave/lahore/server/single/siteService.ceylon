import ceylon.net.http.server { CnRequest = Request, CnResponse = Response }
import com.dgwave.lahore.api { ... }
import ceylon.net.http { contentType }
import com.dgwave.lahore.core { Engine }

class SiteService(Engine engine) { 

    shared void siteService (CnRequest cnReq, CnResponse cnRes) {
        Request req = DefaultRequest(cnReq);
        DefaultResponse resp = DefaultResponse(req);
        engine.siteService(req, resp);
        cnRes.responseStatus = resp.status;
        cnRes.addHeader(contentType(resp.contentType[0], resp.contentType[1]));
        cnRes.writeString(resp.string);
    }
}
