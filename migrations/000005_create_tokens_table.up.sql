CREATE TABLE `tokens`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `hash` char(65) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `expiry` timestamp NOT NULL,
  `scope` enum('activation','authentication') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `greenlight`.`users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);
