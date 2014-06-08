import com.dgwave.lahore.api { id, description, name, site }
doc ("Allows administrators to customize the site navigation menu.")
license ("Apache Software License 2.0 - (c) 2013-2014 Digiwave Systems Ltd.")
by ("Akber Choudhry")

id("system")
name("System")
description("Handles general site configuration for administrators.")
site("localhost", 8080, "/admin")
module com.dgwave.lahore.system "0.2" {
    import ceylon.collection "1.1.0";
    import ceylon.logging "1.1.0";
    
    shared import com.dgwave.lahore.api "0.2";
    import com.dgwave.lahore.menu "0.2";
    import com.dgwave.lahore.help "0.2";
}