--
--
--
-- ○1－1．워밍업：조건에 따라 사용하는 열을 전환한다
--
-- ***********************************

CREATE TABLE CahngeCols
(year  INTEGER NOT NULL PRIMARY KEY,
 col_1 INTEGER NOT NULL,
 col_2 INTEGER NOT NULL);

INSERT INTO CahngeCols VALUES(2011,	10,	7);
INSERT INTO CahngeCols VALUES(2012,	20,	6);
INSERT INTO CahngeCols VALUES(2013,	30,	5);
INSERT INTO CahngeCols VALUES(2014,	40,	4);
INSERT INTO CahngeCols VALUES(2015,	50,	3);

-- 리스트1 열의 전환（SELECT문으로）
SELECT year,
       CASE WHEN year <= 2013 THEN col_1
            WHEN year >= 2014 THEN col_2
            ELSE NULL END AS col_3
  FROM CahngeCols;


-- 리스트2 WHERE문에서의 사용
SELECT year
  FROM CahngeCols
 WHERE 4 <= CASE WHEN year <= 2013 THEN col_1
                 WHEN year >= 2014 THEN col_2
                 ELSE NULL END;


-- ***********************************
--
-- ○1－2．열의 교환
--
-- ***********************************


CREATE TABLE Perm2
(cust_id  CHAR(3) PRIMARY KEY,
 item_1   VARCHAR(32)  NOT NULL,
 item_2   VARCHAR(32) NOT NULL);

INSERT INTO Perm2 VALUES('001', '시계', '정수기');
INSERT INTO Perm2 VALUES('002', '휴대전화', '휴대전화');
INSERT INTO Perm2 VALUES('003', '정수기', '시계');
INSERT INTO Perm2 VALUES('004', '휴대전화', '휴대전화');
INSERT INTO Perm2 VALUES('005', '잉크', '안경');

-- 리스트3 조합⇒순열（중복행 제거전）
SELECT CASE WHEN item_1 < item_2 THEN item_1
            ELSE item_2 END AS c1,
       CASE WHEN item_1 < item_2 THEN item_2
            ELSE item_1 END AS c2
  FROM Perm2;


-- 리스트4 조합⇒순열（중복행 제거후）
SELECT DISTINCT
       CASE WHEN item_1 < item_2 THEN item_1
            ELSE item_2 END AS c1,
       CASE WHEN item_1 < item_2 THEN item_2
            ELSE item_1 END AS c2
  FROM Perm2;


CREATE TABLE Perm3
(cust_id  CHAR(3) PRIMARY KEY,
 item_1   VARCHAR(32)  NOT NULL,
 item_2   VARCHAR(32) NOT NULL,
 item_3   VARCHAR(32) NOT NULL);

INSERT INTO Perm3 VALUES('001', '시계', '정수기', '티슈');
INSERT INTO Perm3 VALUES('002', '티슈', '정수기', '시계');
INSERT INTO Perm3 VALUES('003', '달력', '노트', '시계');
INSERT INTO Perm3 VALUES('004', '달력', '노트', '잉크');
INSERT INTO Perm3 VALUES('005', '문고판 책', '게임 소프트', '안경');
INSERT INTO Perm3 VALUES('006', '문고판 책', '안경', '게임 소프트');

-- 리스트5 열형식⇒행형식
CREATE VIEW CustItems (cust_id, item) AS
SELECT cust_id, item_1
  FROM Perm3
UNION ALL
SELECT cust_id, item_2
  FROM Perm3
UNION ALL
SELECT cust_id, item_3
  FROM Perm3;

-- 리스트6 조합⇒순열（3열 확장판）
SELECT DISTINCT MAX(CI1.item) AS c1, 
       MAX(CI2.item) AS c2,
       MAX(CI3.item) AS c3
  FROM CustItems CI1
           INNER JOIN CustItems CI2
                   ON CI1.cust_id = CI2.cust_id
                  AND CI1.item < CI2.item
                 INNER JOIN CustItems CI3
                         ON CI2.cust_id = CI3.cust_id
                        AND CI2.item < CI3.item
 GROUP BY CI1.cust_id;



-- ***********************************
-- 
-- ○1－3．표두의 복잡한 집계
-- 
-- ***********************************

CREATE TABLE Employees
(emp_id  CHAR(3) NOT NULL PRIMARY KEY,
 dept    VARCHAR(8) NOT NULL,
 sex     CHAR(2) NOT NULL,
 age     INTEGER NOT NULL,
 salary  INTEGER NOT NULL);

INSERT INTO Employees VALUES('001',	'제조',	'남',	32,	30);
INSERT INTO Employees VALUES('002',	'제조',	'남',	30,	29);
INSERT INTO Employees VALUES('003',	'제조',	'여',	23,	19);
INSERT INTO Employees VALUES('004',	'회계',	'남',	45,	35);
INSERT INTO Employees VALUES('005',	'회계',	'남',	50,	45);
INSERT INTO Employees VALUES('006',	'영업',	'여',	40,	50);
INSERT INTO Employees VALUES('007',	'영업',	'여',	42,	40);
INSERT INTO Employees VALUES('008',	'영업',	'남',	52,	38);
INSERT INTO Employees VALUES('009',	'영업',	'남',	34,	28);
INSERT INTO Employees VALUES('010',	'영업',	'여',	41,	25);
INSERT INTO Employees VALUES('011',	'인사',	'남',	29,	25);
INSERT INTO Employees VALUES('012',	'인사',	'여',	36,	29);


-- 리스트7 표두 : 부서・성별, 표측 : 연령계급
SELECT dept,
       SUM(CASE WHEN age <= 30 AND sex = '남' THEN 1 ELSE 0 END) AS "신입（남）",
       SUM(CASE WHEN age <= 30 AND sex = '여' THEN 1 ELSE 0 END) AS "신입（여）",
       SUM(CASE WHEN age >= 31 AND sex = '남' THEN 1 ELSE 0 END) AS "전문가（남）",
       SUM(CASE WHEN age >= 31 AND sex = '여' THEN 1 ELSE 0 END) AS "전문가（여）"
  FROM Employees
 GROUP BY dept;


-- 리스트8 연령계급・성별, 표측 : 부서 (소계합계 존재)
SELECT dept,
       COUNT(*),
       SUM(CASE WHEN age <= 30 THEN 1 ELSE 0 END) AS "신입(합계)",
       SUM(CASE WHEN age <= 30 AND sex = '남' THEN 1 ELSE 0 END) AS "신입（남）",
       SUM(CASE WHEN age <= 30 AND sex = '여' THEN 1 ELSE 0 END) AS "신입（여）",
       SUM(CASE WHEN age >= 31 THEN 1 ELSE 0 END) AS "전문가(합계)",
       SUM(CASE WHEN age >= 31 AND sex = '남' THEN 1 ELSE 0 END) AS "전문가（남）",
       SUM(CASE WHEN age >= 31 AND sex = '여' THEN 1 ELSE 0 END) AS "전문가（여）"
  FROM Employees
 GROUP BY dept;

-- 리스트9 모든 열을 COUNT 함수로 채운다
SELECT dept,
       COUNT(*),
       COUNT(CASE WHEN age <= 30 THEN 1 ELSE NULL END) AS "신입(합계)",
       COUNT(CASE WHEN age <= 30 AND sex = '남' THEN 1 ELSE NULL END) AS "신입（남）",
       COUNT(CASE WHEN age <= 30 AND sex = '여' THEN 1 ELSE NULL END) AS "신입（여）",
       COUNT(CASE WHEN age >= 31 THEN 1 ELSE NULL END) AS "전문가(합계)",
       COUNT(CASE WHEN age >= 31 AND sex = '남' THEN 1 ELSE NULL END) AS "전문가（남）",
       COUNT(CASE WHEN age >= 31 AND sex = '여' THEN 1 ELSE NULL END) AS "전문가（여）"
  FROM Employees
 GROUP BY dept;



-- ***********************************
--
-- ○1－4．④	집약 함수 밖에서 CASE 식을 사용
--
-- ***********************************

-- 리스트10 부서마다 사람수를 선택한다
SELECT dept,
       COUNT(*) AS cnt
  FROM Employees
 GROUP BY dept;


-- 리스트11 집약 결과에 대한 조건 설정 : 집약함수를 인수로 한다
SELECT dept,
       CASE WHEN COUNT(*) <= 2 THEN '2명 이하'
            ELSE '3명 이상' END AS cnt
  FROM Employees
 GROUP BY dept;

