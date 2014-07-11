import com.dgwave.lahore.api {plugin, routes, description, name}

doc ("Allows administrators to customize the site navigation menu.")
license ("Apache Software License 2.0 - Copyright 2013-2014 Digiwave Systems Ltd.")
by ("Akber Choudhry")

plugin(routes)
name("Menu")
description("Allows administrators to customize the site navigation menu.")
module com.dgwave.lahore.menu "0.2" {
    import ceylon.collection "1.1.0";
    shared import com.dgwave.lahore.api "0.2";
    shared import com.dgwave.lahore.help "0.2";
}