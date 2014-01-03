/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.model;

import java.util.Arrays;

/**
 * An enum representing the possible genre values, to avoid the user having to
 * fat-finger in the value. Ideally we would actually query the DB to retrieve 
 * the values, but our schema design didn't take this into consideration.
 * 
 * @author Matt
 */
public enum Genre {
    FICTION("fiction"),
    HISTORY("history"),
    MEDICINE("medicine"),
    NEWS("news"),
    NONFICTION("nonfiction"),
    POLITICS("politics"),
    RELIGION("religion"),
    ROMANCE("romance"),
    SCIENCE("science"),
    SCIFI("scienceFiction");
    
    private String text;
    
    Genre(String val) {
        this.text = val;
    }
    
    public String getText() {
        return text;
    }
    
    public static int indexOf(String genre) {
        for (int i=0; i<values().length; i++) {
            if (values()[i].getText().equals(genre)) {
                return i;
            }
        }
        return -1;
    }
}
