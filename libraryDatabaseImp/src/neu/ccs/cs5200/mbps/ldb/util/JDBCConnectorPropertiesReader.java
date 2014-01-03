package neu.ccs.cs5200.mbps.ldb.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.logging.Level;
import neu.ccs.cs5200.mbps.ldb.jdbc.JDBCProperties;

/**
 * A class for reading in the JDBC connection properties from XML. 
 */
public class JDBCConnectorPropertiesReader
{
    // the attributes and elements we expect in the JDBC properties file
    private static final String DRIVER_TYPE = "driver";
    private static final String URL         = "url";
    private static final String USERNAME    = "username";
    private static final String PASSWORD    = "password";
    
    
    
    // a private constructor allows us to control when objects are instantiated,
    // which allows us to enforce a singleton model
    private JDBCConnectorPropertiesReader() {}
    
    
    /**
     * A class for holding the JDBCConnectorPropertiesReader singleton.
     */
    private static class JDBCConnectorPropertiesReaderInstanceHolder
    {
        private static JDBCConnectorPropertiesReader INSTANCE = new JDBCConnectorPropertiesReader();
    }
    
    
    /**
     * @return the object for reading JDBC connector properties
     */
    public static JDBCConnectorPropertiesReader getInstance()
    {
        return JDBCConnectorPropertiesReaderInstanceHolder.INSTANCE;
    }
    
 
    /**
     * Get the JDBC options from the properties file.
     * 
     * @param propsPath - the path of the properties file
     * @return an object the JDBC connection information
     */
    public JDBCProperties readJDBCPropertiesFromFile(String propsPath)
    {
        Properties props = new Properties();
        try {
            FileInputStream fis = new FileInputStream(new File(propsPath));
            props.load(fis);
        } catch (IOException ex) {
            java.util.logging.Logger.getLogger(JDBCConnectorPropertiesReader.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        JDBCProperties jdbcProps = new JDBCProperties();
        jdbcProps.setDriver(props.getProperty(DRIVER_TYPE));
        jdbcProps.setUrl(props.getProperty(URL));
        jdbcProps.setUsername(props.getProperty(USERNAME));
        jdbcProps.setPassword(props.getProperty(PASSWORD));
        
        return jdbcProps;
    }
}
