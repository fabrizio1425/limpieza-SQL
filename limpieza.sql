create database clean;
use clean;

-- limpieza paso a paso

select * from limpieza limit 10;
select * from limpieza 

-- crear procedimiento almacenado
DELIMITER //
create procedure limp()
begin
	select*from limpieza;
end //
DELIMITER ;

-- llamar al procedimiento almacenado
CALL limp();

-- renombrar columnas con caracteres especiales
alter table limpieza change column `ï»¿Id?empleado`id_emp varchar(20) null;
alter table limpieza change column `gÃ©nero`Gender varchar(20) null;

-- ver valores duplicados
select id_emp,count(*) as cantidad_duplicado from limpieza group by id_emp having count(*)>1;

select count(*) as cantidad_duplicado 

from (select id_emp,count(*) as cantidad_duplicado from limpieza group by id_emp having count(*)>1)as sub_query;

-- eliminar duplicados
rename table limpieza to conduplicados;

create temporary table temp_limpieza 
as select distinct * from conduplicados;

select count(*) original from conduplicados;
select count(*) original from temp_limpieza;

create table limpieza as select * from temp_limpieza;

call limp();

drop table conduplicados;

-- renombrar columnas
alter table limpieza change column Apellido Last_name varchar (50) null;
alter table limpieza change column star_date Star_date varchar (50) null;

-- ver los metadatos
describe limpieza;

call limp();

-- eliminar los espacios de los nombres y apellidos, modificar estos nombres y apellidos y desactivar el modo seguro
set sql_safe_updates=0;

select name from limpieza where length(name) - length( trim(name)) >0;
select name, trim(name) as name from limpieza where length(name) - length( trim(name)) >0;
update limpieza set name=trim(name) where length(name) - length(trim(name)) >0;

select last_name, trim(last_name) as last_name from limpieza where length(last_name) - length(trim(last_name)) >0;
update limpieza set last_name=trim(last_name) where length(last_name) - length(trim(last_name)) >0;

-- buscar y reemplazar
select gender,
case
	when gender='hombre' then 'male'
    when gender='mujer' then 'female'
    else 'other'
end as gender1
from limpieza;

update limpieza set gender = 
case
	when gender='hombre' then 'male'
    when gender='mujer' then 'female'
    else 'other'
end;

call limp();

describe limpieza;

alter table limpieza modify column type TEXT;

select type, 
case
	when type=1 then 'remote'
    when type=0 then 'hybrid'
    else 'other'
end as ejemplo
from limpieza;

update limpieza set type=
case
	when type=1 then 'remote'
    when type=0 then 'hybrid'
    else 'other'
end;

-- remplazar $ y , y dar formato de int a salary que era texto
select salary,
				cast(trim(replace(replace(salary,'$',''),',','')) as decimal(15,2)) as salasry1 from limpieza;

update limpieza set salary = cast(trim(replace(replace(salary,'$',''),',','')) as decimal(15,2));

alter table limpieza modify column salary int null;

describe limpieza;

-- ajustar formato de fechas
select birth_date, case
	when birth_date like '%/%' then date_format(str_to_date(birth_date,'%m/%d/%Y'),'%m-%d-%Y')
    else null
    end as new_birth_date
    from limpieza;
    
update limpieza 
set birth_date = case 
	when birth_date like '%/%' then date_format(str_to_date(birth_date, '%m/%d/%Y'),'%Y-%m-%d')
    when birth_date like '%-%' then date_format(str_to_date(birth_date, '%m-%d-%y'),'%Y-%m-%d')
    else null
end;

call limp();
    
alter table limpieza modify column birth_date date;

select Star_date, case
	when Star_date like '%/%' then date_format(str_to_date(star_date,'%m/%d/%Y'),'%Y-%m-%d')
    else null
    end as new_star_date
    from limpieza;
    
update limpieza 
set Star_date = case
	when Star_date like '%/%' then date_format(str_to_date(star_date,'%m/%d/%Y'),'%Y-%m-%d')
    else null
end;

call limp();
    
alter table limpieza modify column Star_date date;

-- calculos con fechas
-- calcular la edad de los trabjadores

alter table limpieza add column age int;
select name,birth_date,Star_date, timestampdiff(year,birth_date,Star_date) as edad_de_ingreso from limpieza;
-- curdarte para poner la fecha actual y calcular la edad
update limpieza set age =
     timestampdiff(year,birth_date,curdate());

call limp();


-- funciones de texto , crear correo
select concat(substring_index(name,' ',1),'_',substring(last_name,1,2),'.',substring(type,1,1),'@consulting.com') as email from limpieza;

alter table limpieza add column email varchar(100);

update limpieza set email = concat(substring_index(name,' ',1),'_',substring(last_name,1,2),'.',substring(type,1,1),'@consulting.com');

call limp();

-- los datos ya estarian listos para exportar aqui algunos ejemplos de consultas

select Id_emp,name,last_name,age,gender,area,salary,email,finish_date from limpieza
where finish_date <= curdate() or finish_date is null
order by name, last_name;

select area, count(*) as cantidad_empleados from limpieza
group by area
order by cantidad_empleados;

-- datos obtenidos ya limpios
call limp();

    



