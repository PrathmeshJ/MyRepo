/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.nav;

import java.util.HashMap;
import java.util.Map;
import javax.swing.JPanel;

/**
 * The Navigator class makes it possible to quickly switch between screens. The
 * LibraryScreen enum is called when loading various JFrames (varies by user), 
 * and the navigation map is used when moving around with a single role's 
 * navigation panel.
 * 
 * @author Matt
 */
public class Navigator {

    // card manager for navigating screens within each role's nav panel
    private Map<String, JPanel> navigationCards;
    
    // private constructor so that we can control the created instances
    private Navigator() {
        navigationCards = new HashMap<String, JPanel>();
    }
    
    // private class to enforce singleton model
    private static class NavigatorInstance {
        private static Navigator INSTANCE = new Navigator();
    }
    
    
    /**
     * @return the single Navigator instance
     */
    public static Navigator getInstance() {
        return NavigatorInstance.INSTANCE;
    }
    
    
   
    /**
     * Go to the next desired screen.
     * 
     * @param screen - the desired screen to navigate to
     */
    public void load(LibraryScreen screen) {
        screen.getScreen().setVisible(true);
    }
    
    
    /**
     * Register the name of the role's navigation panel that holds each of that
     * role's cards.
     * 
     * @param name - the name of the panel holding the navigation items
     * @param viewPanel - the panel that contains the navigation items
     */
    public void register(String name, JPanel viewPanel)
    {
        navigationCards.put(name, viewPanel);
    }
    
    /**
     * Get the panel that holds the navigation items for a specific role.
     * 
     * @param name - the name of the panel to retrieve
     * @return the panel that holds each of the navigation items for the current role
     */
    public JPanel retrieve(String name) 
    {
        return navigationCards.get(name);
    }
}
