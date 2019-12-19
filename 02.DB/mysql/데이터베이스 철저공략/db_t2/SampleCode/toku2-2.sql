특집2-2：SQL식 행간비교

--***********************************
--
--○2－1．① 우선 기본부터 : 가장 최근의 것을 구한다
--
--***********************************

CREATE TABLE LoadSample
(sample_date DATE NOT NULL , 
 load_amt    INTEGER NOT NULL , 
   PRIMARY KEY (sample_date) ) ;

INSERT INTO LoadSample VALUES('2014-02-01', 1024);
INSERT INTO LoadSample VALUES('2014-02-02', 2366);
INSERT INTO LoadSample VALUES('2014-02-05', 2366);
INSERT INTO LoadSample VALUES('2014-02-07',  985);
INSERT INTO LoadSample VALUES('2014-02-08',  780);
INSERT INTO LoadSample VALUES('2014-02-12', 1000);


--가장 최근 값（윈도우 함수：Oracle LAG 함수）
SELECT sample_date,
       LAG(sample_date, 1) OVER (ORDER BY sample_date ASC) AS latest
  FROM LoadSample;

--리스트1 과거의 가장 최근 값을 구한다 （윈도우 함수：MySQL 이외에서 동작）
SELECT sample_date,
       MIN(sample_date) 
          OVER (ORDER BY sample_date ASC
                ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS latest
  FROM LoadSample;

--리스트2 가장 최근 값（상관 서브쿼리：구현 독립적）
SELECT LS0.sample_date,
         (SELECT MAX(sample_date)
			FROM LoadSample LS1
		   WHERE LS1.sample_date < LS0.sample_date) AS latest
  FROM LoadSample LS0;

--리스트3 가장 최근 값（자기결합：구현 독립적）
SELECT LS0.sample_date AS cur_date,
       MAX(LS1.sample_date) AS latest
  FROM LoadSample LS0
           LEFT OUTER JOIN LoadSample LS1
             ON LS1.sample_date < LS0.sample_date
 GROUP BY LS0.sample_date;


--리스트4 설명용 : 비 집약 상태에서 결과 도출
SELECT LS0.sample_date AS cur_date,
       LS1.sample_date AS latest
  FROM LoadSample LS0
           LEFT OUTER JOIN LoadSample LS1
             ON LS1.sample_date < LS0.sample_date;


--***********************************
--
--○2－2．②	가장 최근, 가장 최근의 바로 이전, 그 바로 이전 …
--
--***********************************

--리스트5 처리량도 함께 표시한다 (현재까지는 Oracle 이외에서 동작)
SELECT LS0.sample_date AS cur_date,
       MAX(LS0.load_amt) AS cur_load_amt,
       MAX(LS1.sample_date) AS latest,
       (SELECT MAX(load_amt)
          FROM LoadSample
         WHERE sample_date = MAX(LS1.sample_date)) AS latest_load_amt
  FROM LoadSample LS0
       LEFT OUTER JOIN LoadSample LS1
         ON LS1.sample_date < LS0.sample_date
 GROUP BY LS0.sample_date;

--리스트6 최대 하계를 얻기 위한 로직을 WHERE 구절에 작성
SELECT LS0.sample_date AS cur_date,
       LS0.load_amt AS cur_load,
       LS1.sample_date AS latest,
       LS1.load_amt AS latest_load
  FROM LoadSample LS0
       LEFT OUTER JOIN LoadSample LS1
         ON LS1.sample_date = (SELECT MAX(sample_date)
                                 FROM LoadSample
                                WHERE sample_date < LS0.sample_date);

--리스트7 3번째 이전의 날짜 까지 출력한다. ：윈도우 함수 이용
SELECT sample_date,
       MIN(sample_date) 
          OVER (ORDER BY sample_date ASC
                ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS latest,
       MIN(sample_date) 
          OVER (ORDER BY sample_date ASC
                ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING) AS latest_2,
       MIN(sample_date) 
          OVER (ORDER BY sample_date ASC
                ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING) AS latest_3
  FROM LoadSample;

--리스트8 3번째 이전의 날짜 까지 출력한다.：자기결합 이용
SELECT LS0.sample_date AS sample_date,
       MAX(LS1.sample_date) AS latest_1,
       MAX(LS2.sample_date) AS latest_2,
       MAX(LS3.sample_date) AS latest_3
  FROM LoadSample LS0
           LEFT OUTER JOIN LoadSample LS1
             ON LS1.sample_date < LS0.sample_date
             LEFT OUTER JOIN LoadSample LS2
               ON LS2.sample_date < LS1.sample_date
               LEFT OUTER JOIN LoadSample LS3
                 ON LS3.sample_date < LS2.sample_date
 GROUP BY LS0.sample_date;

--Oracle LAG
SELECT sample_date,
       LAG(sample_date, 1) OVER (ORDER BY sample_date) AS latest,
       LAG(sample_date, 2) OVER (ORDER BY sample_date) AS latest_2,
       LAG(sample_date, 3) OVER (ORDER BY sample_date) AS latest_3
  FROM LoadSample;


--리스트9 현재와 과거의 가장 최근을 구한다 : 윈도우 함수 버전 
SELECT MIN(sample_date)
           OVER (ORDER BY sample_date ASC
                 ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS past,
       sample_date AS cur_date,
       MAX(sample_date)
           OVER (ORDER BY sample_date DESC
                 ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS future
  FROM LoadSample;

--리스트10 현재와 과거의 가장 최근을 구한다 : 자기 결합 버전
SELECT MAX(LS1.sample_date) AS past,
       LS.sample_date AS sample_date,
       MIN(LS2.sample_date) AS future
  FROM LoadSample LS
       LEFT OUTER JOIN LoadSample LS1
         ON LS1.sample_date < LS.sample_date
         LEFT OUTER JOIN LoadSample LS2
           ON LS2.sample_date > LS.sample_date
 GROUP BY LS.sample_date;


--***********************************
--
--○2－3．③	작게 나눈 그룹 내의 행간 비교
--
--***********************************


CREATE TABLE LoadSample2
(machine     CHAR(3) NOT NULL,
 sample_date DATE NOT NULL , 
 load_amt    INTEGER NOT NULL , 
   PRIMARY KEY (machine, sample_date) ) ;

INSERT INTO LoadSample2 VALUES('PC1',  '2014-02-01', 1024);
INSERT INTO LoadSample2 VALUES('PC1',  '2014-02-02', 2366);
INSERT INTO LoadSample2 VALUES('PC1',  '2014-02-05', 2366);
INSERT INTO LoadSample2 VALUES('PC1',  '2014-02-07',  985);
INSERT INTO LoadSample2 VALUES('PC1',  '2014-02-08',  780);
INSERT INTO LoadSample2 VALUES('PC1',  '2014-02-12', 1000);
INSERT INTO LoadSample2 VALUES('PC2',  '2014-02-01',  999);
INSERT INTO LoadSample2 VALUES('PC2',  '2014-02-02',   50);
INSERT INTO LoadSample2 VALUES('PC2',  '2014-02-05',  328);
INSERT INTO LoadSample2 VALUES('PC2',  '2014-02-07',  913);
INSERT INTO LoadSample2 VALUES('PC3',  '2014-02-01', 2000);
INSERT INTO LoadSample2 VALUES('PC3',  '2014-02-02', 1000);


--리스트11 ②의 쿼리를 그대로 실행 시켜 본다 :잘 되지 않음
SELECT sample_date AS cur_date,
       MIN(sample_date)
           OVER (ORDER BY sample_date ASC
                 ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS latest_1,
       MIN(sample_date)
           OVER (ORDER BY sample_date ASC
                 ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING) AS latest_2,
       MIN(sample_date)
           OVER (ORDER BY sample_date ASC
                 ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING) AS latest_3
  FROM LoadSample2;


--리스트12 윈도우 함수 버전 (machine 열 없음)
SELECT sample_date AS cur_date,
       MIN(sample_date) 
          OVER (ORDER BY sample_date ASC
                ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS latest_1,
       MIN(sample_date) 
          OVER (ORDER BY sample_date ASC
                ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING) AS latest_2,
       MIN(sample_date) 
          OVER (ORDER BY sample_date ASC
                ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING) AS latest_3
  FROM LoadSample2
 GROUP BY sample_date;



--윈도우 함수 버전 (machine 열 있음)
SELECT machine,
       sample_date AS cur_date,
       MIN(sample_date) 
          OVER (PARTITION BY machine ORDER BY sample_date ASC
                ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS latest_1,
       MIN(sample_date) 
          OVER (PARTITION BY machine ORDER BY sample_date ASC
                ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING) AS latest_2,
       MIN(sample_date) 
          OVER (PARTITION BY machine ORDER BY sample_date ASC
                ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING) AS latest_3
  FROM LoadSample2
 GROUP BY machine, sample_date;


--리스트13 자기결합버전（machine열 없음）
SELECT LS0.sample_date AS cur_date,
       MAX(LS1.sample_date) AS latest_1,
       MAX(LS2.sample_date) AS latest_2,
       MAX(LS3.sample_date) AS latest_3
  FROM LoadSample2 LS0
           LEFT OUTER JOIN LoadSample2 LS1
             ON LS1.sample_date < LS0.sample_date
             LEFT OUTER JOIN LoadSample2 LS2
               ON LS2.sample_date < LS1.sample_date
               LEFT OUTER JOIN LoadSample2 LS3
                 ON LS3.sample_date < LS2.sample_date
 GROUP BY LS0.sample_date;


--리스트14 윈도우 함수버전（machine열 있음）
SELECT machine,
       sample_date AS cur_date,
       MIN(sample_date)
           OVER (PARTITION BY machine ORDER BY sample_date ASC
                 ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS latest_1,
       MIN(sample_date)
           OVER (PARTITION BY machine ORDER BY sample_date ASC
                 ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING) AS latest_2,
       MIN(sample_date)
           OVER (PARTITION BY machine ORDER BY sample_date ASC
                 ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING) AS latest_3
  FROM LoadSample2
 GROUP BY machine, sample_date;

--리스트15 자기결합버전（machine열 있음）
SELECT LS0.machine AS machine, 
       LS0.sample_date AS sample_date,
       MAX(LS1.sample_date) AS latest_1,
       MAX(LS2.sample_date) AS latest_2,
       MAX(LS3.sample_date) AS latest_3
  FROM LoadSample2 LS0
           LEFT OUTER JOIN LoadSample2 LS1
             ON LS1.sample_date < LS0.sample_date
             LEFT OUTER JOIN LoadSample2 LS2
               ON LS2.sample_date < LS1.sample_date
               LEFT OUTER JOIN LoadSample2 LS3
                 ON LS3.sample_date < LS2.sample_date
 GROUP BY LS0.machine, LS0.sample_date
 ORDER BY machine, sample_date;
