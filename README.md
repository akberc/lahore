Lahore Web Framework
--------------------

Multi-site and Plugin-enabled Web Framework in Ceylon

Combining concepts from Play, Drupal, Ruby Liquid and best practices

Writen in the intuitive, type-safe and productive Ceylon programming language.

### Pre-Alpha software. If you still want to experiment, here are the steps to build and run:
* Install and/or build the [Ceylon distribution](http://github.com/ceylon/ceylon-dist)
 * Make sure the `ceylon` executable is in your PATH
 * Copy the *contents* of the `repo` folder in the Ceylon distribution to ~/.ceylon/repo (where ~ is the user's home directory)
* Depending on repository configuration, this might not be needed. However, it is still the best option to download these three jars:
 * http://repo1.maven.org/maven2/org/jruby/joni/joni/2.0.0/joni-2.0.0.jar
 * http://repo1.maven.org/maven2/org/jruby/jcodings/jcodings/1.0.10/jcodings-1.0.10.jar
 * http://repo1.maven.org/maven2/org/yaml/snakeyaml/1.11/snakeyaml-1.11.jar

* Install these downloaded jars into the local Ceylon repository:
 * `ceylon import-jar --out ~/.ceylon/repo org.jruby.joni/2.0.0 joni-2.0.0.jar` 
 * `ceylon import-jar --out ~/.ceylon/repo org.yaml.snakeyaml/1.11 snakeyaml-1.11.jar`
 * `ceylon import-jar --out ~/.ceylon/repo org.jruby.jcodings/1.0.10 jcodings-1.0.10.jar`

* Choose a clean directory, clone the Lahore repository and build with `ant clean publish`

* Choose optional plugins to pre-load:
 * `ceylon config --user set lahore.plugins.preload com.dgwave.lahore.system/0.1` 
 * `ceylon config --user set lahore.plugins.preload com.dgwave.lahore.help/0.1` 
 * `ceylon config --user set lahore.plugins.preload com.dgwave.lahore.menu/0.1` 

* Run with `ceylon run com.dgwave.lahore.core/0.1`

* For more information, see [Wiki pages](https://github.com/dgwave/lahore/wiki).

