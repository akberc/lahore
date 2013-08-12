import com.dgwave.lahore.api { Fragment, Markup, MarkupComment }

shared interface Template<Element> given Element satisfies Fragment {
	shared formal {Entry<String, Element>*} fragments; // injectable TODO
	shared formal {Element*} apply ({Entry<String, Element>*} fragments) ;
}

doc("Ceylon coded template")
shared abstract class HtmlTemplate() satisfies Template<Markup> {
	shared actual default {Entry<String, Markup>*} fragments = {}; 
	shared actual default {Markup*} apply ({Entry<String, Markup>*} fragments) {
			return {MarkupComment("Default Output - template not rendered")};
	}
}

shared interface TemplateHook satisfies Hook {
	shared formal String[] preProcessBlock(String[] variables);
}


