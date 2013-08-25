import com.dgwave.lahore.api { Config, Assoc, Array, assoc, Assocable }
import com.redhat.ceylon.common.config { CeylonConfig }
import java.lang {JavaString = String,  ObjectArray }
import ceylon.json { parse, JsonObject = Object }

shared abstract class AbstractConfig() satisfies Config {
	shared actual default void load(Assoc assoc) {} 
	
	shared actual default Assoc save() {
		return assoc();
	}
	
	shared actual default String stringWithDefault(String key, String defValue) {
		if (exists s = stringsWithDefault(key, [defValue]).first) {
			return s;
		} else {
			return defValue;
		}
	}
	
	shared actual default String? stringOnly(String key) {
		if (exists s = stringsWithDefault(key, []).first) {
			return s;
		} else {
			return null;
		}
	}					
}

shared class SystemConfig() extends AbstractConfig() {

	CeylonConfig config = CeylonConfig();
	
	shared actual String[] stringsWithDefault(String key, String[] defValues) {
		ObjectArray<JavaString>? vs = config.getOptionValues(key);
		if (exists vs) {
			value sb = SequenceBuilder<String>();
			variable Integer i = 0;
			while (i < vs.size){
				sb.append(vs.get(i).string);
				i++;
			}
			return sb.sequence;
		} else {
			value oa = ObjectArray<JavaString>(defValues.size);
			variable Integer i = 0;
			for (dv in defValues) {
				oa.set(i, JavaString(dv));
				i++;
			}
			config.setOptionValues(key, oa);
			return defValues;
		}
	}	
}

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