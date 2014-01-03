CREATE DATABASE  IF NOT EXISTS `library_database` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `library_database`;
-- MySQL dump 10.13  Distrib 5.6.11, for Win32 (x86)
--
-- Host: localhost    Database: library_database
-- ------------------------------------------------------
-- Server version	5.6.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `administrator`
--

DROP TABLE IF EXISTS `administrator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `administrator` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employeeID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employeeID` (`employeeID`),
  CONSTRAINT `administrator_ibfk_1` FOREIGN KEY (`employeeID`) REFERENCES `employee` (`employeeID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administrator`
--

LOCK TABLES `administrator` WRITE;
/*!40000 ALTER TABLE `administrator` DISABLE KEYS */;
INSERT INTO `administrator` VALUES (1,1),(2,4);
/*!40000 ALTER TABLE `administrator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ISBN` bigint(20) NOT NULL,
  `title` varchar(100) NOT NULL,
  `author` varchar(50) NOT NULL,
  `publisher` varchar(100) NOT NULL,
  `genre` enum('fiction','history','medicine','news','nonfiction','politics','religion','romance','science','scienceFiction') DEFAULT NULL,
  `numCopies` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=384 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` VALUES (257,9780141439471,'Frankenstein (Penguin Classics)','Mary Shelley','Penguin Books Ltd','fiction',1),(258,9780441788385,'Stranger in a Strange Land','Robert A. Heinlein','Ace Trade','fiction',1),(259,9780553803709,'I, Robot','Isaac Asimov','Spectra','fiction',1),(260,9780930289232,'Watchmen','Alan Moore','DC Comics','fiction',1),(261,9780345418265,'The Princess Bride ','William Goldman','Ballantine Books (Ballantine Reader\'s Circle)','fiction',1),(262,9780060929879,'Brave New World','Aldous Huxley','Harper Perennial','fiction',1),(263,9780007491568,'Fahrenheit 451','Ray Bradbury','Harper Voyager','fiction',1),(264,9780553588484,'A Game of Thrones (A Song of Ice and Fire, #1)','George R.R. Martin','Bantam Spectra','fiction',1),(265,9781937007744,'Endgame (Sirantha Jax, #6)','Ann Aguirre','Ace','fiction',1),(266,9780756406974,'Alien Proliferation (Katherine \"Kitty\" Katt, #4)','Gini Koch','DAW','fiction',1),(267,9780441020713,'Blue Remembered Earth (Poseidon\'s Children, #1)','Alastair Reynolds','Ace Books','fiction',1),(268,9781451638455,'Captain Vorpatril\'s Alliance (Vorkosigan Saga, #15)','Lois McMaster Bujold','Baen','fiction',1),(269,9780345453747,'The Ultimate Hitchhiker\'s Guide to the Galaxy (Hitchhiker\'s Guide to the Galaxy, #1-5)','Douglas Adams','Del Rey/Ballantine Books','fiction',1),(270,9780618346257,'The Fellowship of the Ring (The Lord of the Rings, #1)','J.R.R. Tolkien','Houghton Mifflin Harcourt','fiction',1),(271,9781416599074,'Drop Dead Healthy: One Man\'s Humble Quest for Bodily Perfection','A.J. Jacobs','Simon & Schuster','fiction',1),(272,9781449410247,'How to Tell If Your Cat Is Plotting to Kill You','Matthew Inman','Andrews McMeel Publishing','fiction',1),(273,9781451608120,'Trail of the Spellmans (The Spellmans, #5)','Lisa Lutz','Simon & Schuster','fiction',1),(274,9780062113382,'I Suck at Girls','Justin Halpern','It Books','fiction',1),(275,9780805095838,'Most Talkative: Stories from the Front Lines of Pop Culture','Andy Cohen','Henry Holt and Co.','fiction',1),(276,9780316204279,'Where\'d You Go, Bernadette','Maria Semple','Little, Brown and Company','fiction',1),(277,9781592406890,'Tough Shit: Life Advice from a Fat, Lazy Slob Who Did Good','Kevin Smith','Gotham','fiction',1),(278,9781452106557,'Darth Vader and Son','Jeffrey Brown','Chronicle Books','fiction',1),(279,9781780334837,'Weird Things Customers Say in Bookshops ','Jen Campbell','Constable and Robinson','history',1),(280,9780062124296,'How to Be a Woman','Caitlin Moran','Harper Perennial','history',1),(281,9781455523429,'I am a Pole (And So Can You!)','Stephen Colbert','Grand Central Publishing','history',1),(282,9780399159015,'Let\'s Pretend This Never Happened: A Mostly True Memoir','Jenny  Lawson','Amy Einhorn: Putnam','history',1),(283,9780316010665,'Blink: The Power of Thinking without Thinking','Malcolm Gladwell','Back Bay Books','history',1),(284,9781451648539,'Steve Jobs','Walter Isaacson','Simon & Schuster','history',1),(285,9780785820451,'Out of My Later Years Through His Own Words','Albert Einstein','Castle Books','history',1),(286,9780425179871,'Failure is not an Option: Mission Control From Mercury to Apollo 13 and Beyond','Gene Kranz','Berkley Trade','history',1),(287,9780805091250,'The Believing Brain: From Ghosts and Gods to Politics and Conspiracies How We Construct Beliefs and ','Michael Shermer','Times Books','history',1),(288,9780061719516,'The Clockwork Universe: Isaac Newton, the Royal Society, and the Birth of the Modern World','Edward Dolnick','Harper','history',1),(289,9780785819110,'The Origin of Species','Charles Darwin','Castle Books','history',1),(290,9780140277449,'The Rape of Nanking','Iris Chang','Penguin Books','history',1),(291,9780743477888,'Undaunted Courage: The Pioneering First Mission to Explore America\'s Wild Frontier','Stephen E. Ambrose','Simon & Schuster','history',1),(292,9780671869205,'Truman','David McCullough','Simon & Schuster','history',1),(293,9780195168952,'Battle Cry of Freedom: The Civil War Era','James M. McPherson','Oxford University Press, USA','nonfiction',1),(294,9780671728687,'The Rise and Fall of the Third Reich: A History of Nazi Germany','William L. Shirer','Simon & Schuster','nonfiction',1),(295,9780743270755,'Team of Rivals: The Political Genius of Abraham Lincoln','Doris Kearns Goodwin','Simon & Schuster','nonfiction',1),(296,9780743223133,'John Adams','David McCullough','Simon & Schuster Paperbacks','nonfiction',1),(297,9781630350024,'The Arrangement 11 (The Arrangement, #11)','H.M. Ward','Laree Bailey Press','nonfiction',1),(298,9781594480003,'The Kite Runner','Khaled Hosseini','Riverhead Books','nonfiction',1),(299,9780385732550,'The Giver (The Giver Quartet, #1)','Lois Lowry','Ember','nonfiction',1),(300,9780140283334,'Lord of the Flies','William Golding','Penguin Books ','nonfiction',1),(301,9780743477116,'Romeo and Juliet','William Shakespeare','Washington Square Press','nonfiction',1),(302,9780066238500,'The Chronicles of Narnia (Chronicles of Narnia #1-7)','C.S. Lewis','HarperCollins','nonfiction',1),(303,9780743273565,'The Great Gatsby','F. Scott Fitzgerald','Scribner','nonfiction',1),(304,9780618260300,'The Hobbit','J.R.R. Tolkien','Houghton Mifflin','nonfiction',1),(305,9780156012195,'The Little Prince','Antoine de Saint-Exup','Harcourt, Inc.','nonfiction',1),(306,9780452284241,'Animal Farm','George Orwell','Plume','nonfiction',1),(307,9780330107372,'The Diary of Anne Frank','Anne Frank','Macmillan General Books','nonfiction',1),(308,9780679783268,'Pride and Prejudice','Jane Austen','Modern Library','nonfiction',1),(309,9780061120084,'To Kill a Mockingbird','Harper Lee','Harper Perennial Modern Classics','nonfiction',1),(310,9780812550702,'Ender\'s Game (Ender\'s Saga, #1)','Orson Scott Card','Tor Science Fiction','nonfiction',1),(311,9780156010863,'The Seven Storey Mountain','Thomas Merton','Mariner Books','nonfiction',1),(312,9780807014295,'Man\'s Search for Meaning','Viktor E. Frankl','Beacon Press','nonfiction',1),(313,9780385483711,'God Has a Dream: A Vision of Hope for Our Time','Desmond Tutu','Image','nonfiction',1),(314,9780553208849,'Siddhartha','Hermann Hesse','Bantam Books','nonfiction',1),(315,9780061122415,'The Alchemist','Paulo Coelho','HarperCollins','nonfiction',1),(316,9780062023179,'The Screwtape Letters: Annotated Edition','C.S. Lewis','HarperOne','nonfiction',1),(317,9781579126278,'The Murder of Roger Ackroyd (Hercule Poirot, #4)','Agatha Christie','Black Dog & Leventhal Publishers','nonfiction',1),(318,9780553328257,'The Complete Sherlock Holmes','Arthur Conan Doyle','Bantam Classics','nonfiction',1),(319,9780061043499,'Gaudy Night (Lord Peter Wimsey Mysteries, #12)','Dorothy L. Sayers','HarperTorch','nonfiction',1),(320,9780743442534,'The Spy Who Came In from the Cold (George Smiley #3)','John le Carr','Scribner','nonfiction',1),(321,9780394758282,'The Big Sleep (Philip Marlowe, #1)','Raymond Chandler','Vintage Crime','nonfiction',1),(322,9780684803869,'The Daughter of Time (Inspector Alan Grant #5)','Josephine Tey','Touchstone','nonfiction',1),(323,9780544217621,'Johnny Carson','Henry Bushkin','Eamon Dolan/Houghton Mifflin Harcourt','nonfiction',1),(324,9780805098556,'Killing Jesus: A History','Bill O\'Reilly','Henry Holt and Co.','nonfiction',1),(325,9781592289806,'From Baghdad, With Love: A Marine, the War, and a Dog Named Lava','Jay Kopelman','Lyons Press','nonfiction',1),(326,9780307336798,'The Art of Simple Food: Notes, Lessons, and Recipes from a Delicious Revolution','Alice Waters','Clarkson Potter','nonfiction',1),(327,9780938497301,'Simple Sourdough: Make Your Own Starter Without Store-Bought Yeast and Bake the Best Bread in the Wo','Mark Shepard','Shepard Publications','nonfiction',1),(328,9781623150242,'The DASH Diet Health Plan: Low-Sodium, Low-Fat Recipes to Promote Weight Loss, Lower Blood Pressure,','John Chatham','Rockridge University Press ','nonfiction',1),(329,9780316735506,'Eat to Live: The Revolutionary Formula for Fast and Sustained Weight Loss','Joel Fuhrman','Little, Brown and Company','nonfiction',1),(330,9780061251344,'Deceptively Delicious: Simple Secrets To Get Your Kids Eating Good Foods','Jessica Seinfeld','Collins','nonfiction',1),(331,9780061658198,'The Pioneer Woman Cooks: Recipes from an Accidental Country Girl','Ree Drummond','William Morrow Cookbooks','nonfiction',1),(332,9781416552505,'Speaks the Nightbird (Matthew Corbett #1)','Robert R. McCammon','Gallery Books','nonfiction',1),(333,9781847442765,'Accused','Mark Gimenez','Sphere','nonfiction',1),(334,9780143123231,'The Silent Wife','A.S.A. Harrison','Penguin Books','nonfiction',1),(335,9781448108534,'Unlucky 13','James Patterson','Cornerstone Digital','nonfiction',1),(336,9780385344340,'Never Go Back (Jack Reacher, #18)','Lee Child','Delacorte Press','nonfiction',1),(337,9780316253017,'An Astronaut\'s Guide to Life on Earth: What Going to Space Taught Me About Ingenuity, Determination,','Chris Hadfield','Little, Brown and Company','nonfiction',1),(338,9781250040152,'My Story','Elizabeth  Smart','St. Martin\'s Press','nonfiction',1),(339,9780374500016,'Night  (The Night Trilogy, #1)','Elie Wiesel','Hill and Wang','nonfiction',1),(340,9780316322409,'I Am Malala: The Girl Who Stood Up for Education and Was Shot by the Taliban','Malala Yousafzai','Little, Brown and Company','nonfiction',2),(341,9780451528643,'The Adventures of Tom Sawyer/Adventures of Huckleberry Finn','Mark Twain','Signet Classics','nonfiction',3),(342,9780316322409,'I Am Malala: The Girl Who Stood Up for Education and Was Shot by the Taliban','Malala Yousafzai','Little, Brown and Company','nonfiction',2),(343,9780451528643,'The Adventures of Tom Sawyer/Adventures of Huckleberry Finn','Mark Twain','Signet Classics','nonfiction',3),(344,9780451528643,'The Adventures of Tom Sawyer/Adventures of Huckleberry Finn','Mark Twain','Signet Classics','nonfiction',3);
update book set numCopies = (select floor(1 + (rand(1) * 20)));
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee` (
  `employeeID` int(11) NOT NULL,
  `memberID` int(11) NOT NULL,
  PRIMARY KEY (`employeeID`),
  KEY `memberID` (`memberID`),
  CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`memberID`) REFERENCES `member` (`membershipID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,1),(2,2),(3,4),(4,5);
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `librarian`
--

DROP TABLE IF EXISTS `librarian`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `librarian` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employeeID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employeeID` (`employeeID`),
  CONSTRAINT `librarian_ibfk_1` FOREIGN KEY (`employeeID`) REFERENCES `employee` (`employeeID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `librarian`
--

LOCK TABLES `librarian` WRITE;
/*!40000 ALTER TABLE `librarian` DISABLE KEYS */;
INSERT INTO `librarian` VALUES (1,2),(2,3);
/*!40000 ALTER TABLE `librarian` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member` (
  `membershipID` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phoneNumber` varchar(15) NOT NULL,
  `address` varchar(100) NOT NULL,
  `password` varchar(50) NOT NULL,
  PRIMARY KEY (`membershipID`),
  KEY `email` (`email`),
  CONSTRAINT `member_ibfk_1` FOREIGN KEY (`email`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,'admin@ldb.com','611','1 LDB St','a'),(2,'librarian@ldb.com','411','2 LDB St','l'),(3,'member@ldb.com','311','3 LDB St','m'),(4,'bob@test.com','4','4','b'),(5,'ed@test.com','5','5','e'),(6,'joe@test.com','6','6','j'),(7,'dan@test.com','7','7','d'),(8,'ben@test.com','8','8','b');
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental`
--

DROP TABLE IF EXISTS `rental`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rental` (
  `rentedBy` int(11) NOT NULL,
  `rents` int(11) NOT NULL,
  `startDate` date NOT NULL,
  `dueDate` date NOT NULL,
  `due` double DEFAULT NULL,
  PRIMARY KEY (`rentedBy`,`rents`),
  KEY `rents` (`rents`),
  CONSTRAINT `rental_ibfk_1` FOREIGN KEY (`rentedBy`) REFERENCES `member` (`membershipID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `rental_ibfk_2` FOREIGN KEY (`rents`) REFERENCES `book` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental`
--

LOCK TABLES `rental` WRITE;
/*!40000 ALTER TABLE `rental` DISABLE KEYS */;
/*!40000 ALTER TABLE `rental` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `request`
--

DROP TABLE IF EXISTS `request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address` varchar(100) NOT NULL,
  `createdBy` varchar(100) NOT NULL,
  `phoneNumber` varchar(15) DEFAULT NULL,
  `type` enum('create','delete') DEFAULT NULL,
  `servicedBy` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `createdBy` (`createdBy`),
  KEY `servicedBy` (`servicedBy`),
  CONSTRAINT `request_ibfk_1` FOREIGN KEY (`createdBy`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `request_ibfk_2` FOREIGN KEY (`servicedBy`) REFERENCES `administrator` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `request`
--

LOCK TABLES `request` WRITE;
/*!40000 ALTER TABLE `request` DISABLE KEYS */;
INSERT INTO `request` VALUES (1,'4','sathya@test.com','4','create',null);
/*!40000 ALTER TABLE `request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES ('admin','admin@ldb.com'),('librarian','librarian@ldb.com'),('member','member@ldb.com'),('ben','ben@test.com'),('bob','bob@test.com'),('dan','dan@test.com'),('ed','ed@test.com'),('joe','joe@test.com'),('sathya','sathya@test.com');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlist`
--

DROP TABLE IF EXISTS `wishlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wishlist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `belongsTo` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `belongsTo` (`belongsTo`),
  CONSTRAINT `wishlist_ibfk_1` FOREIGN KEY (`belongsTo`) REFERENCES `member` (`membershipID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlist`
--

LOCK TABLES `wishlist` WRITE;
/*!40000 ALTER TABLE `wishlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `wishlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlistbook`
--

DROP TABLE IF EXISTS `wishlistbook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wishlistbook` (
  `belongsTo` int(11) NOT NULL,
  `hasBook` int(11) NOT NULL,
  PRIMARY KEY (`belongsTo`,`hasBook`),
  KEY `hasBook` (`hasBook`),
  CONSTRAINT `wishlistbook_ibfk_1` FOREIGN KEY (`belongsTo`) REFERENCES `wishlist` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `wishlistbook_ibfk_2` FOREIGN KEY (`hasBook`) REFERENCES `book` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlistbook`
--

LOCK TABLES `wishlistbook` WRITE;
/*!40000 ALTER TABLE `wishlistbook` DISABLE KEYS */;
/*!40000 ALTER TABLE `wishlistbook` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-11-09 10:33:21
