import com.dgwave.lahore.api { Service }
import ceylon.collection { HashMap }

class Services() {
	value serviceMap = HashMap<String, Service>();
	
	shared void register(String serviceId, ServiceImpl serviceImpl) {
		serviceMap.put(serviceId, serviceImpl);
	}
}

shared object services {
	Services sh = Services();
	shared Service find(String serviceId) { return nothing; }
	shared void register(String serviceId, ServiceImpl serviceImpl) {
		sh.register(serviceId, serviceImpl);
	}	
}

shared Service service(String serviceId) {
	return services.find(serviceId);
}

shared class ServiceImpl(pluginId) satisfies Service {

	shared actual String pluginId;
}