by ("Akber Choudhry")
doc ("Lahore port to Ceylon.")
license ("Apache 2.0 License - Copyright 2013 Digiwave Systems Ltd. (http://www.dgwave.com/)")

module com.dgwave.lahore.core '0.1' {
    //  nothing shared out of this module except API
    import ceylon.net '0.6';
    import ceylon.io '0.6';
    import ceylon.file '0.6';
    import ceylon.collection '0.6';
    import ceylon.json '0.6';
    
    import java.base '7';
    
    import com.redhat.ceylon.common '0.6';
    import com.redhat.ceylon.typechecker '0.6';
	import 'com.redhat.ceylon.module-resolver' '0.6';
    import org.jboss.modules 'main';
    
    shared import com.dgwave.lahore.api '0.1'; //only one shared
    
    import ceylon.test '0.6';
}