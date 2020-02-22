insert into crm_tico_version_22_3  
select 
a.foreign_teacher_id, 
a.status,
a.college_score,
a.degree_score,
a.major_score,
a.cret_score,
a.inte_score,
a.expe_score,
if(beha_score_months_num = 0,0,b.beha_score/b.beha_score_months_num) as beha_score,
if(comm_score_months_num = 0,0,b.comm_score/b.comm_score_months_num) as comm_score,
if(reac_class_rate_score_months_num = 0,0,b.reac_class_rate_score/b.reac_class_rate_score_months_num) as reac_class_rate_score,
if(coml_class_rate_score_months_num = 0,0,b.coml_class_rate_score/b.coml_class_rate_score_months_num) as coml_class_rate_score,
if(less_comm_score_months_num = 0,0,b.less_comm_score/b.less_comm_score_months_num) as less_comm_score,
if(teach_abli_score_months_num = 0,0,b.teach_abli_score/b.teach_abli_score_months_num) as teach_abli_score,
if(teach_trai_score_months_num = 0,0,b.teach_trai_score/b.teach_trai_score_months_num) as teach_trai_score,
if(evaluate_score_months_num = 0,0,b.evaluate_score/b.evaluate_score_months_num) as evaluate_score,
if(teach_effe_score_months_num = 0,0,b.teach_effe_score/b.teach_effe_score_months_num) as teach_effe_score,
if(comp_score_months_num = 0,0,b.comp_score/b.comp_score_months_num) as comp_score,
entry_mouths_score,
online_time_score,
listen_test_time_score,
open_class_time_score,
0 as reocrd_score,
0 as train_score,
first_name,
last_name,
a.month	 
from  crm_tico_version_3_22 a
inner join 
(select 
foreign_teacher_id,
sum(beha_score) beha_score,
sum(comm_score) as comm_score,
sum(reac_class_rate_score) as reac_class_rate_score,
sum(coml_class_rate_score) as coml_class_rate_score,
sum(less_comm_score) as less_comm_score,
sum(teach_abli_score) as teach_abli_score,
sum(teach_trai_score) as teach_trai_score,
sum(evaluate_score) as evaluate_score,
sum(teach_effe_score) as teach_effe_score,
sum(if(status = 1,comp_score,0)) as comp_score,
'2017-12' as month,
count(if(month <= '2017-12' and beha_score is not null and beha_score <>0,1,null)) as beha_score_months_num,
count(if(month <= '2017-12' and comm_score is not null and comm_score <>0,1,null)) as comm_score_months_num,
count(if(month <= '2017-12' and reac_class_rate_score is not null and reac_class_rate_score <>0,1,null)) as reac_class_rate_score_months_num,
count(if(month <= '2017-12' and coml_class_rate_score is not null and coml_class_rate_score <>0,1,null)) as coml_class_rate_score_months_num,
count(if(month <= '2017-12' and less_comm_score is not null and less_comm_score <>0,1,null)) as less_comm_score_months_num,
count(if(month <= '2017-12' and teach_abli_score is not null and teach_abli_score <>0,1,null)) as teach_abli_score_months_num,
count(if(month <= '2017-12' and teach_trai_score is not null and teach_trai_score <>0,1,null)) as teach_trai_score_months_num,
count(if(month <= '2017-12' and evaluate_score is not null and evaluate_score <>0,1,null)) as evaluate_score_months_num,
count(if(month <= '2017-12' and teach_effe_score is not null and teach_effe_score <>0,1,null)) as teach_effe_score_months_num,
count(if(status=1,1,null)) as comp_score_months_num
from crm_tico_version_3_22
where month <= '2017-12'
group by foreign_teacher_id) b
on a.foreign_teacher_id = b.foreign_teacher_id
where  a.month = '2017-12'
group by foreign_teacher_id