CREATE TABLE sensors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
);

INSERT INTO sensors (name) VALUES ('Sensor 1'), ('Sensor 2'), ('Sensor 3'), ('Sensor 4'), ('Sensor 5');

CREATE TABLE sensor_readings_daily_avg (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sensor_id INTEGER,
    day DATE,
    temperature REAL,
    humidity REAL,
    FOREIGN KEY (sensor_id) REFERENCES sensors(id)
);

WITH RECURSIVE dates(day) AS (
  VALUES('2001-01-01')
  UNION ALL
  SELECT date(day, '+1 day')
  FROM dates
  WHERE day < '2025-01-01'
)
INSERT INTO sensor_readings_daily_avg (sensor_id, day, temperature, humidity)
SELECT
    (abs(random()) % 5) + 1 sensor_id,
    day,
    20 + (random() / 9223372036854775807.0) * 1.5 temperature,
    40 + (random() / 9223372036854775807.0) * 5 humidity
FROM
    dates;


CREATE TABLE monthly_sensor_readings_avg (
    month VARCHAR(7),
    temperature_avg REAL,
    humidity_avg REAL
);
