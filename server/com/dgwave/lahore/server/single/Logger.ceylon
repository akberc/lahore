import com.dgwave.lahore.server.console { consoleListener }
import com.dgwave.lahore.api { Logger }

shared class LahoreLogger(String component) satisfies Logger {
    
    shared actual void log(Integer severity, String from, String message) {
        String msg = from + ": " +message;
        if (severity <= lahoreDebugLevel) {
            consoleListener.addMessage(msg);
        }
        print(msg);	
    }
}

