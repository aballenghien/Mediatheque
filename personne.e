class PERSONNE 

creation{ANY}
	make

feature{}
	nom: STRING
	prenom: STRING

feature {ANY}
	make is
		do
			nom:= ""
			prenom:= ""
		end
	
	set_nom (n : STRING) is
		do
			nom := n
		end

	set_prenom (p: STRING) is
		do
			prenom := p
		end
		
	get_nom : STRING is
		do
			Result := nom
		end
	
	get_prenom : STRING is
		do
			Result := prenom
		end
		
	to_string : STRING is
		do 
			Result := "PERSONNE:{nom:"+nom+", prenom:"+prenom+"}"
		end

end
