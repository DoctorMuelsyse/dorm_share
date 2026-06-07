-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: dorm_share
-- ------------------------------------------------------
-- Server version	8.0.43

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
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `cat_id` int NOT NULL AUTO_INCREMENT,
  `parent_cat_id` int DEFAULT NULL COMMENT '父分类ID，NULL表示一级分类',
  `cat_name` varchar(50) NOT NULL COMMENT '分类名称',
  PRIMARY KEY (`cat_id`),
  KEY `parent_cat_id` (`parent_cat_id`),
  CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_cat_id`) REFERENCES `categories` (`cat_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,NULL,'电子产品'),(2,NULL,'运动器材'),(3,NULL,'生活用品'),(4,NULL,'学习工具'),(11,1,'手机/平板'),(12,1,'音频设备'),(13,1,'电脑配件'),(21,2,'球类'),(22,2,'健身器材'),(31,3,'日用百货'),(32,3,'寝室神器'),(41,4,'文具'),(42,4,'考试资料');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credit_logs`
--

DROP TABLE IF EXISTS `credit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credit_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(20) NOT NULL,
  `change_amount` int NOT NULL COMMENT '变动值，正为加分负为扣分',
  `reason` varchar(200) NOT NULL COMMENT '变动原因',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_user_time` (`user_id`,`create_time`),
  CONSTRAINT `credit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credit_logs`
--

LOCK TABLES `credit_logs` WRITE;
/*!40000 ALTER TABLE `credit_logs` DISABLE KEYS */;
INSERT INTO `credit_logs` VALUES (1,'2021002',2,'完成租借订单 #1，获得好评','2026-05-30 10:34:43'),(2,'2021003',2,'完成租借订单 #2，按时归还','2026-05-30 10:34:43'),(3,'2021005',2,'完成租借订单 #3，物品完好','2026-05-30 10:34:43'),(4,'2021003',-5,'订单 #5 逾期归还，逾期3天','2026-05-30 10:34:43'),(5,'2021004',-5,'订单 #6 逾期归还，逾期3天','2026-05-30 10:34:43'),(6,'2021009',-10,'订单 #7 逾期归还，逾期4天，信用分扣除','2026-05-30 10:34:43'),(7,'2021005',-3,'订单 #13 取消订单，扣除部分信用分','2026-05-30 10:34:43'),(8,'2021001',-3,'订单 #14 取消订单，扣除部分信用分','2026-05-30 10:34:43'),(9,'2021006',1,'首次完成租借，奖励信用分','2026-05-30 10:34:43'),(10,'2021010',1,'积极评价物主，奖励信用分','2026-05-30 10:34:43');
/*!40000 ALTER TABLE `credit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorites` (
  `user_id` varchar(20) NOT NULL,
  `item_id` int NOT NULL,
  `add_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`item_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
INSERT INTO `favorites` VALUES ('2021001',4,'2026-06-07 14:20:51'),('2021002',1,'2026-05-30 10:26:20'),('2021003',5,'2026-05-30 10:26:20'),('2021004',8,'2026-05-30 10:26:20'),('2021005',9,'2026-05-30 10:26:20'),('2021006',11,'2026-05-30 10:26:20'),('2021007',13,'2026-05-30 10:26:20'),('2021008',15,'2026-05-30 10:26:20'),('2021009',17,'2026-05-30 10:26:20'),('2021010',19,'2026-05-30 10:26:20'),('202420060224',4,'2026-06-06 10:55:27');
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `owner_id` varchar(20) NOT NULL COMMENT '物主学号',
  `cat_id` int NOT NULL COMMENT '分类ID',
  `name` varchar(100) NOT NULL COMMENT '物品名称',
  `description` text COMMENT '物品描述',
  `deposit` decimal(8,2) DEFAULT '0.00' COMMENT '押金金额',
  `daily_rent` decimal(6,2) NOT NULL COMMENT '日租金',
  `status` enum('available','borrowed','maintaining','offline') DEFAULT 'available' COMMENT '可用/借出中/维护中/已下架',
  `location` varchar(50) DEFAULT NULL COMMENT '存放位置',
  `images` varchar(500) DEFAULT NULL COMMENT '图片URL，多个用逗号分隔',
  `view_count` int DEFAULT '0' COMMENT '浏览次数',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  KEY `owner_id` (`owner_id`),
  KEY `cat_id` (`cat_id`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`cat_id`) REFERENCES `categories` (`cat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES (1,'2021001',11,'iPad Air 4','10.9寸，64G，带保护壳，考研神器',2000.00,15.00,'offline','1号楼101',NULL,0,'2026-05-30 10:17:32','2026-06-06 08:32:36'),(2,'2021001',12,'索尼WH-1000XM4耳机','降噪耳机，音质超好，适合自习',1500.00,10.00,'borrowed','1号楼101',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(3,'2021002',21,'斯伯丁篮球','7号球，八成新，手感好',100.00,3.00,'borrowed','1号楼102',NULL,0,'2026-05-30 10:17:32','2026-06-06 10:54:38'),(4,'2021002',31,'小米台灯','可调亮度，护眼模式',50.00,2.00,'available','1号楼102',NULL,0,'2026-05-30 10:17:32','2026-05-30 17:25:33'),(5,'2021003',41,'卡西欧计算器','fx-991CN X，考试可用',80.00,2.50,'available','2号楼201',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(6,'2021003',22,'瑜伽垫','加厚款，送收纳袋',40.00,2.00,'maintaining','2号楼201',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(7,'2021004',32,'床上书桌','折叠款，可放笔记本电脑',60.00,3.00,'available','2号楼202',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(8,'2021004',13,'机械键盘','青轴，RGB背光',200.00,5.00,'available','2号楼202',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(9,'2021005',21,'羽毛球拍','尤尼克斯，送三个球',120.00,4.00,'available','3号楼301',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(10,'2021005',31,'电煮锅','宿舍可用，600W，煮面神器',80.00,3.00,'offline','3号楼301',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(11,'2021006',42,'考研数学真题','2024版，几乎全新',30.00,1.00,'available','3号楼302',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(12,'2021006',12,'漫步者音箱','蓝牙小音箱，音质不错',100.00,3.00,'available','3号楼302',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(13,'2021007',22,'哑铃套装','20kg可调节，送健身手套',300.00,8.00,'available','4号楼401',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(14,'2021007',32,'挂篮收纳架','床边挂篮，放手机书本',20.00,0.50,'available','4号楼401',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(15,'2021008',11,'Kindle青春版','阅读器，墨水屏不伤眼',400.00,5.00,'available','4号楼402',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(16,'2021008',41,'彩色马克笔','40色，手账专用',50.00,1.00,'available','4号楼402',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(17,'2021009',13,'拓展坞','Type-C转USB+HDMI',60.00,2.00,'available','5号楼501',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(18,'2021009',21,'跳绳','计数跳绳，可调节长度',25.00,1.00,'available','5号楼501',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(19,'2021010',32,'懒人支架','手机平板通用，床头夹',30.00,1.50,'available','5号楼502',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(20,'2021010',42,'四级真题','近5年真题，含解析',20.00,0.80,'available','5号楼502',NULL,0,'2026-05-30 10:17:32','2026-05-30 10:17:32'),(21,'243051301235',1,'棉花娃娃','35cm*25cm*45cm',100.00,25.00,'available','22号楼',NULL,0,'2026-06-06 09:05:49','2026-06-06 09:05:49'),(22,'202420060224',1,'联想笔记本','联想14',100.00,20.00,'borrowed','22',NULL,0,'2026-06-06 10:56:41','2026-06-07 14:20:38');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `borrower_id` varchar(20) NOT NULL COMMENT '借用人学号',
  `order_status` enum('pending','waiting_pickup','borrowing','returned','cancelled') DEFAULT 'pending' COMMENT '预约中/待取件/借出中/已归还/已取消',
  `borrow_date` date DEFAULT NULL COMMENT '实际借出日期',
  `due_date` date DEFAULT NULL COMMENT '应还日期',
  `actual_return_date` date DEFAULT NULL COMMENT '实际归还日期',
  `total_cost` decimal(8,2) DEFAULT '0.00' COMMENT '总费用',
  `penalty` decimal(8,2) DEFAULT '0.00' COMMENT '逾期罚金',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `cancel_time` datetime DEFAULT NULL COMMENT '取消时间',
  PRIMARY KEY (`order_id`),
  KEY `item_id` (`item_id`),
  KEY `borrower_id` (`borrower_id`),
  KEY `idx_status_due` (`order_status`,`due_date`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`borrower_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,'2021002','returned','2025-05-01','2025-05-05','2025-05-05',60.00,0.00,'2026-05-30 10:20:38',NULL),(2,3,'2021003','returned','2025-05-10','2025-05-12','2025-05-12',6.00,0.00,'2026-05-30 10:20:38',NULL),(3,4,'2021005','returned','2025-05-15','2025-05-18','2025-05-17',4.00,0.00,'2026-05-30 10:20:38',NULL),(4,8,'2021006','returned','2025-05-20','2025-05-22','2025-05-22',10.00,0.00,'2026-05-30 10:20:38',NULL),(5,2,'2021003','returned','2025-05-01','2025-05-03','2025-05-06',20.00,15.00,'2026-05-30 10:20:38',NULL),(6,5,'2021004','returned','2025-05-05','2025-05-07','2025-05-10',5.00,3.75,'2026-05-30 10:20:38',NULL),(7,11,'2021009','returned','2025-05-08','2025-05-10','2025-05-14',1.00,4.00,'2026-05-30 10:20:38',NULL),(8,7,'2021001','returned','2025-05-25','2025-05-28','2026-05-30',0.00,0.00,'2026-05-30 10:20:38',NULL),(9,9,'2021008','returned','2025-05-26','2025-05-29','2026-05-30',0.00,0.00,'2026-05-30 10:20:38',NULL),(10,12,'2021010','borrowing','2025-05-27','2025-05-30',NULL,0.00,0.00,'2026-05-30 10:20:38',NULL),(11,14,'2021002','waiting_pickup',NULL,NULL,NULL,0.00,0.00,'2026-05-30 10:20:38',NULL),(12,15,'2021004','pending',NULL,NULL,NULL,0.00,0.00,'2026-05-30 10:20:38',NULL),(13,10,'2021001','cancelled',NULL,NULL,NULL,0.00,0.00,'2026-05-30 10:20:38',NULL),(14,18,'2021005','cancelled',NULL,NULL,NULL,0.00,0.00,'2026-05-30 10:20:38',NULL),(15,1,'2021001','returned','2026-05-30','2026-06-02','2026-05-30',0.00,0.00,'2026-05-30 16:54:56',NULL),(16,4,'2021001','returned','2026-05-30','2026-06-02','2026-05-30',0.00,0.00,'2026-05-30 16:55:27',NULL),(17,3,'2021001','returned','2026-05-30','2026-06-02','2026-05-30',0.00,0.00,'2026-05-30 17:16:12',NULL),(18,3,'2021001','returned','2026-05-30','2026-06-02','2026-05-30',0.00,0.00,'2026-05-30 17:25:56',NULL),(19,3,'202420060224','borrowing','2026-06-06','2026-06-09',NULL,0.00,0.00,'2026-06-06 10:54:38',NULL),(20,22,'2021001','borrowing','2026-06-07','2026-06-10',NULL,0.00,0.00,'2026-06-07 14:20:38',NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations` (
  `res_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `user_id` varchar(20) NOT NULL COMMENT '预约人',
  `start_date` date NOT NULL COMMENT '期望借出开始日',
  `end_date` date NOT NULL COMMENT '期望借出结束日',
  `status` enum('active','expired','converted') DEFAULT 'active' COMMENT '有效/过期/已转订单',
  `expire_time` datetime NOT NULL COMMENT '预约失效时间（如2小时后）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`res_id`),
  KEY `item_id` (`item_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`),
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `reservations_chk_1` CHECK ((`start_date` <= `end_date`))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
INSERT INTO `reservations` VALUES (1,1,'2021003','2025-06-01','2025-06-05','active','2026-05-30 12:31:15','2026-05-30 10:31:15'),(2,3,'2021005','2025-06-02','2025-06-04','active','2026-05-30 12:31:15','2026-05-30 10:31:15'),(3,7,'2021002','2025-06-03','2025-06-06','active','2026-05-30 12:31:15','2026-05-30 10:31:15'),(4,2,'2021003','2025-04-28','2025-05-03','converted','2025-04-28 12:00:00','2026-05-30 10:31:15'),(5,5,'2021004','2025-05-03','2025-05-07','converted','2025-05-03 10:30:00','2026-05-30 10:31:15'),(6,11,'2021009','2025-05-06','2025-05-10','converted','2025-05-06 15:00:00','2026-05-30 10:31:15'),(7,9,'2021007','2025-05-20','2025-05-25','expired','2025-05-18 20:00:00','2026-05-30 10:31:15'),(8,15,'2021001','2025-05-22','2025-05-28','expired','2025-05-20 18:00:00','2026-05-30 10:31:15');
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL COMMENT '对应的订单',
  `reviewer_id` varchar(20) NOT NULL COMMENT '评价人（借用人）',
  `rating` int NOT NULL COMMENT '评分1-5星',
  `comment` text COMMENT '文字评价',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `order_id` (`order_id`),
  KEY `reviewer_id` (`reviewer_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,1,'2021002',5,'iPad很好用，学长人不错','2026-05-30 10:23:26'),(2,2,'2021003',4,'篮球手感好，下次还借','2026-05-30 10:23:26'),(3,3,'2021005',5,'台灯很新，亮度可调','2026-05-30 10:23:26'),(4,4,'2021006',4,'键盘手感不错，就是有点吵','2026-05-30 10:23:26'),(5,5,'2021003',3,'耳机音质好，但是借晚了','2026-05-30 10:23:26');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` varchar(20) NOT NULL COMMENT '学号',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `password` varchar(100) NOT NULL DEFAULT '123456' COMMENT '密码',
  `dorm_building` varchar(10) NOT NULL COMMENT '宿舍楼号',
  `dorm_room` varchar(10) DEFAULT NULL COMMENT '宿舍房间号',
  `phone` varchar(15) DEFAULT NULL COMMENT '联系电话',
  `credit_score` int DEFAULT '100' COMMENT '信用分0-100',
  `role` enum('student','admin') DEFAULT 'student' COMMENT '角色',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `users_chk_1` CHECK ((`credit_score` between 0 and 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('2021001','张三','123456','1号楼','101','13800138001',10,'student','2026-05-30 10:12:01'),('2021002','李四','123456','1号楼','102','13800138002',95,'student','2026-05-30 10:12:01'),('2021003','王五','123456','2号楼','201','13800138003',88,'student','2026-05-30 10:12:01'),('2021004','赵六','123456','2号楼','202','13800138004',100,'student','2026-05-30 10:12:01'),('2021005','小明','123456','3号楼','301','13800138005',72,'student','2026-05-30 10:12:01'),('2021006','小红','123456','3号楼','302','13800138006',100,'student','2026-05-30 10:12:01'),('2021007','小刚','123456','4号楼','401','13800138007',90,'student','2026-05-30 10:12:01'),('2021008','小美','123456','4号楼','402','13800138008',85,'student','2026-05-30 10:12:01'),('2021009','大熊','123456','5号楼','501','13800138009',60,'student','2026-05-30 10:12:01'),('2021010','静香','123456','5号楼','502','13800138010',100,'student','2026-05-30 10:12:01'),('202420060224','俞剑韬','123456','22','313','18770070965',100,'student','2026-06-06 10:52:29'),('243051301235','俞剑韬','Y1314LoveLH7','22','313','18770070965',100,'student','2026-06-06 09:02:56'),('admin','管理员','admin123','行政楼','001','13900000000',100,'admin','2026-05-30 10:12:01');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-07 19:30:40
