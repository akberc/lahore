import com.dgwave.lahore.core.console { consoleListener }
import com.dgwave.lahore.core { lahoreDebugLevel }

shared void lahoreLog(Integer severity, String from, String message) {
	String msg = from + ": " +message;
	if (severity <= lahoreDebugLevel) {
		consoleListener.addMessage(msg);
	}
	print(msg);	
}