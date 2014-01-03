/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.view.librarian;

import java.util.List;
import javax.swing.JOptionPane;
import javax.swing.table.DefaultTableModel;
import neu.ccs.cs5200.mbps.ldb.jdbc.LDBConnector;
import neu.ccs.cs5200.mbps.ldb.model.Book;
import neu.ccs.cs5200.mbps.ldb.model.Member;
import neu.ccs.cs5200.mbps.ldb.model.Rental;
import neu.ccs.cs5200.mbps.ldb.nav.Navigator;
import neu.ccs.cs5200.mbps.ldb.view.util.ViewConstants;

/**
 * A Librarian can remove the books checked out from the Member's profile after
 * they return the book.
 * 
 * @author Matt
 */
public class ReturnBooks extends javax.swing.JPanel {

    Member member;
    
    /**
     * Creates new form ReturnBooks
     */
    public ReturnBooks() {
        initComponents();
        registerReturnBooksPanel();
    }
    
    
    /**
     * Register for lazy loading
     */
    private void registerReturnBooksPanel() {
        (Navigator.getInstance()).register(ViewConstants.Librarian.RETURN_BOOKS, this);
    }
    
    
    /**
     * Load the return books screen
     */
    public void loadReturnBooks() {
        // clear the previous selections
        member = null;
        
        this.memberEmailTextField.setText("");
        
        DefaultTableModel m = (DefaultTableModel) checkedOutBooksTable.getModel();
        while (m.getRowCount() > 0) {
            m.removeRow(0);
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

        findBooksButton = new javax.swing.JButton();
        jLabel1 = new javax.swing.JLabel();
        memberEmailTextField = new javax.swing.JTextField();
        jLabel2 = new javax.swing.JLabel();
        jScrollPane1 = new javax.swing.JScrollPane();
        checkedOutBooksTable = new javax.swing.JTable();
        returnBooksButton = new javax.swing.JButton();

        findBooksButton.setText("Find Books");
        findBooksButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                findBooksButtonActionPerformed(evt);
            }
        });

        jLabel1.setText("Return Books");

        jLabel2.setText("Member EMail");

        checkedOutBooksTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {
                "Select", "Due Date", "ID", "ISBN", "Title", "Author", "Publisher", "Genre"
            }
        ) {
            Class[] types = new Class [] {
                java.lang.Boolean.class, java.lang.String.class, java.lang.Integer.class, java.lang.String.class, java.lang.String.class, java.lang.String.class, java.lang.String.class, java.lang.String.class
            };
            boolean[] canEdit = new boolean [] {
                true, false, false, false, false, false, false, false
            };

            public Class getColumnClass(int columnIndex) {
                return types [columnIndex];
            }

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        checkedOutBooksTable.getTableHeader().setReorderingAllowed(false);
        jScrollPane1.setViewportView(checkedOutBooksTable);

        returnBooksButton.setText("Return Selected Books");
        returnBooksButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                returnBooksButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap(53, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addComponent(jLabel1)
                        .addGap(166, 166, 166))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addComponent(jLabel2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(memberEmailTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 94, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(findBooksButton)
                        .addGap(95, 95, 95))))
            .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
            .addGroup(layout.createSequentialGroup()
                .addGap(122, 122, 122)
                .addComponent(returnBooksButton, javax.swing.GroupLayout.PREFERRED_SIZE, 166, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jLabel1)
                .addGap(18, 18, 18)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(findBooksButton)
                    .addComponent(memberEmailTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel2))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 188, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(returnBooksButton)
                .addContainerGap())
        );
    }// </editor-fold>//GEN-END:initComponents

    private void findBooksButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_findBooksButtonActionPerformed
        // make sure a member has been entered
        String memberEmail = this.memberEmailTextField.getText();
        member = (LDBConnector.getInstance()).findMemberByEmail(memberEmail);
        
        // null if the member was incorrect
        if (member == null) {
            JOptionPane.showMessageDialog(this,
                                          "No Member associated with the given Email address",
                                          "Member Not Found",
                                          JOptionPane.WARNING_MESSAGE
            );
            return;
        }
        
        // get the books checked out by the given member
        List<Rental> rentals = (LDBConnector.getInstance()).viewCurrentCheckedOutBooks(member);
        
        // add each of the results to the table
        DefaultTableModel m = (DefaultTableModel) checkedOutBooksTable.getModel();
        for (Rental r : rentals) {
            Book b = r.getBook();
            m.addRow(new Object[] { false,
                                    r.getFormattedDueDate(),
                                    b.getId(),
                                    b.getIsbn(),
                                    b.getTitle(),
                                    b.getAuthor(),
                                    b.getPublisher(),
                                    b.getGenre()
            });
        }
    }//GEN-LAST:event_findBooksButtonActionPerformed

    private void returnBooksButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_returnBooksButtonActionPerformed
        // remove the selected books from the checked out items associated with the member
        DefaultTableModel m = (DefaultTableModel) checkedOutBooksTable.getModel();
        for (int i=0; i<m.getRowCount(); i++) {
            // only read selected rows
            if ((Boolean) m.getValueAt(i, 0)) {
                // col 1 is the due date
                int bookID = (Integer) m.getValueAt(i, 2);
                (LDBConnector.getInstance()).removeRental(member.getMemberID(), bookID);
                
                // remove the selected row
                m.removeRow(i);
                i--; // keep the iterator on the current row
            }
        }
    }//GEN-LAST:event_returnBooksButtonActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JTable checkedOutBooksTable;
    private javax.swing.JButton findBooksButton;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JTextField memberEmailTextField;
    private javax.swing.JButton returnBooksButton;
    // End of variables declaration//GEN-END:variables
}