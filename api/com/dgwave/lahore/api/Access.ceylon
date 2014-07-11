shared interface Principal {
    shared formal String distinguishedName;
}

shared abstract class Human() satisfies Principal{
    
   
}

shared abstract class Machine() satisfies Principal {
    
}

shared alias Team => Collection<Human>;
shared alias System => Collection<Machine>;