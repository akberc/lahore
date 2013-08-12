import org.yaml.snakeyaml.events { Event, MappingStartEvent, ScalarEvent, MappingEndEvent, StreamStartEvent }
import java.lang { JavaIterable = Iterable }
import java.io {StringReader}
import javax.xml.parsers { DocumentBuilder , DocumentBuilderFactory {newInstance}}
import org.w3c.dom {JaxpDoc = Document, Element, Node}
import org.yaml.snakeyaml { Yaml }
import com.dgwave.lahore.api { Storable, Assoc }

shared interface Document satisfies Storable{

	shared formal void marshal();
	shared formal void unmarshal();
}

DocumentBuilder builder =newInstance().newDocumentBuilder();

shared YamlDocument yamlDocument(String yamlString) {

	return YamlDocument(yamlString);
}

shared class YamlDocument(String yamlString) satisfies Document {
	
	JaxpDoc innerDoc = builder.newDocument();
	
	Yaml yaml = Yaml();
	JavaIterable<Event> events= yaml.parse(StringReader(yamlString));
	value sb = SequenceBuilder<Event>(); // FIXME when https://github.com/ceylon/ceylon-compiler/issues/403
	while(events.iterator().hasNext()) {
		sb.append(events.iterator().next());
	}

	innerDoc.appendChild(innerDoc.createElement("yaml"));
	variable Boolean mapping = false;
	variable Node parent = innerDoc.documentElement; // yaml
	variable Node? child = null;
	for (e in sb.sequence) {
		switch(e)
		case (is MappingStartEvent) {
			mapping = true;
			if (exists c = child) {
				parent = c;
				child = null;
			}
		} 
		case (is ScalarEvent) {
			if (mapping) {
				if (exists t = child) {
					t.appendChild(innerDoc.createTextNode(e.\ivalue));
				} else {
					child = innerDoc.createElement(e.\ivalue);
				}
			}
		}
		case (is MappingEndEvent) {
			parent.appendChild(child);
			child = parent; // parent is now the active element
			parent = parent.parentNode;
			
			mapping = false;
		} 		
		else {
			print("Unknown event: ``e.string``");
		}
	}

	shared actual void load(Assoc assoc) {} /* TODO auto-generated stub */
	
	shared actual void marshal() {} /* TODO auto-generated stub */
	
	shared actual Assoc save() => nothing; /* TODO auto-generated stub */
	
	shared actual void unmarshal() {} /* TODO auto-generated stub */
	


	
}