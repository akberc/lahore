import com.dgwave.lahore.api { ... }
import ceylon.test { ... }
import com.dgwave.lahore.core.component { parseTemplate, HtmlLiteral, readFileAsString, segments, parsingRegexes }
import ceylon.file { parsePath, File }
by ("Akber Choudhry")
doc ("Run tests for Lahore Templates")

void testTemplate(){

	Template<Markup> t = parseTemplate("C:/work/antlr/html.html.twig");
	for (f in t.apply({"head_title"-> HtmlLiteral("title", "Lahore Title")})) {
		print(f);	}
	//assertEquals("<html>\n <head>\n  <title>Lahore: home page</title>\n </head>\n <body>\n  <h1 class=\"big\">Welcome to Lahore, 3 !</h1>\n  <p>Now, get your act on :)</p>\n </body>\n</html>",page.render());
	
	if (is File f = parsePath("html.template").resource) {
		String raw = readFileAsString(f);
		print(segments(raw, parsingRegexes.templateParser));
	}
}