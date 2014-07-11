import com.dgwave.lahore.api { ... }

doc ("Allows administrators to customize the site navigation menu.")
license ("Apache Software License 2.0 - (c) 2013-2014 Digiwave Systems Ltd.")
by ("Akber Choudhry")

plugin(themes)
name("System Theme")
description("Handles general site configuration for administrators.")
module com.dgwave.lahore.system_theme "0.2" {
    import ceylon.collection "1.1.0";
    import ceylon.logging "1.1.0";
    
    shared import com.dgwave.lahore.api "0.2";
    import com.dgwave.lahore.menu "0.2";
    import com.dgwave.lahore.help "0.2";
}