CREATE TABLE IF NOT EXISTS `permissions`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` text NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `users_permissions` (
  `user_id` bigint UNSIGNED NOT NULL,
  `permission_id` bigint UNSIGNED NOT NULL,
  PRIMARY KEY (`user_id`, `permission_id`),
  CONSTRAINT `users_permissions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `greenlight`.`users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `greenlight`.`permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO permissions (code)
VALUES
    ('movies:read'),
    ('movies:write');
