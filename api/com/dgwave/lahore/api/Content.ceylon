"""These are logical visible fragments of a page that are rendered to markup by at template.
   A route handler would look up an entity, break it down to templated content and then the renderer kicks in.
   """
shared interface Layout {
    shared formal [Integer, Integer] viewPort;
    shared formal [Integer, Integer] grid;
    shared formal {Fragment *} containers;
    shared formal Boolean rtl;
    shared formal Boolean fluid;
    
    shared formal Boolean validate({Region *} blocks);
}

shared interface Renderer {
    shared formal TaggedMarkup render({Result*} output);
}

shared interface Binder {
    shared formal String extractClientScript();
    shared formal String extractClientStyle();
}

shared interface Fragment {
    shared formal String element;
    shared formal String render();
}

