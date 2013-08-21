import org.yaml.snakeyaml.events { Event, MappingStartEvent, ScalarEvent, MappingEndEvent, StreamStartEvent, SequenceStartEvent, SequenceEndEvent }
import java.lang { JavaIterable = Iterable }
import java.io {StringReader}
import org.yaml.snakeyaml { Yaml }
import com.dgwave.lahore.api {Config, Assoc, Array, watchdog}

shared Config? parseYamlAsConfig(String yamlString) {
	Yaml yaml = Yaml();
	JavaIterable<Event> events= yaml.parse(StringReader(yamlString));
	value sb = SequenceBuilder<Event>(); // FIXME when https://github.com/ceylon/ceylon-compiler/issues/403
	try {
		while(events.iterator().hasNext()) {
			sb.append(events.iterator().next());
		}
	} catch (Exception e) {
		watchdog(3, "Yaml", "Invalid Yaml: " + e.message);
		return null;
	}
	
	variable Assoc? config = null;
	variable Assoc? currentAssoc = null;
	variable Assoc? lastAssoc = null;
	variable Array? currentArray = null;
	variable Array? lastArray = null;
	variable String? name = null;
	variable String? val = null;
	variable Boolean first = true;
	variable Event lastEvent = StreamStartEvent(null, null);
	variable Boolean inArray = false;
	
	for (e in sb.sequence) {
		switch(e)
		case (is SequenceStartEvent) {
			if (is ScalarEvent last = lastEvent) {
				lastArray = currentArray; // save parent
				currentArray = Array(); // opening a new mapping with last key
				if (exists cf = config) {
					if (exists ca = currentArray) {
						cf.put(last.\ivalue, ca);
						inArray = true;
					}
				}
			}
			name = null; val = null; //wipe out pairing
			first = true;	
		}
		case (is MappingStartEvent) {
			if (is ScalarEvent last = lastEvent) {
				lastAssoc = currentAssoc; // save parent
				currentAssoc = Assoc(); // opening a new mapping with last key
				if (exists cf = config) {
					if (exists ca = currentAssoc) {
						cf.put(last.\ivalue, ca);
					}
				}
			}
			else {
				config = Assoc(); // top level mapping
				currentAssoc = config;
			}
			name = null; val = null; //wipe out pairing
			first = true;	
		} 
		case (is ScalarEvent) {
			if (first) {
				if (inArray) {
					if (exists ca = currentArray) {
						ca.add(e.\ivalue);
					}
				} else {
					name = e.\ivalue;
					first = false; // prep for value
				}
			} else {
				val = e.\ivalue;
				first = true; // prep for next pairing
			}
			// if we have both
			if (exists n = name) {
				if (exists v =val) {
					if (exists c = currentAssoc) {
						c.put(n,v);
					}	
					name = null;
					val = null;
				}
			}
		}
		case (is MappingEndEvent) {
			if (exists l = lastAssoc) {
				currentAssoc = l;
			}
		}
		case (is SequenceEndEvent) {
			if (exists l = lastArray) {
				currentArray = l;
			}
			inArray = false;
		} 				
		else {
			watchdog(7, "Yaml", "Unknown YAML parsing event: ``e.string``");
		}
		lastEvent = e; // saving last event
	}
	if (exists c = config) {
		AssocConfig yconfig = AssocConfig();
		yconfig.load(c);
		return yconfig;
	} else {
		return AssocConfig();
	}
}


