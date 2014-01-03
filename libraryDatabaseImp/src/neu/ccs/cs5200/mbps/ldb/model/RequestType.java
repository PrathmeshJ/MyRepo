/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.model;

/**
 * An enum to represent the two types of Request.
 * 
 * @author Matt
 */
public enum RequestType {
    CREATE("create"),
    DELETE("delete");
    
    private String value;
    
    RequestType(String val) {
        setValue(val);
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
