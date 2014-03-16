import ceylon.net.http.server { CnRequest = Request, CnResponse = Response }
import com.dgwave.lahore.api { ... }
import ceylon.io.charset { utf8 }
import ceylon.net.http { contentType }

class SiteService(Site site) { 

    shared void siteService (CnRequest cnReq, CnResponse cnRes) {
        Request req = DefaultRequest(cnReq);
        DefaultResponse resp = DefaultResponse(req, ["text/html", utf8]);
        site.siteService(req, resp);
        cnRes.responseStatus = resp.status;
        cnRes.addHeader(contentType("text/html", utf8));
        cnRes.writeString(resp.string);
    }
}
