import ceylon.test { ... }


doc ("Run tests for static global methods for Lahore")

void testMethods(){
    variable Array arr = array();
    variable StringPrinter p = StringPrinter();
    p.printArray(arr);
    assertEquals("[]", p.string);
    arr = array("a", 1, "z", false, assoc("one" -> "test"));
    p = StringPrinter();
    p.printArray(arr);
    print(p.string);
    assertEquals("[\"a\",1,\"z\",false,{\"one\":\"test\"}]", p.string);
}