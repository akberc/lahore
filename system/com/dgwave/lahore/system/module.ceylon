import com.dgwave.lahore.api { id, description, name }
doc ("Allows administrators to customize the site navigation menu.")
license ("Apache Software License 2.0 (c) Digiwave Systems 2013")
by ("Akber Choudhry")

id("system")
name("System")
description("Handles general site configuration for administrators.")

module com.dgwave.lahore.system '0.1' {
    import ceylon.language '0.6';
    import ceylon.collection '0.6';
    shared import com.dgwave.lahore.api '0.1'; 
}