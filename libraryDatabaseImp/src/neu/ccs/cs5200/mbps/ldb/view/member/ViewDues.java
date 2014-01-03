/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.view.member;

import java.text.DecimalFormat;
import java.util.List;
import javax.swing.table.DefaultTableModel;
import neu.ccs.cs5200.mbps.ldb.jdbc.LDBConnector;
import neu.ccs.cs5200.mbps.ldb.model.Book;
import neu.ccs.cs5200.mbps.ldb.model.Member;
import neu.ccs.cs5200.mbps.ldb.model.Rental;
import neu.ccs.cs5200.mbps.ldb.nav.Navigator;
import neu.ccs.cs5200.mbps.ldb.view.util.Registry;
import neu.ccs.cs5200.mbps.ldb.view.util.ViewConstants;

/**
 * View the current member's late books and fees.
 * 
 * @author Matt
 */
public class ViewDues extends javax.swing.JPanel {

    /**
     * Creates new form ViewDues
     */
    public ViewDues() {
        initComponents();
        this.duesTable.setAutoCreateRowSorter(true);
        registerViewDuesPanel();
    }
    
    
    /**
     * Register with the navigator so that the view dues can be forced to reload
     * its values from the database.
     */
    private void registerViewDuesPanel() {
        (Navigator.getInstance()).register(ViewConstants.Member.VIEW_DUES, this);
    }
    
    
    /**
     * Query the database for the dues owed by the current Member
     */
    public void loadDues() {
        // clear the old table first
        DefaultTableModel m = (DefaultTableModel) duesTable.getModel();
        while (m.getRowCount() > 0) {
            m.removeRow(0);
        }
        
        // display the dues owed by the current user
        Member session = (Member) (Registry.getInstance()).get(ViewConstants.SESSION_MEMBER);
        List<Rental> dues = (LDBConnector.getInstance()).viewDues(session.getMemberID());
        
        
        // add the books to the results table
        double totalDues = 0;
        for (Rental r : dues)
        {
            Book b = r.getBook();
            totalDues += r.getDues();
            m.addRow(new Object[] { DecimalFormat.getCurrencyInstance().format(r.getDues()),
                                    r.getFormattedDueDate(),
                                    b.getId(),
                                    b.getIsbn(),
                                    b.getTitle(),
                                    b.getAuthor(),
                                    b.getPublisher(),
                                    b.getGenre()
            });
        }
        
        this.totalDueLabel.setText(DecimalFormat.getCurrencyInstance().format(totalDues));
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
        jScrollPane1 = new javax.swing.JScrollPane();
        duesTable = new javax.swing.JTable();
        jLabel2 = new javax.swing.JLabel();
        totalDueLabel = new javax.swing.JLabel();

        jLabel1.setText("Dues");

        duesTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {
                "Amount", "Due Date", "ID", "ISBN", "Title", "Author", "Publisher", "Genre"
            }
        ) {
            Class[] types = new Class [] {
                java.lang.String.class, java.lang.String.class, java.lang.Integer.class, java.lang.String.class, java.lang.String.class, java.lang.String.class, java.lang.String.class, java.lang.String.class
            };
            boolean[] canEdit = new boolean [] {
                false, false, false, false, false, false, false, false
            };

            public Class getColumnClass(int columnIndex) {
                return types [columnIndex];
            }

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        duesTable.getTableHeader().setReorderingAllowed(false);
        jScrollPane1.setViewportView(duesTable);

        jLabel2.setText("TOTAL DUE:");

        totalDueLabel.setText("[total]");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 400, Short.MAX_VALUE)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addGap(188, 188, 188)
                        .addComponent(jLabel1))
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(jLabel2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(totalDueLabel)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(25, 25, 25)
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 221, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel2)
                    .addComponent(totalDueLabel))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
    }// </editor-fold>//GEN-END:initComponents
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JTable duesTable;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JLabel totalDueLabel;
    // End of variables declaration//GEN-END:variables
}
