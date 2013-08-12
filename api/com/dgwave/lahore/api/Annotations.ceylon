import ceylon.language.model { OptionalAnnotation }
import ceylon.language.model.declaration { ClassOrInterfaceDeclaration, FunctionDeclaration }

"The annotation class for [[id]]."
shared final annotation class Id(shared String id)
        satisfies OptionalAnnotation<Id, ClassOrInterfaceDeclaration> {}

"Annotation to specify Lahore module short id" 
shared annotation Id id(String id) => Id(id);

"The annotation class for [[name]]."
shared final annotation class Name(shared String name, shared String locale)
        satisfies OptionalAnnotation<Name, ClassOrInterfaceDeclaration> {}

"Annotation to specify Lahore module human-friendly name" 
shared annotation Name name(String name, String locale ="en") => Name(name, locale);

"The annotation class for [[description]]."
shared final annotation class Description(shared String description, shared String locale)
        satisfies OptionalAnnotation<Description, ClassOrInterfaceDeclaration> {}

"Annotation to specify Lahore module description" 
shared annotation Description description(String description, String locale ="en") => Description(description, locale);

"The annotation class for [[configure]]."
shared final annotation class Configure(shared String configureLink)
        satisfies OptionalAnnotation<Configure, ClassOrInterfaceDeclaration> {}

"Annotation to specify module configureation URL" 
shared annotation Configure configure(String configureLink) => Configure(configureLink);

"The annotation class for [[configure]]."
shared final annotation class RouteAnnotation(shared String routeName, shared String routeMethods, shared String routePath,  shared String routerPermission)
        satisfies OptionalAnnotation<RouteAnnotation, FunctionDeclaration> {}

"Annotation to specify Lahore web route" 
shared annotation RouteAnnotation route (String routeName, String routeMethods, String routePath, String routerPermission = "") 
	=> RouteAnnotation(routeName, routeMethods, routePath, routerPermission);

"The annotation class for [[hook]]."
shared final annotation class HookAnnotation(shared String hookName)
        satisfies OptionalAnnotation<HookAnnotation, FunctionDeclaration> {}

"Annotation to specify Lahore module short id" 
shared annotation HookAnnotation hook(String hookName) => HookAnnotation(hookName);