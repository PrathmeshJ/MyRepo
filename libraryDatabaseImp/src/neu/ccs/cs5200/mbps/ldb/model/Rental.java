/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.model;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * A simple bean to tie together a Rental and a Book
 * 
 * @author Matt
 */
public class Rental {
    private Date dueDate;
    private double dues;
    private Book book;

    public String getFormattedDueDate() {
        return (dueDate == null) ? "null" : new SimpleDateFormat("yyyy-MM-dd").format(dueDate);
    }
    
    public Date getDueDate() {
        return dueDate;
    }

    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }

    public double getDues() {
        return dues;
    }

    public void setDues(double dues) {
        this.dues = dues;
    }

    public Book getBook() {
        return book;
    }

    public void setBook(Book book) {
        this.book = book;
    }
}
