import com.dgwave.lahore.core.component { segments }
import ceylon.test { assertEquals }
by ("Akber Choudhry")
doc ("Run tests for static global methods for Lahore")

void testRegex(){

	assertEquals({"1122ii", "33"}, segments("1122iijj33", "jj"));

	assertEquals({"the " , " be"}, segments("the force be", "(.*)force(.*)"));

	assertEquals({"a", "b"}, segments("a|b", "/\\|/as"));

	String quotedString = "\"[^\"]*\"|'[^']*'";
  	String quotedFragment = "``quotedString``|(?:[^\\s,\\|'\"]|``quotedString``)+";
  	String tagAttributes = "/(\\w+)\\s*\\:\\s*(``quotedFragment``)/o";

	assertEquals({"abc", "\"something quoted\""}, segments("abc : \"something quoted\"", tagAttributes));
}