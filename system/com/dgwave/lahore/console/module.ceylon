import com.dgwave.lahore.api { ... }
doc ("Lahore System Adminstration Console (site)")
license ("Apache Software License 2.0 - (c) 2013-2014 Digiwave Systems Ltd.")
by ("Akber Choudhry")

plugin(sites)
name("Console")
description("Lahore Admin console (site)")
site("localhost", 8080, "/admin")
module com.dgwave.lahore.console "0.2" {
    shared import com.dgwave.lahore.api "0.2";
    import com.dgwave.lahore.system_theme "0.2";
    
    "Plugins used by site"
    import com.dgwave.lahore.help "0.2";
    import com.dgwave.lahore.menu "0.2";
}
