import ceylon.test { ... }

doc ("Run tests for static global methods for Lahore")
ignore("Fix spaces in class and attr print loops in Utils.ceylon")
test void testHtml(){
    
    value page = Html(
    Head {
        title = PageTitle("Lahore: home page");    },
    Body {
        H2 { classes=["big"]; content = "Welcome to Lahore, ``plus(1, 2)`` !";},
        P("Now, get your act on :)")    }, 
    {"lang" -> "en"}    );
    assertEquals("<!DOCTYPE html>\n\n<html lang=\"en\">\n <head>\n  <title>Lahore: home page</title>\n </head>\n <body>\n  <h2 class=\"big\">Welcome to Lahore, 3 !</h2>\n  <p>Now, get your act on :)</p>\n </body>\n</html>",page.render());
}