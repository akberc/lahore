import com.dgwave.lahore.api { Hook, Result, hook }


shared interface MenuHook satisfies Hook{
	
	hook("menu_insert")
	shared default Result menuInsert(Menu menu) {return null;}
	
	hook("menu_update")
	shared default Result menuUpdate(Menu menu) {return null;}
	
	hook("menu_delete")
	shared default Result menuDelete(Menu menu) {return null;}
}

shared class Menu() {
	shared String id = nothing;
}