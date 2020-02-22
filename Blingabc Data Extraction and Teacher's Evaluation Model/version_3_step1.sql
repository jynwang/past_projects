
insert into  crm_tico_version_3_22  

select 
t0.foreign_teacher_id,
if(evaluate_score = 75,1,0) as status,
if(college_score is not null ,college_score,0) as college_score,
if(degree_score is not null ,degree_score,0) as degree_score,
if(major_score is not null ,major_score,0) as major_score,
if(cret_score is not null ,cret_score,0) as cret_score,
if(inte_score is not null ,inte_score,0) as inte_score,
if(expe_score is not null ,expe_score,0) as expe_score,
beha_score ,
comm_score,
reac_class_rate_score,
coml_class_rate_score,
less_comm_score,
teach_abli_score,
teach_trai_score,
if(evaluate_score is not null,evaluate_score,0) as evaluate_score,
teach_effe_score,
if(evaluate_score=75,100-comp_score,0) as comp_score,
if(entry_mouths_score is not null,entry_mouths_score,0) as entry_mouths_score ,
if(online_time_score is not null,online_time_score,0) as online_time_score ,
if(listen_test_time_score is not null,listen_test_time_score,0) as listen_test_time_score ,
if(open_class_time_score is not null,open_class_time_score,0) as open_class_time_score ,
first_name ,
last_name,
 '2017-12' as month
from  
(select 
a.id as foreign_teacher_id,
college_score,degree_score,major_score,cret_score,inte_score,expe_score,first_name,last_name
from 
crm_headmaster a

inner join

(SELECT 
foreign_id,
max(case when university_name is not null and university_name not like '%other%' then 100
else 0 end) as  college_score,
max(case when upper(trim(name)) = 'LEvel_1' then 10
     when upper(trim(name)) = 'LEvel_2' then 30
     when upper(trim(name)) = 'LEvel_3' then 50
     when upper(trim(name)) = 'LEvel_4' then 80
     when upper(trim(name)) = 'LEvel_5' then 100
     else 0 end) as degree_score,
max(case when lower(major) like '%english%' or
     lower(major) like 'esl' or 
	 lower(major) like 'linguistic' or 
	 lower(major) like 'education' or
	 lower(major) like 'language' or
	 lower(major) like 'teaching' or
	 lower(major) like 'primary' or
	 lower(major) like 'elementary'  or
	 lower(major) like 'teel' or 
	 lower(major) like 'tesol' then 100
     else 0 end) as major_score
from crm_foreign_teacher_education
group by foreign_id) b 
on a.foreign_id = b.foreign_id
inner join 
(select 
id,
max(case when lower(certificate) like '%cert_1%' then 100
     when lower(certificate) like '%cert_2%' then  70
     else 0 end) as cret_score,
max(interview_score) as inte_score,
max(case when lower(teaching_experience) ='stage_5' then 100
     when lower(teaching_experience) ='stage_4' then 80
     when lower(teaching_experience) ='stage_3' then 50
     when lower(teaching_experience) ='stage_2' then 30
     else 10 end) as expe_score,
max(first_name) as first_name,
max(last_name) as last_name
from crm_foreign_teacher
group by id) c
on a.foreign_id = c.id
where a.role_type =2 and a.teacher_status =1 and  substr(launch_date,1,7) <=  '2017-12') t0

inner join 

(select 
t0.id,
if(t1.score is not null,t1.score,0) as beha_score,
if(t2.score is not null,t2.score,0) as comm_score,
CASE
    WHEN  t3.score> 0.99
    AND t3.score <= 1 THEN
    	100
    WHEN t3.score > 0.95
    AND t3.score <= 0.99 THEN
    	80
    WHEN t3.score > 0.90
    AND t3.score <= 0.95 THEN
    	60
    WHEN t3.score > 0.80
    AND t3.score <= 0.90 THEN
    	20
    WHEN t3.score >= 0
    AND t3.score <= 0.80 THEN
    	0
    else 0 END AS reac_class_rate_score,
CASE
    WHEN  t4.score> 0.99
    AND t4.score <= 1 THEN
    	100
    WHEN t4.score > 0.95
    AND t4.score <= 0.99 THEN
    	80
    WHEN t4.score > 0.90
    AND t4.score <= 0.95 THEN
    	60
    WHEN t4.score > 0.80
    AND t4.score <= 0.90 THEN
    	20
    WHEN t4.score >= 0
    AND t4.score <= 0.80 THEN
    	0
    else 0 END AS coml_class_rate_score,
case when t5.score = 1 then 100
     when t5.score >=0.95 and t5.score <1 then 80
	 when t5.score >= 0.90 and t5.score <0.95 then 60 
	 when t5.score >= 0.80 and t5.score <0.9 then 20
     else 0 end as less_comm_score,
if(t6.score is not null,t6.score,0) as teach_abli_score,
if(t7.score is not null, t7.score,0) as teach_trai_score,
if(t8.score is not null,t8.score,0)  teach_effe_score,
if(t9.score is not null ,t9.score,0) as comp_score
from 
crm_headmaster t0
left join 

(select headmaster_id as foreign_teacher_id,
avg(score) as score,substr(month,1,7) as month
from crm_foreign_tico_behaviour_norm 
group by headmaster_id,substr(month,1,7)) t1

on t0.id = t1.foreign_teacher_id and t1.month =  '2017-12'
left join 
(select headmaster_id as foreign_teacher_id,
avg(score) as score,substr(month,1,7) as month
from crm_foreign_tico_communications 
group by headmaster_id,substr(month,1,7)) t2
on t0.id=t2.foreign_teacher_id and t2.month =  '2017-12'
left join 
(SELECT a.foreign_teacher_id, 
      count(if(a.state IN (20, 40) OR (a.state = 30 AND pt.valid_period > 0),1,null))/count(1) as score,
	  substr(a.begin_date, 1, 7) as month 
FROM crm_class_lesson a
	 LEFT JOIN crm_headmaster b ON a.foreign_teacher_id = b.id
	 LEFT JOIN crm_class_info c ON c.id = a.class_id
	 LEFT JOIN (
		SELECT * FROM
			crm_eeo_person_time
		WHERE
			type = 1
	) pt ON a.id = pt.crm_lesson_id
	AND a.foreign_teacher_id = pt.person_id
WHERE
	 
	    b.role_type = 2
	AND a.course_type IN (10, 20, 30,60, 70, 90)
	AND c.state = 20
GROUP BY foreign_teacher_id , substr(a.begin_date, 1, 7)) t3
on t0.id =t3.foreign_teacher_id and t3.month =  '2017-12'
left join 
(SELECT a.foreign_teacher_id, 
      count(if(a.state IN (20, 40) ,1,null))/count(1) as score,
	  substr(a.begin_date, 1, 7) as month 
FROM crm_class_lesson a
	 LEFT JOIN crm_headmaster b ON a.foreign_teacher_id = b.id
	 LEFT JOIN crm_class_info c ON c.id = a.class_id
	 LEFT JOIN (
		SELECT * FROM
			crm_eeo_person_time
		WHERE
			type = 1
	) pt ON a.id = pt.crm_lesson_id
	AND a.foreign_teacher_id = pt.person_id
WHERE
	 
	    b.role_type = 2
	AND a.course_type IN (10, 20,30, 60, 70, 90)
	AND c.state = 20
GROUP BY foreign_teacher_id , substr(a.begin_date, 1, 7)) t4
on t0.id = t4.foreign_teacher_id and t4.month =  '2017-12'

left join 
(
SELECT
	cl.foreign_teacher_id,
	sum(IF (timestampdiff(MINUTE, ec.create_date,cl.end_date) / 60 < 24 AND ec.STATUS = 1, 1, 0))/count(1)  as score,
	substr(cl.begin_date, 1, 7) as month 
FROM
	`crm_student_lesson` sl
LEFT JOIN `crm_eeo_comment` ec ON sl.class_lesson_id = ec.class_lesson_id
AND ec.student_num = sl.stu_num
LEFT JOIN `crm_student` cs ON cs.stu_num = sl.stu_num
LEFT JOIN `crm_class_lesson` cl ON cl.id = sl.class_lesson_id
LEFT JOIN `crm_class_info` ci ON cl.class_id = ci.id
LEFT JOIN crm_headmaster ht ON ht.id = cl.foreign_teacher_id
WHERE
    cl.course_type IN (10, 20,30, 60, 70, 90)
AND	sl.union_status = 1
AND ht.role_type = 2
AND sl.stu_state = 20
AND cl.state = 20
AND cl.course_type != 40
AND ci.live_contain < 14
GROUP BY
	cl.foreign_teacher_id,substr(cl.begin_date, 1, 7)) t5
on t0.id= t5.foreign_teacher_id and t5.month =  '2017-12'

left join 
(SELECT 
headmaster_id as foreign_teacher_id,
avg(score) as score,
substr(month,1,7) as month 
from crm_foreign_tico_classroom_teaching_tmp
where headmaster_id is not null
group by headmaster_id,substr(month,1,7)) t6
on t0.id=t6.foreign_teacher_id and t6.month =  '2017-12'

left join 
(SELECT 
headmaster_id as foreign_teacher_id,
score,
substr(month,1,7) as month 
from crm_foreign_tico_training
where headmaster_id is not null
group by headmaster_id,substr(month,1,7)) t7
on t0.id = t7.foreign_teacher_id and t7.month =  '2017-12'

left join 
(SELECT
	foreign_teacher_id,
	avg(IF (a.totle IS NOT NULL, a.totle, 0)) AS score,
	SUBSTR(b.begin_date, 1, 7) as month 
FROM
	crm_question_student a
LEFT JOIN crm_class_lesson b ON a.class_lesson_id = b.id
WHERE
	  a.state = 20
GROUP BY
	foreign_teacher_id,SUBSTR(b.begin_date, 1, 7)) t8
on t0.id = t8.foreign_teacher_id and t8.month =  '2017-12'

left join 
(select 
headmaster_id as foreign_teacher_id,
if(light_num*5+common_num*10+mode_num*10+serious_num*50+dead_num*100<=100,
light_num*5+common_num*10+mode_num*10+serious_num*50+dead_num*100,0)
as score,
month 
from 
(select headmaster_id,
       count(if(trim(degree)='轻微',1,null)) as light_num,
     count(if(trim(degree)='一般',1,null)) as common_num,
     count(if(trim(degree)='中度',1,null)) as mode_num,
       count(if(trim(degree)='严重',1,null)) as serious_num,
       count(if(trim(degree)='致命',1,null)) as dead_num ,
substr(complaint_date,1,7) as month 	   
from crm_foreign_tico_complaint 
where trim(result) = '有效' 
group by headmaster_id,substr(complaint_date,1,7)) tab_1) t9
on t0.id = t9.foreign_teacher_id and t9.month =  '2017-12'
where t0.role_type =2 and t0.teacher_status =1 and  substr(launch_date,1,7) <= '2017-12') t1

on t0.foreign_teacher_id = t1.id

left join 

(SELECT
	id,
	CASE
WHEN entry_mouths > 89 THEN
	100

WHEN entry_mouths > 59
AND entry_mouths <= 89 THEN
	80

WHEN entry_mouths > 35
AND entry_mouths <= 59 THEN
	60
WHEN entry_mouths > 17
AND entry_mouths <= 35 THEN
	40

WHEN entry_mouths > 5
AND entry_mouths <= 17 THEN
	20

WHEN entry_mouths >= 0
AND entry_mouths <= 5 THEN
	0
END entry_mouths_score
FROM
	(		SELECT
		id,

		IF (
			entry_time IS NOT NULL,
			PERIOD_DIFF(
				concat(substr( '2017-12',1,4),substr( '2017-12',6,2)),
				DATE_FORMAT(entry_time, '%Y%m')
			),
			PERIOD_DIFF(
				concat(substr( '2017-12',1,4),substr( '2017-12',6,2)),
				DATE_FORMAT(launch_date, '%Y%m')
			)
		) AS entry_mouths,
		entry_time,
		launch_date
	FROM
		crm_headmaster
	WHERE
		launch_date IS NOT NULL
	AND job_status = 1
	AND role_type = 2 and substr(launch_date,1,7) <=  '2017-12'
	) tab) tab_2
on t0.foreign_teacher_id =tab_2.id

left join 

(SELECT
	a.foreign_teacher_id,
	CASE
WHEN sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 > 3599 THEN
	100
WHEN sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 > 2399
AND sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 <= 3599 THEN
	80
WHEN sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 > 1439
AND sum(
		timestampdiff(MINUTE,a.begin_date,a.end_date)
) / 60 <= 2399 THEN
	60
WHEN sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 > 719
AND sum(
		timestampdiff(MINUTE,a.begin_date,a.end_date)
) / 60 <= 1439 THEN
	40
	
WHEN sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 > 239
AND sum(
		timestampdiff(MINUTE,a.begin_date,a.end_date)
) / 60 <= 719 THEN
	20
WHEN sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 >= 0
AND sum(
		timestampdiff(MINUTE, a.begin_date,a.end_date)
) / 60 <= 239 THEN
	0
END AS online_time_score
FROM
	crm_class_lesson a
LEFT JOIN crm_headmaster b ON a.foreign_teacher_id = b.id
LEFT JOIN crm_class_info c ON c.id = a.class_id
WHERE
	b.role_type = 2
AND a.course_type IN (10, 20,30, 60, 70, 90)
and substr(begin_date,1,7) <=  '2017-12'
AND c.state = 20
AND a.state = 20
GROUP BY
	foreign_teacher_id) tab_3
on t0.foreign_teacher_id = tab_3.foreign_teacher_id

left join 

(SELECT
	foreign_teacher_id,
	CASE
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 > 2000 THEN
	100
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 >= 501
AND sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 <= 2000 THEN
	80
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 > 100
AND sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 <= 500 THEN
	30
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 >= 0
AND sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 <= 100 THEN
	10
END AS listen_test_time_score
FROM
	crm_class_lesson
WHERE
	trim(course_type_name) = '试听'
AND course_type != 40
and substr(begin_date,1,7) <=  '2017-12'
AND foreign_teacher_id IS NOT NULL
GROUP BY
	foreign_teacher_id) tab_4
on t0.foreign_teacher_id = tab_4.foreign_teacher_id

left join 
(
SELECT
	foreign_teacher_id,
	CASE
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 > 2000 THEN
	100
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 >= 501
AND sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 <= 2000 THEN
	80
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 > 100
AND sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 <= 500 THEN
	30
WHEN sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 >= 0
AND sum(
		timestampdiff(MINUTE, begin_date,end_date)
) / 60 <= 100 THEN
	10
END AS open_class_time_score
FROM
	crm_class_lesson
WHERE
	trim(course_type_name) = '公开课'
AND course_type != 40
and substr(begin_date,1,7) <= '2017-12'
AND foreign_teacher_id IS NOT NULL
GROUP BY 
	foreign_teacher_id) tab_5
	
on t0.foreign_teacher_id = tab_5.foreign_teacher_id

left join

(SELECT
	foreign_teacher_id,
	CASE
WHEN sum(
		timestampdiff(MINUTE,begin_date,end_date)
) > 0 THEN
	75
ELSE
	0
END AS evaluate_score
FROM
	crm_class_lesson
WHERE
	course_type IN (10, 20, 30, 60, 70, 90)
AND foreign_teacher_id IS NOT NULL
and substr(begin_date,1,7) =  '2017-12'
GROUP BY
	foreign_teacher_id) t6
on t0.foreign_teacher_id = t6.foreign_teacher_id;

