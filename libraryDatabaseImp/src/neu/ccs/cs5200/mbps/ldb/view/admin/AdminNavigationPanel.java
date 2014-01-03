/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.view.admin;

import java.awt.CardLayout;
import javax.swing.JList;
import javax.swing.JPanel;
import neu.ccs.cs5200.mbps.ldb.nav.Navigator;
import neu.ccs.cs5200.mbps.ldb.view.member.DeleteMembership;
import neu.ccs.cs5200.mbps.ldb.view.member.ViewCheckedOutBooks;
import neu.ccs.cs5200.mbps.ldb.view.member.ViewDues;
import neu.ccs.cs5200.mbps.ldb.view.member.ViewProfile;
import neu.ccs.cs5200.mbps.ldb.view.member.ViewWishList;
import neu.ccs.cs5200.mbps.ldb.view.util.ViewConstants;

/**
 * The navigation panel for Administrators, which contains all of the basic
 * Member options plus the Respond to Requests page.
 * 
 * @author Matt
 */
public class AdminNavigationPanel extends javax.swing.JPanel {

    /**
     * Creates new form AdministratorNavigationPanel
     */
    public AdminNavigationPanel() {
        initComponents();
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        librarianNavigationList = new javax.swing.JList();

        librarianNavigationList.setModel(new javax.swing.AbstractListModel() {
            String[] strings = { "Book Search", "View My Profile", "View My Wish List", "View Dues", "View Current Checked Out Books", "Delete Membership", "Respond to Requests" };
            public int getSize() { return strings.length; }
            public Object getElementAt(int i) { return strings[i]; }
        });
        librarianNavigationList.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
        librarianNavigationList.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
            public void valueChanged(javax.swing.event.ListSelectionEvent evt) {
                librarianNavigationListValueChanged(evt);
            }
        });
        jScrollPane1.setViewportView(librarianNavigationList);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 400, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 300, Short.MAX_VALUE)
        );
    }// </editor-fold>//GEN-END:initComponents

    private void librarianNavigationListValueChanged(javax.swing.event.ListSelectionEvent evt) {//GEN-FIRST:event_librarianNavigationListValueChanged
        // navigate to the selected screen
        JList navigationList = (JList) evt.getSource();
        int selected = navigationList.getSelectedIndex();

        // prepare to navigate to a new location
        JPanel viewPanel = (Navigator.getInstance()).retrieve(ViewConstants.Admin.NAVIGATOR);
        CardLayout cl = (CardLayout) viewPanel.getLayout();

        // decide which screen to navigate to
        switch (selected) {
            // home
            case 0:
                cl.show(viewPanel, ViewConstants.Member.BOOK_SEARCH);
                break;

            // view profile
            case 1:
                // lazy load profile details
                ViewProfile vp = (ViewProfile) (Navigator.getInstance()).retrieve(ViewConstants.Member.VIEW_PROFILE);
                vp.loadProfile();
                
                cl.show(viewPanel, ViewConstants.Member.VIEW_PROFILE);
                break;

            // view my wish list
            case 2:
                // lazy load wish list details
                ViewWishList vwl = (ViewWishList) (Navigator.getInstance()).retrieve(ViewConstants.Member.VIEW_WISH_LIST);
                vwl.loadWishList();

                cl.show(viewPanel, ViewConstants.Member.VIEW_WISH_LIST);
                break;

            // view dues
            case 3:
                // lazy load dues details
                ViewDues vd = (ViewDues) (Navigator.getInstance()).retrieve(ViewConstants.Member.VIEW_DUES);
                vd.loadDues();

                cl.show(viewPanel, ViewConstants.Member.VIEW_DUES);
                break;

            // view currently checked out books
            case 4:
                ViewCheckedOutBooks vcob = (ViewCheckedOutBooks) (Navigator.getInstance()).retrieve(ViewConstants.Member.VIEW_CHECKED_OUT_BOOKS);
                vcob.loadCheckedOutBooks();
                
                cl.show(viewPanel, ViewConstants.Member.VIEW_CHECKED_OUT_BOOKS);
                break;

            // delete membership
            case 5:
                DeleteMembership dm = (DeleteMembership) (Navigator.getInstance()).retrieve(ViewConstants.Member.DELETE_MEMBERSHIP);
                dm.checkHasDeleteMembershipRequest();
                
                cl.show(viewPanel, ViewConstants.Member.DELETE_MEMBERSHIP);
                break;

            // respond to membership create/delete requests
            case 6:
                RespondRequests rr = (RespondRequests) (Navigator.getInstance()).retrieve(ViewConstants.Admin.RESPOND_TO_REQUESTS);
                rr.loadRequests();
                
                cl.show(viewPanel, ViewConstants.Admin.RESPOND_TO_REQUESTS);
                break;
        }
    }//GEN-LAST:event_librarianNavigationListValueChanged

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JList librarianNavigationList;
    // End of variables declaration//GEN-END:variables
}