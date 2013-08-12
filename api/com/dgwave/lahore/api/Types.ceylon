import ceylon.collection { ... }
import com.dgwave.lahore.core.component { StringPrinter }

shared alias Assocable => String|Boolean|Integer|Float|Assoc|Array;

by("Akber Choudhry")
shared class Assoc({Entry<String, Assocable>*} values = {}) 
    satisfies MutableMap<String, Assocable> {
    
    value contents = HashMap<String, Assocable>(values);
    
    "Returns a serialised JSON representation"
    shared actual String string {
        StringPrinter p = StringPrinter();
        p.printAssoc(this);
        return p.string;
    }

    "Returns a pretty-printed serialised JSON representation"
    shared String pretty {
        StringPrinter p = StringPrinter(true);
        p.printAssoc(this);
        return p.string;
    }
    
    shared actual void clear() {
        contents.clear();
    }
    
    shared actual Assoc clone {
        return Assoc(contents.clone);
    }
    
    shared actual Null|Assocable get(Object key) {
        return contents[key];
    }
    
    shared actual Iterator<Entry<String, Assocable>> iterator() {
        return contents.iterator();
    }
    
    shared actual Null|Assocable put(String key, Assocable item) {
		return contents.put(key, item);
    }
    
    
    shared actual void putAll({Entry<String, Assocable>*} entries) {
        contents.putAll(entries);
    }
    
    shared actual Null|Assocable remove(String key) {
        return contents.remove(key);
    }
    
    shared actual Integer size {
        return contents.size;
    }
    
    shared actual Integer hash {
        return contents.hash;
    }
    
    shared actual Boolean equals(Object that) {
        if(is Assoc that){
            return this === that || contents == that.contents;
        }
        return false;
    }
        
    shared Integer? getInteger(String key){
        value val = get(key);
        if(is Integer val){
            return val;
        } else {
            return null;
        }

    }

    shared Float? getFloat(String key){
        value val = get(key);
        if(is Float val){
            return val;
        } else {
            return null;
        }
    }

    shared Boolean? getBoolean(String key){
        value val = get(key);
        if(is Boolean val){
            return val;
        } else {
            return null;
        }
    }

    shared String? getString(String key){
        value val = get(key);
        if(is String val){
            return val;
        } else {
            return null;
        }
    }

    shared Assoc? getAssoc(String key){
        value val = get(key);
        if(is Assoc val){
            return val;
        } else {
            return null;
        }
    }
    
    shared Array? getArray(String key){
        value val = get(key);
        if(is Array val){
            return val;
        } else {
            return null;
        }
    }
    
}

shared class Array({Assocable*} values = {}) 
    satisfies MutableList<Assocable> {
    
    value list = LinkedList<Assocable>(values);
    
    shared actual Iterator<Assocable> iterator() => list.iterator();

    
    shared actual void add(Assocable val){
       	list.add(val);
    }
    
    shared actual Assocable|Null get(Integer index){
        return list[index];
    }
    
    shared actual Integer size {
        return list.size;
    }

    shared actual String string {
        StringPrinter p = StringPrinter();
        p.printArray(this);
        return p.string;
    }

    shared String pretty {
        StringPrinter p = StringPrinter(true);
        p.printArray(this);
        return p.string;
    }

    shared actual Array clone {
        return Array(list);
    }

    shared actual Integer? lastIndex {
        return list.lastIndex;
    }
    
    shared actual Array reversed {
        return Array(list.reversed);
    }
    
    shared actual Array rest {
        return Array(list.rest);
    }
    
    shared actual Array segment(Integer from, Integer length) {
        return Array(list.segment(from, length));
    }
    
    shared actual Array span(Integer from, Integer to) {
        return Array(list.span(from, to));
    }
    
    shared actual Array spanFrom(Integer from) {
        return Array(list.spanFrom(from));
    }
    
    shared actual Array spanTo(Integer to) {
        return Array(list.spanTo(to));
    }
    
    shared actual void addAll({Assocable*} values) {
        list.addAll(values);
    }
    
    shared actual void clear() {
        list.clear();
    }
    
    shared actual void insert(Integer index, Assocable val) {
        list.insert(index, val);
    }
    
    shared actual void remove(Integer index) {
        list.remove(index);
    }

    shared actual void removeElement(Assocable val) {
        list.removeElement(val);
    }
    
    shared actual void set(Integer index, Assocable val) {
        list.set(index, val);
    }
    
    shared actual Integer hash {
        return list.hash;
    }
    
    shared actual Boolean equals(Object that) {
        if(is Array that){
            return that === this || list == that.list;
        }
        return false;
    }
}

