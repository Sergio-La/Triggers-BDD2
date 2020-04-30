--Creand0 tabla materias--
create table Materias (
 mat_cod int not null,
 mat_nom varchar(30),
 primary key(mat_cod)
);

--Creando tabla salones--
create table Salones (
 sal_cod int not null unique,
 sal_cur varchar (8) not null,
 primary key(sal_cod, sal_cur)
);

--Creando tabla estudianes--
create table Estudiantes (
 est_cod int not null,
 est_nom varchar(10),
 est_ap varchar(10),
 est_cur int,
 primary key(est_cod),
 foreign key (est_cur) references Salones(sal_cod)
 );
 
 --Creando tabla salon-estudiante--
 create table Sal_est(
 se_estcod int not null,
 se_salcod int not null,
 primary key(se_estcod),
 foreign key (se_estcod) references Estudiantes(est_cod),
 foreign key (se_salcod) references Salones(sal_cod)
);
 
 --Creando tabla estudiante-materia--
create table Est_mat(
 em_estcod int not null,
 em_matcod int not null,
 em_nota float,
 primary key(em_estcod,em_matcod),
 foreign key (em_estcod) references Estudiantes(est_cod),
 foreign key (em_matcod) references Materias(mat_cod)
);

--Creando tabla profesores--
create table Profesores (
 pro_cod int not null,
 pro_nom varchar(10),
 pro_ap varchar(10),
 primary key(pro_cod)
 );

--Creando tabla salones profesores--
create table Sal_pro(
 sp_procod int not null,
 sp_salcod int not null,
 primary key(sp_salcod),
 foreign key (sp_procod) references Profesores (pro_cod),
 foreign key (sp_salcod) references Salones(sal_cod)
);

--Creando tabla Profesores-materia--
create table Pro_mat(
 pm_procod int not null,
 pm_matcod int not null,
 pm_matriculados int,
 primary key (pm_procod,pm_matcod),
 foreign key (pm_procod) references Profesores (pro_cod),
 foreign key (pm_matcod) references Materias (mat_cod)
);

--Creando tabla Auditorias--
create table auditoria (
	llave_audi serial not null,
	nombretabla varchar (30) not null,
	operacion varchar(6) not null,
	valoranterior text,
	valornuevo text,
	fech_hora timestamp without time zone not null,
	usuario varchar (30),
	primary key (llave_audi)
);

--creacion de la funcion para insertar en la tabla auditoria--
create or replace function fn_auditorio() returns trigger as
$$
begin
	if (TG_OP = 'DELETE') then insert into auditoria (nombretabla, operacion, valoranterior, valornuevo, fech_hora, usuario)
	values (TG_TABLE_NAME,'Delete',old,null, now(),user);
	return old;
	
	elsif (TG_OP = 'UPDATE')then insert into auditoria (nombretabla, operacion, valoranterior, valornuevo, fech_hora, usuario)
	values (TG_TABLE_NAME,'Update',old,new, now(),user);
	return new;
	
	elsif (TG_OP = 'INSERT')then insert into auditoria (nombretabla, operacion, valoranterior, valornuevo, fech_hora, usuario)
	values (TG_TABLE_NAME,'Insert',old,new, now(),user);
	return new;
	end if;
	return null;
end;
$$
language 'plpgsql'

--Creacion de triggers para las diferentes tablas--
create trigger auditoria after insert or update or delete on materias for each row execute procedure fn_auditorio();

--Analogo al anterior se hace con todas la tablas--
create trigger auditoria after insert or update or delete on salones for each row execute procedure fn_auditorio();

create trigger auditoria after insert or update or delete on estudiantes for each row execute procedure fn_auditorio();

create trigger auditoria after insert or update or delete on Sal_est for each row execute procedure fn_auditorio();

create trigger auditoria after insert or update or delete on Est_mat for each row execute procedure fn_auditorio();

create trigger auditoria after insert or update or delete on Profesores for each row execute procedure fn_auditorio();

create trigger auditoria after insert or update or delete on Sal_pro for each row execute procedure fn_auditorio();

create trigger auditoria after insert or update or delete on Pro_mat for each row execute procedure fn_auditorio();


--Insertando en las tablas--
--Materias--
insert into Materias values(1010,'Estadisticas.');
insert into Materias values(1020,'Bases de datos.');
insert into Materias values(1030,'Calculo 4.');
--Salones--
insert into Salones values(2010,'11-1');
insert into Salones values(2020,'11-2');
insert into Salones values(2030,'10-1');
--Estudiantes--
insert into Estudiantes values (3010,'Rodrigo','Fernandez',2010);
insert into Estudiantes values (3020,'Nacho','Monrreal',2020);
insert into Estudiantes values (3030,'Nicole','Aguirre',2030);
--profesores--
insert into Profesores values (4010,'Juan','Rodriguez');
insert into Profesores values (4020,'Luis','Diaz');
insert into Profesores values (4030,'Victor','Gutierrez');
--Profesor-Materia--
insert into Pro_mat values (4010,1010,12);
insert into Pro_mat values (4020,1010,17);
insert into Pro_mat values (4030,1020,23);
--Salones-Estudiantes--
insert into Sal_est values (3010,2020);
insert into Sal_est values (3020,2020);
insert into Sal_est values (3030,2030);
--Salones-Profesores--
insert into Sal_pro values (4010,2020);
insert into Sal_pro values (4030,2030);
--Estudiantes-materia--
insert into est_mat values(3010,1010,3.2);


--Triggers pre y post para la tabla materia--
create or replace function insertestudiantes() returns trigger as
$$
	begin
		if (new.est_cod is null) then
		     raise exception 'Debe insertar el codigo del estudiante';
		end if;
		if ((select count(*) from salones where sal_cod=new.est_cur)=0) then
		     raise exception 'El codigo curso debe ser uno existente en la tabla salones';
		end if;		
	return new;
	end;
$$
language 'plpgsql';

create trigger insertestudiantes before insert on estudiantes for each row execute procedure insertestudiantes();




 --Triggers pre y post para la tabla Estudiantes--
create or replace function insertestudiantes() returns trigger as
$$
	begin
		if (new.est_cod is null) then
		     raise exception 'Debe insertar el codigo del estudiante';
		end if;
		if (exists (select count(*) from salones where sal_cod=new.est_cur)) then
		     raise exception 'El codigo curso debe ser uno existente en la tabla salones';
		end if;		
	return new;
	end;
$$
language 'plpgsql';

create trigger insertestudiantes before insert on estudiantes for each row execute procedure insertestudiantes();

create or replace function upest() returns trigger as
$$
	begin
		if (new.est_cod =old.est_cod or new.est_cod =old.est_cod) then
		     raise exception 'La actualizacion fue innecesaria los datos quedaron iguales';
		end if;	
	return new;
	end;
$$
language 'plpgsql';
create trigger upest after update on estudiantes for each row execute procedure upest();
--Triggers pre y post para la tabla Profesores--
create or replace function insertarpro() returns trigger as
$$
	begin
		if (new.pro_cod is null) then
		     raise exception 'Debe insertar el codigo del profesror';
		end if;
		if (exists(select * from profesores where pro_cod=new.pro_cod)) then
		     raise exception 'El codigo que desea insertar ya existe, debe ser unico';
		end if;		
	return new;
	end;
$$
language 'plpgsql';
create trigger insertarpro before insert on Profesores for each row execute procedure insertarpro();

create or replace function borrapro() returns trigger as
$$
	begin
		if (not exists (select * from profesores where pro_cod=old.pro_cod)) then
		     raise exception 'Borrado exitoso';
		end if;	
	return old;
	end;
$$
language 'plpgsql';

create trigger borrapro after delete on profesores for each row execute procedure borrapro();
--Triggers para estudiante materias--create or replace function Insertnota() returns trigger as
create or replace function Insertnota() returns trigger as
$$
	begin
		if ((select count(*) from estudiantes where est_cod=new.em_estcod)=0) then
		     raise exception 'El codigo del estudiante debe coincidir con uno de la tabla estudiante';
		end if;
		if(new.em_nota >5 or new.em_nota<0) then
		    raise exception 'El formato de nota permtido es de 0 a 5';
		end if;
	return new;
	end;
$$
language 'plpgsql';

create trigger Insertnota before insert on est_mat for each row execute procedure Insertnota();

--Mientras el sueldo se mayor al promedio de sueldos irle restanfo 1%--
create or replace function añadirsuel() returns trigger as
$$
	begin
		if (new.sueldo > (select avg (sueldo) from profesores)) then
		     update profesores set sueldo = new.sueldo - (new.sueldo*0.01) where pro_cod = new.pro_cod;
		end if;	
	return new;
	end;
$$
language 'plpgsql';

create trigger añadirsuel after insert or update on profesores for each row execute procedure añadirsuel();