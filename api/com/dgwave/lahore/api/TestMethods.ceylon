import ceylon.test { ... }

"Run tests for static global methods for Lahore"
test void testMethods(){
    variable ArrayL arr = array();
    variable StringPrinter p = StringPrinter();
    p.printArray(arr);
    assertEquals("[]", p.string);
    arr = array("a", 1, "z", false, assoc("one" -> "test"));
    p = StringPrinter();
    p.printArray(arr);
    // print(p.string);
    assertEquals("[\"a\",1,\"z\",false,{\"one\":\"test\"}]", p.string);
}