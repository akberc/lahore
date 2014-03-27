"Identical to Div, but abstract. Used for HTML5 and other custom elements"
shared abstract class Region({Heading | ContainerMarkup | Region | Span | Input | Anchor | P *} children, 
	String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) extends Markup(id, classes, attrs) satisfies ContainerMarkup {
	
	shared actual {Markup*} containedFragments = { for (f in children) if (is Markup f) f};
	shared formal [Integer, Integer] gridSpan;	
}

"Only implementation of region that is not provided by theme"
shared class Div({Heading | ContainerMarkup | Region | Span | Input | Anchor | P *} children, 
	String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) extends Region(children, id, classes, attrs) {
	shared actual [Integer, Integer] gridSpan = [0,0];	
	shared actual String element = "div";
}

shared abstract class Nav({Heading | Ol | Ul | Anchor*} children, String? id = null, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
		extends Region(children, id, classes, attrs) {
	shared actual String element = "nav"; 
}

shared  abstract class Header({Heading | P | Span *} contained, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
		extends Region(contained, "header", classes, attrs) {
	shared actual String element = "header";
}

shared  abstract class Aside(String qualifier, Div contained, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
		extends Region({contained}, "aside" + qualifier, classes, attrs) {
	shared actual String element = "aside";
}

shared  abstract class Main(Div contained, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
		extends Region({contained}, "content", classes, attrs) {
	shared actual String element = "main";
}

shared  abstract class Footer({ P | Span *} contained, String[] classes = empty, {Entry<String, String>*} attrs = {}) 
		extends Region(contained, "footer", classes, attrs) {
	shared actual String element = "footer";
}