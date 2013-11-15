import com.dgwave.lahore.api { Task }
by ("Matej Lazar")
doc ("Adapted from Openshift Ceylon template by Matej Lazar")


class DefaultTask(message, id, done = false) satisfies Task {
    shared actual variable Boolean done;
    shared actual String id;
    shared actual String message;
}

String generateId() {
    return system.nanoseconds.string;
}

shared Task createTask(String message) {
    return DefaultTask(message, generateId());
}
