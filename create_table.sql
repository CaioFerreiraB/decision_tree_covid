
create table agrega_bd as
with dt_max_covid as(
	select
		id_paciente,
		de_analito,
		max(dt_coleta) as dt_coleta
	from exames
	where upper(de_analito) like upper('%Coronavírus (2019-nCoV)%')
	group by 1,2
),
exames_bc as (
	select
		dm.id_paciente,
		ex.de_analito,
		max(ex.dt_coleta) as dt_coleta
	from exames ex inner join dt_max_covid dm on ex.id_paciente = dm.id_paciente
	where dm.dt_coleta <= ex.dt_coleta
	group by 1,2
),
bd_temp as(
	select 
		ex.id_paciente,
		pa.ic_sexo,
		date_part('year', CURRENT_DATE) - CAST(pa.aa_nascimento as int) as idade,
		pa.cd_pais,
		pa.cd_uf,
		pa.cd_municipio,
		ex.de_hospital,
		ex.de_analito,
		ex.de_resultado
	from exames ex inner join exames_bc bc on
							ex.id_paciente = bc.id_paciente
							and ex.de_analito = bc.de_analito
							and ex.dt_coleta = bc.dt_coleta
		inner join paciente pa on pa.id_paciente = ex.id_paciente
	where pa.aa_nascimento not in ('YYYY', 'AAAA')
)
select 
	ex.id_paciente,
	ex.ic_sexo,
	ex.idade,
	ex.cd_pais,
	ex.cd_uf,
	ex.cd_municipio,
	ex.de_hospital,
	case when upper(ex.de_analito) like upper('%Coronavírus (2019-nCoV)%') then 'test_covid' else ex.de_analito end as de_analito,
	ex.de_resultado
from bd_temp ex

