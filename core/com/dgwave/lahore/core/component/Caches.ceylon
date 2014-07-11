import ceylon.collection { HashMap }
import com.dgwave.lahore.api { ... }
import ceylon.io.buffer { ByteBuffer }

shared HashMap<String, [ContentType, String|ByteBuffer]> attachmentCache 
        = HashMap<String, [ContentType, String|ByteBuffer]>();