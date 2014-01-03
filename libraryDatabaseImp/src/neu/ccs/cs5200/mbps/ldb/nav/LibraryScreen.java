/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.nav;

import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JFrame;
import neu.ccs.cs5200.mbps.ldb.view.LaunchPage;
import neu.ccs.cs5200.mbps.ldb.view.admin.AdminHomeScreen;
import neu.ccs.cs5200.mbps.ldb.view.librarian.LibrarianHomeScreen;
import neu.ccs.cs5200.mbps.ldb.view.member.MemberHomeScreen;
import neu.ccs.cs5200.mbps.ldb.view.user.UnregisteredUser;

/**
 * Define the distinct starting points for the different roles. Once a user role
 * is logged in, use a CardLayout to manage navigation.
 * 
 * @author Matt
 */
public enum LibraryScreen {
    HOME(LaunchPage.class),
    
    // user
    UNREGISTERED_USER(UnregisteredUser.class),
    
    // member
    MEMBER_HOME(MemberHomeScreen.class),
    
    // librarian
    LIBRARIAN_HOME(LibrarianHomeScreen.class),
    
    // admin
    ADMIN_HOME(AdminHomeScreen.class);
    
    
    // each item is associated with a particular JFrame
    private Class<? extends JFrame> screen;
    
    LibraryScreen(Class<? extends JFrame> frameClass)
    {
        screen = frameClass;
    }
    
    /**
     * @return the JFrame associated with the current screen
     */
    public JFrame getScreen()
    {
        try {
            // create a new instance of the corresponding class
            return screen.newInstance();
        } catch (InstantiationException ex) {
            Logger.getLogger(LibraryScreen.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            Logger.getLogger(LibraryScreen.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return null;
    }
}
