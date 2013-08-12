import com.dgwave.lahore.api { Fragment, Result, Markup, Template, ContainedMarkup }

shared class HtmlLiteral(type, String rawContent) extends Markup() satisfies ContainedMarkup{
	shared String type;
	shared actual String containedContent = rawContent;
	
}

shared interface Page {
	shared formal String render();
}

shared class RawPage({Fragment+} | {ConcreteResult*} routeOutput) satisfies Page{
	
	StringBuilder output = StringBuilder();
	output.append("<!DOCTYPE html>\n<html>\n<head>\n");
	if (is {ConcreteResult*} routeOutput) {
		for (res in routeOutput) {
			for (String->String link in res.attached) {
				if ("css".equals(link.key)) {
					output.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"" + link.item + "\"/>");
				}
			}
			output.append("\n</head>\n<body>");
			for (String mkp in res.markup) {
				output.append(mkp + "\n");
			}
			output.append("</body>\n</html>\n");
		}
	} else {
	
		output.append(routeOutput.string);
	}
	
	shared actual String render() {
		return output.string;
	}
}

shared class TemplatedPage({Result*} fragments, String templateId) satisfies Page {

	Template<Markup> template = templates.getRootTemplate(templateId);
	shared actual String render() => nothing; /* TODO auto-generated stub */
	
	
//return template.apply({
//				"#html_attributes"->"",
//				"#head"->"",
//				"#head_title"->"Lahore System", // FIXME with Sites
//				"#styles"->"",
//				"#scripts"->"",
//				"#attributes"->"",
//				"#page_top"->"",
//				"#page_bottom"->"",
//				"#page" -> rawPage
//			});
}