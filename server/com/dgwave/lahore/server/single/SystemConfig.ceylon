import com.dgwave.lahore.api { Config, Primitive }
import com.redhat.ceylon.common.config { CeylonConfig }
import java.lang { ObjectArray, JavaString = String }
import ceylon.collection { ArrayList }

shared class SystemConfig() extends Config() {
    shared actual {Primitive+} uniqueKey => {"ceylon"};
    
    shared actual Integer version => 0;
    
    CeylonConfig config = CeylonConfig().get();
    
    shared actual String[] stringsWithDefault(String key, String[] defValues) {
        ObjectArray<JavaString>? vs = config.getOptionValues(key);
        if (exists vs) {
            value sb = ArrayList<String>();
            variable Integer i = 0;
            while (i < vs.size){
                sb.add(vs.get(i).string);
                i++;
            }
            return sb.sequence();
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