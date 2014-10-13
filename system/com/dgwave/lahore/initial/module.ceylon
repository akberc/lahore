import com.dgwave.lahore.api { ... }
doc ("Lahore Initial Page (site)")
license ("Apache Software License 2.0 - (c) 2013-2014 Digiwave Systems Ltd.")
by ("Akber Choudhry")

plugin(sites)
name("Initial")
description("Lahore Initial Page (site)")
site("localhost", 8080, "/")
module com.dgwave.lahore.initial "0.2" {
    shared import com.dgwave.lahore.api "0.2";
    import com.dgwave.lahore.system_theme "0.2";

    "Plugins used by site"
    import com.dgwave.lahore.menu "0.2";
}
