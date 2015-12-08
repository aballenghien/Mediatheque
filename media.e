deferred class MEDIA

feature{}
	titre: STRING
	nombre_exemplaires: INTEGER

feature {ANY}
	make is 
		do
			titre:= ""
			nombre_exemplaires:= 1
		end
		
	to_string : STRING is
		--do
			deferred
			--Result:= "MEDIA : {titre : "+titre+", nombre_exemplaires : "+nombre_exemplaires.to_string+"}"
		end
	
	-- getter et setter
	set_titre (t: STRING) is
		do
			titre.copy(t)
		end

	set_nombre_exemplaires (nb : INTEGER) is
		do
			nombre_exemplaires := nb
		end
		
	get_titre : STRING is
		do
			Result:= titre
		end
		
	get_nombre_exemplaires : INTEGER is
		do
			Result:= nombre_exemplaires
		end
end

	
