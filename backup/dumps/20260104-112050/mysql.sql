-- MySQL dump 10.13  Distrib 8.0.44, for Linux (x86_64)
--
-- Host: localhost    Database: video_conference
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `video_conference`
--

/*!40000 DROP DATABASE IF EXISTS `video_conference`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `video_conference` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `video_conference`;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `source_db` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pk_value` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `op` enum('I','U','D') COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `changed_by` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `old_row` json DEFAULT NULL,
  `new_row` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_audit_log_table_pk` (`table_name`,`pk_value`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=164 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,'mysql','users','1','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1}'),(2,'mysql','users','2','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 2}'),(3,'mysql','users','3','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 3}'),(4,'mysql','users','4','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 4}'),(5,'mysql','users','5','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 5}'),(6,'mysql','users','6','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 6}'),(7,'mysql','rooms','101','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 101}'),(8,'mysql','rooms','102','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 102}'),(9,'mysql','rooms','103','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 103}'),(10,'mysql','permission_roles','1','U','2026-01-04 03:13:34','root@localhost','{\"id\": 1}','{\"id\": 1}'),(11,'mysql','permission_roles','2','U','2026-01-04 03:13:34','root@localhost','{\"id\": 2}','{\"id\": 2}'),(12,'mysql','permission_roles','3','U','2026-01-04 03:13:34','root@localhost','{\"id\": 3}','{\"id\": 3}'),(13,'mysql','meeting_permissions','201','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 201}'),(14,'mysql','meeting_permissions','202','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 202}'),(15,'mysql','meeting_permissions','203','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 203}'),(16,'mysql','meeting_permissions','204','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 204}'),(17,'mysql','meeting_permissions','205','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 205}'),(18,'mysql','room_participants','301','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 301}'),(19,'mysql','room_participants','302','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 302}'),(20,'mysql','room_participants','303','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 303}'),(21,'mysql','room_participants','304','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 304}'),(22,'mysql','room_participants','305','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 305}'),(23,'mysql','room_participants','306','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 306}'),(24,'mysql','room_participants','307','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 307}'),(25,'mysql','room_participants','308','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 308}'),(26,'mysql','room_participants','309','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 309}'),(27,'mysql','messages','1001','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1001}'),(28,'mysql','messages','1002','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1002}'),(29,'mysql','messages','1003','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1003}'),(30,'mysql','messages','1004','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1004}'),(31,'mysql','messages','1005','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1005}'),(32,'mysql','messages','1010','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1010}'),(33,'mysql','messages','1011','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1011}'),(34,'mysql','messages','1012','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1012}'),(35,'mysql','messages','1101','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1101}'),(36,'mysql','messages','1102','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1102}'),(37,'mysql','messages','1103','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1103}'),(38,'mysql','messages','1104','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1104}'),(39,'mysql','messages','1110','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1110}'),(40,'mysql','messages','1111','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1111}'),(41,'mysql','messages','1112','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 1112}'),(42,'mysql','friendships','401','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 401}'),(43,'mysql','friendships','402','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 402}'),(44,'mysql','friendships','403','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 403}'),(45,'mysql','friendships','404','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 404}'),(46,'mysql','friend_requests','501','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 501}'),(47,'mysql','friend_requests','502','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 502}'),(48,'mysql','friend_requests','503','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 503}'),(49,'mysql','waiting_room','601','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 601}'),(50,'mysql','meeting_recordings','701','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 701}'),(51,'mysql','meeting_recordings','702','I','2026-01-04 03:13:34','root@localhost',NULL,'{\"id\": 702}'),(52,'mysql','users','7','I','2026-01-04 03:14:56','lhy@172.18.0.3',NULL,'{\"id\": 7}'),(53,'mysql','users','3','D','2026-01-04 03:15:08','lhy@172.18.0.3','{\"id\": 3}',NULL),(54,'mysql','users','1','D','2026-01-04 03:16:11','lhy@172.18.0.3','{\"id\": 1}',NULL),(55,'mysql','users','2','D','2026-01-04 03:16:11','lhy@172.18.0.3','{\"id\": 2}',NULL),(56,'mysql','users','4','D','2026-01-04 03:16:11','lhy@172.18.0.3','{\"id\": 4}',NULL),(57,'mysql','users','5','D','2026-01-04 03:16:11','lhy@172.18.0.3','{\"id\": 5}',NULL),(58,'mysql','users','6','D','2026-01-04 03:16:11','lhy@172.18.0.3','{\"id\": 6}',NULL),(59,'mysql','users','7','D','2026-01-04 03:16:11','lhy@172.18.0.3','{\"id\": 7}',NULL),(60,'mysql','users','1','I','2026-01-04 03:16:11','lhy@172.18.0.3',NULL,'{\"id\": 1}'),(61,'mysql','users','2','I','2026-01-04 03:16:11','lhy@172.18.0.3',NULL,'{\"id\": 2}'),(62,'mysql','users','4','I','2026-01-04 03:16:11','lhy@172.18.0.3',NULL,'{\"id\": 4}'),(63,'mysql','users','5','I','2026-01-04 03:16:11','lhy@172.18.0.3',NULL,'{\"id\": 5}'),(64,'mysql','users','6','I','2026-01-04 03:16:11','lhy@172.18.0.3',NULL,'{\"id\": 6}'),(65,'mysql','users','7','I','2026-01-04 03:16:11','lhy@172.18.0.3',NULL,'{\"id\": 7}'),(66,'mysql','users','993591','I','2026-01-04 03:16:31','lhy@172.18.0.3',NULL,'{\"id\": 993591}'),(67,'mysql','users','993591','U','2026-01-04 03:16:31','lhy@172.18.0.3','{\"id\": 993591}','{\"id\": 993591}'),(68,'mysql','users','993591','U','2026-01-04 03:16:36','lhy@172.18.0.3','{\"id\": 993591}','{\"id\": 993591}'),(69,'mysql','users','921952','I','2026-01-04 03:16:37','lhy@172.18.0.3',NULL,'{\"id\": 921952}'),(70,'mysql','users','921952','U','2026-01-04 03:16:37','lhy@172.18.0.3','{\"id\": 921952}','{\"id\": 921952}'),(71,'mysql','users','907524','I','2026-01-04 03:16:39','lhy@172.18.0.3',NULL,'{\"id\": 907524}'),(72,'mysql','users','907524','U','2026-01-04 03:16:39','lhy@172.18.0.3','{\"id\": 907524}','{\"id\": 907524}'),(73,'mysql','users','921952','U','2026-01-04 03:16:47','lhy@172.18.0.3','{\"id\": 921952}','{\"id\": 921952}'),(74,'mysql','users','900001','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900001}'),(75,'mysql','users','900002','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900002}'),(76,'mysql','users','900003','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900003}'),(77,'mysql','users','900004','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900004}'),(78,'mysql','users','900005','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900005}'),(79,'mysql','users','900006','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900006}'),(80,'mysql','users','900007','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900007}'),(81,'mysql','users','900008','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900008}'),(82,'mysql','users','900009','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900009}'),(83,'mysql','users','900010','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900010}'),(84,'mysql','users','900011','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900011}'),(85,'mysql','users','900012','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900012}'),(86,'mysql','users','900013','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900013}'),(87,'mysql','users','900014','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900014}'),(88,'mysql','users','900015','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 900015}'),(89,'mysql','rooms','910001','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 910001}'),(90,'mysql','rooms','910002','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 910002}'),(91,'mysql','rooms','910003','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 910003}'),(92,'mysql','rooms','910004','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 910004}'),(93,'mysql','rooms','910005','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 910005}'),(94,'mysql','rooms','910006','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 910006}'),(95,'mysql','room_participants','920001','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920001}'),(96,'mysql','room_participants','920002','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920002}'),(97,'mysql','room_participants','920003','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920003}'),(98,'mysql','room_participants','920004','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920004}'),(99,'mysql','room_participants','920005','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920005}'),(100,'mysql','room_participants','920006','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920006}'),(101,'mysql','room_participants','920007','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920007}'),(102,'mysql','room_participants','920008','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920008}'),(103,'mysql','room_participants','920009','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920009}'),(104,'mysql','room_participants','920010','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920010}'),(105,'mysql','room_participants','920011','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920011}'),(106,'mysql','room_participants','920012','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920012}'),(107,'mysql','room_participants','920013','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920013}'),(108,'mysql','room_participants','920014','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920014}'),(109,'mysql','room_participants','920015','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920015}'),(110,'mysql','room_participants','920016','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920016}'),(111,'mysql','room_participants','920017','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920017}'),(112,'mysql','room_participants','920018','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920018}'),(113,'mysql','room_participants','920019','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920019}'),(114,'mysql','room_participants','920020','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920020}'),(115,'mysql','room_participants','920021','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920021}'),(116,'mysql','room_participants','920022','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920022}'),(117,'mysql','room_participants','920023','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920023}'),(118,'mysql','room_participants','920024','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920024}'),(119,'mysql','room_participants','920025','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920025}'),(120,'mysql','room_participants','920026','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920026}'),(121,'mysql','room_participants','920027','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920027}'),(122,'mysql','room_participants','920028','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920028}'),(123,'mysql','room_participants','920029','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920029}'),(124,'mysql','room_participants','920030','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920030}'),(125,'mysql','room_participants','920031','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 920031}'),(126,'mysql','messages','940001','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940001}'),(127,'mysql','messages','940002','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940002}'),(128,'mysql','messages','940003','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940003}'),(129,'mysql','messages','940004','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940004}'),(130,'mysql','messages','940005','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940005}'),(131,'mysql','messages','940006','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940006}'),(132,'mysql','messages','940007','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940007}'),(133,'mysql','messages','940008','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940008}'),(134,'mysql','messages','940009','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940009}'),(135,'mysql','messages','940010','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940010}'),(136,'mysql','messages','940011','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940011}'),(137,'mysql','messages','940012','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940012}'),(138,'mysql','messages','940013','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940013}'),(139,'mysql','messages','940014','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940014}'),(140,'mysql','messages','940015','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 940015}'),(141,'mysql','friendships','960001','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960001}'),(142,'mysql','friendships','960002','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960002}'),(143,'mysql','friendships','960003','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960003}'),(144,'mysql','friendships','960004','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960004}'),(145,'mysql','friendships','960010','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960010}'),(146,'mysql','friendships','960011','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960011}'),(147,'mysql','friendships','960012','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960012}'),(148,'mysql','friendships','960013','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960013}'),(149,'mysql','friendships','960014','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960014}'),(150,'mysql','friendships','960015','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960015}'),(151,'mysql','friendships','960016','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960016}'),(152,'mysql','friendships','960017','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960017}'),(153,'mysql','friendships','960018','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960018}'),(154,'mysql','friendships','960019','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960019}'),(155,'mysql','friendships','960020','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960020}'),(156,'mysql','friendships','960021','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960021}'),(157,'mysql','friendships','960022','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 960022}'),(158,'mysql','friend_requests','970001','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 970001}'),(159,'mysql','friend_requests','970002','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 970002}'),(160,'mysql','friend_requests','970003','I','2026-01-04 03:18:57','lhy@172.18.0.1',NULL,'{\"id\": 970003}'),(161,'mysql','users','900101','U','2025-12-27 03:19:11','DEMO_SYNC_SEED','{\"id\": 900101, \"status\": \"offline\", \"username\": \"demo_user_a\"}','{\"id\": 900101, \"status\": \"online\", \"username\": \"demo_user_a\"}'),(162,'mysql','rooms','700101','I','2025-12-29 03:19:11','DEMO_SYNC_SEED',NULL,'{\"id\": 700101, \"status\": \"active\", \"meeting_code\": \"MTC999001\"}'),(163,'mysql','friend_requests','800101','U','2026-01-02 03:19:11','DEMO_SYNC_SEED','{\"id\": 800101, \"status\": \"pending\"}','{\"id\": 800101, \"status\": \"accepted\"}');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `change_log`
--

DROP TABLE IF EXISTS `change_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `change_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `source_db` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pk_value` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `op` enum('I','U','D') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_change_log_processed` (`processed`,`id`),
  KEY `idx_change_log_table_pk` (`table_name`,`pk_value`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `change_log`
--

LOCK TABLES `change_log` WRITE;
/*!40000 ALTER TABLE `change_log` DISABLE KEYS */;
INSERT INTO `change_log` VALUES (1,'mysql','users','1','I','2026-01-04 03:13:34',1),(2,'mysql','users','2','I','2026-01-04 03:13:34',1),(3,'mysql','users','3','I','2026-01-04 03:13:34',1),(4,'mysql','users','4','I','2026-01-04 03:13:34',1),(5,'mysql','users','5','I','2026-01-04 03:13:34',1),(6,'mysql','users','6','I','2026-01-04 03:13:34',1),(7,'mysql','rooms','101','I','2026-01-04 03:13:34',1),(8,'mysql','rooms','102','I','2026-01-04 03:13:34',1),(9,'mysql','rooms','103','I','2026-01-04 03:13:34',1),(10,'mysql','permission_roles','1','U','2026-01-04 03:13:34',1),(11,'mysql','permission_roles','2','U','2026-01-04 03:13:34',1),(12,'mysql','permission_roles','3','U','2026-01-04 03:13:34',1),(13,'mysql','meeting_permissions','201','I','2026-01-04 03:13:34',1),(14,'mysql','meeting_permissions','202','I','2026-01-04 03:13:34',1),(15,'mysql','meeting_permissions','203','I','2026-01-04 03:13:34',1),(16,'mysql','meeting_permissions','204','I','2026-01-04 03:13:34',1),(17,'mysql','meeting_permissions','205','I','2026-01-04 03:13:34',1),(18,'mysql','room_participants','301','I','2026-01-04 03:13:34',1),(19,'mysql','room_participants','302','I','2026-01-04 03:13:34',1),(20,'mysql','room_participants','303','I','2026-01-04 03:13:34',1),(21,'mysql','room_participants','304','I','2026-01-04 03:13:34',1),(22,'mysql','room_participants','305','I','2026-01-04 03:13:34',1),(23,'mysql','room_participants','306','I','2026-01-04 03:13:34',1),(24,'mysql','room_participants','307','I','2026-01-04 03:13:34',1),(25,'mysql','room_participants','308','I','2026-01-04 03:13:34',1),(26,'mysql','room_participants','309','I','2026-01-04 03:13:34',1),(27,'mysql','messages','1001','I','2026-01-04 03:13:34',1),(28,'mysql','messages','1002','I','2026-01-04 03:13:34',1),(29,'mysql','messages','1003','I','2026-01-04 03:13:34',1),(30,'mysql','messages','1004','I','2026-01-04 03:13:34',1),(31,'mysql','messages','1005','I','2026-01-04 03:13:34',1),(32,'mysql','messages','1010','I','2026-01-04 03:13:34',1),(33,'mysql','messages','1011','I','2026-01-04 03:13:34',1),(34,'mysql','messages','1012','I','2026-01-04 03:13:34',1),(35,'mysql','messages','1101','I','2026-01-04 03:13:34',1),(36,'mysql','messages','1102','I','2026-01-04 03:13:34',1),(37,'mysql','messages','1103','I','2026-01-04 03:13:34',1),(38,'mysql','messages','1104','I','2026-01-04 03:13:34',1),(39,'mysql','messages','1110','I','2026-01-04 03:13:34',1),(40,'mysql','messages','1111','I','2026-01-04 03:13:34',1),(41,'mysql','messages','1112','I','2026-01-04 03:13:34',1),(42,'mysql','friendships','401','I','2026-01-04 03:13:34',1),(43,'mysql','friendships','402','I','2026-01-04 03:13:34',1),(44,'mysql','friendships','403','I','2026-01-04 03:13:34',1),(45,'mysql','friendships','404','I','2026-01-04 03:13:34',1),(46,'mysql','friend_requests','501','I','2026-01-04 03:13:34',1),(47,'mysql','friend_requests','502','I','2026-01-04 03:13:34',1),(48,'mysql','friend_requests','503','I','2026-01-04 03:13:34',1),(49,'mysql','waiting_room','601','I','2026-01-04 03:13:34',1),(50,'mysql','meeting_recordings','701','I','2026-01-04 03:13:34',1),(51,'mysql','meeting_recordings','702','I','2026-01-04 03:13:34',1),(52,'mysql','users','7','I','2026-01-04 03:14:56',1),(53,'mysql','users','3','D','2026-01-04 03:15:08',1),(54,'mysql','users','1','D','2026-01-04 03:16:11',1),(55,'mysql','users','2','D','2026-01-04 03:16:11',1),(56,'mysql','users','4','D','2026-01-04 03:16:11',1),(57,'mysql','users','5','D','2026-01-04 03:16:11',1),(58,'mysql','users','6','D','2026-01-04 03:16:11',1),(59,'mysql','users','7','D','2026-01-04 03:16:11',1),(60,'mysql','users','1','I','2026-01-04 03:16:11',1),(61,'mysql','users','2','I','2026-01-04 03:16:11',1),(62,'mysql','users','4','I','2026-01-04 03:16:11',1),(63,'mysql','users','5','I','2026-01-04 03:16:11',1),(64,'mysql','users','6','I','2026-01-04 03:16:11',1),(65,'mysql','users','7','I','2026-01-04 03:16:11',1),(66,'mysql','users','993591','I','2026-01-04 03:16:31',1),(67,'mysql','users','993591','U','2026-01-04 03:16:31',1),(68,'mysql','users','993591','U','2026-01-04 03:16:36',1),(69,'mysql','users','921952','I','2026-01-04 03:16:37',1),(70,'mysql','users','921952','U','2026-01-04 03:16:37',1),(71,'mysql','users','907524','I','2026-01-04 03:16:39',1),(72,'mysql','users','907524','U','2026-01-04 03:16:39',1),(73,'mysql','users','921952','U','2026-01-04 03:16:47',1),(74,'mysql','users','900001','I','2026-01-04 03:18:57',1),(75,'mysql','users','900002','I','2026-01-04 03:18:57',1),(76,'mysql','users','900003','I','2026-01-04 03:18:57',1),(77,'mysql','users','900004','I','2026-01-04 03:18:57',1),(78,'mysql','users','900005','I','2026-01-04 03:18:57',1),(79,'mysql','users','900006','I','2026-01-04 03:18:57',1),(80,'mysql','users','900007','I','2026-01-04 03:18:57',1),(81,'mysql','users','900008','I','2026-01-04 03:18:57',1),(82,'mysql','users','900009','I','2026-01-04 03:18:57',1),(83,'mysql','users','900010','I','2026-01-04 03:18:57',1),(84,'mysql','users','900011','I','2026-01-04 03:18:57',1),(85,'mysql','users','900012','I','2026-01-04 03:18:57',1),(86,'mysql','users','900013','I','2026-01-04 03:18:57',1),(87,'mysql','users','900014','I','2026-01-04 03:18:57',1),(88,'mysql','users','900015','I','2026-01-04 03:18:57',1),(89,'mysql','rooms','910001','I','2026-01-04 03:18:57',1),(90,'mysql','rooms','910002','I','2026-01-04 03:18:57',1),(91,'mysql','rooms','910003','I','2026-01-04 03:18:57',1),(92,'mysql','rooms','910004','I','2026-01-04 03:18:57',1),(93,'mysql','rooms','910005','I','2026-01-04 03:18:57',1),(94,'mysql','rooms','910006','I','2026-01-04 03:18:57',1),(95,'mysql','room_participants','920001','I','2026-01-04 03:18:57',1),(96,'mysql','room_participants','920002','I','2026-01-04 03:18:57',1),(97,'mysql','room_participants','920003','I','2026-01-04 03:18:57',1),(98,'mysql','room_participants','920004','I','2026-01-04 03:18:57',1),(99,'mysql','room_participants','920005','I','2026-01-04 03:18:57',1),(100,'mysql','room_participants','920006','I','2026-01-04 03:18:57',1),(101,'mysql','room_participants','920007','I','2026-01-04 03:18:57',1),(102,'mysql','room_participants','920008','I','2026-01-04 03:18:57',1),(103,'mysql','room_participants','920009','I','2026-01-04 03:18:57',1),(104,'mysql','room_participants','920010','I','2026-01-04 03:18:57',1),(105,'mysql','room_participants','920011','I','2026-01-04 03:18:57',1),(106,'mysql','room_participants','920012','I','2026-01-04 03:18:57',1),(107,'mysql','room_participants','920013','I','2026-01-04 03:18:57',1),(108,'mysql','room_participants','920014','I','2026-01-04 03:18:57',1),(109,'mysql','room_participants','920015','I','2026-01-04 03:18:57',1),(110,'mysql','room_participants','920016','I','2026-01-04 03:18:57',1),(111,'mysql','room_participants','920017','I','2026-01-04 03:18:57',1),(112,'mysql','room_participants','920018','I','2026-01-04 03:18:57',1),(113,'mysql','room_participants','920019','I','2026-01-04 03:18:57',1),(114,'mysql','room_participants','920020','I','2026-01-04 03:18:57',1),(115,'mysql','room_participants','920021','I','2026-01-04 03:18:57',1),(116,'mysql','room_participants','920022','I','2026-01-04 03:18:57',1),(117,'mysql','room_participants','920023','I','2026-01-04 03:18:57',1),(118,'mysql','room_participants','920024','I','2026-01-04 03:18:57',1),(119,'mysql','room_participants','920025','I','2026-01-04 03:18:57',1),(120,'mysql','room_participants','920026','I','2026-01-04 03:18:57',1),(121,'mysql','room_participants','920027','I','2026-01-04 03:18:57',1),(122,'mysql','room_participants','920028','I','2026-01-04 03:18:57',1),(123,'mysql','room_participants','920029','I','2026-01-04 03:18:57',1),(124,'mysql','room_participants','920030','I','2026-01-04 03:18:57',1),(125,'mysql','room_participants','920031','I','2026-01-04 03:18:57',1),(126,'mysql','messages','940001','I','2026-01-04 03:18:57',1),(127,'mysql','messages','940002','I','2026-01-04 03:18:57',1),(128,'mysql','messages','940003','I','2026-01-04 03:18:57',1),(129,'mysql','messages','940004','I','2026-01-04 03:18:57',1),(130,'mysql','messages','940005','I','2026-01-04 03:18:57',1),(131,'mysql','messages','940006','I','2026-01-04 03:18:57',1),(132,'mysql','messages','940007','I','2026-01-04 03:18:57',1),(133,'mysql','messages','940008','I','2026-01-04 03:18:57',1),(134,'mysql','messages','940009','I','2026-01-04 03:18:57',1),(135,'mysql','messages','940010','I','2026-01-04 03:18:57',1),(136,'mysql','messages','940011','I','2026-01-04 03:18:57',1),(137,'mysql','messages','940012','I','2026-01-04 03:18:57',1),(138,'mysql','messages','940013','I','2026-01-04 03:18:57',1),(139,'mysql','messages','940014','I','2026-01-04 03:18:57',1),(140,'mysql','messages','940015','I','2026-01-04 03:18:57',1),(141,'mysql','friendships','960001','I','2026-01-04 03:18:57',1),(142,'mysql','friendships','960002','I','2026-01-04 03:18:57',1),(143,'mysql','friendships','960003','I','2026-01-04 03:18:57',1),(144,'mysql','friendships','960004','I','2026-01-04 03:18:57',1),(145,'mysql','friendships','960010','I','2026-01-04 03:18:57',1),(146,'mysql','friendships','960011','I','2026-01-04 03:18:57',1),(147,'mysql','friendships','960012','I','2026-01-04 03:18:57',1),(148,'mysql','friendships','960013','I','2026-01-04 03:18:57',1),(149,'mysql','friendships','960014','I','2026-01-04 03:18:57',1),(150,'mysql','friendships','960015','I','2026-01-04 03:18:57',1),(151,'mysql','friendships','960016','I','2026-01-04 03:18:57',1),(152,'mysql','friendships','960017','I','2026-01-04 03:18:57',1),(153,'mysql','friendships','960018','I','2026-01-04 03:18:57',1),(154,'mysql','friendships','960019','I','2026-01-04 03:18:57',1),(155,'mysql','friendships','960020','I','2026-01-04 03:18:57',1),(156,'mysql','friendships','960021','I','2026-01-04 03:18:57',1),(157,'mysql','friendships','960022','I','2026-01-04 03:18:57',1),(158,'mysql','friend_requests','970001','I','2026-01-04 03:18:57',1),(159,'mysql','friend_requests','970002','I','2026-01-04 03:18:57',1),(160,'mysql','friend_requests','970003','I','2026-01-04 03:18:57',1),(161,'DEMO_SYNC_SEED','users','900101','U','2025-12-27 03:19:11',1),(162,'DEMO_SYNC_SEED','rooms','700101','I','2025-12-29 03:19:11',1),(163,'DEMO_SYNC_SEED','messages','600101','I','2025-12-29 03:19:11',1),(164,'DEMO_SYNC_SEED','friend_requests','800101','U','2026-01-02 03:19:11',0),(165,'DEMO_SYNC_SEED','meeting_permissions','500101','D','2026-01-03 03:19:11',1);
/*!40000 ALTER TABLE `change_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conflicts`
--

DROP TABLE IF EXISTS `conflicts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conflicts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pk_value` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `detected_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('open','resolved') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_db` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolution_db` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolution_method` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolution_note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolved_by` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_conflicts_status` (`status`,`detected_at`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conflicts`
--

LOCK TABLES `conflicts` WRITE;
/*!40000 ALTER TABLE `conflicts` DISABLE KEYS */;
INSERT INTO `conflicts` VALUES (1,'permission_roles','1','2026-01-04 03:14:02','open','updated_at conflict: target(postgres)=2026-01-04T03:13:55.945526 newer than source(2026-01-04T03:13:32)','mysql','postgres',NULL,NULL,NULL,NULL),(2,'permission_roles','2','2026-01-04 03:14:02','open','updated_at conflict: target(postgres)=2026-01-04T03:13:55.945526 newer than source(2026-01-04T03:13:32)','mysql','postgres',NULL,NULL,NULL,NULL),(3,'permission_roles','3','2026-01-04 03:14:02','open','updated_at conflict: target(postgres)=2026-01-04T03:13:55.945526 newer than source(2026-01-04T03:13:32)','mysql','postgres',NULL,NULL,NULL,NULL),(4,'rooms','101','2026-01-04 03:14:14','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_ROOMS_HOST) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".rooms (id, meeting_code, name, description, host_i','mysql','oracle',NULL,NULL,NULL,NULL),(5,'rooms','102','2026-01-04 03:14:14','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_ROOMS_HOST) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".rooms (id, meeting_code, name, description, host_i','mysql','oracle',NULL,NULL,NULL,NULL),(6,'permission_roles','1','2026-01-04 03:14:15','open','updated_at conflict: target(oracle)=2026-01-04T03:14:12.217687 newer than source(2026-01-04T03:13:32)','mysql','oracle',NULL,NULL,NULL,NULL),(7,'permission_roles','2','2026-01-04 03:14:15','open','updated_at conflict: target(oracle)=2026-01-04T03:14:12.219999 newer than source(2026-01-04T03:13:32)','mysql','oracle',NULL,NULL,NULL,NULL),(8,'permission_roles','3','2026-01-04 03:14:15','open','updated_at conflict: target(oracle)=2026-01-04T03:14:12.222142 newer than source(2026-01-04T03:13:32)','mysql','oracle',NULL,NULL,NULL,NULL),(9,'meeting_permissions','201','2026-01-04 03:14:15','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role','mysql','oracle',NULL,NULL,NULL,NULL),(10,'meeting_permissions','202','2026-01-04 03:14:15','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role','mysql','oracle',NULL,NULL,NULL,NULL),(11,'meeting_permissions','203','2026-01-04 03:14:15','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role','mysql','oracle',NULL,NULL,NULL,NULL),(12,'meeting_permissions','204','2026-01-04 03:14:16','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role','mysql','oracle',NULL,NULL,NULL,NULL),(13,'meeting_permissions','205','2026-01-04 03:14:16','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role','mysql','oracle',NULL,NULL,NULL,NULL),(14,'room_participants','301','2026-01-04 03:14:16','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(15,'room_participants','302','2026-01-04 03:14:17','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(16,'room_participants','303','2026-01-04 03:14:17','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(17,'room_participants','304','2026-01-04 03:14:17','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(18,'room_participants','305','2026-01-04 03:14:17','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(19,'room_participants','306','2026-01-04 03:14:17','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(20,'room_participants','307','2026-01-04 03:14:17','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(21,'room_participants','308','2026-01-04 03:14:17','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, l','mysql','oracle',NULL,NULL,NULL,NULL),(22,'messages','1001','2026-01-04 03:14:18','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(23,'messages','1002','2026-01-04 03:14:18','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(24,'messages','1003','2026-01-04 03:14:18','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(25,'messages','1004','2026-01-04 03:14:19','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(26,'messages','1005','2026-01-04 03:14:19','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(27,'messages','1010','2026-01-04 03:14:19','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(28,'messages','1011','2026-01-04 03:14:19','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(29,'messages','1012','2026-01-04 03:14:19','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(30,'messages','1101','2026-01-04 03:14:20','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(31,'messages','1102','2026-01-04 03:14:20','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(32,'messages','1103','2026-01-04 03:14:20','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(33,'messages','1104','2026-01-04 03:14:21','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(34,'messages','1110','2026-01-04 03:14:21','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(35,'messages','1111','2026-01-04 03:14:21','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(36,'messages','1112','2026-01-04 03:14:22','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, conten','mysql','oracle',NULL,NULL,NULL,NULL),(37,'friendships','401','2026-01-04 03:14:22','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FRIENDSHIPS_USER) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friendships (id, user_id, friend_id, categor','mysql','oracle',NULL,NULL,NULL,NULL),(38,'friendships','402','2026-01-04 03:14:22','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FRIENDSHIPS_USER) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friendships (id, user_id, friend_id, categor','mysql','oracle',NULL,NULL,NULL,NULL),(39,'friendships','403','2026-01-04 03:14:22','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FRIENDSHIPS_USER) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friendships (id, user_id, friend_id, categor','mysql','oracle',NULL,NULL,NULL,NULL),(40,'friend_requests','502','2026-01-04 03:14:23','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FR_TO) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friend_requests (id, from_user_id, to_user_id, message,','mysql','oracle',NULL,NULL,NULL,NULL),(41,'waiting_room','601','2026-01-04 03:14:23','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_WR_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".waiting_room (id, room_id, user_id, joined_at, admitt','mysql','oracle',NULL,NULL,NULL,NULL),(42,'meeting_recordings','701','2026-01-04 03:14:23','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_REC_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_recordings (id, meeting_id, file_path, cr','mysql','oracle',NULL,NULL,NULL,NULL),(43,'users','1','2026-01-04 03:14:25','open','updated_at conflict: target(postgres)=2026-01-04T03:14:08.731519 newer than source(2026-01-04T03:13:34)','mysql','postgres',NULL,NULL,NULL,NULL),(44,'users','2','2026-01-04 03:14:26','open','updated_at conflict: target(postgres)=2026-01-04T03:14:09.948290 newer than source(2026-01-04T03:13:34)','mysql','postgres',NULL,NULL,NULL,NULL),(45,'meeting_recordings','702','2026-01-04 03:14:26','open','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_REC_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_recordings (id, meeting_id, file_path, cr','mysql','oracle',NULL,NULL,NULL,NULL),(46,'users','993591','2026-01-04 03:16:32','resolved','updated_at conflict: target(postgres)=2026-01-04T03:16:31.570283 newer than source(2026-01-04T03:16:31)','mysql','oracle','manual',NULL,'admin','2026-01-04 03:16:37'),(47,'users','993591','2026-01-04 03:16:32','resolved','updated_at conflict: target(oracle)=2026-01-04T03:16:31.590299 newer than source(2026-01-04T03:16:31)','mysql','oracle','manual',NULL,'admin','2026-01-04 03:16:37'),(48,'users','921952','2026-01-04 03:16:38','resolved','updated_at conflict: target(postgres)=2026-01-04T03:16:37.743525 newer than source(2026-01-04T03:16:37)','mysql','postgres','manual',NULL,'admin','2026-01-04 03:16:47'),(49,'users','921952','2026-01-04 03:16:39','resolved','updated_at conflict: target(oracle)=2026-01-04T03:16:37.750119 newer than source(2026-01-04T03:16:37)','mysql','postgres','manual',NULL,'admin','2026-01-04 03:16:47'),(50,'users','907524','2026-01-04 03:16:40','resolved','updated_at conflict: target(postgres)=2026-01-04T03:16:40.825934 newer than source(2026-01-04T03:16:39)','mysql','mysql','manual',NULL,'admin','2026-01-04 03:16:44'),(51,'users','907524','2026-01-04 03:16:41','resolved','updated_at conflict: target(oracle)=2026-01-04T03:16:39.605633 newer than source(2026-01-04T03:16:39)','mysql','mysql','manual',NULL,'admin','2026-01-04 03:16:44'),(52,'users','900001','2025-12-26 03:18:51','resolved','updated_at_conflict','mysql','postgres','winner_db','DEMO_REPORT_SEED','admin','2025-12-27 03:18:51'),(53,'friend_requests','800001','2025-12-26 03:18:51','open','fk_missing','mysql','oracle',NULL,'DEMO_REPORT_SEED',NULL,NULL),(54,'rooms','700001','2025-12-27 03:18:51','resolved','unique_violation','mysql','oracle','auto_latest','DEMO_REPORT_SEED','admin','2025-12-28 03:18:51'),(55,'messages','600001','2025-12-28 03:18:51','open','target_db_unreachable','mysql','oracle',NULL,'DEMO_REPORT_SEED',NULL,NULL),(56,'meeting_permissions','500001','2025-12-28 03:18:51','resolved','fk_missing','mysql','oracle','retry_keep_source','DEMO_REPORT_SEED','admin','2025-12-29 03:18:51'),(57,'friendships','400001','2025-12-29 03:18:51','open','updated_at_conflict','mysql','postgres',NULL,'DEMO_REPORT_SEED',NULL,NULL),(58,'users','900002','2025-12-29 03:18:51','resolved','unique_violation','mysql','postgres','sync_from_db','DEMO_REPORT_SEED','admin','2025-12-30 03:18:51'),(59,'rooms','700002','2025-12-30 03:18:51','open','updated_at_conflict','mysql','oracle',NULL,'DEMO_REPORT_SEED',NULL,NULL),(60,'friend_categories','300001','2026-01-01 03:18:51','resolved','manual_override','mysql','postgres','winner_db','DEMO_REPORT_SEED','admin','2026-01-02 03:18:51'),(61,'room_participants','200001','2026-01-01 03:18:51','open','fk_missing','mysql','oracle',NULL,'DEMO_REPORT_SEED',NULL,NULL),(62,'audit_log','100001','2026-01-03 03:18:51','resolved','payload_too_large','mysql','postgres','mark_resolved','DEMO_REPORT_SEED','admin','2026-01-03 03:18:51'),(63,'users','900003','2026-01-04 03:18:51','open','updated_at_conflict','mysql','oracle',NULL,'DEMO_REPORT_SEED',NULL,NULL);
/*!40000 ALTER TABLE `conflicts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friend_categories`
--

DROP TABLE IF EXISTS `friend_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_system` tinyint(1) DEFAULT '1',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_categories`
--

LOCK TABLES `friend_categories` WRITE;
/*!40000 ALTER TABLE `friend_categories` DISABLE KEYS */;
INSERT INTO `friend_categories` VALUES (1,'other',1,1,'2026-01-04 03:13:32'),(2,'family',1,2,'2026-01-04 03:13:32'),(3,'friend',1,3,'2026-01-04 03:13:32'),(4,'workmate',1,4,'2026-01-04 03:13:32'),(5,'boss',1,5,'2026-01-04 03:13:32'),(6,'classmate',1,6,'2026-01-04 03:13:32'),(7,'teacher',1,7,'2026-01-04 03:13:32');
/*!40000 ALTER TABLE `friend_categories` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friend_categories_change_ai` AFTER INSERT ON `friend_categories` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_categories', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_categories', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friend_categories_change_au` AFTER UPDATE ON `friend_categories` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_categories', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_categories', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friend_categories_change_ad` AFTER DELETE ON `friend_categories` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_categories', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_categories', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `friend_requests`
--

DROP TABLE IF EXISTS `friend_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `from_user_id` int NOT NULL,
  `to_user_id` int NOT NULL,
  `message` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category_id` int NOT NULL DEFAULT '1',
  `status` enum('pending','accepted','rejected','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `responded_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_friend_request` (`from_user_id`,`to_user_id`,`status`),
  KEY `category_id` (`category_id`),
  KEY `idx_friend_requests_from_user` (`from_user_id`),
  KEY `idx_friend_requests_to_user` (`to_user_id`),
  KEY `idx_friend_requests_status` (`status`),
  KEY `idx_friend_requests_status_to_user` (`status`,`to_user_id`),
  CONSTRAINT `friend_requests_ibfk_1` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friend_requests_ibfk_2` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friend_requests_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `friend_categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=970004 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_requests`
--

LOCK TABLES `friend_requests` WRITE;
/*!40000 ALTER TABLE `friend_requests` DISABLE KEYS */;
INSERT INTO `friend_requests` VALUES (970001,900003,900007,'[S4] alice -> eve (pending, exclude)',1,'pending','2026-01-02 03:18:57',NULL),(970002,900003,900009,'[S4] alice -> grace (rejected, keep)',1,'rejected','2025-12-25 03:18:57','2025-12-26 03:18:57'),(970003,900003,900015,'[S4] alice -> mia (cancelled, keep)',1,'cancelled','2025-12-31 03:18:57','2026-01-01 03:18:57');
/*!40000 ALTER TABLE `friend_requests` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friend_requests_change_ai` AFTER INSERT ON `friend_requests` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_requests', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_requests', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friend_requests_change_au` AFTER UPDATE ON `friend_requests` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_requests', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_requests', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friend_requests_change_ad` AFTER DELETE ON `friend_requests` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_requests', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_requests', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `friendships`
--

DROP TABLE IF EXISTS `friendships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friendships` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `friend_id` int NOT NULL,
  `category_id` int NOT NULL DEFAULT '1',
  `custom_category_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_friendship` (`user_id`,`friend_id`),
  KEY `idx_friendships_user_id` (`user_id`),
  KEY `idx_friendships_friend_id` (`friend_id`),
  KEY `idx_friendships_category_id` (`category_id`),
  CONSTRAINT `friendships_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friendships_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friendships_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `friend_categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=960023 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friendships`
--

LOCK TABLES `friendships` WRITE;
/*!40000 ALTER TABLE `friendships` DISABLE KEYS */;
INSERT INTO `friendships` VALUES (960001,900003,900004,1,NULL,'alice->bob','2026-01-04 03:18:57'),(960002,900003,900005,1,NULL,'alice->charlie','2026-01-04 03:18:57'),(960003,900003,900006,1,NULL,'alice->diana','2026-01-04 03:18:57'),(960004,900003,900013,1,NULL,'alice->kate (exclude candidate)','2026-01-04 03:18:57'),(960010,900004,900007,1,NULL,'bob->eve','2026-01-04 03:18:57'),(960011,900005,900007,1,NULL,'charlie->eve','2026-01-04 03:18:57'),(960012,900006,900007,1,NULL,'diana->eve','2026-01-04 03:18:57'),(960013,900004,900011,1,NULL,'bob->ivy','2026-01-04 03:18:57'),(960014,900005,900011,1,NULL,'charlie->ivy','2026-01-04 03:18:57'),(960015,900006,900011,1,NULL,'diana->ivy','2026-01-04 03:18:57'),(960016,900005,900009,1,NULL,'charlie->grace','2026-01-04 03:18:57'),(960017,900006,900009,1,NULL,'diana->grace','2026-01-04 03:18:57'),(960018,900004,900015,1,NULL,'bob->mia','2026-01-04 03:18:57'),(960019,900006,900015,1,NULL,'diana->mia','2026-01-04 03:18:57'),(960020,900004,900013,1,NULL,'bob->kate','2026-01-04 03:18:57'),(960021,900005,900013,1,NULL,'charlie->kate','2026-01-04 03:18:57'),(960022,900004,900008,1,NULL,'bob->frank','2026-01-04 03:18:57');
/*!40000 ALTER TABLE `friendships` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friendships_change_ai` AFTER INSERT ON `friendships` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friendships', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friendships', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friendships_change_au` AFTER UPDATE ON `friendships` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friendships', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friendships', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_friendships_change_ad` AFTER DELETE ON `friendships` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friendships', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friendships', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `meeting_permissions`
--

DROP TABLE IF EXISTS `meeting_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `meeting_id` int NOT NULL,
  `user_id` int NOT NULL,
  `role_id` int NOT NULL COMMENT '氓录鈥⒚р€澛β澠捗┾劉聬猫搂鈥櫭ㄢ€奥?,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_meeting_user` (`meeting_id`,`user_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `idx_meeting` (`meeting_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_role` (`role_id`),
  CONSTRAINT `meeting_permissions_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meeting_permissions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meeting_permissions_ibfk_3` FOREIGN KEY (`role_id`) REFERENCES `permission_roles` (`id`),
  CONSTRAINT `meeting_permissions_ibfk_4` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=206 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_permissions`
--

LOCK TABLES `meeting_permissions` WRITE;
/*!40000 ALTER TABLE `meeting_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_permissions` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_meeting_permissions_change_ai` AFTER INSERT ON `meeting_permissions` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_permissions', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_permissions', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_meeting_permissions_change_au` AFTER UPDATE ON `meeting_permissions` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_permissions', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_permissions', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_meeting_permissions_change_ad` AFTER DELETE ON `meeting_permissions` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_permissions', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_permissions', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `meeting_recordings`
--

DROP TABLE IF EXISTS `meeting_recordings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_recordings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `meeting_id` int NOT NULL,
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_meeting_id` (`meeting_id`),
  CONSTRAINT `meeting_recordings_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=703 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_recordings`
--

LOCK TABLES `meeting_recordings` WRITE;
/*!40000 ALTER TABLE `meeting_recordings` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_recordings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_meeting_recordings_change_ai` AFTER INSERT ON `meeting_recordings` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_recordings', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_recordings', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_meeting_recordings_change_au` AFTER UPDATE ON `meeting_recordings` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_recordings', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_recordings', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_meeting_recordings_change_ad` AFTER DELETE ON `meeting_recordings` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_recordings', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_recordings', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `user_id` int NOT NULL,
  `message_type` enum('text','image','file','emoji','system') COLLATE utf8mb4_unicode_ci DEFAULT 'text',
  `content` text COLLATE utf8mb4_unicode_ci,
  `file_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` int DEFAULT NULL,
  `parent_message_id` int DEFAULT NULL,
  `is_edited` tinyint(1) DEFAULT '0',
  `edited_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `parent_message_id` (`parent_message_id`),
  KEY `idx_room_created` (`room_id`,`created_at`),
  KEY `idx_user_room` (`user_id`,`room_id`),
  KEY `idx_messages_room_id` (`room_id`),
  KEY `idx_messages_created_at` (`created_at`),
  KEY `idx_messages_user_created` (`user_id`,`created_at`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`parent_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=940016 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (940001,910001,900001,'text','[S1] 910001 host hello',NULL,NULL,NULL,NULL,0,NULL,'2026-01-01 03:28:57'),(940002,910001,900003,'text','[S1] 910001 alice reply',NULL,NULL,NULL,NULL,0,NULL,'2026-01-01 03:38:57'),(940003,910001,900004,'text','[S1] 910001 bob reply',NULL,NULL,NULL,NULL,0,NULL,'2026-01-01 04:08:57'),(940004,910001,900006,'text','[S1] 910001 diana last msg',NULL,NULL,NULL,NULL,0,NULL,'2026-01-01 04:38:57'),(940005,910002,900004,'text','[S1] 910002 bob msg (5h)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-03 22:18:57'),(940006,910002,900003,'text','[S1] 910002 alice msg (3h)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 00:18:57'),(940007,910002,900012,'text','[S1] 910002 jack msg (90m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 01:48:57'),(940008,910002,900011,'text','[S1] 910002 ivy msg (60m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 02:18:57'),(940009,910002,900006,'text','[S1] 910002 diana msg (40m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 02:38:57'),(940010,910002,900001,'text','[S1] 910002 host msg (5m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 03:13:57'),(940011,910003,900001,'text','[S1] 910003 host msg (45m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 02:33:57'),(940012,910003,900009,'text','[S1] 910003 grace msg (30m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 02:48:57'),(940013,910003,900015,'text','[S1] 910003 mia msg (12m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 03:06:57'),(940014,910003,900001,'text','[S1] 910003 host last msg (1m)',NULL,NULL,NULL,NULL,0,NULL,'2026-01-04 03:17:57'),(940015,910004,900001,'text','[S1] 910004 old msg',NULL,NULL,NULL,NULL,0,NULL,'2025-12-26 03:28:57');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_messages_change_ai` AFTER INSERT ON `messages` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'messages', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'messages', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_messages_change_au` AFTER UPDATE ON `messages` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'messages', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'messages', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_messages_change_ad` AFTER DELETE ON `messages` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'messages', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'messages', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `permission_roles`
--

DROP TABLE IF EXISTS `permission_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'host, co-host, participant',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `can_mute_others` tinyint(1) DEFAULT '0',
  `can_assign_cohost` tinyint(1) DEFAULT '0',
  `can_kick_participants` tinyint(1) DEFAULT '0',
  `can_record_meeting` tinyint(1) DEFAULT '0',
  `can_manage_chat` tinyint(1) DEFAULT '0',
  `can_end_meeting` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission_roles`
--

LOCK TABLES `permission_roles` WRITE;
/*!40000 ALTER TABLE `permission_roles` DISABLE KEYS */;
INSERT INTO `permission_roles` VALUES (1,'host','盲录拧猫庐庐盲赂禄忙艗聛盲潞潞',1,1,1,1,1,1,'2026-01-04 03:13:32','2026-01-04 03:13:32'),(2,'co-host','猫聛鈥澝ヂ嘎ぢ嘎幻ε捖伱ぢ郝?,1,0,1,1,1,0,'2026-01-04 03:13:32','2026-01-04 03:13:32'),(3,'participant','忙鈩⒙┾偓拧氓聫鈥毭ぢ寂∶ㄢ偓鈥?,0,0,0,0,0,0,'2026-01-04 03:13:32','2026-01-04 03:13:32');
/*!40000 ALTER TABLE `permission_roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_permission_roles_change_ai` AFTER INSERT ON `permission_roles` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'permission_roles', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'permission_roles', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_permission_roles_change_au` AFTER UPDATE ON `permission_roles` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'permission_roles', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'permission_roles', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_permission_roles_change_ad` AFTER DELETE ON `permission_roles` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'permission_roles', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'permission_roles', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `room_participants`
--

DROP TABLE IF EXISTS `room_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_participants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `user_id` int NOT NULL,
  `joined_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at` timestamp NULL DEFAULT NULL,
  `participant_status` enum('active','inactive','kicked','left') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `is_muted` tinyint(1) DEFAULT '0',
  `is_video_enabled` tinyint(1) DEFAULT '1',
  `is_screen_sharing` tinyint(1) DEFAULT '0',
  `is_hand_raised` tinyint(1) DEFAULT '0',
  `can_speak` tinyint(1) DEFAULT '1',
  `can_share_screen` tinyint(1) DEFAULT '1',
  `can_enable_video` tinyint(1) DEFAULT '1',
  `can_chat` tinyint(1) DEFAULT '1',
  `last_activity` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_room_user` (`room_id`,`user_id`),
  KEY `idx_room_status` (`room_id`,`participant_status`),
  KEY `idx_user_status` (`user_id`,`participant_status`),
  KEY `idx_room_participants_room_id` (`room_id`),
  KEY `idx_room_participants_user_id` (`user_id`),
  CONSTRAINT `room_participants_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `room_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=920032 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_participants`
--

LOCK TABLES `room_participants` WRITE;
/*!40000 ALTER TABLE `room_participants` DISABLE KEYS */;
INSERT INTO `room_participants` VALUES (920001,910001,900001,'2026-01-01 03:18:57','2026-01-01 04:48:57','left',0,1,0,0,1,1,1,1,'2026-01-01 04:43:57'),(920002,910001,900003,'2026-01-01 03:23:57','2026-01-01 04:46:57','left',0,1,0,0,1,1,1,1,'2026-01-01 04:38:57'),(920003,910001,900004,'2026-01-01 03:24:57','2026-01-01 04:38:57','left',0,1,0,0,1,1,1,1,'2026-01-01 04:33:57'),(920004,910001,900005,'2026-01-01 03:28:57','2026-01-01 04:28:57','left',0,1,0,0,1,1,1,1,'2026-01-01 04:18:57'),(920005,910001,900006,'2026-01-01 03:30:57','2026-01-01 04:48:57','left',0,1,0,0,1,1,1,1,'2026-01-01 04:47:57'),(920006,910002,900001,'2026-01-03 15:18:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:16:57'),(920007,910002,900003,'2026-01-03 21:18:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:10:57'),(920008,910002,900004,'2026-01-03 22:18:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:06:57'),(920009,910002,900006,'2026-01-04 01:48:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:17:57'),(920010,910002,900011,'2026-01-04 02:08:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:14:57'),(920011,910002,900012,'2026-01-04 02:48:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:15:57'),(920012,910002,900008,'2026-01-03 23:18:57','2026-01-04 01:18:57','left',0,1,0,0,1,1,1,1,'2026-01-04 01:23:57'),(920013,910002,900014,'2026-01-04 02:58:57','2026-01-04 03:13:57','left',0,1,0,0,1,1,1,1,'2026-01-04 03:12:57'),(920014,910003,900001,'2026-01-04 02:28:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:17:57'),(920015,910003,900009,'2026-01-04 02:33:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:16:57'),(920016,910003,900015,'2026-01-04 03:03:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:14:57'),(920017,910003,900010,'2026-01-04 03:08:57','2026-01-04 03:16:57','left',0,1,0,0,1,1,1,1,'2026-01-04 03:16:57'),(920018,910004,900001,'2025-12-26 03:18:57','2025-12-26 04:03:57','left',0,1,0,0,1,1,1,1,'2025-12-26 04:02:57'),(920019,910004,900004,'2025-12-26 03:21:57','2025-12-26 03:48:57','left',0,1,0,0,1,1,1,1,'2025-12-26 03:47:57'),(920020,910005,900002,'2026-01-03 19:18:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:12:57'),(920021,910005,900005,'2026-01-03 20:18:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:09:57'),(920022,910005,900006,'2026-01-03 21:18:57','2026-01-04 00:18:57','left',0,1,0,0,1,1,1,1,'2026-01-04 00:20:57'),(920023,910005,900010,'2026-01-04 01:18:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:11:57'),(920024,910005,900007,'2026-01-04 02:48:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:13:57'),(920025,910006,900002,'2026-01-04 02:18:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:17:57'),(920026,910006,900003,'2026-01-04 02:28:57','2026-01-04 02:58:57','left',0,1,0,0,1,1,1,1,'2026-01-04 02:58:57'),(920027,910006,900004,'2026-01-04 02:38:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:15:57'),(920028,910006,900009,'2026-01-04 02:43:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:13:57'),(920029,910006,900011,'2026-01-04 02:53:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:14:57'),(920030,910006,900012,'2026-01-04 03:03:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:16:57'),(920031,910006,900015,'2026-01-04 03:08:57',NULL,'active',0,1,0,0,1,1,1,1,'2026-01-04 03:16:57');
/*!40000 ALTER TABLE `room_participants` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_room_participants_change_ai` AFTER INSERT ON `room_participants` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'room_participants', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'room_participants', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_room_participants_change_au` AFTER UPDATE ON `room_participants` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'room_participants', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'room_participants', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_room_participants_change_ad` AFTER DELETE ON `room_participants` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'room_participants', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'room_participants', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `rooms`
--

DROP TABLE IF EXISTS `rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rooms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `meeting_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '盲录拧猫庐庐莽录鈥撁ヂ徛?MTC+6盲陆聧忙鈥⒙懊ヂ€?,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `host_id` int NOT NULL COMMENT '盲赂禄忙艗聛盲潞潞莽鈥澛λ喡稩D',
  `password` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '盲录拧猫庐庐氓炉鈥犆犅伱寂捗ヂ徛ぢ嘎好┞?,
  `max_participants` int DEFAULT '50',
  `is_waiting_room_enabled` tinyint(1) DEFAULT '1',
  `room_settings` json DEFAULT NULL COMMENT '氓颅藴氓鈥毬ぢ寂∶甭幻ヅ锯€姑ｂ偓聛氓庐鈥懊モ€β久铰€?,
  `scheduled_start` timestamp NULL DEFAULT NULL,
  `scheduled_end` timestamp NULL DEFAULT NULL,
  `actual_start` timestamp NULL DEFAULT NULL COMMENT '氓庐啪茅鈩⑩€γヂ尖偓氓搂鈥姑︹€斅睹┾€斅?,
  `actual_end` timestamp NULL DEFAULT NULL COMMENT '氓庐啪茅鈩⑩€γ烩€溍β澟该︹€斅睹┾€斅?,
  `status` enum('active','ended','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `meeting_code` (`meeting_code`),
  KEY `idx_meeting_code` (`meeting_code`),
  KEY `idx_host_id` (`host_id`),
  KEY `idx_status` (`status`),
  KEY `idx_actual_start` (`actual_start`),
  KEY `idx_rooms_host_id` (`host_id`),
  KEY `idx_rooms_scheduled_start` (`scheduled_start`),
  CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`host_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=910007 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rooms`
--

LOCK TABLES `rooms` WRITE;
/*!40000 ALTER TABLE `rooms` DISABLE KEYS */;
INSERT INTO `rooms` VALUES (910001,'MTCQT001','QT Host1 - Past Ended','S1 demo: ended meeting',900001,NULL,50,1,'{\"level\": 1, \"topic\": \"ended\"}',NULL,NULL,'2026-01-01 03:18:57','2026-01-01 04:48:57','ended','2026-01-04 03:18:57','2026-01-04 03:18:57'),(910002,'MTCQT002','QT Host1 - Big Active','S1+S6 demo: active long room',900001,NULL,50,1,'{\"level\": 2, \"topic\": \"active\"}',NULL,NULL,'2026-01-03 15:18:57',NULL,'active','2026-01-04 03:18:57','2026-01-04 03:18:57'),(910003,'MTCQT003','QT Host1 - New Active','S1 demo: recent active room',900001,NULL,50,1,'{\"level\": 3, \"topic\": \"active\"}',NULL,NULL,'2026-01-04 02:28:57',NULL,'active','2026-01-04 03:18:57','2026-01-04 03:18:57'),(910004,'MTCQT004','QT Host1 - Old Ended','S1 demo: older meeting (threshold test)',900001,NULL,50,1,'{\"level\": 0, \"topic\": \"ended\"}',NULL,NULL,'2025-12-26 03:18:57','2025-12-26 04:03:57','ended','2026-01-04 03:18:57','2026-01-04 03:18:57'),(910005,'MTCQT005','QT Host2 - Long Active','S6 demo: long active room',900002,NULL,50,1,'{\"level\": 2, \"topic\": \"active\"}',NULL,NULL,'2026-01-03 19:18:57',NULL,'active','2026-01-04 03:18:57','2026-01-04 03:18:57'),(910006,'MTCQT006','QT Host2 - Crowd Short','S6 demo: more users, shorter time',900002,NULL,50,1,'{\"level\": 1, \"topic\": \"active\"}',NULL,NULL,'2026-01-04 02:18:57',NULL,'active','2026-01-04 03:18:57','2026-01-04 03:18:57');
/*!40000 ALTER TABLE `rooms` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_rooms_change_ai` AFTER INSERT ON `rooms` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'rooms', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'rooms', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_rooms_change_au` AFTER UPDATE ON `rooms` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'rooms', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'rooms', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_rooms_change_ad` AFTER DELETE ON `rooms` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'rooms', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'rooms', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sync_applied`
--

DROP TABLE IF EXISTS `sync_applied`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sync_applied` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `change_id` bigint NOT NULL,
  `target_db` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('ok','fail') COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_text` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_change_target` (`change_id`,`target_db`),
  CONSTRAINT `fk_sync_applied_change` FOREIGN KEY (`change_id`) REFERENCES `change_log` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=735 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sync_applied`
--

LOCK TABLES `sync_applied` WRITE;
/*!40000 ALTER TABLE `sync_applied` DISABLE KEYS */;
INSERT INTO `sync_applied` VALUES (1,1,'postgres','2026-01-04 03:13:48','fail','updated_at conflict: target(postgres)=2026-01-04T03:14:08.731519 newer than source(2026-01-04T03:13:34)'),(2,1,'oracle','2026-01-04 03:13:48','ok',NULL),(3,2,'postgres','2026-01-04 03:13:48','fail','updated_at conflict: target(postgres)=2026-01-04T03:14:09.948290 newer than source(2026-01-04T03:13:34)'),(4,2,'oracle','2026-01-04 03:13:48','ok',NULL),(5,3,'postgres','2026-01-04 03:13:48','ok',NULL),(6,3,'oracle','2026-01-04 03:13:48','ok',NULL),(7,4,'postgres','2026-01-04 03:13:48','ok',NULL),(8,4,'oracle','2026-01-04 03:13:48','ok',NULL),(9,5,'postgres','2026-01-04 03:13:48','ok',NULL),(10,5,'oracle','2026-01-04 03:13:48','ok',NULL),(11,6,'postgres','2026-01-04 03:13:48','ok',NULL),(12,6,'oracle','2026-01-04 03:13:48','ok',NULL),(13,7,'postgres','2026-01-04 03:13:48','ok',NULL),(14,7,'oracle','2026-01-04 03:13:48','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_ROOMS_HOST) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".rooms (id, meeting_code, name, description, host_id, password, max_participants, is_waiting_room_enabled, room_settings, scheduled_start, scheduled_end, actual_start, actual_end, status, created_at, updated_at) VALUES (:id, :meeting_code, :name, :description, :host_id, :password, :max_participants, :is_waiting_room_enabled, :room_settings, :scheduled_start, :scheduled_end, :actual_start, :actual_end, :status, :created_at, :updated_at)]\n[parameters: {\'id\': 101.0, \'meeting_code\': \'MTC100001\', \'name\': \'Daily Standup\', \'description\': \'Daily sync-up meeting\', \'host_id\': 1.0, \'password\': None, \'max_participants\': 20.0, \'is_waiting_room_enabled\': 1, \'room_settings\': \'{\"chat\": \"enabled\", \"recording\": true}\', \'scheduled_start\': datetime.datetime(2026, 1, 4, 4, 13, 34), \'scheduled_end\': datetime.datetime(2026, 1, 4, 5, 13, 34), \'actual_start\': None, \'actual_end\': None, \'status\': \'active\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'updated_at\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(15,8,'postgres','2026-01-04 03:13:48','ok',NULL),(16,8,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_ROOMS_HOST) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".rooms (id, meeting_code, name, description, host_id, password, max_participants, is_waiting_room_enabled, room_settings, scheduled_start, scheduled_end, actual_start, actual_end, status, created_at, updated_at) VALUES (:id, :meeting_code, :name, :description, :host_id, :password, :max_participants, :is_waiting_room_enabled, :room_settings, :scheduled_start, :scheduled_end, :actual_start, :actual_end, :status, :created_at, :updated_at)]\n[parameters: {\'id\': 102.0, \'meeting_code\': \'MTC100002\', \'name\': \'Project Demo\', \'description\': \'Weekly demo & Q/A\', \'host_id\': 2.0, \'password\': \'1234\', \'max_participants\': 50.0, \'is_waiting_room_enabled\': 1, \'room_settings\': \'{\"chat\": \"enabled\", \"recording\": false}\', \'scheduled_start\': datetime.datetime(2026, 1, 4, 6, 13, 34), \'scheduled_end\': datetime.datetime(2026, 1, 4, 7, 13, 34), \'actual_start\': None, \'actual_end\': None, \'status\': \'active\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'updated_at\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(17,9,'postgres','2026-01-04 03:13:49','ok',NULL),(18,9,'oracle','2026-01-04 03:13:49','ok',NULL),(19,10,'postgres','2026-01-04 03:13:49','fail','updated_at conflict: target(postgres)=2026-01-04T03:13:55.945526 newer than source(2026-01-04T03:13:32)'),(20,10,'oracle','2026-01-04 03:13:49','fail','updated_at conflict: target(oracle)=2026-01-04T03:14:12.217687 newer than source(2026-01-04T03:13:32)'),(21,11,'postgres','2026-01-04 03:13:49','fail','updated_at conflict: target(postgres)=2026-01-04T03:13:55.945526 newer than source(2026-01-04T03:13:32)'),(22,11,'oracle','2026-01-04 03:13:49','fail','updated_at conflict: target(oracle)=2026-01-04T03:14:12.219999 newer than source(2026-01-04T03:13:32)'),(23,12,'postgres','2026-01-04 03:13:49','fail','updated_at conflict: target(postgres)=2026-01-04T03:13:55.945526 newer than source(2026-01-04T03:13:32)'),(24,12,'oracle','2026-01-04 03:13:49','fail','updated_at conflict: target(oracle)=2026-01-04T03:14:12.222142 newer than source(2026-01-04T03:13:32)'),(25,13,'postgres','2026-01-04 03:13:49','ok',NULL),(26,13,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role_id, assigned_by, assigned_at, expires_at) VALUES (:id, :meeting_id, :user_id, :role_id, :assigned_by, :assigned_at, :expires_at)]\n[parameters: {\'id\': 201.0, \'meeting_id\': 101.0, \'user_id\': 1.0, \'role_id\': 1.0, \'assigned_by\': 1.0, \'assigned_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'expires_at\': None}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(27,14,'postgres','2026-01-04 03:13:49','ok',NULL),(28,14,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role_id, assigned_by, assigned_at, expires_at) VALUES (:id, :meeting_id, :user_id, :role_id, :assigned_by, :assigned_at, :expires_at)]\n[parameters: {\'id\': 202.0, \'meeting_id\': 101.0, \'user_id\': 2.0, \'role_id\': 2.0, \'assigned_by\': 1.0, \'assigned_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'expires_at\': None}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(29,15,'postgres','2026-01-04 03:13:49','ok',NULL),(30,15,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role_id, assigned_by, assigned_at, expires_at) VALUES (:id, :meeting_id, :user_id, :role_id, :assigned_by, :assigned_at, :expires_at)]\n[parameters: {\'id\': 203.0, \'meeting_id\': 101.0, \'user_id\': 3.0, \'role_id\': 3.0, \'assigned_by\': 1.0, \'assigned_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'expires_at\': None}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(31,16,'postgres','2026-01-04 03:13:49','ok',NULL),(32,16,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role_id, assigned_by, assigned_at, expires_at) VALUES (:id, :meeting_id, :user_id, :role_id, :assigned_by, :assigned_at, :expires_at)]\n[parameters: {\'id\': 204.0, \'meeting_id\': 102.0, \'user_id\': 2.0, \'role_id\': 1.0, \'assigned_by\': 2.0, \'assigned_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'expires_at\': None}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(33,17,'postgres','2026-01-04 03:13:49','ok',NULL),(34,17,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MP_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_permissions (id, meeting_id, user_id, role_id, assigned_by, assigned_at, expires_at) VALUES (:id, :meeting_id, :user_id, :role_id, :assigned_by, :assigned_at, :expires_at)]\n[parameters: {\'id\': 205.0, \'meeting_id\': 102.0, \'user_id\': 1.0, \'role_id\': 3.0, \'assigned_by\': 2.0, \'assigned_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'expires_at\': None}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(35,18,'postgres','2026-01-04 03:13:49','ok',NULL),(36,18,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 301.0, \'room_id\': 101.0, \'user_id\': 1.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'active\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(37,19,'postgres','2026-01-04 03:13:49','ok',NULL),(38,19,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 302.0, \'room_id\': 101.0, \'user_id\': 2.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'active\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(39,20,'postgres','2026-01-04 03:13:49','ok',NULL),(40,20,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 303.0, \'room_id\': 101.0, \'user_id\': 3.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'active\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(41,21,'postgres','2026-01-04 03:13:49','ok',NULL),(42,21,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 304.0, \'room_id\': 101.0, \'user_id\': 4.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'inactive\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(43,22,'postgres','2026-01-04 03:13:49','ok',NULL),(44,22,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 305.0, \'room_id\': 102.0, \'user_id\': 2.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'active\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(45,23,'postgres','2026-01-04 03:13:49','ok',NULL),(46,23,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 306.0, \'room_id\': 102.0, \'user_id\': 1.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'active\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(47,24,'postgres','2026-01-04 03:13:49','ok',NULL),(48,24,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 307.0, \'room_id\': 102.0, \'user_id\': 5.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'active\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(49,25,'postgres','2026-01-04 03:13:49','ok',NULL),(50,25,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_RP_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".room_participants (id, room_id, user_id, joined_at, left_at, participant_status, is_muted, is_video_enabled, is_screen_sharing, is_hand_raised, can_speak, can_share_screen, can_enable_video, can_chat, last_activity) VALUES (:id, :room_id, :user_id, :joined_at, :left_at, :participant_status, :is_muted, :is_video_enabled, :is_screen_sharing, :is_hand_raised, :can_speak, :can_share_screen, :can_enable_video, :can_chat, :last_activity)]\n[parameters: {\'id\': 308.0, \'room_id\': 102.0, \'user_id\': 6.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'left_at\': None, \'participant_status\': \'left\', \'is_muted\': 0, \'is_video_enabled\': 1, \'is_screen_sharing\': 0, \'is_hand_raised\': 0, \'can_speak\': 1, \'can_share_screen\': 1, \'can_enable_video\': 1, \'can_chat\': 1, \'last_activity\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(51,26,'postgres','2026-01-04 03:13:49','ok',NULL),(52,26,'oracle','2026-01-04 03:13:49','ok',NULL),(53,27,'postgres','2026-01-04 03:13:49','ok',NULL),(54,27,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1001.0, \'room_id\': 101.0, \'user_id\': 1.0, \'message_type\': \'text\', \'content\': \'Morning! Standup starts in 5 minutes.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': None, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 2, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(55,28,'postgres','2026-01-04 03:13:49','ok',NULL),(56,28,'oracle','2026-01-04 03:13:49','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1002.0, \'room_id\': 101.0, \'user_id\': 2.0, \'message_type\': \'text\', \'content\': \'On my way.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1001.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 2, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(57,29,'postgres','2026-01-04 03:13:50','ok',NULL),(58,29,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1003.0, \'room_id\': 101.0, \'user_id\': 3.0, \'message_type\': \'text\', \'content\': \'Today I will finish the sync worker module.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': None, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 2, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(59,30,'postgres','2026-01-04 03:13:50','ok',NULL),(60,30,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1004.0, \'room_id\': 101.0, \'user_id\': 1.0, \'message_type\': \'text\', \'content\': \'Great. Any blockers?\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1003.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 2, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(61,31,'postgres','2026-01-04 03:13:50','ok',NULL),(62,31,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1005.0, \'room_id\': 101.0, \'user_id\': 3.0, \'message_type\': \'text\', \'content\': \'Need to verify Oracle triggers.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1004.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 2, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(63,32,'postgres','2026-01-04 03:13:50','ok',NULL),(64,32,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1010.0, \'room_id\': 101.0, \'user_id\': 2.0, \'message_type\': \'text\', \'content\': \'Pushed a fix for conflicts UI.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': None, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 3, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(65,33,'postgres','2026-01-04 03:13:50','ok',NULL),(66,33,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1011.0, \'room_id\': 101.0, \'user_id\': 4.0, \'message_type\': \'text\', \'content\': \'I can review after lunch.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': None, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 3, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(67,34,'postgres','2026-01-04 03:13:50','ok',NULL),(68,34,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1012.0, \'room_id\': 101.0, \'user_id\': 1.0, \'message_type\': \'text\', \'content\': \'OK.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1011.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 3, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(69,35,'postgres','2026-01-04 03:13:50','ok',NULL),(70,35,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1101.0, \'room_id\': 102.0, \'user_id\': 2.0, \'message_type\': \'text\', \'content\': \'Demo agenda: sync, conflicts, reports.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': None, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 1, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(71,36,'postgres','2026-01-04 03:13:50','ok',NULL),(72,36,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1102.0, \'room_id\': 102.0, \'user_id\': 1.0, \'message_type\': \'text\', \'content\': \'I will present the query optimization part.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1101.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 1, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(73,37,'postgres','2026-01-04 03:13:50','ok',NULL),(74,37,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1103.0, \'room_id\': 102.0, \'user_id\': 5.0, \'message_type\': \'text\', \'content\': \'Can we also show audit_log?\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1101.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 1, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(75,38,'postgres','2026-01-04 03:13:50','ok',NULL),(76,38,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1104.0, \'room_id\': 102.0, \'user_id\': 2.0, \'message_type\': \'text\', \'content\': \'Yes, included.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1103.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 1, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(77,39,'postgres','2026-01-04 03:13:50','ok',NULL),(78,39,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1110.0, \'room_id\': 102.0, \'user_id\': 6.0, \'message_type\': \'text\', \'content\': \'Sorry I missed the meeting.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': None, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 3, 17, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(79,40,'postgres','2026-01-04 03:13:50','ok',NULL),(80,40,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1111.0, \'room_id\': 102.0, \'user_id\': 2.0, \'message_type\': \'text\', \'content\': \'No worries.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': 1110.0, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 3, 18, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(81,41,'postgres','2026-01-04 03:13:50','ok',NULL),(82,41,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_MSG_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".messages (id, room_id, user_id, message_type, content, file_url, file_name, file_size, parent_message_id, is_edited, edited_at, created_at) VALUES (:id, :room_id, :user_id, :message_type, :content, :file_url, :file_name, :file_size, :parent_message_id, :is_edited, :edited_at, :created_at)]\n[parameters: {\'id\': 1112.0, \'room_id\': 102.0, \'user_id\': 1.0, \'message_type\': \'text\', \'content\': \'Next demo is tomorrow.\', \'file_url\': None, \'file_name\': None, \'file_size\': None, \'parent_message_id\': None, \'is_edited\': 0, \'edited_at\': None, \'created_at\': datetime.datetime(2026, 1, 4, 1, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(83,42,'postgres','2026-01-04 03:13:50','ok',NULL),(84,42,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FRIENDSHIPS_USER) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friendships (id, user_id, friend_id, category_id, custom_category_name, note, created_at) VALUES (:id, :user_id, :friend_id, :category_id, :custom_category_name, :note, :created_at)]\n[parameters: {\'id\': 401.0, \'user_id\': 1.0, \'friend_id\': 2.0, \'category_id\': 1.0, \'custom_category_name\': None, \'note\': \'Teammate\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(85,43,'postgres','2026-01-04 03:13:50','ok',NULL),(86,43,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FRIENDSHIPS_USER) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friendships (id, user_id, friend_id, category_id, custom_category_name, note, created_at) VALUES (:id, :user_id, :friend_id, :category_id, :custom_category_name, :note, :created_at)]\n[parameters: {\'id\': 402.0, \'user_id\': 1.0, \'friend_id\': 3.0, \'category_id\': 3.0, \'custom_category_name\': None, \'note\': \'Friend\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(87,44,'postgres','2026-01-04 03:13:50','ok',NULL),(88,44,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FRIENDSHIPS_USER) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friendships (id, user_id, friend_id, category_id, custom_category_name, note, created_at) VALUES (:id, :user_id, :friend_id, :category_id, :custom_category_name, :note, :created_at)]\n[parameters: {\'id\': 403.0, \'user_id\': 2.0, \'friend_id\': 3.0, \'category_id\': 4.0, \'custom_category_name\': None, \'note\': \'Workmate\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(89,45,'postgres','2026-01-04 03:13:50','ok',NULL),(90,45,'oracle','2026-01-04 03:13:50','ok',NULL),(91,46,'postgres','2026-01-04 03:13:50','ok',NULL),(92,46,'oracle','2026-01-04 03:13:50','ok',NULL),(93,47,'postgres','2026-01-04 03:13:50','ok',NULL),(94,47,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_FR_TO) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".friend_requests (id, from_user_id, to_user_id, message, category_id, status, created_at, responded_at) VALUES (:id, :from_user_id, :to_user_id, :message, :category_id, :status, :created_at, :responded_at)]\n[parameters: {\'id\': 502.0, \'from_user_id\': 6.0, \'to_user_id\': 1.0, \'message\': \'Alice, can you approve me?\', \'category_id\': 1.0, \'status\': \'pending\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'responded_at\': None}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(95,48,'postgres','2026-01-04 03:13:50','ok',NULL),(96,48,'oracle','2026-01-04 03:13:50','ok',NULL),(97,49,'postgres','2026-01-04 03:13:50','ok',NULL),(98,49,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_WR_ROOM) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".waiting_room (id, room_id, user_id, joined_at, admitted_by, admitted_at, status) VALUES (:id, :room_id, :user_id, :joined_at, :admitted_by, :admitted_at, :status)]\n[parameters: {\'id\': 601.0, \'room_id\': 102.0, \'user_id\': 6.0, \'joined_at\': datetime.datetime(2026, 1, 4, 3, 13, 34), \'admitted_by\': None, \'admitted_at\': None, \'status\': \'waiting\'}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(99,50,'postgres','2026-01-04 03:13:50','ok',NULL),(100,50,'oracle','2026-01-04 03:13:50','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_REC_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_recordings (id, meeting_id, file_path, created_at) VALUES (:id, :meeting_id, :file_path, :created_at)]\n[parameters: {\'id\': 701.0, \'meeting_id\': 101.0, \'file_path\': \'/recordings/room101_demo.mp4\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(505,51,'postgres','2026-01-04 03:14:26','ok',NULL),(506,51,'oracle','2026-01-04 03:14:26','fail','(oracledb.exceptions.IntegrityError) ORA-02291: integrity constraint (LHY.FK_REC_MEETING) violated - parent key not found\nHelp: https://docs.oracle.com/error-help/db/ora-02291/\n[SQL: INSERT INTO \"LHY\".meeting_recordings (id, meeting_id, file_path, created_at) VALUES (:id, :meeting_id, :file_path, :created_at)]\n[parameters: {\'id\': 702.0, \'meeting_id\': 102.0, \'file_path\': \'/recordings/room102_demo.mp4\', \'created_at\': datetime.datetime(2026, 1, 4, 3, 13, 34)}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)'),(507,52,'postgres','2026-01-04 03:14:56','ok',NULL),(508,52,'oracle','2026-01-04 03:14:57','ok',NULL),(509,54,'postgres','2026-01-04 03:16:12','ok',NULL),(510,54,'oracle','2026-01-04 03:16:12','ok',NULL),(511,55,'postgres','2026-01-04 03:16:12','ok',NULL),(512,55,'oracle','2026-01-04 03:16:12','ok',NULL),(513,56,'postgres','2026-01-04 03:16:13','ok',NULL),(514,56,'oracle','2026-01-04 03:16:13','ok',NULL),(515,57,'postgres','2026-01-04 03:16:13','ok',NULL),(516,57,'oracle','2026-01-04 03:16:13','ok',NULL),(517,58,'postgres','2026-01-04 03:16:13','ok',NULL),(518,58,'oracle','2026-01-04 03:16:13','ok',NULL),(519,59,'postgres','2026-01-04 03:16:13','ok',NULL),(520,59,'oracle','2026-01-04 03:16:13','ok',NULL),(521,60,'postgres','2026-01-04 03:16:13','ok',NULL),(522,60,'oracle','2026-01-04 03:16:13','ok',NULL),(523,61,'postgres','2026-01-04 03:16:13','ok',NULL),(524,61,'oracle','2026-01-04 03:16:13','ok',NULL),(525,62,'postgres','2026-01-04 03:16:13','ok',NULL),(526,62,'oracle','2026-01-04 03:16:13','ok',NULL),(527,63,'postgres','2026-01-04 03:16:14','ok',NULL),(528,63,'oracle','2026-01-04 03:16:14','ok',NULL),(529,64,'postgres','2026-01-04 03:16:14','ok',NULL),(530,64,'oracle','2026-01-04 03:16:14','ok',NULL),(531,65,'postgres','2026-01-04 03:16:14','ok',NULL),(532,65,'oracle','2026-01-04 03:16:14','ok',NULL),(533,66,'postgres','2026-01-04 03:16:32','fail','updated_at conflict: target(postgres)=2026-01-04T03:16:31.570283 newer than source(2026-01-04T03:16:31)'),(534,66,'oracle','2026-01-04 03:16:32','fail','updated_at conflict: target(oracle)=2026-01-04T03:16:31.590299 newer than source(2026-01-04T03:16:31)'),(535,67,'postgres','2026-01-04 03:16:32','fail','updated_at conflict: target(postgres)=2026-01-04T03:16:32.805580 newer than source(2026-01-04T03:16:31)'),(536,67,'oracle','2026-01-04 03:16:32','fail','updated_at conflict: target(oracle)=2026-01-04T03:16:31.590299 newer than source(2026-01-04T03:16:31)'),(539,69,'postgres','2026-01-04 03:16:38','fail','updated_at conflict: target(postgres)=2026-01-04T03:16:37.743525 newer than source(2026-01-04T03:16:37)'),(540,69,'oracle','2026-01-04 03:16:39','fail','updated_at conflict: target(oracle)=2026-01-04T03:16:37.750119 newer than source(2026-01-04T03:16:37)'),(541,70,'postgres','2026-01-04 03:16:39','fail','updated_at conflict: target(postgres)=2026-01-04T03:16:38.969933 newer than source(2026-01-04T03:16:37)'),(542,70,'oracle','2026-01-04 03:16:39','fail','updated_at conflict: target(oracle)=2026-01-04T03:16:37.750119 newer than source(2026-01-04T03:16:37)'),(545,72,'postgres','2026-01-04 03:16:40','fail','updated_at conflict: target(postgres)=2026-01-04T03:16:40.825934 newer than source(2026-01-04T03:16:39)'),(546,72,'oracle','2026-01-04 03:16:41','fail','updated_at conflict: target(oracle)=2026-01-04T03:16:39.605633 newer than source(2026-01-04T03:16:39)'),(547,71,'postgres','2026-01-04 03:16:41','fail','updated_at conflict: target(postgres)=2026-01-04T03:16:40.825934 newer than source(2026-01-04T03:16:39)'),(548,71,'oracle','2026-01-04 03:16:41','fail','updated_at conflict: target(oracle)=2026-01-04T03:16:39.605633 newer than source(2026-01-04T03:16:39)'),(549,74,'postgres','2026-01-04 03:18:59','ok',NULL),(550,74,'oracle','2026-01-04 03:18:59','ok',NULL),(551,75,'postgres','2026-01-04 03:18:59','ok',NULL),(552,75,'oracle','2026-01-04 03:18:59','ok',NULL),(553,76,'postgres','2026-01-04 03:18:59','ok',NULL),(554,76,'oracle','2026-01-04 03:18:59','ok',NULL),(555,77,'postgres','2026-01-04 03:19:00','ok',NULL),(556,77,'oracle','2026-01-04 03:19:00','ok',NULL),(557,78,'postgres','2026-01-04 03:19:00','ok',NULL),(558,78,'oracle','2026-01-04 03:19:00','ok',NULL),(559,79,'postgres','2026-01-04 03:19:00','ok',NULL),(560,79,'oracle','2026-01-04 03:19:00','ok',NULL),(561,80,'postgres','2026-01-04 03:19:00','ok',NULL),(562,80,'oracle','2026-01-04 03:19:00','ok',NULL),(563,81,'postgres','2026-01-04 03:19:00','ok',NULL),(564,81,'oracle','2026-01-04 03:19:00','ok',NULL),(565,82,'postgres','2026-01-04 03:19:00','ok',NULL),(566,82,'oracle','2026-01-04 03:19:00','ok',NULL),(567,83,'postgres','2026-01-04 03:19:00','ok',NULL),(568,83,'oracle','2026-01-04 03:19:00','ok',NULL),(569,84,'postgres','2026-01-04 03:19:01','ok',NULL),(570,84,'oracle','2026-01-04 03:19:01','ok',NULL),(571,85,'postgres','2026-01-04 03:19:01','ok',NULL),(572,85,'oracle','2026-01-04 03:19:01','ok',NULL),(573,86,'postgres','2026-01-04 03:19:01','ok',NULL),(574,86,'oracle','2026-01-04 03:19:01','ok',NULL),(575,87,'postgres','2026-01-04 03:19:01','ok',NULL),(576,87,'oracle','2026-01-04 03:19:01','ok',NULL),(577,88,'postgres','2026-01-04 03:19:01','ok',NULL),(578,88,'oracle','2026-01-04 03:19:01','ok',NULL),(579,89,'postgres','2026-01-04 03:19:01','ok',NULL),(580,89,'oracle','2026-01-04 03:19:01','ok',NULL),(581,90,'postgres','2026-01-04 03:19:01','ok',NULL),(582,90,'oracle','2026-01-04 03:19:01','ok',NULL),(583,91,'postgres','2026-01-04 03:19:02','ok',NULL),(584,91,'oracle','2026-01-04 03:19:02','ok',NULL),(585,92,'postgres','2026-01-04 03:19:02','ok',NULL),(586,92,'oracle','2026-01-04 03:19:02','ok',NULL),(587,93,'postgres','2026-01-04 03:19:02','ok',NULL),(588,93,'oracle','2026-01-04 03:19:02','ok',NULL),(589,94,'postgres','2026-01-04 03:19:02','ok',NULL),(590,94,'oracle','2026-01-04 03:19:02','ok',NULL),(591,95,'postgres','2026-01-04 03:19:03','ok',NULL),(592,95,'oracle','2026-01-04 03:19:03','ok',NULL),(593,96,'postgres','2026-01-04 03:19:03','ok',NULL),(594,96,'oracle','2026-01-04 03:19:03','ok',NULL),(595,97,'postgres','2026-01-04 03:19:03','ok',NULL),(596,97,'oracle','2026-01-04 03:19:03','ok',NULL),(597,98,'postgres','2026-01-04 03:19:03','ok',NULL),(598,98,'oracle','2026-01-04 03:19:03','ok',NULL),(599,99,'postgres','2026-01-04 03:19:03','ok',NULL),(600,99,'oracle','2026-01-04 03:19:03','ok',NULL),(601,100,'postgres','2026-01-04 03:19:04','ok',NULL),(602,100,'oracle','2026-01-04 03:19:04','ok',NULL),(603,101,'postgres','2026-01-04 03:19:04','ok',NULL),(604,101,'oracle','2026-01-04 03:19:04','ok',NULL),(605,102,'postgres','2026-01-04 03:19:04','ok',NULL),(606,102,'oracle','2026-01-04 03:19:04','ok',NULL),(607,103,'postgres','2026-01-04 03:19:04','ok',NULL),(608,103,'oracle','2026-01-04 03:19:04','ok',NULL),(609,104,'postgres','2026-01-04 03:19:04','ok',NULL),(610,104,'oracle','2026-01-04 03:19:04','ok',NULL),(611,105,'postgres','2026-01-04 03:19:05','ok',NULL),(612,105,'oracle','2026-01-04 03:19:05','ok',NULL),(613,106,'postgres','2026-01-04 03:19:05','ok',NULL),(614,106,'oracle','2026-01-04 03:19:05','ok',NULL),(615,107,'postgres','2026-01-04 03:19:05','ok',NULL),(616,107,'oracle','2026-01-04 03:19:05','ok',NULL),(617,108,'postgres','2026-01-04 03:19:05','ok',NULL),(618,108,'oracle','2026-01-04 03:19:05','ok',NULL),(619,109,'postgres','2026-01-04 03:19:05','ok',NULL),(620,109,'oracle','2026-01-04 03:19:06','ok',NULL),(621,110,'postgres','2026-01-04 03:19:06','ok',NULL),(622,110,'oracle','2026-01-04 03:19:06','ok',NULL),(623,111,'postgres','2026-01-04 03:19:06','ok',NULL),(624,111,'oracle','2026-01-04 03:19:06','ok',NULL),(625,112,'postgres','2026-01-04 03:19:06','ok',NULL),(626,112,'oracle','2026-01-04 03:19:06','ok',NULL),(627,113,'postgres','2026-01-04 03:19:06','ok',NULL),(628,113,'oracle','2026-01-04 03:19:06','ok',NULL),(629,114,'postgres','2026-01-04 03:19:06','ok',NULL),(630,114,'oracle','2026-01-04 03:19:06','ok',NULL),(631,115,'postgres','2026-01-04 03:19:06','ok',NULL),(632,115,'oracle','2026-01-04 03:19:06','ok',NULL),(633,116,'postgres','2026-01-04 03:19:06','ok',NULL),(634,116,'oracle','2026-01-04 03:19:07','ok',NULL),(635,117,'postgres','2026-01-04 03:19:07','ok',NULL),(636,117,'oracle','2026-01-04 03:19:07','ok',NULL),(637,118,'postgres','2026-01-04 03:19:07','ok',NULL),(638,118,'oracle','2026-01-04 03:19:07','ok',NULL),(639,119,'postgres','2026-01-04 03:19:07','ok',NULL),(640,119,'oracle','2026-01-04 03:19:07','ok',NULL),(641,120,'postgres','2026-01-04 03:19:07','ok',NULL),(642,120,'oracle','2026-01-04 03:19:07','ok',NULL),(643,121,'postgres','2026-01-04 03:19:07','ok',NULL),(644,121,'oracle','2026-01-04 03:19:07','ok',NULL),(645,122,'postgres','2026-01-04 03:19:07','ok',NULL),(646,122,'oracle','2026-01-04 03:19:07','ok',NULL),(647,123,'postgres','2026-01-04 03:19:07','ok',NULL),(648,123,'oracle','2026-01-04 03:19:08','ok',NULL),(649,124,'postgres','2026-01-04 03:19:10','ok',NULL),(650,124,'oracle','2026-01-04 03:19:10','ok',NULL),(651,125,'postgres','2026-01-04 03:19:10','ok',NULL),(652,125,'oracle','2026-01-04 03:19:10','ok',NULL),(653,126,'postgres','2026-01-04 03:19:10','ok',NULL),(654,126,'oracle','2026-01-04 03:19:10','ok',NULL),(655,127,'postgres','2026-01-04 03:19:10','ok',NULL),(656,127,'oracle','2026-01-04 03:19:10','ok',NULL),(657,128,'postgres','2026-01-04 03:19:10','ok',NULL),(658,128,'oracle','2026-01-04 03:19:10','ok',NULL),(659,129,'postgres','2026-01-04 03:19:10','ok',NULL),(660,129,'oracle','2026-01-04 03:19:11','ok',NULL),(661,130,'postgres','2026-01-04 03:19:11','ok',NULL),(662,130,'oracle','2026-01-04 03:19:11','ok',NULL),(663,161,'postgres','2025-12-27 03:19:13','ok',NULL),(664,161,'oracle','2025-12-27 03:19:14','ok',NULL),(665,162,'postgres','2025-12-29 03:19:13','ok',NULL),(666,162,'oracle','2025-12-29 03:19:15','fail','DEMO: ORA-00001 unique constraint violated'),(667,163,'postgres','2025-12-29 03:19:12','ok',NULL),(668,163,'oracle','2025-12-29 03:19:13','ok',NULL),(669,164,'postgres','2026-01-02 03:19:19','fail','DEMO: deadlock detected'),(670,164,'oracle','2026-01-02 03:19:21','fail','DEMO: FK missing parent'),(671,165,'postgres','2026-01-03 03:19:13','ok',NULL),(672,165,'oracle','2026-01-03 03:19:14','ok',NULL),(673,131,'postgres','2026-01-04 03:19:11','ok',NULL),(674,131,'oracle','2026-01-04 03:19:11','ok',NULL),(675,132,'postgres','2026-01-04 03:19:11','ok',NULL),(676,132,'oracle','2026-01-04 03:19:11','ok',NULL),(677,133,'postgres','2026-01-04 03:19:11','ok',NULL),(678,133,'oracle','2026-01-04 03:19:11','ok',NULL),(679,134,'postgres','2026-01-04 03:19:11','ok',NULL),(680,134,'oracle','2026-01-04 03:19:12','ok',NULL),(681,135,'postgres','2026-01-04 03:19:12','ok',NULL),(682,135,'oracle','2026-01-04 03:19:12','ok',NULL),(683,136,'postgres','2026-01-04 03:19:12','ok',NULL),(684,136,'oracle','2026-01-04 03:19:12','ok',NULL),(685,137,'postgres','2026-01-04 03:19:12','ok',NULL),(686,137,'oracle','2026-01-04 03:19:12','ok',NULL),(687,138,'postgres','2026-01-04 03:19:12','ok',NULL),(688,138,'oracle','2026-01-04 03:19:12','ok',NULL),(689,139,'postgres','2026-01-04 03:19:13','ok',NULL),(690,139,'oracle','2026-01-04 03:19:13','ok',NULL),(691,140,'postgres','2026-01-04 03:19:13','ok',NULL),(692,140,'oracle','2026-01-04 03:19:13','ok',NULL),(693,141,'postgres','2026-01-04 03:19:13','ok',NULL),(694,141,'oracle','2026-01-04 03:19:13','ok',NULL),(695,142,'postgres','2026-01-04 03:19:13','ok',NULL),(696,142,'oracle','2026-01-04 03:19:13','ok',NULL),(697,143,'postgres','2026-01-04 03:19:13','ok',NULL),(698,143,'oracle','2026-01-04 03:19:13','ok',NULL),(699,144,'postgres','2026-01-04 03:19:13','ok',NULL),(700,144,'oracle','2026-01-04 03:19:13','ok',NULL),(701,145,'postgres','2026-01-04 03:19:13','ok',NULL),(702,145,'oracle','2026-01-04 03:19:14','ok',NULL),(703,146,'postgres','2026-01-04 03:19:14','ok',NULL),(704,146,'oracle','2026-01-04 03:19:14','ok',NULL),(705,147,'postgres','2026-01-04 03:19:14','ok',NULL),(706,147,'oracle','2026-01-04 03:19:14','ok',NULL),(707,148,'postgres','2026-01-04 03:19:14','ok',NULL),(708,148,'oracle','2026-01-04 03:19:14','ok',NULL),(709,149,'postgres','2026-01-04 03:19:14','ok',NULL),(710,149,'oracle','2026-01-04 03:19:14','ok',NULL),(711,150,'postgres','2026-01-04 03:19:14','ok',NULL),(712,150,'oracle','2026-01-04 03:19:14','ok',NULL),(713,151,'postgres','2026-01-04 03:19:14','ok',NULL),(714,151,'oracle','2026-01-04 03:19:15','ok',NULL),(715,152,'postgres','2026-01-04 03:19:15','ok',NULL),(716,152,'oracle','2026-01-04 03:19:15','ok',NULL),(717,153,'postgres','2026-01-04 03:19:15','ok',NULL),(718,153,'oracle','2026-01-04 03:19:15','ok',NULL),(719,154,'postgres','2026-01-04 03:19:15','ok',NULL),(720,154,'oracle','2026-01-04 03:19:15','ok',NULL),(721,155,'postgres','2026-01-04 03:19:15','ok',NULL),(722,155,'oracle','2026-01-04 03:19:16','ok',NULL),(723,156,'postgres','2026-01-04 03:19:16','ok',NULL),(724,156,'oracle','2026-01-04 03:19:16','ok',NULL),(725,157,'postgres','2026-01-04 03:19:16','ok',NULL),(726,157,'oracle','2026-01-04 03:19:16','ok',NULL),(727,158,'postgres','2026-01-04 03:19:16','ok',NULL),(728,158,'oracle','2026-01-04 03:19:16','ok',NULL),(729,159,'postgres','2026-01-04 03:19:16','ok',NULL),(730,159,'oracle','2026-01-04 03:19:16','ok',NULL),(731,160,'postgres','2026-01-04 03:19:16','ok',NULL),(732,160,'oracle','2026-01-04 03:19:16','ok',NULL);
/*!40000 ALTER TABLE `sync_applied` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sync_stats_daily`
--

DROP TABLE IF EXISTS `sync_stats_daily`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sync_stats_daily` (
  `stat_date` date NOT NULL,
  `total_events` int NOT NULL DEFAULT '0',
  `applied_ok` int NOT NULL DEFAULT '0',
  `applied_fail` int NOT NULL DEFAULT '0',
  `conflicts` int NOT NULL DEFAULT '0',
  `avg_lag_ms` int NOT NULL DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sync_stats_daily`
--

LOCK TABLES `sync_stats_daily` WRITE;
/*!40000 ALTER TABLE `sync_stats_daily` DISABLE KEYS */;
INSERT INTO `sync_stats_daily` VALUES ('2025-12-26',8,14,2,1,180,'2026-01-04 03:19:11'),('2025-12-27',12,22,3,2,240,'2026-01-04 03:19:11'),('2025-12-28',10,18,1,0,120,'2026-01-04 03:19:11'),('2025-12-29',16,28,4,3,310,'2026-01-04 03:19:11'),('2025-12-30',6,10,0,0,95,'2026-01-04 03:19:11'),('2025-12-31',14,24,2,1,160,'2026-01-04 03:19:11'),('2026-01-01',20,34,6,4,420,'2026-01-04 03:19:11'),('2026-01-02',9,15,2,1,210,'2026-01-04 03:19:11'),('2026-01-03',7,12,1,0,130,'2026-01-04 03:19:11'),('2026-01-04',160,259,61,61,560676,'2026-01-04 03:19:19');
/*!40000 ALTER TABLE `sync_stats_daily` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `personal_tag` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('online','offline','busy') COLLATE utf8mb4_unicode_ci DEFAULT 'offline',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_email` (`email`),
  KEY `idx_users_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=993592 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'alice','alice@example.com','pwd',NULL,'Alice',NULL,'online',NULL,'2026-01-04 03:13:34','2026-01-04 03:13:34'),(2,'bob','bob@example.com','pwd',NULL,'Bob',NULL,'online',NULL,'2026-01-04 03:13:34','2026-01-04 03:13:34'),(4,'dave','dave@example.com','pwd',NULL,'Dave',NULL,'busy',NULL,'2026-01-04 03:13:34','2026-01-04 03:13:34'),(5,'erin','erin@example.com','pwd',NULL,'Erin',NULL,'offline',NULL,'2026-01-04 03:13:34','2026-01-04 03:13:34'),(6,'frank','frank@example.com','pwd',NULL,'Frank',NULL,'online',NULL,'2026-01-04 03:13:34','2026-01-04 03:13:34'),(7,'u1','u1@example.com','pwd',NULL,NULL,NULL,'offline',NULL,'2026-01-04 03:14:56','2026-01-04 03:14:56'),(900001,'qt_host1','qt_host1@example.com','pass',NULL,'QT Host1',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900002,'qt_host2','qt_host2@example.com','pass',NULL,'QT Host2',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900003,'qt_alice','qt_alice@example.com','pass',NULL,'QT Alice',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900004,'qt_bob','qt_bob@example.com','pass',NULL,'QT Bob',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900005,'qt_charlie','qt_charlie@example.com','pass',NULL,'QT Charlie',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900006,'qt_diana','qt_diana@example.com','pass',NULL,'QT Diana',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900007,'qt_eve','qt_eve@example.com','pass',NULL,'QT Eve',NULL,'offline',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900008,'qt_frank','qt_frank@example.com','pass',NULL,'QT Frank',NULL,'offline',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900009,'qt_grace','qt_grace@example.com','pass',NULL,'QT Grace',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900010,'qt_hank','qt_hank@example.com','pass',NULL,'QT Hank',NULL,'offline',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900011,'qt_ivy','qt_ivy@example.com','pass',NULL,'QT Ivy',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900012,'qt_jack','qt_jack@example.com','pass',NULL,'QT Jack',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900013,'qt_kate','qt_kate@example.com','pass',NULL,'QT Kate',NULL,'offline',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900014,'qt_lucas','qt_lucas@example.com','pass',NULL,'QT Lucas',NULL,'offline',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(900015,'qt_mia','qt_mia@example.com','pass',NULL,'QT Mia',NULL,'online',NULL,'2026-01-04 03:18:57','2026-01-04 03:18:57'),(907524,'zz__dbss_demo__8b17846fd0d14de392dd','zz__dbss_demo__8b17846fd0d14de392dd@dbss.invalid','pwd',NULL,'Source 8b1784',NULL,'online',NULL,'2026-01-04 03:16:39','2026-01-04 03:16:39'),(921952,'zz__dbss_demo__4a5af8396b3248399411','zz__dbss_demo__4a5af8396b3248399411@dbss.invalid','pwd',NULL,'Target 4a5af8',NULL,'busy',NULL,'2026-01-04 03:16:38','2026-01-04 03:16:39'),(993591,'zz__dbss_demo__120b7f6e2d9343539789','zz__dbss_demo__120b7f6e2d9343539789@dbss.invalid','pwd',NULL,'Demo 120b7f',NULL,'offline',NULL,'2026-01-04 03:16:32','2026-01-04 03:16:32');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_change_ai` AFTER INSERT ON `users` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'users', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'users', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_change_au` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'users', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'users', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_change_ad` AFTER DELETE ON `users` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'users', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'users', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `waiting_room`
--

DROP TABLE IF EXISTS `waiting_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waiting_room` (
  `id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `user_id` int NOT NULL,
  `joined_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `admitted_by` int DEFAULT NULL,
  `admitted_at` timestamp NULL DEFAULT NULL,
  `status` enum('waiting','admitted','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'waiting',
  PRIMARY KEY (`id`),
  KEY `admitted_by` (`admitted_by`),
  KEY `idx_room_status` (`room_id`,`status`),
  KEY `idx_user_room` (`user_id`,`room_id`),
  CONSTRAINT `waiting_room_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `waiting_room_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `waiting_room_ibfk_3` FOREIGN KEY (`admitted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=602 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waiting_room`
--

LOCK TABLES `waiting_room` WRITE;
/*!40000 ALTER TABLE `waiting_room` DISABLE KEYS */;
/*!40000 ALTER TABLE `waiting_room` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_waiting_room_change_ai` AFTER INSERT ON `waiting_room` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'waiting_room', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'waiting_room', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_waiting_room_change_au` AFTER UPDATE ON `waiting_room` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'waiting_room', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'waiting_room', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_waiting_room_change_ad` AFTER DELETE ON `waiting_room` FOR EACH ROW BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'waiting_room', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'waiting_room', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping events for database 'video_conference'
--

--
-- Dumping routines for database 'video_conference'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_room_score` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_room_score`(p_room_id INT, p_since_ts DATETIME) RETURNS bigint
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_participant_cnt BIGINT DEFAULT 0;
  DECLARE v_total_minutes BIGINT DEFAULT 0;

  SELECT
    COUNT(DISTINCT user_id) AS participant_cnt,
    COALESCE(
      SUM(
        GREATEST(
          TIMESTAMPDIFF(
            MINUTE,
            GREATEST(joined_at, p_since_ts),
            LEAST(COALESCE(left_at, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
          ),
          0
        )
      ),
      0
    ) AS total_minutes
  INTO v_participant_cnt, v_total_minutes
  FROM room_participants
  WHERE room_id = p_room_id
    AND joined_at <= CURRENT_TIMESTAMP
    AND COALESCE(left_at, CURRENT_TIMESTAMP) >= p_since_ts;

  RETURN COALESCE(v_participant_cnt, 0) * 10 + COALESCE(v_total_minutes, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-04  3:20:51
