CREATE DATABASE db001;
CREATE USER 'dbuser'@'localhost' IDENTIFIED BY 'User1589$';
GRANT ALL ON db001.* TO 'dbuser'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'dbuser'@'localhost';
show databases;
