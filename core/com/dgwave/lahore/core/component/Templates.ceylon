import com.dgwave.lahore.api { ... }
import ceylon.collection { HashMap, LinkedList }
import ceylon.file { Path, parsePath, File }
doc("Template supplied as lines read from a file")
shared class MarkupTemplate() extends HtmlTemplate()  { // TODO injection
	
	shared actual HashMap<String,Markup> fragments = HashMap<String, Markup>();
	shared variable LinkedList<String->String> instructions = LinkedList<Entry<String, String>>();
    variable value output = LinkedList<Markup>();
    
	shared actual {Markup*} apply({Entry<String, Markup>*} fills) {
		
		fragments.putAll(fills);
		variable  value ifBlock = LinkedList<Boolean>();
		variable value allowed = true;
		
		for (k->i in instructions) {
		 if (k == "control") {
			if (i.startsWith("if")) {
				value tokens = i.split((Character c) => c == " ");
				if (isIfMatched(tokens)) {
					ifBlock.add(true); //push on stack
					allowed = true;
				} else { // if not matched
					ifBlock.add(false); //push on stack
					allowed = false;
				}
			}
			else if (i.startsWith("else")) { //reverse but do not pop stack
				if (allowed == true) {
					allowed = false;
				} else {
					allowed = true;
				}
			}
			else if (i.startsWith("endif")) { // pop last value into allowed
				if (exists x = ifBlock.last) {
					allowed = x; //pop
					if (exists n = ifBlock.lastIndex) {
						ifBlock.remove(n);
					}
				} else {
					allowed = true; // default
				}
			} else {
				watchdog(1, "Template", "Only 'if-or-/else/endif' control supported in Markup template");
			}
		 }
		 
		 if (allowed) {
			processInstruction(k, i);
		 }
		} // for
		return {for (o in output) o};
	}
	
	Boolean isIfMatched({String*} tokens) {
		variable Boolean v = false; // first token is 'if', so skip
		for(t in tokens) {
		  if (v) {
			if (exists f = fragments.get(t.trimmed)) {
				return true;
			}
		  } 
		  if (v) {v = false;} else { v = true;} //alternate and skip 'or''
		}
		return false;
	}
	
	void processInstruction (String k, String i) {
		if (k == "literal") {
			output.add(HtmlLiteral("literal", i));
		}
		else if (k == "render") {
			if (exists f = fragments.get(i)) {
				output.add(HtmlLiteral("done", f.render()));
			} else {
				output.add(HtmlLiteral("render", i)); // to be rendered
			}
		}
		else if (k == "translate") {
			output.add(HtmlLiteral("done", t(i)));
		} else {
			output.add(HtmlLiteral(k,i)); // as is
		}
	}
}

class TemplateParser(List<String> lines){
    
    variable Boolean comment = false;
    variable Integer index = 0;
    value template = MarkupTemplate();
    
    shared Template<Markup> parseTemplate() { 
        
        for (line in lines) {
            
             index = 0;
             
             if (isComment(line) || comment) { //begin/end or in multi-line comment
                 // nothing
             } 
             else if (isControl(line)) {
                 addControl(line); 
             }
             else if (isSubst(line)) {
                 if (isFullSubstitution(line)) {
                 	addParameter(line);
             	 } else { //interpolate
             	 	variable Integer num=0; index = 0;// reset
             	 	variable {Integer*} begins = line.occurrences("{{");
             	 	variable Integer[] ends = line.occurrences("}}").sequence;
             	 	
             	 	for (b in begins) {
             	 		if (b > index) {
             	 			template.instructions.add("literal" -> line.span(index, b-1));
             	 		}
             	 		if (exists e = ends[num]) {
							addParameter(line.span(b, e + 1));
							index = e+2;
						}
						num++;
             	 	}
             	 	// last one
             	 	if (exists f = ends[num-1]) {
             	 		if ((f + 2) < line.size) {
             	 	    	template.instructions.add("literal" -> line.span(f+2, line.size));		
             	 		}
             	 	}
             	 }
             }             
             else { // must be literal
                 template.instructions.add("literal" -> line);
             }
        }
             for (i in template.instructions) {print(i);}  
        return template;
    }
    
 	void addParameter(String p) {
        String output = p.trimmed.span(2,p.trimmed.size -3).trimmed;
        {String*} tokens = output.split((Character c) => c == "|");
		if (exists y = tokens.skipping(1).first) { // function
			if (exists x = tokens.first) {
				if (y.trimmed == "t") {
					template.instructions.add("translate" -> x.trimmed.span(1, x.size -2));
				} else {
					watchdog(3, "Template", "function ``y `` is not supported in templates");
				}
			}
		} else {
        	template.instructions.add("render" -> output);
    	}
 	}
 
 	 void addControl(String p) {
        String output = p.trimmed.span(2,p.trimmed.size -3).trimmed;
        template.instructions.add("control" -> output);
 	 }	
     Boolean isControl(String line) {
         if (line.contains("{%")) {
             return true;
         } else {
             return false;
         }
     }
         
     Boolean isComment(String line) {
         variable Boolean ret = false;
         if (line.contains("{#")) {
             comment = true;
             ret = true;
         }
         if (line.contains("#}")) { //maybe same line
             comment = false;
             ret = true;
         }
         return ret;
     }
     
     Boolean isSubst(String line) {
         if (line.contains("{{")) {
             return true;
         } else {
             return false;
         }
     }
     Boolean isFullSubstitution(String line) {
		if (line.trimmed.startsWith("{{") && line.trimmed.endsWith("}}")) { // naked braces
			return true;
		} else {
			return false;
		}
     }
}


"Parses a template"
by("Akber Choudhry")
throws(`Exception`, "If the template is invalid")
shared Template<Markup> parseTemplate(String templateFile){
	
	Path filePath = parsePath(templateFile);
	value lines = LinkedList<String>();
	        
    if (is File file = filePath.resource) {
        watchdog(5, "Template", "Loading template `` templateFile`` ");
        
        value reader = file.reader();

        try {
            while(exists line = reader.readLine()) {
                lines.add(line);
        	} 
        } catch (Exception e) {
            throw e; 
        } finally {
            reader.close(null);
        }
	}

    return TemplateParser(lines).parseTemplate();
}

shared object parsingRegexes { // from Liquid
  String filterSeparator = "/\\|/";
  String argumentSeparator = ",";
  String filterArgumentSeparator = ":";
  String variableAttributeSeparator = ".";
  String tagStart = "\\{\\%";
  String tagEnd = "\\%\\}";
  String variableSignature = "/\\(?[\\w\\-\\.\\[\\]]\\)?/";
  String variableSegment = "/[\\w\\-]/";
  String variableStart = "\\{\\{";
  String variableEnd = "\\}\\}";
  String variableIncompleteEnd = "\\}\\}?";
  String quotedString = "\"[^\"]*\"|'[^']*'";
  String quotedFragment = "/``quotedString``|(?:[^\\s,\\|'\"]|``quotedString``)+/o";
  String strictQuotedFragment = "/\"[^\"]+\"|'[^']+'|[^\\s|:,]+/";
  String firstFilterArgument = "/#{FilterArgumentSeparator}(?:#{StrictQuotedFragment})/o";
  String otherFilterArgument = "/#{ArgumentSeparator}(?:#{StrictQuotedFragment})/o";
  String spacelessFilter = "/^(?:'[^']+'|\"[^\"]+\"|[^'\"])*#{FilterSeparator}(?:#{StrictQuotedFragment})(?:#{FirstFilterArgument}(?:#{OtherFilterArgument})*)?/o";
  String expression = "/(?:#{QuotedFragment}(?:#{SpacelessFilter})*)/o";
  String tagAttributes = "/(\\w+)\\s*\\:\\s*(``quotedFragment``)/o";
  String anyStartingTag = "\\{\\{|\\{\\%";
  String partialTemplateParser = "``tagStart``.*?``tagEnd``|``variableStart``.*?``variableIncompleteEnd``";
  shared String templateParser = "(``partialTemplateParser``|``anyStartingTag``)";
  String variableParser = "/\\[[^\\]]+\\]|#{VariableSegment}+\\??/o";
} 

doc("The templates holder")
class Templates() {
	
	
	
}

doc("Templates object accessible to others")
shared object templates {
	Templates tmps = Templates();
	shared Template<Markup> getRootTemplate(String themeId) {
		 return nothing; 
	}
}