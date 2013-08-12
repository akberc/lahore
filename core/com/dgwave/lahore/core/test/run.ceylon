import ceylon.test { ... }
 
by ("Akber Choudhry")
doc ("Run Lahore core tests")

shared void run(){
    suite("lahore.core",
        //"Methods" -> testMethods,
       // "Dispatcher" -> testDispatcher,
        "Plugins" -> testPlugins
       // "Yaml" -> testYaml,
		//"Html" -> testHtml,
		//"Template" -> testTemplate,
		//"Regex" -> testRegex
    );
}