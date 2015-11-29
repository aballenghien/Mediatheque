class MEDIA

creation{ANY}
	make

feature{}
	titre: STRING
	nombre_exemplaires: INTEGER

feature {ANY}
	make is 
		do
			titre:= ""
			nombre_exemplaires:= 0
		
		end
		
	set_titre (t: STRING) is
		do
			titre:= t
			
		end

	set_nombre_exemplaires (nb : INTEGER) is
		do
			nombre_exemplaire:= nb
			
		end
		
	get_titre is
		do
			Result:= titre
		end
		
	get_nombre_exemplaires is
		do
			Result:= nombre_exemplaires
		end

end

	
