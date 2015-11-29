class MEDIA

creation{ANY}
	make

feature{}
	titre: STRING
	nombre_exemplaires: INTEGER
	type: STRING

feature {ANY}
	make is 
		do
			titre:= ""
			nombre_exemplaires:= 1
			type:= ""
		
		end
		
	set_titre (t: STRING) is
		do
			titre:= t
			
		end

	set_nombre_exemplaires (nb : INTEGER) is
		do
			nombre_exemplaires:= nb
			
		end
	set_type (t: STRING) is
		do
			type:= t
			
		end
		
	get_titre : STRING is
		do
			Result:= titre
		end
		
	get_nombre_exemplaires : INTEGER is
		do
			Result:= nombre_exemplaires
		end		
		
	get_type : STRING is
		do
			Result:= type
		end
		
	to_string : STRING is
		do
			Result:= "MEDIA{titre:"+titre+", nombre_exemplaires:"+nombre_exemplaires.to_string+", type:"+type+"}"
		end

end

	
