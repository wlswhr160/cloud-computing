특집2-3：SQL식 집합 조작


--********************************
--
--○4－1．복수의 행을 한 행으로 정리한다
--
--********************************

DROP TABLE NonAggTbl;
CREATE TABLE NonAggTbl
(id VARCHAR(32) NOT NULL,
 data_type CHAR(1) NOT NULL,
 data_1 INTEGER,
 data_2 INTEGER,
 data_3 INTEGER,
 data_4 INTEGER,
 data_5 INTEGER,
 data_6 INTEGER);

DELETE FROM NonAggTbl;
INSERT INTO NonAggTbl VALUES('Jim',    'A',  100,  10,     34,  346,   54,  NULL);
INSERT INTO NonAggTbl VALUES('Jim',    'B',  45,    2,    167,   77,   90,   157);
INSERT INTO NonAggTbl VALUES('Jim',    'C',  NULL,  3,    687, 1355,  324,   457);
INSERT INTO NonAggTbl VALUES('Ken',    'A',  78,    5,    724,  457, NULL,     1);
INSERT INTO NonAggTbl VALUES('Ken',    'B',  123,  12,    178,  346,   85,   235);
INSERT INTO NonAggTbl VALUES('Ken',    'C',  45, NULL,     23,   46,  687,    33);
INSERT INTO NonAggTbl VALUES('Beth',   'A',  75,    0,    190,   25,  356,  NULL);
INSERT INTO NonAggTbl VALUES('Beth',   'B',  435,   0,    183, NULL,    4,   325);
INSERT INTO NonAggTbl VALUES('Beth',   'C',  96,  128,   NULL,    0,    0,    12);

--리스트1~3
SELECT id, data_1, data_2
  FROM NonAggTbl
 WHERE id = 'Jim'
   AND data_type = 'A';

SELECT id, data_3, data_4, data_5
  FROM NonAggTbl
 WHERE id = 'Jim'
   AND data_type = 'B';

SELECT id, data_6
  FROM NonAggTbl
 WHERE id = 'Jim'
   AND data_type = 'C';


--리스트4 아쉽지만 틀리다.（MySQL만 가능함）
SELECT id,
        CASE WHEN data_type = 'A' THEN data_1 ELSE NULL END AS data_1,
        CASE WHEN data_type = 'A' THEN data_2 ELSE NULL END AS data_2,
        CASE WHEN data_type = 'B' THEN data_3 ELSE NULL END AS data_3,
        CASE WHEN data_type = 'B' THEN data_4 ELSE NULL END AS data_4,
        CASE WHEN data_type = 'B' THEN data_5 ELSE NULL END AS data_5,
        CASE WHEN data_type = 'C' THEN data_6 ELSE NULL END AS data_6
  FROM NonAggTbl
 GROUP BY id;

--리스트5 이것이 정답. 어떤 데이터 베이스에도 적용 가능하다.
SELECT id,
        MAX(CASE WHEN data_type = 'A' THEN data_1 ELSE NULL END) AS data_1,
        MAX(CASE WHEN data_type = 'A' THEN data_2 ELSE NULL END) AS data_2,
        MAX(CASE WHEN data_type = 'B' THEN data_3 ELSE NULL END) AS data_3,
        MAX(CASE WHEN data_type = 'B' THEN data_4 ELSE NULL END) AS data_4,
        MAX(CASE WHEN data_type = 'B' THEN data_5 ELSE NULL END) AS data_5,
        MAX(CASE WHEN data_type = 'C' THEN data_6 ELSE NULL END) AS data_6
  FROM NonAggTbl
 GROUP BY id;



--********************************
--
--○4－2．합쳐서 하나로
--
--********************************

CREATE TABLE PriceByAge
(product_id VARCHAR(32) NOT NULL,
 low_age    INTEGER NOT NULL,
 high_age   INTEGER NOT NULL,
 price      INTEGER NOT NULL,
 PRIMARY KEY (product_id, low_age),
   CHECK (low_age < high_age));


INSERT INTO PriceByAge VALUES('제품1',  0  ,  50  ,  2000);
INSERT INTO PriceByAge VALUES('제품1',  51  ,  100  ,  3000);
INSERT INTO PriceByAge VALUES('제품2',  0  ,  100  ,  4200);
INSERT INTO PriceByAge VALUES('제품3',  0  ,  20  ,  500);
INSERT INTO PriceByAge VALUES('제품3',  31  ,  70  ,  800);
INSERT INTO PriceByAge VALUES('제품3',  71  ,  100  ,  1000);
INSERT INTO PriceByAge VALUES('제품4',  0  ,  99  ,  8900);


--리스트6 정답
SELECT product_id
FROM PriceByAge
GROUP BY product_id
HAVING SUM(high_age - low_age + 1) = 101;


--********************************
--
--○4－3．당신은 비만입니까? 저체중입니까? ~Cut와 Partition ~
--
--********************************
CREATE TABLE Persons
(name   VARCHAR(8) NOT NULL,
 age    INTEGER NOT NULL,
 height FLOAT NOT NULL,
 weight FLOAT NOT NULL,
 PRIMARY KEY (name));


INSERT INTO Persons VALUES('Anderson',  30,  188,  90);
INSERT INTO Persons VALUES('Adela',    21,  167,  55);
INSERT INTO Persons VALUES('Bates',    87,  158,  48);
INSERT INTO Persons VALUES('Becky',    54,  187,  70);
INSERT INTO Persons VALUES('Bill',    39,  177,  120);
INSERT INTO Persons VALUES('Chris',    90,  175,  48);
INSERT INTO Persons VALUES('Darwin',  12,  160,  55);
INSERT INTO Persons VALUES('Dawson',  25,  182,  90);
INSERT INTO Persons VALUES('Donald',  30,  176,  53);

--리스트7 이니셜의 알파벳마다 몇 명이 테이블에 존재하는가 집계하는 SQL
SELECT SUBSTRING(name, 1, 1) AS label,
       COUNT(*)
  FROM Persons
 GROUP BY SUBSTRING(name, 1, 1);


--리스트8 연령에 따른 구분을 시행
SELECT CASE WHEN age < 20 THEN '미성년자'
            WHEN age BETWEEN 21 AND 69 THEN '성인'
            WHEN age > 70 THEN '노인'
            ELSE NULL END AS age_class,
       COUNT(*)
  FROM Persons
 GROUP BY CASE WHEN age < 20 THEN '미성년자'
               WHEN age BETWEEN 21 AND 69 THEN '성인'
               WHEN age > 70 THEN '노인'
               ELSE NULL END;

--리스트9 BMI에 의한 체중을 구하는 쿼리
SELECT CASE WHEN weight / POWER(height /100, 2) < 18.5     THEN '저체중'
            WHEN 18.5 <= weight / POWER(height /100, 2) 
                   AND weight / POWER(height /100, 2) < 25 THEN '표준'
            WHEN 25 <= weight / POWER(height /100, 2)      THEN '비만'
            ELSE NULL END AS bmi,
       COUNT(*)
  FROM Persons
 GROUP BY CASE WHEN weight / POWER(height /100, 2) < 18.5     THEN '저체중'
               WHEN 18.5 <= weight / POWER(height /100, 2) 
                      AND weight / POWER(height /100, 2) < 25 THEN '표준'
               WHEN 25 <= weight / POWER(height /100, 2)      THEN '비만'
               ELSE NULL END;

--리스트10 PARTITION BY에 식을 넣어 본다.
SELECT name,
       age,
       CASE WHEN age < 20 THEN '미성년자'
            WHEN age BETWEEN 21 AND 69 THEN '성인'
            WHEN age > 70 THEN '노인'
            ELSE NULL END AS age_class,
       RANK() OVER(PARTITION BY CASE WHEN age < 20 THEN '미성년자'
                                     WHEN age BETWEEN 21 AND 69 THEN '성인'
                                     WHEN age > 70 THEN '노인'
                                     ELSE NULL END
                   ORDER BY age) AS age_rank_in_class
  FROM Persons
 ORDER BY age_class, age_rank_in_class;

--리스트11 집합의 성질을 조사하는 쿼리
SELECT CASE WHEN age < 20 THEN '미성년자'
            WHEN age BETWEEN 21 AND 69 THEN '성인'
            WHEN age > 70 THEN '노인'
       ELSE NULL END AS age_class,
       COUNT(*)
  FROM Persons
 GROUP BY CASE WHEN age < 20 THEN '미성년자'
               WHEN age BETWEEN 21 AND 69 THEN '성인'
               WHEN age > 70 THEN '노인'
          ELSE NULL END
HAVING COUNT(*) = SUM(CASE WHEN weight / POWER(height /100, 2) < 25 THEN 1
                      ELSE 0 END);


--리스트12 집합의 성질을 조사하는 쿼리
SELECT CASE WHEN age < 20 THEN '미성년자'
            WHEN age BETWEEN 21 AND 69 THEN '성인'
            WHEN age > 70 THEN '노인'
       ELSE NULL END AS age_class,
       COUNT(*) AS all_cnt,
       SUM(CASE WHEN weight / POWER(height /100, 2) < 25 THEN 1
           ELSE 0 END) AS not_fat_cnt
  FROM Persons
 GROUP BY CASE WHEN age < 20 THEN '미성년자'
               WHEN age BETWEEN 21 AND 69 THEN '성인'
               WHEN age > 70 THEN '노인'
          ELSE NULL END;
