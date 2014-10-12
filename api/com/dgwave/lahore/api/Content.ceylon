import ceylon.json { JSONObject = Object, JSONArray = Array }

shared interface Layout {
    shared formal [Integer, Integer] viewPort;
    shared formal [Integer, Integer] grid;
    shared formal {Fragment *} containers;
    shared formal Boolean rtl;
    shared formal Boolean fluid;
    
    shared formal Boolean validate({Region *} blocks);
}

shared interface Binder {
    shared formal String extractClientScript();
    shared formal String extractClientStyle();
}

shared interface Renderer {

}

shared interface Styler {
    
}


shared abstract class ContentType() of 
    textCss | applicationJavascript | applicationJson | imagePng | imageJpg | imageIcon {}
shared object imageJpg extends ContentType() {
    shared actual String string => "image/jpg";
}

shared object imagePng extends ContentType() {
    shared actual String string => "image/png";
}

shared object imageIcon extends ContentType() {
    shared actual String string => "image/x-icon";
}

shared object applicationJavascript extends ContentType() {
    shared actual String string => "application/javascript";
}

shared object applicationJson extends ContentType() {
    shared actual String string => "application/json";
}

shared object textCss extends ContentType() {
    shared actual String string => "text/css";
}

shared abstract class Content() of 
    JsonObject | JsonArray | Paged {
    shared default Boolean cacheable => false;
}

shared abstract class JsonArray(JSONArray arr) extends Content() {
    
}

shared abstract class JsonObject(JSONObject obj) extends Content() {
    
}

shared class Attached(name, pathInModule, contentType) {
    shared default String name;
    shared default String pathInModule;
    shared default ContentType contentType; 
}

shared class Paged (region, top = {}, bottom = {}) extends Content() {
    shared default {PageTitle|Meta|Style|Script|Attached *} top;
    shared default Region region;
    shared default {Style|Script|Attached *} bottom;  
}

shared abstract class Fragment() {
    shared formal String element;
    shared formal String render();  
}