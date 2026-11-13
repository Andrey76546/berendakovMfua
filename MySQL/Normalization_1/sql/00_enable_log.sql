-- Включение общего журнала в отдельном учебном контейнере.
-- Журнал предварительно очищается, поэтому в экспорт попадут только действия этой работы.
SET GLOBAL general_log = 'OFF';
TRUNCATE TABLE mysql.general_log;
SET GLOBAL log_output = 'TABLE';
SET GLOBAL general_log = 'ON';

SELECT @@global.general_log AS general_log_enabled,
       @@global.log_output AS log_output;
