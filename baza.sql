-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: kalendar
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `desavanja`
--
use kalendar;
DROP TABLE IF EXISTS `desavanja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `desavanja` (
  `desavanjaID` int NOT NULL AUTO_INCREMENT,
  `IDUsera` int DEFAULT NULL,
  `naslov` varchar(50) DEFAULT NULL,
  `opis` varchar(600) DEFAULT NULL,
  `celodnevni` tinyint(1) DEFAULT NULL,
  `datum` date DEFAULT NULL,
  `odTime` time DEFAULT NULL,
  `gotov` tinyint(1) DEFAULT NULL,
  `kreiran` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `doTime` time DEFAULT NULL,
  `kategD` int DEFAULT '1',
  PRIMARY KEY (`desavanjaID`),
  KEY `fkUser` (`IDUsera`),
  KEY `fkKategD` (`kategD`),
  CONSTRAINT `fkKategD` FOREIGN KEY (`kategD`) REFERENCES `kategorije` (`kategID`),
  CONSTRAINT `fkUser` FOREIGN KEY (`IDUsera`) REFERENCES `user` (`userID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `desavanja`
--

LOCK TABLES `desavanja` WRITE;
/*!40000 ALTER TABLE `desavanja` DISABLE KEYS */;
INSERT INTO `desavanja` VALUES (31,1,'Darkov rodjendan','Cestitaj mu rodjendan i smisli sta ces da mu poklonis\n',1,'2025-01-10','00:00:00',NULL,'2025-01-14 12:43:30','00:00:00',1),(32,1,'Predaja projekta za .NET','Predaj .NET projekat',1,'2025-01-23','00:00:00',NULL,'2025-01-14 12:43:51','00:00:00',1),(33,1,'Predaj projekte za KSS i Web programiranje','',1,'2025-02-02','00:00:00',NULL,'2025-01-14 12:45:52','00:00:00',9),(34,16,'Random desavanje','Moj tekstualni opis nasumicnog desavanja',0,'2025-02-05','17:34:00',NULL,'2025-01-14 16:32:06','23:32:00',1),(35,16,'Novo desanje','Novo celodnvno desavnje\n',1,'2025-02-19','00:00:00',NULL,'2025-01-14 16:33:06','00:00:00',1),(36,1,'KSS ispit','Položio sam teorisjki deo',0,'2025-01-23','08:00:00',NULL,'2025-01-18 00:21:09','15:00:00',1),(37,1,'.NET ispit','Dobio sam 10',0,'2025-01-24','08:00:00',NULL,'2025-01-18 00:21:37','15:00:00',1),(38,1,'Web Programiranje','Kupi dvolisnicu za ispit iz engleskog koji je sutradan, OBAVEZNO.',0,'2025-01-27','15:00:00',NULL,'2025-01-18 00:22:18','17:00:00',9),(39,1,'Engleski ispit','',0,'2025-01-28','12:00:00',NULL,'2025-01-18 00:22:35','14:00:00',9),(42,1,'Proba kategorije','Prvi test dodavanja kategorije.\nDrugi test  izmene kategorije.',0,'2025-01-10','00:00:00',NULL,'2025-01-24 14:54:30','00:00:00',7),(43,1,'Odbrana KSS i Web Programiranja','',0,'2025-02-03','08:00:00',NULL,'2025-01-27 02:55:55','15:00:00',9),(44,1,'Example','',1,'2025-02-04','00:00:00',NULL,'2025-02-01 18:02:33','00:00:00',7),(46,1,'Example','Example event',0,'2025-02-06','13:00:00',NULL,'2025-02-01 18:12:01','15:00:00',11),(47,16,'New event','',0,'2025-02-06','17:00:00',NULL,'2025-02-01 19:46:13','18:00:00',14),(48,16,'New event','',1,'2025-03-06','00:00:00',NULL,'2025-02-01 19:46:35','00:00:00',1);
/*!40000 ALTER TABLE `desavanja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `istorijazadataka`
--

DROP TABLE IF EXISTS `istorijazadataka`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `istorijazadataka` (
  `izID` int NOT NULL AUTO_INCREMENT,
  `IDZadatka` int DEFAULT NULL,
  `uradjen` date DEFAULT (curdate()),
  PRIMARY KEY (`izID`),
  KEY `istorijazadataka_ibfk_1` (`IDZadatka`),
  CONSTRAINT `istorijazadataka_ibfk_1` FOREIGN KEY (`IDZadatka`) REFERENCES `zadaci` (`zadatakID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `istorijazadataka`
--

LOCK TABLES `istorijazadataka` WRITE;
/*!40000 ALTER TABLE `istorijazadataka` DISABLE KEYS */;
INSERT INTO `istorijazadataka` VALUES (50,85,'2025-01-14'),(51,85,'2025-01-14'),(54,92,'2025-01-26'),(55,91,'2025-01-26'),(56,88,'2025-01-26'),(57,93,'2025-01-26'),(58,89,'2025-01-27'),(66,95,'2025-01-28'),(67,97,'2025-01-28'),(69,99,'2025-01-28'),(70,89,'2025-01-29'),(72,89,'2025-01-30'),(79,95,'2025-01-31'),(80,95,'2025-01-31'),(124,97,'2025-02-01'),(125,113,'2025-02-01'),(126,113,'2025-02-01'),(154,95,'2025-02-02'),(155,95,'2025-02-02'),(156,89,'2025-02-03');
/*!40000 ALTER TABLE `istorijazadataka` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kategorije`
--

DROP TABLE IF EXISTS `kategorije`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kategorije` (
  `kategID` int NOT NULL AUTO_INCREMENT,
  `imeKateg` varchar(50) DEFAULT NULL,
  `IDUsera` int DEFAULT NULL,
  PRIMARY KEY (`kategID`),
  KEY `fkKategUser` (`IDUsera`),
  CONSTRAINT `fkKategUser` FOREIGN KEY (`IDUsera`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kategorije`
--

LOCK TABLES `kategorije` WRITE;
/*!40000 ALTER TABLE `kategorije` DISABLE KEYS */;
INSERT INTO `kategorije` VALUES (1,'Nekategorizovano',NULL),(6,'Fizička aktivnost',1),(7,'Projekat',1),(9,'Fakultet',1),(10,'Kućni poslovi',1),(11,'Higijena',1),(12,'Fakultet',17),(14,'New ',16);
/*!40000 ALTER TABLE `kategorije` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rola`
--

DROP TABLE IF EXISTS `rola`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rola` (
  `rolaID` int NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`rolaID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rola`
--

LOCK TABLES `rola` WRITE;
/*!40000 ALTER TABLE `rola` DISABLE KEYS */;
INSERT INTO `rola` VALUES (1,'korisnik'),(2,'admin');
/*!40000 ALTER TABLE `rola` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `lozinka` varchar(500) DEFAULT NULL,
  `rola` int DEFAULT NULL,
  `kreirano` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`),
  KEY `fkRole` (`rola`),
  CONSTRAINT `fkRole` FOREIGN KEY (`rola`) REFERENCES `rola` (`rolaID`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Nemanja','njakovlje@gmail.com','scrypt:32768:8:1$jOqeSs5VyNaoy8bk$74b69a798a9114e8a062d44787dbe9ff09f8016de9b6907281245985bb329dd53e8d293cbcdb0b4fdae8bee390dfb744aefac4bc0b30fc6074c9604206f28d60',2,'2024-12-30 09:05:41'),(15,'mariaphxx','mariaphxx@gmail.com','scrypt:32768:8:1$lQbzLhGUobEa7yCL$2896f6c58064ea8ec1c15b3500c857e2786113eec95492b1c933856881a30ec0916e50affefd044c1b709487f801fe75edabeb00254539a122b30893434b9c8d',2,'2025-01-14 11:52:49'),(16,'Moja Proba','proba@proba.com','scrypt:32768:8:1$HqstacpBiicbeAmC$cf1bce636ef3fb655185ef4f1787ffb627af5d7af9a351e2b26627f601e59bb29fc257b905480054fb5cdc9cf8c26f744e317f8bf82ffc0f4516af849b94b262',1,'2025-01-14 11:53:06'),(17,'Admin','admin@admin.com','scrypt:32768:8:1$U0gFiUwk6S8aFFAs$a4285a195d4a5232f976f76debe6756b92528a44e1e641e197bc99a748c68e66066bedc30bdf8ef1322b96d1bb77c7302a840a7a14c76d211db1c859e551257d',2,'2025-01-25 01:22:35');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `zadaci`
--

DROP TABLE IF EXISTS `zadaci`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `zadaci` (
  `zadatakID` int NOT NULL AUTO_INCREMENT,
  `IDUsera` int DEFAULT NULL,
  `opis` varchar(50) DEFAULT NULL,
  `jednokratni` tinyint(1) DEFAULT NULL,
  `uradjeno` tinyint(1) DEFAULT NULL,
  `brojac` int DEFAULT NULL,
  `kreiran` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `rok` date DEFAULT NULL,
  `kategZ` int DEFAULT '1',
  `cilj` int DEFAULT '0',
  `period` varchar(15) DEFAULT 'Godišnje',
  PRIMARY KEY (`zadatakID`),
  KEY `fkUser2` (`IDUsera`),
  KEY `fkKateg2` (`kategZ`),
  CONSTRAINT `fkKateg2` FOREIGN KEY (`kategZ`) REFERENCES `kategorije` (`kategID`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zadaci`
--

LOCK TABLES `zadaci` WRITE;
/*!40000 ALTER TABLE `zadaci` DISABLE KEYS */;
INSERT INTO `zadaci` VALUES (77,1,'Završi projekat za Web Programiranje',1,0,0,'2025-01-14 12:35:23','2025-01-31',7,0,'godisnje'),(78,1,'Završi projekat za KSS',1,0,0,'2025-01-14 12:35:34','2025-01-31',7,0,'godisnje'),(79,1,'Završi projekat za .NET',1,1,0,'2025-01-14 12:35:44','2025-01-23',1,0,'godisnje'),(80,1,'Proba za istekli rok',1,0,0,'2025-01-14 12:35:55','2025-01-01',1,0,'godisnje'),(81,1,'Napravi bazu podataka',1,1,0,'2025-01-14 12:36:18','1970-01-01',1,0,'godisnje'),(83,16,'Jednokratan zadatak 1',1,0,0,'2025-01-14 16:31:03','2025-01-16',1,0,'godisnje'),(84,16,'Jednokratan zadatak',1,1,0,'2025-01-14 16:31:10','2025-02-21',1,0,'godisnje'),(85,16,'Ponavljajuć zadatak',0,0,2,'2025-01-14 16:31:35',NULL,1,8,'godisnje'),(86,16,'Uradjen zadatak',1,1,0,'2025-01-14 16:31:39','1970-01-01',1,0,'godisnje'),(87,1,'Trčanje',0,0,0,'2025-01-26 00:54:09',NULL,6,52,'nedeljno'),(88,1,'Pranje sudova',0,0,1,'2025-01-26 00:54:33',NULL,10,52,'nedeljno'),(89,1,'Tuširanje',0,0,5,'2025-01-26 00:55:09',NULL,11,260,'nedeljno'),(91,1,'Usisavanje',0,0,1,'2025-01-26 00:56:06',NULL,10,24,'mesecno'),(92,1,'Brijanje',0,0,1,'2025-01-26 01:02:47',NULL,11,52,'nedeljno'),(93,1,'Sređivanje sobe',0,0,1,'2025-01-26 01:04:46',NULL,10,52,'nedeljno'),(94,1,'Wireframe za ovaj sajt',1,0,0,'2025-01-26 01:09:40','2025-02-02',9,0,'godisnje'),(95,1,'Proba urađeno',0,0,4,'2025-01-26 02:25:13',NULL,1,52,'nedeljno'),(96,1,'Oslobodi Anđeli prvu fioku',1,0,0,'2025-01-26 02:25:42',NULL,1,0,'godisnje'),(97,1,'Džak',0,0,2,'2025-01-28 10:28:47',NULL,6,52,'nedeljno'),(99,1,'Vežbe koncentracije',0,0,1,'2025-01-28 10:30:15',NULL,1,156,'nedeljno'),(100,1,'Selidba u spavaću sobu',1,0,0,'2025-01-28 10:31:21',NULL,1,0,'godisnje'),(101,1,'Upali i očisti frižider',1,0,0,'2025-01-29 13:12:09',NULL,1,0,'godisnje'),(102,17,'Projekat KSS',1,0,0,'2025-01-29 18:05:50','2025-02-02',12,0,'godisnje'),(103,17,'Trening',0,0,0,'2025-01-29 18:06:26',NULL,1,0,'godisnje'),(104,17,'Uradjen zadatak',1,1,0,'2025-01-29 18:06:35','1970-01-01',1,0,'godisnje'),(107,17,'Proba cilja',0,0,0,'2025-01-30 04:39:13',NULL,1,2,'godisnje'),(113,1,'Trening',0,0,2,'2025-02-01 01:09:03',NULL,6,104,'nedeljno'),(120,16,'recurring task 2',0,1,1,'2025-02-01 19:40:22','1970-01-01',1,72,'mesecno');
/*!40000 ALTER TABLE `zadaci` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-02-03 11:00:07
