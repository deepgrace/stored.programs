# Stored Programs [![LICENSE](https://img.shields.io/github/license/deepgrace/stored.programs.svg)](https://github.com/deepgrace/stored.programs/blob/master/LICENSE_1_0.txt)

> **Function, View, Trigger and Stored Procedure in SQL**

## Overview

## factorial
```sql
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
```
