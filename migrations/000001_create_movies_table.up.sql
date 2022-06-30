CREATE TABLE `movies`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` text NOT NULL,
  `year` smallint UNSIGNED NOT NULL,
  `runtime` tinyint UNSIGNED NOT NULL,
  `genres` json NOT NULL,
  `version` smallint UNSIGNED NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
