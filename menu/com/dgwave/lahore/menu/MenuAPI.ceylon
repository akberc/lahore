import com.dgwave.lahore.api { Contribution, Result }


shared interface MenuContribution satisfies Contribution{

    shared default Result menuInsert(Menu menu) {return null;}

    shared default Result menuUpdate(Menu menu) {return null;}

    shared default Result menuDelete(Menu menu) {return null;}
}

shared class Menu() {
    shared String id = nothing;
}