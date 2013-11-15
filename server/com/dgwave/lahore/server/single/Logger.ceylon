import com.dgwave.lahore.server.console { addConsoleMessage }
import com.dgwave.lahore.api { Logger }

shared class LahoreLogger(String component) satisfies Logger {
    
    shared actual void log(Integer severity, String from, String message) {
        String msg = from + ": " +message;
        if (severity <= lahoreDebugLevel) {
            addConsoleMessage(msg);
        }
        print(msg);	
    }
}

