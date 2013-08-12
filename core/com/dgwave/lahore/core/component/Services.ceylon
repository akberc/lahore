import com.dgwave.lahore.api { Service, Plugin, plugin }
shared class Services() {
	shared void register(String id, Plugin?(String) plugin) {}
}

shared object services {
	Services sh = Services();
	shared Service find(String serviceId) { return nothing; }
	shared void register(String id, Service service) {
		sh.register(id, plugin);
	}	
}

shared Service service(String serviceId) {
	return services.find(serviceId);
}