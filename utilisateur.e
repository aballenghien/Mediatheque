class UTILISATEUR

creation{ANY}
	make

feature{}
	nom: STRING
	prenom: STRING
	identifiant: STRING
	admin: BOOLEAN

feature{ANY}
	make is
		do
			nom := ""
			prenom := ""
			identifiant := ""
			admin := False
			
		end

	set_nom (n: STRING) is
		do
			nom.copy(n)
		end
	
	set_prenom (p: STRING) is
		do
			prenom.copy(p)
		end
	
	set_identifiant (id: STRING) is
		do
			identifiant.copy(id)
		end	

	set_admin(ad: BOOLEAN) is
		do
			admin := ad
		end
	get_nom : STRING is
		do
			Result := nom
		end
	
	get_prenom : STRING is
		do
			Result := prenom
		end

	get_identifiant : STRING is
		do
			Result := identifiant
		end
		
	is_admin : BOOLEAN is
		do
			Result := admin
		end

	to_string : STRING is
		do
			Result:= "UTILISATEUR{nom:"+nom+", prenom:"+prenom+", identifiant:"+identifiant+"}"
		end
	
end

	
