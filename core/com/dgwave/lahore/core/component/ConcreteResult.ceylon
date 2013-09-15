import ceylon.collection { LinkedList, HashMap }
import com.dgwave.lahore.api { Assoc, Array, Fragment}

deprecated("Make it a generic container for renderables and/or other kinds of hook outputs
            and remove assoc and/or pre-rendered Strings as an input")
shared class ConcreteResult({ Assoc | Fragment *} output) satisfies Fragment {

    shared actual String element = "result";
    
    variable shared HashMap<String, String> attached = HashMap<String, String>();
    variable shared LinkedList<String> markup = LinkedList<String>();
    variable shared LinkedList<String> fragments = LinkedList<String>();
    
    Boolean isMeta(Assoc topAssoc) {
        for (k->i in topAssoc) {
            if (k.startsWith("#")) {
                return false;
            }
        }
        return true;
    }

    void processAttached(Assoc? toProcess) {
        if (exists toProcess) {
            for (e->f in toProcess) {
                if (is Array f) {
                    for (g in f) {
                        if (is String g) {
                            attached.put(e, g);
                        }
                    }
                }
            }
        }		
    }

    doc("processing #xxxx -> something ")
    void processSimpleAssoc(Assoc simple) {
        for (e in simple.keys) {
            if (e == "#attached") {
                processAttached(simple.getAssoc("#attached"));
            } else if (e == "#markup") {
                if (exists s = simple.getString("#markup")) {
                    markup.add(s);				
                }
            }
        }
    }

	/**
	Main initializer
	*/	
    for (routeOutput in output) {
        if (is Assoc routeOutput) { 
            if (isMeta(routeOutput)) { // is it meta or simple?
                for (k->i in routeOutput) {
                    if (is Assoc i) {
                        processSimpleAssoc(i);
                    }                }            } else {
                processSimpleAssoc(routeOutput);
            }
        } 
        else if (is Fragment routeOutput) {
            markup.add(routeOutput.render());
        }
    }

    shared Boolean empty () {
        if (attached.empty && fragments.empty && markup.empty) {
            return true;
        } else {
            return false;
        }
    }

    shared actual default String render() {
        return
        "".join{for (mkp in markup) mkp};
    }		
}

