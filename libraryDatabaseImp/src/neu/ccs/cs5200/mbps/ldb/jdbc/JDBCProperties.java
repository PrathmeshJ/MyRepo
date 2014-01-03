package neu.ccs.cs5200.mbps.ldb.jdbc;

/**
 * A bean for holding JDBC connection properties.
 */
public class JDBCProperties
{
    private String driver;
    private String url;
    private String username;
    private String password;
    

    public String getDriver()
    {
        return driver;
    }

    public void setDriver(String driver)
    {
        this.driver = driver;
    }

    public String getUrl()
    {
        return url;
    }

    public void setUrl(String url)
    {
        this.url = url;
    }

    public String getUsername()
    {
        return username;
    }

    public void setUsername(String username)
    {
        this.username = username;
    }

    public String getPassword()
    {
        return password;
    }

    public void setPassword(String password)
    {
        this.password = password;
    }
}
