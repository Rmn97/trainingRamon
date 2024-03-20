
select * from usuarios u ;
insert into usuarios(nombres,puesto) values ('Anahi' , 5);

select * from usuarios_puestos up ;

insert into usuarios_puestos(nombre,status) values ('Programador Jr', 1),
('Programador Semi Senior', 1),('Programador Senior', 1),('Tester jr', 1),
('Tester Semi Senior', 1),('Tester Senior', 1),('Arquitecto', 1) ,('Project Manager', 1),('Scrum Master', 1);

insert into proyectos_roles(nombre) values ('DESARROLLADOR BACKEND'),('DESARROLLADOR FRONTENDT'),('DESARROLLADOR FULLSTACK'),
('LIDER TECNICO'),('ARQUITECTO'),('TESTER FUNCIONAL'),('TESTER AUTOMATIZADOR'),('LIDER PROYECTO');

insert into proyectos(nombre,status,fechainicio,fechafin,descripcion)
values ('Projecto 1' , 1, now(),null,'Projecto de prueba');

select * from proyectos p ;