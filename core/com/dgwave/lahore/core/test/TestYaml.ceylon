import com.dgwave.lahore.core { ... }
import ceylon.test { ... }
import com.dgwave.lahore.core.component { parseYamlAsConfig }
import com.dgwave.lahore.api { Config }

by ("Akber Choudhry")
doc ("Test parsing of YAML files")

void testYaml() {
		String input = "name: Site\nmail: ''\nslogan: ''\npage:\n  403: ''\n  404: ''\n  front: user\nadmin_compact_mode: '0'\nweight_select_max: '100'\nlangcode: en\n";
	 	Config? c = parseYamlAsConfig(input);
	 	if (exists c) {
		 	String output = c.string;
		 	print(output);
		 	assertEquals(input, output);
	 	} else {
	 		fail("Yaml could not be parsed");
	 	}
	 }