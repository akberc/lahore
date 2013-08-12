import com.dgwave.lahore.api { Config, Assoc, Array, assoc }
import com.redhat.ceylon.common.config { CeylonConfig }
import java.lang {JavaString = String,  ObjectArray }

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

shared class AssocConfig() extends AbstractConfig() {
	variable Assoc assoc = Assoc();

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