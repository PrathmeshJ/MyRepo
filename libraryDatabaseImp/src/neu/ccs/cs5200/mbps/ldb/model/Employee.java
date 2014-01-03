/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.model;

/**
 * A simple bean for employees. Abstract class, so only implementing classes
 * can instantiate this class.
 * 
 * @author Matt
 */
public class Employee extends Member {
    
    private int employeeID;

    public int getEmployeeID() {
        return employeeID;
    }

    public void setEmployeeID(int employeeID) {
        this.employeeID = employeeID;
    }
}
