DROP FUNCTION IF EXISTS operacionesUsuarios(json); -- se tiene que dropear la funcion antes de volverla a crear porque le da amsiedad a postgres
create or replace FUNCTION operacionesUsuarios(in injson json, 
	out cmensaje character varying,
	out cjson character varying,
	out iestado smallint)
RETURNS record
LANGUAGE plpgsql
AS $function$
declare 
	data json;
	i json ; 
	opcion smallint ; 
	ipuesto smallint ;
	iusuario integer ; 
BEGIN
    --raise notice 'function executed %', injson;
	data := injson->'data'; 
	--raise notice 'function executed %', data;
	opcion := injson->'opc';
	cmensaje := 'exito';
    iestado := 1;
	if (opcion = 1) then -- LISTAR
		cjson = (select array_to_json(array_agg(
				jsonb_build_object('idUsuario', id, 'nombres', nombres, 'idPuesto', puesto) 
			)
		)
		from usuarios where status = 1); 
		cmensaje := 'Datos encontrados';
	elsif (opcion = 2) then -- CREAR
		for i in select * from json_array_elements(data) loop 
			ipuesto := (i->>'puesto')::INT;
			insert into usuarios(nombres,puesto) values (i->>'nombres', ipuesto);
		end loop ; 
		cmensaje := 'Usuarios Guardados';
	elsif (opcion = 3) then -- MODIFICAR 
		for i in select * from json_array_elements(data) loop 
			iusuario := (i->>'idUsuario')::INT;
			if exists (select * from usuarios where id = iusuario) then 
				update usuarios set nombres = i->>'nombres', puesto = (i->>'puesto')::INT where id = iusuario ;
				cmensaje := 'Usuarios modificados con exito';
			else 
				cmensaje := 'El usuario con id ' || iusuario || ' no existe '  ; 
				iestado := -1 ; 
				exit ; 
			end if ; 
		end loop ; 
	elsif (opcion = 4) then -- ELIMINAR
		for i in select * from json_array_elements(data) loop 
				iusuario := (i->>'idUsuario')::INT;
				if exists (select * from usuarios where id = iusuario) then 
					update usuarios set status = 0 where id = iusuario;
					cmensaje := 'Usuarios dado de baja con exito';
				else 
					cmensaje := 'El usuario con id ' || iusuario || ' no existe '  ; 
					iestado := -1 ; 
					exit ; 
				end if ; 
		end loop ; 
	else 
		cmensaje := 'Opcion no valida';
	end if ;
    RETURN;
END;
$function$;


//probar lectura 
select cmensaje,cjson,iestado from operacionesusuarios('{
"opc" : 1,
"data" : []
}') ;
//probar creacion 
select cmensaje,cjson,iestado from operacionesusuarios('{
"opc" : 2,
"data" : [
	{
		"nombres" : "Roberto Cervantes", 
		"puesto" : 9
	},
	{
		"nombres" : "Jose Carlos",
		"puesto" : 8
	}
]
}') ;
//probar modificacion 
select cmensaje,cjson,iestado from operacionesusuarios('{
"opc" : 3,
"data" : [
	{
		"idUsuario" : 9 ,
		"nombres" : "Monserrat Valenzuela", 
		"puesto" : 2
	},
	{
		"idUsuario" : 7 ,
		"nombres" : "Daniel Sauceda",
		"puesto" : 8
	}
]
}') ;
//probar eliminacion o borrado logico 
select cmensaje,cjson,iestado from operacionesusuarios('{
"opc" : 4,
"data" : [
	{
		"idUsuario" : 9 ,
		"nombres" : "Monserrat Valenzuela", 
		"puesto" : 2
	},
	{
		"idUsuario" : 7 ,
		"nombres" : "Daniel Sauceda",
		"puesto" : 8
	}
]
}') ;