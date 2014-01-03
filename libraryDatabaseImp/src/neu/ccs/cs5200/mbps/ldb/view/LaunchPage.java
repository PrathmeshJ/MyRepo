/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.view;

import javax.swing.JOptionPane;
import neu.ccs.cs5200.mbps.ldb.jdbc.LDBConnector;
import neu.ccs.cs5200.mbps.ldb.model.Administrator;
import neu.ccs.cs5200.mbps.ldb.model.Librarian;
import neu.ccs.cs5200.mbps.ldb.model.Member;
import neu.ccs.cs5200.mbps.ldb.jdbc.QueryResult;
import neu.ccs.cs5200.mbps.ldb.model.User;
import neu.ccs.cs5200.mbps.ldb.nav.LibraryScreen;
import neu.ccs.cs5200.mbps.ldb.nav.Navigator;
import neu.ccs.cs5200.mbps.ldb.view.util.Registry;
import neu.ccs.cs5200.mbps.ldb.view.util.ViewConstants;

/**
 * The login for the Library Database. From here, a Library User can search for
 * a book and request a membership, Members can view their profile and create a
 * wish list, Librarians can manage the library inventory, and Administrators
 * can manage accounts.
 * 
 * @author Matt
 */
public class LaunchPage extends javax.swing.JFrame {

    /**
     * Creates new form LDBApplication
     */
    public LaunchPage() {
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

        nameTextField = new javax.swing.JTextField();
        emailTextField = new javax.swing.JTextField();
        memberEmailTextField = new javax.swing.JTextField();
        jLabel1 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();
        jLabel4 = new javax.swing.JLabel();
        jLabel5 = new javax.swing.JLabel();
        jLabel6 = new javax.swing.JLabel();
        memberPasswordField = new javax.swing.JPasswordField();
        bookSearchButton = new javax.swing.JButton();
        signInButton = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("MBPS Library");

        memberEmailTextField.addFocusListener(new java.awt.event.FocusAdapter() {
            public void focusLost(java.awt.event.FocusEvent evt) {
                memberEmailTextFieldFocusLost(evt);
            }
        });

        jLabel1.setText("New User Information");

        jLabel2.setHorizontalAlignment(javax.swing.SwingConstants.TRAILING);
        jLabel2.setText("Name");

        jLabel3.setHorizontalAlignment(javax.swing.SwingConstants.TRAILING);
        jLabel3.setText("EMail");

        jLabel4.setText("Member Sign In");

        jLabel5.setText("EMail");

        jLabel6.setText("Password");

        bookSearchButton.setText("Find a Book");
        bookSearchButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                bookSearchButtonActionPerformed(evt);
            }
        });

        signInButton.setText("Sign In");
        signInButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                signInButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(117, 117, 117)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(signInButton, javax.swing.GroupLayout.PREFERRED_SIZE, 88, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jLabel2, javax.swing.GroupLayout.PREFERRED_SIZE, 52, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(nameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 88, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jLabel3, javax.swing.GroupLayout.PREFERRED_SIZE, 49, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(emailTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 88, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jLabel6)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(memberPasswordField, javax.swing.GroupLayout.PREFERRED_SIZE, 88, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jLabel5)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(jLabel4, javax.swing.GroupLayout.DEFAULT_SIZE, 88, Short.MAX_VALUE)
                            .addComponent(memberEmailTextField)))
                    .addComponent(bookSearchButton, javax.swing.GroupLayout.PREFERRED_SIZE, 96, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap(159, Short.MAX_VALUE))
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel1)
                .addGap(151, 151, 151))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(36, 36, 36)
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(nameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel2))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(emailTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel3))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(bookSearchButton)
                .addGap(36, 36, 36)
                .addComponent(jLabel4)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(memberEmailTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel5))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(memberPasswordField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel6))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(signInButton)
                .addContainerGap(38, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void bookSearchButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_bookSearchButtonActionPerformed
        // halt if the name or email field is empty
        if (this.nameTextField.getText().isEmpty() || this.emailTextField.getText().isEmpty()) {
            JOptionPane.showMessageDialog(this,
                                          "Please Enter a Name and Email address",
                                          "Missing User Details",
                                          JOptionPane.WARNING_MESSAGE
            );
            return;
        }
        
        // create a session object for this user
        User sessionUser = new User();
        sessionUser.setName(this.nameTextField.getText());
        sessionUser.setEmail(this.emailTextField.getText());
        
        // store the current user's information
        QueryResult result = (LDBConnector.getInstance()).registerUser(sessionUser.getName(), sessionUser.getEmail());
        
        if (result.isQuerySuccessful()) {
            // establish a session by storing the current user in the global registry
            (Registry.getInstance()).put(ViewConstants.SESSION_USER, sessionUser);

            (Navigator.getInstance()).load(LibraryScreen.UNREGISTERED_USER);
        } else {
            JOptionPane.showMessageDialog(this,
                                          result.getMessage(),
                                          "Duplicate Entry",
                                          JOptionPane.WARNING_MESSAGE
            );

        }
    }//GEN-LAST:event_bookSearchButtonActionPerformed

    private void signInButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_signInButtonActionPerformed
        // get the member login information
        String email = this.memberEmailTextField.getText();
        String password = String.valueOf(this.memberPasswordField.getPassword());

        Member session = null;
        
        if (!email.isEmpty() && !password.isEmpty()) {
            try {
                session = LDBConnector.getInstance().memberLogin(email, password);
            } catch (NumberFormatException e) {
                // swallow the exception -- allow the member session to be null
            }
        }
        
        // see if login failed
        if (session == null) {
            JOptionPane.showMessageDialog(this,
                                          "Username or password not recognized",
                                          "Login Failed",
                                          JOptionPane.WARNING_MESSAGE
            );
        } else {
            // establish a session by storing the current member in the global registry
            (Registry.getInstance()).put(ViewConstants.SESSION_MEMBER, session);

            // bring up the member home page
            if (session instanceof Librarian) {
                (Navigator.getInstance()).load(LibraryScreen.LIBRARIAN_HOME);
            } else if (session instanceof Administrator) {
                (Navigator.getInstance()).load(LibraryScreen.ADMIN_HOME);
            } else {
                (Navigator.getInstance()).load(LibraryScreen.MEMBER_HOME);
            }
        }
    }//GEN-LAST:event_signInButtonActionPerformed

    private void memberEmailTextFieldFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_memberEmailTextFieldFocusLost
        // delete the old password
        this.memberPasswordField.setText("");
    }//GEN-LAST:event_memberEmailTextFieldFocusLost

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (ClassNotFoundException ex) {
            java.util.logging.Logger.getLogger(LaunchPage.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            java.util.logging.Logger.getLogger(LaunchPage.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            java.util.logging.Logger.getLogger(LaunchPage.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (javax.swing.UnsupportedLookAndFeelException ex) {
            java.util.logging.Logger.getLogger(LaunchPage.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>

        /* Create and display the form */
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new LaunchPage().setVisible(true);
            }
        });
    }
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton bookSearchButton;
    private javax.swing.JTextField emailTextField;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JLabel jLabel5;
    private javax.swing.JLabel jLabel6;
    private javax.swing.JTextField memberEmailTextField;
    private javax.swing.JPasswordField memberPasswordField;
    private javax.swing.JTextField nameTextField;
    private javax.swing.JButton signInButton;
    // End of variables declaration//GEN-END:variables
}
