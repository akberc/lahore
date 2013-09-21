import com.dgwave.lahore.api {id, description, name, configure}

doc ("Allows administrators to customize the site navigation menu.")
license ("Apache Software License 2.0")
by ("Akber Choudhry")

id("menu")
name("Menu")
description("Allows administrators to customize the site navigation menu.")
configure("admin/structure/menu")
module com.dgwave.lahore.menu '0.1' {
    import ceylon.language '0.6';
    import ceylon.collection '0.6';
    shared import com.dgwave.lahore.api '0.1';
    shared import com.dgwave.lahore.help '0.1';
}