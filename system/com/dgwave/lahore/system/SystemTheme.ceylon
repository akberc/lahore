import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap, LinkedList }

shared class SystemTheme (Site site) satisfies Theme {
	
    shared actual String id = "system";
    
    "Theme extends HTML5 elements and assigns them a grid range in the theme. Specifies input required for each page render"
    class SystemThemeHeader(H1 heading) extends Header({heading}) {
    	shared actual [Integer, Integer] gridSpan = [1,12];  
    }
 
 	"Does not need any variable"
    object startAside extends Aside( "one", 
 		Div {
 			
 		}
 	) {
    	shared actual [Integer, Integer] gridSpan = [1,2];
    }
    
    class SystemThemeMain(String* rendered) extends Main(
        Div {
            {Span("\n".join(rendered))};
        }
    ) {
    	shared actual [Integer, Integer] gridSpan = [3,10];	
    }
    
    object endAside extends Aside( "two", 
        Div {
            
        }
    ) {
        shared actual [Integer, Integer] gridSpan = [11,12];
    }
    
    object footer extends Footer({
       P("&copy; Copyright 2013-2014 Digiwave Systems Ltd.")
	}) {
		shared actual [Integer, Integer] gridSpan =[1,12];	
	}
    
    "Any custom regions exported by this theme and returnabel by plugins"
    shared actual {Region*} regions = { };
    shared actual {Script*} scripts = {};
    shared actual {Style*} styles = {};
    
    shared actual {Template<Markup>*} templates = {};

    shared actual JsAngular binder = JsAngular();
    
    shared actual TwitterBootstrap layout 
            = TwitterBootstrap();
    
    shared actual HTML5Custom renderer = HTML5Custom();
    
    shared actual String assemble(TaggedMarkup tm) {
        
        String path = "/admin.site";
        Html page = Html { 
            attrs = {"lang" -> "en"};
            head = Head {
                title = PageTitle("Lahore Console");
                Meta ({"http-equiv" -> "Content-Type", "content" -> "text/html; charset=UTF-8"}),
                Link ({"href" -> "``path``/css/bootstrap.min.css", "rel" -> "stylesheet"}),
                Link ({"href" -> "``path``/css/style.css", "rel" -> "stylesheet"}),
                for (String->String link in tm[0]) 
                    if ("css" == link.key) Link({"href" -> link.item, "rel" -> "stylesheet"})
            };
            body = Body {
                Div { classes=["container"]; {
                    Div { classes=["row"]; { 
                        Div { classes=["span12"]; id="header";
                            SystemThemeHeader(H1("Lahore"))
                        }
                    };},
                    Div { classes=["row"]; { 
                        Div { classes=["span2"]; id="aside1";
                            startAside
                        },
                        Div { classes=["span8"]; id="content";
                            SystemThemeMain(for (String mkp in tm[1]) mkp)
                        },
                        Div { classes=["span2"]; id="aside2";
                            endAside
                        }                        
                    };},
                    Div { classes=["row"]; { 
                        Div { classes=["span12"]; id="footer";
                            footer
                        }
                    };}
                };} // container
                
            }; // body
        };

        return page.render();
    }
}

shared class TwitterBootstrap () satisfies Layout {

    shared actual {Div *} containers => {
        
    };
    
    shared actual Boolean fluid = true;
    
    shared actual [Integer, Integer] grid = [12, 16];
    
    shared actual Boolean rtl = false;
    
    shared actual Boolean validate({Region *} regions) => true;
    
    shared actual [Integer, Integer] viewPort = [1024, 768];

}


shared class HTML5Custom() satisfies Renderer{

    shared actual TaggedMarkup render({Result*} output) {

        HashMap<String, String> attached = HashMap<String, String>();
        LinkedList<String> markup = LinkedList<String>();
        
        Boolean isMeta(Assoc topAssoc) {
            for (k->i in topAssoc) {
                if (k.startsWith("#")) {
                    return false;
                }
            }
            return true;
        }
        
        void processAttached(Assoc? toProcess) {
            if (exists toProcess) {
                for (e->f in toProcess) {
                    if (is Array f) {
                        for (g in f) {
                            if (is String g) {
                                attached.put(e, g);
                            }
                        }
                    }
                }
            }		
        }
        
        doc("processing #xxxx -> something ")
        void processSimpleAssoc(Assoc simple) {
            for (e in simple.keys) {
                if (e == "#attached") {
                    processAttached(simple.getAssoc("#attached"));
                } else if (e == "#markup") {
                    if (exists s = simple.getString("#markup")) {
                        markup.add(s);				
                    }
                }
            }
        }
        
        /**
         Main initializer
         */	
        for (routeOutput in output) {
            if (is Assoc routeOutput) { 
                if (isMeta(routeOutput)) { // is it meta or simple?
                    for (k->i in routeOutput) {
                        if (is Assoc i) {
                            processSimpleAssoc(i);
                        }                    }                } else {
                    processSimpleAssoc(routeOutput);
                }
            } 
            else if (is Fragment routeOutput) {
                markup.add(routeOutput.render());
            }
        }
        return [attached, markup];
    } 
}

shared class JsAngular() satisfies Binder {

    shared actual String extractClientScript() => nothing;
    
    shared actual String extractClientStyle() => nothing;
    

}