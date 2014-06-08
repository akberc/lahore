import com.dgwave.lahore.api { id, description, name }

doc ("Manages the display of online help.")
license ("Apache Software License 2.0 - Copyright 2013-2014 Digiwave Systems Ltd.")
by ("Akber Choudhry")

id("help")
name("Help")
description("Manages the display of online help.")
module com.dgwave.lahore.help "0.2" {
    import ceylon.collection "1.1.0";
    shared import com.dgwave.lahore.api "0.2";
    shared import com.dgwave.lahore.menu "0.2";
}
