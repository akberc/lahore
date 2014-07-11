"This is not a comprehensive HTML reference or producer.  
  It just establishes bare minimum good practices for program-generated HTML"
shared abstract class Markup(id = null, classes = [], attrs = {}) extends Fragment() {

    shared default {Entry<String, String>*} attrs;

    shared default variable String? id ;
    shared default variable String[] classes ;

    shared actual default String element = "";

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

shared interface Action {
    shared formal String invoke;
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

shared class Meta({Entry<String, String>*} attrs) extends Markup(null, [], attrs) satisfies ContainedMarkup {	
    shared actual String element = "meta";
    shared actual String containedContent = "";  // so that element ends
    //shared actual {Entry<String, String>*} attributes = attrs;
}

shared class Link ({Entry<String, String>*} attrs) extends Markup(null, [], attrs) satisfies ContainedMarkup {
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
    shared actual variable String containedContent = " "; // to end the script tag if not inline
    shared actual variable {Entry<String, String>*} attrs = {};
    switch (content)
    case (is String) {
        containedContent = content; // if it is inline JS
    }
    case (is {Entry<String, String>*}) {
        attrs = content;
    }	 
}

shared class Body({Script | Heading | ContainerMarkup | P | Div+} children) extends Markup() satisfies ContainerMarkup { 
    shared actual String element = "body";
    shared actual {Markup*} containedFragments = { for (f in children) if (is Markup f) f};
}

shared class Table({Tr*} rows, Thead? thead = null, Tbody? tbody = null, Tfoot? tfoot = null, 
String? id = null, String[] classes = empty, {Entry<String, String>*} attrs={}) 
        extends Markup(id, classes, attrs) satisfies ContainerMarkup {

    shared actual String element = "table";
    shared actual {Markup*} containedFragments = {
        for (f in {thead, tbody, tfoot, *rows}) if (exists f) f };
    }

    shared class Span(String content, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs={}) 
            extends Markup(id, classes, attrs) satisfies ContainedMarkup {
        shared actual default String element = "span";
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

    shared Thead thead(String* heads) {
        return Thead (
        Tr ( {
            for (head in heads) Th(head)
        })    
        );
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

    shared abstract class Heading(String el, String content, String? id, String[] classes, {Entry<String, String>*} attrs={}) 
            extends Markup(id, classes, attrs) satisfies ContainedMarkup {
        shared actual String element = el;
        shared actual String containedContent = content;
    }

    shared class H1(String content, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs={}) 
            extends Heading("h1", content, id, classes, attrs) satisfies ContainedMarkup {}

    shared class H2(String content, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs={}) 
            extends Heading("h2", content, id, classes, attrs) satisfies ContainedMarkup {}

    shared class H3(String content, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs={}) 
            extends Heading("h3", content, id, classes, attrs) satisfies ContainedMarkup {}

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

    shared class Ol({Ol|Ul|Li*} children, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
            extends Markup(id, classes, attrs) satisfies ContainerMarkup {
        shared actual String element = "ol";
        shared actual {Markup*} containedFragments = children;	
    }

    shared class Ul({Ol|Ul|Li*} children, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
            extends Markup(id, classes, attrs) satisfies ContainerMarkup {
        shared actual String element = "ul";
        shared actual {Markup*} containedFragments = children;	
    }

    shared class Li(String | Anchor content, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
            extends Markup(id, classes, attrs) satisfies ContainedMarkup {
        shared actual String element = "li";
        shared actual String containedContent = content.string;	
    }

    shared class Anchor(String content, String? id, String[] classes, {Entry<String, String>*} attrs) 
            extends Markup(id, classes, attrs) satisfies ContainedMarkup {
        shared actual String element = "a";
        shared actual String containedContent = content;	
    }

    shared class Button(String content, invoke = "", String name="", String type="submit", Boolean enabled = true, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
            extends Input(name, "button", content, enabled, id, classes, attrs) 
            satisfies ContainedMarkup & Action {
        shared actual String element = "button";
        shared actual String invoke;
    }

    shared Button button(String content, Boolean enabled = true, String? id = null, String* classes) {
        return Button ("", content, "", "", enabled, id, classes.sequence(), {} );
    }

    shared Anchor a(String href, String content, {Entry<String, String>*} other={}, String? id = null, String[] classes = empty) {
        return Anchor(content, id, classes, {"href"->href, *other});
    }

    shared class Html (Head head, Body body, {Entry<String, String>*} attrs) 
            extends Markup(null, [], attrs) satisfies ContainerMarkup {
        
        shared actual String element = "html";
        shared actual {Markup*} containedFragments ={head,body};
        shared actual String string {
            return "<!DOCTYPE html>\n" + super.string;
        }
        shared actual String render() {
            return "<!DOCTYPE html>\n" + super.render();
        }	
    }

    shared class Form({Div | Label | Input *} children, String method, String action, 
    String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {} ) 
            extends Markup(id, classes, attrs) satisfies ContainerMarkup {

        shared actual String element = "form";
        shared actual {Markup*} containedFragments = children;
    }

    shared class Label (String content, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs={}) 
            extends Span(content, id, classes, attrs) satisfies ContainedMarkup { 
        shared actual String element = "label";
        
    }

    shared abstract class Input (String name, String type, String content, Boolean enabled = true, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
            extends Markup(id, classes, attrs.chain(
                (!enabled) then {"disabled"->"disabled"} else {})
                .chain({"name"->name, "type"->type
            })) satisfies ContainedMarkup {
    shared actual default String element = "input";
    shared actual String containedContent = content;
    
}

shared class Text(String name, String content, String placeHolder = "", Integer size=0, Integer max=0, 
Boolean enabled = true,  String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
        extends Input (name, "text", content, enabled, id, classes, {"size"->size.string,
"maxLength"->max.string,
"placeHolder"->placeHolder
}.chain(attrs)) {}
