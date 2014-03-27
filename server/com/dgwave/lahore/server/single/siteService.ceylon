import ceylon.net.http.server { CnRequest = Request, CnResponse = Response }
import com.dgwave.lahore.api { ... }
import com.dgwave.lahore.core { Engine }

class SiteService(Engine engine) { 

    shared void siteService (CnRequest cnReq, CnResponse cnRes) {
        Request req = DefaultRequest(cnReq);
        DefaultResponse resp = DefaultResponse(req, cnRes);
        engine.siteService(req, resp);
    }
}
