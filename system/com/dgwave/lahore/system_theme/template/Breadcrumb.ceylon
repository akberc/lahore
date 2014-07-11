import com.dgwave.lahore.api { ... }

shared class BreadcrumbTemplate() extends HtmlTemplate() {

    shared actual {Markup*} apply({Entry<String, Markup>*} breadcrumb) {
        return {
/*            Nav{ classes=["breadcrumb"]; attrs= {"role"->"navigation"};
            H2{ classes=["visually-hidden"]; content= t("You are here"); },
            Ol( {
                for (key->item in breadcrumb) Li(item.string)
            }
            )
        }*/
    };
}

shared actual Map<String, Markup> fragments = nothing; /* TODO auto-generated stub */

}