doc("These are logical visible fragments of a page that are rendered to markup by at template.
     A route handler would look up an entity, break it down to templated content and then the renderer kicks in.")
shared abstract class Templated(String name) satisfies Fragment {
    "This is the name against which the template would be looked up. "
    shared actual default String element = name;

}