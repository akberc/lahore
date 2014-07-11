import com.dgwave.lahore.api { ... }
import ceylon.json { parse, JsonObject = Object }
import ceylon.logging { logger, Logger }

Logger log = logger(`package com.dgwave.lahore.core.component`);

class JsonConfig(String key, Assoc assoc) extends AssocConfig(assoc) {
    shared actual {Primitive+} uniqueKey => {key};
    
    shared actual Integer version => 0;
}

shared Config? parseJsonAsConfig(String key, String jsonString) {
    
    try {
        JsonObject? jsonObj {
            value parsed = parse(jsonString);
            if (is JsonObject parsed)  {
                return parsed;
            } else {
                return null;
            }
        }
        
        Assoc assoc = Assoc();
        if (exists it = jsonObj) {
	        for (an in it) {
	            if (is Assocable another = an.item) {
	                assoc.put(an.key, another);
	            }
	        }
	    } else {
	        return null;
	    }
	    
        return JsonConfig(key, assoc);
	    
    } catch (Exception e) {
        return null;
    } 
}