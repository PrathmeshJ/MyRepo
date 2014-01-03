/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package neu.ccs.cs5200.mbps.ldb.view.util;

/**
 * A class for shared components between different views.
 * 
 * @author Matt
 */
public class ViewConstants {

    // the registry key for session user roles
    public static final String SESSION_USER = "SESSION_USER";
    public static final String SESSION_MEMBER = "SESSION_MEMBER";
    
    // page title
    public static final String TITLE = "MBPS Library";
    
    
    // card IDs for User Book Search
    public final class User {
        public static final String USER_REGISTRATION = "userRegistration";
        public static final String REQUEST_MEMBERSHIP = "requestMembership";
        public static final String BOOK_SEARCH = "userBookSearch";
        public static final String BOOK_SEARCH_RESULTS = "userBookSearchResults";
    }
    
    // card IDs for each Member navigation panel item
    public final class Member {
        // the name of the panel containing each card
        public static final String NAVIGATOR = "memberNavigator";
        
        // the name of each card
        public static final String BOOK_SEARCH = "memberBookSearch";
        public static final String VIEW_PROFILE = "memberViewProfile";
        public static final String VIEW_WISH_LIST = "memberViewWishList";
        public static final String VIEW_DUES = "memberViewDues";
        public static final String VIEW_CHECKED_OUT_BOOKS = "memberViewCheckedOutBooks";
        public static final String DELETE_MEMBERSHIP = "deleteMembership";
        
        
        // card IDs for the book search cards
        public final class BookSearch {
            public static final String SEARCH = "bookSearch";
            public static final String RESULTS = "bookSearchResults";
        }
    }
    
    // card IDs for each Librarian navigation panel item
    public final class Librarian {
        // the name of the panel containing each card
        public static final String NAVIGATOR = "librarianNavigator";
        
        // the name of each card specific to Librarian
        public static final String MANAGE_BOOKS = "librarianManageBooks";
        public static final String CHECK_OUT_BOOKS = "librarianCheckOutBooks";
        public static final String RETURN_BOOKS = "librarianReturnBooks";
        
        
        // card IDs for the Librarian's Manage Books flow
        public final class ManageBooks {
            public static final String ADD_BOOK = "librarianAddBook";
            public static final String EDIT_BOOK = "librarianEditBook";
            public static final String DELETE_BOOK = "librarianDeleteBook";
            
            
            // card IDs for a Librarian's Edit Book flow
            public final class EditBook {
                public static final String SEARCH_BOOK = "edit_bookSearch";
                public static final String EDIT_BOOK = "edit_bookEdit";
            }
            
            // card IDs for a Librarian's Delete Book flow
            public final class DeleteBook {
                public static final String SEARCH_BOOK = "delete_bookSearch";
                public static final String DELETE_BOOK = "delete_bookDelete";
            }
        }
        
        // card IDs for Librarian Check Out Books flow
        public final class CheckOutBooks {
            public static final String BOOK_SEARCH = "checkOutBookSearch";
            public static final String BOOK_SEARCH_RESULTS = "checkOutBookSearchResults";
            public static final String MEMBER_INFO = "checkOutAssignMember";
        }
    }
    
    // card IDs for each Administrator navigation panel card
    public final class Admin {
        // the name of the panel containing each card
        public static final String NAVIGATOR = "adminNavigator";
        
        // the name of each card specific to Admin
        public static final String RESPOND_TO_REQUESTS = "adminRespondRequests";
    }
}
