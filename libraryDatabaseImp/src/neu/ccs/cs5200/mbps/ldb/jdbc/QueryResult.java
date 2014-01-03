/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.jdbc;

/**
 * A way to indicate why a query may have failed to the user.
 * 
 * @author Matt
 */
public class QueryResult {
    boolean querySuccessful;
    String message;
    
    public QueryResult() {
        this.querySuccessful = true;
        this.message = "";
    }

    public boolean isQuerySuccessful() {
        return querySuccessful;
    }

    public void setQuerySuccessful(boolean querySuccessful) {
        this.querySuccessful = querySuccessful;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
    
    /**
     * Append a message to the result
     * 
     * @param message 
     */
    public void addMessage(String message) {
        if (getMessage() == null) {
            setMessage(message);
        } else {
            setMessage(getMessage() + "\n" + message);
        }
    }
}
