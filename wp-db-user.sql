CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'WP1password$';
GRANT ALL ON wordpress.* TO 'wpuser'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'wpuser'@'localhost';

