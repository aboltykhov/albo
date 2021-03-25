USE wpdb;
CREATE TABLE wpdb.albo ( item_id INT AUTO_INCREMENT, content VARCHAR(255), PRIMARY KEY(item_id) );
INSERT INTO wpdb.albo (content) VALUES ("Al Bo item first");
INSERT INTO wpdb.albo (content) VALUES ("Al Bo item second");
INSERT INTO wpdb.albo (content) VALUES ("Al Bo item third ");
SELECT * FROM  wpdb.albo;
SHOW GRANTS FOR 'wpuser'@'localhost';
