import ceylon.collection { HashMap }
import com.dgwave.lahore.api { ... }
import ceylon.io.buffer { ByteBuffer }

HashMap<String, [ContentType, String|ByteBuffer]> attachmentCache 
        = HashMap<String, [ContentType, String|ByteBuffer]>();

abstract class Scope() of 
globalScope | pluginScope | siteScope | sessionScope | conversationScope | requestScope | callScope {}

object globalScope extends Scope() { shared actual String string = "global";}
object pluginScope extends Scope() { shared actual String string = "plugin";}
object siteScope extends Scope() { shared actual String string = "site";}
object sessionScope extends Scope() { shared actual String string = "session";}	
object conversationScope extends Scope() { shared actual String string = "conversation";}	
object requestScope extends Scope() { shared actual String string = "request";}	
object callScope extends Scope() { shared actual String string = "call";}		
