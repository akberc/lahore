import com.dgwave.lahore.api { AbstractConfig }
import com.redhat.ceylon.common.config { CeylonConfig }
import java.lang { ObjectArray, JavaString = String }

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