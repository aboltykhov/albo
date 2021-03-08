USE wordpress;
CREATE TABLE wordpress.list ( item_id INT AUTO_INCREMENT, content VARCHAR(255), PRIMARY KEY(item_id) );
INSERT INTO wordpress.list (content) VALUES ("Test Al Bo item 001");
SELECT * FROM  wordpress.list;
SHOW GRANTS FOR 'wpuser'@'localhost';
