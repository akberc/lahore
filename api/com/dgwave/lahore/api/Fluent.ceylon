import ceylon.math.float { ceiling }

shared Array array (Assocable* vars) {

    return Array{for (v in vars) v};
}

shared Assoc assoc (Entry<String, Assocable>* vars) {
    return Assoc{for (v in vars) v};
}

shared Result result (Assoc | {Fragment+} | {Entity+} routeOutput) {
    return  routeOutput;
}

shared String t(String text, {Entry<String,String>*} pairs = {}) {
    //TODO translation
    variable String temp = text;
    for (pair in pairs) {
        temp = temp.replace(pair.key, pair.item);
    }
    return temp;
}

shared String l(String to, String link) {
    return "<a href=\"/" + link +"\">" + to +"</a>";
}

shared String url(String link) {
    return "/" + link;
}

shared Integer count(List<Object>|Object* list) {
    return list.size;
}

shared Float|Integer ceil(Float num) {
    return ceiling(num);
}