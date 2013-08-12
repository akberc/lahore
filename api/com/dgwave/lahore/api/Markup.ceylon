import com.dgwave.lahore.core.component { StringPrinter }
doc("This is not a comprehensive HTML parser.  
     It just establishes bare minimum good practices for program-generated HTML")
shared abstract class Markup({Entry<String, String>*}? attrs = {}) satisfies Fragment {
    
    shared actual default String element = "";
    shared default variable {Entry<String, String>*} attributes = {};
    
    if (exists attrs) {
    	attributes = attrs;
	}
    	
    shared actual default String string {
        StringPrinter p = StringPrinter();
        p.printMarkup(this);
        return p.string;
    }
    
    shared actual default String render() {
        StringPrinter p = StringPrinter(true);
        p.printMarkup(this);
        return p.string;       
    }
}

doc("Marker Interface for rendering container elements")
shared interface ContainerMarkup {
	shared formal {Markup*} containedFragments;
}

doc("Marker Interface for rendering contained elements")
shared interface ContainedMarkup {
	shared formal String containedContent;
}

shared class MarkupComment(String content) extends Markup() {

	shared actual String element = "<!-- -->";
	shared actual String string = "<!-- " + content + " -->";
	shared actual String render() { return string; }
}


shared class Head(PageTitle title, {Meta|Link|Script*} children) extends Markup() satisfies ContainerMarkup {
	shared actual String element = "head";
	shared actual {Markup*} containedFragments = {title, *children};
}

shared class PageTitle(String content) extends Markup() satisfies ContainedMarkup {
	 shared actual String element = "title";
	 shared actual String containedContent = content;
}

shared class Meta({Entry<String, String>*}? attrs) extends Markup(attrs) satisfies ContainedMarkup {	
	shared actual String element = "meta";
	shared actual String containedContent = "";  // so that element ends
	//shared actual {Entry<String, String>*} attributes = attrs;
}

shared class Link ({Entry<String, String>*}? attrs) extends Markup(attrs) satisfies ContainedMarkup {
	shared actual String element = "link";
	shared actual String containedContent = "";  // so that element ends
	//shared actual {Entry<String, String>*} attributes = attrs;
}

shared class Style(String content) extends Markup() satisfies ContainedMarkup {
	 shared actual String element = "style";
	 shared actual String containedContent = content;
}

shared class Script({Entry<String, String>*} | String content) extends Markup() satisfies ContainedMarkup {
	shared actual String element = "script";
	shared actual variable String containedContent = ""; // to end the script tag if not inline
	shared actual variable {Entry<String, String>*} attributes = {};
	switch (content)
	case (is String) {
		containedContent = content; // if it is inline JS
	}
	case (is {Entry<String, String>*}) {
		attributes = content;
	}	 
}

shared class Body({Heading | ContainerMarkup | P | Div+} children) extends Markup() satisfies ContainerMarkup { 
	shared actual String element = "body";
	shared actual {Markup*} containedFragments = { for (f in children) if (is Markup f) f};
}

shared class Div({Heading | ContainerMarkup | Div | Span *} children) extends Markup() satisfies ContainerMarkup { 
	shared actual String element = "div";

	shared actual {Markup*} containedFragments = { for (f in children) if (is Markup f) f};
	
}

shared class Table(Thead? thead, Tbody? tbody, Tfoot? tfoot, {Tr*} rows) extends Markup() satisfies ContainerMarkup {
	 shared actual String element = "table";
	 shared actual {Markup*} containedFragments = {
		for (f in {thead, tbody, tfoot, *rows}) if (exists f) f };
}

shared class Span(String content) extends Markup() satisfies ContainedMarkup {
	 shared actual String element = "span";
	 shared actual String containedContent = content;
}

shared class P(String content) extends Markup() satisfies ContainedMarkup { 
	shared actual String element = "p";
	shared actual String containedContent = content;
}

shared class Thead(Tr row) extends Markup() satisfies ContainerMarkup { 
	shared actual String element = "thead";
	shared actual {Markup*} containedFragments = {row};
}

shared class Tbody({Tr*} rows) extends Markup() satisfies ContainerMarkup { 
	shared actual String element = "tbody";
	shared actual {Markup*} containedFragments = rows;
}

shared class Tfoot(Tr row) extends Markup() satisfies ContainerMarkup { 
	shared actual String element = "tfoot";
	shared actual {Markup*} containedFragments = {row};
}

shared class Tr({Td*} | {Th*} cells) extends Markup() satisfies ContainerMarkup { 
	shared actual String element = "tr";
	shared actual {Markup*} containedFragments = cells;
}

shared class Td(String | {Markup*} content) extends Markup() satisfies ContainerMarkup & ContainedMarkup { // yes, TDs are special 
	shared actual String element = "td";
	shared actual variable String containedContent = ""; 
	shared actual variable {Markup*} containedFragments = {};
	switch (content)
	case (is String) {
		containedContent = content; 
	}
	case (is {Markup*}) {
		containedFragments = content;
	}
}

shared class Th(String content) extends Markup() satisfies ContainedMarkup { 
	shared actual String element = "th";
	shared actual String containedContent = content;
}

shared class Heading(String el, String content, {Entry<String, String>*}? attrs={}) extends Markup(attrs) satisfies ContainedMarkup {
	shared actual String element = el;
	shared actual String containedContent = content;
}

shared class H1(String content, {Entry<String, String>*}? attrs={}) extends Heading("h1", content, attrs) satisfies ContainedMarkup {}

shared Heading h1({Entry<String, String>*}? attrs, String content) {
	return H1 (content, attrs);
}

shared class H2(String content, {Entry<String, String>*}? attrs={}) extends Heading("h2", content, attrs) satisfies ContainedMarkup {}

shared Heading h2({Entry<String, String>*}? attrs, String content) {
	return H1 (content, attrs);
}

shared class H3(String content, {Entry<String, String>*}? attrs={}) extends Heading("h3", content, attrs) satisfies ContainedMarkup {}

shared Heading h3({Entry<String, String>*}? attrs, String content) {
	return H1 (content, attrs);
}

shared class Dl({Dt | Dd*} children) extends Markup() satisfies ContainerMarkup { 
	shared actual String element = "dl";
	shared actual {Markup*} containedFragments = children;
}

shared class Dt(String content) extends Markup() satisfies ContainedMarkup { 
	shared actual String element = "dt";
	shared actual String containedContent = content;	
}

shared class Dd(String content) extends Markup() satisfies ContainedMarkup {
	shared actual String element = "dd";
	shared actual String containedContent = content;	 
}

shared class Ol({Ol|Ul|Li*} children, {Entry<String, String>*}? attrs = {}) extends Markup(attrs) satisfies ContainerMarkup {
	shared actual String element = "ol";
	shared actual {Markup*} containedFragments = children;	
}
shared Ol ol({Entry<String, String>*}? attrs, {Ol|Ul|Li*} children) {
	return Ol(children, attrs);
}

shared class Ul({Ol|Ul|Li*} children) extends Markup() satisfies ContainerMarkup {
	shared actual String element = "ol";
	shared actual {Markup*} containedFragments = children;	
}

shared class Li(String content) extends Markup() satisfies ContainedMarkup {
	shared actual String element = "li";
	shared actual String containedContent = content;	
}

shared class Nav({Heading | Ol | Ul | Anchor*} children, {Entry<String, String>*}? attrs) extends Markup(attrs) satisfies ContainerMarkup {
	shared actual String element = "ol";
	//shared actual {Entry<String, String>*} attributes = attrs;
	shared actual variable {Markup*} containedFragments = children; 
}

shared Nav nav({Entry<String, String>*}? attrs, {Heading | Ol | Ul | Anchor*} children) {
	return Nav(children, attrs);
}

shared class Anchor(String content, {Entry<String, String>*}? attrs) extends Markup(attrs) satisfies ContainedMarkup {
	shared actual String element = "li";
	shared actual String containedContent = content;	
}
shared Anchor a(String href, String content, {Entry<String, String>*}? other={}) {
	return Anchor(content, {"href"->href, *other});
}

shared class Html (Head head, Body body) extends Markup() satisfies ContainerMarkup {
	
	shared actual String element = "html";
	shared actual {Markup*} containedFragments ={head,body};
}



