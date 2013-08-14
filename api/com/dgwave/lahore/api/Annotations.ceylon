import ceylon.language.model { OptionalAnnotation, SequencedAnnotation }
import ceylon.language.model.declaration { FunctionDeclaration }

"The annotation class for [[id]]."
shared final annotation class Id(shared String id)
        satisfies OptionalAnnotation<Id, Plugin> {}

"Annotation to specify Lahore module short id" 
shared annotation Id id(String id) => Id(id);

"The annotation class for [[name]]."
shared final annotation class Name(shared String name, shared String locale)
        satisfies OptionalAnnotation<Name, Plugin> {}

"Annotation to specify Lahore module human-friendly name" 
shared annotation Name name(String name, String locale ="en") => Name(name, locale);

"The annotation class for [[description]]."
shared final annotation class Description(shared String description, shared String locale)
        satisfies OptionalAnnotation<Description, Plugin> {}

"Annotation to specify Lahore module description" 
shared annotation Description description(String description, String locale ="en") => Description(description, locale);

"The annotation class for [[configure]]."
shared final annotation class Configure(shared String configureLink)
        satisfies OptionalAnnotation<Configure, Plugin> {}

"Annotation to specify module configuration URL" 
shared annotation Configure configure(String configureLink) => Configure(configureLink);

"The annotation class for [[route]]."
shared final annotation class RouteAnnotation(shared String routeName, shared String routePath)
        satisfies OptionalAnnotation<RouteAnnotation, FunctionDeclaration> {}

"Annotation to specify Lahore web route" 
shared annotation RouteAnnotation route (String routeName, String routePath) 
	=> RouteAnnotation(routeName, routePath);

"The annotation class for [[permission]]."
shared final annotation class Permission(shared String permission)
        satisfies OptionalAnnotation<Permission, FunctionDeclaration> {}

"Annotation to specify the permission on a web route, hook or entity" 
shared annotation Permission permission(String permission) => Permission(permission);

"The annotation class for [[methods]]."
shared abstract class HttpMethod()
	of httpGET | httpPOST | httpPUT | httpHEAD | httpDELETE | httpTRACE | httpCONNECT |
		httpOPTIONS | httpPROPFIND | httpPROPPATCH | httpMKCOL |
		httpCOPY | httpMOVE | httpLOCK | httpUNLOCK {}
shared object httpGET extends HttpMethod() {}
shared object httpPOST extends HttpMethod() {}
shared object httpPUT extends HttpMethod() {}
shared object httpDELETE extends HttpMethod() {}
shared object httpHEAD extends HttpMethod() {}
shared object httpOPTIONS extends HttpMethod() {}
shared object httpTRACE extends HttpMethod() {}
shared object httpCONNECT extends HttpMethod() {}
shared object httpPROPFIND extends HttpMethod() {}
shared object httpPROPPATCH extends HttpMethod() {}
shared object httpMKCOL extends HttpMethod() {}
shared object httpCOPY extends HttpMethod() {}
shared object httpMOVE extends HttpMethod() {}
shared object httpLOCK extends HttpMethod() {}
shared object httpUNLOCK extends HttpMethod() {}

shared final annotation class Methods(HttpMethod method)
        satisfies SequencedAnnotation<Methods, FunctionDeclaration> {}

"Annotation to specify the HTTP methods allowed on a route" 
shared annotation Methods methods(HttpMethod method) => Methods(method);

