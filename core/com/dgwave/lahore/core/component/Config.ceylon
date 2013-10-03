import com.dgwave.lahore.api { ... }
import ceylon.json { parse, JsonObject = Object }

shared class AssocConfig(assoc = Assoc()) extends AbstractConfig() {
    variable Assoc assoc;
    
    shared actual String[] stringsWithDefault(String key, String[] defValues) {
        if (exists a = assoc.getArray(key)) {
            return filterStrings(a);
        } else {
            return [];
        }
    }
    
    String[] filterStrings(Array a) { 
        value sb = SequenceBuilder<String>(); 
        for (ae in a) {
            if (is String ae) {
                sb.append(ae);
            }
        }
        return sb.sequence;
    }	
}

shared Config? parseJsonAsConfig(String jsonString) {
    
    try {
        JsonObject jsonObj = parse(jsonString);
        Assoc assoc = Assoc();
        for (an in jsonObj) {
            if (is Assocable another = an.item) {
                assoc.put(an.key, another);
            }
        }
        return AssocConfig(assoc);
    } catch (Exception e) {
        return null;
    } 
}