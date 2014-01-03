/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.view.util;

import java.util.HashMap;
import java.util.Map;

/**
 * A class that allows global access to arbitrary data. This can be used to pass
 * data between two views, effectively creating a session.
 * 
 * @author Matt
 */
public class Registry {
    
    // a map to hold global key/value pairs
    private Map<String, Object> registry;
    
    // a private constructor allows us to control the number of instances created
    private Registry() {
        registry = new HashMap<String, Object>();
    }
    
    
    /**
     * Private inner class to enforce the singleton model
     */
    private static class RegistryInstanceHolder {
        private static final Registry INSTANCE = new Registry();
    }
    
    
    /**
     * @return the only Registry instance
     */
    public static Registry getInstance() {
        return RegistryInstanceHolder.INSTANCE;
    }
    
    
    /**
     * Add data to the registry.
     * 
     * @param key
     * @param data 
     */
    public void put(String key, Object data) {
        registry.put(key, data);
    }
    
    /**
     * Get data from the global registry.
     * 
     * @param key - the entry key
     * @return the object stored at the given registry key
     */
    public Object get(String key) {
        return registry.get(key);
    }
}
