import ceylon.logging { logger, Logger }
import com.dgwave.lahore.api { ... }

Logger log = logger(`module com.dgwave.lahore.system_theme`);

shared class SystemTheme(String siteContext, SystemThemeConfig config)
        extends Theme(siteContext, config) {

    shared actual String id = "system";
    shared actual Binder binder = JsAngular();
    shared actual Layout layout = TwitterBootstrap();
    shared actual Renderer renderer = SystemRenderer();
    shared actual Styler styler = TwitterBootstrapSTyler();

    shared actual {Attached*} attachments = {
        Attached("bootstrap-min-css", "css/bootstrap.min.css", textCss),
        Attached("style1", "css/style.css", textCss),
        Attached("bg", "img/bg.png", imagePng),
        Attached("glyphicons-halflings-white", "img/glyphicons-halflings-white.png", imagePng),
        Attached("glyphicons-halflings", "img/glyphicons-halflings.png", imagePng),
        Attached("header", "img/header.jpg", imageJpg),
        Attached("bootstrap-min-js", "js/bootstrap.min.js", applicationJavascript),
        Attached("jquery-1.10.2-min-js", "js/jquery-1.10.2.min.js", applicationJavascript),
        Attached("favicon", "favicon.ico", imageIcon)
    };

    "Theme extends HTML5 elements and assigns them a grid range in the theme.
        Specifies input required for each page render"
    class SystemThemeHeader(H1 heading) extends Header({ heading }) {
        shared actual [Integer, Integer] gridSpan = [1, 12];
    }

    "Does not need any variable"
    object startAside extends Aside("one",
        Div {
        }
    ) {
        shared actual [Integer, Integer] gridSpan = [1, 2];
    }

    class SystemThemeMain(Div contained) extends Main(contained) {
        shared actual [Integer, Integer] gridSpan = [3, 10];
    }

    object endAside extends Aside("two",
        Div {
        }
    ) {
        shared actual [Integer, Integer] gridSpan = [11, 12];
    }

    object footer extends Footer({
            P("&copy; Copyright 2013-2014 Digiwave Systems Ltd.")
        }) {
        shared actual [Integer, Integer] gridSpan = [1, 12];
    }

    shared actual String assemble(Map<String,String> map, Paged tm) {
        String context = siteContext == "/" then "" else siteContext;
        Html page = Html {
            attrs = { "lang"->"en" };
            head = Head {
                title = tm.top.narrow<PageTitle>().first else PageTitle("Lahore");
                children = {
                    Meta({ "http-equiv"->"Content-Type", "content"->"text/html; charset=UTF-8" }),
                    Meta({ "charset"->"utf-8" }),
                    Meta({ "http-equiv"->"X-UA-Compatible", "content"->"IE=edge,chrome=1" })
                }.chain(
                    tm.top.narrow<Meta>()
                ).chain({
                        Link({ "href"->"``context``/css/bootstrap.min.css", "rel"->"stylesheet" }),
                        Link({ "href"->"``context``/css/style.css", "rel"->"stylesheet" }),
                        Link({ "href"->"``context``/favicon.ico", "rel"->"icon" })
                }).chain({
                        for (att in tm.top.narrow<Attached>())
                            if (att.contentType == textCss && map.get(att.name) exists)
                                Link({ "href"->(map.get(att.name) else ""), "rel"->"stylesheet" })
                }).chain({
                        // script
                });
            };
            body = Body {
                children = {
                Div { classes = ["container"]; {
                        Div { classes = ["row"]; {
                                Div { classes = ["span12"]; id = "header";
                                    SystemThemeHeader(H1(a(siteContext, tm.top.narrow<PageTitle>().first?.containedContent else "Lahore")))
                                }
                            }; },
                        Div { classes = ["row"]; {
                                Div { classes = ["span2"]; id = "aside1";
                                    startAside
                                },
                                Div { classes = ["span8"]; id = "content";
                                    (tm.region is Div)
                                            then SystemThemeMain({ tm.region }.narrow<Div>().first else Div { })
                                            else tm.region
                                },
                                Div { classes = ["span2"]; id = "aside2";
                                    endAside
                                }
                            }; },
                        Div { classes = ["row"]; {
                                Div { classes = ["span12"]; id = "footer";
                                    footer
                                }
                            }; }
                    }; } // container
                }.chain(tm.bottom.narrow<Script>().sequence());
            }; // body
        };

        return page.render();
    }
}

shared class TwitterBootstrap() satisfies Layout {

    shared actual {Div*} containers => {
    };

    shared actual Boolean fluid = true;

    shared actual [Integer, Integer] grid = [12, 16];

    shared actual Boolean rtl = false;

    shared actual Boolean validate({Region*} regions) => true;

    shared actual [Integer, Integer] viewPort = [1024, 768];
}

shared class JsAngular() satisfies Binder {

    shared actual String extractClientScript() => nothing;

    shared actual String extractClientStyle() => nothing;
}

shared class SystemRenderer() satisfies Renderer {
}

shared class TwitterBootstrapSTyler() satisfies Styler {
}
