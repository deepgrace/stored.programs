--
-- Copyright (c) 2012-present DeepGrace (complex dot invoke at gmail dot com)
--
-- Distributed under the Boost Software License, Version 1.0.
-- (See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
--
-- Official repository: https://github.com/deepgrace/stored.programs
--

USE database;

DROP TRIGGER IF EXISTS insert_uuid;
DELIMITER //
CREATE TRIGGER insert_uuid
       BEFORE INSERT ON table_name
       FOR EACH ROW
BEGIN
       SET NEW.uuid = REPLACE(UUID(), '-', '');
END //
DELIMITER ;

DROP FUNCTION IF EXISTS find_id;
DELIMITER //
CREATE FUNCTION find_id(_id CHAR(11)) RETURNS BOOL
BEGIN
       DECLARE id_ CHAR(11);
       SELECT id FROM table_name WHERE id = _id INTO id_;
       RETURN ! ISNULL(id_);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS save_buffer;
DELIMITER //
CREATE PROCEDURE save_buffer(_id CHAR(11), _role VARBINARY(4096))
BEGIN
       IF find_id(_id) THEN
          UPDATE person SET role = _role WHERE id = _id LIMIT 1;
       END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS update_model;
DELIMITER //
CREATE PROCEDURE update_model(mobile CHAR(11), name CHAR(13), id INT)
BEGIN
       SET @_id = id;
       SET @_mobile  = mobile;
       SET @cond = "= ? WHERE mobile = ? LIMIT 1";
       SET @query = CONCAT_WS(" ", "UPDATE person SET", name, @cond);
       PREPARE stmt FROM @query;
       EXECUTE stmt USING @_id, @_mobile;
       DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS get_data;
DELIMITER //
CREATE PROCEDURE get_data(_id CHAR(11))
BEGIN
       IF find_id(_id) THEN
           SELECT name, gender, industry, job, uuid, 
           p.password, p.role_info, p.role
           FROM table_name INNER JOIN person AS p
           USING(uuid) WHERE uuid = get_uuid(_id) LIMIT 1;
       END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS clear_person;
DELIMITER //
CREATE PROCEDURE clear_person()
BEGIN
       DECLARE _id CHAR(11);
       DECLARE done BOOL DEFAULT FALSE;       
       DECLARE cur CURSOR FOR SELECT id FROM table_name;
       DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
       OPEN cur;
       _loop: REPEAT
              FETCH cur INTO _id;
              IF (! done) THEN
                  CALL delete_person(_id);
              END IF;
       UNTIL done
       END REPEAT _loop;
       CLOSE cur;
       SET done = FALSE;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS add_object;
DELIMITER //
CREATE PROCEDURE add_object(status CHAR(1), tab VARCHAR(12), uuid CHAR(32), member_id CHAR(32))
BEGIN
       SET @_uuid = uuid;
       SET @_member_id = member_id;
       SET @insert_ = CONCAT("INSERT INTO ", tab);
       SET @col = "uuid, member_id) VALUES(";
       IF tab REGEXP "friend" THEN
          SET @col = CONCAT("(", @col, "?, ?)");
       ELSE
          SET @col = CONCAT("(status, ", @col, status, ", ?, ?)");
       END IF;
       IF ! (tab REGEXP "apply") THEN
          SET @cond = " WHERE uuid = ? AND member_id = ?";
          SET @query = CONCAT("DELETE FROM apply_", tab, @cond);
          PREPARE stmt FROM @query;
          EXECUTE stmt USING @_member_id, @_uuid;
          DEALLOCATE PREPARE stmt;
       END IF;
       SET @query = CONCAT_WS(" ", @insert_, @col);
       PREPARE stmt FROM @query;
       IF tab = "friend" THEN
          EXECUTE stmt USING @_member_id, @_uuid;
       END IF;
       EXECUTE stmt USING @_uuid, @_member_id;
       DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- SET max_sp_recursion_depth = N

DROP PROCEDURE IF EXISTS factorial;
DELIMITER //
CREATE PROCEDURE factorial(n INT, OUT f INT)
BEGIN
       IF n <= 1 THEN
          SET f = 1;
       ELSE
          CALL factorial(n-1, @k);
          SET f = n * @k;
       END IF;
END //
DELIMITER ;
