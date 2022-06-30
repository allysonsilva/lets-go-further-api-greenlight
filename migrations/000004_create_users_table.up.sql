CREATE TABLE IF NOT EXISTS users  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `activated` tinyint(1) UNSIGNED NOT NULL,
  `version` smallint UNSIGNED NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `email_unique_idx`(`email`)
);
