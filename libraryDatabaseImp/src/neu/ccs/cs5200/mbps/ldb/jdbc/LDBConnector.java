package neu.ccs.cs5200.mbps.ldb.jdbc;

import java.math.BigInteger;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import neu.ccs.cs5200.mbps.ldb.model.Administrator;
import neu.ccs.cs5200.mbps.ldb.model.Book;
import neu.ccs.cs5200.mbps.ldb.model.Librarian;
import neu.ccs.cs5200.mbps.ldb.model.Member;
import neu.ccs.cs5200.mbps.ldb.model.Rental;
import neu.ccs.cs5200.mbps.ldb.model.Request;
import neu.ccs.cs5200.mbps.ldb.model.RequestType;
import neu.ccs.cs5200.mbps.ldb.model.User;
import neu.ccs.cs5200.mbps.ldb.model.WishList;
import neu.ccs.cs5200.mbps.ldb.util.JDBCConnectorPropertiesReader;


/**
 * Connects to the MBPS Library Database using JDBC. The scope of each database
 * connection should be the method that the query occurs in.
 */
public class LDBConnector
{
    // detail for the JDBC connector to be used to connect to the database
    private JDBCProperties jdbcProps = null;
    
    // the name of the JDBC connector from the properties file
    private static final String JDBC_DRIVER = "mysql";
    
    // the path of the JDBC properties file
    private static final String JDBC_PROPERTIES_FILE = "./data/JDBCConnection.properties";
    
    private static int nextMembershipID = 0;
    
    
    
    /**
     * Making the constructor private means that we can control when instances
     * are created. This allows us to guarantee a singleton model.
     */
    private LDBConnector()
    {
        // get the properties for the target JDBC connector
        try {
            jdbcProps = JDBCConnectorPropertiesReader.getInstance().readJDBCPropertiesFromFile(JDBC_PROPERTIES_FILE);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("using default connection values");
            System.err.println("failed to load JDBC properties from " + JDBC_PROPERTIES_FILE);
            
            jdbcProps = new JDBCProperties();
            jdbcProps.setDriver("com.mysql.jdbc.Driver");
            jdbcProps.setUsername("root");   
            jdbcProps.setPassword("root");
            jdbcProps.setUrl("jdbc:mysql://localhost:8889/library_database");         
        }
        
        // load the JDBC driver
        try
        {
            Class.forName(jdbcProps.getDriver());
        }
        catch (ClassNotFoundException e)
        {
            System.err.println("Could not load driver name \"" + jdbcProps.getDriver() + "\" from property \"" + JDBC_DRIVER + "\"");
            e.printStackTrace();
            System.exit(-1);
        }
        
        
        
        // initialize the next membership ID variable
        try {
            PreparedStatement nextMemberID = getConnection().prepareStatement(
                    "select membershipID from member order by membershipID desc limit 1"
            );
            
            ResultSet nextMemberIDResult = nextMemberID.executeQuery();
            if (nextMemberIDResult.next()) {
                nextMembershipID = nextMemberIDResult.getInt("membershipID") + 1;
            }
            
            nextMemberIDResult.close();
            nextMemberID.close();
            
        } catch (SQLException ex) {
            System.err.println("unable to find current max membershipID");
            ex.printStackTrace();
        }
    }
    
    
    
    /**
     * Enforce a singleton model 
     */
    private static class LDBConnectorInstanceHolder
    {
        private static LDBConnector INSTANCE = new LDBConnector();
    }
    
    
    /**
     * @return the Library Database Connector
     */
    public static LDBConnector getInstance()
    {
        return LDBConnectorInstanceHolder.INSTANCE;
    }
    
    
    /**
     * Create a connection to the Library Database.
     * 
     * @return an LDB connection
     * @throws SQLException 
     */
    private Connection getConnection() throws SQLException
    {
        String url = jdbcProps.getUrl();
        String user = jdbcProps.getUsername();
        String pass = jdbcProps.getPassword();
        return DriverManager.getConnection(url, user, pass);
    }
    
    
    

    /**
     * Any User can search for a book in the library.
     * 
     * @param field - the attribute to search for
     * @param value - the value to search for
     * @return the list of books matching the given field:value pair
     */
    public List<Book> searchBook(String field, String value)
    {
        // the result of the query
        List<Book> books = new ArrayList<Book>();
        
        try
        {
            PreparedStatement findBook = getConnection().prepareStatement(
                    "select * from book where " + field + " like ?"
            );
            findBook.setString(1, "%" + value + "%");

            // perform the query
            ResultSet result = findBook.executeQuery();

            int numRecords = 0;
            
            // iterate through each record in the result
            while (result.next())
            {
                // get the values for each field in the record
                int id = result.getInt("id");
                BigInteger isbn = result.getBigDecimal("ISBN").toBigInteger();
                String title = result.getString("title");
                String author = result.getString("author");
                String publisher = result.getString("publisher");
                String genre = result.getString("genre");
                int numCopies = result.getInt("numCopies");
                
                // create a book with the record's attributes
                Book b = new Book();
                b.setId(id);
                b.setIsbn(isbn.toString());
                b.setTitle(title);
                b.setAuthor(author);
                b.setPublisher(publisher);
                b.setGenre(genre);
                b.setNumCopies(numCopies);
                
                books.add(b);
                
                numRecords++;
            }
            
            System.out.println("returned " + numRecords + " records");
            result.close();
            findBook.close();
        }
        catch (SQLException ex)
        {
            // handle any errors
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return books;
    }


    /**
     * A User requests a library Membership.
     * 
     * @param name -- session variable for name
     * @param email -- session variable for email
     * @param address -- given address from textbox
     * @param phoneNumber -- given phone number from textbox
     */
    private void createRequest(RequestType requestType, String name, String email, String address, String phoneNumber) {
        try {
            Connection conn = getConnection();
            
            // make sure this email address doesn't already have a request
            PreparedStatement existingEntry = conn.prepareStatement(
                    "select * from request "
                    + "where createdBy = ? "
                    + "and type = ?"
            );
            existingEntry.setString(1, email);
            existingEntry.setString(2, requestType.getValue());
            
            ResultSet hasExistingEntry = existingEntry.executeQuery();
            // the resultant table is non-empty
            if (hasExistingEntry.next()) {
                System.out.println(name + " (" + email + ") already has a " + requestType.getValue() + " request");
            }
            else {
                // add the request to the database
                PreparedStatement insertRequest = conn.prepareStatement(
                        "insert into request " 
                        + "(address, createdBy, phoneNumber, type, servicedBy) "
                        + "values(?, ?, ?, ?, ?)"
                );
                insertRequest.setString(1, address);
                insertRequest.setString(2, email);
                insertRequest.setString(3, phoneNumber);
                insertRequest.setString(4, requestType.getValue());
                insertRequest.setNull(5, Types.INTEGER);
                insertRequest.executeUpdate();

                insertRequest.close();
            }
            
            hasExistingEntry.close();
            existingEntry.close();
            conn.close();
        }
        catch (SQLException ex)
        {
            // handle any errors
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }

    
    
    /**
     * Add a new user to the database.
     * 
     * @param name
     * @param email
     * @return the result of the query
     */
    public QueryResult registerUser(String name, String email) {
        QueryResult result = new QueryResult();
        
        try {
            Connection conn = getConnection();
            PreparedStatement findUser = conn.prepareStatement(
                    "select * from user u where email = ?"
            );
            findUser.setString(1, email);
            ResultSet user = findUser.executeQuery();

            // If user doesn't exist insert in table
            if (!user.next())
            {
                System.out.println("adding new user " + name + " (" + email + ")");
                PreparedStatement insertUser = conn.prepareStatement(
                        "insert into User(name, email) values(?, ?)"
                );

                // Inserting textbox name and email:
                insertUser.setString(1, name);
                insertUser.setString(2, email);
                insertUser.executeUpdate();
                insertUser.close();
            }
            // user does exist -- add return message
            else 
            {
                result.setQuerySuccessful(false);
                result.addMessage("User with email \"" + email + "\" already exists!");
            }
            
            user.close();
            findUser.close();
            conn.close();
        }
        catch (SQLException ex)
        {
            // handle any errors
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return result;
    }
    
    
    /**
     * Get the member details for the given membership ID.
     * 
     * @param membershipId - the current session's member ID
     * @return the member object corresponding to the given ID
     */
    public Member viewMyProfile(int membershipId)
    {
        Member mem = new Member();
        mem.setMemberID(membershipId);
        
        try {
        
            PreparedStatement viewProfile = getConnection().prepareStatement(
                    "select m.email, m.address, m.phoneNumber, u.name "
                    + "from member m, user u "
                    + "where m.membershipID = ? "
                    + "and m.email = u.email"
            );

            viewProfile.setInt(1, membershipId);
            ResultSet displayProfile = viewProfile.executeQuery();
            
            //displays the email, address and phone number of member
            //here email should be non editable whereas address and phoneNumber should be editable
            if (displayProfile.next())
            {
                mem.setName(displayProfile.getString("name"));
                mem.setEmail(displayProfile.getString("email"));
                mem.setAddress(displayProfile.getString("address"));
                mem.setPhoneNumber(displayProfile.getString("phoneNumber"));
            }
             
            displayProfile.close();
            viewProfile.close();
        }
        catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
         
        return mem;
    }
    
    /**
     * Verifies that the given membership ID and password exists, and if so logs
     * the member in.
     * 
     * @param loginEmail - member's login email
     * @param loginPassword - the member's login password
     * @return the member attempting to log in
     */
    public Member memberLogin(String loginEmail, String loginPassword) 
    {
        Member mem = null;
        try {
            // Check that member ID and password exist
            Connection conn = getConnection();
            PreparedStatement checkMember = conn.prepareStatement(
                    "select m.membershipID, m.email, m.phoneNumber, m.address, u.name "
                    + "from member m, user u "
                    + "where m.email = u.email "
                    + "and m.email = ? "
                    + "and m.password = ?"
            );
            checkMember.setString(1, loginEmail);
            checkMember.setString(2, loginPassword);
            ResultSet member = checkMember.executeQuery();

            //If the entry doesn't exist, proceed with adding the book
            // to the wishlist
            if (!member.next()) {
                System.out.println("Error: Username or password incorrect");
            } else {
                System.out.println("Login information corresponds to a Member");
                
                // get the values from the record
                int membershipID = member.getInt("membershipID");
                String email = member.getString("email");
                String phone = member.getString("phoneNumber");
                String address = member.getString("address");
                String name = member.getString("name");
                
                // initialize a Member if neither a Librarian nor an Admin
                mem = new Member();
                
                // determine if the member is also an employee
                PreparedStatement checkEmployee = conn.prepareStatement(
                        "select * from employee e, member m "
                        + "where e.memberID = ?"
                );
                checkEmployee.setInt(1, membershipID);
                
                ResultSet isEmployee = checkEmployee.executeQuery();
                while (isEmployee.next()) {
                    // determine admin or librarian
                    
                    // librarian
                    PreparedStatement checkLibrarian = conn.prepareStatement(
                            "select * from employee e, librarian l "
                            + "where e.memberID = ? "
                            + "and e.employeeID = l.employeeID"
                    );
                    checkLibrarian.setInt(1, membershipID);
                    
                    ResultSet isLibrarian = checkLibrarian.executeQuery();
                    while (isLibrarian.next()) {
                        mem = new Librarian();
                        ((Librarian) mem).setEmployeeID(isLibrarian.getInt("employeeID"));
                        System.out.println("Member logging in is a Librarian");
                        break;
                    }
                    checkLibrarian.close();
                    isLibrarian.close();
                    
                    // admin
                    PreparedStatement checkAdmin = conn.prepareStatement(
                            "select * from employee e, administrator a "
                            + "where e.memberID = ? "
                            + "and e.employeeID = a.employeeID"
                    );
                    checkAdmin.setInt(1, membershipID);
                    
                    ResultSet isAdmin = checkAdmin.executeQuery();
                    while (isAdmin.next()) {
                        mem = new Administrator();
                        ((Administrator) mem).setEmployeeID(isAdmin.getInt("employeeID"));
                        System.out.println("Member logging in is an Administrator");
                        break;
                    }
                    checkAdmin.close();
                    isAdmin.close();
                    
                    break;
                }
                
                // use the values from the record to fill in the member details
                mem.setMemberID(membershipID);
                mem.setEmail(email);
                mem.setPhoneNumber(phone);
                mem.setAddress(address);
                mem.setName(name);
            }
            
            checkMember.close();
            member.close();
            conn.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return mem;
    }
    
    
    /**
     * Get the wish list belonging to the current member.
     * 
     * @param member - the current logged in member
     * @return the wishlist belonging to the given member, or null if the member has no wishlist
     */
    public WishList viewWishList(Member member) {

        WishList wl = createWishList(member.getMemberID(), member.getName() + "'s Wish List");

        try {
            
            // get the user's wishlist name
            Connection conn = getConnection();
            PreparedStatement wishListName = conn.prepareStatement(
                    "select wl.name "
                  + "from wishlist wl " 
                  + "where wl.belongsTo = ?"
            );
            
            wishListName.setInt(1, member.getMemberID());
            ResultSet displayWishListName = wishListName.executeQuery();
            
            while (displayWishListName.next()) {
                if (wl == null) {
                    wl = new WishList();
                }

                wl.setName(displayWishListName.getString("name"));
                System.out.println("set wl name: " + wl.getName());
                break;
            }
            
            wishListName.close();
            displayWishListName.close();


            // get the member's wishlist's books
            PreparedStatement wishList = conn.prepareStatement(
                    "select b.* "
                    + "from book b, wishlist wl, wishlistbook wlb "
                    + "where b.id = wlb.hasBook "
                    + "and wlb.belongsTo = wl.id "
                    + "and wl.belongsTo= ?");

            wishList.setInt(1, member.getMemberID());
            ResultSet displayWishList = wishList.executeQuery();


            // assign the books to the wishlist bean
            List<Book> wishListBooks = new ArrayList<Book>();
            while (displayWishList.next()) {
                // add the current book to the wishlist
                int id = displayWishList.getInt("id");
                String isbn = displayWishList.getBigDecimal("isbn").toBigInteger().toString();
                String title = displayWishList.getString("title");
                String author = displayWishList.getString("author");
                String publisher = displayWishList.getString("publisher");
                String genre = displayWishList.getString("genre");

                Book b = new Book();
                b.setId(id);
                b.setIsbn(isbn);
                b.setTitle(title);
                b.setAuthor(author);
                b.setPublisher(publisher);
                b.setGenre(genre);

                wishListBooks.add(b);
            }

            wl.setBooks(wishListBooks);
            wishList.close();
            displayWishList.close();
            conn.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
        }
        
        return wl;
    }
    
    
    /**
     * Set the name of a wishlist to a new value.
     * 
     * @param memberID - the member ID of the current member
     * @param name - the new name of the wish list
     */
    public void setWishListName(int memberID, String name) {
        try {
            // ensure the member's wishlist exists
            createWishList(memberID, name);
            
            // set the new name
            PreparedStatement updateWishListName = getConnection().prepareStatement(
                    "update wishlist "
                    + "set name=? "
                    + "where belongsTo = ?"
            );
            updateWishListName.setString(1, name);
            updateWishListName.setInt(2, memberID);
            updateWishListName.executeUpdate();
            updateWishListName.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }
    
    /**
     * Creates a wishlist for member only if they do not have a wishlist yet.
     * Method prevents a member from having more than one wishlist.
     *
     * @param belongsTo--the membership ID of the member who is creating the
     * wish list
     * @param name--the name of the wishlist to be created
     */
    private WishList createWishList(int belongsTo, String name) {
        WishList wl = new WishList();
        wl.setName(name);
        
        try {
            //First need to ensure user doesn't already have a wishlist
            Connection conn = getConnection();
            PreparedStatement checkWishList = conn.prepareStatement(
                    "select * from wishlist w "
                    + "where w.belongsTo=?");
            checkWishList.setInt(1, belongsTo);
            
            
            ResultSet wishList = checkWishList.executeQuery();
            
            //If the user doesn't have a wishlist, proceed with creating it:
            if (!wishList.next()) {

                PreparedStatement createWishList = conn.prepareStatement(
                        "insert into wishlist (belongsTo, name)"
                        + " VALUES (?, ?)");
                createWishList.setInt(1, belongsTo);
                createWishList.setString(2, name);
                
                createWishList.executeUpdate();
                createWishList.close();
                
            } else {
                wl.setName(wishList.getString("name"));
                System.out.println("Wish List already exists for user -- cannot create a new one");
            }
            
            wishList.close();
            conn.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return wl;
    }

    
    /**
     * Adds the selected book to the Member's wishlist if the book does not
     * already exist in the Member's wishlist.
     *
     * @param memberID - the member ID currently logged in
     * @param bookID - the book ID to add
     * @return the result of the update
     */
    public QueryResult addBookToWishList(int memberID, int bookID) {
        QueryResult result = new QueryResult();
        
        try {
            //First need to ensure book isn't already in wishList
            Connection conn = getConnection();
            PreparedStatement checkWishList = conn.prepareStatement(
                    "select wl.id, wl.belongsTo as owner, "
                    + "wlb.belongsTo as onWishList, wlb.hasBook "
                    + "from wishlist wl, wishlistbook wlb "
                    + "where wl.belongsTo = ? "
                    + "and wlb.belongsTo = wl.id "
                    + "and wlb.hasBook = ?");
            checkWishList.setInt(1, memberID);
            checkWishList.setInt(2, bookID);
            ResultSet wishListBook = checkWishList.executeQuery();
            
            
            // If the entry doesn't exist, proceed with adding the book to the wishlist
            if (!wishListBook.next()) 
            {
                // get the wishlist owner
                PreparedStatement wishListOwner = conn.prepareStatement(
                        "select * from wishlist where belongsTo = ?"
                );
                wishListOwner.setInt(1, memberID);
                ResultSet wishListOwnerResult = wishListOwner.executeQuery();
                
                if (wishListOwnerResult.next()) {
                    int wishListID = wishListOwnerResult.getInt("id");
                    
                    // add book to the member's wish list
                    System.out.println("adding book ID " + bookID + " to wish list ID " + wishListID);
                    PreparedStatement addBookWishList = conn.prepareStatement(
                            "insert into wishlistbook (belongsTo, hasBook)"
                            + " VALUES (?, ?)");
                    addBookWishList.setInt(1, wishListID);
                    addBookWishList.setInt(2, bookID);
                    addBookWishList.executeUpdate();
                    addBookWishList.close();
                } 
                else
                {
                    result.addMessage("Member " + memberID + " does not have a Wishlist");
                    result.setQuerySuccessful(false);
                }
                
                wishListOwnerResult.close();
                wishListOwner.close();
                
            } else {
                result.setMessage("Wishlist already contains Book ID " + bookID);
                result.setQuerySuccessful(false);
            }
            
            
            checkWishList.close();
            wishListBook.close();
            conn.close();
            
        } 
        catch (SQLException ex) 
        {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return result;
    }

    
    /**
     *
     * @param membershipId - membershipId from session variable
     * @param ISBN - ISBN value from the wishlist This method removes the books
     * in a members wish list The ISBN is used to remove the corresponding wish
     * list for a member
     */
    public void removeSelectedFromWishList(int membershipId, String ISBN) {

        try {
            PreparedStatement bookRemoval = getConnection().prepareStatement(
                    "delete wlb from "
                    + "book b, wishlist wl, wishlistbook wlb "
                    + "where "
                    + "b.id = wlb.hasBook "
                    + "and wlb.belongsTo = wl.id "
                    + "and b.ISBN = ? "
                    + "and wl.belongsTo= ?");

            bookRemoval.setString(1, ISBN);
            bookRemoval.setInt(2, membershipId);
            bookRemoval.executeUpdate();
            bookRemoval.close();

        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }


    
    
    /**
     * viewDues method
     *
     * @param membershipId -- the membership id should come from the session
     * object or variable
     *
     * This method views the dues of a membership give the membership ID. It
     * displays the Book id, due for that book, ISBN and title The query
     * contains the join of the Rental and Book table total dues is a variable
     * used to derive the total dues payable by the member
     */
    public List<Rental> viewDues(int membershipId) {

        List<Rental> dues = new ArrayList<Rental>();
        
        try {
            PreparedStatement findDues = getConnection().prepareStatement(
                    "select r.due, r.dueDate, b.* "
                    + "from rental r, book b "
                    + "where r.rents = b.id "
                    + "and rentedBy = ? "
                    + "and r.dueDate < now()"
            );

            findDues.setInt(1, membershipId);
            ResultSet duesResult = findDues.executeQuery();
            
            //iterating through the record set to display due book wise
            while (duesResult.next()) {

                // get the dues and book information
                double dueAmount = duesResult.getDouble("due");
                Date dueDate = duesResult.getDate("dueDate");
                int id = duesResult.getInt("id");
                String isbn = duesResult.getBigDecimal("isbn").toBigInteger().toString();
                String title = duesResult.getString("title");
                String author = duesResult.getString("author");
                String publisher = duesResult.getString("publisher");
                String genre = duesResult.getString("genre");
                
                // the dues object contains a book and the amount due
                Rental due = new Rental();
                due.setDues(dueAmount);
                due.setDueDate(dueDate);
                
                Book book = new Book();
                book.setId(id);
                book.setIsbn(isbn);
                book.setTitle(title);
                book.setAuthor(author);
                book.setPublisher(publisher);
                book.setGenre(genre);
                
                due.setBook(book);
                
                dues.add(due);
            }
            
            duesResult.close();
            findDues.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return dues;
    }

    
    
    /**
     * This method is used to create membership records by servicing requests in
     * the request table. This method is called when the check boxes are
     * selected on "Respond to Requests" screen. and "Accept Selected" is
     * created
     * 
     * @param requestId - This represents the request id of the request which is
     * obtained from "Respond to Requests" screen
     */
    public void acceptSelectedMembershipRequests(int requestId) {
        try {
            Connection conn = getConnection();

            // get the request type
            PreparedStatement getRequestType = conn.prepareStatement(
                    "select * from request where id = ?"
            );
            getRequestType.setInt(1, requestId);
            
            ResultSet request = getRequestType.executeQuery();
            if (request.next()) {
                // get the record values
                String requestor = request.getString("createdBy");
                String address = request.getString("address");
                String phoneNumber = request.getString("phoneNumber");
                String requestType = request.getString("type");
                
                
                // create a new member given the current user's information
                if (requestType.equalsIgnoreCase(RequestType.CREATE.getValue())) {
                    // increment to the next global membership ID
                    int membershipID = ++nextMembershipID;
                    
                    PreparedStatement createMembership = conn.prepareStatement(
                            "insert into member (membershipID, email, phoneNumber, address, password) "
                            + "values (?,?,?,?,?)"
                    );
                    createMembership.setInt(1, membershipID);
                    createMembership.setString(2, requestor);
                    createMembership.setString(3, phoneNumber);
                    createMembership.setString(4, address);
                    createMembership.setString(5, "" + requestor.charAt(0));
                    createMembership.executeUpdate();
                    createMembership.close();
                    
                    //replace these print commands with a status message to the admin that records have been successfully created.
                    System.out.println("created membership: " + membershipID + " " + requestor + " " + address + " " + phoneNumber);
                   
                    // delete the requests from the request table after membership creation
                    deleteRequest(requestId);
                    
                    createMembership.close();
                }
                // delete the requestor from the member table
                else if (requestType.equalsIgnoreCase(RequestType.DELETE.getValue())) {
                    
                    // get the membership ID of the requestor
                    PreparedStatement requestMemberID = conn.prepareStatement(
                            "select * from member where email = ?"
                    );
                    requestMemberID.setString(1, request.getString("createdBy"));
                    ResultSet requestedMemberID = requestMemberID.executeQuery();
                    
                    if (requestedMemberID.next()) {
                        int memberID = requestedMemberID.getInt("membershipID");

                        // use the membership ID to delete rows from the Member table
                        PreparedStatement deleteMembership = conn.prepareStatement(
                                "delete from member where id = ?"
                        );
                        deleteMembership.setInt(1, memberID);

                        // remove the ack'ed request
                        deleteRequest(requestId);

                        deleteMembership.close();
                    }
                    requestMemberID.close();
                }
            }
            
            request.close();
            getRequestType.close();
            conn.close();

        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }

    /**
     * This method is used to delete membership requests in the request table.
     * This method is called when the check boxes are selected on "Respond to
     * Requests" screen and "Reject Selected" button is clicked.
     * 
     * @param requestId - the request to delete
     */
    public void deleteRequest(int requestId) {
        try {
            //if record type is delete fetch all the data from request table for the request id
            //delete the requests from the request table  
            PreparedStatement deleteFromRequest = getConnection().prepareStatement(
                    "delete from request where id = ?"
            );
            deleteFromRequest.setInt(1, requestId);
            deleteFromRequest.executeUpdate();
            deleteFromRequest.close();
                
            //display status message that requests have been rejected.
            System.out.println("Rejected request " + requestId);
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }
    
    
    /**
     * Add a new create membership request using the user-entered information.
     * 
     * @param user
     * @param address
     * @param phoneNumber 
     */
    public void requestMembership(User user, String address, String phoneNumber) {
        createRequest(RequestType.CREATE, user.getName(), user.getEmail(), address, phoneNumber);
    }
    
    /**
     * This method creates an entry in the request table to delete membership.
     * It calls the createRequest method with "delete" request type.
     * 
     * @param member - the member request a deletion
     */
    public void deleteMembership(Member member) {
        createRequest(RequestType.DELETE,
                      member.getName(),
                      member.getEmail(), 
                      member.getAddress(), 
                      member.getPhoneNumber());
    }

    
    /**
     * Get a list of all create/delete membership requests.
     * 
     * @return all create/delete membership requests
     */
    public List<Request> viewRequests() {
        
        List<Request> requests = new ArrayList<Request>();
        
        try {
            PreparedStatement getRequests = getConnection().prepareStatement(
                    "select * from request"
            );
            ResultSet requestResults = getRequests.executeQuery();
            
            // loop through the results, adding each item to the list
            while (requestResults.next()) {
                int id = requestResults.getInt("id");
                String createdBy = requestResults.getString("createdBy");
                String address = requestResults.getString("address");
                String phoneNumber = requestResults.getString("phoneNumber");
                String type = requestResults.getString("type");
                
                Request r = new Request();
                r.setId(id);
                r.setRequestor(createdBy);
                r.setType(type);
                r.setAddress(address);
                r.setPhoneNumber(phoneNumber);
                
                requests.add(r);
            }
        
            requestResults.close();
            getRequests.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
     
        return requests;
    }
    
    
    /**
     * Determine if the given user has already submitted a create membership request.
     * 
     * @param email - the email of the current user
     * @return true iff a "create" request record exists for this year
     */
    public boolean hasCreateMembershipRequest(String email) {
        return hasMembershipRequest(RequestType.CREATE, email);
    }
    
    /**
     * Determine if the given user has already submitted a delete membership request.
     * 
     * @param email - the email of the current user
     * @return true iff a "delete" request record exists for this year
     */
    public boolean hasDeleteMembershipRequest(String email) {
        return hasMembershipRequest(RequestType.DELETE, email);
    }
    
    
    /**
     * Determine if there exists a request of the specified type associated with
     * the given email address.
     * 
     * @param requestType
     * @param email
     * @return true iff there exists a record for the given email with the specified type
     */
    private boolean hasMembershipRequest(RequestType requestType, String email) {
        boolean hasMembershipRequest = false;
        
        try {
            PreparedStatement hasMembershipQuery = getConnection().prepareStatement(
                    "select count(*) as n from request "
                    + "where createdby = ? "
                    + "and type = ?"
            );
            hasMembershipQuery.setString(1, email);
            hasMembershipQuery.setString(2, requestType.getValue());
            
            ResultSet hasMembershipResult = hasMembershipQuery.executeQuery();
            if (hasMembershipResult.next()) {
                int n = hasMembershipResult.getInt("n");
                hasMembershipRequest = (n > 0);
            }
            
            hasMembershipResult.close();
            hasMembershipQuery.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return hasMembershipRequest;
    }
    
    
    /**
     * Get the current checked out books for the given Member email address.
     * 
     * @param memberEmail - the member to search by
     * @return the rentals associated with the given Member
     */
    public Member findMemberByEmail(String memberEmail) {
        
        Member member = null;
        
        try {
            // get the member ID for the given member email
            PreparedStatement getMemberByEmail = getConnection().prepareStatement(
                    "select * from member where email = ?"
            );
            getMemberByEmail.setString(1, memberEmail);
            
            ResultSet memberResult = getMemberByEmail.executeQuery();
            if (memberResult.first()) {
                int memberID = memberResult.getInt("membershipID");
                String email = memberResult.getString("email");
                String phoneNumber = memberResult.getString("phoneNumber");
                String address = memberResult.getString("address");
                
                member = new Member();
                member.setMemberID(memberID);
                member.setEmail(email);
                member.setPhoneNumber(phoneNumber);
                member.setAddress(address);
            }
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return member;
    }
    
    /**
     * This method displays the books checked out by a member
     * 
     * @param member - the member for whom to find checked out books
     * @return the list of books currently checked out by this member
     */
    public List<Rental> viewCurrentCheckedOutBooks(Member member) {
        
        List<Rental> checkedOutBooks = new ArrayList<Rental>();
        int membershipId = member.getMemberID();
        
        try {
            PreparedStatement checkedBooks = getConnection().prepareStatement(
                    "select r.due, r.dueDate, b.* "
                    + "from rental r, book b "
                    + "where r.rents = b.id "
                    + "and rentedBy = ? "
                    + "order by r.dueDate asc"
            );
            checkedBooks.setInt(1, membershipId);
            ResultSet books = checkedBooks.executeQuery();
            
            while (books.next()) {
                double due = books.getDouble("due");
                Date dueDate = books.getDate("dueDate");
                int id = books.getInt("id");
                String isbn = books.getString("isbn");
                String title = books.getString("title");
                String author = books.getString("author");
                String publisher = books.getString("publisher");
                String genre = books.getString("genre");
                
                Rental rental = new Rental();
                rental.setDues(due);
                rental.setDueDate(dueDate);
                
                Book book = new Book();
                book.setId(id);
                book.setIsbn(isbn);
                book.setTitle(title);
                book.setAuthor(author);
                book.setPublisher(publisher);
                book.setGenre(genre);
                rental.setBook(book);
                
                checkedOutBooks.add(rental);
            }
            
            books.close();
            checkedBooks.close();
            
            System.out.println("memID " + membershipId + " checked out " + checkedOutBooks.size() + " books");
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return checkedOutBooks;
    }

    
    /**
     * Allows a librarian to add a Book. This method automatically calculates
     * "numCopies" field of the book being added, and updates all other books'
     * "numCopies" that share its ISBN
     *
     * @param book - the book to add
     */
    public void addBook(Book book) {
        int numCopies = 0;

        try {
            Connection conn = getConnection();
            
            //first get the number of copies of the book that currently exist
            PreparedStatement findNumCopies = conn.prepareStatement(
                    "select count(*) from book b where b.ISBN=?");
            findNumCopies.setString(1, book.getIsbn());
            ResultSet rs = findNumCopies.executeQuery();

            while (rs.next()) {
                numCopies = rs.getInt("count(*)");
            }
            numCopies++;
            
            rs.close();
            findNumCopies.close();

            //Now add the book:
            PreparedStatement addBook = conn.prepareStatement(
                    "insert into book (ISBN, title, author, publisher, genre,"
                    + " numCopies) values (?, ?, ?, ?, ?, ?)");
            addBook.setString(1, book.getIsbn());
            addBook.setString(2, book.getTitle());
            addBook.setString(3, book.getAuthor());
            addBook.setString(4, book.getPublisher());
            addBook.setString(5, book.getGenre());
            addBook.setInt(6, numCopies);
            
            System.out.println("adding: " + book);
            addBook.executeUpdate();
            addBook.close();

            //Finally, update the numCopies of the other books with that ISBN
            PreparedStatement updateBooks = conn.prepareStatement(
                    "update book b set b.numCopies=? where b.ISBN=?");
            updateBooks.setInt(1, numCopies);
            updateBooks.setString(2, book.getIsbn());
            updateBooks.executeUpdate();
            updateBooks.close();
            
            conn.close();

        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }

    /**
     * Updates the book record with the given bookID.
     *
     * @param book - the book to update
     */
    public void updateBook(Book book) {
        
        try {

            PreparedStatement updateBook = getConnection().prepareStatement(
                    "update book b set b.ISBN=?, b.title=?, b.author=?, "
                    + "b.publisher=?, b.genre=? where b.id=?");
            updateBook.setString(1, book.getIsbn());
            updateBook.setString(2, book.getTitle());
            updateBook.setString(3, book.getAuthor());
            updateBook.setString(4, book.getPublisher());
            updateBook.setString(5, book.getGenre());
            updateBook.setInt(6, book.getId());
        
            System.out.println("updating: " + book);
            updateBook.executeUpdate();
            updateBook.close();

        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }

    /**
     * Delete the book with the given bookID. Also updates the numCopies of all
     * other books that share its ISBN to be one less than their current value
     *
     * @param bookID - the id of the book to be deleted
     */
    public void deleteBook(int bookID) {
        int numCopies = 0;

        try {
            Connection conn = getConnection();
            
            String isbn = "";
            //first get the book ID's ISBN number:
            PreparedStatement findISBN = conn.prepareStatement(
                    "select b.ISBN from book b where b.id=?");
            findISBN.setInt(1, bookID);
            ResultSet rs = findISBN.executeQuery();
            while (rs.next()) {
                isbn = rs.getString("ISBN");
            }
            
            rs.close();
            findISBN.close();

            //Now, count the number of books with that ISBN:
            PreparedStatement findNumCopies = conn.prepareStatement(
                    "select count(*) from book b where b.ISBN=?");
            findNumCopies.setString(1, isbn);
            rs = findNumCopies.executeQuery();
            while (rs.next()) {
                numCopies = rs.getInt("count(*)");
            }
            rs.close();
            findNumCopies.close();

            //Now delete the book
            PreparedStatement deleteBook = conn.prepareStatement(
                    "delete from book where id=?");
            deleteBook.setInt(1, bookID);
            deleteBook.executeUpdate();
            deleteBook.close();
            numCopies--;

            //Now update the numCopies of other books that may have had its ISBN
            PreparedStatement updateBooks = conn.prepareStatement(
                    "update book b set b.numCopies=? where b.ISBN=?");
            updateBooks.setInt(1, numCopies);
            updateBooks.setString(2, isbn);
            System.out.println("deleting book " + isbn + " (" + numCopies + " copies remain)");
            updateBooks.executeUpdate();
            updateBooks.close();
            
            conn.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }

        
    /**
     * Create Rental entries assigned to the given Member.
     * 
     * @param memberEmail
     * @param rentals 
     * @return an indication whether the query ran successfully or not (include message if unsuccessful)
     */
    public QueryResult createRentals(String memberEmail, List<Rental> rentals) {
        QueryResult result = new QueryResult();
        
        try {
            Connection conn = getConnection();
            conn.setAutoCommit(false); // makes this connection a transaction
            
            // get the membership ID for the given email
            PreparedStatement getMemberID = conn.prepareStatement(
                    "select membershipID from member where email = ?"
            );
            getMemberID.setString(1, memberEmail);
            ResultSet memberIDResult = getMemberID.executeQuery();
            
            // proceed only if a member ID exists for the given email
            if (!memberIDResult.next()) {
                result.setQuerySuccessful(false);
                result.addMessage("Member email \"" + memberEmail + "\" not found");
            } else {
                // the membership ID corresponding to the given email address
                int memberID = memberIDResult.getInt("membershipID");
            
                
                // for each Rental:
                // 1. check for uniqueness
                // 2. insert a record for each Rental object
                // 3. reduce the number of copies of the book by 1
                
                // prepare the uniqueness check
                PreparedStatement checkDuplicates = conn.prepareStatement(
                        "select (count(*) > 0) as rentalExists from rental "
                        + "where rentedBy = ? "
                        + "and rents = ? "
                        + "and dueDate > now()"
                );
                
                // prepare the insert statement
                PreparedStatement insertRental = conn.prepareStatement(
                        "insert into rental values (?, ?, ?, ?, ?)"
                );
                
                // prepare the inventory statements
                PreparedStatement getNumCopies = conn.prepareStatement(
                        "select numCopies from Book where id = ?"
                );
                PreparedStatement removeCopy = conn.prepareStatement(
                        "update Book "
                        + "set numCopies = numCopies - 1 "
                        + "where id = ?"
                );
                

                for (Rental rental : rentals) {
                    int bookID = rental.getBook().getId();
                    
                    // ensure the member does not already have a rental for this book
                    boolean hasExistingRental = false;
                    checkDuplicates.setInt(1, memberID);
                    checkDuplicates.setInt(2, bookID);
                    ResultSet checkDuplicatesResult = checkDuplicates.executeQuery();
                    if (checkDuplicatesResult.next()) {
                        int rentalExists = checkDuplicatesResult.getInt("rentalExists");
                        
                        // 0 is false, 1 is true
                        if (rentalExists == 1) {
                            hasExistingRental = true;
                            result.setQuerySuccessful(false);
                            result.addMessage("\nMember \"" + memberEmail + "\" already has a rental for book \n-- " + rental.getBook());
                            System.out.println(result.getMessage());
                        }
                    }
                    checkDuplicatesResult.close();
                    
                    
                    if (!hasExistingRental) {
                        // get the current number of copies for the given book
                        getNumCopies.setInt(1, bookID);
                        ResultSet numCopiesResult = getNumCopies.executeQuery();

                        if (numCopiesResult.next()) {
                            int numCopies = numCopiesResult.getInt("numCopies");

                            // at least one copy is available
                            if (numCopies > 0) {
                                insertRental.setInt(1, memberID);
                                insertRental.setInt(2, bookID);
                                insertRental.setDate(3, new Date(System.currentTimeMillis()));
                                insertRental.setDate(4, new Date(rental.getDueDate().getTime()));
                                insertRental.setDouble(5, rental.getDues());


                                // insert the rental
                                insertRental.executeUpdate();

                                // remove the old copy
                                removeCopy.setInt(1, bookID);
                                removeCopy.executeUpdate();
                            }
                            // no copies available
                            else {
                                result.setQuerySuccessful(false);
                                result.addMessage("No copies available for book \n-- " + rental.getBook());
                                System.out.println(result.getMessage());
                            }
                        }
                        
                        numCopiesResult.close();
                    }
                }
                
                checkDuplicates.close();
                removeCopy.close();
                getNumCopies.close();
                insertRental.close();
            }
            
            memberIDResult.close();
            getMemberID.close();
            
            // execute the transaction if there were no errors, otherwise rollback
            if (result.isQuerySuccessful()) {
                conn.commit();
            } else {
                conn.rollback();
            }
            conn.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        
        return result;
    }
    
    
    /**
     * Remove the rentals for the given member and book pairings.
     * 
     * @param memberID - the member renting the book
     * @param bookID - the book rented by the member
     */
    public void removeRental(int memberID, int bookID) {
        try {
            Connection conn = getConnection();
            
            PreparedStatement removeRental = conn.prepareStatement(
                    "delete from rental where rentedBy = ? and rents = ?"
            );
            removeRental.setInt(1, memberID);
            removeRental.setInt(2, bookID);
            removeRental.executeUpdate();
            removeRental.close();
            
            // add a book back to the available inventory
            PreparedStatement countBook = conn.prepareStatement(
                    "select numCopies from book where id = ?"
            );
            countBook.setInt(1, bookID);
            ResultSet countBookResults = countBook.executeQuery();
            if (countBookResults.first()) {
                int numCopies = countBookResults.getInt("numCopies") + 1;
                
                PreparedStatement addBook = conn.prepareStatement(
                        "update book set numCopies = ? where id = ?"
                );
                addBook.setInt(1, numCopies);
                addBook.setInt(2, bookID);
                addBook.executeUpdate();
                addBook.close();
            }
            
            countBookResults.close();
            countBook.close();
            conn.close();
            
        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            ex.printStackTrace();
        }
    }
}
