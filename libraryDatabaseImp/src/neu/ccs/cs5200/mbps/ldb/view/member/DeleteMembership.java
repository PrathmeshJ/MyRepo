/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.view.member;

import neu.ccs.cs5200.mbps.ldb.jdbc.LDBConnector;
import neu.ccs.cs5200.mbps.ldb.model.Member;
import neu.ccs.cs5200.mbps.ldb.nav.Navigator;
import neu.ccs.cs5200.mbps.ldb.view.util.Registry;
import neu.ccs.cs5200.mbps.ldb.view.util.ViewConstants;

/**
 * Request that the current Member be removed from the system.
 * 
 * @author Matt
 */
public class DeleteMembership extends javax.swing.JPanel {

    /**
     * Creates new form DeleteMembership
     */
    public DeleteMembership() {
        initComponents();
        registerDeleteMembershipPanel();
    }
    
    /**
     * Register the view so it can be loaded at runtime
     */
    private void registerDeleteMembershipPanel() {
        (Navigator.getInstance()).register(ViewConstants.Member.DELETE_MEMBERSHIP, this);
    }
    
    
    /**
     * Get the current state of the Member's delete request
     */
    public void checkHasDeleteMembershipRequest() {
        Member member = (Member) (Registry.getInstance()).get(ViewConstants.SESSION_MEMBER);
        boolean hasDeleteMembershipRequest = (LDBConnector.getInstance()).hasDeleteMembershipRequest(member.getEmail());
        
        if (hasDeleteMembershipRequest) {
            this.deleteMembershipButton.setEnabled(false);
            this.deleteMembershipButton.setText("Delete Request Submitted");
        } else {
            this.deleteMembershipButton.setEnabled(true);
            this.deleteMembershipButton.setText("Delete Membership");
        }
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jLabel1 = new javax.swing.JLabel();
        deleteMembershipButton = new javax.swing.JButton();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();

        jLabel1.setText("Delete Membership");

        deleteMembershipButton.setText("Delete Membership");
        deleteMembershipButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                deleteMembershipButtonActionPerformed(evt);
            }
        });

        jLabel2.setText("Click below to request that");

        jLabel3.setText("your Membership be deleted");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(136, 136, 136)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                    .addComponent(deleteMembershipButton)
                    .addComponent(jLabel3)
                    .addComponent(jLabel2)
                    .addComponent(jLabel1))
                .addContainerGap(128, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(39, 39, 39)
                .addComponent(jLabel1)
                .addGap(33, 33, 33)
                .addComponent(jLabel2)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel3)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(deleteMembershipButton)
                .addContainerGap(151, Short.MAX_VALUE))
        );
    }// </editor-fold>//GEN-END:initComponents

    private void deleteMembershipButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_deleteMembershipButtonActionPerformed
        // submit a delete membership request
        Member member = (Member) (Registry.getInstance()).get(ViewConstants.SESSION_MEMBER);
        (LDBConnector.getInstance()).deleteMembership(member);
        checkHasDeleteMembershipRequest();
    }//GEN-LAST:event_deleteMembershipButtonActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton deleteMembershipButton;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    // End of variables declaration//GEN-END:variables
}
