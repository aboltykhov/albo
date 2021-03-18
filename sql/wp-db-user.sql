CREATE DATABASE wpdb;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'WP1password$';
GRANT ALL ON wpdb.* TO 'wpuser'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'wpuser'@'localhost';
SHOW DATABASES;
