import com.dgwave.lahore.api { Contribution, Assoc }


shared interface MenuContribution satisfies Contribution{

    shared formal Assoc menuInsert(Menu menu);

    shared formal Assoc menuUpdate(Menu menu);

    shared formal Assoc menuDelete(Menu menu);
}

shared class Menu() {
    shared String id = nothing;
}