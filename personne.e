deferred class PERSONNE 

feature{}
	nom: STRING
	prenom: STRING

feature {ANY}
	make is
		do
			nom:= ""
			prenom:= ""
		end
	
	to_string : STRING is
		--do 
			deferred
			--Result := "PERSONNE : {nom : "+nom+", prenom : "+prenom+"}"
		end
	
	-- getter et setter
	set_nom (n : STRING) is
		do
			nom.copy(n)
		end

	set_prenom (p: STRING) is
		do
			prenom.copy(p)
		end
		
	get_nom : STRING is
		do
			Result := nom
		end
	
	get_prenom : STRING is
		do
			Result := prenom
		end
end
