import com.dgwave.lahore.api { ... }
import ceylon.test { ... }

doc ("Run tests for static global methods for Lahore")

void testHtml(){
    
    value page = Html(
    Head {
        title = PageTitle("Lahore: home page");    },
    Body {
        H2 { classes=["big"]; content = "Welcome to Lahore, ``plus(1, 2)`` !";},
        P("Now, get your act on :)")    }, 
    {"lang" -> "en"}    );
    assertEquals("<html lang=\"en\">\n <head>\n  <title>Lahore: home page</title>\n </head>\n <body>\n  <h1 class=\"big\">Welcome to Lahore, 3 !</h1>\n  <p>Now, get your act on :)</p>\n </body>\n</html>",page.render());
}