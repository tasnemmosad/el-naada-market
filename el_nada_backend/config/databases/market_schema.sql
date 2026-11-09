-- MySQL dump 10.13  Distrib 26.10.0, for Win64 (x86_64)
--
-- Host: localhost    Database: el_nada_market
-- ------------------------------------------------------
-- Server version	26.10.0

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
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '8f19508c-dc8a-11f1-a83c-7478273928f1:1-38';

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name_en` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `name_ar` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `category` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `unit_of_msr_po` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `unit_of_msr_so` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `photo_url` text COLLATE utf8mb4_general_ci,
  `in_stock` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_products_created_by` (`created_by`),
  KEY `fk_products_updated_by` (`updated_by`),
  KEY `idx_products_category` (`category`),
  CONSTRAINT `fk_products_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_products_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_products_category` CHECK ((`category` in (_cp850'fruit',_cp850'vegetable'))),
  CONSTRAINT `chk_products_unit_msr_po` CHECK ((`unit_of_msr_po` in (_cp850'Kg',_cp850'Grm',_cp850'Piece',_cp850'Carton'))),
  CONSTRAINT `chk_products_unit_msr_so` CHECK ((`unit_of_msr_so` in (_cp850'Kg',_cp850'Grm',_cp850'Piece',_cp850'Carton')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_prices`
--

DROP TABLE IF EXISTS `product_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_prices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int unsigned NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `valid_from` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_price_date` (`product_id`,`valid_from`),
  KEY `fk_prices_created_by` (`created_by`),
  KEY `fk_prices_updated_by` (`updated_by`),
  KEY `idx_prices_product_date` (`product_id`,`valid_from` DESC),
  CONSTRAINT `fk_prices_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_prices_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_prices_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_unit_price` CHECK ((`unit_price` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `prevent_price_update` BEFORE UPDATE ON `product_prices` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Price history cannot be updated' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `prevent_price_delete` BEFORE DELETE ON `product_prices` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Price history cannot be deleted' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `address` text COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `payment_method` varchar(10) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'cash',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`),
  KEY `fk_customers_created_by` (`created_by`),
  KEY `fk_customers_updated_by` (`updated_by`),
  CONSTRAINT `fk_customers_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_customers_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_customers_payment_method` CHECK ((`payment_method` in (_cp850'cash',_cp850'card',_cp850'wallet')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `basket_items`
--

DROP TABLE IF EXISTS `basket_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `basket_items` (
  `customer_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `quantity` decimal(6,2) NOT NULL,
  PRIMARY KEY (`customer_id`,`product_id`),
  KEY `fk_basket_product` (`product_id`),
  CONSTRAINT `fk_basket_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_basket_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `chk_basket_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int unsigned NOT NULL,
  `delivery_type` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `payment_method` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `delivery_address` text COLLATE utf8mb4_general_ci,
  `total` decimal(10,2) NOT NULL,
  `status` varchar(12) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'new',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_orders_created_by` (`created_by`),
  KEY `fk_orders_updated_by` (`updated_by`),
  KEY `idx_orders_customer` (`customer_id`),
  KEY `idx_orders_status` (`status`),
  CONSTRAINT `fk_orders_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_orders_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_order_total` CHECK ((`total` >= 0)),
  CONSTRAINT `chk_orders_delivery_type` CHECK ((`delivery_type` in (_cp850'delivery',_cp850'pickup'))),
  CONSTRAINT `chk_orders_payment_method` CHECK ((`payment_method` in (_cp850'cash',_cp850'bankcard',_cp850'wallet',_cp850'instapay'))),
  CONSTRAINT `chk_orders_status` CHECK ((`status` in (_cp850'new',_cp850'preparing',_cp850'on_the_way',_cp850'done',_cp850'cancelled')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL,
  `product_id` int unsigned DEFAULT NULL,
  `price_id` int unsigned DEFAULT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` decimal(6,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_order_items_product` (`product_id`),
  KEY `fk_order_items_price` (`price_id`),
  KEY `idx_order_items_order` (`order_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_items_price` FOREIGN KEY (`price_id`) REFERENCES `product_prices` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_order_item_quantity` CHECK ((`quantity` > 0)),
  CONSTRAINT `chk_order_item_subtotal` CHECK ((`subtotal` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `current_prices`
--

DROP TABLE IF EXISTS `current_prices`;
/*!50001 DROP VIEW IF EXISTS `current_prices`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `current_prices` AS SELECT 
 1 AS `price_id`,
 1 AS `product_id`,
 1 AS `unit_price`,
 1 AS `valid_from`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `products_with_price`
--

DROP TABLE IF EXISTS `products_with_price`;
/*!50001 DROP VIEW IF EXISTS `products_with_price`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `products_with_price` AS SELECT 
 1 AS `id`,
 1 AS `name_en`,
 1 AS `name_ar`,
 1 AS `category`,
 1 AS `photo_url`,
 1 AS `in_stock`,
 1 AS `price_id`,
 1 AS `unit_price`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `basket_totals`
--

DROP TABLE IF EXISTS `basket_totals`;
/*!50001 DROP VIEW IF EXISTS `basket_totals`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `basket_totals` AS SELECT 
 1 AS `customer_id`,
 1 AS `item_count`,
 1 AS `total`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `current_prices`
--

/*!50001 DROP VIEW IF EXISTS `current_prices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `current_prices` AS select `pp`.`id` AS `price_id`,`pp`.`product_id` AS `product_id`,`pp`.`unit_price` AS `unit_price`,`pp`.`valid_from` AS `valid_from` from `product_prices` `pp` where ((`pp`.`valid_from` <= now()) and (not exists(select 1 from `product_prices` `newer` where ((`newer`.`product_id` = `pp`.`product_id`) and (`newer`.`valid_from` <= now()) and (`newer`.`valid_from` > `pp`.`valid_from`))))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `products_with_price`
--

/*!50001 DROP VIEW IF EXISTS `products_with_price`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `products_with_price` AS select `p`.`id` AS `id`,`p`.`name_en` AS `name_en`,`p`.`name_ar` AS `name_ar`,`p`.`category` AS `category`,`p`.`photo_url` AS `photo_url`,`p`.`in_stock` AS `in_stock`,`c`.`price_id` AS `price_id`,`c`.`unit_price` AS `unit_price` from (`products` `p` join `current_prices` `c` on((`c`.`product_id` = `p`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `basket_totals`
--

/*!50001 DROP VIEW IF EXISTS `basket_totals`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `basket_totals` AS select `b`.`customer_id` AS `customer_id`,count(0) AS `item_count`,sum((`b`.`quantity` * `c`.`unit_price`)) AS `total` from (`basket_items` `b` join `current_prices` `c` on((`c`.`product_id` = `b`.`product_id`))) group by `b`.`customer_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-10  0:31:42
