by ("Akber Choudhry")
doc ("Lahore port to Ceylon.")
license ("Apache 2.0 License - Copyright 2013 Digiwave Systems Ltd. (http://www.dgwave.com/)")

module com.dgwave.lahore.server.single "0.1" {

    import ceylon.net '0.6.1';
    import ceylon.io '0.6.1';
    import ceylon.collection "0.6.1";

    import java.base '7';
    
    import com.redhat.ceylon.common '0.6.1';
    import com.redhat.ceylon.typechecker '0.6.1';
    import 'com.redhat.ceylon.module-resolver' '0.6.1';
    import org.jboss.modules 'main';
    
    shared import com.dgwave.lahore.api '0.1';
    import com.dgwave.lahore.core "0.1";
    import com.dgwave.lahore.server.console '0.1';
    
    import ceylon.test '0.6.1'; // test branch
}
