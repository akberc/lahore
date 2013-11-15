doc("These are logical visible fragments of a page that are rendered to markup by at template.
     A route handler would look up an entity, break it down to templated content and then the renderer kicks in.")

shared interface Region{}

shared interface Layout {
    shared formal [Integer,Integer] viewPort;
    shared formal [Integer,Integer] grid;
    shared formal {Fragment *} containers;
    shared formal Boolean rtl;
    shared formal Boolean fluid;
    
    shared formal Boolean validate({Region *} blocks);
}

shared interface Renderer {

}

shared interface Binder {
    
}

shared interface Fragment {
    shared formal String element;
    shared formal String render();
}

shared abstract class Templated(String name) satisfies Fragment {
    "This is the name against which the template would be looked up. "
    shared actual default String element = name;

}
