shared ArrayL array(Assocable* vars) {
    
    return ArrayL { for (v in vars) v };
}

shared Assoc assoc(Entry<String,Assocable>* vars) {
    return Assoc { for (v in vars) v };
}

shared String t(String text, {Entry<String,String>*} pairs = {}) {
    //TODO translation
    variable String temp = text;
    for (pair in pairs) {
        temp = temp.replace(pair.key, pair.item);
    }
    return temp;
}
